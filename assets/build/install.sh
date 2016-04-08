#!/bin/bash
set -e

MATTERMOST_CLONE_URL=https://github.com/mattermost/platform.git

export GOPATH=/opt/go
MATTERMOST_BUILD_PATH=${GOPATH}/src/github.com/mattermost

# install build dependencies
apk --no-cache add --virtual build-dependencies \
  alpine-sdk git go godep libffi libffi-dev nodejs ruby ruby-dev

gem install compass || true

# create build directories
mkdir -p ${GOPATH}
mkdir -p ${MATTERMOST_BUILD_PATH}
cd ${MATTERMOST_BUILD_PATH}

# install mattermost
echo "Cloning Mattermost ${MATTERMOST_VERSION}..."
git clone -q -b v${MATTERMOST_VERSION} --depth 1 ${MATTERMOST_CLONE_URL}

echo "Building Mattermost..."
cd platform
make .prepare-go
make build-server

cd web/react
npm install babel-runtime
cd -
make build-client
make package

echo "Installing Mattermost..."
mkdir -p ${MATTERMOST_HOME}
cd ${MATTERMOST_HOME}
tar -xvzf ${MATTERMOST_BUILD_PATH}/platform/dist/mattermost.tar.gz

# cleanup build dependencies, caches and artifacts
apk del build-dependencies
rm -rf ${GOPATH}
rm -rf /tmp/npm*
rm -rf /root/.gem
rm -rf /root/.npm
rm -rf /usr/lib/ruby
