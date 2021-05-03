#!/bin/sh

. /lib/netifd/netifd-proto.sh;
. /lib/functions/network.sh;

login_campus_interface() {
	local ip interface username password
	
	interface=$1
	network_get_device device $interface
	
	username=$(uci -q get network.$interface.username)
	password=$(uci -q get network.$interface.password)
	
	result=$(php-cli /usr/lib/wocampus/campus.php $username $password $device 2>&1)
	result_code=$?
	
	if [ "$result_code" -ne "0" ]; then
		$(uci -q set network.$interface.should_login=false & uci commit)
		
		proto_notify_error "$interface" "$result"
		logger -t "$interface" "$result"
	fi
}

# check interfaces that use wocampus proto
get_campus_interfaces() {
	interfaces=""
	
	for ifobj in `ubus list network.interface.\*`; do
		interface="${ifobj##network.interface.}"
		
		network_get_protocol proto $interface
		if [ "$proto" != "wocampus" ]; then
			continue
		fi
		
		network_get_ipaddr ip $interface
		if [ -z "$ip" ]; then
			continue
		fi
		
		interfaces="$interfaces $interface"
	done
	echo $interfaces
}

hello=$(php-cli -r "echo 'hello wocampus';")
logger -t "wocampus" "$hello"

while [ true ]; do
	sleep 20
	
	for interface in `get_campus_interfaces`; do
		network_get_device device $interface
		if [ -z "$device" ]; then
			continue
		fi
		
		# check if network need to login
		redirect_url=$(curl -I -s --show-error --connect-timeout 1 "http://connect.rom.miui.com/generate_204" --interface $device --dns-interface $device | grep -i "location" | awk '{print $2}')
		if [ -z "$redirect_url" ]; then
			continue
		fi
		
		# check if should login
		should_login=$(uci -q get network.$interface.should_login)
		if [ "$should_login" == "false" ]; then
			continue
		fi
		
		login_campus_interface "$interface"
	done
done
