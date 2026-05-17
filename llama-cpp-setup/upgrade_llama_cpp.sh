#!/bin/bash

cd "$HOME/code/repos/llama.cpp"
git pull

cmake -B build -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/bin/llama.cpp \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON \
    -DGGML_NATIVE=ON \
    -DGGML_VULKAN=ON

cmake --build build --config Release -j $(nproc)
cmake --install build --config Release
