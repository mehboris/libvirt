terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}
provider "libvirt" {
  ## Configuration options
  uri = "qemu:///system"
  #alias = "server2"
  #uri   = "qemu+ssh://root@192.168.100.10/system"
}
resource "libvirt_volume" "vm-qcow2" {
  name = "${var.domain_name}.qcow2"
  pool = "default2" # List storage pools using virsh pool-list
  source = var.image_source
  #source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "vm" {
  name   = var.domain_name
  memory = var.memory
  vcpu   = var.vcpu

dynamic network_interface {
    for_each = var.network_interfaces
iterator = item
    content{
        network_id     = item.value.id
        hostname       = item.value.hostname
        addresses      = item.value.ip
        mac            = item.value.mac
        wait_for_lease = true
   }
}

  disk {

    volume_id = "${libvirt_volume.vm-qcow2.id}"
  }
cloudinit = "${libvirt_cloudinit_disk.vm-commoninit.id}"
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
  template = var.template_path
    vars = {
    ssh_pub_key = file("~/.ssh/hyper_key.pub")
    }
}
resource "libvirt_cloudinit_disk" "vm-commoninit" {
  name = "${var.domain_name}-commoninit.iso"
  pool = "default2" # List storage pools using virsh pool-list
  user_data      = "${data.template_file.user_data1.rendered}"
}
