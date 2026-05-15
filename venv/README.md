# venv

pyenv virtualenv manager. Rust binary + thin bash wrapper.

## Architecture

Activation requires modifying the current shell's environment (`pyenv activate` sets env vars). A subprocess can't do this — changes die with the child process. So the tool is split:

- **Rust binary** (`~/.cargo/bin/venv`) — handles `new`, `delete`, `list`, `pick`. Stateless, no shell interaction needed.
- **Bash wrapper** (`~/scripts/venv_wrapper.sh`) — defines a `venv()` shell function. Intercepts `activate` and runs `pyenv activate` directly in the shell. Everything else is forwarded to the binary via `command venv "$@"`.

```
venv activate foo
  └─> bash function intercepts → pyenv activate foo (runs in current shell)

venv delete foo
  └─> bash function falls through → command venv delete foo (Rust binary)
```

The `activate` subcommand exists in the Rust binary only to appear in `--help`. Calling it directly prints an error explaining to use the shell wrapper.

The `pick` subcommand is hidden from `--help`. It's an internal command used by the bash wrapper to open an fzf picker and return the selected venv name via stdout, which the wrapper then passes to `pyenv activate`.

## Setup

Source the wrapper once at shell startup (already in `~/.config/.bash_aliases`):

```bash
source ~/scripts/venv_wrapper.sh
```

This initialises pyenv and defines the `venv` shell function + bash tab completion.

## Usage

```
venv activate [name]               # fzf picker if no name
venv new [name] [--version VER] [--path DIR]
venv delete [name]                 # fzf picker if no name
venv list
```

`--path DIR` creates the venv and writes a `.python-version` file into `DIR` so pyenv auto-activates it when you `cd` there.

## Updating after code changes

```bash
cargo install --path ~/scripts/venv
```

Rebuilds and replaces `~/.cargo/bin/venv`.
