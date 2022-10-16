#!/bin/bash
source .env

_containers_down () {
    docker-compose down
}

_containers_stage () {
    local VERSION="$1"
    if [ $VERSION = 'current' ]; then
        WP_BACKUP="./backups-wp/$( ls -1t ./backups-wp/ | tail -1 )"
        MYSQL_BACKUP="./backups-mysql/$( ls -1t ./backups-mysql/ | tail -1 )"
    else
        echo "This app can currently only stage the current version. Pass 'current' or stage manually."
        exit
        # WP_BACKUP="./backups-wp/${VERSON}"
        # MYSQL_BACKUP="./backups-sql/${VERSON}"
    fi
    # warn the user they are about to delete their current stage
    rm -r ./_site/
    rm mysql/*
    
    cp -p $MYSQL_BACKUP ./mysql/${MYSQL_DATABASE}.sql; cp -p $WP_BACKUP ./_site.gz
    tar -xvf ./_site.gz
    rm _site.gz
}

_containers_stop () {
    docker-compose stop
}

_containers_up () {
    docker-compose up -d
}

_db_update_links () {
    local SCRIPT='update-links.sh'
    docker cp .my.cnf wp-recover_db_1:/root/.my.cnf
    docker cp scripts/${SCRIPT} wp-recover_db_1:/root/${SCRIPT}
    docker exec -it wp-recover_db_1 \
        bash -c "chmod +x /root/${SCRIPT}; /root/${SCRIPT} ${DOMAIN} ${MYSQL_DATABASE}"
}

_init () {
    mkdir -p ./backups-mysql
    mkdir -p ./backups-wp
    mkdir -p ./mysql
    mkdir -p ./.ssh
}


_server_shell () {
    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP}
}

_server_backup () {
    local DATE=$( date +'%Y-%m-%d_%H-%M' )
    local SERVER_BACKUP_CONF="${SERVER_HOME}/.my.cnf"
    local SERVER_BACKUP_DIR="${SERVER_HOME}/backups-manual"
    local SERVER_BACKUP_SCRIPT="${SERVER_BACKUP_DIR}/backup.sh"

    scp -i $SERVER_KEY ./.my.cnf \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_CONF}
    scp -i $SERVER_KEY ./scripts/backup.sh \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/

    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "chmod 0770 ${SERVER_BACKUP_SCRIPT} && chmod 660 ${SERVER_BACKUP_CONF}"
    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "${SERVER_BACKUP_SCRIPT} ${DATE} ${SERVER_HOME} ${WORDPRESS_DB_USER} ${WORDPRESS_DB_NAME}"

    scp -pi $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/mysql/${WORDPRESS_DB_NAME}.sql.${DATE} \
        ./backups-mysql/${WORDPRESS_DB_NAME}.sql.${DATE}
    scp -pri $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/wp/_site.tar.gz.${DATE} \
        ./backups-wp/_site.tar.gz.${DATE}
}

_COMM="$1"
shift
_ARGS="$@"

$_COMM "$_ARGS"
