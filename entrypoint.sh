#!/bin/bash
set -e
source ${MATTERMOST_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:start)
    initialize
    configure
    migrate
    exec ./bin/platform --config ${MATTERMOST_CONF_DIR}/config.json server
    ;;

  app:help)
    echo "Available options:"
    echo " app:start        - Starts the mattermost server (default)"
    echo " app:help         - Displays the help"
    echo " [command]        - Execute the specified command, eg. bash."
    ;;

  *)
    exec "$@"
    ;;
esac
