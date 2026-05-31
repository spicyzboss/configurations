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
        identityFile = [ (sshPath "spicyzboss") ];
      };
      "github.100x" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ (sshPath "boss-spicyz100x") ];
      };
    };
  };

  helix = import ./helix.nix { inherit pkgs; };

  kitty = {
    enable = true;
    font = {
      name = "Iosevka Nerd Font Mono";
      size = 24;
      package = pkgs.nerd-fonts.iosevka;
    };
    settings = {
      window_padding_width = 16;
      hide_window_decorations = true;
      macos_option_as_alt = "no";
      kitty_mod = "ctrl+shift";
    };
    keybindings = {
      "kitty_mod+k" = "scroll_line_up";
      "kitty_mod+j" = "scroll_line_down";
      "kitty_mod+page_up" = "scroll_page_up";
      "kitty_mod+page_down" = "scroll_page_down";
      "kitty_mod+home" = "scroll_home";
      "kitty_mod+end" = "scroll_end";
      "kitty_mod+z" = "scroll_to_prompt -1";
      "kitty_mod+x" = "scroll_to_prompt 1";
      "kitty_mod+h" = "show_scrollback";
      "kitty_mod+g" = "show_last_command_output";
      "cmd+enter" = "new_window";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+f" = "move_window_forward";
      "kitty_mod+b" = "move_window_backward";
      "kitty_mod+d" = "detach_tab ask";
      "kitty_mod+t" = "launch --cwd=current --type=tab --location=neighbor";
      "ctrl+alt+t" = "goto_layout tall";
      "ctrl+alt+s" = "goto_layout stack";
    };
    shellIntegration.mode = "no-cursor";
  };

  bat.enable = true;

  btop = {
    enable = true;
    settings = {
      update_ms = 500;
    };
  };

  fzf = {
    enable = true;
    enableFishIntegration = false;
  };

  lazygit.enable = true;

  yazi = {
    enable = true;
    enableFishIntegration = false;
    shellWrapperName = "y";
  };

  starship = {
    enable = true;
    enableFishIntegration = false;
  };

  zoxide = {
    enable = true;
    enableFishIntegration = false;
  };
}
