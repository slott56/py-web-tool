#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
from textwrap import dedent

import pyweb



class MyHTML(pyweb.Weaver):
    bootstrap_html = dedent("""
    {%- macro begin_code(chunk) %}
    <div class="card">
      <div class="card-header">
        <a type="button" class="btn btn-primary" name="pyweb_{{chunk.seq}}"></a>
        <!--line number {{chunk.location}}-->
        <p class="small"><em>{{chunk.full_name or chunk.name}} ({{chunk.seq}})</em> {% if chunk.initial %}={% else %}+={% endif %}</p>
       </div>
      <div class="card-body">
        <pre><code>
    {%- endmacro -%}

    {%- macro end_code(chunk) %}
        </code></pre>
      </div>
    <div class="card-footer">
      <p>&#8718; <em>{{chunk.full_name or chunk.name}} ({{chunk.seq}})</em>.
      </p> 
    </div>
    </div>
    {% endmacro -%}
    """)
    
    def __init__(self, output: Path = Path.cwd()) -> None:
        super().__init__(output)
        self.template_map = pyweb.Weaver.template_map | {"html_macros": self.bootstrap_html}



def main(source: Path) -> None:
    with pyweb.Logger(pyweb.default_logging_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            weaver="html",
            command='@',
            permitList=[],
            tangler_line_numbers=False,
            webReader=pyweb.WebReader(),
            
            theWeaver=MyHTML(),  # Customize with a specific Weaver subclass
        )
        
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))

