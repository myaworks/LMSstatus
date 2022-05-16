#!/bin/sh

#===========================================================================
# Set the following according to your setup
#---------------------------------------------------------------------------
MAC_ADDR=xx:xx:xx:xx:xx:xx                                      # Raspberry Pi MAC address
LMS_IP=XXX.XXX.XXX.XXX                                            # LMS IP address
INTERVAL=0.5                                                            # Set Poll interval
GPIO=17                                                                         # Set GPIO
COMMAND="status 0 0"                                            # LMS player status command
DEBUG=0
#---------------------------------------------------------------------------
#===========================================================================
# Initial GPIO setup
#---------------------------------------------------------------------------
if [  ! -e /sys/class/gpio/gpio17 ]; then
         echo "17" > /sys/class/gpio/export
 fi

 echo "out" > /sys/class/gpio/gpio17/direction
 echo "1" > /sys/class/gpio/gpio17/value

#---------------------------------------------------------------------------

if [ $DEBUG = 1 ]; then
        echo
        echo "MAC_ADDR : "$MAC_ADDR
        echo "LMS_IP   : "$LMS_IP
        echo "INTERVAL : "$INTERVAL
        echo "GPIO     : "$GPIO
        echo "COMMAND  : "$COMMAND
fi

pause() {
        echo "1" > /sys/class/gpio/gpio$GPIO/value
        sleep 0.25
        echo "0" > /sys/class/gpio/gpio$GPIO/value
        sleep 3
}
get_mode() {
        RESULT=`( echo "$MAC_ADDR $COMMAND"; echo exit ) | nc $LMS_IP 9090`
        echo $RESULT | grep "mode%3Aplay" > /dev/null 2>&1
        if [ $? == 0 ]; then
                #echo "!! Playing !!"
                echo "0" > /sys/class/gpio/gpio$GPIO/value
        else
                #       echo "!!! Stopped !!!"
        #               echo "1" > /sys/class/gpio/gpio$GPIO/value
        pause
        fi
}

#===========================================================================
# Loop forever. This uses less the 1% CPU, so it should be OK.
#---------------------------------------------------------------------------
while true
do
        get_mode
        sleep $INTERVAL
done
#---------------------------------------------------------------------------
