
"""Weaver tests exercise various weaving features."""
import io
import logging
import os
from pathlib import Path
import string
import sys
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


test0_expected = """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
<a href="#pyweb1">&rarr;<em>some code</em> (1)</a>


    <a name="pyweb1"></a>
    <!--line number 10-->
    <p><em>some code</em> (1)&nbsp;=</p>
    <pre><code>

def fastExp(n, p):
    r = 1
    while p &gt; 0:
        if p%2 == 1: return n*fastExp(n,p-1)
    return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)

    </code></pre>
    <p>&loz; <em>some code</em> (1).
    
    </p>

</body>
</html>
"""


class Test_RefDefWeave(WeaveTestcase):
    text = test0_w
    file_path = Path("test0.w")
    def test_load_should_createChunks(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(3, len(chunks))
    @unittest.skip("Requires HTML Weaver.""")
    def test_weave_should_createFile(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        doc = pyweb.HTML()
        doc.reference_style = pyweb.SimpleReference() 
        doc.emit(self.web)
        actual = self.file_path.with_suffix(".html").read_text()
        self.maxDiff = None
        self.assertEqual(test0_expected, actual)




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
    @unittest.skip("Requires HTML Weaver.""")
    def test_should_evaluate(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        doc = pyweb.HTML( )
        doc.reference_style = pyweb.SimpleReference() 
        doc.emit(self.web)
        actual = self.file_path.with_suffix(".html").read_text().splitlines()
        #print(actual)
        self.assertEqual("An anonymous chunk.", actual[0])
        self.assertTrue("Time = mocked time", actual[1])
        self.assertEqual("File = ('test9.w', 3)", actual[2])
        self.assertEqual('Version = 3.1', actual[3])
        self.assertEqual(f'CWD = {os.getcwd()}', actual[4])


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.WARN)
    unittest.main()

