TESTSUITE = \
	$(srcdir)/testsuite

AUTOTEST = \
	$(AUTOM4TE) --language=autotest

TESTSUITE_DEPS = \
	$(srcdir)/package.m4 \
	$(top_srcdir)/src/ax_at_check_pattern.m4 \
	$(top_srcdir)/src/ax_at_check_pyrediff.m4 \
	01-simple.at \
	02-trivial.at \
	03-complex.at \
	04-trivial-bad.at \
	05-complex-diffs.at \
	06-extract.at \
	07-quoting.at \
	08-example1.at \
	09-example2.at \
	10-example3.at \
	11-group-escape.at \
	12-example4.at \
	13-escape.at \
	14-group-unknown.at \
	15-alternation-bad.at \
	16-alternation-optional.at \
	17-version.at \
	local.at \
	testsuite.at

DISTCLEANFILES = \
	atconfig \
	atlocal

EXTRA_DIST = \
	$(TESTSUITE) \
	$(TESTSUITE_DEPS) \
	13-escape.in \
	13-escape.re \
	atlocal.in

$(srcdir)/package.m4: $(top_srcdir)/configure.ac
	:; { \
	echo '# Signature of the current package.'; \
	echo 'm4_define([AT_PACKAGE_NAME],      [@PACKAGE_NAME@])'; \
	echo 'm4_define([AT_PACKAGE_TARNAME],   [@PACKAGE_TARNAME@])'; \
	echo 'm4_define([AT_PACKAGE_VERSION],   [@PACKAGE_VERSION@])'; \
	echo 'm4_define([AT_PACKAGE_STRING],    [@PACKAGE_STRING@])'; \
	echo 'm4_define([AT_PACKAGE_BUGREPORT], [@PACKAGE_BUGREPORT@])'; \
	} >'$(srcdir)/package.m4'

all-local: $(TESTSUITE)

check-local: atconfig atlocal $(TESTSUITE)
	$(SHELL) '$(TESTSUITE)' $(TESTSUITEFLAGS)

clean-local:
	test ! -f '$(TESTSUITE)' || $(SHELL) '$(TESTSUITE)' --clean

$(TESTSUITE): @MAINTAINER_MODE_TRUE@ $(TESTSUITE_DEPS)
	$(AM_V_GEN)$(AUTOTEST) \
		-I '$(top_srcdir)/src' \
		-I '$(srcdir)' \
		-o $@.tmp $@.at
	mv $@.tmp $@
