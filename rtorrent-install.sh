#!/bin/bash
source $(dirname $0)/incl.sh

####################### EVERYTHING LOOKS GOOD, START THE SCRIPT ###############################
clear

# Check to see if this script is up-to-date
if [[ $1 == "update" ]]; then
  source $(dirname $0)/check_version.sh
  echo
  echo " Now continuing with the installation."
  echo
elif [[ $1 == "noupdate" ]]; then echo; echo " Skipping script update checker"; echo;
else echo; read -p " Run script updater (y/n)? " UPDATE1;
	if [[ $UPDATE1 = "y" ]]; then source $(dirname $0)/check_version.sh; echo; echo " Now continuing with the installation."; echo; fi
fi

# Welcome screen
echo
echo " NOTE: Options when launching ./rtorrent-install.sh [ update | noupdate ]"
echo " By default, if no variable is given, it will ask you to update (y/n)."
echo
echo " Your system is running $OS1 ($OS2) which is supported by this script."
echo
read -p " Press [Enter] to start the installation... Press [CTRL+C] to abort." -n 1
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


# Script to see if the username entered exist.
check=0
while [ $check -eq 0 ]; do
echo; read -p " Check if username is valid: " user;
if [ -z $user ]; then
	echo " You did not enter a username."
else	
	if grep -wF "$user" /tmp/users.list > /dev/null; then echo; echo " You can't use '$user' as a user!";
	elif id -u $user >/dev/null 2>&1; then echo " The username name '$user' is valid."; echo " Continuing with installation..."; echo; check=1;
	else echo; echo " This user does not exist, try a different user."; fi
fi
done

rm /tmp/users.list
homedir=$(cat /etc/passwd | grep "$user": | cut -d: -f6)

# those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

# Custom Install
read -p " Install everything using default settings (y/n)? " YESORNO1;
if [[ $YESORNO1 = "y" ]]; then ANSWER="YES";	else ANSWER="NO";	fi

# Install other software & services
#getString NO  "Set password for $user: " PASSWORD1
getString NO " Install/Update rTorrent (yes/no)?: " INSTALLRTORRENT1 $ANSWER
getString NO " Install/Update ruTorrent WebGUI (yes/no)?: " INSTALLRUTORRENT1 $ANSWER
if [ "$INSTALLRUTORRENT1" = "YES" ]; then
INSTALLPLUGINS1=NO
getString NO " Install/Update RUTORRENT PLUGINS (yes/no)?: " INSTALLPLUGINS1 YES
fi
getString NO  " Install/Update SSH (yes/no)?: " INSTALLSSH1 $ANSWER
if [ "$INSTALLSSH1" = "YES" ]; then
getString NO  " SSH port (usually 22): " NEWSSHPORT1 22
fi
getString NO  " Install/Update VSFTPD (yes/no)?: " INSTALLVSFTPD1 $ANSWER
if [ "$INSTALLVSFTPD1" = "YES" ]; then
getString NO  " VSFTPD port (usually 21): " NEWFTPPORT1 21
fi
getString NO  " Install/Update OpenVPN (yes/no)?: " INSTALLOPENVPN1 $ANSWER
if [ "$INSTALLOPENVPN1" = "YES" ]; then
getString NO  " Port 1194 is already set but you can add another port (usually 53): " OPENVPNPORT1 53
fi
getString NO  " Install/Update Proxy Server (yes/no)?: " INSTALLSQUID1 $ANSWER
if [ "$INSTALLSQUID1" = "YES" ]; then
getString NO  " VSFTPD port (usually 3128): " SQUIDPORT1 3128
fi
getString NO  " Install/Update Webmin (yes/no)?: " INSTALLWEBMIN1 $ANSWER
if [ "$INSTALLWEBMIN1" = "YES" ]; then
getString NO  " Webmin port (default: 10000)?: " WEBMINPORT1 10000
fi

clear
echo "                          S  E  T  T  I  N  G  S                             "
echo "============================================================================="
echo
echo " USERNAME: $user    |     HOMEDIR: $homedir"
echo
if [ "$INSTALLRTORRENT1" = "YES" ]; then echo " Install/Update RTORRENT: $INSTALLRTORRENT1"; echo; fi
if [ "$INSTALLRUTORRENT1" = "YES" ]; then echo " Install/Update RUTORRENT: $INSTALLRUTORRENT1 and PLUGINS: $INSTALLPLUGINS1"; echo; fi
if [ "$INSTALLSSH1" = "YES" ]; then echo " Install/Update SSH: $INSTALLSSH1 on PORT: $NEWSSHPORT1"; echo; fi
if [ "$INSTALLVSFTPD1" = "YES" ]; then echo " Install/Update VSFTPD: $INSTALLVSFTPD1 on PORT: $NEWFTPPORT1"; echo; fi
if [ "$INSTALLSQUID1" = "YES" ]; then echo " Install/Update Proxy Server: $INSTALLSQUID1 on PORT: $SQUIDPORT1"; echo; fi
if [ "$INSTALLWEBMIN1" = "YES" ]; then echo " Install/Update WEBMIN: $INSTALLWEBMIN1 on PORT: $WEBMINPORT1"; echo; fi
if [ "$INSTALLOPENVPN1" = "YES" ]; then	echo " Install/Update OPENVPN: $INSTALLOPENVPN1 on MAIN PORT: 1194 and ALTERNATE PORT: $OPENVPNPORT1"; echo; fi

while [ $LAUNCH -eq 0 ]; do
read -p "DO YOU WANT TO CONTINUE WITH THE INSTALLATION? (yes / no): " INSTALL
if [ -z $INSTALL ]; echo "You did not enter yes or no. Try again." else LAUNCH=1; fi
if [ "$INSTALL" = "yes" ]; then
read -p "ARE YOU SURE? (yes / no): " SURE
if [ "$SURE" != "yes" ]; then echo; echo "Aborting installation."; echo; exit; else clear; echo; echo "Starting the installation now, this will take a while..."; echo; fi

# Installing dependencies
apt-get update > /dev/null && apt-get -y install openssl git subversion zip unzip rar unrar-free

clear
if [ "$INSTALLRTORRENT1" = "YES" ]; then bash ./install_rtorrent "$homedir" "$user"; fi
if [ "$INSTALLRUTORRENT1" = "YES" ]; then bash ./install_rutorrent "$homedir" "$user"; fi
if [ "$INSTALLSSH1" = "YES" ]; then bash ./install_ssh "$NEWSSHPORT1"; fi
if [ "$INSTALLVSFTPD1" = "YES" ]; then bash ./install_vsftpd "$NEWFTPPORT1"; fi
if [ "$INSTALLOPENVPN1" = "YES" ]; then bash ./install_openvpn "$user" "$OPENVPNPORT1"; fi
if [ "$INSTALLSQUID1" = "YES" ]; then bash ./install_squid "$user" "$SQUIDPORT1"; fi
if [ "$INSTALLWEBMIN1" = "YES" ]; then bash ./install_webmin "$WEBMINPORT1"; fi
if [ "$INSTALLPLUGINS1" = "YES" ]; then bash ./install_plugins "$homedir"; fi
clear
echo -e "\033[0;32;148mInstallation is complete..\033[39m"
tput sgr0
echo

if [ -z "$(ip addr | grep eth0)" ]; then
	echo "Unable to find your IP Address."
	ip="<IP.ADDRESS>"
	detectnet=0
else
	ip=$(ip addr | grep eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)
	detectnet=1
fi

# ruTorrent WebGUI
if [ "$INSTALLRUTORRENT1" = "YES" ]; then echo "ruTorrent WebGUI: https://$ip/rutor/"; fi
# Webmin
if [ "$INSTALLWEBMIN1" = "YES" ]; then
	if [ $detectnet = 0 ]; then echo "Webmin: https://<IP.ADDRESS>:10000 (unless port was changed)"; else echo "Webmin: https://$ip:$WEBMINPORT1"; fi	
fi
# Proxy Server
if [ "$INSTALLSQUID1" = "YES" ]; then
	SQUIDPORT=$(grep "http_port" /etc/squid3/squid.conf | cut -d' ' -f2)
	echo "Proxy Server: http://$ip/ - Port: $SQUIDPORT"
fi
echo
if [ -f $OUTPUTFILE ]; then grep -v 'https://' $OUTPUTFILE; rm $OUTPUTFILE; fi
echo
echo -e "\033[0;32;148mTo exit the script, type: exit\033[39m"

exec sh
# ELSE Installation Start
else echo; echo "Aborting installation."; echo;	exit 1; fi
# END Installation Start
