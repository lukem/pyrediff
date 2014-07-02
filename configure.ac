AC_PREREQ([2.69])
AC_INIT([ax_at_check_pattern], [2], [luke@mewburn.net])

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
