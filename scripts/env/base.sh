#!/bin/bash

export CONTAINER_IP=$(hostname --ip-address)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  E X P O R T   V A R I A B L E S   F R O M   /opt/env
#
# files in /opt/env are named as environment variables
# and contain needed values
#
# export values from files (will override default values)
if [ -d "/opt/env" ]; then
  for file in `ls /opt/env/`; do
    VAR=$(basename $file)
    VAL=$(cat /opt/env/$file | tr -d "\n ")
    export $VAR=$VAL
  done
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  E X P A N D  {{DOCKER_SECRET}}  V A R I A B L E S
