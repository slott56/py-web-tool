
"""Weaver tests exercise various weaving features."""
import pyweb
import unittest
import logging
import os
import string
import io


class WeaveTestcase(unittest.TestCase):
    text = ""
    file_name = ""
    error = ""
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.web = pyweb.Web()
        self.rdr = pyweb.WebReader()
    def tangle_and_check_exception(self, exception_text: str) -> None:
        try:
            self.rdr.load(self.web, self.file_name, self.source)
            self.web.tangle(self.tangler)
            self.web.createUsedBy()
            self.fail("Should not tangle")
        except pyweb.Error as e:
            self.assertEqual(exception_text, e.args[0])
    def tearDown(self) -> None:
        name, _ = os.path.splitext(self.file_name)
        try:
            os.remove(name + ".html")
        except OSError:
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
    file_name = "test0.w"
    def test_load_should_createChunks(self) -> None:
        self.rdr.load(self.web, self.file_name, self.source)
        self.assertEqual(3, len(self.web.chunkSeq))
    def test_weave_should_createFile(self) -> None:
        self.rdr.load(self.web, self.file_name, self.source)
        doc = pyweb.HTML()
        doc.reference_style = pyweb.SimpleReference() 
        self.web.weave(doc)
        with open("test0.html","r") as source:
            actual = source.read()
        self.maxDiff = None
        self.assertEqual(test0_expected, actual)




test9_w= """An anonymous chunk.
Time = @(time.asctime()@)
File = @(theLocation@)
Version = @(__version__@)
CWD = @(os.path.realpath('.')@)
"""


class TestEvaluations(WeaveTestcase):
    text = test9_w
    file_name = "test9.w"
    def test_should_evaluate(self) -> None:
        self.rdr.load(self.web, self.file_name, self.source)
        doc = pyweb.HTML( )
        doc.reference_style = pyweb.SimpleReference() 
        self.web.weave(doc)
        with open("test9.html","r") as source:
            actual = source.readlines()
        #print(actual)
        self.assertEqual("An anonymous chunk.\n", actual[0])
        self.assertTrue(actual[1].startswith("Time ="))
        self.assertEqual("File = ('test9.w', 3)\n", actual[2])
        self.assertEqual('Version = 3.1\n', actual[3])
        self.assertEqual(f'CWD = {os.getcwd()}\n', actual[4])


if __name__ == "__main__":
    import sys
    logging.basicConfig(stream=sys.stderr, level=logging.WARN)
    unittest.main()

