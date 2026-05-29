{ pkgs, config, ... }:

let
  personalPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeyy6f27Lzkile5KU4Mu6ZX2YPp9FHPDxI7WexvJwl+";
  work100xPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUFapELtvauLRoMSO59nuKFrfpIES3I8nh/F0vZepVQ";
in

{
  ".ssh/spicyzboss.pub" = {
    text = personalPublicKey;
  };
  ".ssh/boss-spicyz100x.pub" = {
    text = work100xPublicKey;
  };
  ".hushlogin" = {
    text = "";
  };
  ".config/1Password/ssh/agent.toml" = {
    text = ''
      [[ssh-keys]]
      vault = "Private"
      item = "spicyzboss"

      [[ssh-keys]]
      vault = "100x"
      item = "boss-spicyz100x"
    '';
  };

  ".config/yazi/yazi.toml" = {
    text = ''
      [mgr]
      show_hidden = true
    '';
  };
}
