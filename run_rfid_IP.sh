#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &
sleep 15
SID=$1
# MacAdd=$(cat /sys/class/net/wlan0/address)
IPAdd=$(hostname -I)
# sudo /home/rfid/TSync/rfid -STID $SID -MAC $MacAdd -IP $IPAdd &
sudo /home/rfid/TSync/rfid -STID $SID -IP $IPAdd &