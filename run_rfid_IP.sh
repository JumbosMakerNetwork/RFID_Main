#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &

while ! ping -c 1 -W 1 130.64.17.0; do
    echo "Waiting for connection to network - network interface might be down..."
    sleep 2
done

sleep 120
SID=$1
# MacAdd=$(cat /sys/class/net/wlan0/address)
IPAdd=$(hostname -I)
# sudo /home/rfid/TSync/rfid -STID $SID -MAC $MacAdd -IP $IPAdd &

# This eventually needs to be cleaner. Look through all for the "-SI" even though it will only ever be 2
if [ "$2" = "-SI" ]; then
	echo "Configuring as a SignIn Station"
	# stn="SignIn"
	# cmd="sudo /home/rfid/TSync/SignIn -STID $SID -IP $IPAdd &"
	sudo /home/rfid/TSync/SignIn -STID $SID -IP $IPAdd &
	# sudo sh /home/rfid/TSync/ProcessChk.sh $SID -SI &
else
	echo "Configuring as an Interlock Terminal"
	# stn="rfid"
	# cmd="sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &"
	sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &
	# sudo sh /home/rfid/TSync/ProcessChk.sh $SID &
fi

