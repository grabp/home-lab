{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];

  # Import ZFS pools automatically
  boot.zfs.extraPools = [
    "zpool"
  ];

  # Recommended ZFS tuning for hosts
  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "weekly";
    trim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];
}
