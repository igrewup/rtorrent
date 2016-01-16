#!/bin/bash
while true; do ./vpnuserlist.sh |grep -e ^CLIENT_LIST; sleep 1; done
