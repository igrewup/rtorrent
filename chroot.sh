#!/bin/bash
# By default this script will create chroot in /home/jail as defined by the $CHROOT variable.
# Feel free to change this variable according to your needs. When ready, make the script executable
# and run it with the file full path to your executables and files you wish to include.
#
# For example, if you need: ls, cat, echo, rm, bash, vi then use the which command to get a full path
# and supply it as an argument to the above chroot.sh script: 
# ./chroot.sh /bin/{ls,cat,echo,rm,bash} /usr/bin/vi /etc/hosts

CHROOT='/home/jail'
if [ ! -d $CHROOT ]; then
mkdir $CHROOT
fi

#apt-get install bmon
#run chroot.sh /usr/bin/bmon
#mkdir $CHROOT/proc
#mount --bind /proc $CHROOT/proc


for i in $( ldd $* | grep -v dynamic | cut -d " " -f 3 | sed 's/://' | sort | uniq )
  do
    cp --parents $i $CHROOT
  done

# ARCH amd64
if [ -f /lib64/ld-linux-x86-64.so.2 ]; then
   cp --parents /lib64/ld-linux-x86-64.so.2 /$CHROOT
fi

# ARCH i386
if [ -f  /lib/ld-linux.so.2 ]; then
   cp --parents /lib/ld-linux.so.2 /$CHROOT
fi

echo "Chroot jail is ready. To access it execute: chroot $CHROOT"
