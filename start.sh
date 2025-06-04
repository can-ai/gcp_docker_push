#!/bin/bash
set -e

# Verify Python environment
if ! command -v python &> /dev/null; then
    echo "Error: Python not found"
    exit 1
fi

# Verify ComfyUI directory
if [ ! -d "/app/ComfyUI" ]; then
    echo "Error: ComfyUI directory not found at /app/ComfyUI"
    exit 1
fi

# Start SSH server
echo "Starting SSH server..."
/usr/sbin/sshd

# Navigate to ComfyUI directory
cd /app/ComfyUI

# Start ComfyUI server
echo "Starting ComfyUI server..."
exec python main.py --listen 0.0.0.0 --port 8188