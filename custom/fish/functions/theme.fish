function theme --description "Show or override the theme that follows the OS appearance"
    switch "$argv[1]"
        case '' show
            set -l following auto
            set -q __starship_theme_override; and set following "forced $__starship_theme_override"

            set -l palette default
            set -q STARSHIP_CONFIG; and set palette (path basename $STARSHIP_CONFIG | string replace .toml '')

            echo "$palette ($following)"
            echo "  starship  "(set -q STARSHIP_CONFIG; and echo $STARSHIP_CONFIG; or echo "~/.config/starship.toml")
            echo "  bat/delta "(set -q BAT_THEME; and echo $BAT_THEME; or echo "(BAT_THEME unset)")
            echo "  btop      "(path basename (path resolve $HOME/.config/btop/current.theme 2>/dev/null) 2>/dev/null)
        case dark light
            set -gx __starship_theme_override $argv[1]
            __apply_appearance $argv[1]
        case auto
            set -e __starship_theme_override
        case '*'
            echo "usage: theme [show|dark|light|auto]" >&2
            return 1
    end
end
