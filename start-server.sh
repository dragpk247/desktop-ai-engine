#!/usr/bin/env bash
# ==============================================================================
# start-server.sh: Ultra-Low Latency OpenAI-Compatible Server for Desktop
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

# 2. Pick primary model
MODEL_FILE=""
MODEL_ALIAS=""
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
  FIRST_GGUF=$(find "$MODELS_DIR" -name "*.gguf" ! -name "*0.5b*" | head -n 1)
  if [ -n "$FIRST_GGUF" ]; then
    MODEL_FILE="$FIRST_GGUF"
    MODEL_ALIAS="local-model"
  else
    echo "❌ Error: No primary .gguf model found in $MODELS_DIR."
    echo "👉 Please run ./download-models.sh first."
    exit 1
  fi
fi

# 3. Check for Speculative Decoding Draft Model
DRAFT_ARGS=()
DRAFT_FILE="$MODELS_DIR/qwen2.5-0.5b-instruct-q4_k_m.gguf"
if [ -f "$DRAFT_FILE" ] && [[ "$MODEL_FILE" != *"0.5b"* ]]; then
  echo "⚡ [Speculative Decoding] Draft model detected ($DRAFT_FILE)!"
  echo "   Enabling speculative execution -> expected 1.8x-2.5x generation speedup."
  DRAFT_ARGS=(
    "-md" "$DRAFT_FILE"
    "-ngld" "99"
    "--draft-max" "8"
    "--draft-min" "3"
  )
fi

# 4. Detect IP Addresses (LAN + Tailscale)
LAN_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || true)
PORT=8080

echo "========================================================================"
echo "🚀 [Desktop AI Engine] Launching Ultra-Low Latency Inference Server"
echo "🖥️  Target Model: $MODEL_FILE"
echo "⚡ GPU Offload:  RTX 5070 Ti 16GB (100% offload: -ngl 99)"
echo "🧠 CPU Tuning:   Ryzen 9 9950X3D (AVX-512 VNNI, mlock pinned)"
echo "🌐 Local Access: http://127.0.0.1:$PORT"
echo "📶 LAN Access:   http://${LAN_IP:-<desktop-ip>}:$PORT/v1"
if [ -n "$TAILSCALE_IP" ]; then
  echo "🔒 Remote (Net): http://$TAILSCALE_IP:$PORT/v1 (Tailscale Encrypted)"
fi
echo "========================================================================"

# 5. Check if we should pin to 3D V-Cache cores (CCD0 on 32-thread 9950X3D)
EXEC_PREFIX=()
TOTAL_THREADS=$(nproc)
if [ "$TOTAL_THREADS" -ge 24 ] && command -v taskset >/dev/null 2>&1; then
  echo "🎯 Pinning execution to 3D V-Cache CCD cores (0-15) to prevent cache hopping."
  EXEC_PREFIX=("taskset" "-c" "0-15")
fi

# 6. Execute server
exec "${EXEC_PREFIX[@]}" "$SERVER_BIN" \
  -m "$MODEL_FILE" \
  --alias "$MODEL_ALIAS" \
  --host 0.0.0.0 \
  --port "$PORT" \
  -ngl 99 \
  --flash-attn on \
  -c 16384 \
  -ctk q8_0 \
  -ctv q8_0 \
  --mlock \
  --parallel 2 \
  -cb \
  "${DRAFT_ARGS[@]}"
