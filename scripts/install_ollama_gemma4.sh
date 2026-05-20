#!/usr/bin/env bash
set -euo pipefail

echo "[install] Installing Ollama..."
# Official installer provided by Ollama.
install_script="$(mktemp)"
curl -fsSL https://ollama.com/install.sh -o "${install_script}"
sh "${install_script}"
rm -f "${install_script}"

MODEL_NAME="${MODEL_NAME:-gemma4}"
MODEL_ALIAS="${MODEL_ALIAS:-${MODEL_NAME}-local}"
MAX_API_WAIT_SECONDS="${MAX_API_WAIT_SECONDS:-20}"
CONTEXT_SIZE="${CONTEXT_SIZE:-4096}"

echo "[install] Enabling Ollama service..."
sudo systemctl daemon-reload || true
sudo systemctl enable ollama || true
sudo systemctl restart ollama || true

echo "[install] Waiting for Ollama API..."
api_ready="false"
for _ in $(seq 1 "${MAX_API_WAIT_SECONDS}"); do
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    api_ready="true"
    break
  fi
  sleep 1
done

if [[ "${api_ready}" != "true" ]]; then
  echo "[install] ERROR: Ollama API did not start at http://127.0.0.1:11434 within ${MAX_API_WAIT_SECONDS} seconds."
  echo "[install] Check service status with: sudo systemctl status ollama"
  exit 1
fi

echo "[install] Pulling model: ${MODEL_NAME}..."
ollama pull "${MODEL_NAME}"

if ! ollama show "${MODEL_NAME}" >/dev/null 2>&1; then
  echo "[install] ERROR: ${MODEL_NAME} could not be loaded after pull."
  echo "[install] Check disk space, Ollama logs, and available tags, then retry with:"
  echo "  MODEL_NAME=<tag> ./scripts/install_ollama_gemma4.sh"
  exit 1
fi

echo "[install] If available, pull a quantized tag for 16 GB RAM (example):"
echo "  ollama pull gemma4:q4_k_m"

echo "[install] Creating tuned model alias with KV-cache-friendly context..."
modelfile_path="$(mktemp)"
cat > "${modelfile_path}" <<EOF
FROM ${MODEL_NAME}
PARAMETER num_ctx ${CONTEXT_SIZE}
EOF

ollama create "${MODEL_ALIAS}" -f "${modelfile_path}"
rm -f "${modelfile_path}"

echo "[install] Smoke test..."
ollama run "${MODEL_ALIAS}" "Reply in one sentence: installation complete?"

echo "[install] Done. Use: ollama run ${MODEL_ALIAS}"
