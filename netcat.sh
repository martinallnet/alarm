#!/bin/sh

netcat="nc 192.168.1.2 20010 -w1"

if [ "$1" = "no_timeout" ]; then
 $netcat

else 
 timeout_full=10

 tmp_file=/tmp/.netcat_timeout

 if [ ! -f $tmp_file ]; then
  echo "0" > $tmp_file
 fi

 timeout=$(cat $tmp_file)

 if [ $timeout_full -gt $timeout ]; then
  timeout=$(($timeout + 1))
  echo "$timeout" > $tmp_file

 elif [ $timeout_full -le $timeout ]; then
  $netcat
  rm $tmp_file
 fi

fi
