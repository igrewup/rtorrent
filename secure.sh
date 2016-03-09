#!/bin/bash
echo "Checking if webserver is secure..."

# Check webserver folders to make sure it's secure.
if [ ! -f /var/www/index.html ]; then
echo "Webserver root folder is not secure, securing /var/www/"
echo '<html><body><h1>It works!</h1>
<p>This is the default web page for this server.</p>
<p>The web server software is running but no content has been added, yet.</p>
</body></html>' > /var/www/index.html
chown root.root /var/www/index.html
chmod 444 /var/www/index.html
echo "Webserver root folder /var/www/ is now secure."
fi

if [ ! -f /var/www/.htaccess ]; then
echo "Root redirect is missing."
echo 'Redirect 301 /index.html http://www.torproject.org' > /var/www/.htaccess
chown root.root /var/www/.htaccess
chmod 444 /var/www/.htaccess
echo "Root redirect now setup."
fi

# Check to make sure VPN folder is secure.
if [ ! -f /var/www/vpn/.htaccess ]; then
mkdir -p /var/www/vpn/
echo "VPN folder is not secure, securing /var/www/vpn."
echo '#Prevent directory listings
Options All -Indexes' > /var/www/vpn/.htaccess
chown www-data.www-data /var/www/vpn/.htaccess
chmod 444 /var/www/vpn/.htaccess
echo "VPN folder /var/www/vpn is now secure."
fi

echo "Webserver is SECURE"
