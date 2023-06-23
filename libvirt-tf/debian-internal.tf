
module "debian2" {
  source = "../modules/vms"

  domain_name   = "debian-internal2"
  image_source  = "../debian-internal.qcow2"
  memory        = 2048
  vcpu          = 2
  network_id    = libvirt_network.net-internal.id
  hostname      = "local2"
  addresses     = ["10.17.4.200"]
  template_path = file("${path.module}/conf-debian-internal.cfg")
}

output "module_ip_debian" {

  value = module.debian2.ip
}
