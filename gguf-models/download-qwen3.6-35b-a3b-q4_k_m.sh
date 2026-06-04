#!/bin/bash

mkdir -p "$HOME/models/Qwen3.6-35B-A3B-GGUF"
wget -O "$HOME/models/Qwen3.6-35B-A3B-GGUF/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf" \
    https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf
wget -O "$HOME/models/Qwen3.6-35B-A3B-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-qwen3.6-35b-a3b-GGUF.sh"
chmod +x "$HOME/models/run-qwen3.6-35b-a3b-GGUF.sh"
    cat >> "$HOME/models/run-qwen3.6-35b-a3b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen3.6-35B-A3B-GGUF/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf"\
    --mmproj "$HOME/models/Qwen3.6-35B-A3B-GGUF/mmproj-BF16.gguf" \
    -a qwen3.6-35b-a3b \
    -fa on \
    -c 131072 \
    --host 0.0.0.0 \
    --port 8001 \
    -np 1
EOF
