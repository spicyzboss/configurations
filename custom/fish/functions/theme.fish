function theme --description "Show or override the starship palette that follows the OS appearance"
    set -l config_dir $HOME/.config/starship

    switch "$argv[1]"
        case '' show
            set -l following auto
            set -q __starship_theme_override; and set following "forced $__starship_theme_override"

            if set -q STARSHIP_CONFIG
                echo (path basename $STARSHIP_CONFIG | string replace .toml '')" ($following)"
            else
                echo "default ($following)"
            end
        case dark light
            set -gx __starship_theme_override $argv[1]
            set -gx STARSHIP_CONFIG $config_dir/$argv[1].toml
        case auto
            set -e __starship_theme_override
        case '*'
            echo "usage: theme [show|dark|light|auto]" >&2
            return 1
    end
end
