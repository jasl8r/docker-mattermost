#!/bin/bash
set -e
set -x

mkdir -p ${MATTERMOST_HOME}
cd ${MATTERMOST_HOME}

echo "Downloading Mattermost v.${MATTERMOST_VERSION}"
curl -OL https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz
tar xzf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz
rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz

# disable default nginx configuration and enable mattermost's nginx configuration
rm -rf /etc/nginx/sites-enabled/default

# move nginx logs to ${MATTERMOST_LOG_DIR}/nginx
sed -i \
  -e "s|access_log /var/log/nginx/access.log;|access_log ${MATTERMOST_LOG_DIR}/nginx/access.log;|" \
  -e "s|error_log /var/log/nginx/error.log;|error_log ${MATTERMOST_LOG_DIR}/nginx/error.log;|" \
  /etc/nginx/nginx.conf

#configure supervisord to start mattermost
cat > /etc/supervisor/conf.d/mattermost.conf <<EOF
[program:mattermost]
priority=10
directory=${MATTERMOST_INSTALL_DIR}
command=${MATTERMOST_INSTALL_DIR}/bin/platform -config ${MATTERMOST_CONF_DIR}/config.json
autostart=true
autorestart=true
stopsignal=QUIT
stdout_logfile=${MATTERMOST_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${MATTERMOST_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start nginx
cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
priority=20
directory=/tmp
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
stdout_logfile=${MATTERMOST_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${MATTERMOST_LOG_DIR}/supervisor/%(program_name)s.log
EOF
