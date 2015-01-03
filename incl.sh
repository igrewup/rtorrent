#!/bin/bash

OS1=$(lsb_release -si)
OS2=$(lsb_release -sc)
OSV1=$(lsb_release -rs)
OUTPUTFILE="/tmp/output.txt"
HITENTER="pause 'Press [Enter] key to continue...'"

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

# Checking if Debian is running codename 'wheezy'.
if [ "$OS2" != "wheezy" ]; then
	echo
	echo "Unfortunately, you are not running Debian codename (wheezy)"
	echo "You are running Debian codename $OS2. This script will now exit." 1>&2
	echo
	exit 1
fi

### FUNCTIONS
function pause(){
   read -p "$*"
}

function getString
{
ISPASSWORD=$1
LABEL=$2
RETURN=$3
DEFAULT=$4
NEWVAR1=a
NEWVAR2=b
YESYES=YESyes
NONO=NOno
YESNO=$YESYES$NONO

  while [ ! $NEWVAR1 = $NEWVAR2 ] || [ -z "$NEWVAR1" ];
  do
    #clear

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
    #echo "---> $NEWVAR2"

  done
  eval $RETURN=\$NEWVAR1
}

# Security check to make sure server is secure.
if [ ! -f /var/www/vpn/index.html ]; then
mkdir -p /var/www/vpn/
echo '<!DOCTYPE HTML>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="1;url=http://www.ubuntu.com">
<script type="text/javascript">
window.location.href = "http://www.ubuntu.com"
</script>
<title>Page Redirection</title>
</head>
<body>
If you are not redirected automatically, follow the <a href='http://www.ubuntu.com'></a>
</body>
</html>' > /var/www/vpn/index.html
fi
