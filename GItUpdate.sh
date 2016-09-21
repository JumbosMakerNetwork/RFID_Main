# Shell script to run daily
# Checks git for updates to the RFID programs
# Needs to check if updated (IE git returns not up to date)
# If not up to date, run git pull etc
# Then recompile
# Use crontable to set this up to run daily
# 0 0 * * * /home/RFID/GitUpdate.sh
# https://www.raspberrypi.org/documentation/linux/usage/cron.md
# https://quaintproject.wordpress.com/2013/09/29/how-to-schedule-a-job-on-the-raspberry-pi/

# git remote update && git status 
# No changes -
# 	Returns
# 		Fetching origin
# 		On branch master
# 		Your branch is up-to-date with 'origin/master'.
# 		nothing to commit, working directory clean
# Changes - 
# 	Returns
# 		Fetching origin
# 		remote: Counting objects: 3, done.
# 		remote: Compressing objects: 100% (3/3), done.
# 		remote: Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
# 		Unpacking objects: 100% (3/3), done.
# 		From https://github.com/JumbosMakerNetwork/TSync
# 		   8a6b2ea..4fa35df  master     -> origin/master
# 		On branch master
# 		Your branch is behind 'origin/master' by 1 commit, and can be fast-forwarded.
# 		  (use "git pull" to update your local branch)
# 		nothing to commit, working directory clean


# Shell script to be run daily
# Checks git for updates to the functional RFID programs

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
		sudo git -C /home/RFID/TSync pull
		# Recompile the RFID application
		sudo sh /home/RFID/TSync/compile1.sh
		# Include a delay to allow for the compile to occur
		sleep 5m
		# Reeboot for good measure
		sudo reboot	
fi

