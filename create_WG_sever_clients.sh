#!/bin/bash

#====== need to modify information when you create new config file
severConfigName=wg0
severPort=51825
serverIP=111.222.333.444:$severPort
clientList="client-1 client-2 client-3 client-4 etc..."
#======

wg genkey | tee sever_private_key | wg pubkey > sever_public_key
severPrivateKey=$( cat ./sever_private_key )
severPublicKey=$( cat ./sever_public_key )

echo "[Interface]" > ${severConfigName}.conf
echo "PrivateKey = $severPrivateKey" >> ${severConfigName}.conf
echo "Address = 10.0.0.1/24" >> ${severConfigName}.conf
echo "PostUp   = iptables -A FORWARD -i $severConfigName -j ACCEPT; iptables -A FORWARD -o $severConfigName -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> ${severConfigName}.conf
echo "PostDown = iptables -D FORWARD -i $severConfigName -j ACCEPT; iptables -D FORWARD -o $severConfigName -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >> ${severConfigName}.conf
echo "ListenPort = $severPort" >> ${severConfigName}.conf
echo "DNS = 8.8.8.8" >> ${severConfigName}.conf
echo "MTU = 1420" >> ${severConfigName}.conf
echo -e "\n"  >> ${severConfigName}.conf

generate_wg_server_client(){
    #${1}= severConfigName, ${2}=IP_Last_Number
    wg genkey | tee client_private_key | wg pubkey > client_public_key

    clientPrivateKey=$( cat ./client_private_key )
    clientPublicKey=$( cat ./client_public_key )

    #add Peer into server config file
    #echo -e "\n" >> ${1}.conf
    echo "[Peer]" >> ${1}.conf
    echo "#User ${ipNum}: $clientName" >> ${1}.conf
    echo "PublicKey = $clientPublicKey" >> ${1}.conf
    echo "AllowedIPs = 10.0.0.${ipNumber}/32" >> ${1}.conf

    #add client config file
    echo "[Interface]" > ${2}.conf
    echo "#User ${ipNum}: $clientName" >> ${2}.conf
    echo "PrivateKey = $clientPrivateKey" >> ${2}.conf
    echo "Address = 10.0.0.${ipNumber}/24" >> ${2}.conf
    echo "DNS = 8.8.8.8" >> ${2}.conf
    echo "MTU = 1420" >> ${2}.conf

    echo -e "\n" >> ${2}.conf
    echo "[Peer]" >> ${2}.conf
    echo "PublicKey = $severPublicKey" >> ${2}.conf
    echo "Endpoint = $serverIP" >> ${2}.conf
    echo "AllowedIPs = 0.0.0.0/0, ::0/0" >> ${2}.conf
    echo "PersistentKeepalive = 25" >> ${2}.conf
}

ipNumber=2
for clientName in $clientList ;do
    generate_wg_server_client $severConfigName $clientName-$ipNumber
    ipNumber=$(( $ipNumber + 1 ))
done
rm -r sever_private_key sever_public_key client_private_key client_public_key
