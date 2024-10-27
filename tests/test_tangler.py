
"""Tangler tests exercise various semantic features."""
import io
import logging
import os
from pathlib import Path
from typing import ClassVar, TextIO

import pytest

import pyweb



test2_w = """Some anonymous chunk
@o test2.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
Okay, now for some errors: no part2!
"""

test3_w = """Some anonymous chunk
@o test3.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
@d part2 @{This is part 2, with an illegal: @f.@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""

test4_w = """Some anonymous chunk
@o test4.tmp
@{@<part1...@>
@<part2@>
@}@@
@d part1... @{This is part 1.@}
@d part2 @{This is part 2.@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""

test5_w = """
Some anonymous chunk
@o test5.tmp
@{@<part1...@>
@<part2@>
@}@@
@d part1a @{This is part 1 a.@}
@d part1b @{This is part 1 b.@}
@d part2 @{This is part 2.@}
Okay, now for some errors: part1... is ambiguous
"""



tangle_cases = [
    (test2_w, "test2.w", "Attempt to tangle an undefined Chunk, 'part2'"),
    (test3_w, "test3.w", "Illegal tangling of a cross reference command."),
    (test4_w, "test4.w", "No full name for 'part1...'"),
    (test5_w, "test5.w", "Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']"),
]

@pytest.fixture(params=tangle_cases)
def source_reader_path_tangler_error(request, tmp_path) -> [TextIO, pyweb.WebReader, Path, pyweb.Tangler, str]:
    text, name, error = request.param
    source = io.StringIO(text)
    rdr = pyweb.WebReader()
    path = tmp_path / name
    tangler = pyweb.Tangler(tmp_path)
    yield source, rdr, path, tangler, error
    for output in tmp_path.glob("*.tmp"):
        output.unlink()


def test_tangle_and_check_exception(source_reader_path_tangler_error) -> None:
    source, rdr, file_path, tangler, exception_text = source_reader_path_tangler_error

    with pytest.raises(pyweb.Error) as exc_info:
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        tangler.emit(web)
        assert False, "Should not tangle"
    assert exception_text == exc_info.value.args[0]


 

test6_w = """Some anonymous chunk
@o test6.tmp
@{@<part1...@>
@<part1a@>
@}@@
@d part1a @{This is part 1 a.@}
@d part2 @{This is part 2.@}
Okay, now for some warnings: 
- part1 has multiple references.
- part2 is unreferenced.
"""


@pytest.mark.text_name(test6_w, "test6.w")
def test_tangle_warnings(tmp_path, source_path) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    tangler = pyweb.Tangler(tmp_path)
    tangler.emit(web)
    print(web.no_reference())
    assert 1 == len(web.no_reference())
    assert 1 == len(web.multi_reference())
    assert {'part1a', 'part1...'} == tangler.reference_names



test7_w = """
Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test7_inc.tmp
A final anonymous chunk from test7.w
"""

test7_inc_w = """The test7a.tmp chunk for test7.w"""


@pytest.mark.text_name_incl(test7_w, "test7.w", test7_inc_w, 'test7_inc.tmp')
def test_tangle_should_include(tmp_path, source_path_incl) -> None:
    source, file_path = source_path_incl
    rdr = pyweb.WebReader()

    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    tangler = pyweb.Tangler(tmp_path)
    tangler.emit(web)
    assert 5 == len(web.chunks)
    assert test7_inc_w == web.chunks[3].commands[0].text

