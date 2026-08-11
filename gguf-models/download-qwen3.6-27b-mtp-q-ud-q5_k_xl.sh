#!/bin/bash

mkdir -p "$HOME/models/Qwen3.6-27B-MTP-GGUF"
wget -O "$HOME/models/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf" \
    https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-UD-Q5_K_XL.gguf
wget -O "$HOME/models/Qwen3.6-27B-MTP-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-qwen3.6-27b-GGUF.sh"
chmod +x "$HOME/models/run-qwen3.6-27b-GGUF.sh"
    cat >> "$HOME/models/run-qwen3.6-27b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf"\
    --mmproj "$HOME/models/Qwen3.6-27B-MTP-GGUF/mmproj-BF16.gguf" \
    -a qwen3.6-27b \
    -fa on \
    -c 131072 \
    -ngl 999 \
    --kv-unified \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 64 \
    --host 0.0.0.0 \
    --port 8000 \
    --spec-type draft-mtp --spec-draft-n-max 2 \
    -np 4
EOF