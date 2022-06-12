#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
import pyweb



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



def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            command='@',
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

