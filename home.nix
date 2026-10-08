{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "d3rhund";
  home.homeDirectory = "/home/d3rhund";
  home.stateVersion = "26.05";

  # ====================================================================
  # Variables y Rutas de Entorno
  # ====================================================================
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # ====================================================================
  # Paquetes de Usuario
  # ====================================================================
  home.packages = with pkgs; [
    # Entorno y Flakes externos
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    rofi
    slurp
    nwg-look
    libnotify
    vdirsyncer    

    # Internet, Mensajería y Trabajo
    google-chrome
    discord
    keepassxc
    obsidian
    onlyoffice-desktopeditors
    evince

    # Multimedia y Gráficos
    vlc
    loupe
    cava
    sox
    ffmpeg

    # Productividad y Terminal
    vscodium
    gh
    btop
    fastfetch
    fetch
    fzf
    jq
    cowsay
    cmatrix
    inxi
    qalculate-gtk

    # Gestión de Archivos y Virtualización
    nemo
    qemu-utils
    virt-viewer
    protontricks

    # Desarrollo y Compiladores
    gcc
    gnumake
    pkg-config
    python3
    rustup
    jdk21
    libGL
    libpng
  ];

  # ====================================================================
  # Cursor y Apariencia
  # ====================================================================
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 12;
    gtk.enable = true;
    x11.enable = true;
  };

  # ====================================================================
  # Integración Spicetify
  # ====================================================================
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
    ];
  };

  # ====================================================================
  # Starship Prompt
  # ====================================================================
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # ====================================================================
  # Shell (Zsh) y Starship
  # ====================================================================
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  
 

    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "sudo"
        "z"
        "extract"
        "copypath"
        "copyfile"
        "colored-man-pages"
      ];
    };

    initContent = ''
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

  # ====================================================================
  # Acciones de Nemo
  # ====================================================================
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

  # Gestor de Home Manager
  programs.home-manager.enable = true;
}
