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
    if test "$flavor" != "$__appearance_btop_flavor"
        set -g __appearance_btop_flavor $flavor
        command ln -sfn $flavor.theme \
            $HOME/.config/btop/themes/current.theme 2>/dev/null
        command pkill -USR2 -x btop 2>/dev/null
        or true # no btop running is the normal case, not a failure
    end
end
