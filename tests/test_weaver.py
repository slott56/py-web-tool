
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



 
test0_w = """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
@<some code@>

@d some code 
@{
def fastExp(n, p):
    r = 1
    while p > 0:
        if p%2 == 1: return n*fastExp(n,p-1)
    return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)
@}
</body>
</html>
"""


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

test0_expected_debug = (
    'text: TextCommand(text=\'<html>\\n<head>\\n    <link rel="StyleSheet" href="pyweb.css" type="text/css" />\\n</head>\\n<body>\\n\', location=(\'test0.w\', 1))\n'
    "ref: ReferenceCommand(name='some code', location=('test0.w', 6))"
    "text: TextCommand(text='\\n\\n', location=('test0.w', 7))\n"
    "begin_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
    "code: CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))\n"
    "end_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
    "text: TextCommand(text='\\n</body>\\n</html>\\n', location=('test0.w', 19))"
    )



@pytest.mark.text_name(test0_w, "test0.w")
def test_load_should_createChunks(source_path) -> None:
    source, file_path = source_path
    rdr = pyweb.WebReader()
    chunks = rdr.load(file_path, source)
    assert 3 == len(chunks)
        
@pytest.mark.text_name(test0_w, "test0.w")
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
        
@pytest.mark.text_name(test0_w, "test0.w")
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



test9_w= """An anonymous chunk.
Time = @(time.asctime()@)
File = @(theLocation@)
Version = @(__version__@)
CWD = @(os.path.realpath('.')@)
"""


from unittest.mock import Mock

@pytest.fixture()
def mock_time(monkeypatch):
    mock_time = Mock(asctime=Mock(return_value="mocked time"))
    monkeypatch.setattr(pyweb, "time", mock_time)
    return mock_time

@pytest.mark.text_name(test9_w, "test9.w")
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

