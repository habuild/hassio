## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM AS builder-base

# Execute during the build of the image
ARG TEMPIO_VERSION BUILD_ARCH
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

# Copy root filesystem
COPY rootfs /
# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install requirements from https://pkgs.alpinelinux.org/packages?name=&branch=v3.21&repo=&arch=&origin=&flagged=&maintainer=
RUN apk update && apk add --no-cache \
    bluez=5.82-r0 \
    bluez-dev=5.82-r0 \
    boost-dev=1.84.0-r3 \
    curl-dev=8.14.1-r1 \
    git=2.49.1-r0 \
    g++=14.2.0-r6 \
    make=4.4.1-r3 \
    mariadb-dev=11.4.8-r0\
    mosquitto-clients=2.0.21-r0 \
    tzdata=2025b-r0
           
# download and build SBFspot
WORKDIR /tmp
RUN \
    git clone https://github.com/sbfspot/SBFspot.git . \
    && sed -i s/mariadbclient/mariadb/ ./SBFspot/makefile \
    && make -C ./SBFspot mariadb \
    && sed -i s/mariadbclient/mariadb/ ./SBFspotUploadDaemon/makefile \
    && make -C ./SBFspotUploadDaemon mariadb


# runtinme container   
FROM $BUILD_FROM 

ARG TEMPIO_VERSION BUILD_ARCH
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]


RUN apk update && apk add --no-cache \
    bluez=5.82-r0 \
    bluez-libs=5.82-r0 \
    nano=8.4-r0 \
    libstdc++=14.2.0-r6 \
    mariadb-common=11.4.8-r0 \
    mariadb-connector-c=3.3.10-r0 \
    ncurses-libs=6.5_p20250503-r0 \
    libcurl=8.14.1-r1 \
    mosquitto-clients=2.0.21-r0 \
    
    #nginx=1.26.2-r4
    #tzdata=2023c-r1 
    #boost-date_time1.78 

# Copy data for add-on
WORKDIR /usr/bin/sbfspot
COPY --from=builder-base /tmp/SBFspot/mariadb/bin/SBFspot /usr/bin/sbfspot/SBFspot
COPY --from=builder-base /tmp/SBFspotUploadDaemon/mariadb/bin/SBFspotUploadDaemon /usr/bin/sbfspot/SBFspotUploadDaemon
COPY --from=builder-base /tmp/SBFspot/date_time_zonespec.csv /usr/bin/sbfspot/date_time_zonespec.csv
COPY --from=builder-base /tmp/SBFspot/TagList* /usr/bin/sbfspot/


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

# Labels
LABEL \ 
    io.hass.name="HAOS-SBFspot-test" \
    io.hass.description="Home Assistant addon for Bluetooth SBFspot, is an open source project to get actual and archive data out of an SMA® inverter over Bluetooth or Ethernet (Speedwire®)" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Hasqt <https://community.home-assistant.io/u/hasqt>" \
    org.label-schema.description="Home Assistant addon for Bluetooth SBFspot, is an open source project to get actual and archive data out of an SMA® inverter over Bluetooth or Ethernet (Speedwire®)" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="HAOS-SBFspot-test" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/habuild/hassio/tree/main/haos-sbfspot" \
    org.label-schema.usage="https://github.com/habuild/hassio-addons/tree/main/haos-sbfspot/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/habuild/hassio" \
    org.label-schema.vendor="Hasqt"


#Launch nginx with debug options. not working yet
#CMD [ "nginx","-g","daemon off;error_log /dev/stdout debug;" ] 
