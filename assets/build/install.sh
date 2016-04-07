#!/bin/bash
set -e
set -x

mkdir -p ${MATTERMOST_HOME}
cd ${MATTERMOST_HOME}

echo "Downloading Mattermost v.${MATTERMOST_VERSION}"
curl -OL https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz
tar xzf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz
rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz
