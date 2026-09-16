{ config, pkgs, lib, ... }:

let
  user = "spicyz";
  sshPath = path: "${config.home.homeDirectory}/.ssh/${path}";
  work100xGitConfig = "${config.xdg.configHome}/git/100x.gitconfig";
in
{
  git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs.enable = true;
    includes = [
      {
        condition = "gitdir:~/Documents/work/100x/";
        path = work100xGitConfig;
      }
    ];
    settings = {
      user = {
        name = "spicyzboss";
        email = "supachai@spicyz.io";
        signingkey = sshPath "spicyzboss";
      };
      init.defaultBranch = "main";
      core = {
        editor = "hx";
        autocrlf = "input";
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = true;
        "line-numbers" = true;
        "side-by-side" = true;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    # `matchBlocks` is a deprecated alias for `settings`. The two differ in more
    # than name: matchBlocks took home-manager's camelCase options and translated
    # them, while settings is freeform and takes the real ssh_config directive
    # names. Translated per the module's own legacyBlockSettings mapping --
    # hostname -> HostName, identitiesOnly -> IdentitiesOnly, and so on.
    settings = {
      "*" = {
        SendEnv = [ "LANG" "LC_*" ];
        HashKnownHosts = true;
      };
      "github.com" = {
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = [ (sshPath "spicyzboss") ];
      };
      "github.100x" = {
        HostName = "github.com";
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = [ (sshPath "boss-spicyz100x") ];
      };
    };
  };

  bat = {
    enable = true;
    config = {
      # catppuccin's module pins --theme; auto resolves via theme-dark/theme-light
      # instead, so bat follows the terminal background outside fish too
      theme = lib.mkForce "auto";
      theme-dark = "Catppuccin Mocha";
      theme-light = "Catppuccin Latte";
    };
  };

  fzf = {
    enable = true;
    enableFishIntegration = false;
  };

  lazygit.enable = true;

  zoxide = {
    enable = true;
    enableFishIntegration = false;
  };
}
