# Keep the active gh CLI account in sync with the repo's git identity.
# The account name is read from `git config user.name`, which the per-repo
# includeIf rules already resolve by directory -- so no account names are
# hardcoded here. Git push/pull tokens are handled separately by the
# credential helper in ~/.gitconfig.

_gh_account_by_dir() {
	local want
	want=$(git config user.name 2>/dev/null)
	[ -n "$want" ] || return
	[ "$want" = "$_GH_ACTIVE" ] && return
	gh auth switch --user "$want" >/dev/null 2>&1 && _GH_ACTIVE="$want"
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_gh_account_by_dir"
