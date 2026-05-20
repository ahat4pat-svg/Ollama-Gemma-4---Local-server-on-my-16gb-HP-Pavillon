#!/usr/bin/env bash
set -euo pipefail

echo "[install] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

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

echo "[install] Pulling Gemma 4..."
ollama pull gemma4

echo "[install] If available, pull a quantized tag for 16 GB RAM (example):"
echo "  ollama pull gemma4:q4_k_m"

echo "[install] Creating tuned model alias with KV-cache-friendly context..."
cat > /tmp/Gemma4-HP16.Modelfile <<'EOF'
FROM gemma4
PARAMETER num_ctx 4096
EOF

ollama create gemma4-hp16 -f /tmp/Gemma4-HP16.Modelfile
rm -f /tmp/Gemma4-HP16.Modelfile

echo "[install] Smoke test..."
ollama run gemma4-hp16 "Réponds en une phrase: installation terminée ?"

echo "[install] Done. Use: ollama run gemma4-hp16"
