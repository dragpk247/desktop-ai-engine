#!/usr/bin/env bash
# ==============================================================================
# start-cli.sh: Interactive Terminal Chat on Desktop
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-cli"
MODELS_DIR="$SCRIPT_DIR/models"

if [ ! -f "$CLI_BIN" ]; then
  echo "❌ Error: llama-cli binary not found. Please run ./build-desktop.sh first."
  exit 1
fi

MODEL_FILE=$(find "$MODELS_DIR" -name "*.gguf" | head -n 1)
if [ -z "$MODEL_FILE" ]; then
  echo "❌ Error: No models found. Please run ./download-models.sh first."
  exit 1
fi

echo "💬 Starting interactive chat with $(basename "$MODEL_FILE")..."
exec "$CLI_BIN" \
  -m "$MODEL_FILE" \
  -ngl 99 \
  --flash-attn on \
  -c 16384 \
  -ctk q8_0 \
  -ctv q8_0 \
  -co \
  --conversation \
  -p "You are an intelligent, helpful AI assistant running locally on a high-performance desktop workstation."
