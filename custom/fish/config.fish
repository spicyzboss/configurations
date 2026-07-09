# Repo-tracked Fish config. Link with ./scripts/link-fish.

function __source_hm_session_vars
    for hm_session_vars in $HOME/.nix-profile/etc/profile.d/hm-session-vars.fish $HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.fish /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.fish
        if test -f $hm_session_vars
            source $hm_session_vars
            return
        end
    end

    for hm_session_vars in $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh $HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.sh /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
        if not test -f $hm_session_vars
            continue
        end

        set -l names
        for line in (string match -r '^export [A-Za-z_][A-Za-z0-9_]*=' <$hm_session_vars)
            set -a names (string replace -r '^export ([A-Za-z_][A-Za-z0-9_]*).*' '$1' -- $line)
        end

        if test (count $names) -eq 0
            return
        end

        for line in (command env -i HOME="$HOME" USER="$USER" TERM="$TERM" PATH="$PATH" /bin/sh -c '. "$1"; shift; for name do eval "value=\${$name-}"; printf "%s=%s\n" "$name" "$value"; done' sh $hm_session_vars $names)
            set -l parts (string split -m 1 = -- $line)
            set -gx $parts[1] "$parts[2]"
        end

        return
    end
end

__source_hm_session_vars
functions -e __source_hm_session_vars

if status is-interactive
    if test -f $HOME/.config/fish/themes/catppuccin-mocha.theme
        fish_config theme choose catppuccin-mocha >/dev/null 2>/dev/null
    end

    alias ls eza

    abbr --add -- c claude
    abbr --add -- d docker
    abbr --add -- dcp docker-compose
    abbr --add -- dcpd 'docker-compose down'
    abbr --add -- dcpu 'docker-compose up -d'
    abbr --add -- dps 'docker ps'
    abbr --add -- dpsa 'docker ps -a'
    abbr --add -- g git
    abbr --add -- ga 'git add'
    abbr --add -- gb 'git branch'
    abbr --add -- gc 'git commit -m'
    abbr --add -- gch 'git checkout'
    abbr --add -- gco 'git branch | fzf | xargs git checkout'
    abbr --add -- gd 'git diff'
    abbr --add -- gl 'git log --oneline'
    abbr --add -- gph 'git push origin HEAD'
    abbr --add -- gphf 'git push origin HEAD --force-with-lease'
    abbr --add -- gpl 'git pull'
    abbr --add -- gpla 'git fetch --all --tags && git pull'
    abbr --add -- grm 'git remote'
    abbr --add -- grma 'git remote add origin'
    abbr --add -- grml 'git remote -v'
    abbr --add -- grmr 'git remote remove origin'
    abbr --add -- grr 'git reset HEAD~1'
    abbr --add -- grs 'git reset --hard'
    abbr --add -- gs 'git status -s'
    abbr --add -- gst 'git stash -u'
    abbr --add -- gstp 'git stash pop'
    abbr --add -- k kubectl
    abbr --add -- lg lazygit
    abbr --add -- lsa 'ls -la'
    abbr --add -- zz yazi

    alias cd z

    if command -q fzf
        fzf --fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end

    if test "$TERM" != dumb; and command -q starship
        starship init fish | source
    end

    if set -q KITTY_INSTALLATION_DIR
        set --global KITTY_SHELL_INTEGRATION "no-rc no-cursor"
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
    end

    set -gx fish_greeting ""
    set -gx BUN_INSTALL $HOME/.bun
    set -gx GOPATH $HOME/go
    set -gx PYENV_ROOT $HOME/.pyenv
    set -gx RUSTUP_HOME $HOME/.rustup
    set -gx CARGO_HOME $HOME/.cargo

    fish_add_path -a $HOME/.local/bin $HOME/.bun/bin $HOME/go/bin $HOME/.pyenv/bin $HOME/.cargo/bin

    if test (uname) = Darwin
        if test -x /opt/homebrew/bin/brew
            eval (/opt/homebrew/bin/brew shellenv)
        else if test -x /usr/local/bin/brew
            eval (/usr/local/bin/brew shellenv)
        end

        fish_add_path -a /opt/homebrew/opt/libpq/bin /usr/local/texlive/2026/bin/universal-darwin
    end

    test -f $HOME/.cargo/env.fish; and source $HOME/.cargo/env.fish
end

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
