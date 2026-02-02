{ config, pkgs, ... }:

{
  #### Incus daemon
  virtualisation.incus = {
    enable = true;
    ui = {
      enable = true;
    };
  };

  #### Firewall requirements (per NixOS wiki)
  networking.nftables.enable = true;

  #### Allow Incus API access (local + cluster)
  networking.firewall.allowedTCPPorts = [
    8443 # Incus REST / cluster API
  ];

  #### Allow Incus-managed bridges to work
  ##
  ## The default incusbr0 created by `incus admin init`
  ## uses DHCP + NAT. Without this, instances get no IP.
  networking.firewall.trustedInterfaces = [
    "incusbr0"
  ];

  #### User access (non-root incus CLI)
  users.groups.incus-admin = { };

  users.users.ops.extraGroups = [
    "incus-admin"
  ];

  #### Kernel / sysctl requirements
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  #### Required packages for debugging / ops
  environment.systemPackages = with pkgs; [
    incus
  ];
}
