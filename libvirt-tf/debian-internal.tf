# Defining VM Volume
resource "libvirt_volume" "debian-internal-qcow2" {
  name = "debian11-internal.qcow2"
  pool = "default2" # List storage pools using virsh pool-list
  source = "../debian-internal.qcow2"
  #source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "debian11-internal" {
  name   = "debian-internal"
  memory = "4048"
  vcpu   = 4


network_interface {
    network_id     = libvirt_network.net-internal.id
    hostname       = "local"
    addresses      = ["10.17.4.223"]
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
  vars = {
    ssh_pub_key = file("~/.ssh/hyper_key.pub")
    }
}
resource "libvirt_cloudinit_disk" "commoninit-internal" {
  name = "commoninit-internal.iso"
  pool = "default2" # List storage pools using virsh pool-list
  user_data      = "${data.template_file.user_data-internal.rendered}"
}
# Output Server IP
output "ip_debian-internal" {
  value = "${libvirt_domain.debian11-internal.network_interface.0.addresses.0}"
}

module "debian2" {
  source = "../modules/vms"

  domain_name="debian-internal2"
  image_source="../debian-internal.qcow2"
  memory = 4048
  vcpu = 4
  network_id     = libvirt_network.net-internal.id
  hostname       = "local2"
  addresses      = ["10.17.4.200"]
  template_path = "${file("${path.module}/conf-debian-internal.cfg")}"
}

output "module_ip_debian"{

  value = module.debian2.ip
}