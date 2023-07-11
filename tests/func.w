Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-   `Tests for Loading`_

-   `Tests for Tangling`_

-   `Tests for Weaving`_

There are a total of 11 test cases.

Tests for Loading
------------------

We need to be able to load a web from one or more source files.

@o test_loader.py 
@{@<Load Test overheads: imports, etc.@>

@<Load Test superclass to refactor common setup@>

@<Load Test error handling with a few common syntax errors@>

@<Load Test include processing with syntax errors@>

@<Load Test main program@>
@}

Parsing test cases have a common setup shown in this superclass.

By using some class-level variables ``text``,
``file_path``, we can simply provide a file-like
input object to the ``WebReader`` instance.

@d Load Test superclass...
@{
class ParseTestcase(unittest.TestCase):
    text: ClassVar[str]
    file_path: ClassVar[Path]
    
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.rdr = pyweb.WebReader()
@}

There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

@d Load Test overheads...
@{
import logging.handlers
from pathlib import Path
from textwrap import dedent
from typing import ClassVar
@}

@d Load Test error handling...
@{
@<Sample Document 1 with correct and incorrect syntax@>

class Test_ParseErrors(ParseTestcase):
    text = test1_w
    file_path = Path("test1.w")
    def test_error_should_count_1(self) -> None:
        with self.assertLogs('WebReader', level='WARN') as log_capture:
            chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(3, self.rdr.errors)
        self.assertEqual(log_capture.output, 
            [
                "ERROR:WebReader:At ('test1.w', 8): expected {'@@{'}, found '@@o'",
                "ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)",
                "ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)"
            ]
        )
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

All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

In order to test the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing,
since it's a nested instance of the tokenizer.

@d Load Test include...
@{
@<Sample Document 8 and the file it includes@>

class Test_IncludeParseErrors(ParseTestcase):
    text = test8_w
    file_path = Path("test8.w")
    def setUp(self) -> None:
        super().setUp()
        Path('test8_inc.tmp').write_text(test8_inc_w)
    def test_error_should_count_2(self) -> None:
        with self.assertLogs('WebReader', level='WARN') as log_capture:
            chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(1, self.rdr.errors)
        self.assertEqual(log_capture.output,
            [
                "ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, {'@@{', '@@['} not found", 
                "ERROR:WebReader:Errors in included file 'test8_inc.tmp', output is incomplete."
            ]
        ) 
    def tearDown(self) -> None:
        super().tearDown()
        Path('test8_inc.tmp').unlink()
@}

The sample document must reference the correct name that will
be given to the included document by ``setUp``.

@d Sample Document 8...
@{
test8_w = """Some anonymous chunk.
@@d title @@[the title of this document, defined with @@@@[ and @@@@]@@]
A reference to @@<title@@>.
@@i test8_inc.tmp
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@@d yap
"""
@}

<p>The overheads for a Python unittest.</p>

@d Load Test overheads...
@{
"""Loader and parsing tests."""
import io
import logging
import os
from pathlib import Path
import string
import sys
import types
import unittest

import pyweb
@}

A main program that configures logging and then runs the test.

@d Load Test main program...
@{
if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()
@}

Tests for Tangling
------------------

We need to be able to tangle a web.

@o test_tangler.py 
@{@<Tangle Test overheads: imports, etc.@>
@<Tangle Test superclass to refactor common setup@>
@<Tangle Test semantic error 2@>
@<Tangle Test semantic error 3@>
@<Tangle Test semantic error 4@>
@<Tangle Test semantic error 5@>
@<Tangle Test semantic error 6@>
@<Tangle Test include error 7@>
@<Tangle Test main program@>
@}

Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.


@d Tangle Test superclass...
@{
class TangleTestcase(unittest.TestCase):
    text: ClassVar[str]
    error: ClassVar[str]
    file_path: ClassVar[Path]
    
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.rdr = pyweb.WebReader()
        self.tangler = pyweb.Tangler()
        
    def tangle_and_check_exception(self, exception_text: str) -> None:
        with self.assertRaises(pyweb.Error) as exc_mgr:
            chunks = self.rdr.load(self.file_path, self.source)
            self.web = pyweb.Web(chunks)
            self.tangler.emit(self.web)
            self.fail("Should not tangle")
        exc = exc_mgr.exception
        self.assertEqual(exception_text, exc.args[0])
            
    def tearDown(self) -> None:
        try:
            self.file_path.with_suffix(".tmp").unlink()
        except FileNotFoundError:
            pass  # If the test fails, nothing to remove...
@}

@d Tangle Test semantic error 2... 
@{
@<Sample Document 2@>

class Test_SemanticError_2(TangleTestcase):
    text = test2_w
    file_path = Path("test2.w")
    def test_should_raise_undefined(self) -> None:
        self.tangle_and_check_exception("Attempt to tangle an undefined Chunk, 'part2'")
@}

@d Sample Document 2... @{
test2_w = """Some anonymous chunk
@@o test2.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
Okay, now for some errors: no part2!
"""
@}

@d Tangle Test semantic error 3... 
@{
@<Sample Document 3@>

class Test_SemanticError_3(TangleTestcase):
    text = test3_w
    file_path = Path("test3.w")
    def test_should_raise_bad_xref(self) -> None:
        self.tangle_and_check_exception("Illegal tangling of a cross reference command.")
@}

@d Sample Document 3... @{
test3_w = """Some anonymous chunk
@@o test3.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
@@d part2 @@{This is part 2, with an illegal: @@f.@@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""
@}


@d Tangle Test semantic error 4... 
@{
@<Sample Document 4@>

class Test_SemanticError_4(TangleTestcase):
    """An optional feature of a Web."""
    text = test4_w
    file_path = Path("test4.w")
    def test_should_raise_noFullName(self) -> None:
        self.tangle_and_check_exception("No full name for 'part1...'")
@}

@d Sample Document 4... @{
test4_w = """Some anonymous chunk
@@o test4.tmp
@@{@@<part1...@@>
@@<part2@@>
@@}@@@@
@@d part1... @@{This is part 1.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""
@}

@d Tangle Test semantic error 5... 
@{
@<Sample Document 5@>

class Test_SemanticError_5(TangleTestcase):
    text = test5_w
    file_path = Path("test5.w")
    def test_should_raise_ambiguous(self) -> None:
        self.tangle_and_check_exception("Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']")
@}

@d Sample Document 5... @{
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

@d Tangle Test semantic error 6... 
@{ 
@<Sample Document 6@>

class Test_SemanticError_6(TangleTestcase):
    text = test6_w
    file_path = Path("test6.w")
    def test_should_warn(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        self.tangler.emit(self.web)
        print(self.web.no_reference())
        self.assertEqual(1, len(self.web.no_reference()))
        self.assertEqual(1, len(self.web.multi_reference()))
        self.assertEqual({'part1a', 'part1...'}, self.tangler.reference_names)
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

@d Tangle Test include error 7... 
@{
@<Sample Document 7 and it's included file@>

class Test_IncludeError_7(TangleTestcase):
    text = test7_w
    file_path = Path("test7.w")
    def setUp(self) -> None:
        Path('test7_inc.tmp').write_text(test7_inc_w)
        super().setUp()
    def test_should_include(self) -> None:
        chunks = self.rdr.load(self.file_path, self.source)
        self.web = pyweb.Web(chunks)
        self.tangler.emit(self.web)
        self.assertEqual(5, len(self.web.chunks))
        self.assertEqual(test7_inc_w, self.web.chunks[3].commands[0].text)
    def tearDown(self) -> None:
        Path('test7_inc.tmp').unlink()
        super().tearDown()
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
from typing import ClassVar
import unittest

import pyweb
@}

@d Tangle Test main program...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()
@}


Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.

@o test_weaver.py 
@{@<Weave Test overheads: imports, etc.@>
@<Weave Test superclass to refactor common setup@>
@<Weave Test references and definitions@>
@<Weave Test evaluation of expressions@>
@<Weave Test main program@>
@}

Weaving test cases have a common setup shown in this superclass.

@d Weave Test superclass... @{
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
@}

@d Weave Test references... @{
@<Sample Document 0@>
@<Expected Output 0@>

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
    "begin_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)\n"
    "code: CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))\n"
    "end_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], options=[], def_names=[], initial=True, comment_start=None, comment_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)\n"
    "text: TextCommand(text='\\n</body>\\n</html>\\n', location=('test0.w', 19))"
    )
@}

Note that this really requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.

@d Weave Test evaluation... @{
@<Sample Document 9@>

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
import unittest

import pyweb
@}

@d Weave Test main program...
@{
if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.WARN)
    unittest.main()
@}
