resource "incus_profile" "default" {
  name = "default"

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = "incusbr0"
      name    = "eth0"
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "default"
    }
  }
}

resource "incus_profile" "base_vm" {
  name = "base-vm"

  config = {
    "boot.autostart" = "true"

    # Optional sane defaults
    "limits.cpu"    = "2"
    "limits.memory" = "2GiB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "default"
    }
  }


  device {
    name = "eth0"
    type = "nic"
    properties = {
      name    = "eth0"
      network = "incusbr0"
    }
  }

}
