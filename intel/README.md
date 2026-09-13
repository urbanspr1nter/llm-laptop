# LLM serving on Intel Arc A770 (Fedora)

Reproducible setup, benchmarks, and notes for serving GGUF models on an Intel
Arc A770 16 GB (DG2/Xe1) with llama.cpp — Vulkan and SYCL backends.
**Gemma-4-12B is the example model used throughout** (the measurements below
are for it; re-run `llama-bench` for any other model).

An earlier vLLM 0.29.0+xpu attempt is archived in
[`vllm-attempt/`](vllm-attempt/) (serves short prompts; hangs on >~1.3K-token
prefills; ~100 tok/s pp512, 16–22 tok/s tg128 when it works).

**Start here:**

1. **[RESULTS-SUMMARY.md](RESULTS-SUMMARY.md)** — Vulkan vs SYCL measurements,
   decode-over-time, and the prefill:decode crossover by backend and serving
   mode.
2. **[REPRODUCE.md](REPRODUCE.md)** — rebuild either backend from zero; what
   each file here is for.
3. **[TUTORIAL-fedora-sycl-llamacpp.md](TUTORIAL-fedora-sycl-llamacpp.md)** —
   standalone, step-by-step fresh-Fedora → llama.cpp-SYCL guide with checkpoints
   and troubleshooting.

**Artifacts:** `logs/` (recorded benchmark outputs),
`tests/decode_timeline.py` (streaming decode-over-time probe),
`vllm-attempt/` (archived attempt + hang probes).

**Not in git (too large):** the example model weights —
`gguf/gemma-4-12b-it-Q4_K_M.gguf` (unsloth/gemma-4-12b-it-GGUF, 7.1 GB) and the
original `gemma-4-12B-it-int4-AutoRound/` HF checkpoint (7.3 GB). Download
sources and exact install commands are in REPRODUCE.md; any GGUF works with
either backend (`MODEL=/path/to/model.gguf ./run-gemma-4-12b-llamacpp.sh`).

Headline numbers for the example model (Gemma-4-12B Q4_K_M, A770, 16K ctx,
fa=0, 225 W cap):

| | llama.cpp Vulkan | llama.cpp SYCL |
|---|---|---|
| prefill 512 | 524 tok/s | **1188 tok/s** |
| prefill 8192 | 432 tok/s | **1056 tok/s** |
| decode 128 (fresh ctx) | **34.3 tok/s** | 22.6 tok/s |
| decode 256 @ 9K ctx | **30.9 tok/s** | 18.9 tok/s |
| 8K prefill + 1K decode (avg) | **175 tok/s** | 144 tok/s |

System: Fedora 44, kernel 7.1.10, i915 (DG2), Mesa 26.1 (ANV), Level Zero +
compute-runtime 26.22.38646.6, i7-13700 (8 threads), GPU power limit raised
190 W → 225 W via hwmon `power1_max` (resets at reboot).
