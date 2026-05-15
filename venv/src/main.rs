use std::io::Write;
use std::path::Path;
use std::process::{Command, Stdio};

use clap::{Parser, Subcommand};

const DEFAULT_VERSION: &str = "3.14";

#[derive(Parser)]
#[command(name = "venv", about = "pyenv virtualenv manager")]
struct Cli {
    #[command(subcommand)]
    command: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    List,
    New {
        name: Option<String>,
        #[arg(short, long, default_value = DEFAULT_VERSION)]
        version: String,
        #[arg(long)]
        path: Option<String>,
    },
    Activate { name: Option<String> },
    Delete { name: Option<String> },
}

fn list_venvs() -> Vec<String> {
    let output = Command::new("pyenv")
        .args(["virtualenvs", "--bare"])
        .output()
        .expect("failed to run pyenv");

    String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty() && !l.contains('/'))
        .map(String::from)
        .collect()
}

fn pick_venv(prompt: &str) -> Option<String> {
    let venvs = list_venvs();
    if venvs.is_empty() {
        eprintln!("No pyenv virtualenvs found.");
        return None;
    }

    let mut child = Command::new("fzf")
        .args([
            "--height=40%",
            "--layout=reverse",
            "--border",
            &format!("--prompt={}> ", prompt),
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("fzf not found — install fzf to use interactive picker");

    child
        .stdin
        .take()
        .unwrap()
        .write_all(venvs.join("\n").as_bytes())
        .ok();

    let output = child.wait_with_output().expect("fzf wait failed");

    if output.status.success() {
        Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        None
    }
}

fn cmd_list() {
    let venvs = list_venvs();
    if venvs.is_empty() {
        println!("No pyenv virtualenvs found.");
    } else {
        for v in venvs {
            println!("{}", v);
        }
    }
}

fn cmd_new(name: Option<String>, version: &str, path: Option<String>) -> Result<String, ()> {
    let name = name.unwrap_or_else(|| {
        let base = path.as_deref().unwrap_or(".");
        let canonical = std::fs::canonicalize(base)
            .unwrap_or_else(|_| Path::new(base).to_path_buf());
        let dir_name = canonical
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "venv".to_string());
        format!("{}_venv", dir_name)
    });

    if list_venvs().contains(&name) {
        eprintln!("Abort: virtualenv '{}' already exists.", name);
        return Err(());
    }

    eprintln!("Creating pyenv virtualenv: {} (Python {})...", name, version);

    let status = Command::new("pyenv")
        .args(["virtualenv", version, &name])
        .status()
        .expect("failed to run pyenv virtualenv");

    if !status.success() {
        return Err(());
    }

    if let Some(ref dir) = path {
        match std::fs::create_dir_all(dir) {
            Err(e) => eprintln!("Warning: could not create '{}': {}", dir, e),
            Ok(()) => {
                let version_file = Path::new(dir).join(".python-version");
                match std::fs::write(&version_file, format!("{}\n", name)) {
                    Err(e) => eprintln!("Warning: could not write .python-version: {}", e),
                    Ok(()) => eprintln!("Set {}/.python-version → {}", dir, name),
                }
            }
        }
    }

    Ok(name)
}

fn cmd_delete(name: Option<String>) {
    let name = match name.or_else(|| pick_venv("delete")) {
        Some(n) => n,
        None => return,
    };

    if !list_venvs().contains(&name) {
        eprintln!("Error: virtualenv '{}' not found.", name);
        std::process::exit(1);
    }

    eprint!("Delete '{name}'? [y/N] ");
    std::io::stderr().flush().ok();

    let mut input = String::new();
    std::io::stdin().read_line(&mut input).ok();

    if input.trim().eq_ignore_ascii_case("y") {
        let status = Command::new("pyenv")
            .args(["virtualenv-delete", "-f", &name])
            .status()
            .expect("failed to run pyenv virtualenv-delete");

        if status.success() {
            eprintln!("Deleted '{}'.", name);
        }
    } else {
        eprintln!("Cancelled.");
    }
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Cmd::List => cmd_list(),

        Cmd::New { name, version, path } => match cmd_new(name, &version, path) {
            Ok(name) => println!("{}", name),
            Err(()) => std::process::exit(1),
        },

        Cmd::Activate { .. } => {
            eprintln!("Run 'source ~/scripts/venv_wrapper.sh' in your shell config — activate must run inside the shell, not a subprocess.");
            std::process::exit(1);
        }

        Cmd::Delete { name } => cmd_delete(name),
    }
}
