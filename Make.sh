#!/bin/bash
source .env

_containers_down () {
    docker-compose down
}

_containers_stop () {
    docker-compose stop

}

_containers_up () {
    docker-compose up -d
}


_server_shell () {
    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP}
}



_COMM="$1"
shift
_ARGS="$@"

$_COMM $_ARGS