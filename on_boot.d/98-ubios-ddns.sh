#!/bin/sh

# Load environment variables
. /data/ubios-ddns/ubios-ddns.env

if [ ! -f /etc/cron.d/ubios-ddns ]; then
	# Sleep for 1 minute to allow Internet connection to be up.
	sleep 60
	sh /data/ubios-ddns/ubios-ddns.sh
fi
