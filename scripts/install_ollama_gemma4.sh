#!/usr/bin/env bash
set -euo pipefail

echo "[install] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

MODEL_NAME="${MODEL_NAME:-gemma4}"
MODEL_ALIAS="${MODEL_ALIAS:-${MODEL_NAME}-hp16}"

echo "[install] Enabling Ollama service..."
sudo systemctl daemon-reload || true
sudo systemctl enable ollama || true
sudo systemctl restart ollama || true

echo "[install] Waiting for Ollama API..."
for _ in {1..20}; do
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "[install] Pulling model: ${MODEL_NAME}..."
ollama pull "${MODEL_NAME}"

if ! ollama show "${MODEL_NAME}" >/dev/null 2>&1; then
  echo "[install] ERROR: ${MODEL_NAME} is unavailable in your Ollama registry."
  echo "[install] Check available models/tags and retry with:"
  echo "  MODEL_NAME=<available-tag> ./scripts/install_ollama_gemma4.sh"
  exit 1
fi

echo "[install] If available, pull a quantized tag for 16 GB RAM (example):"
echo "  ollama pull gemma4:q4_k_m"

echo "[install] Creating tuned model alias with KV-cache-friendly context..."
cat > /tmp/Gemma4-HP16.Modelfile <<EOF
FROM ${MODEL_NAME}
PARAMETER num_ctx 4096
EOF

ollama create "${MODEL_ALIAS}" -f /tmp/Gemma4-HP16.Modelfile
rm -f /tmp/Gemma4-HP16.Modelfile

echo "[install] Smoke test..."
ollama run "${MODEL_ALIAS}" "Réponds en une phrase: installation terminée ?"

echo "[install] Done. Use: ollama run ${MODEL_ALIAS}"
