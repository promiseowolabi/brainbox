# su -
# export hostname=chip01
# ssh-copy-id chip@chip01
 
cat >> /etc/sudoers << EOF
$hostname ALL=(ALL) NOPASSWD:ALL
EOF

sed -i "s/chip/$hostname/" \
    /etc/hosts \
    /etc/hostname
    
hostname $hostname
hostname
 
nmcli device wifi connect "TALKTALK54297B" \
    password "E9QQD44M" \
    ifname wlan0
    
shutdown -h now
 
sed -i \
    "s/opensource.nextthing.co/chip.jfpossibilities.com/" \
    /etc/apt/sources.list
  
# Add this repository
wget -qO - https://kaplan2539.github.io/CHIP-Debian-Kernel/PUBLIC.KEY | sudo apt-key add -
echo "deb http://kaplan2539.github.io/CHIP-Debian-Kernel jessie main" | sudo tee --append /etc/apt/sources.list
sudo apt-get update
 
# Install the new kernel
sudo apt-get install linux-image-4.4.138-chip rtl8723bs-mp-driver-modules-4.4.138 chip-mali-modules-4.4.138

sed -i "s/jessie/stretch/" /etc/apt/sources.list

sed -i "/kaplan/d" /etc/apt/sources.list
sed -i "/chip/d" /etc/apt/sources.list
 
sudo apt-get update

sudo apt-get full-upgrade
