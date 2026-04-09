{ pkgs, lib ? pkgs.lib, ... }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    virtualenv
  ]);

  myFonts = import ./fonts.nix { inherit pkgs; };

  linuxOnlyPackages = with pkgs; [ jetbrains.datagrip slack ];
  basePackages = with pkgs; [
    bun
    code-cursor
    coreutils
    delta
    dust
    fd
    ffmpeg
    go
    gcc
    gh
    glow
    gopls
    _1password-cli
    helix
    imagemagick
    jdk21
    jq
    kitty
    myPython
    neofetch
    nodejs_22
    openssh
    pandoc
    ripgrep
    cargo
    terraform
    tflint
    tree
    unrar
    unzip
    uv
    zig
    zls
    zip
    zoxide
  ];
  filteredPackages = basePackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) linuxOnlyPackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) myFonts;
in
filteredPackages ++ myFonts
