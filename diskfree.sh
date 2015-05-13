#!/bin/bash
# Run every 10minutes add the command below to crontab.
# Use command: crontab -e
# Add the line below to crontab (without the # at the begining)
# */10 * * * * /path/to/script
# change the location where df will check for free space.
df -h /change/me | tail -n+2 | while read fs size used avail rest ; do
    if [[ $used ]] ; then
	rmdir 0o.DISKFREE*
	mkdir 0o.DISKFREE-$avail.o0
    fi
done
