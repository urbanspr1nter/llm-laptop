#!/bin/bash

mkdir -p "$HOME/models/Ornith-1.0-35B-GGUF"
wget -O "$HOME/models/Ornith-1.0-35B-GGUF/ornith-1.0-35b-Q8_0.gguf" \
    https://huggingface.co/deepreinforce-ai/Ornith-1.0-35B-GGUF/resolve/main/ornith-1.0-35b-Q8_0.gguf

touch "$HOME/models/run-ornith-1.0-35b-GGUF.sh"
chmod +x "$HOME/models/run-ornith-1.0-35b-GGUF.sh"
    cat >> "$HOME/models/run-ornith-1.0-35b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Ornith-1.0-35B-GGUF/ornith-1.0-35b-Q8_0.gguf"\
    -a ornith-35b \
    -fa on \
    -c 262144 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF
