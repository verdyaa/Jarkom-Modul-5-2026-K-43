#!/bin/sh
ip2int(){ _o=$IFS; IFS=.; set -- $1; IFS=$_o; echo $(( ($1<<24)+($2<<16)+($3<<8)+$4 )); }
int2ip(){ echo "$(( ($1>>24)&255 )).$(( ($1>>16)&255 )).$(( ($1>>8)&255 )).$(( $1&255 ))"; }
[ "$(id -u)" = 0 ] || { echo "Harus dijalankan sebagai root"; exit 1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables belum ada, mencoba memasang..."; (apt-get update -qq && apt-get install -y -qq iptables) >/dev/null 2>&1 || apk add -q iptables >/dev/null 2>&1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables gagal dipasang. Pasang manual dulu."; exit 1; }
ADDRS=$(ip -4 -o addr show | while read _ dev fam addr _; do [ "$dev" = lo ] && continue; echo "$dev $addr"; done)
DEFDEV=$(ip route show default | sed -n "s/.* dev \([^ ]*\).*/\1/p" | head -1)
[ -n "$DEFDEV" ] || { echo "Default route belum ada. Selesaikan soal 2 sampai 4 dulu."; exit 1; }
INTIP=$(echo "$ADDRS" | while read dev addr; do [ "$dev" != "$DEFDEV" ] && { echo "${addr%/*}"; break; }; done)
P=${P:-${INTIP%.*.*}}
case "$(hostname)" in
  *[Mm]isato*) NODE=misato ;;
  *[Gg]endo*)  NODE=gendo ;;
  *) [ "$FORCE" = misato ] && NODE=misato; [ "$FORCE" = gendo ] && NODE=gendo
     [ -n "$NODE" ] || { echo "Jalankan di Misato dan di Gendo."; exit 1; } ;;
esac
if [ "$NODE" = misato ]; then
  CAGEIF=; while read dev addr; do [ "$dev" != "$DEFDEV" ] && { CAGEIF=$dev; CADDR=$addr; break; }; done <<EOT
$ADDRS
EOT
  [ -n "$CAGEIF" ] || { echo "Interface Cage tidak terdeteksi."; exit 1; }
  len=${CADDR#*/}; ipn=$(ip2int ${CADDR%/*}); mask=$(( (0xFFFFFFFF << (32-len)) & 0xFFFFFFFF ))
  CAGE=$(int2ip $(( ipn & mask )))/$len
  UPIF=$DEFDEV
else
  WAN=$DEFDEV
  CAGE=${CAGE:-$P.4.64/29}
  ip route show | grep -q "^$CAGE " || echo "Subnet tidak terdeteksi"
fi
if [ "$NODE" = misato ]; then
  iptables -t nat -D POSTROUTING -s $CAGE ! -d $P.0.0/16 -o $UPIF -j SNAT --to-source 172.31.99.1 2>/dev/null
  iptables -t nat -A POSTROUTING -s $CAGE ! -d $P.0.0/16 -o $UPIF -j SNAT --to-source 172.31.99.1
else
  iptables -t nat -D POSTROUTING -s $CAGE -o $WAN -j RETURN 2>/dev/null
  iptables -t nat -I POSTROUTING 1 -s $CAGE -o $WAN -j RETURN
fi
echo "Script sudah dirusak"
