#!/bin/bash

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.


#if [ ! -d "$APACHE_RUN_DIR" ]; then
#	mkdir "$APACHE_RUN_DIR"
#	chown $APACHE_RUN_USER:$APACHE_RUN_GROUP "$APACHE_RUN_DIR"
#fi

if [ -f "$APACHE_PID_FILE" ]; then
	rm "$APACHE_PID_FILE"
fi

rm -rf /run/httpd/* /tmp/httpd*

LOCKFILE=/run/apache2/apache2.pid

# Previous apache should execute successfully:

[ -f $LOCKFILE ] && exit 0

# Upon exit, remove lockfile.

trap "{ rm -f $LOCKFILE ; exit 255; }" EXIT

/usr/sbin/apache2ctl -D FOREGROUND
