#!/bin/bash

emergency_shutdown_time=15
default_deactivation_time=30
logfile="alarm/door.log"
alarm_status_file="/var/www/html/alarm/alarm_status.php"

door_opened_time=0
deactivation_time_counter=0
emergency_shutdown=0

alarm_deactivated_file=/tmp/.alarm_deactivated

screen -d -m alarm/door_log.sh

~/alarm/beep.sh activated &

echo "$(date) Alarm initiated and activated!" >> $logfile
echo "Activated" > $alarm_status_file

while true; do

 clear

 if [ ! -f $alarm_deactivated_file ]; then

  door_status=$(gpio -g read 23)
# door_status=$1

  if [ -z $door_opened ]; then

   if [ $door_status -eq 1 ]; then
    ~/alarm/netcat.sh &

    echo "Door closed."

   elif [ $door_status -eq 0 ]; then
    door_opened=1
    echo "Door opened!"
   fi

  elif [ $door_opened -eq 1 ]; then
   echo "Door was opened!"

   if [ $door_status -eq 1 ]; then

    echo "Current status: closed."

   elif [ $door_status = 0 ]; then

    echo "Current status: opened!"

   fi

   if [ -z $warning_sound_played ]; then 
    ~/alarm/beep.sh warning & 
    warning_sound_played=1
    echo "$(date) Alarm countdown initiated!" >> $logfile
   fi

   door_opened_time=$(($door_opened_time + 1))
   echo "Time: $(($door_opened_time / 5)) s / $emergency_shutdown_time s"
   echo "Alarm countdown! $(($door_opened_time / 5)) s / $emergency_shutdown_time s" > $alarm_status_file
  fi

  if [ $emergency_shutdown -eq 0 ]; then
    
   if [ $door_opened_time -ge $(($emergency_shutdown_time * 5)) ]; then
    emergency_shutdown=1

    if [ -z $alarm_sound_played ]; then
     ~/alarm/beep.sh alarm &
     alarm_sound_played=1
     echo "$(date) Alarm!" >> $logfile
     echo "Alarm!" > $alarm_status_file
    fi

    echo "Emercency shutdown!"
    sleep 1
   fi

  elif [ $emergency_shutdown -eq 1 ]; then
   echo "Emergency shutdown already executed!"
  fi

 elif [ -f $alarm_deactivated_file ]; then
  
  alarm_deactivated_file_content=$(cat $alarm_deactivated_file)

  if [ -z $alarm_deactivated_file_content ]; then
   deactivation_time=$default_deactivation_time

  elif [ ! -z $alarm_deactivated_file_content ]; then
   deactivation_time=$alarm_deactivated_file_content
  fi

  if [ $deactivation_time_counter -le $deactivation_time ]; then
   echo "Alarm deactivated."
   echo "$deactivation_time_counter/$deactivation_time s"
   echo "Deactivated $deactivation_time_counter / $deactivation_time s" > $alarm_status_file
   ~/alarm/netcat.sh no_timeout &

   if [ -z $mpd_stopped ]; then
    ~/alarm/beep.sh deactivated &
    mpd_stopped=1
    echo "$(date) Alarm deactivated for $deactivation_time seconds." >> $logfile
   fi

   if [ -z $deactivation_time_last ]; then
    deactivation_time_last=$deactivation_time
   fi

   if [ $deactivation_time_last -ne $deactivation_time ]; then
    echo "$(date) Alarm deactivated for $deactivation_time seconds." >> $logfile
    deactivation_time_last=$deactivation_time
   fi

   deactivation_time_counter=$(($deactivation_time_counter + 1))
   sleep 0.8

  elif [ $deactivation_time_counter -ge $deactivation_time ]; then
   rm $alarm_deactivated_file
   door_opened=
   door_opened_time=0
   deactivation_time_counter=0
   emergency_shutdown=0
   warning_sound_played=
   alarm_sound_played=
   mpd_stopped=
   deactivation_time_last=
   ~/alarm/beep.sh activated &
   echo "$(date) Alarm activated!" >> $logfile
   echo "Activated" > $alarm_status_file
  fi

 fi

 sleep 0.2

done
