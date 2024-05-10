ARG BUILD_FROM
FROM $BUILD_FROM AS builder-base

# Execute during the build of the image
ARG TEMPIO_VERSION BUILD_ARCH
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

# Copy root filesystem
COPY rootfs /

FROM simaofsilva/noip-renewer:latest

# Labels
LABEL \
    io.hass.name="noip-renewer" \
    io.hass.description="Home Assistant addon for simao-silva/noip-renewer" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Hasqt <https://community.home-assistant.io/u/hasqt>" \
    org.label-schema.description="Home Assistant addon for simao-silva/noip-renewer" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="noip-renewer" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/habuild/hassio/tree/main/noip-renewer" \
    org.label-schema.usage="https://github.com/habuild/hassio/tree/main/noip-renewer/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/habuild/hassio" \
    org.label-schema.vendor="Hasqt"
