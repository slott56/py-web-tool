..  py-web-tool/src/scripts.w

Handy Scripts and Other Files
=================================================

Two aditional scripts, ``tangle.py`` and ``weave.py``, are provided as examples 
which can be customized and extended.

``tangle.py`` Script
---------------------

This script shows a simple version of Tangling.  This has a permitted 
error for '@@i' commands to allow an include file (for example test results)
to be omitted from the tangle operation.

Note the general flow of this top-level script.

1.	Create the logging context.

2.	Create the options. This hard-coded object is a stand-in for 
	parsing command-line options. 
	
3.	Create the web object.

4.	For each action (``LoadAction`` and ``TangleAction`` in this example)
	Set the web, set the options, execute the callable action, and write
	a summary.

@o tangle.py 
@{#!/usr/bin/env python3
"""Sample tangle.py script."""
import argparse
import logging
from pathlib import Path
import pyweb

def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            command='@@',
            permitList=['@@i'],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theTangler=pyweb.TanglerMake(),
            webReader=pyweb.WebReader(),
        )
            
        for action in pyweb.LoadAction(), pyweb.TangleAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))
@}

``weave.py`` Script
---------------------

This script shows a simple version of Weaving.  This shows how
to define a customized set of templates for a different markup language.


A customized weaver generally has three parts.

@o weave.py
@{@<weave.py overheads for correct operation of a script@>

@<weave.py custom weaver definition to customize the Weaver being used@>

@<weaver.py processing: load and weave the document@>
@}

@d weave.py overheads...
@{#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
import pyweb
@}

To override templates, a class
needs to provide a text definition of
the Jinja ``{% macro %}`` definitions.
This is used to update the superclass
``template_map``.

Something like the following:

..  parsed-literal::

    self.template_map['html']['overrides'] = my_templates

@d weave.py custom weaver definition...
@{
class MyHTML(pyweb.Weaver):
    pass
@}

@d weaver.py processing...
@{
def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            weaver="html",
            command='@@',
            permitList=[],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theWeaver=MyHTML(),
            webReader=pyweb.WebReader(),
        )
        
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))
@}
