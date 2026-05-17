#!/bin/bash

sudo dnf update
sudo dnf group install development-tools \
    c-development \
    system-tools
sudo dnf install \
    cmake \
    vulkan-loader-devel \
    tmux \
    vim \
    tk \
    tk-devel \
    openssh \
    curl \
    xz \
    xz-devel \
    bzip2 \
    bzip2-devel \
    ncurses \
    ncurses-devel \
    readline \
    readline-devel \
    sqlite3 \
    sqlite-devel \
    lzma \
    nvtop \
    git \
    git-lfs


git-lfs install

curl -fsSL https://pyenv.run | bash

# Add pyenv to future interactive shells                                                                                                                             
if ! grep -q 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.bashrc"; then                                                                                                
    cat >> "$HOME/.bashrc" <<'EOF'
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"                                                                                                      
eval "$(pyenv init - bash)"                                                                                                                                          
eval "$(pyenv virtualenv-init -)"                                                                                                                                    
EOF
fi

# Load pyenv into this script right now                                                                                                                              
export PYENV_ROOT="$HOME/.pyenv"                                                                                                                                     
export PATH="$PYENV_ROOT/bin:$PATH"                                                                                                                                  
eval "$("$PYENV_ROOT/bin/pyenv" init - bash)"                                                                                                                        
eval "$("$PYENV_ROOT/bin/pyenv" virtualenv-init -)"


pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

mkdir -p "$HOME/vulkan-sdk"
wget -O "$HOME/vulkan-sdk/vulkansdk-linux-x86_64-1.4.350.0.tar.xz" \
    https://sdk.lunarg.com/sdk/download/1.4.350.0/linux/vulkansdk-linux-x86_64-1.4.350.0.tar.xz
tar -xf "$HOME/vulkan-sdk/vulkansdk-linux-x86_64-1.4.350.0.tar.xz" -C "$HOME/vulkan-sdk"

# Install Vulkan SDK
if ! grep -q 'export VULKAN_SDK=$HOME/vulkan-sdk/1.4.350.0/x86_64' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

export VULKAN_SDK=$HOME/vulkan-sdk/1.4.350.0/x86_64
export PATH=$PATH:$VULKAN_SDK/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VULKAN_SDK/lib
export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d
export VK_ADD_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d
export PKG_CONFIG_PATH=$VULKAN_SDK/lib/pkgconfig

EOF
fi


mkdir -p $HOME/code/repos
mkdir -p $HOME/bin/llama.cpp
mkdir -p $HOME/models

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

mkdir -p "$HOME/models/gemma-4-E4B-it-GGUF"
wget -O "$HOME/models/gemma-4-E4B-it-GGUF/gemma-4-E4B-it-UD-Q4_K_XL.gguf" \
    https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-UD-Q4_K_XL.gguf
wget -O "$HOME/models/gemma-4-E4B-it-GGUF/mmproj-BF16.gguf" \
    https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/mmproj-BF16.gguf

touch "$HOME/models/run-gemma-4-E4B-it-GGUF.sh"
chmod +x "$HOME/models/run-gemma-4-E4B-it-GGUF.sh"
    cat >> "$HOME/models/run-gemma-4-E4B-it-GGUF.sh" <<'EOF'
#!/bin/bash

"$HOME/bin/llama.cpp/bin/llama-server" \
    -m "$HOME/models/gemma-4-E4B-it-GGUF/gemma-4-E4B-it-UD-Q4_K_XL.gguf"\
    --mmproj "$HOME/models/gemma-4-E4B-it-GGUF/mmproj-BF16.gguf" \
    -a gemma-4-E4B-it \
    -fa on \
    -c 131072 \
    --host 0.0.0.0 \
    --port 8000 \
    -np 1
EOF

echo "Done."