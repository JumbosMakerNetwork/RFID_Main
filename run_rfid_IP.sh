#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &
sleep 30
SID=$1
# MacAdd=$(cat /sys/class/net/wlan0/address)
IPAdd=$(hostname -I)
# sudo /home/rfid/TSync/rfid -STID $SID -MAC $MacAdd -IP $IPAdd &

# This eventually needs to be cleaner. Look through all for the "-SI" even though it will only ever be 2
if [ "$2" = "-SI" ]; then
	echo "Configuring as a SignIn Station"
	stn="SignIn"
	cmd="sudo /home/rfid/TSync/SignIn -STID $SID -IP $IPAdd &"
	# sudo /home/rfid/TSync/SignIn -STID $SID -IP $IPAdd &
	# sudo sh /home/rfid/TSync/ProcessChk.sh $SID -SI &
else
	echo "Configuring as an Interlock Terminal"
	stn="rfid"
	cmd="sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &"
	# sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &
	# sudo sh /home/rfid/TSync/ProcessChk.sh $SID &
fi

# echo $cmd

eval $cmd

chk=$(pgrep $stn)

while [ -n "$chk" ];
do
	sleep 60
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
