{ config, pkgs, ... }:

{
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
  };

  # Incus API (cluster + remote management)
  networking.firewall.allowedTCPPorts = [
    8443
  ];

  # Required for Incus networking
  networking.bridge.br0 = {
    interfaces = [ ];
  };

  networking.useNetworkd = true;

  systemd.network.enable = true;
}
