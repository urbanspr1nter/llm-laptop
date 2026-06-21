#!/bin/bash

mkdir -p "$HOME/models/North-Mini-Code-1.0-GGUF"
wget -O "$HOME/models/North-Mini-Code-1.0-GGUF/North-Mini-Code-1.0-UD-Q4_K_XL.gguf" \
    https://huggingface.co/unsloth/North-Mini-Code-1.0-GGUF/resolve/main/North-Mini-Code-1.0-UD-Q4_K_XL.gguf

touch "$HOME/models/run-north-mini-code-1.0-GGUF.sh"
chmod +x "$HOME/models/run-north-mini-code-1.0-GGUF.sh"
    cat >> "$HOME/models/run-north-mini-code-1.0-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/North-Mini-Code-1.0-GGUF/North-Mini-Code-1.0-UD-Q4_K_XL.gguf"\
    -a North-Mini-Code-1.0 \
    -fa on \
    -c 262144 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF