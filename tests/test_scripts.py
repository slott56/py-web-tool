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
        self.maxDiff = None
        
    def tearDown(self) -> None:
        self.sample_path.unlink()

    def assertEqual_Ignore_Blank_Lines(self, first: str, second: str, msg: str=None) -> None:
        """Skips blank lines and trailing whitespace that (generally) aren't problems when weaving."""
        def non_blank(line: str) -> bool:
            return len(line) > 0
        first_nb = '\n'.join(filter(non_blank, (line.rstrip() for line in first.splitlines())))
        second_nb = '\n'.join(filter(non_blank, (line.rstrip() for line in second.splitlines())))
        self.assertEqual(first_nb, second_nb, msg)



expected_weave = ('<!doctype html>\n'
    '<html lang="en">\n'
    '  <head>\n'
    '    <meta charset="utf-8">\n'
    '    <meta name="viewport" content="width=device-width, initial-scale=1">\n'
    '    <title>Sample HTML web file</title>\n'
    '  </head>\n'
    '  <body>\n'
    '    <h1>Sample HTML web file</h1>\n'
    "    <p>We're avoiding using Python specifically.\n"
    '    This hints at other languages being tangled by this tool.</p>\n'
    '<div class="card">\n'
    '  <div class="card-header">\n'
    '    <a type="button" class="btn btn-primary" name="pyweb_1"></a>\n'
    "    <!--line number ('test_sample.w', 16)-->\n"
    '    <p class="small"><em>sample_tangle.code (1)</em> =</p>\n'
    '   </div>\n'
    '  <div class="card-body">\n'
    '    <pre><code>\n'
    '&rarr;<a href="#pyweb_2"><em>preamble (2)</em></a>\n'
    '&rarr;<a href="#pyweb_3"><em>body (3)</em></a>\n'
    '    </code></pre>\n'
    '  </div>\n'
    '<div class="card-footer">\n'
    '  <p>&#8718; <em>sample_tangle.code (1)</em>.\n'
    '  </p>\n'
    '</div>\n'
    '</div>\n'
    '<div class="card">\n'
    '  <div class="card-header">\n'
    '    <a type="button" class="btn btn-primary" name="pyweb_2"></a>\n'
    "    <!--line number ('test_sample.w', 22)-->\n"
    '    <p class="small"><em>preamble (2)</em> =</p>\n'
    '   </div>\n'
    '  <div class="card-body">\n'
    '    <pre><code>\n'
    '#include &lt;stdio.h&gt;\n'
    '    </code></pre>\n'
    '  </div>\n'
    '<div class="card-footer">\n'
    '  <p>&#8718; <em>preamble (2)</em>.\n'
    '  </p>\n'
    '</div>\n'
    '</div>\n'
    '<div class="card">\n'
    '  <div class="card-header">\n'
    '    <a type="button" class="btn btn-primary" name="pyweb_3"></a>\n'
    "    <!--line number ('test_sample.w', 27)-->\n"
    '    <p class="small"><em>body (3)</em> =</p>\n'
    '   </div>\n'
    '  <div class="card-body">\n'
    '    <pre><code>\n'
    'int main() {\n'
    '    println(&quot;Hello, World!&quot;)\n'
    '}\n'
    '    </code></pre>\n'
    '  </div>\n'
    '<div class="card-footer">\n'
    '  <p>&#8718; <em>body (3)</em>.\n'
    '  </p>\n'
    '</div>\n'
    '</div>\n'
    '  </body>\n'
    '</html>')
    
class TestWeave(SampleWeb):
    def setUp(self) -> None:
        super().setUp()
        self.output = self.sample_path.with_suffix(".html")
        self.maxDiff = None

    def test(self) -> None:
        weave.main(self.sample_path)
        result = self.output.read_text()
        self.assertEqual_Ignore_Blank_Lines(expected_weave, result)

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
        self.assertEqual(expected_tangle, result)

    def tearDown(self) -> None:
        super().tearDown()
        self.output.unlink()



if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

