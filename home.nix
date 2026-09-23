{ config, pkgs, inputs, ... }:
{
  home.username = "d3rhund";
  home.homeDirectory = "/home/d3rhund";
  home.stateVersion = "25.05";

  ######################################################################
  ## Paquetes personales
  ######################################################################
  home.packages = with pkgs; [
    fastfetch
    discord
    spotify
    vscodium
    gh
    cowsay
    gparted
    btop
    starship
    nwg-look
    cmatrix
    inxi
    cava
    quickshell
    onlyoffice-desktopeditors
    obsidian
    nemo
    qemu-utils
    protontricks
    libnotify
    sox
    keepassxc
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Herramientas de compilación
    gcc
    gnumake
    pkg-config
    python3
    rustup
    
    # Librerías para Wayland, EGL/GLES y PNG
    wayland
    wayland-protocols
    libGL
    libpng
  ];

  ######################################################################
  ## Acciones de Nemo
  ######################################################################
  home.file.".local/share/nemo/actions/vmdk-to-qcow2.nemo_action".text = ''
    [Nemo Action]
    Name=Convertir a QCOW2
    Comment=Convierte esta imagen VMDK al formato QCOW2
    Exec=${pkgs.bash}/bin/bash -c 'for f in %F; do ${pkgs.qemu-utils}/bin/qemu-img convert -f vmdk -O qcow2 "$f" "''${f%.*}.qcow2"; done'
    Icon-Name=drive-harddisk
    Selection=any
    Extensions=vmdk;VMDK;
    Quote=custom
  '';

  ######################################################################
  ## Cursor
  ######################################################################
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 6;                   
    gtk.enable = true;            
    x11.enable = true;            
  };

  ######################################################################
  ## Shell
  ######################################################################
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"
      fastfetch
    '';
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      edit-h = "sudo nano /etc/nixos/home.nix";
      edit-c = "sudo nano /etc/nixos/configuration.nix";
      nix-clear = "sudo nix-collect-garbage -d";
      edit-m = "sudo nano /home/$USER/.config/mango/config.conf";
    };
  };

  ######################################################################
  ## Home Manager
  ######################################################################
  programs.home-manager.enable = true;
}
