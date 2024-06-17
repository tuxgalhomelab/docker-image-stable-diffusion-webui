#!/usr/bin/env bash
set -E -e -o pipefail

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_stable_diffusion_webui() {
    echo "Starting stable-diffusion-webui ..."
    echo
    cd /opt/stable-diffusion-webui
    source bin/activate

    export PYTHONUNBUFFERED=1
    export PYTHONIOENCODING=UTF-8

    local skip_download_sd_model_flag=""
    if [[ "${SKIP_DOWNLOAD_SD_MODEL}" == "y" ]]; then
        skip_download_sd_model_flag="--no-download-sd-model"
    fi

    exec python3 launch.py \
        --listen \
        --port 7860 \
        --use-cpu all \
        --no-half \
        $skip_download_sd_model_flag \
        --skip-torch-cuda-test
}

set_umask
start_stable_diffusion_webui
