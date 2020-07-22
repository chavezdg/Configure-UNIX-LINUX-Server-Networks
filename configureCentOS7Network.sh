#!/bin/bash

scriptName="Configure CentOS 7 Network" 
# Created by davidc

note="This script is to configure networking on Centos 7\n
      Works with genX server."

hostsFile="/etc/hosts"
networkFile="/etc/sysconfig/network-scripts/ifcfg-eno2"

function applysshKey(){
# Variable containing the SSH key:
key="<KEY STRING GOES HERE>"

 mkdir -p /root/.ssh
 echo "ssh-rsa $key dedicatedServer@hostSite.com" >> /root/.ssh/authorized_keys
 chmod -R og-rwx /root/.ssh
}

clear
echo "$scriptName"
echo -e "$note"
echo ""
read -p "HOSTNAME: " dediHostname
read -p "IP ADDRESS: " dediIP
read -p "SUBNET: " dediSubnet
read -p "GATEWAY: " dediGateway
read -p "APPLY SETTINGS? [y/n]: " applySettings

if [[ "$applySettings" == "y" ]]; then
 echo "APPLYING HOSTNAME SETTINGS IN: $hostsFile"; sleep 1
 hostnamectl set-hostname $dediHostname
 echo "$dediIP  ${dediHostname}.hostSite.com $dediHostname" >>$hostsFile
 echo "SAVING NETWORKING SETTINGS IN: $networkFile"; sleep 1
 echo "IPADDR=$dediIP" >> $networkFile
 echo "NETMASK=$dediSubnet" >> $networkFile
 echo "GATEWAY=$dediGateway" >> $networkFile
 echo "APPLYING HOST SSH KEY"; sleep 1
 applysshKey
 echo "REBOOTING SERVER"; sleep 2
 reboot
else
 echo "NOT SAVING SETTINGS"; sleep 1; echo ""; exit 0
fi

