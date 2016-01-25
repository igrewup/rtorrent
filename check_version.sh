#!/bin/bash
source $(dirname $0)/incl.sh

dir=$(dirname $0)

rm -f /tmp/LATESTVERSION

if [[ ! -f $dir/VERSION ]]; then
	echo "Unable to locate local VERSION file."
	echo "Make sure you have a $dir/VERSION file."
	read -p "Run 'git pull' to update your folder. (y/n)? " RUNGITPULL
	if [[ "$RUNGITPULL" = "y" ]]; then
		git pull
	        if [[ -f VERSION ]]; then
	                echo "Found $dir/VERSION, continuing..."

		else
			echo "Cannot find $dir/VERSION, exiting."
			exit 0
		fi
	else
		exit 0
	fi
fi

# Download latest VERSION from GITHUB and check it against the current VERSION file.
if [[ ! -f /tmp/LATESTVERSION ]]; then
	wget --quiet --no-check-certificate -O /tmp/LATESTVERSION https://raw.githubusercontent.com/igrewup/rtorrent/master/VERSION
	#clear
	#touch /tmp/LATESTVERION
	if [[ ! -f /tmp/LATESTVERSION ]]; then
        	echo "Failed to download LATEST VERSION file."
        	echo "There seems to be a problem with the webserver."
        	exit 0
	else
	LATESTVERSION=$(cat /tmp/LATESTVERSION)
	#LATESTVERSION=0;
	CURRENTVERSION=$(cat $dir/VERSION)
	
	echo
	echo "[ Current version: $CURRENTVERSION ]"
	echo "[ Latest version : $LATESTVERSION ]"
	echo
	if [[ $CURRENTVERSION == $LATESTVERSION ]]; then
		echo "This script is up-to-date."
	elif [[ $CURRENTVERSION < $LATESTVERSION ]]; then
		echo "This script is outdated."
	        read -p "Run 'git pull' to update your folder. (y/n)? " RUNGITPULL
        	if [[ "$RUNGITPULL" = "y" ]]; then
                	git pull
			CURRENTVERSION=$(cat $dir/VERSION)
        		if [[ $CURRENTVERSION == $LATESTVERSION ]]; then
				echo "Your system is fully up-to-date, re-run the script."
				exit 0
                	else
                        	echo "Still not the latest $dir/VERSION, try removing the main rtorrent folder."
				echo "And then run: 'git clone git://github.com/igrewup/rtorrent.git'"
                        	exit 0
                	fi
        	else
                	exit 0
        	fi

	else
		echo "Unable to determine what version you have."
		echo "Going to exit from the system update."
		exit 0
	fi
fi
fi
