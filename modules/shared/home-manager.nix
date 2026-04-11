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
      "ctrl+shift+k" = "scroll_line_up";
      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";
      "ctrl+shift+z" = "scroll_to_prompt -1";
      "ctrl+shift+x" = "scroll_to_prompt 1";
      "ctrl+shift+h" = "show_scrollback";
      "ctrl+shift+g" = "show_last_command_output";
      "ctrl+shift+enter" = "new_window";
      "cmd+enter" = "new_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+f" = "move_window_forward";
      "ctrl+shift+b" = "move_window_backward";
      "ctrl+shift+d" = "detach_tab ask";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+alt+t" = "goto_layout tall";
      "ctrl+alt+s" = "goto_layout stack";
    };
    shellIntegration.mode = "no-cursor";
  };

  fish = {
    enable = true;
    shellAliases = {
      cd = "z";
    };
    shellAbbrs = {
      g = "git";
      ga = "git add";
      gc = "git commit -m";
      gch = "git checkout";
      gco = "git branch | fzf | xargs git checkout";
      gb = "git branch";
      gd = "git diff";
      gs = "git status -s";
      gpl = "git fetch --all --tags && git pull";
      gph = "git push origin HEAD";
      gphf = "git push origin HEAD --force-with-lease";
      gl = "git log --oneline";
      gst = "git stash -u";
      gstp = "git stash pop";
      grs = "git reset --hard";
      grr = "git reset HEAD~1";
      grm = "git remote";
      grml = "git remote -v";
      grma = "git remote add origin";
      grmr = "git remote remove origin";
      d = "docker";
      dps = "docker ps";
      dpsa = "docker ps -a";
      dcp = "docker-compose";
      dcpu = "docker-compose up -d";
      dcpd = "docker-compose down";
      c = "claude";
      zz = "yazi";
      lg = "lazygit";
    };
    interactiveShellInit = ''
      set -gx fish_greeting ""
      fish_add_path -a $HOME/.local/bin $HOME/.bun/bin $HOME/go/bin $HOME/.pyenv/bin $HOME/.cargo/bin ${pkgs.rustup}/bin
      set -gx BUN_INSTALL $HOME/.bun
      set -gx GOPATH $HOME/go
      set -gx PYENV_ROOT $HOME/.pyenv
      ${lib.optionalString pkgs.stdenv.isDarwin ''eval "$(/opt/homebrew/bin/brew shellenv)"''}
      ${lib.optionalString pkgs.stdenv.isDarwin ''fish_add_path -a /usr/local/texlive/2026/bin/universal-darwin''}
      test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish
    '';
    shellHook = ''
      rustup default 1.94.1 2>/dev/null || true
      rustup target add thumbv8m.main-none-eabihf thumbv7em-none-eabihf wasm32-unknown-unknown aarch64-apple-darwin 2>/dev/null || true
    '';
  };

  bat.enable = true;

  btop.enable = true;

  fzf.enable = true;

  lazygit.enable = true;

  yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  starship = {
    enable = true;
    enableFishIntegration = true;
  };

  zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
