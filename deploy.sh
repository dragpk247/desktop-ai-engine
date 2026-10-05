#!/usr/bin/env bash
# ==============================================================================
# deploy.sh: One-Click Desktop AI Engine Setup
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================================================"
echo "⚡ Starting All-in-One Desktop AI Workstation Deployment"
echo "   Hardware target: AMD Ryzen 9 9950X3D + NVIDIA RTX 5070 Ti 16GB"
echo "========================================================================"

# Step 1: Make scripts executable
chmod +x build-desktop.sh download-models.sh start-server.sh start-cli.sh setup-vllm.sh

# Step 2: Build llama.cpp
echo ""
echo "▶️ Step 1/3: Compiling hardware-optimized engine..."
./build-desktop.sh

# Step 3: Download model
echo ""
echo "▶️ Step 2/3: Downloading model weights..."
./download-models.sh

# Step 4: Ask whether to run as background service or launch now
echo ""
echo "▶️ Step 3/3: Setup complete!"
echo "Would you like to:"
echo "1) Launch the server right now in this terminal"
echo "2) Install and enable the systemd background service (auto-starts on boot)"
echo "3) Exit"

read -rp "Enter choice [1-3] (default: 1): " action
action="${action:-1}"

if [ "$action" = "1" ]; then
  ./start-server.sh
elif [ "$action" = "2" ]; then
  mkdir -p "$HOME/.config/systemd/user"
  # Update WorkingDirectory and ExecStart in service file to actual path
  sed "s|%h/desktop-ai-engine|$SCRIPT_DIR|g" desktop-ai.service > "$HOME/.config/systemd/user/desktop-ai.service"
  systemctl --user daemon-reload
  systemctl --user enable --now desktop-ai.service
  echo "✅ desktop-ai.service is active and enabled on boot!"
  echo "👉 Status check: systemctl --user status desktop-ai.service"
  echo "👉 Logs:         journalctl --user -u desktop-ai.service -f"
else
  echo "Done! You can run ./start-server.sh whenever you are ready."
fi
