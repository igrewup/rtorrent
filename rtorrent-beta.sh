homedir=$(cat /etc/passwd | grep "$user": | cut -d: -f6)

# Installing dependencies

apt-get update
apt-get -y install openssl git subversion apache2 apache2-utils build-essential libsigc++-2.0-dev libcurl4-openssl-dev automake libtool libcppunit-dev libncurses5-dev libapache2-mod-scgi php5 php5-curl php5-cli libapache2-mod-php5 screen rar unrar zip unzip

# Downloading and installing rtorrent init script.

wget --no-check-certificate -O /etc/init.d/rtorrent-init https://raw.githubusercontent.com/igrewup/rtorrent/master/rtorrent-init

chmod +x /etc/init.d/rtorrent-init

sed -i "s/USERNAMEHERE/$user/g" /etc/init.d/rtorrent-init

update-rc.d rtorrent-init defaults


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

