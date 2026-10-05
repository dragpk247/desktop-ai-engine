# ⚡ Desktop AI Inference Engine

High-performance, hardware-optimized local AI inference server designed specifically for:
* **CPU:** AMD Ryzen 9 9950X3D (16C/32T Zen 5, AVX-512 VNNI, 128MB+ 3D V-Cache)
* **GPU:** NVIDIA GeForce RTX 5070 Ti (16GB GDDR7, Blackwell Tensor Cores)
* **RAM:** 64GB DDR5

---

## 🚀 1-Minute Quick Start on Desktop

### 1. Run the One-Click Installer:
```bash
cd desktop-ai-engine
chmod +x deploy.sh
./deploy.sh
```

The script will automatically:
1. Detect host architecture and compile `llama.cpp` using Ninja, AVX-512, and CUDA.
2. Download the recommended **Qwen 2.5 14B Instruct (Q4_K_M)** model (fits 100% in 16GB VRAM).
3. Optionally install a background systemd user service (`desktop-ai.service`) so it runs automatically on boot.

---

## 💻 Connecting From Your Laptop

Once `start-server.sh` is running on your desktop, it binds to `0.0.0.0:8080`, allowing your laptop (and other devices on your Wi-Fi) to query your desktop's RTX 5070 Ti!

### 1. Test via cURL from Laptop:
Replace `<DESKTOP_IP>` with your desktop's local IP (printed in the terminal when `start-server.sh` launches):

```bash
curl http://<DESKTOP_IP>:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-14b",
    "messages": [{"role": "user", "content": "Explain quantum computing in one sentence."}]
  }'
```

### 2. Use with Python / OpenAI SDK on Laptop:
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://<DESKTOP_IP>:8080/v1",
    api_key="not-needed"
)

response = client.chat.completions.create(
    model="qwen2.5-14b",
    messages=[{"role": "user", "content": "Write a Python script to sort a list."}]
)

print(response.choices[0].message.content)
```

### 3. Use with Coding Agents (Agy, Continue, Cursor, Cline):
Set your endpoint in their settings:
* **Base URL:** `http://<DESKTOP_IP>:8080/v1`
* **Model:** `qwen2.5-14b`
* **API Key:** any string (e.g. `local`)

---

## 📂 Project Structure

| File | Purpose |
| :--- | :--- |
| `deploy.sh` | Master setup script (builds, downloads, configures) |
| `build-desktop.sh` | Compiles `llama.cpp` with Zen 5 AVX-512 + CUDA optimizations |
| `download-models.sh` | Resumable downloader for 7B, 14B, and 32B models |
| `start-server.sh` | Launches production OpenAI-compatible server on `0.0.0.0:8080` |
| `start-cli.sh` | Direct interactive terminal chat on desktop |
| `setup-vllm.sh` | High-concurrency alternative using vLLM |
| `desktop-ai.service` | Systemd service file for auto-start on boot |
