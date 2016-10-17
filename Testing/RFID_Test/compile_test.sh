#!/bin/sh
# Must be run from after cd /home/rfid/TSync/Testing
gcc *.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o test_rfid
