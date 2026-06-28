#!/bin/bash

mkdir -p "$HOME/models/Qwen-AgentWorld-35B-A3B-GGUF"
wget -O "$HOME/models/Qwen-AgentWorld-35B-A3B-GGUF/Qwen-AgentWorld-35B-A3B-UD-Q8_K_XL.gguf" \
    https://huggingface.co/unsloth/Qwen-AgentWorld-35B-A3B-GGUF/resolve/main/Qwen-AgentWorld-35B-A3B-UD-Q8_K_XL.gguf

touch "$HOME/models/run-qwen-agentworld-35b-a3b-GGUF.sh"
chmod +x "$HOME/models/run-qwen-agentworld-35b-a3b-GGUF.sh"
    cat >> "$HOME/models/run-qwen-agentworld-35b-a3b-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/Qwen-AgentWorld-35B-A3B-GGUF/Qwen-AgentWorld-35B-A3B-UD-Q8_K_XL.gguf"\
    -a qwen-agentworld-35b-a3b \
    -fa on \
    -c 262144 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF
