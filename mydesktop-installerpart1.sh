

# installation  freebsd 14 + KDE et divers
# version 1.04 26.07.2025 text install guide on USB /isi


# boot usb et install : keyboard sf, network ip static, user administrateur,password

####################################################
# installation guide on usb /isi
# mkdir /media/usb
# mount /dev/da0s2a /media/usb
# cd /media/usb/isi & cp * /media

# install cups

####################################################
# reboot et login administrateur and su -
# one line at once
####################################################


####################################################
#   EVERYTHING MUST BE INSTALLED IN QUARTERLY PKG

pkg update
y

freebsd-update fetch install


####################################################
#                  BASE CONFIG
#  
####################################################

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sh /etc/rc.d/sshd restart

####################################################
# some tips and silent boot (some times...)
#
####################################################

echo 'boot_mute="YES"' >>/boot/loader.conf
echo 'splash_changer_enable="YES"' >>/etc/rc.conf 

sed -i '' 's/run_rc_script ${_rc_elem} ${_boot}/run_rc_script ${_rc_elem} ${_boot} > \/dev\/null/g' /etc/rc
sysrc rc_startmsgs=NO

####################################################
# set real resolution at EFI boot (console)
# do not forget to change at your real screen resolution
#
####################################################

echo 'efi_max_resolution="1920x1200"' >>/boot/loader.conf
echo 'kern.vt.fb.default_mode="1920x1200"' >>/boot/loader.conf




####################################################
# set boot time out
#
####################################################

sysrc -f /boot/loader.conf autoboot_delay=3

####################################################
# some tips to enhance speed of desktop
#
####################################################

echo "kern.sched.preempt_thresh=224 " >>/etc/sysctl.conf
echo "kern.ipc.shm_allow_removed=1" >>/etc/sysctl.conf

echo 'tmpfs_load="YES"' >>/boot/loader.conf
echo 'aio_load="YES"' >>/boot/loader.conf
sysctl net.local.stream.recvspace=65536
sysctl net.local.stream.sendspace=65536


####################################################
# set time out
#
####################################################


cat > /etc/ntp.conf <<EOF
pool 0.ch.pool.ntp.org iburst
EOF


####################################################
# some tips to manage temp on board
#
####################################################

# for Intel
echo 'coretemp_load="YES"' >>/boot/loader.conf

# for AMD
# echo 'amdtemp_load="YES"' >>/boot/loader.conf


####################################################
# need enable Linux for Nvidia driver
#
####################################################

sysrc linux_enable="YES"


####################################################
# configuration 
# install htop and some utilities
####################################################

pkg install -y htop neofetch doas unzip libzip smartmontools avahi dbus wget
pkg install -y python3 bashtop system-config-printer cups xfburn xpdf 


####################################################
# configuration powermanagement
# 
####################################################

sysrc smartd_enable="YES"
cd /usr/local/etc
cp smartd.conf.sample smartd.conf
service smartd start
cd


####################################################
# install sudo for final management
# 
####################################################

pkg install -y sudo


####################################################
# use visudo to remove # at %wheel ALL=(ALL:ALL ) ALL 
# echo to sudo file Don't work
####################################################

printf "%s " "Press enter to continue"
read ans
visudo


####################################################
# network configuration 
# examples : list network:  arp -a nmap -sP x.x.x.x/24
#                           nmap -sP 192.168.254.0/24
# install nmap
####################################################

pkg install -y nmap


####################################################
# Samba server 
# 
####################################################

pkg install -y samba416

mkdir /home/share
chmod 777 /home/share
cat >>/usr/local/etc/smb4.conf <<EOF

 # create new

[global]
    unix charset = UTF-8
    workgroup = HOMELAB
    server string = FreeBSD
    # network range you allow to access
    interfaces = 127.0.0.0/8 192.168.254.0/24
    bind interfaces only = yes
    map to guest = bad user

# any Share name you like
[Share]
    # specify shared directory
    path = /home/share
    # allow writing
    writable = yes
    # allow guest user (nobody)
    guest ok = yes
    # looks all as guest user
    guest only = yes
    # set permission [777] when file created
    force create mode = 777
    # set permission [777] when folder created
    force directory mode = 777

EOF

sysrc samba_server_enable="YES"

service samba_server start 


####################################################
# install french class 
#   do not use cat
####################################################


echo "  " >> /etc/login.conf
echo 'french|French Users Accounts:\' >> /etc/login.conf
echo '     :charset=UTF-8:\' >> /etc/login.conf
echo '     :lang=fr_FR.UTF-8:\' >> /etc/login.conf
echo '      lc_all=fr_FR:\' >> /etc/login.conf
echo '      lc_collate=fr_FR:\' >> /etc/login.conf
echo '      lc_ctype=fr_FR:\' >> /etc/login.conf
echo '      lc_messages=fr_FR:\' >> /etc/login.conf
echo '     :tc=default:' >> /etc/login.conf
echo '   ' >> /etc/login.conf

cap_mkdb /etc/login.conf
echo 'defaultclass=french' > /etc/adduser.conf


####################################################
# use adduser -C to set default values
# or setup in adduser.conf
# when user added on install, change Language to French
# 
####################################################

pw usermod administrateur -G wheel,operator,video -L french

pw usermod root -L french


####################################################
# install xorg before any video drivers
#
####################################################

sysrc dbus_enable="YES"
sysrc avahi_enable="YES"
echo  "proc       proc       procfs       rw       0       0" >>/etc/fstab
echo  "fdesc     /dev/fd      fdescfs       rw       0       0" >>/etc/fstab

pkg install -y xorg avahi dbus

####################################################
#
# only for ps/2 mouse  only if you do not select it at install 

# echo  'moused_enable="YES"' >> /etc/rc.conf


####################################################
# now set swiss french keyboard on X11 config
#
####################################################

cat >>/usr/local/etc/X11/xorg.conf.d/20keyboards.conf <<EOF
Section     "InputClass"
           Identifier     "All Keyboards"
           MatchIsKeyboard    "yes"
           Option     "XkbLayout" "ch"
           Option     "XkbVariant" "fr"
EndSection

EOF

####################################################
# set ctrl-alt-backspace to kill X11 when it freeze
#
####################################################

cat >> /usr/local/etc/X11/xorg.conf.d/flags.conf <<EOF

Section "ServerFlags"
                 Option "DontZap" "false"
EndSection

Section   "InputClass"
              Identifier       "Keyboard Defaults"
              MatchIsKeyboard        "yes"
              Option                 "XkbOptions" "terminate:ctrl_alt_bksp" 

EndSection 

EOF


####################################################
# now reboot needed to set video driver
#
####################################################

# reboot

