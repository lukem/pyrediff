# Change Log

## [unreleased] - unreleased

### Fixed
- Fix `pyrediff` -e escaping to escape $.
- Import print_function.

## [14] - 2020-03-07

### Fixed
- Fix `AX_AT_CHECK_PATTERN()` exit value handling for unexpected lines.
- Distribute `CHANGELOG.md` and `README.md` in make dist.
- Support python 3 as well as python 2.6 or newer.


## [13] - 2017-08-17

### Fixed
- Correctly fail if the any diff change block has a shorter output than
the provided pattern. (Improved version of fix in [release/10](#10---2016-03-31))


## [12] - 2017-07-13

### Fixed
- Gracefully handle regex errors in the PATTERN file, including
  unknown `(?P=group)` or `\number` backreferences on the same line.
- Prevent false matching when the pattern contains an empty alternation
  at the start or end of the pattern.

### Changed
- Renamed project to `pyrediff` (from `ax_at_check_pattern`).


## [11] - 2017-01-23

### Changed
- Replace `NEWS` with `CHANGELOG.md`.
- Simplify `pyrediff` -e escaping: no need to escape whitespace or characters: ! # $ & ' ; ` ~


## [10] - 2016-03-31

### Fixed
- Correctly fail if the final diff block has a shorter output than
the provided pattern.


## [9] - 2015-11-22

### Fixed
- Fix \g<> handling when patterns are captured in `pyrediff`.

### Changed
- Simplify `pyrediff` -e escaping: no need to escape: " < >


## [8] - 2015-09-22

### Added
- Provide `pyrediff` as a standalone python application.
- Install `check_pattern.awk` and the `.m4` files.
- Add `NEWS`.


## [7] - 2015-07-06

### Changed
- Add copyright to generated `.awk` and `.py` files.


## [6] - 2015-04-23

### Fixed
- Fix multiline pattern comparison in `pyrediff`.

### Changed
- Support named group caching in `pyrediff`.


## [5] - 2015-04-20

### Added
- Provide `AX_AT_CHECK_PYREDIFF()` to use python RE (instead of awk RE),
also known as "pyrediff".
- Provide `AX_AT_DIFF_PYRE()`.
- Provide `AX_AT_DATA_PYREDIFF_PY()` to write a python script
containing the diff post-processor to a file.
- Provide `pyrediff.py` implementing the pyrediff functionality.
- Describe `check_pattern.awk`.

### Fixed
- Fix `AX_AT_CHECK_PATTERN()` to skip leading space in diff output.


## [4] - 2014-10-21

### Added
- Provide `AX_AT_DATA_CHECK_PATTERN_AWK()` to write an awk script
containing the diff post-processor to a file.
- Add `README`.

### Changed
- Improve `AX_AT_CHECK_PATTERN()` quoting and use quadrigraphs.
- Add references to github.


## [3] - 2014-07-02

### Added
- Provide `AX_AT_DIFF_PATTERN()`.


## [2] - 2014-07-02

### Fixed
- Fix testsuite assumptions about timezone.

### Changed
- Improve comments and documentation.


## [1] - 2013-12-17

### Added
- Initial release.
- Provide `AX_AT_CHECK_PATTERN()`.
