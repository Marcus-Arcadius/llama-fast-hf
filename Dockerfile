# llama.cpp CUDA server + fast Hugging Face downloader.
# On start: downloads MODEL_FILE from MODEL_REPO (parallel, via hf_xet) into
# MODEL_DIR if it isn't there yet, then runs llama-server on it.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m venv /opt/hf \
 && /opt/hf/bin/pip install --no-cache-dir -U "huggingface_hub[hf_xet]" \
 && ln -s /opt/hf/bin/hf /usr/local/bin/hf

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV MODEL_DIR=/workspace/models \
    HF_XET_HIGH_PERFORMANCE=1

ENTRYPOINT ["/start.sh"]
