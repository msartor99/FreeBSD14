#!/bin/sh

####################################################
####################################################
####################################################
# PART TWO
#
####################################################



####################################################
# install graphic card driver
# select only one for your graphic card
####################################################

####################################################
# basic check install for BIOS boot system

# how to see type of graphic adapter

pciconf -lv | grep -B4 "VGA"

# how to see boot method

sysctl machdep.bootmethod

####################################################
# for Nvidia old Quadro NO K* use version 390
# for Nvidia old Quadro K* use version 470
# for Quadro M-P-RTX use version 550 (or latest)
# but try last version and remove if not good
####################################################

# pkg install -y nvidia-driver-390 nvidia-xconfig nvidia-settings

# pkg install -y nvidia-driver-470 nvidia-xconfig nvidia-settings

pkg install -y nvidia-driver nvidia-xconfig nvidia-settings


sysrc kld_list+=nvidia-modeset
kldload nvidia-modeset
nvidia-xconfig




####################################################
# sound set to DisplayPort first DP port
# 
####################################################

# pkg install -y pulseaudio
sysrc sound_load="YES"
sysrc  snd_hda_load="YES"
sysctl hw.snd.default_unit=3



####################################################
# install USB auto mount support
#
####################################################


pkg install -y fusefs-ntfs fusefs-ext2 fusefs-hfsfuse
sysrc kld_list+=fusefs
sysrc kld_list+=ext2fs
kldload fusefs
kldload ext2fs
echo "vfs.usermount=1" >> /etc/sysctl.conf


####################################################
# set devfs local rules
# yes we need it for all version
#
####################################################

cat >>/etc/devfs.rules <<EOF

[localrules=5]
add path 'da*' mode 0660 group operator
add path 'cd*' mode 0660 group operator
add path 'uscanner*' mode 0660 group operator
add path 'xpt*' mode 660 group operator
add path 'pass*' mode 660 group operator
add path 'md*' mode 0660 group operator
add path 'msdosfs/*' mode 0660 group operator
add path 'ext2fs/*' mode 0660 group operator
add path 'ntfs/*' mode 0660 group operator
add path 'usb/*' mode 0660 group operator

EOF

sysrc devfs_system_ruleset=localrules
service devfs restart


####################################################
# install display manager
#
####################################################

pkg install -y sddm


####################################################
# optional sddm customization, use Winscp before 
# to copy config files
# on /media directory
# if media is not created   :   mkdir /media
#
####################################################


cd /usr/local/share/sddm/themes
mkdir nasa
cp ./maldives/* ./nasa/
cd nasa
cp /media/Main.qml .
cp /media/metadata.desktop .
cp /media/nasa2560login.jpg .
rm background.jpg
mv nasa2560login.jpg background.jpg

cat > /usr/local/etc/sddm.conf <<EOF
[Theme]
# Current theme name
Current=nasa
[General]
background=background.png
displayFont="Montserrat"
EOF

cd 

####################################################
# change image on boot menu 
# images are from windows files copied by Winscp
####################################################


cp -r /media/freebsd-brand-rev.png /boot/images
cp -r /media/freebsd-logo-rev.png  /boot/images

echo 'splash="/boot/images/nasa1920.png"' >>/boot/loader.conf
cp -r /media/nasa1920.png  /boot/images

cd

####################################################
# install kde 6 plasma
#
####################################################

pkg install -y plasma6-plasma kate konsole ark remmina dolphin kvantum

pkg install -y -g "plasma6-*"
pkg install -y -g "kf6-*"


####################################################
# now install base apps
#
####################################################

pkg install -y firefox
pkg install -y vlc 

####################################################
# now install extended apps
#
####################################################

pkg install -y chromium foreign-cdm

pkg install -y thunderbird

pkg install -y multimedia/mpv 


####################################################
# now install extra apps
#
####################################################

pkg install -y  gimp libreoffice


####################################################
# now install extra fonts
#
####################################################

pkg install -y \
  cantarell-fonts \
  droid-fonts-ttf \
  inconsolata-ttf \
  noto-basic \
  noto-emoji \
  roboto-fonts-ttf \
  ubuntu-font \
  webfonts

pkg install -y terminus-font terminus-ttf


####################################################
# install virtualbox 7.0
# 22.4.2025 NEW version dont forget hald_enable 
# 11.06.2025 Freebsd 14.3 release block vboxdrv load, do not install vb on 14.3
# 15.7.2025 now ok, but need reboot before vboxdrv config
#
####################################################

pkg install -y virtualbox-ose-70

kldload vboxdrv
echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'vboxnet_load="YES"' >> /boot/loader.conf
sysrc vboxnet_enable="YES"

pw groupmod vboxusers -m root

pw groupmod vboxusers -m administrateur

#############################################
# 15.7.2025 Virtualbox
# need reboot now and
# execute chown after the reboot 
#
####################################################

reboot

