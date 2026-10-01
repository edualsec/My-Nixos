{ config, pkgs, inputs, ... }:
{
  home.username = "d3rhund";
  home.homeDirectory = "/home/d3rhund";
  home.stateVersion = "25.05";
  xdg.configFile."mango".source = ./dotfiles/mango;
  xdg.configFile."ghostty".source = ./dotfiles/ghostty;
  xdg.configFile."waybar".source = ./dotfiles/waybar;
  xdg.configFile."eww".source = ./dotfiles/eww;
  ######################################################################
  ## Paquetes personales y utilidades de escritorio
  ######################################################################
  home.packages = with pkgs; [
    fastfetch
    discord
    spotify
    vscodium
    gh
    cowsay
    btop
    starship
    nwg-look
    cmatrix
    inxi
    cava
    onlyoffice-desktopeditors
    obsidian
    nemo
    qemu-utils
    protontricks
    libnotify
    sox
    fetch
    gnome-pomodoro
    jq
    vlc
    fzf
    keepassxc
    pulseaudio
    wf-recorder
    eww
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Stack modular para Wayland
    fuzzel                    # Lanzador de aplicaciones
    swaynotificationcenter    # Centro de notificaciones (SwayNC)
    grim                      # Capturas de pantalla
    slurp                     # Selector de áreas
    wl-clipboard              # Portapapeles
    sassc
    cliphist
    playerctl
    pamixer  
    networkmanager
                   # Control de audio/multimedia

    # Herramientas de compilación y librerías
    gcc
    gnumake
    pkg-config
    python3
    rustup
    ffmpeg
    jdk21    
    wayland
    wayland-protocols
    libGL
    libpng
  ];

  ######################################################################
  ## Barra de estado modular (Waybar)
  ######################################################################
  programs.waybar.enable = true;

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

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Configuración de Oh My Zsh y sus plugins
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
      eval "$(starship init zsh)"
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
