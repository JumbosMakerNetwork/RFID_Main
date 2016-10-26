#!/bin/sh
# hostname -I | sudo /home/dolanwill/rfid/rfid -IP &
sleep 15
SID=$1
IPAdd=$(hostname -I)
sudo /home/rfid/TSync/signin/SignIn -STID $SID -IP $IPAdd &
