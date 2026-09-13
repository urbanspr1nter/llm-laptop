# Intel Arc A770: llama.cpp Vulkan vs SYCL measurements

Both backends run the same GGUF on Intel Arc A770 16 GB (DG2/Xe1), Fedora 44.
The reference model for every number here is **Gemma-4-12B Q4_K_M** — treat the
values as a worked example for this card, not as constants for all models;
`llama-bench` re-runs take minutes. 16K context, fa=0, 225 W power cap.
Raw outputs in `logs/`; build/run instructions in `REPRODUCE.md`.

SYCL was measured on two toolchains: **official oneAPI 2026.1.1** (`icpx`,
builds pristine llama.cpp) and the intel/llvm nightly 2026-09-12 (`clang++`,
which required a CMake link patch, kept only in this repo's git history).
Prefill is identical (~±1%); decode is 14–18% faster on the official
toolchain, so its numbers are the primary SYCL column below; nightly values
appear in parentheses where they differ.

An earlier vLLM 0.29.0+xpu attempt (~100 tok/s pp512, 16–22 tok/s tg128,
hangs on prompts > ~1261–1296 tokens) is archived in `vllm-attempt/`.

## llama-bench (isolated paths)

| Test | Vulkan | SYCL (official oneAPI 2026.1.1) |
|---|---|---|
| pp512 | 524 tok/s | **1180 tok/s** |
| pp2048 | — | 1133 tok/s |
| pp4096 | — | 1096 tok/s |
| pp8192 | 432 tok/s | **1051 tok/s** |
| tg128 (fresh ctx) | **34.3 tok/s** | 22.6 tok/s (nightly 19.2) |
| tg256 @ ~9K ctx | **30.9 tok/s** | 18.9 tok/s (nightly 16.4) |
| tg256 @ 16K ctx | **~30 tok/s** | 17.5 tok/s (nightly 15.3) |
| 8K prefill + 1K decode | **175.3 tok/s** avg | 144.0 tok/s avg (nightly 127.0) |
| Cold engine start | ~7 s | ~7 s (+JIT on first use) |
| decode graph on/off (tg128) | — | 22.6 / 16.9 tok/s (nightly 19.2 / 13.7) |

Prefill declines ~18% from 1K→8K on Vulkan (measured pp512 vs pp8192) and ~9%
on SYCL (1166 → 1056 tok/s); SYCL prefill is GEMM-dominated and nearly flat.

## Server-mode vs bench-mode prefill

llama-server's prompt path is slower than llama-bench's on both backends, and
not by the same factor (8K prompt):

| | llama-bench | llama-server |
|---|---|---|
| Vulkan | 432 tok/s | 121 tok/s |
| SYCL (both toolchains, warm) | ~1050 tok/s | ~435 tok/s |

(First request after engine start is slower — 343–371 tok/s on SYCL — until
kernels are warmed; identical repeated prompts hit the prompt cache and are
not measurements.)

## Decode over time (streaming, 1024-token generation, 100-token windows)

| Backend / scenario | start | end | avg |
|---|---|---|---|
| SYCL fresh ctx | 25.1 tok/s | 21.5 | 22.8 |
| SYCL after 8K prefill | 16.2 tok/s | 15.4 | 15.7 |
| Vulkan fresh ctx | 32.9 tok/s | 30.4 | 31.5 |
| Vulkan after 8K prefill | 27.4 tok/s | 27.0 | 27.1 |

(SYCL rows measured on the official toolchain; nightly was proportionally
slower. Both decline monotonically within a generation (KV attention grows
with position). Decline with context depth (bench): Vulkan 32.8 → 30.9 tok/s
(1K→16K, −6%); SYCL 22.6 → 17.5 (−23%; nightly 18.0 → 15.3, −15%).)

## Prefill:decode crossover by mode

Wall time for a turn of P prefill tokens and D decode tokens is
`P/pp_rate + D/tg_rate`. Setting Vulkan time = SYCL time gives the P:D ratio
where the engines tie (using tg at ~8–9K context depth):

| Measured in | rates used | crossover P:D |
|---|---|---|
| llama-bench | pp8192 432/1051; tg@9K 30.9/18.9 | ≈ 15 : 1 |
| llama-server | pp8192 121/435; tg 27.1/15.7 | ≈ 4.5 : 1 |

Measured wall times at fixed turn shapes (server-mode rates, official SYCL):

| Turn (P in / D out) | Vulkan | SYCL | lower time |
|---|---|---|---|
| 2K / 400 | 31 s | 30 s | ≈ tie |
| 4K / 1K | 70 s | 73 s | Vulkan |
| 8K / 1K | 103 s | 82 s | SYCL |
| 16K / 512 | 151 s | 69 s | SYCL |

The crossover depends on the prefill path measured: server-mode prompt
processing is 3.6× slower than bench on Vulkan but equal on SYCL (warm), which
moves the tie point from ≈15:1 (bench) to ≈4.5:1 (server). Both engines'
server prefill is tunable (`-b`/`-ub`, untested); SYCL figures include
`GGML_SYCL_ENABLE_GRAPH=1`. The ratios shift with any model whose prefill/decode
cost ratio differs from the example's.

## Other observations

1. **fa effect depends on head size** — for the example model (Gemma-4: head
   dims 256 sliding / 512 full), flash-attention is slower than the non-FA path
   on both backends: Vulkan pp8192 57 → 426 tok/s with fa off; SYCL pp8192
   473 → 973 tok/s. Models with conventional head dims (e.g. 128) are unlikely
   to show this — benchmark `-fa 0` vs `-fa 1` per model. The non-FA path
   disallows q8_0 KV quant on Vulkan (FA-only there).
2. **Decode power** — Vulkan decode draws ~48 W; the GPU is not the bottleneck
   at batch size 1 (host-submission-bound). Mesa ANV reports "matrix cores:
   none" on DG2.
3. **DG2 free-VRAM reporting** — free memory is reported equal to total;
   `ZES_ENABLE_SYSMAN=1` is set by the SYCL launcher.
4. **Toolchain affects decode** — the official oneAPI 2026.1.1 (`icpx`) build
   decodes 14–18% faster than the intel/llvm nightly (`clang++`) build; prefill
   is unchanged. With the nightly, MKL's CMake does not export its SYCL targets
   and the SYCL runtime needs explicit linking — the official toolchain has
   neither problem.

Raw outputs: `logs/llama-bench-results.md` (Vulkan matrix),
`logs/llama-bench-pg.md` / `logs/llama-bench-pg-fa0.md` (fa A/B).
