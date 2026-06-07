#!/bin/bash

mkdir -p "$HOME/models/SmolVLM2-500M-Video-Instruct-GGUF"
wget -O "$HOME/models/SmolVLM2-500M-Video-Instruct-GGUF/SmolVLM2-500M-Video-Instruct-f16.gguf" \
    https://huggingface.co/ggml-org/SmolVLM2-500M-Video-Instruct-GGUF/resolve/main/SmolVLM2-500M-Video-Instruct-f16.gguf
wget -O "$HOME/models/SmolVLM2-500M-Video-Instruct-GGUF/mmproj-SmolVLM2-500M-Video-Instruct-f16.gguf" \
    https://huggingface.co/ggml-org/SmolVLM2-500M-Video-Instruct-GGUF/resolve/main/mmproj-SmolVLM2-500M-Video-Instruct-f16.gguf

touch "$HOME/models/run-SmolVLM2-500M-Video-Instruct-GGUF.sh"
chmod +x "$HOME/models/run-SmolVLM2-500M-Video-Instruct-GGUF.sh"
    cat >> "$HOME/models/run-SmolVLM2-500M-Video-Instruct-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/SmolVLM2-500M-Video-Instruct-GGUF/SmolVLM2-500M-Video-Instruct-f16.gguf"\
    --mmproj "$HOME/models/SmolVLM2-500M-Video-Instruct-GGUF/mmproj-SmolVLM2-500M-Video-Instruct-f16.gguf" \
    -a SmolVLM2-500M-Video-Instruct \
    -fa on \
    -c 16384 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF