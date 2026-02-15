{ pkgs, lib ? pkgs.lib, ... }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    virtualenv
  ]);

  myFonts = import ./fonts.nix { inherit pkgs; };

  linuxOnlyPackages = with pkgs; [ jetbrains.datagrip slack ];
  basePackages = with pkgs; [
    bat
    btop
    bun
    code-cursor
    coreutils
    delta
    dust
    fd
    ffmpeg
    fzf
    go
    gcc
    gh
    glow
    gopls
    _1password-cli
    helix
    imagemagick
    jq
    kitty
    lazygit
    myPython
    neofetch
    nodejs_22
    openssh
    pandoc
    ripgrep
    rustc
    cargo
    starship
    terraform
    tflint
    tree
    unrar
    unzip
    uv
    zip
    yazi
    zoxide
  ];
  filteredPackages = basePackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) linuxOnlyPackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) myFonts;
in
filteredPackages ++ myFonts
