terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "~> 0.2"
    }
  }
}

provider "incus" {
  # Default: connects to local Incus via Unix socket
}
