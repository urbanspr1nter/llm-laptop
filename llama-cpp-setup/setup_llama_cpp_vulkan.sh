#!/bin/bash

mkdir -p $HOME/bin/llama.cpp

if [ ! -d "$HOME/code/repos/llama.cpp/.git" ]; then                                                                                                                  
    git clone https://github.com/ggml-org/llama.cpp "$HOME/code/repos/llama.cpp"                                                                                     
else                                                                                                                                                                 
    echo "llama.cpp already exists, pulling latest changes..."                                                                                                       
    git -C "$HOME/code/repos/llama.cpp" pull                                                                                                                         
fi

python3 -m venv $HOME/code/repos/llama.cpp/.venv
"$HOME/code/repos/llama.cpp/.venv/bin/python" -m pip install -r "$HOME/code/repos/llama.cpp/requirements.txt"

cd "$HOME/code/repos/llama.cpp"
cmake -B build -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/bin/llama.cpp \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON \
    -DGGML_NATIVE=ON \
    -DGGML_VULKAN=ON

cmake --build build --config Release -j $(nproc)
cmake --install build --config Release
