#!/bin/bash

. /opt/scripts/env.sh
if [ $? != 0 ]; then
  echo "cacti   ERROR  initialization error happened"
  exit 1
fi

. /opt/scripts/run/first_run.sh
if [ $? != 0 ]; then
  echo "cacti   ERROR  configuration error happened"
  exit 1
fi

EXIT_FLAG=0

exit_script() {
    # trap - SIGINT SIGTERM # clear the trap
    service cron  stop && \
    service snmpd stop && \
    service nginx stop && \
    service php7.0-fpm stop
    echo
    echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "cacti   INFO   cacti container stopped"
    echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo
    EXIT_FLAG=1
}

service cron  start && \
service snmpd start && \
service nginx start && \
service php7.0-fpm start

echo
echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "cacti   INFO   cacti container started"
echo "cacti   INFO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo

#
#  IMPLEMENT "INIT" HERE INSTEAD OF INFINITE LOOP
#
while [ $EXIT_FLAG == 0 ]; do
  sleep 1
  # #
  # # check running services and restart if needed
  # #
done
