{ pkgs, lib ? pkgs.lib, ... }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    virtualenv
  ]);

  myFonts = import ./fonts.nix { inherit pkgs; };

  # helix installed via `brew --HEAD` on darwin (modules/darwin/brews.nix) instead of nixpkgs
  linuxOnlyPackages = with pkgs; [ jetbrains.datagrip slack helix ];
  basePackages = with pkgs; [
    btop
    bun
    code-cursor
    coreutils
    delta
    dust
    eza
    fd
    ffmpeg
    fish
    go
    gcc
    gh
    glow
    gopls
    _1password-cli
    imagemagick
    jdk21
    jq
    myPython
    fastfetch
    nodejs_22
    openssh
    pandoc
    postgresql
    ripgrep
    starship
    terraform
    tflint
    tmux
    tree
    unrar
    unzip
    uv
    yazi
    zellij
    zig
    zls
    zip
    zoxide
    kubectl
    kubernetes-helm
  ];
  filteredPackages = basePackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) linuxOnlyPackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin) myFonts;
in
filteredPackages ++ myFonts
