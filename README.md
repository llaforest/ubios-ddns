# Update DNS record using DNS API for Ubiquiti UbiOS

**TL;DR** jump to [Installation](#Installation)

## What it does

Spare you from manually updating 'A' records in your DNS provider when your external IP changes on your UDM.

This set of scripts is installed on devices with UbiOS, like the UniFi Dream Machine Pro (UDMP), and will

* check external IP address and compare it with the DNS 'A' record specified using DNS Provider API
* update the DNS 'A' record in case it is different than the external IP assigned by your ISP (Internet Service Provider)
* survive device reboots and firmware upgrades thanks to [boostchicken's udm-utilities](https://github.com/boostchicken/udm-utilities) using its `on_boot.d` extension.

This is valid as long as Ubiquiti does not change something in their config. Use at your own risk, you have been warned.

## Currently supported DNS API providers

Adjusting two variables in `ubios-ddns.env` should allow access to many of more than 120 providers from [acme.sh DNS API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi). Adjust

`````sh
API_URL="..."
KEY="..."
SECRET="..."
SSO="..."
`````

to your liking and feel free to add to this repo. Some APIs may require additional manual preparation.

## But why?

In private installations, the UDM(P) is given an FQDN for remote access and this record must point to the ever changing IP address provided by an ISP.

## What you need

* A UniFi Dream Machine (Pro),
* a registered domain where you have API access for udating 'A' records whenever the external IP changes.

## Inspired by - Sources and Credits

A huge "Thank You" goes to

* [boostchicken's udm-utilites](https://github.com/boostchicken/udm-utilities): the way to run stuff on UbiOS while surviving upgrades and reboots

## UniFi OS and Network Controller Versions

Confirmed to work on UniFi OS Version 1.11.4 and Network Version 7.0.23

## Installation

### Download the package

* `ssh` into your UDMP
* Download the archive to your home directory
* Unzip it
* [Make your adjustments](#make-your-adjustments) to `ubios-ddns.env`
* Deploy the package (Will adjust if udmp or udmse)

````sh
cd
curl -JLO https://github.com/llaforest/ubios-ddns/archive/refs/heads/main.zip
unzip ubios-ddns-main.zip
cd ubios-ddns-main
vi ubios-ddns/ubios-ddns.env
chmod 0755 deploy.sh
. deploy.sh
````

* You should be in the proper directory
* Verify one last time the content of .env file
* Run the script for the first time

````sh
./ubios-ddns.sh
````

### Make your adjustments

Adjust file `ubios-ddns.env` to your liking. You typically only need to touch environment variables `DOMAIN`, `NAME`, `KEY` and `SECRET`.

## First Run

Calling the script for the first time will

* setup up the trigger for persistence over reboot / firmware upgrades
* establish a cron job to take care about your DNS updates

## Behaviour after firmware upgrade / reboot

Here the script in `on_boot.d` will trigger execution of `sh /mnt/data/ubios-ddns/ubios-ddns.sh`, with a friendly delay of one minutes after boot.

## De-installation and de-registration

* If running on UDMSE or UDR, replace `/mnt/data` by `/data`
* Remove the cron file from `/etc/cron.d´
* Remove the boot trigger from `/mnt/data/on_boot.d/´

Then, you can delete the script directory. As always, be careful with `rm`.

````sh
cd /mnt/data/
rm -irf ./ubios-ddns
````
