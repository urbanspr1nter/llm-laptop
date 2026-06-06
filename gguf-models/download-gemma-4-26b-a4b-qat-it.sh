#!/bin/bash

mkdir -p "$HOME/models/gemma-4-26B-A4B-qat-it-GGUF"
wget -O "$HOME/models/gemma-4-26B-A4B-qat-it-GGUF/gemma-4-26B_q4_0-it.gguf" \
    https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/resolve/main/gemma-4-26B_q4_0-it.gguf
wget -O "$HOME/models/gemma-4-26B-A4B-qat-it-GGUF/gemma-4-26B-it-mmproj.gguf" \
    https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/resolve/main/gemma-4-26B-it-mmproj.gguf

touch "$HOME/models/run-gemma-4-26B-A4B-qat-it-GGUF.sh"
chmod +x "$HOME/models/run-gemma-4-26B-A4B-qat-it-GGUF.sh"
    cat >> "$HOME/models/run-gemma-4-26B-A4B-qat-it-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/gemma-4-26B-A4B-qat-it-GGUF/gemma-4-26B_q4_0-it.gguf"\
    --mmproj "$HOME/models/gemma-4-26B-A4B-qat-it-GGUF/gemma-4-26B-it-mmproj.gguf" \
    -a gemma-4-26B-A4B-qat-it \
    -fa on \
    -c 131072 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF