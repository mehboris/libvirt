resource "libvirt_network" "net-internal" {
                    name      = "internal"
                    mode      = "none"
                    domain    = "internal.local"
                    addresses = ["10.17.4.0/24"]
                    dhcp {
                        enabled = true
                    }
}
