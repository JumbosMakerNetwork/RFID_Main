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

# sleep 15
# # echo "Starting Process Script check"

# while true
# do
# 	sleep 60
# 	# Check if either process is running
# 	chk=$(pgrep $stn)
# 	if ! [ -n "$chk" ];
# 		then
# 		# echo "Application not running. Restarting Process..."
# 		eval $cmd
# 	fi
# done

# if [ -n "$(pgrep $stn)"]; then echo "Running"; else echo "Not running"; fi
# if ! [ -n "$chk1" ]; then echo "Not Running"; fi


