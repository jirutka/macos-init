# vim: set ts=4 sw=4:
# Utility functions for provisioning scripts.
# https://github.com/jirutka/macos-init

die() {
	error "$1"
	exit 1
}

error() {
	printf 'ERROR: %s\n' "$1" >&2
}

warn() {
	printf 'WARN: %s\n' "$1" >&2
}

# Returns 0 if $1 is a protected variable name (e.g. PATH, PWD, RC_*),
# 1 otherwise.
is_protected_var() {
	case "$1" in
		EINFO_* | PATH | PWD | RC_* | SHLVL | SVCNAME | MACINIT_*) return 0;;
		*) return 1;;
	esac
}

# Returns 0 if the needle $1 is included in the list $2+, 1 otherwise.
list_has() {
	local needle="$1"; shift

	local i; for i in "$@"; do
	        [ "$i" != "$needle" ] || return 0
	done
	return 1
}

# Normalizes $1 to be a valid shell variable name and converts it to
# SCREAMING_CASE.
normalize_var_name() {
	printf %s "$1" | tr '[a-z]' '[A-Z]' | sed 's/[^A-Z0-9_]/_/g'
}

# Escapes single quote marks (') in the given string, so it can be used in a
# single-quoted string.
escape_squote() {
	printf '%s' "$1" | sed "s/'/'\\\\''/g"
}