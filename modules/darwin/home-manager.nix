{ config, pkgs, lib, home-manager, ... }:

let
  user        = "spicyz";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
in
{
  imports = [
    ./dock
  ];

  programs.fish.enable = true;

  users.users.${user} = {
    name     = "${user}";
    home     = "/Users/${user}";
    isHidden = false;
    shell    = pkgs.fish;
  };

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    enable = true;
    casks  = pkgs.callPackage ./casks.nix {};
    #masApps = {
    #  "hidden-bar"   = 1452453066;
    #  "wireguard"    = 1451685025;
    #};
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:
      {
        imports = [ ../shared/claude-settings.nix ];
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix {};
          file = sharedFiles;
          stateVersion = "25.11";
          sessionVariables = {
            EDITOR = "hx";
            VISUAL = "hx";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
            PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
          };
        };
        programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
        manual.manpages.enable = false;
      };
  };

  local.dock = {
    enable   = true;
    username = user;
    entries  = [
      { path = "/System/Library/CoreServices/Finder.app"; }
      { path = "/Applications/Google Chrome.app"; }
      { path = "/System/Applications/Launchpad.app"; }
      { path = "/Applications/Cursor.app"; }
      { path = "${pkgs.kitty}/Applications/Kitty.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/System/Applications/Mail.app"; }
      { path = "/System/Applications/Calendar.app"; }
      { path = "/System/Applications/Reminders.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };
}
