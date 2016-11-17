#!/bin/bash
while true
do
	sleep 60
	# Check if either process is running
	if ! [ pgrep "rfid" > /dev/null ] || ! [ pgrep "SignIn" > /dev/null ]
	then
		echo "Application not running"
		echo "Rebooting system"
	    sudo reboot
	fi
done
