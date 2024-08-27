# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

COPY scripts/start-stable-diffusion-webui.sh scripts/install-stable-diffusion-webui.sh /scripts/

SHELL ["/bin/bash", "-c"]

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG STABLE_DIFFUSION_WEBUI_VERSION
ARG STABLE_DIFFUSION_WEBUI_SHA256_CHECKSUM
ARG TORCH_VERSION
ARG TORCH_VISION_VERSION
ARG OPENCV_PYTHON_HEADLESS_VERSION
ARG PACKAGES_TO_INSTALL

# hadolint ignore=DL4006
RUN \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Install build dependencies. \
    && homelab install util-linux \
    # Install dependencies. \
    && homelab install ${PACKAGES_TO_INSTALL:?} \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    # Download and install the release. \
    && homelab install-tar-dist \
        https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/tags/${STABLE_DIFFUSION_WEBUI_VERSION:?}.tar.gz \
        "${STABLE_DIFFUSION_WEBUI_SHA256_CHECKSUM:?}" \
        stable-diffusion-webui \
        stable-diffusion-webui-"$(echo "${STABLE_DIFFUSION_WEBUI_VERSION:?}" | sed -E 's/^v(.+)$/\1/g')" \
        ${USER_NAME:?} \
        ${GROUP_NAME:?} \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} /opt/stable-diffusion-webui/ \
    && su --login --shell /bin/bash --command "TORCH_VERSION=${TORCH_VERSION:?} TORCH_VISION_VERSION=${TORCH_VISION_VERSION:?} OPENCV_PYTHON_HEADLESS_VERSION=${OPENCV_PYTHON_HEADLESS_VERSION:?} /scripts/install-stable-diffusion-webui.sh" ${USER_NAME:?} \
    && ln -sf /scripts/start-stable-diffusion-webui.sh /opt/bin/start-stable-diffusion-webui \
    # Clean up. \
    && rm /scripts/install-stable-diffusion-webui.sh \
    && homelab remove util-linux \
    && homelab cleanup

EXPOSE 7860

ENV USER=${USER_NAME}
USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

CMD ["start-stable-diffusion-webui"]
STOPSIGNAL SIGINT
