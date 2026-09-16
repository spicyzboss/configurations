{ pkgs, config, lib, ... }:

let
  sshDir = "${config.home.homeDirectory}/.ssh";
  sshPath = path: "${sshDir}/${path}";
  keyNames = [ "spicyzboss" "boss-spicyz100x" ];

  # catppuccin/tmux, pinned to the v2.3.0 release rather than the 2.1.3 nixpkgs
  # currently packages. Linked below to the path upstream documents, so
  # custom/tmux/tmux.conf keeps the stock `run` line and there is no clone to
  # keep up to date.
  tmuxCatppuccin = pkgs.tmuxPlugins.catppuccin.overrideAttrs (_: {
    version = "2.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "v2.3.0";
      hash = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
    };
  });
  generateKey = name: ''
    key_path="${sshDir}/${name}"

    if [ ! -e "$key_path" ]; then
      rm -f "$key_path.pub"
      ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -C "${name}" -f "$key_path"
    elif [ ! -e "$key_path.pub" ]; then
      ${pkgs.openssh}/bin/ssh-keygen -y -f "$key_path" > "$key_path.pub"
    fi

    chmod 600 "$key_path" 2>/dev/null || true
    chmod 644 "$key_path.pub" 2>/dev/null || true
  '';
in
{
  activation = {
    generateGitSshKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      umask 077
      mkdir -p "${sshDir}"
      chmod 700 "${sshDir}" 2>/dev/null || true

      ${lib.concatMapStringsSep "\n" generateKey keyNames}
    '';
  };

  files = {
    ".hushlogin" = {
      text = "";
    };
    ".config/tmux/plugins/catppuccin/tmux" = {
      source = "${tmuxCatppuccin}/share/tmux-plugins/catppuccin";
    };
    ".config/git/100x.gitconfig" = {
      text = ''
        [user]
          email = "boss.spicyz@100x.fi"
          name = "boss-spicyz100x"
          signingkey = "${sshPath "boss-spicyz100x"}"
      '';
    };
  };
}
