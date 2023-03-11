#!/bin/sh
set -e
SCRIPT_DIR=$(dirname ${0})

# Set default data path
export DATA_DIR="/mnt/data"
# Get the firmware version
export FIRMWARE_VER=$(ubnt-device-info firmware || true)
# Get the Harware Model
export MODEL="$(ubnt-device-info model || true)"

if [ $(echo ${FIRMWARE_VER} | sed 's#\..*$##g') -gt 1 ]
then
    sed -i 's#/mnt/data#/data#g' "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.env" "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.sh" "${SCRIPT_DIR}/ubios-ddns/on_boot.d/98-ubios-ddns.sh"
    sed -i 's#/etc/init.d/crond#/etc/init.d/cron#g' "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.sh"
    export DATA_DIR="/data"
fi

case "${MODEL}" in
    "UniFi Dream Machine Pro"|"UniFi Dream Machine"|"UniFi Dream Router"|"UniFi Dream Machine SE")
    echo "${MODEL} running firmware ${FIRMWARE_VER} detected, installing ubios-cert in ${DATA_DIR}..."
    ;;
    *)
    echo "Unsupported model: ${MODEL}"
    exit 1
    ;;
esac
echo

mkdir -p "${DATA_DIR}/ubios-ddns"
mv "${SCRIPT_DIR}/ubios-ddns" "${DATA_DIR}"
cd "${DATA_DIR}/ubios-ddns"
chmod 0755 ubios-ddns.sh on_boot.d/98-ubios-ddns.sh
echo "Deployed with success in ${DATA_DIR}/ubios-ddns"
