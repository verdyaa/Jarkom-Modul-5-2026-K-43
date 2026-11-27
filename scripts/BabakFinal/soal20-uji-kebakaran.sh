#!/bin/bash
NAME="$1"
iptables-save > "/root/${NAME}.rules"
iptables -F
iptables -t nat -F
ip route del default 2>/dev/null
iptables-restore < "/root/${NAME}.rules"
"/root/${NAME}.sh"
echo "RESTORE1 filter:$(iptables -S | wc -l) nat:$(iptables -t nat -S | wc -l) route:$(ip route | wc -l)"
iptables-restore < "/root/${NAME}.rules"
"/root/${NAME}.sh"
echo "RESTORE2 filter:$(iptables -S | wc -l) nat:$(iptables -t nat -S | wc -l) route:$(ip route | wc -l)"
ping -c 2 -W 2 8.8.8.8
