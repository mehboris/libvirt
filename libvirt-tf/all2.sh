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
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" - y
  apt update -y
  apt install wget make curl unzip net-tools qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin qemu uml-utilities virt-manager git wget libguestfs-tools p7zip-full gnupg software-properties-common terraform -y
  /usr/bin/make init
  curl -s https://api.github.com/repos/dmacvicar/terraform-provider-libvirt/releases/latest \
    | grep browser_download_url \
    | grep linux_amd64.zip \
    | cut -d '"' -f 4 \
    | wget -i -
  unzip terraform-provider-libvirt_*_linux_amd64.zip
  rm -f terraform-provider-libvirt_*_linux_amd64.zip
  mkdir -p .terraform.d/plugins/
  mv terraform-provider-libvirt_* .terraform.d/plugins/terraform-provider-libvirt
  echo “security_driver = none” >>  /etc/libvirt/qemu.conf 
  systemctl restart libvirtd
  /usr/bin/make apply
  terraform output -json> output_ip.txt
  ip_debian=$(jq -r .ext_ip_debian.value output_ip.txt)
  output_gate_debian= $(/sbin/ifconfig | grep -i 'inet 10.17.3.1' -B1 |head -n 1| awk '{print $1}')
  gate=${output_gate_debian::-1}
  iptables -I FORWARD -o $gate -d  $ip_debian/32 -j ACCEPT
  iptables -t nat -I PREROUTING -p tcp --dport 9867 -j DNAT --to $ip_debian:80
  iptables -A FORWARD -o $gate -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i $gate -o $int -j ACCEPT
  iptables -A FORWARD -i $gate -o lo -j ACCEPT
}
func1
if [ "$?" = "1" ]; then
  echo " failed"
  exit 1
fi

