#!/bin/sh
if [ "$FORCE" != 1 ]; then case "$(hostname)" in *[Ss]higeru*) ;; *) echo "Script ini hanya untuk Shigeru."; exit 1;; esac; fi
ip2int(){ _o=$IFS; IFS=.; set -- $1; IFS=$_o; echo $(( ($1<<24)+($2<<16)+($3<<8)+$4 )); }
int2ip(){ echo "$(( ($1>>24)&255 )).$(( ($1>>16)&255 )).$(( ($1>>8)&255 )).$(( $1&255 ))"; }
[ "$(id -u)" = 0 ] || { echo "Harus dijalankan sebagai root"; exit 1; }
ADDRS=$(ip -4 -o addr show | while read _ dev fam addr _; do [ "$dev" = lo ] && continue; echo "$dev $addr"; done)
DEFDEV=$(ip route show default | sed -n "s/.* dev \([^ ]*\).*/\1/p" | head -1)
if ip rule show | grep -q "iif .* lookup 100"; then echo "Script sudah dijalankan sebelumnya"; exit 1; fi
LANIF=; L30=; LANIP=
while read dev addr; do
  [ -z "$dev" ] && continue
  if [ "${addr#*/}" = 30 ]; then L30="$L30 $dev:${addr%/*}"; else LANIF=$dev; LANIP=${addr%/*}; fi
done <<EOT
$ADDRS
EOT
UPIF=$DEFDEV; UPIP=; MKIF=; MKIP=
for e in $L30; do d=${e%%:*}; i=${e#*:}; if [ "$d" = "$UPIF" ]; then UPIP=$i; else MKIF=$d; MKIP=$i; fi; done
if [ -z "$LANIF" ] || [ -z "$UPIP" ] || [ -z "$MKIF" ]; then
  echo "Topologi Shigeru belum terdeteksi. Selesaikan soal 2 dan 3 dulu (IP semua interface dan default route ke Gendo)."; exit 1; fi
MKGW=$(int2ip $(( $(ip2int $MKIP) ^ 3 )))
P=${P:-${LANIP%.*.*}}
DOGMA=${DOGMA:-$P.4.72/29}
echo 0 > /proc/sys/net/ipv4/ip_forward
ip route replace default via $MKGW dev $MKIF
ip route del blackhole $DOGMA 2>/dev/null
ip route add blackhole $DOGMA
ip route flush table 100 2>/dev/null
ip route add unreachable default table 100
ip rule del iif $LANIF lookup 100 priority 90 2>/dev/null
ip rule add iif $LANIF lookup 100 priority 90
echo "Script sudah dirusak"
