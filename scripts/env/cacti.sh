#!/bin/bash

#
# env expand:
# https://gist.github.com/bvis/b78c1e0841cfd2437f03e20c1ee059fe
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  E X P O R T   D E F A U L T   V A L U E S
#
if [ -z "$MYSQL_DATABASE" ]; then
  export MYSQL_DATABASE=cacti
fi
if [ -z "$MYSQL_ROOT_USER" ]; then
  export MYSQL_ROOT_USER=admin
fi
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  export MYSQL_ROOT_PASSWORD=admin
fi
if [ -z "$MYSQL_USER" ]; then
  export MYSQL_USER=cacti
fi
if [ -z "$MYSQL_PASSWORD" ]; then
  export MYSQL_PASSWORD=cacti
fi
if [ -z "$MYSQL_PORT" ]; then
  export MYSQL_PORT=3306
fi
# if [ -z "$MYSQL_HOST" ]; then
#   export MYSQL_HOST=localhost
# fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  E X P O R T   S E C R E T S
#
# (will override values passed as
#  ENV to container or configured
#  in /opt/env)
#
if [ -f "/run/secrets/mysql_root_user" ]; then
  export MYSQL_ROOT_USER=`cat /run/secrets/mysql_root_user | tr -d '\n'`
fi
if [ -f "/run/secrets/mysql_root_password" ]; then
  export MYSQL_ROOT_PASSWORD=`cat /run/secrets/mysql_root_password | tr -d '\n'`
fi
if [ -f "/run/secrets/mysql_user" ]; then
  export MYSQL_USER=`cat /run/secrets/mysql_user | tr -d '\n'`
fi
if [ -f "/run/secrets/mysql_password" ]; then
  export MYSQL_PASSWORD=`cat /run/secrets/mysql_password | tr -d '\n'`
fi
