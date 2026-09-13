# Reproduce-from-scratch guide (Intel Arc A770 / Fedora)

Everything regenerable was deleted; this file is the map from zero back to a
working setup. On disk: the example model checkpoints, the `.sh` launchers, the
docs.

The launchers are named for the example model (Gemma-4-12B) but are
model-agnostic — serve any GGUF with
`MODEL=/path/to/model.gguf ./run-gemma-4-12b-llamacpp.sh` (same for the SYCL
variant). Both default to 16K context; adjust `CTX` as needed.

Current state: no binaries in the workspace. Rebuild as needed:

## 1. llama.cpp — Vulkan (stock upstream)

```bash
sudo dnf install -y git cmake make gcc-c++ glslc spirv-headers-devel
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build-vk -DGGML_VULKAN=ON -DGGML_NATIVE=ON -DLLAMA_CURL=OFF
cmake --build build-vk -j$(nproc)
```

No patches. Benchmark `-fa 0` vs `-fa 1` for your model (for the example
model fa=0 is 7.4× faster prefill — head-dim-dependent, see
RESULTS-SUMMARY.md):

```bash
./run-gemma-4-12b-llamacpp.sh        # expects ./llama.cpp/build-vk/bin/llama-server
```

## 2. llama.cpp — SYCL (fastest prefill)

Follow **`TUTORIAL-fedora-sycl-llamacpp.md`** end to end. In short:

- `sudo dnf install -y intel-compute-runtime intel-level-zero oneapi-level-zero intel-oneapi-mkl-devel intel-oneapi-compiler-dpcpp-cpp`
  (+ Intel oneAPI dnf repo, in the tutorial)
- `source /opt/intel/oneapi/setvars.sh`
- `git clone https://github.com/ggml-org/llama.cpp` — pristine upstream; no
  patches with the official toolchain
- cmake as in the tutorial §5 (icx/icpx), then:

```bash
./run-gemma-4-12b-llamacpp-sycl.sh   # expects ./llama.cpp/build-sycl/bin/llama-server
```

## 3. vLLM XPU (archived attempt)

The vLLM 0.29.0+xpu attempt is in `vllm-attempt/` with its own README covering
the exact pip pins, required DG2 workarounds, and the >1.3K-token prefill hang.

## 4. Re-verify with the benchmark

```bash
MODEL=path/to/model.gguf ./bench-gemma-4-llamacpp.sh   # -> logs/llama-bench-results.md
tests/decode_timeline.py <port> <prompt_tokens> <gen_tokens>   # decode-over-time
```

## What's on disk

| Path | Role |
|---|---|
| `gguf/gemma-4-12b-it-Q4_K_M.gguf` | example model (llama.cpp engines) |
| `gemma-4-12B-it-int4-AutoRound/` | original checkpoint (vLLM attempt) |
| `run-gemma-4-12b-llamacpp.sh` / `-sycl.sh`, `stop-llamacpp.sh` | launchers (`MODEL=` to swap models) |
| `bench-gemma-4-llamacpp.sh`, `tests/decode_timeline.py` | benchmarks |
| `README.md`, `RESULTS-SUMMARY.md`, `TUTORIAL-fedora-sycl-llamacpp.md` | docs |
| `vllm-attempt/` | archived vLLM attempt (scripts, workarounds, hang probes) |
| `logs/*.md` | recorded benchmark outputs |
