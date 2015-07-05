# check_pattern.awk
# Generated by AX_AT_DATA_CHECK_PATTERN_AWK()
# from https://github.com/lukem/ax_at_check_pattern
#
# awk script to process the output of "diff PATTERN OUTPUT" removing lines
# where the difference is a PATTERN line that exactly matches an OUTPUT line.
#
#
# Copyright (c) 2013-2015 Luke Mewburn <luke@mewburn.net>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#

BEGIN { exitval=0 }

function mismatch()
{
	print mode
	for (i = 0; i < lc; i++) {
		print ll[i]
	}
	print "---"
	for (i = 0; i < rc; i++) {
		print rl[i]
	}
	mode=""
	exitval=1
}

$1 ~ /^[0-9]+(,[0-9]+)?[ad][0-9]+(,[0-9]+)?$/ {
	print
	mode=""
	exitval=1
	next
}

$1 ~ /^[0-9]+(,[0-9]+)?[c][0-9]+(,[0-9]+)?$/ {
	mode=$1
	lc=0
	rc=0
	next
}

mode == "" {
	print $0
	next
}

$1 == "<" {
	ll[lc] = $0
	lc = lc + 1
	next
}

$1 == "---" {
	next
}

$1 == ">" {
	rl[rc] = $0
	rc = rc + 1
	if (rc > lc) {
		mismatch()
		next
	}
	pat = "^" substr(ll[rc-1], 3) "$"
	str = substr($0, 3)
	if (str !~ pat) {
		mismatch()
	}
	next
}
{
	print "UNEXPECTED LINE: " $0
	exit 10
}

END { exit exitval }
