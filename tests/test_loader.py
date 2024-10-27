
"""Loader and parsing tests."""
import io
import logging
import logging.handlers
import os
from pathlib import Path
import string
import sys
from textwrap import dedent
import types
from typing import TextIO

import pytest

import pyweb





test1_w = """Some anonymous chunk
@o test1.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
Okay, now for an error.
@o show how @o commands work
@{ @{ @] @]
"""


@pytest.mark.text_name(test1_w, "test1.w")
def test_error_should_count_1(source_path, caplog):
    source, file_path = source_path
    rdr = pyweb.WebReader()

    with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
        chunks = rdr.load(file_path, source)
    assert 3 == rdr.errors
    assert caplog.text.splitlines() == [
        "ERROR:WebReader:At ('test1.w', 8): expected {'@{'}, found '@o'",
        "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)",
        "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)"
    ]




test8_w = """Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test8_inc.w
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@d yap
"""


@pytest.mark.text_name_incl(test8_w, "test8.w", test8_inc_w, 'test8_inc.w')
def test_error_should_count_2(caplog, tmp_path, source_path_incl) -> None:
    source, file_path = source_path_incl
    rdr = pyweb.WebReader()
    with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
        chunks = rdr.load(file_path, source)
    assert 1 == rdr.errors
    assert caplog.text.splitlines() == [
        "ERROR:WebReader:At ('test8_inc.w', 4): end of input, {'@{', '@['} not found",
        "ERROR:WebReader:Errors in included file 'test8_inc.w', output is incomplete."
    ]

