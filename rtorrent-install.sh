#!/bin/bash
source $(dirname $0)/incl.sh

####################### EVERYTHING LOOKS GOOD, START THE SCRIPT ###############################

function getString
{
  local ISPASSWORD=$1
  local LABEL=$2
  local RETURN=$3
  local DEFAULT=$4
  local NEWVAR1=a
  local NEWVAR2=b
  local YESYES=YESyes
  local NONO=NOno
  local YESNO=$YESYES$NONO

  while [ ! $NEWVAR1 = $NEWVAR2 ] || [ -z "$NEWVAR1" ];
  do
    clear

    if [ "$ISPASSWORD" == "YES" ]; then
      read -s -p "$DEFAULT" -p "$LABEL" NEWVAR1
    else
      read -e -i "$DEFAULT" -p "$LABEL" NEWVAR1
    fi
    if [ -z "$NEWVAR1" ]; then
      NEWVAR1=a
      continue
    fi

    if [ ! -z "$DEFAULT" ]; then
      if grep -q "$DEFAULT" <<< "$YESNO"; then
        if grep -q "$NEWVAR1" <<< "$YESNO"; then
          if grep -q "$NEWVAR1" <<< "$YESYES"; then
            NEWVAR1=YES
          else
            NEWVAR1=NO
          fi
        else
          NEWVAR1=a
        fi
      fi
    fi

    if [ "$NEWVAR1" == "$DEFAULT" ]; then
      NEWVAR2=$NEWVAR1
    else
      if [ "$ISPASSWORD" == "YES" ]; then
        echo
        read -s -p "Retype: " NEWVAR2
      else
        read -p "Retype: " NEWVAR2
      fi
      if [ -z "$NEWVAR2" ]; then
        NEWVAR2=b
        continue
      fi
    fi


    if [ ! -z "$DEFAULT" ]; then
      if grep -q "$DEFAULT" <<< "$YESNO"; then
        if grep -q "$NEWVAR2" <<< "$YESNO"; then
          if grep -q "$NEWVAR2" <<< "$YESYES"; then
            NEWVAR2=YES
          else
            NEWVAR2=NO
          fi
        else
          NEWVAR2=a
        fi
      fi
    fi
    echo "---> $NEWVAR2"

  done
  eval $RETURN=\$NEWVAR1
}

# Output result file
rm output.txt

# Welcome screen
clear
echo
echo
echo "Your system is running $OS1 ($OS2) which is support by this script."
echo
read -p "Press [Enter] to start the installation... Press [CTRL+C] to abort." -n 1
echo
echo

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
echo -n "Check if username is valid: "
read user

if grep "$user" /tmp/users.list > /dev/null; then
   echo "You can't use '$user' as a user!"
elif id -u $user >/dev/null 2>&1; then
#elif [ id $user ]; then
	echo "ID=$user"
	check=1
else
	echo "This user does not exist, try a different user."
fi

done

rm /tmp/users.list

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
	echo "OPENVPN port: $OPENVPNPORT1"
	echo
fi
if [ "$INSTALLWEBMIN1" = "YES" ]; then
	echo "Install/Update WEBMIN: $INSTALLWEBMIN1"
	echo "WEBMIN port: $WEBMINPORT1"
	echo
fi

read -p "DO YOU WANT TO CONTINUE WITH THE INSTALLATION? (yes / no):" INSTALL
#getString NO  "DO YOU WANT TO CONTINUE WITH INSTALLATION? (yes/no): " INSTALL NO
### START INSTALLATION = YES ##
if [ "$INSTALL" = "yes" ]; then
read -p "ARE YOU SURE? (yes / no):" SURE
	if [ "$SURE" != "yes" ]; then
		echo
		echo "Aborting installation."
		echo
		exit
	else
		clear
		echo "Starting the installation now, this will take a while..."
	fi

# Installing dependencies
apt-get update
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
  bash ./install_openvpn "$OPENVPNPORT1" "$user"
fi

if [ "$INSTALLWEBMIN1" = "YES" ]; then
  bash ./install_webmin "$WEBMINPORT1"
fi

if [ "$INSTALLPLUGINS1" = "YES" ]; then
	bash ./install_plugins "$homedir"
fi

clear

echo -e "\033[0;32;148mInstallation is complete..\033[39m"
cat output.txt && rm output.txt
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
	echo "OpenVPN certificate: https://$ip/rutor/vpn/"
	fi
fi
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
