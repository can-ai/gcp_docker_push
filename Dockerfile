FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update -y && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs wget vim zip unzip curl && \
    python3 -m pip install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install huggingface[cli]
RUN pip install "huggingface_hub[cli]"

# Set working directory
WORKDIR /app

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Download necessities using huggingface-cli with token as environment variable
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00001-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00002-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00003-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00004-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00005-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B diffusion_pytorch_model-00006-of-00006.safetensors --local-dir /app/ComfyUI/models/diffusion_models --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B models_t5_umt5-xxl-enc-bf16.pth --local-dir /app/ComfyUI/models/clip --token=$HF_TOKEN
RUN huggingface-cli download Kijai/WanVideo_comfy Wan2.1-Fun-Control-14B_fp8_e4m3fn.safetensors --local-dir /app/ComfyUI/models/controlnet --token=$HF_TOKEN
RUN huggingface-cli download Kijai/WanVideo_comfy Wan21_CausVid_14B_T2V_lora_rank32.safetensors --local-dir /app/ComfyUI/models/loras --token=$HF_TOKEN
RUN huggingface-cli download Comfy-Org/Wan_2.1_ComfyUI_repackaged clip_vision/clip_vision_h.safetensors --local-dir /app/ComfyUI/models/clip_vision --token=$HF_TOKEN
RUN huggingface-cli download Wan-AI/Wan2.1-T2V-14B Wan2.1_VAE.pth --local-dir /app/ComfyUI/models/vae --token=$HF_TOKEN

EXPOSE 8188
EXPOSE 22

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]