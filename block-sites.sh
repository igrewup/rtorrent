#!/bin/bash

# Block facebook using IPTABLES
blocked="/root/blocked-sites-list.txt"
for ip in `whois -h whois.radb.net '!gAS32934' | grep /`
do
rm $blocked && touch $blocked
echo $ip >> $blocked
cat $blocked
#  /sbin/iptables -A FORWARD -p all -d $ip -j REJECT
done
