#!/bin/bash
set -e
source ${MATTERMOST_RUNTIME_DIR}/functions

initialize
configure

exec "$@"
