#!/bin/bash
source $(dirname $0)/incl.sh


# Checking if user is root.
if [[ $EUID -ne 0 ]]; then
  echo
  echo "This script must be run as root" 1>&2
  echo
  exit 1
fi

# Checking if system is running Debian.
if [ "$OS1" != "Debian" ]; then
	echo
	echo "You are not running Debian. This script will now exit." 1>&2
	echo
	exit 1
fi

# Checking if system is running Debian.
if [ "$OS2" != "wheezy" ]; then
	echo
	echo "Unfortunately, you are not running Debian codename (wheezy)"
	echo "You are running Debian codename $OS2. This script will now exit." 1>&2
	echo
	exit 1
fi

####################### EVERYTHING LOOKS GOOD, START THE SCRIPT ###############################
clear

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

# License

echo
echo
echo "Your system is running $OS1 ($OS2) which is support by this script."
echo
#read -p "Press [Enter] to start the installation... Press [CTRL+C] to abort." -n 1
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
getString NO "Install/Update rTorrent (yes/no)?: " INSTALLRTORRENT1 YES
getString NO  "Install/Update SSH (yes/no)?: " INSTALLSSH1 YES
if [ "$INSTALLSSH1" = "YES" ]; then
getString NO  "SSH port (usually 22): " NEWSSHPORT1 22
fi
getString NO  "Install/Update VSFTPD (yes/no)?: " INSTALLVSFTPD1 YES
if [ "$INSTALLVSFTPD1" = "YES" ]; then
getString NO  "VSFTPD port (usually 21): " NEWFTPPORT1 21
fi
getString NO  "Install/Update OpenVPN (yes/no)?: " INSTALLOPENVPN1 NO
if [ "$INSTALLOPENVPN1" = "YES" ]; then
getString NO  "OpenVPN port (usually ??): " OPENVPNPORT1 22220
fi
getString NO  "Install/Update Webmin (yes/no)?: " INSTALLWEBMIN1 NO
if [ "$INSTALLWEBMIN1" = "YES" ]; then
getString NO  "Webmin port (default: 10000)?: " WEBMINPORT1 10000
fi
getString NO "Install/Update PLUGINS (yes/no)?: " INSTALLPLUGINS1 YES
clear

echo "Your settings:"
echo
echo "USERNAME: $user |  PASSWORD: $PASSWORD1  |  HOMEDIR: $homedir"
echo
if [ "$INSTALLRTORRENT1" = "YES" ]; then
echo "Install/Update RTORRENT: $INSTALLRTORRENT1"
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
if [ "$INSTALLPLUGINS1" = "YES" ]; then
echo "Install/Update PLUGINS: $INSTALLPLUGINS1"
echo
fi

echo
echo
read -p "Press [Enter] to start the installation... Press [CTRL+C] to abort." -n 1
echo

#getString NO  "DO YOU WANT TO CONTINUE WITH INSTALLATION? (yes/no): " INSTALL NO
INSTALL=YES
### START INSTALLATION = YES ##
if [ "$INSTALL" = "YES" ]; then

clear
if [ "$INSTALLRTORRENT1" = "YES" ]; then
	bash ./install_rtorrent "$homedir" "$user"
fi

if [ "$INSTALLSSH1" = "YES" ]; then
	bash ./install_ssh "$NEWSSHPORT1"
fi

if [ "$INSTALLVSFTPD1" = "YES" ]; then
  bash ./install_vsftpd "$NEWFTPPORT1"
fi

if [ "$INSTALLOPENVPN1" = "YES" ]; then
  bash ./install_openvpn "$OPENVPNPORT1"
fi

if [ "$INSTALLWEBMIN1" = "YES" ]; then
  bash ./install_webmin "$WEBMINPORT1"
fi

if [ "$INSTALLPLUGINS1" = "YES" ]; then
	bash ./install_plugins "$homedir"
fi

else
	echo
	echo "Aborting installation."
	echo
	exit 1
fi 
### END INSTALLATION ###

# Secure ruTorrent web folder
cp .htaccess /var/www/rutor/ && chmod 444 /var/www/rutor/.ht*

clear
cat output.txt && rm output.txt
echo "End of rTorrent installation script."
