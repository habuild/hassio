## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
## hadolint ignore=DL3018  
## Hadolint ignore Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>`
## hadolint ignore=DL3022   
## COPY --from should reference a previously defined FROM alias

ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.1.1    ## Should swap this link to ghrc.io/docker-base/alpinelinux:3.22, not sure of the link
# hadolint ignore=DL3006
FROM ${BUILD_FROM} AS builder-base



# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
#RUN \
     #apk add --no-cache \
        # would be cool to add base SBFspot here.
## install requirements from https://pkgs.alpinelinux.org/packages?name=&branch=v3.22&repo=&arch=&origin=&flagged=&maintainer=
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache \
    bluez \
    bluez-dev \
    boost-dev \
    curl-dev \
    git \
    g++ \
    make \
    mariadb-dev\
    mosquitto-clients \
    tzdata

# download and build SBFspot
WORKDIR /tmp 
RUN \
    git clone https://github.com/sbfspot/SBFspot.git . \
    && sed -i s/mariadbclient/mariadb/ ./SBFspot/makefile \
    && make -C ./SBFspot mariadb \
    && sed -i s/mariadbclient/mariadb/ ./SBFspotUploadDaemon/makefile \
    && make -C ./SBFspotUploadDaemon mariadb


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
    org.opencontainers.image.url="https://github.com/habuild/hassio/tree/main/haos-sbfspot" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
