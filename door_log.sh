#!/bin/sh

logfile="alarm/door.log"
door_status_file="/var/www/html/alarm/door_status.php"

door_logwrite_closed=0
door_logwrite_opened=0

while true; do

 door_status=$(gpio -g read 23)

 if [ $door_status -eq 1 ]; then

  if [ $door_logwrite_closed -eq 0 ]; then
   echo "$(date) Door closed." >> $logfile
   echo "Door closed" > $door_status_file
   door_logwrite_closed=1
   door_logwrite_opened=0
  fi

 elif [ $door_status -eq 0 ]; then

  if [ $door_logwrite_opened -eq 0 ]; then
   echo "$(date) Door opened." >> $logfile
   echo "Door opened" > $door_status_file
   door_logwrite_opened=1
   door_logwrite_closed=0
  fi

 fi
  

 sleep 0.5

done
