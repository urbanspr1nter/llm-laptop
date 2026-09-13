# From zero to llama.cpp-on-SYCL: Intel Arc A770 on Fedora

A step-by-step guide for a **fresh Fedora system** (tested on Fedora 44; should
work on 41+). By the end you'll have `llama-server` serving a GGUF model
from an Intel Arc GPU through the **SYCL** backend, with an OpenAI-compatible
HTTP API. The guide is model-agnostic; **Gemma-4-12B is the example model**
used for the reference numbers.

**What the pieces are, in one breath:**

| Piece | What it does |
|---|---|
| i915 kernel driver | In-tree on Fedora; drives the Arc GPU. Nothing to install. |
| Level Zero (compute-runtime) | User-space driver the GPU compute stack talks to. |
| SYCL / DPC++ | C++ hetero-compute language+compiler. llama.cpp's SYCL backend compiles kernels with it at runtime (JIT). |
| oneMKL | Intel's math library; supplies the fast GEMMs (the 90% of LLM time). |
| llama.cpp SYCL backend | The glue: runs GGUF models on `level_zero:gpu` devices. |

**Verified performance on an A770 16 GB (Gemma-4-12B Q4_K_M, fa=0):**

| test | tok/s |
|---|---|
| prefill 512 | ~1180 |
| prefill 8192 | ~1050 |
| decode 128 | ~23 (with `GGML_SYCL_ENABLE_GRAPH=1`) |

> On this card the SYCL backend shows the fastest prefill and slower decode
> than llama.cpp's Vulkan backend (measurements: `RESULTS-SUMMARY.md`). The
> Vulkan backend needs only `glslc` + `spirv-headers-devel`
> (`-DGGML_VULKAN=ON`); both backends can coexist in separate build
> directories.

---

## 0. Check the hardware (30 seconds)

```bash
lspci -nn | grep -i vga
# want something like: VGA compatible controller [0300]: Intel ... 56a0 (rev 05)
```

`8086:56a0` is an Arc A770 (DG2/Alchemist). Any recent Arc (A-Series, B-Series)
or Intel iGPU (Meteor Lake and newer) works with this guide.

## 1. Install the GPU compute runtime (2 minutes)

The kernel driver is built into Fedora; you need the *user-space* part:

```bash
sudo dnf install -y intel-compute-runtime intel-level-zero oneapi-level-zero
# optional tools for monitoring:
sudo dnf install -y intel-gpu-tools
```

If `dnf` can't find them, the packages live in the standard Fedora repos
(these are Fedora packages, not Intel-repo packages).

Give your user access to the GPU (render/video groups), then log out and back in:

```bash
sudo usermod -aG render,video $USER
```

**Checkpoint:** after re-login,

```bash
ls /dev/dri/          # expect card0 + renderD128 (numbers may differ)
```

## 2. Optional: raise the power limit

Arc A770 ships with a 190 W software cap; the card tolerates 225 W. First look
at the candidates (there is one hwmon per GPU):

```bash
for d in /sys/class/drm/card*/device/hwmon/hwmon*; do
    [ -f "$d/power1_max" ] && echo "$d: $(cat $d/name 2>/dev/null) = $(cat $d/power1_max)"
done
```

Pick the one whose current value is `190000000` (that's the A770's stock cap;
CPU hwmon entries look different), then:

```bash
echo 225000000 | sudo tee /sys/class/drm/card0/device/hwmon/hwmon8/power1_max
```

(adjust the path to the one you found above; resets at reboot)

## 3. Install oneMKL (2 minutes)

llama.cpp's SYCL backend links **oneMKL SYCL BLAS** for its GEMMs — this is
mandatory for the `INTEL` SYCL target.

```bash
sudo tee /etc/yum.repos.d/oneAPI.repo > /dev/null <<'EOF'
[oneAPI]
name=Intel oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
sudo dnf install -y intel-oneapi-mkl-devel
```

**Checkpoint:** `ls /opt/intel/oneapi/mkl/latest/lib/libmkl_sycl_blas.so` exists.

## 4. Get a SYCL compiler

```bash
sudo dnf install -y intel-oneapi-compiler-dpcpp-cpp
source /opt/intel/oneapi/setvars.sh    # provides icpx/icx + sycl-ls
sycl-ls
```

(`setvars.sh` sets `ONEAPI_ROOT`, which llama.cpp's CMake detects as the
"oneAPI Release compiler" path. The package is ~16 sub-packages, a few GB.)

**Checkpoint:**

```
[level_zero:gpu][level_zero:0] Intel(R) oneAPI Unified Runtime over Level-Zero, Intel(R) Arc(TM) A770 Graphics ...
```

If `sycl-ls` shows no `level_zero:gpu`, go back to step 1 (groups/re-login).

With this toolchain, pristine upstream llama.cpp builds and links against
oneMKL 2026.1 without any source changes (verified: cmake reports "Using oneAPI
Release SYCL compiler (icpx)", full build, no link errors).

> Alternative that was measured but is not part of this guide: the intel/llvm
> nightly `sycl_linux.tar.gz` tarball also builds llama.cpp, but its `clang++`
> requires a small CMake patch to link against oneMKL and measured 14–18%
> slower decode (numbers in RESULTS-SUMMARY.md; the patch is in this repo's
> git history).

## 5. Build llama.cpp with the SYCL backend

```bash
sudo dnf install -y git cmake make gcc-c++ python3
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

source /opt/intel/oneapi/setvars.sh
cmake -B build-sycl \
      -DGGML_SYCL=ON \
      -DGGML_SYCL_F16=ON \
      -DGGML_SYCL_DNN=OFF \
      -DCMAKE_C_COMPILER=icx \
      -DCMAKE_CXX_COMPILER=icpx \
      -DCMAKE_PREFIX_PATH=/opt/intel/oneapi/mkl/latest \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLAMA_CURL=OFF

cmake --build build-sycl -j$(nproc)
```

Flags explained:

- `GGML_SYCL_F16=ON` — fp16 kernels.
- `GGML_SYCL_DNN=OFF` — skip oneDNN (would need `intel-oneapi-dnnl-devel`;
  rebuild with `ON` to test the oneDNN kernels).
- `-DCMAKE_PREFIX_PATH=...` — where to find MKL's CMake config.

Build takes ~10-20 min. **Checkpoint:** these exist:

```
build-sycl/bin/llama-server
build-sycl/bin/llama-bench
```


## 6. Smoke test

```bash
export ONEAPI_DEVICE_SELECTOR="level_zero:0"
export ZES_ENABLE_SYSMAN=1                     # correct free-memory reporting
export GGML_SYCL_ENABLE_GRAPH=1                # ~40% faster decode (see §7)

# any small GGUF works; example: a 1-2B instruct model
./build-sycl/bin/llama-cli -m model.gguf -ngl 99 -p "Hello" -n 32 --no-cnv
```

Expected: generation speed in the tens of tok/s (small model) and the log
line `use 1 SYCL GPUs: [0] with Max compute units:512`.

## 7. Serving a big model + the flags that actually matter

```bash
export ONEAPI_DEVICE_SELECTOR="level_zero:0" ZES_ENABLE_SYSMAN=1 GGML_SYCL_ENABLE_GRAPH=1
./build-sycl/bin/llama-server -m gemma-4-12b-it-Q4_K_M.gguf \
    -ngl 99 -c 16384 -fa 0 -t 8 --port 8082 --host 127.0.0.1
```

- **`-fa`**: benchmark `-fa 0` vs `-fa 1` for *your* model. For the example
  model (Gemma-4: head dims 256/512), flash-attention is much slower on SYCL
  (8K prefill: 473 tok/s with fa=1 vs 973 tok/s with fa=0) — likely a large-
  head-dim effect, not a general rule. Without FA, `-ctk/-ctv q8_0` KV quant
  is unavailable.
- **`-ngl 99`**: offload every layer.
- **`GGML_SYCL_ENABLE_GRAPH=1`**: capture the decode graph once — decode
  16.9 → 22.6 tok/s on the example model with the official toolchain
  (13.7 → 19.2 with the nightly).
- **`-t`**: CPU threads for non-offloaded ops (use your P-core count).
- **`ZES_ENABLE_SYSMAN=1`**: without it Arc's free-memory query returns the
  *total* size, which confuses some tooling.

Then test the API:

```bash
curl -s localhost:8082/v1/completions -H 'Content-Type: application/json' \
  -d '{"prompt":"The capital of France is","max_tokens":8,"temperature":0}'
```

**Reference numbers for the example model** (Gemma-4-12B Q4_K_M, A770 16 GB,
fa=0, graph=1):

| test | tok/s (official oneAPI 2026.1.1 toolchain) |
|---|---|
| pp512 / pp2048 / pp4096 / pp8192 | 1180 / 1133 / 1096 / 1051 |
| tg128 (fresh) | 22.6 |
| tg256 @ 16K context | 17.5 |

Decode degrades only gently with context length; prefill stays nearly flat.

## 8. Troubleshooting

| Symptom | Fix |
|---|---|
| `sycl-ls` shows no `level_zero:gpu` | `usermod -aG render,video $USER`, re-login. Then check `ls /dev/dri`. |
| `libsycl.so: cannot open shared object file` | `source /opt/intel/oneapi/setvars.sh` (or put `/opt/intel/oneapi/compiler/latest/lib` on `LD_LIBRARY_PATH`). |
| `undefined reference to sycl::_V1::...` at link | Not expected with the official toolchain; if you built with a third-party SYCL compiler, link `libsycl` explicitly. |
| `cannot find -lmkl_sycl_blas` | `CMAKE_PREFIX_PATH` didn't point at MKL; check `/opt/intel/oneapi/mkl/latest/lib`. |
| Server starts but slow first request | Normal: SYCL kernels are JIT-compiled on first use (no AOT in this build). Later requests are full speed. |
| Out of device memory | Lower `-c` (KV cache is the big consumer; f16 KV at 16K ≈ 5.7 GB for Gemma-4-12B). |
| Want AOT (no JIT startup) | Optional: `-DGGML_SYCL_DEVICE_ARCH=dg2` at cmake time (AOT via ocloc; needs `intel-igc`/ocloc installed). Unverified in this guide. |
| GPU hangs / fence timeouts in dmesg | Kill the process; if a device reset is needed, `sudo reboot` is the clean fix on i915. |

## 9. Copy-paste environment block (runtime)

Save as `~/.config/llama-sycl-env.sh` and `source` it before running:

```bash
source /opt/intel/oneapi/setvars.sh
export ONEAPI_DEVICE_SELECTOR="level_zero:0"
export ZES_ENABLE_SYSMAN=1
export GGML_SYCL_ENABLE_GRAPH=1
```

---

## Appendix B: versions this tutorial was verified with

| Component | Version |
|---|---|
| Fedora | 44 (kernel 7.1.10) |
| GPU | Arc A770 16 GB (8086:56a0), i915 |
| compute-runtime / Level Zero | 26.22.38646.6 / 1.28.6 (Fedora pkgs) |
| DPC++ | oneAPI 2026.1.1 (intel-oneapi-compiler-dpcpp-cpp, dnf) |
| oneMKL | 2026.1.0-236 (intel-oneapi-mkl-devel) |
| llama.cpp | master @ build 790cf51 era |
| Model for reference numbers | unsloth/gemma-4-12b-it Q4_K_M |
