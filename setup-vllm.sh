#!/usr/bin/env bash
# ==============================================================================
# setup-vllm.sh: vLLM High-Concurrency Engine Setup (Optional Alternative)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv-vllm"

echo "⚡ [vLLM Setup] Initializing Python virtual environment for vLLM..."

if command -v uv >/dev/null 2>&1; then
  echo "📦 Creating virtual environment using uv..."
  uv venv "$VENV_DIR" --python 3.11 || uv venv "$VENV_DIR"
  # shellcheck source=/dev/null
  source "$VENV_DIR/bin/activate"
  echo "📥 Installing vLLM with CUDA acceleration..."
  uv pip install vllm
else
  echo "📦 Creating virtual environment using standard python3..."
  python3 -m venv "$VENV_DIR"
  # shellcheck source=/dev/null
  source "$VENV_DIR/bin/activate"
  pip install --upgrade pip
  echo "📥 Installing vLLM..."
  pip install vllm
fi

cat << 'EOF' > "$SCRIPT_DIR/start-vllm.sh"
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/venv-vllm/bin/activate"

MODEL="${1:-Qwen/Qwen2.5-14B-Instruct-GPTQ-Int4}"

echo "🚀 Starting vLLM engine with model: $MODEL on port 8000..."
exec vllm serve "$MODEL" \
  --host 0.0.0.0 \
  --port 8000 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 16384 \
  --enforce-eager
EOF
chmod +x "$SCRIPT_DIR/start-vllm.sh"

echo "✅ vLLM installation complete!"
echo "👉 To launch vLLM: ./start-vllm.sh [model_name]"
