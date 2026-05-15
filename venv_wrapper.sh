#!/bin/bash

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

venv() {
    case "$1" in
        activate)
            local name="${2:-}"
            if [[ -z "$name" ]]; then
                name=$(command venv pick "activate")
                [[ $? -ne 0 || -z "$name" ]] && return 1
            fi
            pyenv activate "$name"
            ;;
        new)
            local name
            name=$(command venv "$@")
            [[ $? -ne 0 ]] && return 1
            [[ -n "$name" ]] && pyenv activate "$name"
            ;;
        *)
            command venv "$@"
            ;;
    esac
}

_venv_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local subcmd="${COMP_WORDS[1]}"

    if [[ "$COMP_CWORD" -eq 1 ]]; then
        COMPREPLY=($(compgen -W "activate new delete list" -- "$cur"))
        return
    fi

    if [[ "$COMP_CWORD" -eq 2 ]]; then
        case "$subcmd" in
            activate|delete)
                local selected
                selected=$(command venv pick "$subcmd") 2>/dev/null
                if [[ -n "$selected" ]]; then
                    COMPREPLY=("$selected")
                    printf '\n'
                    bind 'redraw-current-line' 2>/dev/null  # fzf hijacks terminal; restore prompt
                fi
                ;;
            new)
                COMPREPLY=($(compgen -W "--version --path" -- "$cur"))
                ;;
        esac
    fi

    if [[ "$COMP_CWORD" -ge 3 && "$subcmd" == "new" ]]; then
        case "${COMP_WORDS[COMP_CWORD-1]}" in
            --path)    COMPREPLY=($(compgen -d -- "$cur")) ;;
            --version) COMPREPLY=($(compgen -W "$(pyenv versions --bare 2>/dev/null | grep -v '/' | sort)" -- "$cur")) ;;
            *)         COMPREPLY=($(compgen -W "--version --path" -- "$cur")) ;;
        esac
    fi
}

complete -F _venv_complete venv
