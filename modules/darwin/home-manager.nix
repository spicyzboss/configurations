{ config, pkgs, lib, home-manager, catppuccin, ... }:

let
  user        = "spicyz";
in
{
  imports = [
    ./dock
  ];

  programs.fish.enable = true;

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
      then
        exec fish -l
      fi
    '';
  };

  users.users.${user} = {
    name     = "${user}";
    home     = "/Users/${user}";
    isHidden = false;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    taps   = [ "catppuccin/tap" ];
    brews  = pkgs.callPackage ./brews.nix {};
    casks  = pkgs.callPackage ./casks.nix {};
    #masApps = {
    #  "hidden-bar"   = 1452453066;
    #  "wireguard"    = 1451685025;
    #};
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:
      let
        sharedHome = import ../shared/files.nix { inherit config pkgs lib; };
      in
      {
        imports = [ catppuccin.homeModules.catppuccin ];
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix {};
          file = sharedHome.files;
          stateVersion = "25.11";
          sessionVariables = {
            EDITOR = "hx";
            VISUAL = "hx";
            JAVA_HOME = "${pkgs.jdk21}";
            DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
            PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
            LIBRARY_PATH = "/opt/homebrew/lib";
            LDFLAGS = "-L/opt/homebrew/lib";
            CPPFLAGS = "-I/opt/homebrew/include";
            PKG_CONFIG_PATH = "/opt/homebrew/lib/pkgconfig";
          };
          activation = sharedHome.activation // {
            rustupSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
              ${pkgs.rustup}/bin/rustup toolchain install 1.94.1 2>/dev/null || true
              ${pkgs.rustup}/bin/rustup default 1.94.1 2>/dev/null || true
              ${pkgs.rustup}/bin/rustup target add --toolchain 1.94.1 thumbv8m.main-none-eabihf thumbv7em-none-eabihf wasm32-unknown-unknown 2>/dev/null || true
            '';
          };
        };
        programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
        launchd.agents.colima = {
          enable = true;
          config = {
            ProgramArguments = [ "${pkgs.colima}/bin/colima" "start" ];
            RunAtLoad = true;
          };
        };
        catppuccin = {
          flavor = "mocha";
          bat.enable = true;
          delta.enable = true;
          fzf.enable = true;
          kitty.enable = true;
          lazygit.enable = true;
          starship.enable = true;
        };
        manual.manpages.enable = false;
      };
  };

  local.dock = {
    enable   = true;
    username = user;
    entries  = [
      { path = "/Applications/Google Chrome.app"; }
      { path = "/System/Applications/Apps.app"; }
      { path = "/Applications/kitty.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Claude.app"; }
      { path = "/System/Applications/Calendar.app"; }
      { path = "/System/Applications/Reminders.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };
}
