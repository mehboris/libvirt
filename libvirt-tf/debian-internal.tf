# Defining VM Volume
resource "libvirt_volume" "debian-internal-qcow2" {
  name = "debian11-internal.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "debian11-internal" {
  name   = "debian-internal"
  memory = "4048"
  vcpu   = 4


network_interface {
    network_id     = libvirt_network.net1.id
    hostname       = "master"
    addresses      = ["10.17.3.5"]
    mac            = "AA:BB:CC:11:33:33"
    wait_for_lease = true
  }
network_interface {
    network_id     = libvirt_network.net-internal.id
    hostname       = "local"
    addresses      = ["10.17.4.3"]
    mac            = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }

  disk {

    volume_id = "${libvirt_volume.debian-internal-qcow2.id}"
  }
cloudinit = "${libvirt_cloudinit_disk.commoninit-internal.id}"
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
data "template_file" "user_data-internal" {
  template = "${file("${path.module}/conf-debian-internal.cfg")}"
}
resource "libvirt_cloudinit_disk" "commoninit-internal" {
  name = "commoninit-internal.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data      = "${data.template_file.user_data-internal.rendered}"
}
# Output Server IP
output "ip-internal" {
  value = "${libvirt_domain.debian11-internal.network_interface.0.addresses}"
}