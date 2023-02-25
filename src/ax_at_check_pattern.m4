# SYNOPSIS
#
#   AX_AT_CHECK_PATTERN(COMMANDS, [STATUS], [STDOUT-RE], [STDERR-RE], [RUN-IF-FAIL], [RUN-IF-PASS])
#   AX_AT_DIFF_PATTERN(PATTERN-FILE, TEST-FILE, [STATUS=0], [DIFFERENCES])
#   AX_AT_DATA_CHECK_PATTERN_AWK(FILENAME)
#
# DESCRIPTION
#
#   AX_AT_CHECK_PATTERN() executes a test similar to AT_CHECK(), except
#   that stdout and stderr are awk regular expressions (REs).
#
#   NOTE: as autoconf uses [] for quoting, the use of [brackets] in the RE
#   arguments STDOUT-RE and STDERR-RE can be awkward and require careful
#   extra quoting, or quadrigraphs '@<:@' (for '[') and '@:>@' (for ']').
#
#   awk is invoked via $AWK, which defaults to "awk" if unset or empty.
#
#   Implemented using AT_CHECK() with a custom value for $at_diff that
#   invokes diff with an awk post-processor.
#
#
#   AX_AT_DIFF_PATTERN() checks that the PATTERN-FILE applies to TEST-FILE.
#   If there are differences, STATUS will be 1 and they should be DIFFERENCES.
#
#
#   AX_AT_DATA_CHECK_PATTERN_AWK() creates FILENAME with the contents of
#   the awk script used.
#
#
#   The latest version of this macro and a supporting test suite are at:
#   https://github.com/lukem/pyrediff
#
#
# LICENSE
#
#   Copyright (c) 2013-2023, Luke Mewburn <luke@mewburn.net>
#
#   Copying and distribution of this file, with or without modification,
#   are permitted in any medium without royalty provided the copyright
#   notice and this notice are preserved.  This file is offered as-is,
#   without any warranty.

#serial 17

m4_define([_AX_AT_CHECK_PATTERN_AWK],
[[BEGIN { exitval=0 }

function set_mode(m)
{
	mode=m
	lc=0
	rc=0
}

function mismatch()
{
	print mode
	for (i = 0; i < lc; i++) {
		print ll@<:@i@:>@
	}
	print "---"
	for (i = 0; i < rc; i++) {
		print rl@<:@i@:>@
	}
	set_mode("")
	exitval=1
}

function change_mode(m)
{
	if (lc > rc) {
		mismatch()
	}
	set_mode(m)
}

@S|@1 ~ /^@<:@0-9@:>@+(,@<:@0-9@:>@+)?@<:@ad@:>@@<:@0-9@:>@+(,@<:@0-9@:>@+)?@S|@/ {
	change_mode("")
	print
	exitval=1
	next
}

@S|@1 ~ /^@<:@0-9@:>@+(,@<:@0-9@:>@+)?@<:@c@:>@@<:@0-9@:>@+(,@<:@0-9@:>@+)?@S|@/ {
	change_mode(@S|@1)
	next
}

mode == "" {
	print @S|@0
	next
}

@S|@1 == "<" {
	ll@<:@lc@:>@ = @S|@0
	lc = lc + 1
	next
}

@S|@1 == "---" {
	next
}

@S|@1 == ">" {
	rl@<:@rc@:>@ = @S|@0
	rc = rc + 1
	if (rc > lc) {
		mismatch()
		next
	}
	pat = "^" substr(ll@<:@rc-1@:>@, 3) "@S|@"
	str = substr(@S|@0, 3)
	if (str !~ pat) {
		mismatch()
	}
	next
}

{
	print "UNEXPECTED LINE: " @S|@0
	exitval=10
	exit
}

END {
	if (exitval != 10) {
		change_mode("")
	}
	exit exitval
}
]])


m4_defun([_AX_AT_CHECK_PATTERN_PREPARE], [dnl
dnl Can't use AC_PROG_AWK() in autotest.
AS_VAR_IF([AWK], [], [AWK=awk])

AS_REQUIRE_SHELL_FN([ax_at_diff_pattern],
  [AS_FUNCTION_DESCRIBE([ax_at_diff_pattern], [PATTERN OUTPUT],
    [Diff PATTERN OUTPUT and elide change lines where the RE pattern matches])],
  [diff "$[]1" "$[]2" | $AWK '_AX_AT_CHECK_PATTERN_AWK'])
])dnl _AX_AT_CHECK_PATTERN_PREPARE


m4_defun([AX_AT_CHECK_PATTERN], [dnl
AS_REQUIRE([_AX_AT_CHECK_PATTERN_PREPARE])
_ax_at_check_pattern_prepare_original_at_diff="$at_diff"
at_diff='ax_at_diff_pattern'
AT_CHECK(m4_expand([$1]), [$2], m4_expand([$3]), m4_expand([$4]),
        [at_diff="$_ax_at_check_pattern_prepare_original_at_diff";$5],
        [at_diff="$_ax_at_check_pattern_prepare_original_at_diff";$6])
])dnl AX_AT_CHECK_PATTERN


m4_defun([AX_AT_DIFF_PATTERN], [dnl
AS_REQUIRE([_AX_AT_CHECK_PATTERN_PREPARE])
AT_CHECK([ax_at_diff_pattern $1 $2], [$3], [$4])
])dnl AX_AT_DIFF_PATTERN


m4_defun([AX_AT_DATA_CHECK_PATTERN_AWK], [dnl
m4_if([$1], [], [m4_fatal([$0: argument 1: empty filename])])dnl
AT_DATA([$1], [dnl
# check_pattern.awk
# Generated by AX_AT_DATA_CHECK_PATTERN_AWK()
# from https://github.com/lukem/pyrediff
#
# awk script to process the output of "diff PATTERN OUTPUT" removing lines
# where the difference is a PATTERN line that exactly matches an OUTPUT line.
#
#
# Copyright (c) 2013-2023, Luke Mewburn <luke@mewburn.net>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
]
_AX_AT_CHECK_PATTERN_AWK)
])dnl AX_AT_DATA_CHECK_PATTERN_AWK
