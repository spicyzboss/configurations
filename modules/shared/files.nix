{ pkgs, config, lib, ... }:

let
  sshDir = "${config.home.homeDirectory}/.ssh";
  sshPath = path: "${sshDir}/${path}";
  keyNames = [ "spicyzboss" "boss-spicyz100x" ];
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
    ".config/yazi/yazi.toml" = {
      text = ''
        [mgr]
        show_hidden = true
      '';
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
