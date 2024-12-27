#!/bin/bash
# 
# set charge_control_start_threshold and charge_control_end_threshold values
# 
# 2024-12 @jwlandon
#

# Battery device path
base_dev=/sys/class/power_supply/BAT0

# default values
start_flag=false
stop_flag=false
start_value=0  # Default to 0 if no value is passed.
stop_value=0  # Default to 0 if no value is passed

dateTime(){
 date "+%Y-%m-%d %H:%M:%S"
}

# Function to handle start action
start_action() {
  if [[ "$start_flag" == true ]]; then
    echo "$(dateTime) INFO Setting minimum battery level $start_value (before the battery accepts a charge)"
    echo $start_value > $base_dev/charge_control_start_threshold
    confirm_action start_action $start_value
  else
    read_start_value=`cat $base_dev/charge_control_start_threshold`
    echo "$(dateTime) INFO Start charge level action not called ; value currently set at $read_start_value"
  fi
}

# Function to handle stop action
stop_action() {
  if [[ "$stop_flag" == true ]]; then
    echo "$(dateTime) INFO Setting maximum battery level $stop_value (before the battery stops accepting a charge)"
    echo $stop_value > $base_dev/charge_control_end_threshold
    confirm_action stop_action $stop_value
  else
    read_stop_value=`cat $base_dev/charge_control_end_threshold`
    echo "$(dateTime) INFO Stop charge level action not called ; value currently set to $read_stop_value"
  fi
}

usage(){
echo "Set Battery Charge levels ; recommend stop level be set to 80"
echo "Usage: $0 [--start <percent_level>] [--stop <percent_level>]"
exit 1
}

confirm_action(){
  if [ $1 == "start_action" ] ; then
    read_start_value=`cat $base_dev/charge_control_start_threshold`
    if [ $read_start_value -eq $2 ] ; then
      echo "$(dateTime) INFO Confirmed $base_dev/charge_control_start_threshold reports $read_start_value ; success setting value" 
     else
      echo "$(dateTime) ERROR Failed setting $base_dev/charge_control_start_threshold to $2 ; kernel driver issue? ; exiting."
      exit 1
    fi
   elif [ $1 == "stop_action" ] ; then
    read_stop_value=`cat $base_dev/charge_control_end_threshold`
    if [ $read_stop_value -eq $2 ] ; then
      echo "$(dateTime) INFO Confirmed $base_dev/charge_control_end_threshold reports $read_stop_value ; success setting value"
     else
      echo "$(dateTime) ERROR Failed setting $base_dev/charge_control_end_threshold to $2 ; kernel driver issue? ; exiting."
      exit 1
    fi
   else
    echo "$(dateTime) CRITICAL Internal error ; $1 is not registered in confirm_action() ; exiting."
    exit 1
  fi

}

if [ ! -d $base_dev ] ; then 
  echo "Battery $base_dev is not found.  Please make sure your battery is actively detected by your machine."
  echo "Set \$base_dev in the script after identifying the battery's system path."
  exit 1
 else
  if [ -e $base_dev/charge_control_start_threshold ] && [ -e $base_dev/charge_control_end_threshold ] ; then 
    echo "$(dateTime) INFO Using $base_dev"
   else
    echo "$(dateTime) ERROR charge_control_start_threshold and/or charge_control_end_threshold is not found under $base_dev ; incompatible.  Exiting."
    exit 99
  fi
fi


# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --start)
      start_flag=true
      shift
      if [[ "$1" =~ ^[0-9]+$ ]]; then
          start_value="$1"
          shift
      else
        echo "$(dateTime) ERROR Invalid integer value after --start ; recommended value 60"
        usage
      fi
      ;;
    --stop)
      stop_flag=true
      shift
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        stop_value="$1"
        shift
      else
        echo "$(dateTime) ERROR Invalid integer value after --stop ; recommended value 80"
        usage
      fi
      ;;
     --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

# dictate usage
if [ "$start_flag" = false ] && [ "$stop_flag" = false ]; then
    usage
fi

# Perform actions based on flags
start_action
stop_action
exit 0
