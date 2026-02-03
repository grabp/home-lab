resource "incus_instance" "nixos_test" {
  name = "nixos-test"
  type = "virtual-machine"

  image = "images:nixos/unstable"

  profiles = ["base-vm"]

  config = {
    # NixOS images are not Secure Boot signed
    "security.secureboot" = "false"

    "cloud-init.user-data" = <<-EOF
      #cloud-config
      hostname: nixos-test

      ssh_pwauth: false
      disable_root: false

      users:
        - name: root
          ssh-authorized-keys:
            - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY7yfcUgzDRtAxxRe07DcXV8CpljRjYQWERAUETEE+E grabowskip@koksownik

      runcmd:
        # Fetch declarative configuration
        - nix-shell -p git --run "git clone https://github.com/grabp/home-lab.git /etc/nixos"

        # Apply the VM configuration
        - nixos-rebuild switch --flake /etc/nixos#nixos-test
    EOF
  }
}

