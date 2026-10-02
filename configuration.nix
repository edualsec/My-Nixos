{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.mangowm.nixosModules.mango
  ];

  services.gvfs.enable = true;

  # Habilitar Zsh
  programs.zsh.enable = true;

  ####################################################################
  ## Boot / kernel
  ####################################################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub.theme = "/etc/nixos/grubtheme";
  programs.nix-ld.enable = true;

  ####################################################################
  ## Optimización de apagado / reinicio
  ####################################################################
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  systemd.user.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  ####################################################################
  ## CPU boost y Swap
  ####################################################################
  powerManagement.cpuFreqGovernor = "performance";
  zramSwap.enable = true;
  boot.kernelParams = [
    "reboot=pci"
    "nowatchdog"
  ];
  zramSwap.memoryPercent = 50;
  
  ####################################################################
  ## Red
  ####################################################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  ####################################################################
  ## Nix / Flakes
  ####################################################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  ####################################################################
  ## Discos extra
  ####################################################################
  fileSystems."/mnt/datos" = {
    device = "/dev/disk/by-uuid/e4a4f12b-c873-425a-b293-49a3d60d1b2c";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
 
  ####################################################################
  ## Fuentes
  ####################################################################  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  ####################################################################
  ## Flatpak
  ####################################################################
  services.flatpak.enable = true;

  ####################################################################
  ## Portales y MIME
  ####################################################################
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-wlr 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config.common.default = [ "wlr" "gtk" ];
  };

  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "inode/directory" = "nemo.desktop";
  };

  ####################################################################
  ## Seguridad, PAM y Servicios de Noctalia
  ####################################################################
  security.pam.services.swaylock = {};
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  ####################################################################
  ## Gráficos / Gaming
  ####################################################################
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.steam-hardware.enable = true;

  ####################################################################
  ## Appimage
  ####################################################################
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  ####################################################################
  ## Localización
  ####################################################################
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  ####################################################################
  ## Entorno gráfico: Display Manager y MangoWM
  ####################################################################
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Habilitar soporte de MangoWM
  programs.mango.enable = true;

  # Gestor de inicio de sesión con tuigreet configurado a Mango
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd mango";
        user = "greeter";
      };
    };
  };

  ####################################################################
  ## GPU: NVIDIA y Wayland
  ####################################################################
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    branch = "legacy_580";
    open = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  ####################################################################
  ## Steam
  ####################################################################
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  ####################################################################
  ## Audio: Pipewire
  ####################################################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ####################################################################
  ## Impresión
  ####################################################################
  services.printing.enable = true;

  ####################################################################
  ## Virtualización
  ####################################################################
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;
  
  ####################################################################
  ## Usuarios
  ####################################################################
  users.users."d3rhund" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "d3rhund";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "video" "input" ];
  };

  ####################################################################
  ## Programas y paquetes del sistema
  ####################################################################

  environment.systemPackages = with pkgs; [
    wget
    file-roller
    wtype
    ghostty
    unrar
    unzip
    gzip
    gnutar
    appimage-run
    git

    # Herramientas de sistema con privilegios
    gparted
    brightnessctl
  ];

  system.stateVersion = "26.05";
}