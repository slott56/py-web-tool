"""Script tests."""
import logging
from pathlib import Path
import sys
import textwrap
import unittest

import tangle
import weave



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
        
    @o sample_tangle.code
    @{
    @<preamble@>
    @<body@>
    @}
    
    @d preamble
    @{
    #include <stdio.h>
    @}
    
    @d body
    @{
    int main() {
        println("Hello, World!")
    }
    @}
    
      </body>
    </html>
    """)



class SampleWeb(unittest.TestCase):
    def setUp(self) -> None:
        self.sample_path = Path("test_sample.w")
        self.sample_path.write_text(sample)
    def tearDown(self) -> None:
        self.sample_path.unlink()




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



if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

