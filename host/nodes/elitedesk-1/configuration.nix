{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    # Defaults for every NixOS system
    ../../../nix-common

    # Host machine specific commons
    ../../common/base.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "elitebook-1";

  environment.systemPackages = with pkgs; [
    neovim
  ];

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
