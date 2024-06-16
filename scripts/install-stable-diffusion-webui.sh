#!/usr/bin/env bash
set -E -e -o pipefail

export PYENV_ROOT="/opt/pyenv"
export PATH="${PYENV_ROOT:?}/shims:${PYENV_ROOT:?}/bin:${PATH:?}"

echo "Installing stable-diffusion-webui ..."

cd /opt/stable-diffusion-webui
python3 -m venv .
source bin/activate

export PYTHONUNBUFFERED=1
export PYTHONIOENCODING=UTF-8

pip3 install \
    torch==${TORCH_VERSION:?} \
    torchvision==${TORCH_VISION_VERSION:?} \
    --index-url https://download.pytorch.org/whl/cpu
python3 launch.py --skip-torch-cuda-test --exit
pip3 install \
    opencv-python-headless==${OPENCV_PYTHON_HEADLESS_VERSION:?}

# TODO; Install extensions.
