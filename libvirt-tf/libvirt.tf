# Defining VM Volume
resource "libvirt_volume" "centos7-qcow2" {
  name = "centos7.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "centos7" {
  name   = "centos7"
  memory = "2048"
  vcpu   = 2


network_interface {
    network_id     = libvirt_network.net1.id
    hostname       = "master"
    addresses      = ["10.17.3.3"]
    mac            = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }
  disk {

    volume_id = "${libvirt_volume.centos7-qcow2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}


# Output Server IP
output "ip-cetos" {
  value = "${libvirt_domain.centos7.network_interface.0.addresses.0}"
}
