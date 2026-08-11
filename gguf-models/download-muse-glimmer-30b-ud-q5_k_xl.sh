#!/bin/bash

mkdir -p "$HOME/models/Muse-Glimmer-30B-GGUF"
wget -O "$HOME/models/Muse-Glimmer-30B-GGUF/Muse-Glimmer-30B-UD-Q5_K_XL.gguf" \
    https://huggingface.co/unsloth/Muse-Glimmer-30B-GGUF/resolve/main/Muse-Glimmer-30B-UD-Q5_K_XL.gguf
wget -O "$HOME/models/Muse-Glimmer-30B-GGUF/mmproj-Muse-Glimmer-30B-BF16.gguf" \
    https://huggingface.co/unsloth/Muse-Glimmer-30B-GGUF/resolve/main/mmproj-Muse-Glimmer-30B-BF16.gguf
wget -O "$HOME/models/Muse-Glimmer-30B-GGUF/dflash-kquant.gguf" \
    https://huggingface.co/unsloth/Muse-Glimmer-30B-GGUF/resolve/main/dflash-kquant.gguf

touch "$HOME/models/run-muse-glimmer-30b-GGUF.sh"
chmod +x "$HOME/models/run-muse-glimmer-30b-GGUF.sh"
    cat >> "$HOME/models/run-muse-glimmer-30b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Muse-Glimmer-30B-GGUF/Muse-Glimmer-30B-UD-Q5_K_XL.gguf"\
    --mmproj "$HOME/models/Muse-Glimmer-30B-GGUF/mmproj-Muse-Glimmer-30B-BF16.gguf" \
    -a muse-glimmer-30b \
    -fa on \
    -c 131072 \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 64 \
    --kv-unified \
    -ngl 999 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 4
EOF
