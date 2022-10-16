#!/bin/bash

DOMAIN="$1"
DATABASE="$2"

mysql -e "UPDATE wp_options SET option_value = REPLACE(option_value, '${DOMAIN}', 'http://localhost') WHERE option_name = 'home' OR option_name = 'siteurl';" $DATABASE
mysql -e "UPDATE wp_posts SET post_content = REPLACE(post_content, '${DOMAIN}', 'http://localhost');" $DATABASE
mysql -e "UPDATE wp_postmeta SET meta_value = REPLACE(meta_value,'${DOMAIN}','http://localhost');" $DATABASE
