#!/bin/sh

# Load environment variables
. /mnt/data/ubios-ddns/ubios-ddns.env

if [ ! -f /etc/cron.d/ubios-ddns ]; then
	# Sleep for 1 minute to allow Internet connection to be up.
	sleep 60
	sh ${UBIOS_DDNS_ROOT}/ubios-ddns.sh
fi
