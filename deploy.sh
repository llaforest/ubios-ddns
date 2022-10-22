#!/bin/sh
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case "$(ubnt-device-info model || true)" in
  "UniFi Dream Machine Pro"|"UniFi Dream Machine")
    echo "UDM/Pro detected, installing ddns in /mnt/data..."
    DATA_DIR="/mnt/data"
    ;;
  "UniFi Dream Router"|"UniFi Dream Machine SE")
    echo "UDR/UDMSE detected, installing ddns in /data..."
    sed -i 's#/mnt/data#/data#g' "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.env" "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.sh" "${SCRIPT_DIR}/ubios-ddns/on_boot.d/98-ubios-ddns.sh"
    sed -i 's#/etc/init.d/crond#/etc/init.d/cron#g' "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.env" "${SCRIPT_DIR}/ubios-ddns/ubios-ddns.sh"
    DATA_DIR="/data"
    ;;
  *)
    echo "Unsupported model: $(ubnt-device-info model)" 1>&2
    exit 1
    ;;
esac
echo

mkdir -p "${DATA_DIR}/ubios-ddns"
mv "${SCRIPT_DIR}/ubios-ddns" "${DATA_DIR}"
cd "${DATA_DIR}/ubios-ddns"
chmod 0755 ubios-ddns.sh on_boot.d/98-ubios-ddns.sh
rm -irf ${SCRIPT_DIR}/../ubios-ddns-main*
