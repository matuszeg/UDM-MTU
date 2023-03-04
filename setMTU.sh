#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "1 argument required, $# provided. Argument should be desired MTU"
    exit 1
fi

if [[ "$1" -le 0 ]]; then
    echo "first argument must be greater than 0. First argument is the desired MTU value"
    exit 1
fi

ppp_two_lines=$(head -n 2 /etc/ppp/peers/ppp0)
splitArray=($ppp_two_lines)
splitArrayLength=${#splitArray[@]}
splitArrayLastIndex="$(($splitArrayLength-1))"
targetInterface="${splitArray[$splitArrayLastIndex]}"

MSS="$(($1-40))"
ETH_MTU="$(($1+8))"

echo "Target eth Interface is $targetInterface"
echo "PPP (pppoe) MTU will be set to $1"
echo "MSS will be set to $MSS"
echo "$targetInterface Interface MTU will be $ETH_MTU"

sed -i 's/ 1492/ $1/g' /etc/ppp/peers/ppp0
iptables -t mangle -D UBIOS_FORWARD_TCPMSS 1
iptables -t mangle -D UBIOS_FORWARD_TCPMSS 1
iptables -t mangle -A UBIOS_FORWARD_TCPMSS -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1404
ifconfig $targetInterface mtu $ETH_MTU
ifconfig $targetInterface down && ifconfig $targetInterface up
killall pppd

