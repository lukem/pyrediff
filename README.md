README
======

This project contains a collection of AWK scripts, Python scripts,
and autotest (part of [autoconf](https://www.gnu.org/software/autoconf/))
m4 macros.

## Table of Contents

  * [`pyrediff`](#pyrediff)
  * [`check_pattern.awk`](#check_patternawk)
  * [autotest m4 macros](#autotest-macros), including:
    * [`AX_AT_CHECK_PATTERN()`](#macro-ax_at_check_patterncommands-status0-stdout-re-stderr-re-run-if-fail-run-if-pass)
    * [`AX_AT_DIFF_PATTERN()`](#macro-ax_at_diff_patternpattern-file-test-file-status0-differences-run-if-fail-run-if-pass)
    * [`AX_AT_CHECK_PYREDIFF()`](#macro-ax_at_check_pyrediffcommands-status0-stdout-re-stderr-re-run-if-fail-run-if-pass)
    * [`AX_AT_DIFF_PYRE()`](#macro-ax_at_diff_pyrepyre-file-test-file-status0-differences-run-if-fail-run-if-pass)
  * [Examples](#examples)
  * [Copyright](#copyright)
  * [Workflow status](#workflow-status)

## pyrediff

`pyrediff` is a Python script to perform pattern-aware comparison of
`PATTERN` and `OUTPUT` files to remove blocks that don't differ if a given
[Python regular expression](https://docs.python.org/3/library/re.html)
(*pyre*) line in `PATTERN` matches
the equivalent line in `OUTPUT`.

Named groups `(?P<name>...)` can be used in subsequent patterns
with `\g<name>`; see [example 3](#example-3-pyre-pgroup-and-ggroup).

`pyrediff` supports three different modes of operation:
  1. `pyrediff PATTERN OUTPUT`: compare `PATTERN` and `OUTPUT`, writing
     mismatches to stdout.
  2. `pyrediff -e INPUT`: escape the pattern characters in INPUT, writing
     the result to stdout.
  3. `pyrediff -f`: filter the output of `diff PATTERN OUTPUT`.

Named groups are supported.
Strings captured in a named group using `(?P<name>...)` can
be used in the current pattern line with the backreference `(?P=name)`
and in subsequent pattern lines with `\g<name>`.
In the latter, occurrences of `\g<name>` in the pattern line will be
replaced with a previously captured value before the pattern is applied.
See [example 3](#example-3-pyre-pgroup-and-ggroup).

> **Note**: `pyrediff PATTERN OUTPUT` post-processes the output of `diff`.
> Complex regular expressions, and/or lots of non-alphanumeric escaping
> in `PATTERN` may cause `diff` to generate output as added and removed
> lines at different line offsets (instead of changed lines),
> preventing `pyrediff` from applying the `PATTERN` correctly.

The `pyrediff` usage is:
```
Usage: pyrediff PATTERN OUTPUT
       pyrediff -e INPUT
       pyrediff -f

Pattern-aware comparison of PATTERN and OUTPUT. Similar to diff(1), except
that PATTERN may contain python regular expressions. Strings captured in a
named group using (?P<name>...) can be used in subsequent pattern lines with
\g<name>; occurrences of \g<name> in the pattern line will be replaced with a
previously captured value before the pattern is applied.

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -e INPUT, --escape=INPUT
                        escape INPUT to stdout instead of diffing
  -f, --filter          filter stdin, which is the output of `diff PATTERN
                        OUTPUT`
```


## check\_pattern.awk

`check_pattern.awk` is an AWK script to post-process the output of
`diff PATTERN OUTPUT` to remove blocks that don't differ if a
given AWK regular expression line in `PATTERN` matches
the equivalent line in `OUTPUT`.

The script is usually invoked as:

```
% diff pattern output | awk -f check_pattern.awk
```

## autotest macros

Various autotest
([autoconf](https://www.gnu.org/software/autoconf/))
m4 macros are provided with pattern (AWK regular expression)
and pyre (Python regular expression) support.

> **Note**: As autoconf uses [] for quoting, the use of [brackets] in the
> macro arguments _stdout-re_ and _stderr-re_ can be awkward and require
> careful extra quoting, or quadrigraphs `@<:@` (for `[`) and `@:>@` (for `]`).

### AWK regular expression patterns

Macros that support AWK regular expressions in the pattern:

#### Macro: `AX_AT_CHECK_PATTERN(`_commands_, [_status_=`0`], [_stdout-re_], [_stderr-re_], [_run-if-fail_], [_run-if-pass_]`)`

Similar to `AT_CHECK()`, except that _stdout-re_ and _stderr-re_ are
AWK regular expressions (REs).

Using `AT_CHECK()`, runs _commands_ in a subshell, which are expected to
have an exit status of _status_, and to generate `stdout` to match the
pattern _stdout-re_ and `stderr` to match the pattern _stderr-re_.
The `AT_CHECK()` support for special values for _stdout-re_ and _stderr-re_
of `ignore`, `stdout`, `stderr`, (etc) is available.

#### Macro: `AX_AT_DIFF_PATTERN(`_pattern-file_, _test-file_, [_status_=`0`], [_differences_], [_run-if-fail_], [_run-if-pass_]`)`

Checks that an AWK pattern file _pattern-file_ applies to a test file _test_file_,
using `AT_CHECK()`, with expected `diff` differences in _differences_.

#### Macro: `AX_AT_DATA_CHECK_PATTERN_AWK(`_filename_`)`

Create the file _filename_ with the contents of the AWK script used by
`AX_AT_CHECK_PATTERN()` and `AX_AT_DIFF_PATTERN()`.
This is the same as the [check\_pattern.awk](#check_patternawk) script.

### Python regular expression (pyre) patterns

Macros that support
[Python regular expressions](https://docs.python.org/3/library/re.html):

#### Macro: `AX_AT_CHECK_PYREDIFF(`_commands_, [_status_=`0`], [_stdout-re_], [_stderr-re_], [_run-if-fail_], [_run-if-pass_]`)`

Similar to `AT_CHECK()`, except that _stdout-re_ and _stderr-re_ are
Python regular expressions (pyre).

Using `AT_CHECK()`, runs _commands_ in a subshell, which are expected to
have an exit status of _status_, and to generate `stdout` to match the
pyre (Python regular expression) _stdout-re_ and `stderr` to match the pyre _stderr-re_.
The `AT_CHECK()` support for special values for _stdout-re_ and _stderr-re_
of `ignore`, `stdout`, `stderr`, (etc) is available.

#### Macro: `AX_AT_DIFF_PYRE(`_pyre-file_, _test-file_, [_status_=`0`], [_differences_], [_run-if-fail_], [_run-if-pass_]`)`

Checks that a pyre file _pyre-file_ applies to a test file _test-file_,
using `AT_CHECK()`, with expected `diff` differences in _differences_.

#### Macro: `AX_AT_DATA_PYREDIFF_PY(`_filename_`)`

Create a file _filename_ with the contents of the Python script used by
`AX_AT_CHECK_PYREDIFF()` and `AX_AT_DIFF_PYRE()`.
This is the same as the [pyrediff](#pyrediff) script.

## Examples

### Example 1: Simple example

Given pattern file `1.pattern`:

```
First line
Second line with a date .*\.
```

and output file `1.output`:

```
First line
Second line with a date 2014-11-22T16:41:00.
```

the output of `diff 1.pattern 1.output` is:

```
% diff 1.pattern 1.output
2c2
< Second line with a date .*\.
---
> Second line with a date 2014-11-22T16:41:00.
```

and filtered with `awk -f check_pattern.awk`:

```
% diff 1.pattern 1.output | awk -f check_pattern.awk
```

or filtered with `pyrediff`:

```
% diff 1.pattern 1.output | pyrediff -f
```

or processed with `pyrediff`:

```
% pyrediff 1.pattern 1.output
```

There is no output because the regex on the second line of 1.pattern
matches that of the second line of 1.output.

### Example 2: Extra lines in output

Given pattern file `2.pattern`:

```
line 1 [0-9]+\.[0-9]+s
line 2
line 3
line 4
```

and output file `2.output`:

```
line 1 25.63s
line 2
line 3
line 3b extra
line 4
```

the output of `diff 2.pattern 2.output` is:

```
% diff 2.pattern 2.output
1c1
< line 1 [0-9]+\.[0-9]+s
---
> line 1 25.63s
3a4
> line 3b extra
```

and filtered with `awk -f check_pattern.awk` the only output is the extra line `line 3b extra`:

```
% diff 2.pattern 2.output | awk -f check_pattern.awk
3a4
> line 3b extra
```

(with an exit status of 1),
or filtered with `pyrediff`:

```
% diff 2.pattern 2.output | pyrediff -f
3a4
> line 3b extra
```

(with an exit status of 1),
or processed with `pyrediff`:

```
% pyrediff 2.pattern 2.output
3a4
> line 3b extra
```

(with an exit status of 1).

### Example 3: pyre `(?P<group>)` and `\g<group>`

Given pattern file `3.pattern`:

```
pid (?P<Pid>\d+) again=(?P=Pid)
second
third,\g<Pid>\g<Pid>
```

and output file `3.output` created with:

```
% ( echo "pid $$ again=$$"; echo "second"; echo "third,$$$$" ) > 3.output

% cat 3.output
pid 2211 again=2211
second
third,22112211
```

and filtered with `pyrediff`:

```
% diff 3.pattern 3.output | pyrediff -f
```

or processed with `pyrediff`:

```
% pyrediff 3.pattern 3.output
```

There is no output because the occurrences of `\g<Pid>` in the pattern line `third,\g<Pid>\g<Pid>` are replaced by the value of named group `Pid` captured from the `(?P<Pid>\d+)` in the first pattern.

### Example 4: Missing lines in output

Given pattern file `4.pattern`:

```
line 1 [0-9]+\.[0-9]+s
line 2
line 3
l..e 4
line 5 extra
line 6
line 7.*
line 8
line 9
```

and output file `4.output`:

```
line 1 25.63s
line 2
line 3
line 4
line 6
line 7 match any
line 8
```

the output of `diff 4.pattern 4.output` is:

```
% diff 4.pattern 4.output
1c1
< line 1 [0-9]+\.[0-9]+s
---
> line 1 25.63s
4,5c4
< l..e 4
< line 5 extra
---
> line 4
7c6
< line 7.*
---
> line 7 match any
9d7
< line 9
```

and filtered with `awk -f check_pattern.awk` the output is missing `line 5 extra` and `line 9`:

```
% diff 4.pattern 4.output | awk -f check_pattern.awk
4,5c4
< l..e 4
< line 5 extra
---
> line 4
9d7
< line 9
```

(with an exit status of 1),
or filtered with `pyrediff`:

```
% diff 4.pattern 4.output | pyrediff -f
4,5c4
< l..e 4
< line 5 extra
---
> line 4
9d7
< line 9
```

(with an exit status of 1),
or processed with `pyrediff`:

```
% pyrediff 4.pattern 4.output
4,5c4
< l..e 4
< line 5 extra
---
> line 4
9d7
< line 9
```

(with an exit status of 1).

## Copyright

Copyright (c) 2013-2024, Luke Mewburn <luke@mewburn.net>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.

---

## Workflow status

![Build](https://github.com/lukem/pyrediff/actions/workflows/makefile.yml/badge.svg)
![Pylint workflow](https://github.com/lukem/pyrediff/actions/workflows/pylint.yml/badge.svg)
