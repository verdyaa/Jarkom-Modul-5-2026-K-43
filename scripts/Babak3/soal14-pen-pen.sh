#!/bin/bash
PILOT_START="01:00"
PILOT_STOP="09:00"
PILOT_DAYS="Mon,Tue,Wed,Thu,Fri"
STAF_START="10:00"
STAF_STOP="16:00"

ip addr flush dev eth0
ip addr add 10.85.3.194/27 dev eth0
ip link set eth0 up
ip route replace default via 10.85.3.193
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

iptables -F INPUT
iptables -P INPUT ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

for ip in 10.85.4.66 10.85.4.67 10.85.4.68 10.85.3.130; do
  iptables -A INPUT -s "$ip" -p icmp --icmp-type echo-request -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
  iptables -A INPUT -s "$ip" -p tcp --dport 80 -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
  iptables -A INPUT -s "$ip" -p icmp --icmp-type echo-request -j DROP
  iptables -A INPUT -s "$ip" -p tcp --dport 80 -j DROP
done

for ip in 10.85.4.74 10.85.4.75; do
  iptables -A INPUT -s "$ip" -p icmp --icmp-type echo-request -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
  iptables -A INPUT -s "$ip" -p tcp --dport 80 -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
  iptables -A INPUT -s "$ip" -p icmp --icmp-type echo-request -j DROP
  iptables -A INPUT -s "$ip" -p tcp --dport 80 -j DROP
done

for ip in 10.85.4.51 10.85.4.50 10.85.4.102; do
  iptables -A INPUT -s "$ip" -p icmp --icmp-type echo-request -j DROP
  iptables -A INPUT -s "$ip" -p tcp --dport 80 -j DROP
done
