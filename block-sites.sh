#!/bin/bash
# Install whois
sudo apt-get -y install whois

blocked="/root/blocked-sites-list.txt"
rm $blocked && touch $blocked
echo "#!/bin/bash" >> $blocked

# Allow SSH
echo "# Start Allow SSH" >> $blocked
echo "iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT" >> $blocked
echo "# End Allow SSH" >> $blocked

# Block Facebook
echo "# Start Blocking Facebook" >> $blocked
echo "iptables -A OUTPUT -d facebook.com -j REJECT" >> $blocked
echo "iptables -A OUTPUT -d www.facebook.com -j REJECT" >> $blocked
for ip in `whois -h whois.radb.net '!gAS32934' | grep /`
do
echo "iptables -A FORWARD -p all -d $ip -j REJECT" >> $blocked
#  /sbin/iptables -A FORWARD -p all -d $ip -j REJECT
done
echo "# End Blocking Facebook" >> $blocked

# Block POF
echo "# Start Blocking POF" >> $blocked
echo "iptables -A OUTPUT -d pof.com -j REJECT" >> $blocked
echo "iptables -A OUTPUT -d www.pof.com -j REJECT" >> $blocked
echo "iptables -A FORWARD -p all -d 199.182.216.166 -j REJECT" >> $blocked
echo "# End Blocking POF" >> $blocked

chmod 755 $blocked

clear
cat $blocked
