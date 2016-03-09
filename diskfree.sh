#!/bin/bash
# Run every 10 minutes, add the command below to crontab.
# Use command: crontab -e
# Add the line below to crontab (without the # at the begining)
# */10 * * * * /path/to/diskfree.sh
# change the location where df will check for free space.
diskcheck="/location/of/dir/to/check/freespace"
# Do not modify anything starting here.
df -h $diskcheck | tail -n+2 | while read fs size used avail rest ; do
    if [[ $used ]] ; then
	rmdir $diskcheck/0o.DISKFREE*
	mkdir $diskcheck/0o.DISKFREE-$avail.o0
	chmod 000 $diskcheck/0o.DISKFREE*
    fi
done

