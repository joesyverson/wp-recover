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

_server_backup () {
    DATE=$( date +'%Y-%m-%d_%H-%M' )
    SERVER_BACKUP_CONF="${SERVER_HOME}/.my.cnf"
    SERVER_BACKUP_DIR="${SERVER_HOME}/backups-manual/"
    SERVER_BACKUP_SCRIPT="${SERVER_BACKUP_DIR}/backup.sh"

    scp -i $SERVER_KEY ./.my.cnf \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_CONF}
    scp -i $SERVER_KEY ./scripts/backup.sh \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}

    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "chmod 0770 ${SERVER_BACKUP_SCRIPT} && chmod 660 ${SERVER_BACKUP_CONF}"
    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "${SERVER_BACKUP_SCRIPT} ${DATE} ${SERVER_HOME} ${WORDPRESS_DB_USER} ${WORDPRESS_DB_NAME}"

    scp -pi $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/mysql/${WORDPRESS_DB_NAME}.sql.${DATE} \
        ./backups-mysql/${WORDPRESS_DB_NAME}.sql.${DATE}
    scp -pri $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/wp/_site.${DATE}.gz \
        ./backups-wp/_site.${DATE}.gz
}



_COMM="$1"
shift
_ARGS="$@"

$_COMM "$_ARGS"
