#!/bin/bash

mkdir -p "$HOME/models/Qwen3.5-2B-GGUF"
wget -O "$HOME/models/Qwen3.5-2B-GGUF/Qwen3.5-2B-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-2B-GGUF/resolve/main/Qwen3.5-2B-BF16.gguf
wget -O "$HOME/models/Qwen3.5-2B-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-2B-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-qwen3.5-2b-bf16-GGUF.sh"
chmod +x "$HOME/models/run-qwen3.5-2b-bf16-GGUF.sh"
    cat >> "$HOME/models/run-qwen3.5-2b-bf16-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen3.5-2B-GGUF/Qwen3.5-2B-BF16.gguf"\
    --mmproj "$HOME/models/Qwen3.5-2B-GGUF/mmproj-BF16.gguf" \
    -a qwen3.5-2b \
    -fa on \
    -c 16384 \
    --image-min-tokens 1024 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF