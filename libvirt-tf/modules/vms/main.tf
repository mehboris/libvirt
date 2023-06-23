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
    content{
        network_id     = var.network_interfaces["id"]
        hostname       = var.network_interfaces["hostname"]
        addresses      = var.network_interfaces["ip"]
        mac            = var.network_interfaces["mac"]
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
