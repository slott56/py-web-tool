
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
            pass  # if the test failed, nothing to remove


 
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

test0_expected_debug = dedent("""\
    text: TextCommand(text='<html>', location=('test0.w', 1), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 2), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='<head>', location=('test0.w', 2), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 3), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='    <link rel="StyleSheet" href="pyweb.css" type="text/css" />', location=('test0.w', 3), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 4), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</head>', location=('test0.w', 4), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 5), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='<body>', location=('test0.w', 5), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 6), logger=<Logger TextCommand (INFO)>, definition=True)
    ref: ReferenceCommand(name='some code', location=('test0.w', 6), definition=False, logger=<Logger ReferenceCommand (INFO)>)text: TextCommand(text='\\n', location=('test0.w', 7), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 8), logger=<Logger TextCommand (INFO)>, definition=True)
    begin_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='        if p%2 == 1: return n*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    return n*n*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)
    code: CodeCommand(text='\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='        if p%2 == 1: return n*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='    return n*n*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True)
    code: CodeCommand(text='\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)
    end_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='        if p%2 == 1: return n*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    return n*n*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)
    text: TextCommand(text='\\n', location=('test0.w', 19), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</body>', location=('test0.w', 19), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 20), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</html>', location=('test0.w', 20), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\n', location=('test0.w', 21), logger=<Logger TextCommand (INFO)>, definition=True)""")


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
        doc.reference_style = pyweb.SimpleReference() 
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
        doc.reference_style = pyweb.SimpleReference() 
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
        doc.reference_style = pyweb.SimpleReference() 
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

