output "ips" {
  value = libvirt_domain.vm.network_interface.*.addresses
}
#values(libvirt_domain.vm.network_interface).*.addresses.0
