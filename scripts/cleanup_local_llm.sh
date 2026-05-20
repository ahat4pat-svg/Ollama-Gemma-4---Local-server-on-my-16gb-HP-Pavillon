#!/usr/bin/env bash
set -euo pipefail

echo "[cleanup] Stopping Ollama service if present..."
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl stop ollama 2>/dev/null || true
  sudo systemctl disable ollama 2>/dev/null || true
fi

echo "[cleanup] Removing Ollama package/binary if present..."
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get remove -y ollama 2>/dev/null || true
  sudo apt-get purge -y ollama 2>/dev/null || true
  sudo apt-get autoremove -y 2>/dev/null || true
fi

sudo rm -f /usr/local/bin/ollama 2>/dev/null || true
sudo rm -f /etc/systemd/system/ollama.service 2>/dev/null || true
sudo rm -f /lib/systemd/system/ollama.service 2>/dev/null || true
sudo systemctl daemon-reload 2>/dev/null || true

echo "[cleanup] Removing old model cache..."
rm -rf "${HOME}/.ollama" 2>/dev/null || true
sudo rm -rf /usr/share/ollama 2>/dev/null || true
sudo rm -rf /var/lib/ollama 2>/dev/null || true

echo "[cleanup] Optional: remove other local LLM apps manually if installed (LM Studio, GPT4All, text-generation-webui)."
echo "[cleanup] Done."
