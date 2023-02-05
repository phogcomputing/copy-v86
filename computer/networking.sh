rmmod ne2k-pci && modprobe ne2k-pci
rm /var/lib/dhcpcd/enp0s5.lease
/usr/sbin/dhcpcd -w4 enp0s5
