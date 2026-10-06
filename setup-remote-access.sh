#!/usr/bin/env bash
# ==============================================================================
# setup-remote-access.sh: Secure Remote Inference via Tailscale (Zero Router Ports)
# ==============================================================================
set -euo pipefail

echo "========================================================================"
echo "🔒 [Remote AI Access] Tailscale Mesh Setup"
echo "   Allows querying your Desktop RTX 5070 Ti from any network safely"
echo "   with end-to-end WireGuard encryption and zero port forwarding."
echo "========================================================================"

if command -v tailscale >/dev/null 2>&1; then
  echo "✅ Tailscale is already installed!"
else
  echo "📥 Installing Tailscale..."
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm tailscale
  elif command -v apt-get >/dev/null 2>&1; then
    curl -fsSL https://tailscale.com/install.sh | sh
  else
    echo "❌ Unsupported package manager. Please install Tailscale manually from https://tailscale.com."
    exit 1
  fi
fi

# Enable and start the system service
echo "⚙️ Ensuring tailscaled service is enabled and running..."
sudo systemctl enable --now tailscaled

# Check current status
if tailscale status >/dev/null 2>&1; then
  CURRENT_IP=$(tailscale ip -4)
  echo "🎉 Tailscale is authenticated and active!"
  echo "👉 Your private Tailscale IP is: $CURRENT_IP"
  echo "👉 From your laptop, you can access your desktop AI server at:"
  echo "   http://$CURRENT_IP:8080/v1"
else
  echo ""
  echo "👉 Please log in to your Tailscale account to connect this machine to your tailnet:"
  sudo tailscale up
  CURRENT_IP=$(tailscale ip -4)
  echo ""
  echo "🎉 Connected! Your private Tailscale IP is: $CURRENT_IP"
  echo "👉 Query endpoint from any device on your Tailscale network:"
  echo "   http://$CURRENT_IP:8080/v1"
fi
