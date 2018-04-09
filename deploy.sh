# System configuration
# Console connection (Linux), Networking, Access Point,
# Connect the CHIP to a Linux computer and setup a terminal session with Screen
# dmesg

screen /dev/ttyACM0

# Use the nmtui utility to connect to the wifi network for internet access, select the 
# TALKTALK-2883C4 and connect with password

nmtui
# nmcli device wifi connect TALKTALK-288-3C4 password *****

# Get IP address on the device

hostname -I

# Save $IPAdress and Shutdown and connect to 5v power source

shutdown -h now

# Storage Installation

fdisk /dev/sda
mkdir /media/data | mount /dev/sda1 /media/data

# Copy KaLite videos, Guttenberg and Wiki Zim files to /media/data

mkdir /media/data
# sudo cp /media/data/* /media/data/

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Upgrade the Debian Kernel

hostname itsybrain
apt-get update
apt-get upgrade
reboot -h now

# Install docker on CHIP

curl -sSL https://get.docker.com | sh

# # # # # # # # # # # # # # # # # # # #
#                                     #
#          Install Packages           #
#                                     #
# # # # # # # # # # # # # # # # # # # #

apt-get update
apt-get install dnsmasq
apt-get install python-m2crypto python-pkg-resources nginx python-psutil
apt-get install debconf-utils

# Access point configuration
# Install DNSMasq and configure the device to be able to join an access point and also act as one itself

touch /etc/dnsmasq.d/access_point.conf

echo "
#If you want dnsmasq to listen for DHCP and DNS requests only on
#specified interfaces (and the loopback) give the name of the
#interface (eg eth0) here.
#Repeat the line for more than one interface.
interface=wlan1
#Or you can specify which interface not to listen on
listen-address=1.1.1.1     # Explicitly specify the address to listen on
bind-interfaces      # Bind to the interface to make sure we aren't sending things elsewhere
server=8.8.8.8                   # Forward DNS requests to Google DNS
domain-needed        # Don't forward short names
bogus-priv                         # Never forward addresses in the non-routed address spaces.

#Uncomment this to enable the integrated DHCP server, you need
#to supply the range of addresses available for lease and optionally
#a lease time. If you have more than one network, you will need to
#repeat this for each network on which you want to supply DHCP >>
#service.
dhcp-range=1.1.1.10,1.1.1.40,1h

local=/ed.local/
expand-hosts
domain=ed.local
" >> /etc/dnsmasq.d/access_point.conf

# Setup Static IP for the access point 
# Create an IP file in network interfaces

touch /etc/network/interfaces

echo "# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
  
  source-directory /etc/network/interfaces.d
  
  auto wlan1
  
  iface wlan1 inet static
    address 1.1.1.1
    netmask 255.255.255.0
" >> /etc/network/interfaces

# Check AP IP address

ifup wlan1

# Restart the DHCP server 

/etc/init.d/dnsmasq restart

# We have just tested the IP configuration portion.
# Now we can configure the WiFi access point on wlan1.

touch /etc/hostapd.conf

echo "
interface=wlan1
driver=nl80211
ssid=brainbox
channel=1
ctrl_interface=/var/run/hostapd

auth_algs=3
max_num_sta=40
wpa=2
wpa_passphrase=brainbox
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
" >> /etc/hostapd.conf

# Start the Access Point (exit with Ctrl + C)

hostapd /etc/hostapd.conf

# Now we would like to configure CHIP to create the access point automatically on boot.
# We can setup a systemd service to do our bidding. We give the service a unique name, so it doesn't conflict with the systemV stuff in init.d:

touch /lib/systemd/system/hostapd-systemd.service

echo "
[Unit]
Description=hostapd service
Wants=network-manager.service
After=network-manager.service
Wants=module-init-tools.service
After=module-init-tools.service
ConditionPathExists=/etc/hostapd.conf

[Service]
ExecStart=/usr/sbin/hostapd /etc/hostapd.conf

[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/hostapd-systemd.service

# Disable the existing systemV script for booting hostapd:

update-rc.d hostapd disable

# Now we can setup the systemd service with these commands:

systemctl daemon-reload
systemctl enable hostapd-systemd

# Reboot or test with these commands:

systemctl start hostapd-systemd
systemctl status hostapd-systemd

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE  
iptables -A FORWARD -i wlan0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -A FORWARD -i wlan1 -o wlan0 -j ACCEPT  

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Edit the configuration file to allow ipv4 forwarding

nano /etc/sysctl.conf
remove the # from the beginning of the line containing net.ipv4.ip_forward=1

# Edit the startup file to allow NAT forwarding at reboot

nano /etc/rc.local and just above the line exit 0, add the following line:
iptables-restore < /etc/iptables.ipv4.nat 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

service hostapd start
service dnsmasq start 

# Get docker images from DockerHub (Kiwix)

docker pull promise/kiwix
docker pull promise/kiwix-books

docker run -d --restart always \
-v /media/data/kiwix-data:/kiwix-data \
-p 8075:8080 --name kiwix-wiki \
promise/kiwix

docker run -d --restart always \
-v /media/data/kiwix-data:/kiwix-data \
-p 8076:8080 --name gutenberg \
promise/kiwix-books

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                           #
#                 docker ps --no-trunc -aqf "status=exited" | xargs docker rm               #
#                                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Install NGINX on the SBC (CHIP)

# apt-get install nginx
mkdir /var/www/html/images

# Copy static webpage to new device

scp -r root@192.168.1.141:/var/www/html/* /var/www/html/

# Configure brainbox.io domain

echo "
127.0.0.1       chip01 brainbox
1.1.1.1           chip01 brainbox
" >> /etc/hosts

echo "
nameserver 127.0.0.1
" >> /etc/resolv.conf

# KA Lite Installation
# Install dependencies

# apt-get install debconf-utils

echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-upgrade       note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/user    string  root | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/init-instructions       note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/init    boolean true | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/manual-instructions     note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-storage-error-msg     note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/kalite-setup    string  from kalite.project.settings.raspberry_pi import * | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-clear boolean false | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items       boolean true | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-url   string  http://learningequality.org/downloads/ka-lite/0.16/content/khan_assessment.zip | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-tmp   string  /tmp | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-manual        note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-storage-error boolean false | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-url-notfound  note | debconf-set-selections
echo ka-lite-raspberry-pi    ka-lite/download-assessment-items-bundle        boolean false | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
export USER=root

# apt-get install python-m2crypto python-pkg-resources nginx python-psutil

# Fetch the latest .deb
wget https://learningequality.org/r/deb-pi-installer-0-16 --no-check-certificate --content-disposition

# Install the .deb
dpkg -i ka-lite-raspberry-pi_0.16.9-0ubuntu3_all.deb

# Link Static Kalite content in SD card to .kalite/content

ln -s /media/data/kalite/* ~/.kalite/content/

# Kalite restart script

touch kalite-run.sh
echo "
#!/bin/sh

export USER=root
kalite start --port=7007
" >> kalite-run.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Edit rc.local to boot up kalite with the right port 7007

nano /etc/rc.local
sh ~/kalite-run.sh
