cd() {
    if [[ $# -eq 0 ]]; then
        local dir
        dir=$(
            {
                zoxide query --list 2>/dev/null
                find "$PWD" -maxdepth 1 -mindepth 1 -type d 2>/dev/null
            } | awk '!seen[$0]++' | fzf --height=40% --reverse --prompt="cd> "
        )
        __zoxide_z "${dir:-$HOME}"
    else
        __zoxide_z "$@"
    fi
}
