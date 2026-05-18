#!/bin/bash

mkdir -p "$HOME/models/Qwen3.5-2B-GGUF"
wget -O "$HOME/models/Qwen3.5-2B-GGUF/Qwen3.5-2B-UD-Q8_K_XL.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-2B-GGUF/resolve/main/Qwen3.5-2B-UD-Q8_K_XL.gguf
wget -O "$HOME/models/Qwen3.5-2B-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.5-2B-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-qwen3.5-2b-GGUF.sh"
chmod +x "$HOME/models/run-qwen3.5-2b-GGUF.sh"
    cat >> "$HOME/models/run-qwen3.5-2b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen3.5-2B-GGUF/Qwen3.5-2B-UD-Q8_K_XL.gguf"\
    --mmproj "$HOME/models/Qwen3.5-2B-GGUF/mmproj-BF16.gguf" \
    -a qwen3.5-2b \
    -fa on \
    -c 131072 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF