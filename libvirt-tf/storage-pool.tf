resource "libvirt_pool" "default2" {
  name = "default2"
  type = "dir"
  path = "/opt/cluster_storage2"
}
