#!/usr/bin/env bash
# ==============================================================================
# download-models.sh: Optimized GGUF Model Downloader
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_DIR="$SCRIPT_DIR/models"
mkdir -p "$MODELS_DIR"

# Official HuggingFace URLs (Q4_K_M quants from Qwen / bartowski)
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

echo "Select which model(s) to download for your Desktop setup:"
echo "1) [RECOMMENDED] Qwen 2.5 14B Instruct Q4_K_M (~9.0 GB) -> 100% fits 16GB VRAM, ~75 t/s"
echo "2) Qwen 2.5 7B Instruct Q4_K_M (~4.4 GB)               -> Ultra-fast speed, ~120+ t/s"
echo "3) Qwen 2.5 32B Instruct Q4_K_M (~19.8 GB)             -> Advanced coding & logic"
echo "4) Download ALL models"

read -rp "Enter choice [1-4] (default: 1): " choice
choice="${choice:-1}"

case "$choice" in
  1)
    download_file "Qwen 2.5 14B Instruct (Q4_K_M)" "$URL_14B" "$FILE_14B"
    ;;
  2)
    download_file "Qwen 2.5 7B Instruct (Q4_K_M)" "$URL_7B" "$FILE_7B"
    ;;
  3)
    download_file "Qwen 2.5 32B Instruct (Q4_K_M)" "$URL_32B" "$FILE_32B"
    ;;
  4)
    download_file "Qwen 2.5 14B Instruct (Q4_K_M)" "$URL_14B" "$FILE_14B"
    download_file "Qwen 2.5 7B Instruct (Q4_K_M)" "$URL_7B" "$FILE_7B"
    download_file "Qwen 2.5 32B Instruct (Q4_K_M)" "$URL_32B" "$FILE_32B"
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac

echo ""
echo "🎉 Model downloads finished! Stored in: $MODELS_DIR"
