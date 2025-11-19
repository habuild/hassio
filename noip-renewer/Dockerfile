ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.1.1
FROM $BUILD_FROM



# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk update && apk add --no-cache \
    mosquitto-clients \
    nano
ENV PATH=/data/options.json
ENV NO_IP_USERNAME="$NOIP_Email:$PATH"
ENV NO_IP_PASSWORD="$NOIP_Password:$PATH"
ENV NO_IP_TOTP_KEY="NOIP_TOTP_KEY:$PATH"
ENV TRANSLATE_ENABLED="false"
      
WORKDIR /etc/s6-overlay/s6-rc.d/noip/

FROM simaofsilva/noip-renewer:latest

# Copy root filesystem
COPY rootfs /

RUN chmod -Rv a+x /etc/s6-overlay/s6-rc.d/noip/**


# CMD docker exec -it --env NO_IP_PASSWORD="$PASSWORD" --env NO_IP_TOTP_KEY="$NOIP_TOTPKEY" --env TRANSLATE_ENABLED="$TRANSLATE" simaofsilva/noip-renewer:latest /bin/bash
# CMD [ "/etc/s6-overlay/s6-rc.d/noip/run" ]

# Build arguments    <<<< Need to remove this to build or add to build_arch to ignore builder
ARG BUILD_ARCH  
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Hasqt <https://community.home-assistant.io/u/hasqt>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Hasqt" \
    org.opencontainers.image.authors="Hasqt <https://community.home-assistant.io/u/hasqt>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/habuild/hassio/tree/main/noip-renewer" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/noip-renewer/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}























