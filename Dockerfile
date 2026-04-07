# Use official ROCm-enabled PyTorch image from AMD
FROM rocm/pytorch:rocm6.4.4_ubuntu24.04_py3.12_pytorch_release_2.7.1

# Set working directory
WORKDIR /workspace/ComfyUI

# Install system-level dependencies
RUN apt-get update && \
    apt-get install -y git wget sudo cron && \
    rm -rf /var/lib/apt/lists/*

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git . && \
    pip install --upgrade pip

# Install ComfyUI Python dependencies
RUN pip install -r requirements.txt

# Install ROCm-compatible PyTorch (ensure it's reinstalled correctly)
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3 --force-reinstall --no-cache-dir

# Optional: Install ComfyUI Manager (popular custom node)
RUN mkdir -p custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/comfyui-manager

# Expose ComfyUI port
EXPOSE 8188

# Create non-root user (optional but recommended for security)
#RUN chown -R ubuntu:ubuntu /workspace/ComfyUI
#RUN cat /etc/passwd

# Create cron job to delete PNGs older than 10 minutes
RUN echo "* * * * * root find /workspace/ComfyUI/output/* /workspace/ComfyUI/input/* -mmin +10 -type f -delete >> /var/log/cron.log 2>&1" > /etc/cron.d/png-cleanup && \
    chmod 0644 /etc/cron.d/png-cleanup && \
    touch /var/log/cron.log

# Launch script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
