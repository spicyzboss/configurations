{ config, pkgs, lib, ... }:

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
      deny = [ "Bash(cd *)" "Bash(cd)" ];
      defaultMode = "default";
    };
    enabledPlugins = {
      "typescript-lsp@claude-plugins-official" = true;
      "gopls-lsp@claude-plugins-official" = true;
      "rust-analyzer-lsp@claude-plugins-official" = true;
    };
    syntaxHighlightingDisabled = false;
  };

  baseEnv = {
    API_TIMEOUT_MS = "3000000";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
  };

  glmEnv = baseEnv // {
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.7";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5";
    ANTHROPIC_AUTH_TOKEN = "op://100x/ZAI_API_KEY/notes";
    ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
  };

  settingsJson = baseConfig // { env = baseEnv; };
  settingsGlmJson = baseConfig // { env = glmEnv; model = "opus"; };

  op = pkgs._1password-cli;
in
{
  home.file.".claude/settings.json" = {
    text = builtins.toJSON settingsJson;
  };

  home.file.".claude/settings-glm.json.tpl" = {
    text = builtins.toJSON settingsGlmJson;
  };

  home.activation.claudeSettingsGlm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${op}/bin/op inject -i "$HOME/.claude/settings-glm.json.tpl" -o "$HOME/.claude/settings-glm.json"; then
      echo "Created ~/.claude/settings-glm.json from 1Password"
    else
      echo "1Password not ready. After signing in, run:"
      echo "  op inject -i $HOME/.claude/settings-glm.json.tpl -o $HOME/.claude/settings-glm.json"
    fi
  '';
}
