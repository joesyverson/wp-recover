#!/bin/bash
source .env

_ansible_backup () {
    local DATE=$( date +'%Y-%m-%d_%H-%M' )
    local SERVER_BACKUP_CONF="/${SERVER_HOME}/.my.cnf"
    local SERVER_BACKUP_DIR="/${SERVER_HOME}/backups-manual"
    local SERVER_BACKUP_SCRIPT="${SERVER_BACKUP_DIR}/backup.sh"

    ansible-playbook -vi ./playbooks/.inventory.ini \
        --extra-vars "SERVER_USER=${SERVER_USER}" \
        --extra-vars "SERVER_BACKUP_CONF=${SERVER_BACKUP_CONF}" \
        --extra-vars "SERVER_BACKUP_DIR=${SERVER_BACKUP_DIR}" \
        --extra-vars "SERVER_BACKUP_SCRIPT=${SERVER_BACKUP_SCRIPT}" \
        --extra-vars "DATE=${DATE}" \
        --extra-vars "SERVER_HOME=${SERVER_HOME}" \
        --extra-vars "WORDPRESS_DB_USER=${WORDPRESS_DB_USER}" \
        --extra-vars "WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}" \
        --extra-vars "SERVER_WP_CONTENT_DIR=${SERVER_WP_CONTENT_DIR}" \
        ./playbooks/server-backup.yml
}

_containers_down () {
    docker-compose down
}

_containers_stage () {
    local VERSION="$1"
    if [ $VERSION = 'current' ]; then
        # Linux will list the files alphanumerically
        # So no additional sort or property-lookup required
        WP_BACKUP="./backups-wp/$( ls -1 ./backups-wp/ | tail -1 )"
        MYSQL_BACKUP="./backups-mysql/$( ls -1 ./backups-mysql/ | tail -1 )"
    else
        WP_BACKUP="./backups-wp/${SERVER_WP_CONTENT_DIR}.tar.gz.${VERSION}"
        MYSQL_BACKUP="./backups-mysql/${WORDPRESS_DB_NAME}.sql.${VERSION}"
    fi
    echo 'Enter your password to make old container data deletable. Press [Ctrl]C to quit.'
    sudo chown -R ${USER}:${USER} ./${SERVER_WP_CONTENT_DIR}/ 2> /dev/null
    sudo chown -R ${USER}:${USER} ./mysql/ 2> /dev/null
    rm -rf ./${SERVER_WP_CONTENT_DIR}/ 2> /dev/null
    rm ./mysql/* 2> /dev/null
    
    cp -p $MYSQL_BACKUP ./mysql/${MYSQL_DATABASE}.sql; cp -p $WP_BACKUP ./${SERVER_WP_CONTENT_DIR}.gz
    tar -xvf ./${SERVER_WP_CONTENT_DIR}.gz
    rm *.gz

    WP_BACKUP=$( ls | grep 'site\.[0-9]*' )
    mv $WP_BACKUP $SERVER_WP_CONTENT_DIR  
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
    local SERVER_BACKUP_CONF="/${SERVER_HOME}/.my.cnf"
    local SERVER_BACKUP_DIR="/${SERVER_HOME}/backups-manual"
    local SERVER_BACKUP_SCRIPT="${SERVER_BACKUP_DIR}/backup.sh"

    scp -i $SERVER_KEY ./.my.cnf \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_CONF}
    scp -i $SERVER_KEY ./scripts/backup.sh \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/

    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "chmod 0770 ${SERVER_BACKUP_SCRIPT} && chmod 660 ${SERVER_BACKUP_CONF}"
    ssh -i $SERVER_KEY ${SERVER_USER}@${SERVER_IP} \
        "${SERVER_BACKUP_SCRIPT} ${DATE} ${SERVER_HOME} ${WORDPRESS_DB_USER} ${WORDPRESS_DB_NAME} ${SERVER_WP_CONTENT_DIR}"

    scp -pi $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/mysql/${WORDPRESS_DB_NAME}.sql.${DATE} \
        ./backups-mysql/${WORDPRESS_DB_NAME}.sql.${DATE}
    scp -pri $SERVER_KEY \
        ${SERVER_USER}@${SERVER_IP}:${SERVER_BACKUP_DIR}/wp/${SERVER_WP_CONTENT_DIR}.tar.gz.${DATE} \
        ./backups-wp/${SERVER_WP_CONTENT_DIR}.tar.gz.${DATE}
}

_versions_print () {
    local _ARG="$1"
    local _DEFAULT='dates'
    if [ -z "$_ARG" ]; then _ARG="$_DEFAULT"; fi
    local _BACKUPS_SQL=$( ls backups-mysql ); local _BACKUPS_WP=$( ls backups-wp )
    local _FILES=$(paste <( echo "${_BACKUPS_SQL}" ) <( echo "${_BACKUPS_WP}" ))
    if [ "$_ARG" = 'files' ]
        then echo "$_FILES"
    elif [ "$_ARG" = 'dates' ]
        then echo "$_FILES" | awk '{print $1}' | cut -d '.' -f 3
    fi
}

_COMM="$1"
shift
_ARGS="$@"

$_COMM "$_ARGS"
