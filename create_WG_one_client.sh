#!/bin/bash

#Usage
#./create_one_client IP_last_number(10.0.0.X) UserName(Denny)


if [ -z $1 ] && [ -z $2 ];then
    echo "Please keyin the Client private IP address and client config name"
    echo "Example: X Denny"
    exit
fi

cp wg0.conf wg0.conf.backup
ipNum=$1
clientName=$2
#clientIP=10.0.0.6
clientIP=10.0.0.$1
#====================
serverIP=111.222.333.242:11154
serverPublicKey=UpvqUFPaIHtqhp2nPpDXZozN0EOwqB+2EJ26mDnB83I=
#====== need to modify part when changing server IP

generate_wg_server_client(){
    wg genkey | tee private_key | wg pubkey > public_key

    clientPrivateKey=$( cat ./private_key )
    clientPublicKey=$( cat ./public_key )

    #add Peer into server config file
    #echo -e "\n" >> wg0.conf
    echo "[Peer]" >> wg0.conf
    echo "#User ${ipNum}: $clientName" >> wg0.conf
    echo "PublicKey = $clientPublicKey" >> wg0.conf 
    echo "AllowedIPs = $clientIP/32" >> wg0.conf

    #add client config file
    echo "[Interface]" >> wg-${ipNum}-$clientName.conf
    echo "#User ${ipNum}: $clientName" >> wg-${ipNum}-$clientName.conf
    echo "PrivateKey = $clientPrivateKey" >> wg-${ipNum}-$clientName.conf
    echo "Address = $clientIP/24" >> wg-${ipNum}-$clientName.conf
    echo "DNS = 8.8.8.8" >> wg-${ipNum}-$clientName.conf
    echo "MTU = 1420" >> wg-${ipNum}-$clientName.conf

    echo -e "\n" >> wg-${ipNum}-$clientName.conf
    echo "[Peer]" >> wg-${ipNum}-$clientName.conf
    echo "PublicKey = $serverPublicKey" >> wg-${ipNum}-$clientName.conf
    echo "Endpoint = $serverIP" >> wg-${ipNum}-$clientName.conf
    echo "AllowedIPs = 0.0.0.0/0, ::0/0" >> wg-${ipNum}-$clientName.conf
    echo "PersistentKeepalive = 25" >> wg-${ipNum}-$clientName.conf
}

generate_wg_server_client
rm -r private_key public_key

