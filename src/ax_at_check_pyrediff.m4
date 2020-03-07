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
#   AX_AT_DATA_PYREDIFF_PY() creates FILENAME with the contents of the python
#   script used. This should be same contents as the 'pyrediff' script.
#
#
#   The latest version of this macro and a supporting test suite are at:
#   https://github.com/lukem/pyrediff
#
#
# LICENSE
#
#   Copyright (c) 2015-2020 Luke Mewburn <luke@mewburn.net>
#
#   Copying and distribution of this file, with or without modification,
#   are permitted in any medium without royalty provided the copyright
#   notice and this notice are preserved.  This file is offered as-is,
#   without any warranty.

#serial 13

m4_define([_AX_AT_CHECK_PYREDIFF],
[[import io
import optparse
import re
import subprocess
import sys


class Pyrediff:
    _add_del_re = re.compile(r"^(\d+a\d+(,\d+)?|\d+(,\d+)?d\d+)@S|@")
    _change_re = re.compile(r"^\d+(,\d+)?c\d+(,\d+)?@S|@")
    _escape_re = re.compile(r"\\(@<:@-\s!\"#@S|@&%,/:;<=>@_`'~@:>@)")
    _group_re = re.compile(r"\\g<(@<:@^>@:>@+)>")

    def diff(self, input):
        self.fail = False
        self.set_mode()
        self.groups = {}
        for line in input:
            self.diff_line(line.rstrip("\n"))
        self.change_mode()
        return self.fail

    def escape(self, input_name):
        fp = open(input_name, "r")
        try:
            for line in fp:
                esc = re.escape(line)
                esc = self._escape_re.sub(r"\1", esc)
                sys.stdout.write(esc)
        finally:
            fp.close()

    def diff_line(self, line):
        if self._add_del_re.match(line):
            self.change_mode()
            print(line)
            self.fail = True
        elif self._change_re.match(line):
            self.change_mode(line)
        elif self.mode is None:
            print(line)
        elif line.startswith("< "):
            self.patlines.append(line)
        elif "---" == line:
            return
        elif line.startswith("> "):
            self.strlines.append(line)
            idx = len(self.strlines)-1
            if idx >= len(self.patlines):
                return self.mismatch()
            pat = self._group_re.sub(self.repl_groups, self.patlines@<:@idx@:>@@<:@2:@:>@)
            raw = line@<:@2:@:>@
            try:
                match = re.match("^(?:%s)@S|@" % pat, raw)
            except re.error as e:
                print("# ERROR: Pattern \"%s\": %s" % (pat, e))
                return self.mismatch()
            if match is None:
                return self.mismatch()
            elif match.lastgroup is not None:
                for k, v in match.groupdict().items():
                    self.groups@<:@k@:>@ = re.escape(v)
        else:
            raise NotImplementedError("unexpected line=%r" % line)

    def change_mode(self, mode=None):
        if len(self.patlines) > len(self.strlines):
            self.mismatch()
        self.set_mode(mode)

    def mismatch(self):
        print(self.mode)
        print("\n".join(self.patlines))
        print("---")
        print("\n".join(self.strlines))
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
pattern lines with \\g<name>; occurrences of \\g<name> in the pattern line will
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
            if sys.version_info < (3, 0):
                pout = pipe.stdout
            else:
                pout = io.TextIOWrapper(pipe.stdout)
            if self.diff(pout):
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
# pyrediff PATTERN OUTPUT
# pyrediff -e INPUT
# pyrediff -f
#
# pyrediff is a Python script to perform pattern-aware diff comparison
# of PATTERN and OUTPUT to remove blocks that don't differ if a given
# Python regular expression (pyre) line in PATTERN matches the equivalent
# line in OUTPUT.
#
# https://github.com/lukem/pyrediff
#
# Copyright (c) 2015-2020 Luke Mewburn <luke@mewburn.net>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
]
_AX_AT_CHECK_PYREDIFF)
])dnl AX_AT_DATA_PYREDIFF_PY
