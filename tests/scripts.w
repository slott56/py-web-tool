Additional Scripts Testing
==========================

.. test/scripts.w

We provide these two additional scripts; effectively command-line short-cuts:

-   ``tangle.py``

-   ``weave.py``

These need their own test cases.


This gives us the following outline for the script testing.

@o test_scripts.py 
@{@<Script Test overheads: imports, etc.@>

@<Sample web file to test with@>

@<Superclass for test cases@>

@<Test of weave.py@>

@<Test of tangle.py@>

@<Scripts Test main@>
@}

Sample Web File
---------------

This is a web ``.w`` file to create a document and tangle a small file.

@d Sample web file...
@{
sample = textwrap.dedent("""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Sample HTML web file</title>
      </head>
      <body>
        <h1>Sample HTML web file</h1>
        <p>We're avoiding using Python specifically.
        This hints at other languages being tangled by this tool.</p>
        
    @@o sample_tangle.code
    @@{
    @@<preamble@@>
    @@<body@@>
    @@}
    
    @@d preamble
    @@{
    #include <stdio.h>
    @@}
    
    @@d body
    @@{
    int main() {
        println("Hello, World!")
    }
    @@}
    
      </body>
    </html>
    """)
@}

Superclass for test cases
-------------------------

This superclass definition creates a consistent test fixture for both test cases.
The sample ``test_sample.w`` file is created and removed after the test.

@d Superclass...
@{
class SampleWeb(unittest.TestCase):
    def setUp(self) -> None:
        self.sample_path = Path("test_sample.w")
        self.sample_path.write_text(sample)
    def tearDown(self) -> None:
        self.sample_path.unlink()

@}

Weave Script Test
-----------------

We check the weave output to be sure it's what we expected. 
This could be altered to check a few features of the weave file rather than compare the entire file.

@d Test of weave.py
@{
expected_weave = textwrap.dedent("""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Sample HTML web file</title>
      </head>
      <body>
        <h1>Sample HTML web file</h1>
        <p>We're avoiding using Python specifically.
        This hints at other languages being tangled by this tool.</p>
    
    <a name="pyweb1"></a>
        <!--line number 16-->
        <p>``sample_tangle.code`` (1)&nbsp;=</p>
        <pre><code>
    
    <a href="#pyweb2">&rarr;<em>preamble</em>&nbsp;(2)</a>
    <a href="#pyweb3">&rarr;<em>body</em>&nbsp;(3)</a>
    </code></pre>
        <p>&loz; ``sample_tangle.code`` (1).
        []
        </p>
    
    
    <a name="pyweb2"></a>
        <!--line number 22-->
        <p><em>preamble</em> (2)&nbsp;=</p>
        <pre><code>
    
    #include &lt;stdio.h&gt;
    
        </code></pre>
        <p>&loz; <em>preamble</em> (2).
          Used by <a href="#pyweb1"><em>sample_tangle.code</em>&nbsp;(1)</a>.
        </p>
    
    
    <a name="pyweb3"></a>
        <!--line number 27-->
        <p><em>body</em> (3)&nbsp;=</p>
        <pre><code>
    
    int main() {
        println(&quot;Hello, World!&quot;)
    }
    
        </code></pre>
        <p>&loz; <em>body</em> (3).
          Used by <a href="#pyweb1"><em>sample_tangle.code</em>&nbsp;(1)</a>.
        </p>
    
    
      </body>
    </html>
    """)
    
class TestWeave(SampleWeb):
    def setUp(self) -> None:
        super().setUp()
        self.output = self.sample_path.with_suffix(".html")
    def test(self) -> None:
        weave.main(self.sample_path)
        result = self.output.read_text()
        self.assertEqual(result, expected_weave)
    def tearDown(self) -> None:
        super().tearDown()
        self.output.unlink()
@}

Tangle Script Test
------------------

We check the tangle output to be sure it's what we expected. 

@d Test of tangle.py
@{

expected_tangle = textwrap.dedent("""

    #include <stdio.h>
    
    
    int main() {
        println("Hello, World!")
    }
    
    """)
    
class TestTangle(SampleWeb):
    def setUp(self) -> None:
        super().setUp()
        self.output = Path("sample_tangle.code")
    def test(self) -> None:
        tangle.main(self.sample_path)
        result = self.output.read_text()
        self.assertEqual(result, expected_tangle)
    def tearDown(self) -> None:
        super().tearDown()
        self.output.unlink()
@}

Overheads and Main Script
--------------------------

This is typical of the other test modules. We provide a unittest runner 
here in case we want to run these tests in isolation.

@d Script Test overheads...
@{"""Script tests."""
import logging
from pathlib import Path
import sys
import textwrap
import unittest

import tangle
import weave
@}

@d Scripts Test main...
@{
if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()
@}

We run the default ``unittest.main()`` to execute the entire suite of tests.
