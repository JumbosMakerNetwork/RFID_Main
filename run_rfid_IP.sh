#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &
# sudo sh /home/rfid/TSync/run_rfid_IP.sh 23

while ! ping -c 1 130.64.17.0 | grep rtt; do
    echo "Waiting for connection to network - network interface might be down..."
    sleep 2
done

sleep 120
SID=$1
IPAdd=$(hostname -I)

# This eventually needs to be cleaner. Look through all for the "-SI" even though it will only ever be 2
if [ "$2" = "-SI" ]; then
	echo "Configuring as a SignIn Station"
	sudo /home/rfid/TSync/SignIn -STID $SID -IP $IPAdd &
else
	echo "Configuring as an Interlock Terminal"
	sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &
fi

