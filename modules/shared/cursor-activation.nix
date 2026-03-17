{ lib, ... }: {
  home.activation.removeOldCursorCommands = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    if [ -d "$HOME/.cursor/commands" ] && [ ! -L "$HOME/.cursor/commands" ]; then
      rm -rf "$HOME/.cursor/commands"
    fi
  '';
}
