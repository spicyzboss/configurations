function __apply_appearance --argument-names mode \
    --description "Point the tools that follow the OS appearance at their dark or light theme"

    set -l flavor

    switch $mode
        case dark
            set flavor catppuccin_mocha
            set -gx STARSHIP_CONFIG $HOME/.config/starship/dark.toml
            # delta infers its own light/dark mode from BAT_THEME, so this covers both
            set -gx BAT_THEME 'Catppuccin Mocha'
        case light
            set flavor catppuccin_latte
            set -gx STARSHIP_CONFIG $HOME/.config/starship/light.toml
            set -gx BAT_THEME 'Catppuccin Latte'
        case '*'
            echo "__apply_appearance: expected dark or light, got '$mode'" >&2
            return 1
    end

    # btop resolves color_theme through this symlink. SIGUSR2 sets reload_conf,
    # which re-runs init_config + Theme::setTheme (btop.cpp:323, 1140), so a
    # running btop switches live; without it the change lands on next launch.
    # Only on a change, so the prompt does not fork on every render.
    # Compare against the symlink itself, not a remembered value: another shell or
    # a `theme` override can move it, and a per-shell memo would then conclude there
    # is nothing to do and leave it wrong. `path resolve` and `test` are builtins,
    # so the check costs no fork; only an actual change does.
    set -l link $HOME/.config/btop/themes/current.theme
    set -l want $HOME/.config/btop/themes/$flavor.theme

    if test (path resolve $link) != (path resolve $want)
        command ln -sfn $flavor.theme $link 2>/dev/null
        command pkill -USR2 -x btop 2>/dev/null
        or true # no btop running is the normal case, not a failure
    end

    # lazygit reads LG_CONFIG_FILE at startup and has no reload, so flipping the
    # symlink is enough: the next lazygit launch picks it up.
    set -l lg_flavor mocha
    test $mode = light; and set lg_flavor latte

    set -l lg_link $HOME/.config/lazygit/themes/current.yml
    set -l lg_want $HOME/.config/lazygit/themes/$lg_flavor.yml

    if test (path resolve $lg_link) != (path resolve $lg_want)
        command ln -sfn $lg_flavor.yml $lg_link 2>/dev/null
    end
end
