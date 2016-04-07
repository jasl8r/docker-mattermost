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

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl gettext-base \
    mysql-client locales \
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
WORKDIR ${MATTERMOST_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
