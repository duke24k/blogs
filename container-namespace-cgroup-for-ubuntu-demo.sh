#!/bin/bash -x 
# Description : Demo scripts for ubuntu
# Writer : jaeminj@gmail.com

# Refer the follwoings. 
# https://www.kernel.org/doc/Documentation/cgroups/cpusets.txt
# http://lxc.sourceforge.net/old/index.php/about/kernel-namespaces/network/configuration/
# http://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/
# https://doc.opensuse.org/documentation/html/openSUSE_121/opensuse-tuning/cha.tuning.cgroups.html
# http://www.axeman.in/blog/2014/12/09/build-your-own-lxc-contain-it-yourself/
# http://www.linux-kongress.org/2010/slides/seyfried-cgroups-linux-kongress-2010-presentation.pdf

if [ -f global.conf.sh ] ; then 
source global.conf.sh
else
UUID=$(cat /proc/sys/kernel/random/uuid)
cat > global.conf.sh <<EOF
container_network_type=router
#contraier_network_type=bridge
UUID=$UUID
EOF
fi


mkRootfs()
{
	mkdir -p rootfs

	debootstrap sid rootfs
	chroot rootfs 
	apt-get -y install stress
}

EnableByRoute()
{

	ip netns add $UUID
	ip link add veth0 type veth peer name veth1
	ip link set veth1 netns $UUID
	ip netns exec $UUID ifconfig veth1 10.1.1.1/24 up
	ip netns exec $UUID ip link set lo up
	ip netns exec $UUID ip route add default via 10.1.1.2

	ifconfig veth0 10.1.1.2/24 up

	sysctl net.ipv4.ip_forward=1
	sysctl net.ipv4.conf.eth0.proxy_arp=1
	sysctl net.ipv4.conf.veth0.proxy_arp=1

	iptables -t nat -I POSTROUTING -s 10.1.1.1 ! -d 10.1.1.1 -j MASQUERADE


	ip netns exec $UUID ping -c 3 localhost
	ip netns exec $UUID ping -c 3 10.1.1.2
	ip netns exec $UUID ping -c 3 8.8.8.8
	#ip netns exec $UUID tc qdisc add dev veth1 root netem loss 30%

}




mountGuest()
{
	cd rootfs
	mkdir -p proc dev/pts sys/fs/cgroup
	mount -o bind /proc proc
	mount -o bind /dev dev
	mount -o bind /dev/pts dev/pts
	mount -o bind /sys sys
	ip netns exec $UUID chroot .  /bin/bash
}

umountGuest()
{
	mount |grep rootfs | awk '{print $3}' \
	| sort -r | while read f ; do umount  $f ; done 
}


setCgroupCpuset()
{
#mount -t cgroup sys/fs/cgroup
	mkdir -p /sys/fs/cgroup/cpuset/$UUID
	pushd  /sys/fs/cgroup/cpuset/$UUID
	echo Cpu $1
	echo $1 > cpuset.cpus
	echo 0 > cpuset.mems
	echo $PPID > tasks
	popd

}

setCgroupMemory()
{

	#mount -t cgroup sys/fs/cgroup
	mkdir -p /sys/fs/cgroup/memory/$UUID

	pushd  /sys/fs/cgroup/memory/$UUID
	cat memory.usage_in_bytes
	echo cat memory.limit_in_bytes
	cat memory.limit_in_bytes
	echo $PPID > tasks
	popd


	pushd  /sys/fs/cgroup/memory/$UUID
	echo $1 > memory.limit_in_bytes
	cat memory.limit_in_bytes
	popd
}


DisableByRoute()
{

	ip link delete veth0

	if [ "$(ip netns pids $UUID)" != "" ]  ; then 
		ip netns pids $UUID | xargs kill
	fi

	ip netns del $UUID
	iptables -t nat -I POSTROUTING -s 10.1.1.1 ! -d 10.1.1.1 -j MASQUERADE
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
	ip link set veth1 netns $UUID
	ip netns exec $UUID ifconfig veth1 192.168.0.102/24 up
	ip netns exec $UUID ifconfig lo up


}


DisableByBridge()
{

	ip link delete veth0 
	ip link delete veth1
	ifconfig br0 down 
	brctl delbr br0 

	ip netns pids | xargs kill
	ip netns del $UUID
}


case "$1" in
mkrootfs)
	mkRootfs
;;
ifup)
	EnableByRoute
;;
ifdown)
	DisableByRoute
;;
mount)
	mountGuest
;;
status)
	cat /proc/self/cgroup
	ip link show 
;;
umount)
	umountGuest
;;
cpu0)
	setCgroupCpuset 0
;;
mem0)
	setCgroupMemory 128M
;;
boot)
	
	EnableByRoute
	setCgroupCpuset 0
	setCgroupMemory 128M
	mountGuest
;;
shutdown)
	
	umountGuest
	DisableByRoute
;;
*)

cat <<EOF
$0 mkrootfs
$0 boot
	$0 ifup
	$0 cpu0
	$0 mem0
	$0 mount
cat /proc/self/cgroup
ip link show 
stress -c 2 --vm 1 --vm-bytes 260M --vm-hang 0 

open host terminal 
top -p \$(pidof stress|sed -e 's/ /,/g')


exit
$0 shutdown 
	$0 umount
	$0 ifdown
EOF
;;

esac
