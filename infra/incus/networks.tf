resource "incus_network" "default" {
  name = "incusbr0"

  config = {
    "ipv4.address" = "10.0.100.1/24"
    "ipv4.nat"     = "true"
    "ipv4.dhcp"    = "true"

    "ipv6.address" = "none"
  }
}

