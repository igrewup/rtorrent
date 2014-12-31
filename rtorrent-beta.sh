homedir=$(cat /etc/passwd | grep "$user": | cut -d: -f6)

# Installing dependencies

apt-get update
apt-get -y install openssl git subversion apache2 apache2-utils build-essential libsigc++-2.0-dev libcurl4-openssl-dev automake libtool libcppunit-dev libncurses5-dev libapache2-mod-scgi php5 php5-curl php5-cli libapache2-mod-php5 screen rar unrar zip unzip

# Downloading and installing rtorrent init script.

wget --no-check-certificate -O /etc/init.d/rtorrent-init https://raw.githubusercontent.com/igrewup/rtorrent/master/rtorrent-init

chmod +x /etc/init.d/rtorrent-init

sed -i "s/USERNAMEHERE/$user/g" /etc/init.d/rtorrent-init

update-rc.d rtorrent-init defaults

# Creating Apache SSL certificates

if [ ! -f /etc/ssl/private/apache.crt ]; then

openssl req -x509 -nodes -days 12000 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -newkey rsa:2048 -keyout /etc/ssl/private/apache.key -out /etc/ssl/private/apache.crt
chmod 600 /etc/ssl/private/apache.*

#sed -i 's/.*SSLEngine on/SSLEngine on/' /etc/apache2/sites-available/default-ssl
#sed -i 's/.*SSLCertificateFile.*/SSLCertificateFile \/etc\/ssl\/private\/apache.crt/' /etc/apache2/sites-available/default-ssl
#sed -i 's/.*SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/ssl\/private\/apache.key/' /etc/apache2/sites-available/default-ssl

fi

rm /etc/apache2/sites-available/default-ssl
echo '<IfModule mod_ssl.c>
<VirtualHost _default_:443>
	ServerAdmin webmaster@localhost

	DocumentRoot /var/www
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory "/usr/lib/cgi-bin">
		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog ${APACHE_LOG_DIR}/ssl_access.log combined

	SSLEngine on

	SSLCertificateFile /etc/ssl/private/apache.crt
	SSLCertificateKeyFile /etc/ssl/private/apache.key

	<FilesMatch "\.(cgi|shtml|phtml|php)$">
		SSLOptions +StdEnvVars
	</FilesMatch>
	<Directory /usr/lib/cgi-bin>
		SSLOptions +StdEnvVars
	</Directory>

	BrowserMatch "MSIE [2-6]" \
		nokeepalive ssl-unclean-shutdown \
		downgrade-1.0 force-response-1.0
	# MSIE 7 and newer should be able to use keepalive
	BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

</VirtualHost>
</IfModule>' > /etc/apache2/sites-available/default-ssl
chmod 644 /etc/apache2/sites-available/*

a2enmod ssl
a2enmod scgi
a2enmod rewrite
a2ensite default-ssl
a2ensite rutor

clear

echo -e "\033[0;32;148mInstallation is complete..\033[39m"
echo

service apache2 restart
service rtorrent-init start

echo -e "\033[0;32;148m Done..\033[39m"
echo
echo -e "\033[1;34;148mYour downloads is put in the 'Downloads' folder, sessions data in '.rtorrent-session' and 
rtorrent's configuration file is '.rtorrent.rc', all in your home directory.\033[39m"
echo
echo -e "\033[1;34;148mIf you want to change configuration for rtorrent, such as download folder, port, etc., 
you will need to edit the '.rtorrent.rc' file. E.g. 'nano $homedir/.rtorrent.rc'\033[39m"
tput sgr0
echo

if [ -z "$(ip addr | grep eth0)" ]; then
	echo "Visit rutorrent at http://IP.ADDRESS/rutor" 
else
	ip=$(ip addr | grep eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)
	echo "Visit rutorrent at http://$ip/rutor"
fi
echo
echo -e "\033[0;32;148mTo exit the script, type: exit\033[39m"

exec sh

