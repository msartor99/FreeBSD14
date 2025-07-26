#!/bin/sh

#############################################
# install VirtualBOX 7.0 second part ( and printer manager )
#
####################################################

chown root:vboxusers /dev/vboxnetctl
chmod 0660 /dev/vboxnetctl

echo 'own     vboxnetctl root:vboxusers' >> /etc/devfs.conf
echo 'perm     vboxnetctl 0660' >> /etc/devfs.conf

echo '[system=10]' >> /etc/devfs.rules
echo "add path 'usb/*' mode 0660 group operator" >> /etc/devfs.rules
echo "add path 'video*' mode 0660 group operator" >> /etc/devfs.rules


####################################################
# and install printer manager
#
# and printer cups
####################################################


echo "add path 'unlpt*' mode 0660 group cups" >> /etc/devfs.rules
echo "add path 'unlpt*' mode 0660 group cups" >> /etc/devfs.rules
echo "add path 'lpt*' mode 0660 group cups" >> /etc/devfs.rules

pkg install -y cups gutenprint cups-filters 
sysrc cupsd_enable="YES"

sysrc devfs_system_ruleset="system"
service devfs restart


####################################################
#  install webcam manager
#
####################################################


pkg install -y webcamd v4l-utils
sysrc -v webcamd_enable=YES

####################################################
# install xrdp (need reboot)
#
####################################################

pkg install -y xrdp
sysrc  xrdp_enable="YES"
sysrc xrdp_sesman_enable="YES"


####################################################
# enable wdm on xrdp by vi
# vi /usr/local/etc/xrdp/startwm.sh
#	#enable
#	startxfce4
#	mate-session
#
#	or use echo 
####################################################


mv /usr/local/etc/xrdp/startwm.sh /usr/local/etc/xrdp/startwm.sh.backup
echo 'export LANG=fr_FR.UTF-8' >> /usr/local/etc/xrdp/startwm.sh
echo 'exec startplasma-x11' >> /usr/local/etc/xrdp/startwm.sh
chmod 555  /usr/local/etc/xrdp/startwm.sh


####################################################
# end of base configuration, now enable sddm and reboot
#
####################################################

sysrc sddm_enable="YES"
sysrc sddm_lang="ch_FR"


####################################################
#   set latest to repo but kde plasma some tips to re install
#
# 
####################################################
echo ####################################################
echo #   set latest to repo but kde plasma some tips to re install
echo #   if you dont want to set lastest, stop script
echo #   now with ctrl-c
echo ####################################################


printf "%s " "Press enter to continue"
read ans

# service sddm stop

# sysrc sddm_enable=no

freebsd-update fetch install

pkg update
mkdir -p /usr/local/etc/pkg/repos
echo 'FreeBSD: { url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest" }' > /usr/local/etc/pkg/repos/FreeBSD.conf

pkg update -f

pkg upgrade -y

##################################################
# update to 14.3 latest remove some utilities, reinstall it


pkg install -y kate konsole ark remmina dolphin kvantum

pkg install -y  audacious-plugins-qt5 audacious-qt5 digikam elisa en-hunspell
pkg install -y  freedesktop-sound-theme k3b kmix libva-utils libvdpau-va-gl 
pkg install -y  konversation merkuro  signal-desktop vdpauinfo




echo ####################################################
echo # USE  KDE macos theme SONOMATIC 2.0 by phob1an, and install accretion start image,
echo #  and whiteSur Dark for icon and util and kvantum
echo ####################################################

printf "%s " "Press enter to continue"
read ans

####################################################
####################################################
####################################################
####################################################
#  finito
# 
reboot


