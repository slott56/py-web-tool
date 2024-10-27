
"""Script tests."""
import logging
from pathlib import Path
import sys
import textwrap

import pytest

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



@pytest.fixture
def sample_path(tmp_path) -> Path:
    sample_path = tmp_path / "test_sample.w"
    sample_path.write_text(sample)
    yield sample_path
    sample_path.unlink()

def clean_lines(first: str) -> list[str]:
    """Strips blank lines and trailing whitespace that (generally) aren't problems when weaving."""
    def non_blank(line: str) -> bool:
        return len(line) > 0
    return list(filter(non_blank, (line.rstrip() for line in first.splitlines())))



@pytest.fixture
def expected_weave(sample_path) -> str:
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
    return expected_weave

def test_weave(sample_path: Path, expected_weave) -> None:
    output = sample_path.with_suffix(".html")

    weave.main(sample_path)
    result = output.read_text()
    output.unlink()

    assert clean_lines(expected_weave) == clean_lines(result)




expected_tangle = textwrap.dedent("""

    #include <stdio.h>
    
    
    int main() {
        println("Hello, World!")
    }
    
    """)

def test_tangle(sample_path):
    # Name comes from ``@o`` command
    output = sample_path.parent / "sample_tangle.code"

    tangle.main(sample_path)
    result = output.read_text()
    output.unlink()
    assert clean_lines(expected_tangle) == clean_lines(result)

