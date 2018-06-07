#!/bin/bash

DIR=/opt/scripts/env

for e in `ls $DIR`; do
 . $DIR/$e
 if [ $? != 0 ]; then
   echo "cacti   ERROR  in configuration script: $e"
   exit 1
 fi
done
