#!/usr/bin/env bash
# ==============================================================================
# start-server.sh: High-Throughput OpenAI-Compatible Server for Desktop
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-server"
MODELS_DIR="$SCRIPT_DIR/models"

# 1. Verify binary exists
if [ ! -f "$SERVER_BIN" ]; then
  echo "❌ Error: llama-server binary not found at $SERVER_BIN"
  echo "👉 Please run ./build-desktop.sh first."
  exit 1
fi

# 2. Pick model (default to 14B if present, else 7B or 32B)
MODEL_FILE=""
if [ -f "$MODELS_DIR/qwen2.5-14b-instruct-q4_k_m.gguf" ]; then
  MODEL_FILE="$MODELS_DIR/qwen2.5-14b-instruct-q4_k_m.gguf"
  MODEL_ALIAS="qwen2.5-14b"
elif [ -f "$MODELS_DIR/qwen2.5-7b-instruct-q4_k_m.gguf" ]; then
  MODEL_FILE="$MODELS_DIR/qwen2.5-7b-instruct-q4_k_m.gguf"
  MODEL_ALIAS="qwen2.5-7b"
elif [ -f "$MODELS_DIR/qwen2.5-32b-instruct-q4_k_m.gguf" ]; then
  MODEL_FILE="$MODELS_DIR/qwen2.5-32b-instruct-q4_k_m.gguf"
  MODEL_ALIAS="qwen2.5-32b"
else
  # Check if any .gguf exists
  FIRST_GGUF=$(find "$MODELS_DIR" -name "*.gguf" | head -n 1)
  if [ -n "$FIRST_GGUF" ]; then
    MODEL_FILE="$FIRST_GGUF"
    MODEL_ALIAS="local-model"
  else
    echo "❌ Error: No .gguf model found in $MODELS_DIR."
    echo "👉 Please run ./download-models.sh first."
    exit 1
  fi
fi

# 3. Detect Host IP for Remote/Laptop Access
HOST_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')
PORT=8080

echo "========================================================================"
echo "🚀 [Desktop AI Engine] Launching Hardware-Accelerated Server"
echo "🖥️  Model:      $MODEL_FILE"
echo "⚡ GPU:        RTX 5070 Ti 16GB (100% offload: -ngl 99)"
echo "🧠 CPU:        Ryzen 9 9950X3D (AVX-512 VNNI active)"
echo "🌐 Local URL:  http://127.0.0.1:$PORT"
echo "💻 Laptop URL: http://${HOST_IP:-<desktop-ip>}:$PORT/v1"
echo "========================================================================"

# Launch server
exec "$SERVER_BIN" \
  -m "$MODEL_FILE" \
  --alias "$MODEL_ALIAS" \
  --host 0.0.0.0 \
  --port "$PORT" \
  -ngl 99 \
  --flash-attn on \
  -c 16384 \
  -ctk q8_0 \
  -ctv q8_0 \
  --parallel 2 \
  -cb
