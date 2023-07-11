
"""Weaver tests exercise various weaving features."""
import io
import logging
import os
from pathlib import Path
import string
import sys
from textwrap import dedent
from typing import ClassVar
import unittest

import pyweb


class WeaveTestcase(unittest.TestCase):
    text: ClassVar[str]
    error: ClassVar[str]
    file_path: ClassVar[Path]
    
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.rdr = pyweb.WebReader()
        self.maxDiff = None

    def tearDown(self) -> None:
        try:
            self.file_path.with_suffix(".html").unlink()
        except FileNotFoundError:
            pass
        try:
            self.file_path.with_suffix(".debug").unlink()
        except FileNotFoundError:
            pass


 
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
    "begin_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)\n"
    "code: CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))\n"
    "end_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)\n"
    "text: TextCommand(text='\\n</body>\\n</html>\\n', location=('test0.w', 19))"
    )


class Test_RefDefWeave(WeaveTestcase):
    text = test0_w
    file_path = Path("test0.w")
    def test_load_should_createChunks(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(3, len(chunks))
        
    def test_weave_should_create_html(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        self.web.web_path = self.file_path
        doc = pyweb.Weaver( )
        doc.set_markup("html")
        doc.emit(self.web)
        actual = self.file_path.with_suffix(".html").read_text()
        self.maxDiff = None
        self.assertEqual(test0_expected_html, actual)
        
    def test_weave_should_create_debug(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        self.web.web_path = self.file_path
        doc = pyweb.Weaver( )
        doc.set_markup("debug")
        doc.emit(self.web)
        actual = self.file_path.with_suffix(".debug").read_text()
        self.maxDiff = None
        self.assertEqual(test0_expected_debug, actual)



test9_w= """An anonymous chunk.
Time = @(time.asctime()@)
File = @(theLocation@)
Version = @(__version__@)
CWD = @(os.path.realpath('.')@)
"""


from unittest.mock import Mock

class TestEvaluations(WeaveTestcase):
    text = test9_w
    file_path = Path("test9.w")
    def setUp(self):
        super().setUp()
        self.mock_time = Mock(asctime=Mock(return_value="mocked time"))
    def test_should_evaluate(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        self.web.web_path = self.file_path
        doc = pyweb.Weaver( )
        doc.set_markup("html")
        doc.emit(self.web)
        actual = self.file_path.with_suffix(".html").read_text().splitlines()
        #print(actual)
        self.assertEqual("An anonymous chunk.", actual[0])
        self.assertTrue("Time = mocked time", actual[1])
        self.assertEqual("File = ('test9.w', 3)", actual[2])
        self.assertEqual('Version = 3.2', actual[3])
        self.assertEqual(f'CWD = {os.getcwd()}', actual[4])


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.WARN)
    unittest.main()

