AC_PREREQ([2.69])
AC_INIT([pyrediff], [19], [luke@mewburn.net])

AC_COPYRIGHT([[
Copyright 2013-2024, Luke Mewburn <luke@mewburn.net>.
All rights reserved.
]])

AC_CONFIG_AUX_DIR([buildaux])
AC_CONFIG_MACRO_DIR([buildaux])

AM_INIT_AUTOMAKE([foreign nostdinc silent-rules -Werror -Wall])
AM_MAINTAINER_MODE()

AS_SHELL_SANITIZE()

AC_PROG_AWK()
AM_PATH_PYTHON()

AC_CONFIG_TESTDIR([tests])
AM_MISSING_PROG([AUTOM4TE], [autom4te])

AC_CONFIG_FILES([
	Makefile
	tests/Makefile
	tests/atlocal
])

AC_OUTPUT()

AC_MSG_NOTICE([ === Configuration results ===])
AC_MSG_NOTICE([Version:             $PACKAGE_VERSION])
AC_MSG_NOTICE([AWK:                 $AWK])
AC_MSG_NOTICE([PYTHON:              $PYTHON])
AC_MSG_NOTICE([ =============================])
