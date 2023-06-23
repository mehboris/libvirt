#!/usr/bin/env bash

set -Eeuo pipefail

# Define variables
readonly dir="$(dirname "$0")" 

# Usage or Help message
usage() {
  cat <<EOF >&2
Usage: $(basename "$0") id_host_interface(ens0 or br0)
EOF
  exit 1
}

# Parse options
int=$1
while getopts h?v:id OPT; do
  case "${OPT}" in
    h|\?)
        usage
        exit 0 ;;
   v| --verbose) set -x ;;
  esac
done
if [ $# -lt 1 ]; then
  usage
fi

func1(){
	echo "You entered interface: "
	echo $int
	curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
  apt update -y
  apt install wget make curl unzip net-tools qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin qemu uml-utilities virt-manager git wget libguestfs-tools p7zip-full gnupg software-properties-common terraform -y
  /usr/bin/make init
  curl -s https://api.github.com/repos/dmacvicar/terraform-provider-libvirt/releases/latest \
    | grep browser_download_url \
    | grep linux_amd64.zip \
    | cut -d '"' -f 4 \
    | wget -i -
  mkdir -p .terraform.d/plugins/
  unzip -o terraform-provider-libvirt_*_linux_amd64.zip -d .terraform.d/plugins/
  rm -f terraform-provider-libvirt_*_linux_amd64.zip
  if grep -q "security_driver = \"none\"" /etc/libvirt/qemu.conf 
     then echo "selinux already disabled"; 
  else sed -i '1s/^/security_driver = "none"\n/' /etc/libvirt/qemu.conf 
  fi
  systemctl restart libvirtd
  if [[ -f "/root/.ssh/hyper_key" ]]
     then echo "ssh_key already exist"
     else ssh-keygen -q -t rsa -N '' -f ~/.ssh/hyper_key <<<y >/dev/null 2>&1
  fi
  if [[ -f "../debian-internal.qcow2" ]] 
     then echo "image already downloaded"
     else wget -O ../debian-internal.qcow2 https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2
  fi 
  /usr/bin/make apply
  terraform output -json> output_ip.txt
  ip_debian=$(jq -r .ext_ip_debian.value output_ip.txt)
  gate=`/sbin/ifconfig | grep -i 'inet 10.17.3.1' -B1 |head -n 1| awk '{print $1}'|sed 's/.$//'`
  iptables -I FORWARD -o $gate -d  $ip_debian/32 -j ACCEPT
  iptables -t nat -I PREROUTING -p tcp --dport 9867 -j DNAT --to $ip_debian:80
  iptables -A FORWARD -o $gate -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i $gate -o $int -j ACCEPT
  iptables -A FORWARD -i $gate -o lo -j ACCEPT
  ssh -o "StrictHostKeyChecking no" -t debian@$ip_debian "sudo systemctl restart nginx"
}
func1
if [ "$?" = "1" ]; then
  echo " failed"
  exit 1
fi

