#!/bin/bash
echo "Checking if webserver is secure..."

# Check webserver folders to make sure it's secure.
rm /var/www/index.html /var/www/.htaccess
echo '<html><body><h1>It works!</h1>
<p>This is the default web page for this server.</p>
<p>The web server software is running but no content has been added, yet.</p>
</body></html>' > /var/www/index.html
echo 'Redirect 301 /index.html http://www.torproject.org' > /var/www/.htaccess
chown root.root /var/www/index.html /var/www/.htaccess && chmod 444 /var/www/index.html /var/www/.htaccess

# Check to make sure OpenVPN folder is secure.
if [ -d /var/www/vpn/ ]; then
  # Control will enter here if /var/www/vpn/ exists.
  if [ ! -f /var/www/vpn/.htaccess ]; then  
  echo "VPN folder is not secure, securing /var/www/vpn/"
  echo '#Prevent directory listings
  Options All -Indexes' > /var/www/vpn/.htaccess
  chown www-data.www-data /var/www/vpn/.htaccess && chmod 444 /var/www/vpn/.htaccess
  echo "VPN folder /var/www/vpn/ is now secure."
  fi
else
	echo "OpenVPN is not installed. Skipping secure check."
fi

# Check to make sure ruTorrent folder is secure.
if [ -d /var/www/rutor/ ]; then
  # Control will enter here if /var/www/rutor/ exists.
	if [ ! -f /var/www/rutor/.htaccess ]; then
	echo "ruTorrent folder is not secure, securing /var/www/rutor/"
	cp $(dirname $0)/.htaccess /var/www/rutor/.htaccess
	chown www-data.www-data /var/www/rutor/.htaccess && chmod 444 /var/www/rutor/.htaccess
	echo "ruTorrent folder /var/www/rutor/ is now secure."
	fi
else
	echo "ruTorrent is not installed. Skipping secure check."
fi

# Check to make sure VnStat folder is secure.
if [ -d /var/www/vnstat/ ]; then
  # Control will enter here if /var/www/vnstat/ exists.
	if [ ! -f /var/www/vnstat/.htaccess ]; then
	echo "VnStat folder is not secure, securing /var/www/vnstat/"
	cp $(dirname $0)/.htaccess /var/www/vnstat/.htaccess
	chown www-data.www-data /var/www/vnstat/.htaccess && chmod 444 /var/www/vnstat/.htaccess
	echo "VnStat folder /var/www/vnstat/ is now secure."
	fi
else
	echo "VnStat is not installed. Skipping secure check."
fi

echo "Webserver is SECURE"
