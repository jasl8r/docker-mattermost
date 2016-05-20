#!/bin/bash
set -e
source ${MATTERMOST_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:start)
    initialize
    configure
    migrate
    ./bin/platform -config ${MATTERMOST_CONF_DIR}/config.json
    ;;

  app:migrate)
    initialize
    configure
    migrate -interactive
    ;;

  app:help)
    echo "Available options:"
    echo " app:start        - Starts the mattermost server (default)"
    echo " app:migrate      - Interactively migrate the mattermost server"
    echo " app:help         - Displays the help"
    echo " [command]        - Execute the specified command, eg. bash."
    ;;

  *)
    exec "$@"
    ;;
esac
