#!/usr/bin/env bash
# Download the GGUF once (fast, parallel), then hand everything else to llama-server.
# Required env: MODEL_REPO, MODEL_FILE. Optional: MODEL_DIR (default /workspace/models), HF_TOKEN.
# Any arguments (the template's start command) are passed straight to llama-server.
set -euo pipefail

: "${MODEL_REPO:?Set MODEL_REPO, e.g. DavidAU/Some-Model-GGUF}"
: "${MODEL_FILE:?Set MODEL_FILE, e.g. Some-Model-Q8_0.gguf}"
MODEL_DIR="${MODEL_DIR:-/workspace/models}"
MODEL_PATH="${MODEL_DIR}/${MODEL_FILE}"

mkdir -p "$MODEL_DIR"

if [ -s "$MODEL_PATH" ]; then
  echo "[start] Using cached model: $MODEL_PATH"
else
  echo "[start] Downloading $MODEL_FILE from $MODEL_REPO ..."
  if [ -z "${HF_TOKEN:-}" ]; then
    echo "[start] Note: HF_TOKEN is not set; gated repos will refuse the download."
  fi
  start_ts=$(date +%s)
  # Resumable: a restarted pod picks up where the last attempt stopped.
  hf download "$MODEL_REPO" "$MODEL_FILE" --local-dir "$MODEL_DIR"
  echo "[start] Download finished in $(( $(date +%s) - start_ts ))s"
fi

if command -v llama-server >/dev/null 2>&1; then
  SERVER=llama-server
else
  SERVER=/app/llama-server
fi

echo "[start] Launching: $SERVER -m $MODEL_PATH $*"
exec "$SERVER" -m "$MODEL_PATH" "$@"
