# Shell script to be run daily
# Checks git for updates to the functional RFID programs
# Make sure that the root crontable includes the line: 0 0 * * * /home/RFID/TSync/GitUpdate.sh
# This will update every night at midnight

# Compare local repository against the origin
echo 'Updating repository...'
git -C /home/RFID/TSync remote update

# Check status against the origin
echo 'Checking Status...'
if git -C /home/RFID/TSync status | grep -q 'Your branch is up-to-date'
	then
		# If up to date, kill the script 
		echo 'up-to-date'
		exit 1
	else
		echo 'Update required'
		# Pull updates from the repository
		sudo git -C /home/rfid/TSync pull
		# Recompile the RFID application
		sudo sh /home/rfid/TSync/compile1.sh
		# Include a delay to allow for the compile to occur
		sleep 5m
		# Reeboot for good measure
		sudo reboot	
fi

