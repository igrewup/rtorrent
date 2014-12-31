#!/bin/bash

VERSION=1.00
OS1=$(lsb_release -si)
OS2=$(lsb_release -sc)
OSV1=$(lsb_release -rs)
OUTPUTFILE="/tmp/output.txt"

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

if [ ! -f /var/www/vpn/index.html ]; then
echo "index.html doesn't exist, now creating it."
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
