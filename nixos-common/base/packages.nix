{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    age
    sops
  ];
}
