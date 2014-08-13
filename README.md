README
======

This project contains a collection of autotest macros offering the
following functionality:

  * autotest checks with pattern (`awk` regular expression) support.

Available Macros
----------------

The following autotest macros are provided:

  * `AX_AT_CHECK_PATTERN()`: similar to `AT_CHECK()`, except that stdout and stderr are awk regular expressions (REs).
  * `AX_AT_DIFF_PATTERN()`: checks that a pattern file applies to a test file.
  * `AX_AT_DATA_CHECK_PATTERN_AWK()`: create a file with the contents of the awk script used by `AX_AT_CHECK_PATTERN()` and `AX_AT_DIFF_PATTERN()`.

Copyright
---------

Copyright (c) 2013-2014 Luke Mewburn <luke@mewburn.net>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
