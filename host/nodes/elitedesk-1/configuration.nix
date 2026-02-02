{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # 1. Load hardware defaults by type
    ../../common/hardware/elitebook.nix

    # 2. Include the results of the hardware scan.
    ./hardware-configuration.nix

    # 2.1. Include necessary components for zfs storage
    ../../common/zfs-storage.nix

    # 3. Defaults for every NixOS system
    ../../../nixos-common/base

    # 4. Include default monitoring services
    ../../../nixos-common/monitoring

    # 5. Include incus service
    ../../common/services/incus.nix
  ];

  networking.hostId = "d90a56a6";
  networking.hostName = "elitebook-1";

  my.networking = {
    interface = "eno1";

    staticIPv4 = {
      enable = true;
      address = "10.0.0.150";
      gateway = "10.0.0.1";
    };
  };

  system.stateVersion = "25.11";
}
