{ config, pkgs, lib, ... }:

let name = "spicyz";
    user = "spicyz";
    email = "spicyz@local";
    onePasswordSigner = if pkgs.stdenv.isDarwin then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" else "/opt/1Password/op-ssh-sign";
    sshAgentSocket = if pkgs.stdenv.isDarwin then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" else "~/.1password/agent.sock";
    personalPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeyy6f27Lzkile5KU4Mu6ZX2YPp9FHPDxI7WexvJwl+";
    work100xPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUFapELtvauLRoMSO59nuKFrfpIES3I8nh/F0vZepVQ";
    sshPubPath = path: if pkgs.stdenv.isDarwin then "/Users/${user}/.ssh/${path}" else "/home/${user}/.ssh/${path}";
in
{
  git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs.enable = true;
    includes = [
      {
        condition = "gitdir:~/Documents/work/100x/";
        contents = {
          user = {
            name = "boss-spicyz100x";
            email = "boss.spicyz@100x.fi";
            signingkey = work100xPublicKey;
          };
        };
      }
    ];
    settings = {
      user = {
        name = "spicyzboss";
        email = "supachai@spicyz.io";
        signingkey = personalPublicKey;
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
        ssh.program = onePasswordSigner;
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
        extraOptions = { IdentityAgent = "\"${sshAgentSocket}\""; };
      };
      "github.com" = {
        identityFile = [ (sshPubPath "spicyzboss.pub") ];
      };
      "github.100x" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ (sshPubPath "boss-spicyz100x.pub") ];
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
