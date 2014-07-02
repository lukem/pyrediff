AC_PREREQ([2.69])
AC_INIT([ax_at_check_pattern], [3], [luke@mewburn.net])

AC_COPYRIGHT([[
Copyright 2013-2014, Luke Mewburn <luke@mewburn.net>.
All rights reserved.
]])
AC_REVISION([m4_esyscmd_s([git describe --tags --always])])

AC_CONFIG_AUX_DIR([buildaux])
AC_CONFIG_MACRO_DIR([buildaux])

AM_INIT_AUTOMAKE([foreign nostdinc silent-rules -Werror -Wall])
AM_MAINTAINER_MODE()

AS_SHELL_SANITIZE()

AC_PROG_AWK()

AC_CONFIG_TESTDIR([tests])
AM_MISSING_PROG([AUTOM4TE], [autom4te])

AC_CONFIG_FILES([
	Makefile
	tests/Makefile
])

AC_OUTPUT()
