#!/bin/sh

set -e

# Load environment variables
. /mnt/data/ubios-ddns/ubios-ddns.env

# Setup persistent on_boot.d trigger
ON_BOOT_DIR='/mnt/data/on_boot.d'
ON_BOOT_FILE='98-ubios-ddns.sh'
if [ -d "${ON_BOOT_DIR}" ] && [ ! -f "${ON_BOOT_DIR}/${ON_BOOT_FILE}" ]; then
	cp "${UBIOS_DDNS_ROOT}/on_boot.d/${ON_BOOT_FILE}" "${ON_BOOT_DIR}/${ON_BOOT_FILE}"
	chmod 755 ${ON_BOOT_DIR}/${ON_BOOT_FILE}
	echo "Restored 'on_boot.d' trigger"
fi

# Setup cron job to run every minute
CRON_FILE='/etc/cron.d/ubios-ddns'
if [ ! -f "${CRON_FILE}" ]; then
	echo "* * * * * sh ${UBIOS_DDNS_ROOT}/ubios-ddns.sh > ${UBIOS_DDNS_ROOT}/ubios-ddns.log 2>&1" >${CRON_FILE}
	chmod 644 ${CRON_FILE}
	/etc/init.d/crond reload ${CRON_FILE}
	echo "Restored cron file"
fi

# Check DNS record and update if ncessary
result=$(curl -s -X GET -H "${SSO}" \
 "${API_URL}/${DOMAIN}/records/A/${NAME}")

dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "dnsIp:" $dnsIp

# Get public IP address. There are several websites that can do this.
ret=$(curl -s GET "https://ipinfo.io/json")
currentIp=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo "currentIp:" $currentIp

if [ "$dnsIp" != "$currentIp" ];
 then
	echo "Ips are not equal"
	request='[{"data":"'$currentIp'","ttl":600}]'
	echo " request:" $request
	nresult=$(curl -i -s -X PUT \
 -H "${SSO}" \
 -H "Content-Type: application/json" \
 -d $request "${API_URL}/${DOMAIN}/records/A/${NAME}")
	echo "result:" $nresult
fi