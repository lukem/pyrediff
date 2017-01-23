# SYNOPSIS
#
#   AX_AT_CHECK_PYREDIFF(COMMANDS, [STATUS], [STDOUT-RE], [STDERR-RE], [RUN-IF-FAIL], [RUN-IF-PASS])
#   AX_AT_DIFF_PYRE(PYRE-FILE, TEST-FILE, [STATUS=0], [DIFFERENCES])
#   AX_AT_DATA_PYREDIFF_PY(FILENAME)
#
# DESCRIPTION
#
#   AX_AT_CHECK_PYREDIFF() executes a test similar to AT_CHECK(), except
#   that stdout and stderr are python regular expressions (REs).
#
#   NOTE: as autoconf uses [] for quoting, the use of [brackets] in the RE
#   arguments STDOUT-RE and STDERR-RE can be awkward and require careful
#   extra quoting, or quadrigraphs '@<:@' (for '[') and '@:>@' (for ']').
#
#   python is invoked via $PYTHON, which defaults to "python" if unset or empty.
#
#   Implemented using AT_CHECK() with a custom value for $at_diff that
#   invokes diff with a python post-processor.
#
#
#   AX_AT_DIFF_PYRE() checks that the PYRE-FILE applies to TEST-FILE.
#   If there are differences, STATUS will be 1 and they should be DIFFERENCES.
#
#
#   AX_AT_DATA_PYREDIFF_PY() creates FILENAME with the contents of
#   the python script used.
#
#
#   The latest version of this macro and a supporting test suite are at:
#   https://github.com/lukem/ax_at_check_pattern
#
#
# LICENSE
#
#   Copyright (c) 2015 Luke Mewburn <luke@mewburn.net>
#
#   Copying and distribution of this file, with or without modification,
#   are permitted in any medium without royalty provided the copyright
#   notice and this notice are preserved.  This file is offered as-is,
#   without any warranty.

#serial 10

m4_define([_AX_AT_CHECK_PYREDIFF],
[[import optparse
import re
import subprocess
import sys


class Pyrediff:
    apat = re.compile("^\d+(,\d+)?@<:@ad@:>@\d+(,\d+)?@S|@")
    cpat = re.compile("^\d+(,\d+)?@<:@c@:>@\d+(,\d+)?@S|@")

    def diff(self, input):
        self.fail = False
        self.set_mode()
        self.groups = {}
        for line in input:
            self.diff_line(line.rstrip("\n"))
        if len(self.patlines) > len(self.strlines):
            self.mismatch()
        return self.fail

    def escape(self, input_name):
        fp = open(input_name, "r")
        try:
            for line in fp:
                esc = re.escape(line)
                esc = re.sub(r"\\(@<:@-\s!\"#@S|@&'%,/:;<=>@_`~@:>@)", r"\1", esc)
                sys.stdout.write(esc)
        finally:
            fp.close()

    def diff_line(self, line):
        if self.apat.match(line):
            print line
            self.set_mode()
            self.fail = True
        elif self.cpat.match(line):
            self.set_mode(line)
        elif self.mode is None:
            print line
        elif line.startswith("< "):
            self.patlines.append(line)
        elif "---" == line:
            pass
        elif line.startswith("> "):
            self.strlines.append(line)
            if len(self.strlines) > len(self.patlines):
                self.mismatch()
            else:
                pat = re.sub(r"\\g<(@<:@^>@:>@+)>", self.repl_groups,
                             self.patlines@<:@len(self.strlines)-1@:>@@<:@2:@:>@)
                raw = line@<:@2:@:>@
                match = re.search("^%s@S|@" % pat, raw)
                if match is None:
                    self.mismatch()
                elif match.lastgroup is not None:
                    for k, v in match.groupdict().iteritems():
                        self.groups@<:@k@:>@ = re.escape(v)
        else:
            raise NotImplementedError("unexpected line=%r" % line)

    def mismatch(self):
        print self.mode
        print "\n".join(self.patlines)
        print "---"
        print "\n".join(self.strlines)
        self.set_mode()
        self.fail = True

    def repl_groups(self, match):
        if match.group(1) in self.groups:
            return self.groups@<:@match.group(1)@:>@
        else:
            return match.string

    def set_mode(self, mode=None):
        self.mode = mode
        self.patlines = @<:@@:>@
        self.strlines = @<:@@:>@

    def parse_args(self):
        parser = optparse.OptionParser(
            usage="""%prog PATTERN OUTPUT
       %prog -e INPUT
       %prog -f\
""",
            description="""\
Pattern-aware comparison of PATTERN and OUTPUT.
Similar to diff(1), except that PATTERN may contain python regular expressions.
Strings captured in a named group using (?P<name>...) can be used in subsequent
pattern lines with \g<name>; occurrences of \g<name> in the pattern line will
be replaced with a previously captured value before the pattern is applied.
""")
        parser.add_option(
            "-e", "--escape",
            metavar="INPUT",
            help="escape INPUT to stdout instead of diffing")
        parser.add_option(
            "-f", "--filter",
            action="store_true",
            default=False,
            help="filter stdin, which is the output of `diff PATTERN OUTPUT`")
        (self.opts, self.args) = parser.parse_args()
        modes = 0
        if self.opts.escape is not None:
            modes += 1
        if self.opts.filter:
            modes += 1
        if modes > 1:
            parser.error("-e and -f and mutually exclusive")
        elif modes == 1:
            if len(self.args) != 0:
                parser.error("incorrect number of arguments")
        else:
            if len(self.args) != 2:
                parser.error("incorrect number of arguments")

    def main(self):
        self.parse_args()
        if self.opts.escape is not None:
            self.escape(self.opts.escape)
        elif self.opts.filter:
            if self.diff(sys.stdin):
                sys.exit(1)
        else:
            pipe = subprocess.Popen(@<:@"diff", self.args@<:@0@:>@, self.args@<:@1@:>@@:>@,
                                    stdout=subprocess.PIPE)
            if self.diff(pipe.stdout):
                sys.exit(1)
            prv = pipe.wait()
            if prv > 1:
                sys.exit(prv)

if "__main__" == __name__:
    Pyrediff().main()
]])


m4_defun([_AX_AT_CHECK_PYRE_PREPARE], [dnl
dnl Can't use AM_PATH_PYTHON() in autotest.
AS_VAR_IF([PYTHON], [], [PYTHON=python])

AS_REQUIRE_SHELL_FN([ax_at_diff_pyre],
  [AS_FUNCTION_DESCRIBE([ax_at_diff_pyre], [PYRE OUTPUT],
    [Diff PYRE OUTPUT and elide change lines where the python RE matches])],
  [$PYTHON -c 'm4_bpatsubst(_AX_AT_CHECK_PYREDIFF,','\\'')' "$[]1" "$[]2"])
])dnl _AX_AT_CHECK_PYRE_PREPARE


m4_defun([AX_AT_CHECK_PYREDIFF], [dnl
AS_REQUIRE([_AX_AT_CHECK_PYRE_PREPARE])
_ax_at_check_pyrediff_prepare_original_at_diff="$at_diff"
at_diff='ax_at_diff_pyre'
AT_CHECK(m4_expand([$1]), [$2], m4_expand([$3]), m4_expand([$4]),
        [at_diff="$_ax_at_check_pyrediff_prepare_original_at_diff";$5],
        [at_diff="$_ax_at_check_pyrediff_prepare_original_at_diff";$6])
])dnl AX_AT_CHECK_PYREDIFF


m4_defun([AX_AT_DIFF_PYRE], [dnl
AS_REQUIRE([_AX_AT_CHECK_PYRE_PREPARE])
AT_CHECK([ax_at_diff_pyre $1 $2], [$3], [$4])
])dnl AX_AT_DIFF_PYRE


m4_defun([AX_AT_DATA_PYREDIFF_PY], [dnl
m4_if([$1], [], [m4_fatal([$0: argument 1: empty filename])])
AT_DATA([$1], [dnl
#!/usr/bin/env python
#
# pyrediff
# Generated by AX_AT_DATA_PYREDIFF_PY@{:@@:}@
# from https://github.com/lukem/ax_at_check_pattern
#
# python script to process the output of "diff PYRE OUTPUT" removing lines
# where the difference is a PYRE line that exactly matches an OUTPUT line.
#
#
# Copyright (c) 2015-2017 Luke Mewburn <luke@mewburn.net>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
]
_AX_AT_CHECK_PYREDIFF)
])dnl AX_AT_DATA_PYREDIFF_PY
