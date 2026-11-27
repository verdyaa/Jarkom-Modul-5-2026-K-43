#!/bin/bash
iptables -F FORWARD
iptables -P FORWARD ACCEPT
iptables -A FORWARD -s 10.85.4.83 -j DROP
iptables -A FORWARD -d 10.85.4.83 -j DROP
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -s 10.85.4.56/29 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -j DROP
iptables -I INPUT 1 -s 10.85.4.83 -j DROP
iptables -I OUTPUT 1 -d 10.85.4.83 -j DROP
