## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
## hadolint ignore=DL3018  
## Hadolint ignore Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>`
## hadolint ignore=DL3022   
## COPY --from should reference a previously defined FROM alias

ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.1.1    ## Should swap this link to ghrc.io/docker-base/alpinelinux:3.22, not sure of the link
# hadolint ignore=DL3006
FROM ${BUILD_FROM}



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

# Copy root filesystem
COPY rootfs /

          
# download and build SBFspot
WORKDIR /tmp 
RUN \
    git clone https://github.com/sbfspot/SBFspot.git . \
    && sed -i s/mariadbclient/mariadb/ ./SBFspot/makefile \
    && make -C ./SBFspot mariadb \
    && sed -i s/mariadbclient/mariadb/ ./SBFspotUploadDaemon/makefile \
    && make -C ./SBFspotUploadDaemon mariadb

# Copy root filesystem
COPY rootfs /  

FROM SBFspotCopy AS builder

# hadolint ignore=DL3018
RUN apk update && apk add --no-cache \
    bluez \
    bluez-libs \
    nano \
    libstdc++ \
    mariadb-common \
    mariadb-connector-c \
    ncurses-libs \
    libcurl \
    mosquitto-clients
    
    #nginx=1.26.2-r4
    #tzdata=2023c-r1 
    #boost-date_time1.78 

# Copy data for add-on
FROM SBFspotCopy
WORKDIR /usr/bin/sbfspot
# hadolint ignore=DL3023
COPY \ 
  --from=builder-sbf /tmp/SBFspot/mariadb/bin/SBFspot /usr/bin/sbfspot/SBFspot \
  --from=builder-sbf /tmp/SBFspotUploadDaemon/mariadb/bin/SBFspotUploadDaemon /usr/bin/sbfspot/SBFspotUploadDaemon \
  --from=builder-sbf /tmp/SBFspot/date_time_zonespec.csv /usr/bin/sbfspot/date_time_zonespec.csv \
  --from=builder-sbf /tmp/SBFspot/TagList* /usr/bin/sbfspot/


COPY rootfs /

RUN chmod a+x /etc/services.d/sbfspot/** /usr/bin/sbfspot/**

# --- install cron ---
# set shell
RUN echo 'SHELL=/bin/bash' > /etc/crontabs/root
# update sensors after restart
RUN echo '@reboot sleep 30 && /usr/bin/sbfspot/SBFspot -v -ad0 -am0 -mqtt -finq > /dev/stdout' >> /etc/crontabs/root
# daily data SBFspot
RUN echo '*/5 6-22 * * *    /usr/bin/sbfspot/SBFspot -v -ad1 -am0 -ae0 -mqtt > /dev/stdout' >> /etc/crontabs/root
# monthly data SBFspot
RUN echo '55 05 * * *       /usr/bin/sbfspot/SBFspot -v -sp0 -ad0 -am1 -ae1 -finq > /dev/stdout' >> /etc/crontabs/root
# start SBFspotUpload 1 min after boot
RUN echo '@reboot sleep 60 && /usr/bin/sbfspot/SBFspotUploadDaemon -c /usr/bin/sbfspot/SBFspotUpload.cfg > /dev/stdout' >> /etc/crontabs/root
#  Log SBFspotUpload to HA logging window  defunct now in version 3.9.6+ sbfspot, using it for the timed message
RUN echo '*/5 6-22 * * * /usr/bin/sbfspot/taillog.sh' >> /etc/crontabs/root

############################ Base labels etc below

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
