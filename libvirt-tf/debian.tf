# Defining VM Volume
resource "libvirt_volume" "debian-qcow2" {
  name = "debian11.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "debian11" {
  name   = "debian"
  memory = "4048"
  vcpu   = 4


network_interface {
    network_id     = libvirt_network.net1.id
    hostname       = "master"
    addresses      = ["10.17.3.4"]
    mac            = "AA:BB:CC:11:33:22"
    wait_for_lease = true
  }
  disk {

    volume_id = "${libvirt_volume.debian-qcow2.id}"
  }
cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"
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
data "template_file" "user_data1" {
  template = "${file("${path.module}/conf-debian.cfg")}"
}
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data      = "${data.template_file.user_data1.rendered}"
}
# Output Server IP
output "ip2" {
  value = "${libvirt_domain.debian11.network_interface.0.addresses.0}"
}
