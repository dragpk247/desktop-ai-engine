#!/usr/bin/env bash
# ==============================================================================
# build-desktop.sh: High-Performance Build for Ryzen 9 9950X3D + RTX 5070 Ti
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_DIR="$SCRIPT_DIR/llama.cpp"

echo "⚡ [Desktop AI Engine] Initializing build environment..."

# 1. Dependency checks
command -v git >/dev/null 2>&1 || { echo "❌ Error: git is required."; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo "❌ Error: cmake is required."; exit 1; }
command -v ninja >/dev/null 2>&1 || { echo "❌ Error: ninja is required."; exit 1; }
command -v nvcc >/dev/null 2>&1 || { echo "⚠️ Warning: nvcc (CUDA toolkit) not found in PATH. Ensure CUDA is installed."; }

# 2. Clone or update llama.cpp
if [ ! -d "$LLAMA_DIR" ]; then
  echo "📥 Cloning latest llama.cpp repository..."
  git clone https://github.com/ggerganov/llama.cpp.git "$LLAMA_DIR"
else
  echo "🔄 Updating existing llama.cpp repository..."
  cd "$LLAMA_DIR"
  git pull --ff-only || true
fi

cd "$LLAMA_DIR"

# 3. Configure with Hardware-Specific Optimizations:
# - Zen 5 AVX-512 + AVX-512 VNNI vector execution
# - Native compiler flags tuned for host CPU architecture
# - CUDA acceleration for RTX 5070 Ti
echo "⚙️ Configuring build with Ninja + AVX-512 + CUDA..."
cmake -B build -G Ninja \
  -DGGML_CUDA=ON \
  -DGGML_NATIVE=ON \
  -DGGML_AVX512=ON \
  -DGGML_AVX512_VNNI=ON \
  -DCMAKE_BUILD_TYPE=Release

# 4. Compile across all CPU threads
CORES=$(nproc)
echo "🚀 Building targets using $CORES parallel compilation threads..."
cmake --build build -j"$CORES"

echo "✅ Build complete! Binaries located at:"
echo "   - Server: $LLAMA_DIR/build/bin/llama-server"
echo "   - CLI:    $LLAMA_DIR/build/bin/llama-cli"
