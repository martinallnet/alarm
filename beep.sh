#!/bin/sh

host="123456@127.0.0.1"

if [ "$1" = "warning" ]; then
 mpc -h $host volume 100
 mpc -h $host clear
 mpc -h $host load beep_warning
 mpc -h $host play

elif [ "$1" = "alarm" ]; then
 mpc -h $host volume 100 
 mpc -h $host clear
 mpc -h $host load beep_alarm
 mpc -h $host play

elif [ "$1" = "activated" ]; then
 mpc -h $host volume 50 
 mpc -h $host clear
 mpc -h $host load beep_activated
 mpc -h $host play

elif [ "$1" = "deactivated" ]; then
 mpc -h $host volume 50 
 mpc -h $host clear
 mpc -h $host load beep_deactivated
 mpc -h $host play

elif [ "$1" = "stop" ]; then
 mpc -h $host stop

elif [ "$1" = "status" ]; then
 mpc -h $host status
 mpc -h $host listall

else
 echo "Usage:"
 echo "$0 warning"
 echo "$0 alarm"
 echo "$0 activated"
 echo "$0 deactivated"
 echo "$0 stop"
 echo "$0 status"

fi