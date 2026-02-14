{ pkgs, ... }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    virtualenv
  ]);

  myFonts = import ./fonts.nix { inherit pkgs; };
in
with pkgs; [
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
  jetbrains.datagrip
  jq
  kitty
  lazygit
  myPython
  neofetch
  nodejs_22
  openssh
  pandoc
  ripgrep
  slack
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
] ++ myFonts
