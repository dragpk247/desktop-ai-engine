# 🗺️ Desktop AI Engine — Project Tracks & Roadmap

This document outlines the current status, deployment plan, and execution tracks for `desktop-ai-engine`.

---

## 🎯 Active Execution Tracks

### Track A.1: Compilation & Binary Verification
- [ ] **Build llama.cpp with CUDA Acceleration**: Run `./build-desktop.sh` using `/opt/cuda/bin/nvcc` and Ninja.
- [ ] **Binary Inspection**: Verify `llama-server` and `llama-cli` execute cleanly and detect CUDA runtime.
- [ ] **Cross-Machine Profile**:
  - *Current Host (Laptop)*: AMD Ryzen 9 5900HS (8C/16T), 16 GB RAM, RTX 3050 Ti (4 GB VRAM).
  - *Target Desktop*: AMD Ryzen 9 9950X3D (16C/32T Zen 5), 64 GB DDR5, RTX 5070 Ti (16 GB VRAM).

### Track A.2: Model Download & Quantization Strategy
- [ ] **Primary Target (Desktop Deployment)**:
  - Download Qwen 2.5 14B Instruct (`qwen2.5-14b-instruct-q4_k_m.gguf`, ~9.0 GB).
  - Download Speculative Draft model (`qwen2.5-0.5b-instruct-q4_k_m.gguf`, ~400 MB).
- [ ] **Laptop Fallback / Testing Profile**:
  - Quantized 1.5B or 3B model (or 7B Q4 with offload) that fits inside the local 4 GB VRAM budget.

### Track A.3: Daemonization & Remote Networking
- [ ] **Systemd User Service**:
  - Install [`desktop-ai.service`](desktop-ai.service) into `~/.config/systemd/user/`.
  - Enable and start: `systemctl --user enable --now desktop-ai.service`.
  - Verify status: `systemctl --user status desktop-ai.service`.
- [ ] **Tailscale Integration**:
  - Run `./setup-remote-access.sh` for zero-trust remote access from laptops/mobile devices.
  - Test health endpoint: `curl http://localhost:8080/health`.
