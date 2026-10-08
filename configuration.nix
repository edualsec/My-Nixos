{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.mangowm.nixosModules.mango
  ];

  # ====================================================================
  # Sistema, Nix y Rendimiento
  # ====================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "reboot=pci" "nowatchdog" ];

  powerManagement.cpuFreqGovernor = "performance";
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";

  # ====================================================================
  # Arranque y Discos
  # ====================================================================
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
    theme = "/etc/nixos/grubtheme";
  };

  fileSystems."/mnt/datos" = {
    device = "/dev/disk/by-uuid/e4a4f12b-c873-425a-b293-49a3d60d1b2c";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  services.gvfs.enable = true;

  # Soporte AppImage
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  # ====================================================================
  # Red y Conectividad
  # ====================================================================
  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  hardware.bluetooth.enable = true;

  # ====================================================================
  # Localización e Idioma
  # ====================================================================
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

  # ====================================================================
  # Gráficos, NVIDIA y Display Server
  # ====================================================================
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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

  # ====================================================================
  # Entorno de Ventanas y Portales
  # ====================================================================
  programs.mango.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd mango";
        user = "greeter";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-wlr 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config.common.default = [ "wlr" "gtk" ];
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };

  # ====================================================================
  # Audio, Impresión y Seguridad
  # ====================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  services.gnome.gnome-keyring.enable = true;

  # ====================================================================
  # Gaming y Virtualización
  # ====================================================================
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # ====================================================================
  # Fuentes, Shell y Paquetes Globales
  # ====================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  services.flatpak.enable = true;

  users.users."d3rhund" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "d3rhund";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "video" "input" ];
  };

  environment.systemPackages = with pkgs; [
    # Utilidades CLI
    wget
    git
    file
    wtype
    ghostty

    # Compresión y archivos
    file-roller
    unrar
    unzip
    gzip
    gnutar
    appimage-run

    # Sistema y Privilegios
    gparted
    brightnessctl
  ];

  system.stateVersion = "26.05";
}