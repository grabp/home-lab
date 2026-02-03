resource "incus_storage_pool" "default" {
  name   = "default"
  driver = "zfs"

  config = {
    source = "zpool/incus"
  }
}

