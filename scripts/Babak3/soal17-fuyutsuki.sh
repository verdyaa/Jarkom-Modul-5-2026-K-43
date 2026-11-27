#!/bin/bash
iptables -t nat -F PREROUTING
iptables -t nat -A PREROUTING -s 10.85.4.58 -d 10.85.4.82 -p tcp -j DNAT --to-destination 10.85.3.194
