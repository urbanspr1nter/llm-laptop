# Local Claude Code

Get your `llama.cpp` server up and running. It does have compatibility with Anthropic messages API.



## Pre-Requisites

1. Install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
2. Build and install `llama.cpp`: https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md



## Configuring

Then edit your `.bashrc` to have the following environment variables. For example, if I am hosting `Qwen3.6-35B-A3B`:

```bash
export LLAMA_SERVER_ENDPOINT=http://127.0.0.1:8080
export LLAMA_SERVER_API_KEY=none
export LLAMA_SERVER_MODEL=Qwen3.6-35B-A3B
```

Then configure the environment variables in the same file:

```bash
export API_TIMEOUT_MS=1200000   # raise per-request timeout
export API_FORCE_IDLE_TIMEOUT=0 # don't abort if the model pauses >5 min between chunks
export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1

export ANTHROPIC_API_KEY=$LLAMA_SERVER_API_KEY
export ANTHROPIC_BASE_URL=$LLAMA_SERVER_ENDPOINT
export ANTHROPIC_AUTH_TOKEN=sk-local
```

Add the alias to `claude`:

```bash
alias claude="claude --dangerously-skip-permissions --model $LLAMA_SERVER_MODEL"
```

> **⚠️ Warning**: The above puts me in "YOLO" mode. This is my preferred way of working. I put it upon myself to be responsible for whatever my agent does. So if it is an `rm -rf /`, I had it coming. If this is not your jam, then remove `--dangerously-skip-permissions`.



## Full Changes

The full `.bashrc` file changes (append to the end):

```bash
export LLAMA_SERVER_ENDPOINT=http://127.0.0.1:8080
export LLAMA_SERVER_API_KEY=none
export LLAMA_SERVER_MODEL=Qwen3.6-35B-A3B

export API_TIMEOUT_MS=1200000   # raise per-request timeout
export API_FORCE_IDLE_TIMEOUT=0 # don't abort if the model pauses >5 min between chunks
export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1

export ANTHROPIC_API_KEY=$LLAMA_SERVER_API_KEY
export ANTHROPIC_BASE_URL=$LLAMA_SERVER_ENDPOINT
export ANTHROPIC_AUTH_TOKEN=sk-local

alias claude="claude --dangerously-skip-permissions --model $LLAMA_SERVER_MODEL"
```

