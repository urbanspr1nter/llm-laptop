#!/bin/bash

mkdir -p "$HOME/models/gemma-4-E2B-it-qat-q4_0-GGUF"
wget -O "$HOME/models/gemma-4-E2B-it-qat-q4_0-GGUF/gemma-4-E2B_q4_0-it.gguf" \
    https://huggingface.co/google/gemma-4-E2B-it-qat-q4_0-gguf/resolve/main/gemma-4-E2B_q4_0-it.gguf
wget -O "$HOME/models/gemma-4-E2B-it-qat-q4_0-GGUF/gemma-4-E2B-it-mmproj.gguf" \
    https://huggingface.co/google/gemma-4-E2B-it-qat-q4_0-gguf/resolve/main/gemma-4-E2B-it-mmproj.gguf

touch "$HOME/models/run-gemma-4-E2B-it-qat-q4_0-GGUF.sh"
chmod +x "$HOME/models/run-gemma-4-E2B-it-qat-q4_0-GGUF.sh"
    cat >> "$HOME/models/run-gemma-4-E2B-it-qat-q4_0-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/gemma-4-E2B-it-qat-q4_0-GGUF/gemma-4-E2B_q4_0-it.gguf"\
    --mmproj "$HOME/models/gemma-4-E2B-it-qat-q4_0-GGUF/gemma-4-E2B-it-mmproj.gguf" \
    -a gemma-4-E2B-it-qat \
    -fa on \
    -c 65536 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 2
EOF