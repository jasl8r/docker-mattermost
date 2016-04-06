#!/bin/bash
set -e
source ${MATTERMOST_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

initialize
configure

exec "$@"
