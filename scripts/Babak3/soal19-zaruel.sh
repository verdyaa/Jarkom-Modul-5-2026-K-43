#!/bin/bash
iptables -F INPUT
iptables -F OUTPUT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -s 10.85.4.83 -j DROP
iptables -A OUTPUT -d 10.85.4.83 -j DROP
