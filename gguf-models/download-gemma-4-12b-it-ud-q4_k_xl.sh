#!/bin/bash

mkdir -p "$HOME/models/gemma-4-12b-it-GGUF"
wget -O "$HOME/models/gemma-4-12b-it-GGUF/gemma-4-12b-it-UD-Q4_K_XL.gguf" \
    https://huggingface.co/unsloth/gemma-4-12b-it-GGUF/resolve/main/gemma-4-12b-it-UD-Q4_K_XL.gguf
wget -O "$HOME/models/gemma-4-12b-it-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/gemma-4-12b-it-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-gemma-4-12b-it-GGUF.sh"
chmod +x "$HOME/models/run-gemma-4-12b-it-GGUF.sh"
    cat >> "$HOME/models/run-gemma-4-12b-it-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/gemma-4-12b-it-GGUF/gemma-4-12b-it-UD-Q4_K_XL.gguf"\
    --mmproj "$HOME/models/gemma-4-12b-it-GGUF/mmproj-BF16.gguf" \
    -a gemma-4-12b-it \
    -fa on \
    -c 262144 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF