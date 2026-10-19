# llama-fast-hf

llama.cpp CUDA server image that downloads a GGUF from Hugging Face at full speed
(parallel `hf_xet` download) on first start, caches it on the volume, then runs `llama-server`.

## RunPod template

- **Image:** `ghcr.io/marcus-arcadius/llama-fast-hf:latest`
- **Env vars:**
  - `MODEL_REPO` – e.g. `DavidAU/Qwen3.8-27B-Turbo-Brilliance-50X-Reasoning-Instruct-NEO-MAX-MTP-GGUF`
  - `MODEL_FILE` – e.g. `Qwen3.8-27B-Turbo-Brilliance-50X-RI-NEO-MAX-MTP-Q8_0.gguf`
  - `HF_TOKEN` – needed for gated repos (use a RunPod secret)
  - `MODEL_DIR` – optional, defaults to `/workspace/models`
  - `LLAMA_API_KEY` – optional, protects the server
- **Start command:** only llama-server flags (no `-m`, no `--hf-repo`), e.g.
  `--host 0.0.0.0 --port 8080 -c 262144 -ngl 999 -fa on --spec-type draft-mtp --spec-draft-n-max 2 --jinja`

The model is downloaded once per volume; later starts load it from disk.
Swap models by changing `MODEL_REPO` / `MODEL_FILE`.
