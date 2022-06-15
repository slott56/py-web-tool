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
    
        w = pyweb.Web() 
        
        for action in pyweb.LoadAction(), pyweb.TangleAction():
            action.web = w
            action.options = options
            action()
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

@d weave.py custom weaver definition...
@{
class MyHTML(pyweb.HTML):
    """HTML formatting templates."""
    extension = ".html"
    
    cb_template = string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
    <pre><code>\n""")

    ce_template = string.Template("""
    </code></pre>
    <p>&loz; <em>${fullName}</em> (${seq}).
    ${references}
    </p>\n""")
        
    fb_template = string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p>``${fullName}`` (${seq})&nbsp;${concat}</p>
    <pre><code>\n""") # Prevent indent
        
    fe_template = string.Template( """</code></pre>
    <p>&loz; ``${fullName}`` (${seq}).
    ${references}
    </p>\n""")
        
    ref_item_template = string.Template(
    '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    
    ref_template = string.Template('  Used by ${refList}.' )
            
    refto_name_template = string.Template(
    '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    refto_seq_template = string.Template('<a href="#pyweb${seq}">(${seq})</a>')
 
    xref_head_template = string.Template("<dl>\n")
    xref_foot_template = string.Template("</dl>\n")
    xref_item_template = string.Template("<dt>${fullName}</dt><dd>${refList}</dd>\n")
    
    name_def_template = string.Template('<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>')
    name_ref_template = string.Template('<a href="#pyweb${seq}">${seq}</a>')
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
            command='@@',
            permitList=[],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theWeaver=MyHTML(),
            webReader=pyweb.WebReader(),
        )
    
        w = pyweb.Web() 
    
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action.web = w
            action.options = options
            action()
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))
@}
