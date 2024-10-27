Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-   `Tests for Loading`_

-   `Tests for Tangling`_

-   `Tests for Weaving`_

Because of some overlaps in fixture definition, there is also a ``conftest.py`` file that contains the shared test fixtures.

Shared Fixtures
---------------

@o tests/conftest.py
@{
import io
from pathlib import Path
from typing import TextIO
import pytest
import pyweb

@<Fixture for Source, WebReader, and Path@>

@<Fixture for Source, WebReader, Path, with an Include@>
@}

These fixtures require a "marker" set in each test that uses them.
The marker provides needed parameter values.

Many of the parsing test cases have a common setup shown in this fixture.

@d Fixture for Source, WebReader, and Path...
@{
@@pytest.fixture
def source_path(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
    marker = request.node.get_closest_marker("text_name")
    text, name = marker.args
    source = io.StringIO(text)
    path = tmp_path / name
    return source, path
@}

Some of the more complex cases inject an Include file.
This requires a somewhat more complicated fixture.

@d Fixture for Source, WebReader, Path, with an Include
@{
@@pytest.fixture
def source_path_incl(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
    marker = request.node.get_closest_marker("text_name_incl")
    text, name, incl_text, incl_name = marker.args
    include_path = tmp_path / incl_name
    include_path.write_text(incl_text)
    source = io.StringIO(text)
    path = tmp_path / name
    return source, path
@}

Additionally, a ``pytest.ini`` is also required to register the marks used to provide test parameters to a fixture.
This also sets a logging format to assure the log messages have the expected format.

@o pytest.ini
@{
[pytest]
markers =
    text_name: a blob of text, the path name
    text_name_incl: a blob of text, a path, a blob of include text, the include path
log_format = %(levelname)s:%(name)s:%(message)s
@}

Tests for Loading
------------------

We need to be able to load a web from one or more source files.

@o tests/test_loader.py
@{@<Load Test overheads: imports, etc.@>

@<Load Test error handling with a few common syntax errors@>

@<Load Test include processing with syntax errors@>
@}

There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to  find an expected next token.

@d Load Test error handling...
@{

@<Sample Document 1 with correct and incorrect syntax@>

@@pytest.mark.text_name(test1_w, "test1.w")
def test_error_should_count_1(source_path, caplog):
    source, file_path = source_path
    rdr = pyweb.WebReader()

    with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
        chunks = rdr.load(file_path, source)
    assert 3 == rdr.errors
    assert caplog.text.splitlines() == [
        "ERROR:WebReader:At ('test1.w', 8): expected {'@@{'}, found '@@o'",
        "ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)",
        "ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)"
    ]
@}

@d Sample Document 1...
@{
test1_w = """Some anonymous chunk
@@o test1.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
Okay, now for an error.
@@o show how @@o commands work
@@{ @@{ @@] @@]
"""
@}

All of the parsing exceptions should be correctly identified with any included file.
We'll cover most of the cases with a quick check for a failure to find an expected next token.

In order to test the include file processing, we have to actually create a temporary file.
It's hard to mock the include processing, since it's a nested instance of the tokenizer.

@d Load Test include...
@{
@<Sample Document 8 and the file it includes@>

@@pytest.mark.text_name_incl(test8_w, "test8.w", test8_inc_w, 'test8_inc.w')
def test_error_should_count_2(caplog, tmp_path, source_path_incl) -> None:
    source, file_path = source_path_incl
    rdr = pyweb.WebReader()
    with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
        chunks = rdr.load(file_path, source)
    assert 1 == rdr.errors
    assert caplog.text.splitlines() == [
        "ERROR:WebReader:At ('test8_inc.w', 4): end of input, {'@@{', '@@['} not found",
        "ERROR:WebReader:Errors in included file 'test8_inc.w', output is incomplete."
    ]
@}

The sample document must reference the correct name that will be given to the included document by ``setUp``.

@d Sample Document 8...
@{
test8_w = """Some anonymous chunk.
@@d title @@[the title of this document, defined with @@@@[ and @@@@]@@]
A reference to @@<title@@>.
@@i test8_inc.w
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@@d yap
"""
@}

The overheads for a Python test.

@d Load Test overheads...
@{
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
@}

Tests for Tangling
------------------

We need to be able to tangle a web.

@o tests/test_tangler.py
@{@<Tangle Test overheads: imports, etc.@>

@<Tangle Test semantic errors 2-5@>

@<Tangle Test fixture to refactor common setup@>
@<Tangle Test function to execute cases@>

@<Tangle Test semantic error 6@>
@<Tangle Test include example 7@>
@}

Tangling test cases have a common setup and teardown shown in this fixture.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the exceptions raised.

Since these test cases are all very similar, we can use a parameterized fixture to execute a single test function repeatedly.

@d Tangle Test fixture...
@{
tangle_cases = [
    (test2_w, "test2.w", "Attempt to tangle an undefined Chunk, 'part2'"),
    (test3_w, "test3.w", "Illegal tangling of a cross reference command."),
    (test4_w, "test4.w", "No full name for 'part1...'"),
    (test5_w, "test5.w", "Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']"),
]

@@pytest.fixture(params=tangle_cases)
def source_reader_path_tangler_error(request, tmp_path) -> [TextIO, pyweb.WebReader, Path, pyweb.Tangler, str]:
    text, name, error = request.param
    source = io.StringIO(text)
    rdr = pyweb.WebReader()
    path = tmp_path / name
    tangler = pyweb.Tangler(tmp_path)
    yield source, rdr, path, tangler, error
    for output in tmp_path.glob("*.tmp"):
        output.unlink()
@}

@d Tangle Test function...
@{
def test_tangle_and_check_exception(source_reader_path_tangler_error) -> None:
    source, rdr, file_path, tangler, exception_text = source_reader_path_tangler_error

    with pytest.raises(pyweb.Error) as exc_info:
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        tangler.emit(web)
        assert False, "Should not tangle"
    assert exception_text == exc_info.value.args[0]
@}

@d Tangle Test semantic errors 2-5...
@{
test2_w = """Some anonymous chunk
@@o test2.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
Okay, now for some errors: no part2!
"""

test3_w = """Some anonymous chunk
@@o test3.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
@@d part2 @@{This is part 2, with an illegal: @@f.@@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""

test4_w = """Some anonymous chunk
@@o test4.tmp
@@{@@<part1...@@>
@@<part2@@>
@@}@@@@
@@d part1... @@{This is part 1.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""

test5_w = """
Some anonymous chunk
@@o test5.tmp
@@{@@<part1...@@>
@@<part2@@>
@@}@@@@
@@d part1a @@{This is part 1 a.@@}
@@d part1b @@{This is part 1 b.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some errors: part1... is ambiguous
"""
@}

The remaining errors have unique features, and can't use the generic test function.
The first of these looks for a number of warnings, instead of an exception.

@d Tangle Test semantic error 6... 
@{ 
@<Sample Document 6@>

@@pytest.mark.text_name(test6_w, "test6.w")
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
@}

@d Sample Document 6... @{
test6_w = """Some anonymous chunk
@@o test6.tmp
@@{@@<part1...@@>
@@<part1a@@>
@@}@@@@
@@d part1a @@{This is part 1 a.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some warnings: 
- part1 has multiple references.
- part2 is unreferenced.
"""
@}

@d Tangle Test include example 7...
@{
@<Sample Document 7 and it's included file@>

@@pytest.mark.text_name_incl(test7_w, "test7.w", test7_inc_w, 'test7_inc.tmp')
def test_tangle_should_include(tmp_path, source_path_incl) -> None:
    source, file_path = source_path_incl
    rdr = pyweb.WebReader()

    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    tangler = pyweb.Tangler(tmp_path)
    tangler.emit(web)
    assert 5 == len(web.chunks)
    assert test7_inc_w == web.chunks[3].commands[0].text
@}

@d Sample Document 7... @{
test7_w = """
Some anonymous chunk.
@@d title @@[the title of this document, defined with @@@@[ and @@@@]@@]
A reference to @@<title@@>.
@@i test7_inc.tmp
A final anonymous chunk from test7.w
"""

test7_inc_w = """The test7a.tmp chunk for test7.w"""
@}

@d Tangle Test overheads...
@{
"""Tangler tests exercise various semantic features."""
import io
import logging
import os
from pathlib import Path
from typing import ClassVar, TextIO

import pytest

import pyweb
@}


Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.

@o tests/test_weaver.py
@{@<Weave Test overheads: imports, etc.@>

@<Weave Test references and definitions@>
@<Weave Test evaluation of expressions@>
@}

Weaving test cases have a common setup shown in this fixture.

@d Weave Test references... @{
@<Sample Document 0@>
@<Expected Output 0@>


@@pytest.mark.text_name(test0_w, "test0.w")
def test_load_should_createChunks(source_path) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    assert 3 == len(chunks)
        
@@pytest.mark.text_name(test0_w, "test0.w")
def test_weave_should_create_html(tmp_path, source_path) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    web.web_path = file_path
    doc = pyweb.Weaver( )
    doc.set_markup("html")
    doc.output = tmp_path
    doc.emit(web)
    assert doc.target_path == file_path.with_suffix(".html")
    actual = doc.target_path.read_text()
    assert test0_expected_html == actual
        
@@pytest.mark.text_name(test0_w, "test0.w")
def test_weave_should_create_debug(tmp_path, source_path) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    web.web_path = file_path
    doc = pyweb.Weaver( )
    doc.set_markup("debug")
    doc.output = tmp_path
    doc.emit(web)
    assert doc.target_path == file_path.with_suffix(".debug")
    actual = doc.target_path.read_text()
    assert test0_expected_debug == actual
@}

@d Sample Document 0... 
@{ 
test0_w = """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
@@<some code@@>

@@d some code 
@@{
def fastExp(n, p):
    r = 1
    while p > 0:
        if p%2 == 1: return n*fastExp(n,p-1)
    return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)
@@}
</body>
</html>
"""
@}

@d Expected Output 0... @{
test0_expected_html = """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
&rarr;<a href="#pyweb_1"><em>some code (1)</em></a>


<a name="pyweb_1"></a>
<!--line number ('test0.w', 10)-->
<p><em>some code (1)</em> =</p>
<pre><code>
def fastExp(n, p):
    r = 1
    while p &gt; 0:
        if p%2 == 1: return n*fastExp(n,p-1)
    return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)

</code></pre>
<p>&#8718; <em>some code (1)</em>.

</p> 

</body>
</html>
"""
@}

@d Expected Output 0... @{
test0_expected_debug = (
    'text: TextCommand(text=\'<html>\\n<head>\\n    <link rel="StyleSheet" href="pyweb.css" type="text/css" />\\n</head>\\n<body>\\n\', location=(\'test0.w\', 1))\n'
    "ref: ReferenceCommand(name='some code', location=('test0.w', 6))"
    "text: TextCommand(text='\\n\\n', location=('test0.w', 7))\n"
    "begin_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
    "code: CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))\n"
    "end_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
    "text: TextCommand(text='\\n</body>\\n</html>\\n', location=('test0.w', 19))"
    )
@}

Note that this requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.

@d Weave Test evaluation... @{
@<Sample Document 9@>

from unittest.mock import Mock

@@pytest.fixture()
def mock_time(monkeypatch):
    mock_time = Mock(asctime=Mock(return_value="mocked time"))
    monkeypatch.setattr(pyweb, "time", mock_time)
    return mock_time

@@pytest.mark.text_name(test9_w, "test9.w")
def test_should_evaluate(tmp_path, source_path, mock_time) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    web = pyweb.Web(chunks)
    web.web_path = file_path
    doc = pyweb.Weaver( )
    doc.set_markup("html")
    doc.output = tmp_path
    doc.emit(web)
    assert doc.target_path == file_path.with_suffix(".html")
    actual = doc.target_path.read_text().splitlines()
    #print(actual)
    assert "An anonymous chunk." == actual[0]
    assert "Time = mocked time" == actual[1]
    assert "File = ('test9.w', 3)" == actual[2]
    assert 'Version = 3.3' == actual[3]
    assert f'CWD = {os.getcwd()}' == actual[4]
@}

@d Sample Document 9...
@{
test9_w= """An anonymous chunk.
Time = @@(time.asctime()@@)
File = @@(theLocation@@)
Version = @@(__version__@@)
CWD = @@(os.path.realpath('.')@@)
"""
@}

@d Weave Test overheads...
@{
"""Weaver tests exercise various weaving features."""
import io
import logging
import os
from pathlib import Path
import string
import sys
from textwrap import dedent
from typing import ClassVar

import pytest

import pyweb
@}
