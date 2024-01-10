#!/bin/bash

title() {
	echo -en "\t\033[0;93m#$1: \033[0m"
}

archtecture() {
	title 'Arquitecture'
	uname -srnvio
}

physical_cpu() {
	title 'Physical CPU'
	nproc
}

virtual_cpu() {
	title 'Virtual CPU'
	lscpu | grep '^CPU(s):' | awk '{print$2}'
}

memory_usage() {
	title 'Memory Usage'
	free -m | grep 'Mem:' | awk '{printf("%d/%dMB (%.2f%%)\n", $3, $2, $3/$2*100)}'
}

disk_usage() {
	title 'Disk Usage'
	df -h --total | grep 'total' | awk '{printf("%s/%s (%s)", $3, $2, $5)}'
}

cpu_load() {
	title 'CPU Load'
	mpstat | grep 'all' | awk '{printf("%.1f%%", 100 - $13)}'	
}

last_boot() {
	title 'Last Boot'
	who -b | grep 'boot' | awk '{print $3 " " $4}'
}

lvm_use() {
	title 'LVM Use'
	if [ $(lsblk -o TYPE | grep 'lvm' | wc -l) -eq 0 ]
	then
		echo -e '\033[0;91mno\033[0m'
	else
		echo -e '\033[0;92myes\033[0m'
	fi
}

connections() {
	title 'Connections TCP'
	ss -Hto state established | wc -l
}

user_log() {
	title 'User Log'
	users | wc -w
}

network() {
	title 'Network'
	echo -n "IP $(hostname -I)"
	echo "($(ip link | grep 'ether' | awk '{print $2}'))"
}

sudo() {
	title 'Sudo'
	echo "$(cat /var/log/sudo/sudo.log | grep 'COMMAND' | wc -l)"
}

broadcast() {
wall "$(archtecture)
$(physical_cpu)
$(virtual_cpu)
$(memory_usage)
$(disk_usage)
$(cpu_load)
$(last_boot)
$(lvm_use)
$(connections) ESTABLISHED
$(user_log)
$(network)
$(sudo) cmd"
}

await() {
	sleep $((1 * 60))
	$(broadcast)
	$(await)
}

$(await)
