#!/bin/sh
set -e

RUN . /etc/default/apache2
RUN . /etc/apache2/envvars
export APACHE_LOCK_DIR=/var/run/lock/apache2$SUFFIX
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} ${APACHE_LOCK_DIR}

# Apache gets grumpy about PID files pre-existing
rm -f ${APACHE_PID_FILE}

exec apache2 -X -D FOREGROUND
