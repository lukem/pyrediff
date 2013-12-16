# SYNOPSIS
#
#   AX_AT_CHECK_PATTERN(commands, [status], [stdout_re], [stderr_re],
#                      [run-if-fail], [run-if-pass])
#
# DESCRIPTION
#
#   This macro executes a test, similar to AT_CHECK(), except that
#   stdout and stderr are awk regular expressions.
#
# LICENSE
#
#   Copyright (c) 2013 Luke Mewburn <luke@mewburn.net>
#
#   Copying and distribution of this file, with or without modification,
#   are permitted in any medium without royalty provided the copyright
#   notice and this notice are preserved.  This file is offered as-is,
#   without any warranty.

#serial 1

dnl XXX AC_REQUIRE([AC_PROG_AWK])


m4_defun([_AX_AT_CHECK_PATTERN_PREPARE],
[AS_REQUIRE_SHELL_FN([ax_at_diff_pattern],
  [AS_FUNCTION_DESCRIBE([ax_at_diff_pattern], [PATTERN OUTPUT],
    [Diff PATTERN OUTPUT and elide change lines where the RE pattern matches])],
[diff "$[]1" "$[]2" | awk '
BEGIN { exitval=0 }

function mismatch()
{
	print mode
	for (i = 0; i < lc; i++) {
		print ll[[i]]
	}
	print "---"
	for (i = 0; i < rc; i++) {
		print rl[[i]]
	}
	mode=""
	exitval=1
}

$[]1 ~ /^[[0-9]]+(,[[0-9]]+)?[[ad]][[0-9]]+(,[[0-9]]+)?$/ {
	print
	mode=""
	exitval=1
	next
}

$[]1 ~ /^[[0-9]]+(,[[0-9]]+)?[[c]][[0-9]]+(,[[0-9]]+)?$/ {
	mode=$[]1
	lc=0
	rc=0
	next
}

mode == "" {
	print $[]0
	next
}

$[]1 == "<" {
	ll[[lc]] = $[]0
	lc = lc + 1
	next
}

$[]1 == "---" {
	next
}

$[]1 == ">" {
	rl[[rc]] = $[]0
	rc = rc + 1
	if (rc > lc) {
		mismatch()
		next
	}
	pat = "^" substr(ll[[rc-1]], 2) "$"
	str = substr($[]0, 2)
	if (str !~ pat) {
		mismatch()
	}
	next
}
{
	print "UNEXPECTED LINE: " $[]0
	exit 10
}

END { exit exitval }
'])])dnl _AX_AT_CHECK_PATTERN_PREPARE


m4_defun([AX_AT_CHECK_PATTERN],
[AS_REQUIRE([_AX_AT_CHECK_PATTERN_PREPARE])
_ax_a_c_p_d="$at_diff"
at_diff='ax_at_diff_pattern'
AT_CHECK($1, $2, $3, $4,
        [at_diff="$_ax_a_c_p_d";]$5,
	[at_diff="$_ax_a_c_p_d";]$6)

])dnl AX_AT_CHECK_PATTERN
