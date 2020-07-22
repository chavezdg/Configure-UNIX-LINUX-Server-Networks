#!/bin/bash

# This script is used to configure a Ubuntu 16 or 18 server.
# Created by davidc

# Function to ensure that user is root or using sudo.
function rootCreds()
{
# Variables for root or sudo authorization.
userIs=$( id -g )
userPass=0

if [[ "$userIs" == "$userPass" ]]; then
 echo
else
 echo -e "\t\t\tYOU MUST BE LOGGED IN AS ROOT!"; echo
 exit 0
fi

}

# Function to choose ubuntu version number.
function ubuntuVersion()
{
# Variable that gives Ubuntu version number.
verNum=$( grep "VERSION_ID" /etc/os-release| cut -c 13-14 )

if [[ "$verNum" == "16" ]]; then
 echo "THIS SCRIPT HAS BEEN TESTED TO WORK WITH UBUNTU 16 VERSION:"
 echo "16.04.2 LTS (Xenial Xerus)"
 echo
 ubuntu16Setup
elif [[ "$verNum" == "18" ]]; then
 echo "THIS SCRIPT HAS BEEN TESTED TO WORK WITH UBUNTU 18 VERSION:"
 echo "18.04.1 LTS (Bionic Beaver)"
 echo
 ubuntu18Setup
else 
 echo "THIS IS NOT UBUNTU VERSION 16 OR 18. DEFAULTING TO UBUNTU 16 SCRIPT"
 echo
 ubuntu16Setup
fi
}

# Ubuntu version 16 setup function.
function ubuntu16Setup()
{
setHost
setNetwork
saveSettings16
}

# Ubuntu version 18 setup function.
function ubuntu18Setup()
{
setHost
setNetwork
saveSettings18
}

# Function to setup hostname.
function setHost()
{
echo -e "\t\t\tENTER HOSTNAME: \c"
read hostnameVar
}

# Function to setup network settings.
function setNetwork()
{
echo -e "\t\t\tENTER NETWORK INTERFACE: \c"
read netInterfaceVar
echo -e "\t\t\tENTER IP ADDRESS: \c"
read ipVar
echo -e "\t\t\tENTER NETMASK: \c"
read netmaskVar
echo -e "\t\t\tENTER GATEWAY: \c"
read gatewayVar
}

# Function to setup SSH key.
function addSSHKey()
{
# Variable containing the SSH key:
key="<SSH KEY>"

mkdir -p /root/.ssh
echo "ssh-rsa $key dedicatedServer@hostSite.com" >> /root/.ssh/authorized_keys
chmod -R og-rwx /root/.ssh
}

# Function to convert subnetmask to cidr.
function netmask2cidr()
{
case $netmaskVar in
 "255.255.255.255") echo 32
 ;;
 "255.255.255.254") echo 31
 ;;
 "255.255.255.252") echo 30
 ;;
 "255.255.255.248") echo 29
 ;;
 "255.255.255.240") echo 28
 ;;
 "255.255.255.224") echo 27
 ;;
 "255.255.255.192") echo 26
 ;;
 "255.255.255.128") echo 25
 ;;
 "255.255.255.0") echo 24
 ;;
 "255.255.254.0") echo 23
 ;;
 "255.255.252.0") echo 22
 ;;
 "255.255.248.0") echo 21
 ;;
 "255.255.240.0") echo 20
 ;;
 "255.255.224.0") echo 19
 ;;
 "255.255.192.0") echo 18
 ;;
 "255.255.128.0") echo 17
 ;;
 "255.255.0.0") echo 16
 ;;
 "255.254.0.0") echo 15
 ;;
 "255.252.0.0") echo 14
 ;;
 "255.248.0.0") echo 13
 ;;
 "255.240.0.0") echo 12
 ;;
 "255.224.0.0") echo 11
 ;;
 "255.192.0.0") echo 10
 ;;
 "255.128.0.0") echo 9
 ;;
 "255.0.0.0") echo 8
 ;;
 "254.0.0.0") echo 7
 ;;
 "252.0.0.0") echo 6
 ;;
 "248.0.0.0") echo 5
 ;;
 "240.0.0.0") echo 4
 ;;
 "224.0.0.0") echo 3
 ;;
 "192.0.0.0") echo 2
 ;;
 "128.0.0.0") echo 1
 ;;
 "0.0.0.0") echo 0
 ;;
 *) echo 0
 ;;
esac
}

# Function to save all settings or disregard in ubuntu version 16.
function saveSettings16()
{
echo -e "\t\t\tSAVE SETTINGS? [y/n]: \c"
read reply
 if [[ "$reply" == [yY] ]]; then
  echo -e "\n\t\t\tSAVING SETTINGS IN:"
  echo -e "\t\t\t/etc/hostname"; sleep 1
  cat /dev/null > /etc/hostname
  echo "$hostnameVar" > /etc/hostname
  echo -e "\t\t\t/etc/hosts"; sleep 1
  echo "127.0.1.1 $hostnameVar" >> /etc/hosts
  echo -e "\t\t\t/etc/network/interfaces"; sleep 1
  echo "" >> /etc/network/interfaces
  echo "# Primary network interface" >> /etc/network/interfaces
  echo "auto $netInterfaceVar" >> /etc/network/interfaces
  echo "iface $netInterfaceVar inet static" >> /etc/network/interfaces
  echo "address $ipVar" >> /etc/network/interfaces
  echo "netmask $netmaskVar" >> /etc/network/interfaces
  echo "gateway $gatewayVar" >> /etc/network/interfaces
  echo "dns-nameservers 8.8.8.8" >> /etc/network/interfaces
  echo -e "\t\t\t/root/.ssh/authorized_keys"; sleep 1
  addSSHKey
  echo -e "\n\t\t\tREBOOTING SERVER"; sleep 2; reboot
 else
  echo -e "\n\t\t\tNOT SAVING CONFIGURATION. EXITING TO SHELL."; echo
 fi
}

# Function to save all settings or disregard in ubuntu version 18.
function saveSettings18()
{
echo -e "\t\t\tSAVE SETTINGS? [y/n]: \c"
read reply
 if [[ "$reply" == [yY] ]]; then
  echo -e "\n\t\t\tSAVING SETTINGS IN:"
  echo -e "\t\t\t/etc/hostname"; sleep 1
  cat /dev/null > /etc/hostname
  echo "$hostnameVar" > /etc/hostname
  echo -e "\t\t\t/etc/hosts"; sleep 1
  sed -i "1 a 127.0.1.1\tlocalhost.localdomain\t$hostnameVar" /etc/hosts
  echo -e "\t\t\tSETTING PRESERVE_HOSTNAME PARAMETER FROM FALSE TO TRUE IN /etc/cloud/cloud.cfg"
  sed -i "s/preserve_hostname: false/preserve_hostname: true/g" /etc/cloud/cloud.cfg
  echo -e "\n\t\t\t/etc/netplan/*.yaml"; sleep 1
  sed -in '/ethernets/,$d' /etc/netplan/*.yaml
  echo " ethernets:" >>/etc/netplan/*.yaml
  echo "  $netInterfaceVar:" >>/etc/netplan/*.yaml
  echo "   addresses: [$ipVar/$(netmask2cidr)] " >>/etc/netplan/*.yaml
  echo "   gateway4: $gatewayVar" >>/etc/netplan/*.yaml
  echo "   nameservers:" >>/etc/netplan/*.yaml
  echo "    addresses: [8.8.8.8]" >>/etc/netplan/*.yaml
  echo "   dhcp4: no" >>/etc/netplan/*.yaml
  echo " version: 2" >>/etc/netplan/*.yaml
  netplan apply
  echo -e "\t\t\t/root/.ssh/authorized_keys"; sleep 1
  addSSHKey
  echo -e "\n\t\t\tREBOOTING SERVER"; sleep 2; reboot
 else
  echo -e "\n\t\t\tNOT SAVING CONFIGURATION. EXITING TO SHELL."; echo
 fi
}

clear
echo -e "\n\t\t\tIMH UBUNTU 16 OR 18 SETUP"

rootCreds
ubuntuVersion

