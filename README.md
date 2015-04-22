README
======

This project contains a collection of scripts and autotest macros
offering the following functionality:

  * `check_pattern.awk` to post-process the output of `diff PATTERN OUTPUT` to remove blocks that don't differ if a given line in PATTERN matches the equivalent OUTPUT line as an `awk` regular expression.
  * `pyrediff.py` to post-process the output of `diff PYRE OUTPUT` to remove blocks that don't differ if a given line in PYRE matches the equivalent OUTPUT line as a `python` regular expression. Named groups `(?P<name>...)` can be used in subsequent patterns with `\g<name>`.
  * autotest checks with pattern (`awk` regular expression) and pyre (`python` regular expression) support.

(autotest is part of [autoconf](https://www.gnu.org/software/autoconf/))

Available autotest Macros
-------------------------

### awk regex patterns

Macros that support awk regular expressions in the pattern:

  * `AX_AT_CHECK_PATTERN()`: similar to `AT_CHECK()`, except that stdout and stderr are awk regular expressions (REs).
  * `AX_AT_DIFF_PATTERN()`: checks that a pattern file applies to a test file.
  * `AX_AT_DATA_CHECK_PATTERN_AWK()`: create a file with the contents of the awk script used by `AX_AT_CHECK_PATTERN()` and `AX_AT_DIFF_PATTERN()`.

### Support for python re (pyre) patterns

Macros that support python regular expressions in the pattern:

  * `AX_AT_CHECK_PYREDIFF()`: similar to `AT_CHECK()`, except that stdout and stderr are python regular expressions (REs).
  * `AX_AT_DIFF_PYRE()`: checks that a pattern file applies to a test file.
  * `AX_AT_DATA_PYREDIFF_PY()`: create a file with the contents of the python script used by `AX_AT_CHECK_PYREDIFF()` and `AX_AT_DIFF_PYRE()`.

Examples
--------

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

Copyright
---------

Copyright (c) 2013-2015 Luke Mewburn <luke@mewburn.net>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
