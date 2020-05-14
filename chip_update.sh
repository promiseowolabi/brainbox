###################################
#           PART 1                #
###################################

# su -
# export hostname=chip01
# ssh-copy-id chip@chip01
 
cat >> /etc/sudoers << EOF
chip ALL=(ALL) NOPASSWD:ALL
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
 
 
###################################
#           PART 2                #
###################################

# su -

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
 
sudo apt update

sudo apt -y full-upgrade

sudo apt -y autoremove
 
sudo apt -y remove --purge linux-image-4.4.13-ntc-mlc

sudo apt -y --purge autoremove

sudo apt -y update

sudo apt -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
 
sudo add-apt-repository \
   "deb [arch=armhf] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
 
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker chip

sudo apt -y --purge autoremove
 
