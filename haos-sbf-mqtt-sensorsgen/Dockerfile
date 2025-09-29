ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.1.1
FROM $BUILD_FROM

# Copy root filesystem
COPY rootfs /

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk update && apk add --no-cache \
    mosquitto-clients \
    nano

WORKDIR /etc/s6-overlay/s6-rc.d

RUN \
     chmod a+x /etc/s6-overlay/s6-rc.d/sensorsgen/run \
     && chmod a+x /etc/s6-overlay/s6-rc.d/test/tag \
     && chmod a+x /etc/s6-overlay/s6-rc.d/test/run \
     && chmod a+x /etc/s6-overlay/s6-rc.d/message1/run \
     && chmod a+x /etc/s6-overlay/s6-rc.d/message2/run


# Build arguments
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
    org.opencontainers.image.url="https://github.com/habuild/hassio/tree/main/haos-sbf-mqtt-sensorsgen" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
