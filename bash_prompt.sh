case "$TERM" in
    xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    c_user=$(tput setaf 33)
    c_host=$(tput setaf 10)
    c_path=$(tput setaf 203)
    c_git=$(tput setaf 220)
    c_off=$(tput sgr0)
else
    c_user= c_host= c_path= c_git= c_off=
fi

prompt_glyph=$(printf '')

git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    printf -- '----> %s (%s)' "$prompt_glyph" "$branch"
}

prompt_header() {
    local dir=${PWD/#$HOME/\~}
    printf '%s\n' "${c_user}${USER}${c_host}@${HOSTNAME%%.*}:${c_path}${dir}${c_off}"
}

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }prompt_header"

PS1='${debian_chroot:+($debian_chroot)}\[$c_git\]$(git_branch)\[$c_off\]$ '

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

unset color_prompt force_color_prompt
