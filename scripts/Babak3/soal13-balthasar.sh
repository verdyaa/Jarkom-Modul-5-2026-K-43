#!/bin/bash
iptables -F INPUT
iptables -P INPUT ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
for ip in 10.85.4.58 10.85.4.66 10.85.4.67 10.85.4.68 10.85.3.130; do
  iptables -A INPUT -p tcp -s "$ip" -m multiport --dports 5000,5001 -j ACCEPT
done
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -j REJECT --reject-with tcp-reset
