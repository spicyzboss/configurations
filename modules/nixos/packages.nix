{ pkgs, inputs, config ? null }:
with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };

  rofi-launcher = pkgs.writeShellScriptBin "rofi-launcher" ''
    ${pkgs.kdePackages.kde-cli-tools}/bin/kstart5 --window "rofi" -- ${pkgs.rofi}/bin/rofi -show drun
  '';
in
shared-packages ++ [
  _1password-gui
  cloudflare-warp
  cliphist
  docker-compose
  ninja
  notion-app
  obsidian
  chromium
  discord
  xclip
  glow
  google-chrome
  imv
  pavucontrol
  qmk
  unixtools.ifconfig
  unixtools.netstat
  pinentry-qt
  xwayland
  cava
  asciiquarium
  tty-clock
  rofi-launcher
  libnotify
  rofi
  linuxKernel.packages.linux_zen.xone
  virtualbox
]
