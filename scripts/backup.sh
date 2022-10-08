#!/usr/bin/bash

DATE="$1"
SERVER_HOME="$2"
# WORDPRESS_DB_PASS="$3"
WORDPRESS_DB_USER="$3"
WORDPRESS_DB_NAME="$4"

SERVER_BACKUP_DIR="${SERVER_HOME}/backups-manual"
BACKUP_WP="${SERVER_BACKUP_DIR}/wp/_site.${DATE}"
BACKUP_MYSQL="${SERVER_BACKUP_DIR}/mysql/${WORDPRESS_DB_NAME}.sql.${DATE}"

mkdir -p ${SERVER_BACKUP_DIR}/wp
mkdir -p ${SERVER_BACKUP_DIR}/mysql

echo BACKUP Mysql: $BACKUP_MYSQL
mysqldump -u $WORDPRESS_DB_USER $WORDPRESS_DB_NAME > \
    $BACKUP_MYSQL

echo BACKUP Wordpress: $BACKUP_WP
cp -pr ${SERVER_HOME}/public_html/_site $BACKUP_WP
pushd ${SERVER_BACKUP_DIR}/wp/
tar -czvf _site.gz $BACKUP_WP
popd

rm .my.cnf
echo DONE
