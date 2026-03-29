{ config, ... }:

let
  baseConfig = {
    includeCoAuthoredBy = false;
    permissions = {
      allow = [
        "WebSearch"
        "WebFetch(domain:github.com)"
        "WebFetch(domain:docs.rs)"
        "WebFetch(domain:www.npmjs.com)"
        "WebFetch(domain:raw.githubusercontent.com)"
        "Bash(git add:*)"
        "Bash(git commit:*)"
        "Bash(bun run:*)"
        "Bash(bun format:check:*)"
        "Bash(bun format:fix:*)"
        "Bash(bun lint:check:*)"
        "Bash(bun lint:fix:*)"
        "Bash(tree:*)"
        "Bash(bun rules-install:all:*)"
        "Skill(organization.new-employee)"
        "Skill(organization.new-employee:*)"
        "Bash(bun nx build:*)"
        "Bash(bun nx check:*)"
        "Bash(bun nx run:*)"
        "Bash(bun nx test:*)"
        "Bash(bun nx lint:*)"
        "Bash(bun nx show:*)"
      ];
      deny = [ ];
      defaultMode = "default";
    };
    enabledPlugins = {
      "typescript-lsp@claude-plugins-official" = true;
      "gopls-lsp@claude-plugins-official" = true;
      "rust-analyzer-lsp@claude-plugins-official" = true;
    };
    syntaxHighlightingDisabled = false;
  };

  env = {
    API_TIMEOUT_MS = "3000000";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
  };

  hookPath = "${config.home.homeDirectory}/.claude/hooks/session-start-datetime.sh";

  hooks = {
    SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = hookPath;
          }
        ];
      }
    ];
  };

  settings = baseConfig // {
    inherit env hooks;
  };
in
{
  home.file.".claude/hooks/session-start-datetime.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      echo "Session clock: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    '';
  };

  home.file.".claude/settings.json" = {
    text = builtins.toJSON settings;
  };
}
