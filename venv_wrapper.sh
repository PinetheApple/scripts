#!/bin/bash

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

DEFAULT_VERSION="3.14"
DIR_NAME=$(basename "$PWD")
PYENV_VENV_NAME="${DIR_NAME}_venv"

_activate_logic() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
        echo "Activated local .venv"
    elif pyenv virtualenvs | grep -q "$PYENV_VENV_NAME"; then
        pyenv activate "$PYENV_VENV_NAME"
    else
        echo "No venv found. Please create one using: venv new"
    fi
}

_new_logic() {
    local version=${1:-$DEFAULT_VERSION}
    local name=${2:-$PYENV_VENV_NAME}

    if [ -d ".venv" ]; then
        echo "Abort: Local .venv already exists."
        return 1
    elif pyenv virtualenvs | grep -q "$PYENV_VENV_NAME"; then
        echo "Abort: Pyenv virtualenv $PYENV_VENV_NAME already exists."
        return 1
    fi

    echo "Creating pyenv virtualenv: $name (Python $version)..."
    pyenv virtualenv "$version" "$name" && pyenv activate "$name"
}

# CLI Router
case "$1" in
    activate)
        _activate_logic
        ;;
    new)
        _new_logic "$2" "$3"
        ;;
    *)
        echo "Usage: venv <activate|new> [version] [name]"
        ;;
esac