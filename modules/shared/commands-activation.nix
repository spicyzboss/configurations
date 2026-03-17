{ lib, ... }: {
  home.activation.removeOldClaudeCommands = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    if [ -d "$HOME/.claude/commands" ] && [ ! -L "$HOME/.claude/commands" ]; then
      rm -rf "$HOME/.claude/commands"
    fi
  '';
}
