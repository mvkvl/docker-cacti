#!/bin/bash

wait_for() {
  local HOST=$1
  local PORT=$2
  local TM=$3
  for i in `seq $TM` ; do
    nc -z "$HOST" "$PORT" > /dev/null 2>&1
    result=$?
    if [ $result -eq 0 ] ; then
      return 0
    fi
    sleep 1
  done
  return 1
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  E X I T   I F   A L R E A D Y   C O N F I G U R E D
#
if [ -f /opt/.configured ]; then
  # echo "cacti   DEBUG  environment variable MYSQL_HOST not set"
  exit 0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  C H E C K   I F   S O M E T H I N G'S   M I S S I N G
#
if [ -z "$MYSQL_HOST" ]; then
  echo "cacti   ERROR  environment variable MYSQL_HOST not set"
  exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  W A I T  F O R  D A T A B A S E  T O  G E T  R E A D Y
#  ( as on first run we should create & initialize cacti
#    database )
#
if [ -z "$DB_STARTUP_TIMEOUT" ]; then
  DB_STARTUP_TIMEOUT=5
fi
echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "cacti   INFO   waiting for database at $MYSQL_HOST:$MYSQL_PORT"
echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
wait_for $MYSQL_HOST $MYSQL_PORT $DB_STARTUP_TIMEOUT
if [ $? -eq 0 ] ; then
  echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "cacti   INFO   database ready                            "
  echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
else
  echo "cacti   ERROR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "cacti   ERROR  database not available                    "
  echo "cacti   ERROR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  C O N F I G U R E   C A C T I
#
# replace stubs in cacti docker config with env values
sed -i -e "s/%DB_HOST%/$MYSQL_HOST/g"         "/opt/cacti/include/config.php"  && \
sed -i -e "s/%DB_PORT%/$MYSQL_PORT/g"         "/opt/cacti/include/config.php"  && \
sed -i -e "s/%DB_NAME%/$MYSQL_DATABASE/g"     "/opt/cacti/include/config.php"  && \
sed -i -e "s/%DB_USER%/$MYSQL_USER/g"         "/opt/cacti/include/config.php"  && \
sed -i -e "s/%DB_PASSWORD%/$MYSQL_PASSWORD/g" "/opt/cacti/include/config.php"  && \

# to get rid of SNMPd warnings
# sed -i -e "s|max-bindings INTEGER ::= 2147483647|max-bindings ::= INTEGER (2147483647)|" /usr/share/snmp/mibs/ietf/SNMPv2-PDU
sed -i -e "s|defaultMonitors          yes|#defaultMonitors          yes|" /etc/snmp/snmpd.conf
sed -i -e "s|linkUpDownNotifications  yes|#linkUpDownNotifications  yes|" /etc/snmp/snmpd.conf

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  S E T   T I M E Z O N E
#
rm /etc/localtime && ln -s /usr/share/zoneinfo/$TZ /etc/localtime
echo "$TZ" > /etc/timezone
echo "date.timezone = $TZ" >> /etc/php/7.0/fpm/php.ini
echo "date.timezone = $TZ" >> /etc/php/7.0/cli/php.ini
echo "date.timezone = $TZ" >> /etc/php/7.0/cgi/php.ini

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  C O N F I G U R E   S N M P   D A E M O N
#
sed  -i "s|#rocommunity secret  10.0.0.0/16|rocommunity secret $CONTAINER_IP|" /etc/snmp/snmpd.conf

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  I N I T I A L I Z E   D A T A B A S E
#
DB_CONNECT_STR="--user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_HOST --port=$MYSQL_PORT"

mysqladmin $DB_CONNECT_STR create $MYSQL_DATABASE
mysql $DB_CONNECT_STR --database $MYSQL_DATABASE < /opt/cacti/cacti.sql
mysql $DB_CONNECT_STR --database "mysql" --execute "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; flush privileges;"
mysql $DB_CONNECT_STR --database "mysql" --execute "grant select ON time_zone_name TO '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD'"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  S E T   " C O N F I G U R E D "   F L A G
#
touch /opt/.configured
