#!/bin/bash
set -e

MATTERMOST_CLONE_URL=https://github.com/mattermost/platform.git

export GOPATH=/opt/go
MATTERMOST_BUILD_PATH=${GOPATH}/src/github.com/mattermost

# install build dependencies
apk --no-cache add --virtual build-dependencies \
  curl go git mercurial nodejs make g++

go get github.com/tools/godep
npm update npm --global

# create build directories
mkdir -p ${GOPATH}
mkdir -p ${MATTERMOST_BUILD_PATH}
cd ${MATTERMOST_BUILD_PATH}

# install mattermost
echo "Cloning Mattermost ${MATTERMOST_VERSION}..."
git clone -q -b v${MATTERMOST_VERSION} --depth 1 ${MATTERMOST_CLONE_URL}

echo "Building Mattermost..."
cd platform
sed -i.org 's/sudo //g' Makefile
make build-linux BUILD_NUMBER=${MATTERMOST_VERSION}

echo "Installing Mattermost..."
cd ${MATTERMOST_HOME}
curl -sSL https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz | tar -xvz
cp ${GOPATH}/bin/platform ./mattermost/bin/platform

# cleanup build dependencies, caches and artifacts
apk del build-dependencies
rm -rf ${GOPATH}
rm -rf /tmp/npm*
rm -rf /root/.npm
rm -rf /root/.node-gyp
rm -rf /usr/lib/go/pkg
rm -rf /usr/lib/node_modules
