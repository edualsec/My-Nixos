# /etc/nixos/noctalia.nix
{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    swaylock
    swayidle
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}