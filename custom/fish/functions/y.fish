function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
