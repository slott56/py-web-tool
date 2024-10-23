..  py-web-tool/src/scripts.w

Handy Scripts
=============

Two aditional scripts, ``tangle.py`` and ``weave.py``, are provided as examples which can be customized and extended.

``tangle.py`` Script
---------------------

This script shows a simple version of Tangling.
This has a permitted error for '@@i' commands to allow an include file to be omitted from a tangle operation.
This permits a WEB to include the log from test output.
When tangling the code and test cases, the log is not available, and can be safely ignored.
When weaving a final document after testing, the log will be available.

Note the general flow of this top-level script.

1.	Create the logging context.

2.	Create the options. This hard-coded object is a stand-in for 
	parsing command-line options. 
	
3.	Create the ``Web`` object.

4.	For each action (``LoadAction`` and ``TangleAction`` in this example)
	Set the web, set the options, execute the callable action, and write
	a summary.

Conspicuous by its absence is CLI parsing to get the name of a WEB file to process.

@o tangle.py 
@{#!/usr/bin/env python3
"""Sample tangle.py script."""
import argparse
import logging
from pathlib import Path
import pyweb

def main(source: Path) -> None:
    with pyweb.Logger(pyweb.default_logging_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            command='@@',
            permitList=['@@i'],
            tangler_line_numbers=False,
            webReader=pyweb.WebReader(),
            theTangler=pyweb.TanglerMake(),
        )
            
        for action in pyweb.LoadAction(), pyweb.TangleAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    # CLI parsing goes here...
    source = Path("examples/test_rst.w")
    main(source)
@}

``weave.py`` Script
---------------------

This script shows a simple version of Weaving.
This shows how to define a customized set of templates for a new markup language, or to use new features of a supported language.

A customized weaver generally has three parts.

@o weave.py
@{@<weave.py overheads for correct operation of a script@>

@<weave.py custom weaver definition to customize the Weaver being used@>

@<weaver.py processing: load and weave the document@>
@}

Conspicuous by its absence is CLI parsing to get the name of a WEB file to process.

@d weave.py overheads...
@{#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
from textwrap import dedent

import pyweb
@}

To override templates, a class needs to provide a list of text definitions for each Jinja ``{% macro %}`` definition.
This is used to update the superclass
``template_name_map``.

Something like the following sets the macros in use.

..  parsed-literal::

    self.template_name_map['html'] = (
        (my_templates,) + self.template_name_map['html']
    )

The value of a template name is a tuple of definition lists, with the overriding definitions first, and the default definitions must follow later.
This will be used to build a ``ChainMap``, ensuring the high-priority items defined first override the defaults defined later.

@d weave.py custom weaver definition...
@{
bootstrap_html = [
    dedent("""\
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
    """),
    dedent("""\
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
    ]

class MyHTML(pyweb.Weaver):
    def __init__(self, output: Path = Path.cwd()) -> None:
        super().__init__(output)
        self.template_name_map['html'] = (
            (bootstrap_html,) +
            self.template_name_map['html']
        )
@}

@d weaver.py processing...
@{
def main(source: Path) -> None:
    with pyweb.Logger(pyweb.default_logging_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            weaver="html",
            command='@@',
            permitList=[],
            tangler_line_numbers=False,
            webReader=pyweb.WebReader(),
            
            theWeaver=MyHTML(),  # Customized with a specific Weaver subclass
        )
        
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    # CLI parsing goes here...
    source = Path("examples/test_rst.w")
    main(source)
@}
