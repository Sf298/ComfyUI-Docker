#!/bin/bash

# Activate any environment if needed (not always required with base image)
# source /opt/pytorch/bin/activate

# Start cron
cron

# Start ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --cuda-device=0  --enable-manager
