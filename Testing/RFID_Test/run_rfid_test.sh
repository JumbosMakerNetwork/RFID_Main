#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &
sleep 15
SID=5
IPAdd=$(hostname -I)
sudo /home/rfid/TSync/Testing/test_rfid -STID $SID -IP $IPAdd &
