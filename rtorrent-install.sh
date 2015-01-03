#!/bin/bash
source $(dirname $0)/incl.sh

####################### EVERYTHING LOOKS GOOD, START THE SCRIPT ###############################
clear

# Check to see if this script is up-to-date
if [[ $1 == "update" ]]; then
  source $(dirname $0)/check_version.sh
  echo
  echo "Now continuing with the installation."
  echo
elif [[ $1 == "noupdate" ]]; then
	echo
	echo "Skipping script update checker"
	echo
else
	echo
	read -p "Run script updater (y/n)? " UPDATE1
	if [[ $UPDATE1 = "y" ]]; then
  		source $(dirname $0)/check_version.sh
  		echo
  		echo "Now continuing with the installation."
  		echo
  	fi
fi

# Welcome screen
echo
echo "NOTE: Options when launching ./rtorrent-install.sh [ update | noupdate ]"
echo "By default, if no variable is given, it will ask you to update (y/n)."
echo
echo "Your system is running $OS1 ($OS2) which is supported by this script."
echo
read -p "Press [Enter] to start the installation... Press [CTRL+C] to abort." -n 1
echo
echo
# Remove temp files
rm $OUTPUTFILE
clear

# Prompting for system user.
cut -d":" -f1 /etc/passwd > /tmp/users.list
DIRS=`ls -l /home | egrep '^d' | awk '{print $9}'`

for DIR in $DIRS
do
# Remove usernames that exist in /home
sed -i "/$DIR/d" /tmp/users.list
done

check=0
user=nobody
while [ $check -eq 0 ]; do

# Script to see if User exists
echo
echo -n "Check if username is valid: "
read user

if grep -wF "$user" /tmp/users.list > /dev/null; then
   echo
   echo "You can't use '$user' as a user!"
elif id -u $user >/dev/null 2>&1; then
#elif [ id $user ]; then
	echo "ID=$user"
	check=1
else
	echo
	echo "This user does not exist, try a different user."
fi

done

rm /tmp/users.list

echo
echo "$user is a valid and available username"

homedir=$(cat /etc/passwd | grep "$user": | cut -d: -f6)

# those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

# Install other software & services
#getString NO  "Set password for $user: " PASSWORD1
getString NO "Install/Update rTorrent (yes/no)?: " INSTALLRTORRENT1 NO
getString NO "Install/Update ruTorrent WebGUI (yes/no)?: " INSTALLRUTORRENT1 NO
if [ "$INSTALLRUTORRENT1" = "YES" ]; then
getString NO "Install/Update RUTORRENT PLUGINS (yes/no)?: " INSTALLPLUGINS1 YES
fi
getString NO  "Install/Update SSH (yes/no)?: " INSTALLSSH1 NO
if [ "$INSTALLSSH1" = "YES" ]; then
getString NO  "SSH port (usually 22): " NEWSSHPORT1 22
fi
getString NO  "Install/Update VSFTPD (yes/no)?: " INSTALLVSFTPD1 NO
if [ "$INSTALLVSFTPD1" = "YES" ]; then
getString NO  "VSFTPD port (usually 21): " NEWFTPPORT1 21
fi
getString NO  "Install/Update OpenVPN (yes/no)?: " INSTALLOPENVPN1 NO
if [ "$INSTALLOPENVPN1" = "YES" ]; then
getString NO  "Port 1194 is already set but you can add another port (usually 53): " OPENVPNPORT1 53
fi
getString NO  "Install/Update Webmin (yes/no)?: " INSTALLWEBMIN1 NO
if [ "$INSTALLWEBMIN1" = "YES" ]; then
getString NO  "Webmin port (default: 10000)?: " WEBMINPORT1 10000
fi

clear

	echo "Your settings:"
	echo
	echo "USERNAME: $user |  PASSWORD: $PASSWORD1  |  HOMEDIR: $homedir"
	echo
if [ "$INSTALLRTORRENT1" = "YES" ]; then
	echo "Install/Update RTORRENT: $INSTALLRTORRENT1"
	echo
fi

if [ "$INSTALLRUTORRENT1" = "YES" ]; then
echo "Install/Update RUTORRENT: $INSTALLRUTORRENT1"
	if [ "$INSTALLPLUGINS1" = "YES" ]; then
	echo "Install/Update PLUGINS: $INSTALLPLUGINS1"
fi
echo
fi

if [ "$INSTALLSSH1" = "YES" ]; then
	echo "Install/Update SSH: $INSTALLSSH1"
	echo "SSH port: $NEWSSHPORT1"
	echo
fi
if [ "$INSTALLVSFTPD1" = "YES" ]; then
	echo "Install/Update VSFTPD: $INSTALLVSFTPD1"
	echo "VSFTPD port: $NEWFTPPORT1"
	echo
fi
if [ "$INSTALLOPENVPN1" = "YES" ]; then
	echo "Install/Update OPENVPN: $INSTALLOPENVPN1"
	echo "OPENVPN main port: 1194"
	echo "OPENVPN alternate port: $OPENVPNPORT1"
	echo
fi
if [ "$INSTALLWEBMIN1" = "YES" ]; then
	echo "Install/Update WEBMIN: $INSTALLWEBMIN1"
	echo "WEBMIN port: $WEBMINPORT1"
	echo
fi

read -p "DO YOU WANT TO CONTINUE WITH THE INSTALLATION? (yes / no): " INSTALL
#getString NO  "DO YOU WANT TO CONTINUE WITH INSTALLATION? (yes/no): " INSTALL NO
### START INSTALLATION = YES ##
if [ "$INSTALL" = "yes" ]; then
read -p "ARE YOU SURE? (yes / no): " SURE
	if [ "$SURE" != "yes" ]; then
		echo
		echo "Aborting installation."
		echo
		exit
	else
		clear
		echo
		echo "Starting the installation now, this will take a while..."
		echo
	fi

# Installing dependencies
apt-get update > /dev/null
apt-get -y install openssl git subversion zip unzip rar unrar-free

clear
if [ "$INSTALLRTORRENT1" = "YES" ]; then
	bash ./install_rtorrent "$homedir" "$user"
fi

if [ "$INSTALLRUTORRENT1" = "YES" ]; then
	bash ./install_rutorrent "$homedir" "$user"
fi

if [ "$INSTALLSSH1" = "YES" ]; then
	bash ./install_ssh "$NEWSSHPORT1"
fi

if [ "$INSTALLVSFTPD1" = "YES" ]; then
  bash ./install_vsftpd "$NEWFTPPORT1"
fi

if [ "$INSTALLOPENVPN1" = "YES" ]; then
  bash ./install_openvpn "$user" "$OPENVPNPORT1"
fi

if [ "$INSTALLWEBMIN1" = "YES" ]; then
  bash ./install_webmin "$WEBMINPORT1"
fi

if [ "$INSTALLPLUGINS1" = "YES" ]; then
	bash ./install_plugins "$homedir"
fi

clear

echo -e "\033[0;32;148mInstallation is complete..\033[39m"
tput sgr0
echo

if [ -z "$(ip addr | grep eth0)" ]; then
	echo "Unable to find your IP Address."
	echo "ruTorrent WebGUI: https://IP.ADDRESS/rutor"
	echo "Webmin: https://<IP.ADDRESS>:10000 (unless port was changed)"
	echo "OpenVPN certificate: https://<IP.ADDRESS>/rutor/vpn/" 
else
	ip=$(ip addr | grep eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)
	if [ "$INSTALLRUTORRENT1" = "YES" ]; then
		echo "ruTorrent WebGUI: https://$ip/rutor/"
	fi
	if [ "$INSTALLWEBMIN1" = "YES" ]; then
		echo "Webmin: https://$ip:$WEBMINPORT1"
	fi
	if [ "$INSTALLOPENVPN1" = "YES" ]; then
		if [ -f $OUTPUTFILE ]; then
			grep 'https://' $OUTPUTFILE
		fi
	fi
	echo
	if [ -f $OUTPUTFILE ]; then
		grep -v 'https://' $OUTPUTFILE 
	fi
fi
rm $OUTPUTFILE
echo
echo -e "\033[0;32;148mTo exit the script, type: exit\033[39m"

exec sh

else
	echo
	echo "Aborting installation."
	echo
	exit 1
fi 
### END INSTALLATION ###
