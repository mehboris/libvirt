resource "libvirt_network" "net-internal" {
                    name      = "internal"
                    mode      = "nat"
                    domain    = "internal.local"
                    addresses = ["10.17.4.0/24"]
                    dhcp {
                        enabled = true
                    }
}
resource "libvirt_network" "net1" {
                    name      = "ext"
                    mode      = "nat"
                    domain    = "ext.local"
                    addresses = ["10.17.3.0/24"]
                    dhcp {
                        enabled = true
                    }
}
