# gcc /home/rfid/TSync/*.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o /home/rfid/TSync/rfid
# gcc *.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o rfid

# Create object file from the source files
gcc /home/rfid/TSync/headers/*.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o /home/rfid/TSync/headers/rfid_headers.o

gcc /home/rfid/TSync/main.c /home/rfid/TSync/headers/rfid_headers.o -Wall -Wextra -o /home/rfid/TSync/rfid