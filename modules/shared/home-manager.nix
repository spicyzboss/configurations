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
    matchBlocks = {
      "*" = {
        sendEnv = [ "LANG" "LC_*" ];
        hashKnownHosts = true;
      };
      "github.com" = {
        user = "git";
        identitiesOnly = true;
        identityFile = [ (sshPath "spicyzboss") ];
      };
      "github.100x" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = [ (sshPath "boss-spicyz100x") ];
      };
    };
  };

  bat.enable = true;

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
