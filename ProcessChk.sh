#!/bin/bash
sleep 5
SID=$1

# This eventually needs to be cleaner. Look through all for the "-SI" even though it will only ever be 2
if [ "$2" = "-SI" ]; then
	stn="SignIn"
	cmd="sudo sh /home/rfid/TSync/run_rfid_IP.sh $1 -SI &"
else
	stn="rfid"
	cmd="sudo sh /home/rfid/TSync/run_rfid_IP.sh $1 &"
fi

chk=$(pgrep $stn)

while [ -n "$chk" ];
do
	sleep 30
	chk=$(pgrep $stn)
done

eval $cmd


# if ping -c 1 130.64.17.0 >> /dev/null 2>&1; then
#     echo "online"
# else
#     echo "offline"
# fi
