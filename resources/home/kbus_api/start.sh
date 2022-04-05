#!/bin/bash
DAEMON_NAME="kbus-api"

wait_for_stop()
{
  local PID=$1
  local TIMEOUT=$2
  local RET_VAL=0
  local  TIMEOUT_COUNTER=0
  if [ -n "${PID}" ]
  then
    while [ -d "/proc/${PID}" ]
    do
      if (( TIMEOUT_COUNTER > TIMEOUT ))
      then
        RET_VAL=1
        break
      else
       TIMEOUT_COUNTER=$((TIMEOUT_COUNTER + 1))
       sleep 1
      fi
    done
  fi

  return $RET_VAL
}

cleanup()
{
  DAEMONIZE="/sbin/start-stop-daemon"
  echo "stopping all init daemons"
  run-parts -a stop /etc/rc_kbus_api.d/ 

  local PID=$(pidof $DAEMON_NAME)
  echo -e "pidof $DAEMON_NAME:  ${PID}"  
  "$DAEMONIZE" -K -qx "$DAEMON_NAME"
  wait_for_stop ${PID} 5
  if [ $? -ne 0 ]
  then
    echo -e "Regular stopping of $DAEMON_NAME failed send SIGKILL"    
    killall -9 $DAEMON_NAME &> /dev/null
  fi
  echo "done"
}

run() 
{
  echo "start init daemons"
  run-parts -a start /etc/rc_kbus_api.d/

  echo -e "start $DAEMON_NAME"
  kbus-api&
  wait $!
}

trap cleanup INT TERM
run
