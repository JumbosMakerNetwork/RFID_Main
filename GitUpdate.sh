# Shell script to be run daily
# Checks git for updates to the functional RFID programs
# Make sure that the root crontable includes the line: 0 0 * * * /home/RFID/TSync/GitUpdate.sh
# This will update every night at midnight

# Compare local repository against the origin
date
echo 'Updating repository...'
git -C /home/rfid/TSync remote update

# Check status against the origin
echo 'Checking Status...'
if git -C /home/rfid/TSync status | grep -q 'Your branch is up-to-date'
	then
		# If up to date, kill the script 
		echo 'up-to-date'
		exit 1
	else
		echo 'Update required - pulling from GitHub...'
		# Pull updates from the repository
		sudo git -C /home/rfid/TSync pull
		# Recompile the RFID application
		echo 'Recompiling applications...'
		sudo sh /home/rfid/TSync/compile1.sh
		# Turn of the LCD
		sudo echo "18" > /sys/class/gpio/export                 
		sudo echo "out" > /sys/class/gpio/gpio18/direction
		sudo echo "0" > /sys/class/gpio/gpio18/value
		echo 'Rebooting sytem...'		
		sleep 5
		# Reeboot for good measure
		sudo reboot	
fi

