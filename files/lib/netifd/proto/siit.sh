#!/bin/sh
# siit.sh - SIIT ip4/ip6
#
# Copyright (c) 2014 Nils Schneider
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_siit_setup() {
	local cfg="$1"
	local iface="$2"
	local link="siit-$cfg"

	local rule ip6prefix ipaddr ip6addr cfgstr
	json_get_vars ip6prefix ipaddr ip6addr

	echo add $link > /proc/net/nat46/control

	cfgstr="local.style RFC6052 local.v6 $ip6prefix remote.style RFC6052 remote.v6 $ip6prefix"

	echo config $link $cfgstr > /proc/net/nat46/control

	proto_init_update "$link" 1

	[ -n "$ipaddr" ]  && proto_add_ipv4_address "$ipaddr" "255.255.255.255"
	[ -n "$ip6addr" ] && proto_add_ipv6_address "$ip6addr" "128"
	
	proto_send_update "$cfg"
}

proto_siit_teardown() {
	local cfg="$1"
	local link="siit-$cfg"

	echo del $link > /proc/net/nat46/control
}

proto_siit_init_config() {
	no_device=1
	available=1

	proto_config_add_string "ip6prefix"
	proto_config_add_string "ipaddr"
	proto_config_add_string "ip6addr:ip6addr"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol siit
}
