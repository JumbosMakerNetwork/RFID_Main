#!/bin/bash
while true
do
	sleep 60
	# Check if either process is running
	if ! [ pgrep "rfid" > /dev/null ] || ! [ pgrep "SignIn" > /dev/null ]
	then
		echo "Application not running"
		echo "Restarting application"
	    # sudo reboot
	    eval $1
	fi
done

# sudo sh /home/rfid/TSync/run_rfid_IP.sh 27


