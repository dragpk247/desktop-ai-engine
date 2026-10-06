#!/usr/bin/env bash
# ==============================================================================
# download-models.sh: Optimized GGUF Model Downloader with Speculative Draft Models
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_DIR="$SCRIPT_DIR/models"
mkdir -p "$MODELS_DIR"

# HuggingFace URLs (Official Q4_K_M quants)
URL_DRAFT="https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf"
FILE_DRAFT="$MODELS_DIR/qwen2.5-0.5b-instruct-q4_k_m.gguf"

URL_14B="https://huggingface.co/Qwen/Qwen2.5-14B-Instruct-GGUF/resolve/main/qwen2.5-14b-instruct-q4_k_m.gguf"
FILE_14B="$MODELS_DIR/qwen2.5-14b-instruct-q4_k_m.gguf"

URL_7B="https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m.gguf"
FILE_7B="$MODELS_DIR/qwen2.5-7b-instruct-q4_k_m.gguf"

URL_32B="https://huggingface.co/Qwen/Qwen2.5-32B-Instruct-GGUF/resolve/main/qwen2.5-32b-instruct-q4_k_m.gguf"
FILE_32B="$MODELS_DIR/qwen2.5-32b-instruct-q4_k_m.gguf"

download_file() {
  local name="$1"
  local url="$2"
  local dest="$3"

  echo "========================================================"
  echo "📥 Downloading: $name"
  echo "🎯 Destination: $dest"
  echo "========================================================"

  if [ -f "$dest" ]; then
    echo "ℹ️ Existing file detected. Resuming if incomplete..."
  fi

  curl -L --fail --retry 5 --retry-delay 3 -C - --progress-bar "$url" -o "$dest"
  echo "✅ Successfully downloaded: $name"
}

echo "Select which model tier to download for your Desktop setup:"
echo "1) [RECOMMENDED] Qwen 2.5 14B + 0.5B Draft Model (~9.4 GB total)"
echo "   -> Enables Speculative Decoding (120-140 t/s, 100% VRAM offload)"
echo "2) Qwen 2.5 7B + 0.5B Draft Model (~4.8 GB total)"
echo "   -> Maximum throughput (~150+ t/s)"
echo "3) Qwen 2.5 32B Instruct (~19.8 GB)"
echo "   -> High reasoning / complex coding"
echo "4) Download ALL models"

read -rp "Enter choice [1-4] (default: 1): " choice
choice="${choice:-1}"

case "$choice" in
  1)
    download_file "Qwen 2.5 0.5B Draft Model" "$URL_DRAFT" "$FILE_DRAFT"
    download_file "Qwen 2.5 14B Instruct (Q4_K_M)" "$URL_14B" "$FILE_14B"
    ;;
  2)
    download_file "Qwen 2.5 0.5B Draft Model" "$URL_DRAFT" "$FILE_DRAFT"
    download_file "Qwen 2.5 7B Instruct (Q4_K_M)" "$URL_7B" "$FILE_7B"
    ;;
  3)
    download_file "Qwen 2.5 32B Instruct (Q4_K_M)" "$URL_32B" "$FILE_32B"
    ;;
  4)
    download_file "Qwen 2.5 0.5B Draft Model" "$URL_DRAFT" "$FILE_DRAFT"
    download_file "Qwen 2.5 7B Instruct (Q4_K_M)" "$URL_7B" "$FILE_7B"
    download_file "Qwen 2.5 14B Instruct (Q4_K_M)" "$URL_14B" "$FILE_14B"
    download_file "Qwen 2.5 32B Instruct (Q4_K_M)" "$URL_32B" "$FILE_32B"
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac

echo ""
echo "🎉 Model downloads finished! Stored in: $MODELS_DIR"
