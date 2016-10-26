# Create the main application - for interlock terminals
gcc /home/rfid/TSync/main.c /home/rfid/TSync/headers/*.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o /home/rfid/TSync/rfid

# Create the SignIn application - for Sign In/Out stations
gcc /home/rfid/TSync/SignIn.c /home/rfid/TSync/headers/*.c -Wall -Wextra -lcurl -lbcm2835 -lwiringPi -ljpeg -o /home/rfid/TSync/SignIn
