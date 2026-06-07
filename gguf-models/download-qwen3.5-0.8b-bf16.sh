#!/bin/bash

mkdir -p "$HOME/models/Qwen3.5-0.8-GGUF"
wget -O "$HOME/models/Qwen3.5-0.8-GGUF/Qwen3.5-0.8B-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-0.8B-GGUF/resolve/main/Qwen3.5-0.8B-BF16.gguf
wget -O "$HOME/models/Qwen3.5-0.8-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-0.8-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-qwen3.5-0.8b-GGUF.sh"
chmod +x "$HOME/models/run-qwen3.5-0.8b-GGUF.sh"
    cat >> "$HOME/models/run-qwen3.5-0.8b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen3.5-0.8B-GGUF/Qwen3.5-0.8B-BF16.gguf"\
    --mmproj "$HOME/models/Qwen3.5-0.8B-GGUF/mmproj-BF16.gguf" \
    -a qwen3.5-0.8b \
    -fa on \
    -c 32768 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 2
EOF