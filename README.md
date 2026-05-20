# Ollama-Gemma-4---Local-server-on-my-16gb-HP-Pavillon

Guide + scripts to:
1. **clean previous local LLM installs** on an HP Pavilion 16 GB machine
2. install **Ollama + Gemma 4** quickly
3. prepare the node for a **Tailscale-connected multi-computer setup**

## Correct term for "remove what was installed"
The right technical term is usually:
- **désinstallation complète** (complete uninstall)
- **purge** (remove app + config/data leftovers)

In this repo, "cleanup" means a **purge of previous Ollama/local-LLM services, binaries, and model cache**.

## Quick start
```bash
cd /path/to/Ollama-Gemma-4---Local-server-on-my-16gb-HP-Pavillon
chmod +x scripts/*.sh
./scripts/cleanup_local_llm.sh
./scripts/install_ollama_gemma4.sh
```

## Files
- `scripts/cleanup_local_llm.sh`: stop services and remove old Ollama/local LLM installs
- `scripts/install_ollama_gemma4.sh`: install Ollama, configure service, and pull Gemma 4

## Notes for Gemma 4 on 16 GB
- Use a **quantized Gemma 4 tag** when available (example: `gemma4:q4_k_m`) for better RAM usage.
- KV cache is used by Ollama at runtime; tune context size with `PARAMETER num_ctx` in `Modelfile`.
- Keep this machine dedicated to inference and connect it to the other nodes via Tailscale.
