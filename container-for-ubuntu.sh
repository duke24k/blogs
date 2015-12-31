#!/bin/bash

# Refer : 
# http://lxc.sourceforge.net/old/index.php/about/kernel-namespaces/network/configuration/
# http://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/
# https://doc.opensuse.org/documentation/html/openSUSE_121/opensuse-tuning/cha.tuning.cgroups.html

mkRootfs()
{
mkdir -p rootfs

debootstrap sid rootfs
chroot rootfs 
apt-get -y install stress
exit
}

EnableByRoute()
{

ip netns add my1stNetns
ip link add veth0 type veth peer name veth1
ip link set veth1 netns my1stNetns
ip netns exec my1stNetns ifconfig veth1 10.1.1.1/24 up
ip netns exec my1stNetns ip link set lo up
ip netns exec my1stNetns ip route add default via 10.1.1.0
ifconfig veth0 10.1.1.2/24 up
route add-host 10.1.1.1 dev veth0

sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.eth0.proxy_arp=1
sysctl net.ipv4.conf.veth0.proxy_arp=1

iptables -t nat -A POSTROUTING -o veth0 -j  MASQUERADE

ip netns exec my1stNetns ping -c 3 localhost
ip netns exec my1stNetns ping -c 3 10.1.1.2
ip netns exec my1stNetns ping -c 3 google.com
#ip netns exec my1stNetns ping google.com
#ip netns exec my1stNetns /bin/bash
#ip netns exec my1stNetns tc qdisc add dev veth1 root netem loss 30%

}




mountGuest()
{
cd rootfs
mkdir -p proc dev/pts sys/fs/cgroup
mount -o bind /proc proc
mount -o bind /dev dev
mount -o bind /dev/pts dev/pts
mount -o bind /sys sys
chroot .  /bin/bash
}

umountGuest()
{
exit
mount |grep rootfs | awk '{print $3}' | sort -r | while read f ; do umount  $f ; done 
}


setCgroup()
{
mount -t cgroup sys/fs/cgroup
mkdir /sys/fs/cgroup/cpuset/my1stCgroup
cd /sys/fs/cgroup/cpuset/my1stCgroup
echo 0 > cpuset.cpus
echo 0 > cpuset.mems
echo num_of_pid > tasks
}

DisableByRoute()
{

ip link delete veth1
ip netns pids | xargs kill
ip netns del my1stNetns
# iptables -t nat -D POSTROUTING -s 10.1.1.0/24 -d 0.0.0.0/0 -j MASQUERADE
iptables -t nat -D POSTROUTING -o veth0 -j  MASQUERADE
}


EnableByBridge()
{

ip link add type veth
ifconfig veth0 up
brctl addbr br0
ifconfig br0 192.168.0.1/24 up
brctl addif br0 eth0
ifconig eth0 0.0.0.0
brctl addif br0 veth0
ip link set veth1 netns my1stNetns
ip netns exec my1stNetns ifconfig veth1 192.168.0.102/24 up
ip netns exec my1stNetns ifconfig lo up


}


DisableByBridge()
{

ip link delete veth0 
ip link delete veth1
ifconfig br0 down 
brctl delbr br0 

ip netns pids | xargs kill
ip netns del my1stNetns
}


case "$1" in
mkrootfs)
mkRootfs
;;
add)
	EnableByRoute
;;
del)
	DisableByRoute
;;
mount)
mountGuest
;;
umount)
umountGuest
;;
setCgroup)
setCgroup
;;
*)

cat <<EOF
$0 mkrootfs
$0 add
$0 mount
$0 unmount
$0 cgroup
$0 del
EOF
;;
esac

