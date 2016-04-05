FROM ubuntu:14.04
MAINTAINER jasl8r@alum.wpi.edu

ENV MATTERMOST_VERSION=2.1.0 \
    MATTERMOST_HOME="/opt/mattermost"

ENV MATTERMOST_DATA_DIR="${MATTERMOST_HOME}/data" \
    MATTERMOST_BUILD_DIR="${MATTERMOST_HOME}/build" \
    MATTERMOST_RUNTIME_DIR="${MATTERMOST_HOME}/runtime" \
    MATTERMOST_INSTALL_DIR="${MATTERMOST_HOME}/mattermost" \
    MATTERMOST_CONF_DIR="${MATTERMOST_HOME}/config" \
    MATTERMOST_LOG_DIR="/var/log/mattermost"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl gettext-base nginx \
    mysql-client supervisor locales \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure locales \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${MATTERMOST_BUILD_DIR}/
RUN bash ${MATTERMOST_BUILD_DIR}/install.sh

COPY assets/runtime/ ${MATTERMOST_RUNTIME_DIR}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp

VOLUME ["${MATTERMOST_DATA_DIR}", "${MATTERMOST_LOG_DIR}"]
WORKDIR ${MATTERMOST_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisor/supervisord.conf"]
