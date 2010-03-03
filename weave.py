#!/usr/bin/env python
"""Sample weave.py script."""
import pyweb
import logging, sys, string

logging.basicConfig( stream=sys.stderr, level=logging.INFO )
logger= logging.getLogger(__file__)


class MyHTML( pyweb.HTML ):
    """HTML formatting templates."""
    extension= ".html"
    
    cb_template= string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
    <code><pre>\n""")

    ce_template= string.Template("""
    </pre></code>
    <p>&loz; <em>${fullName}</em> (${seq}).
    ${references}
    </p>\n""")
        
    fb_template= string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p><tt>${fullName}</tt> (${seq})&nbsp;${concat}</p>
    <code><pre>\n""") # Prevent indent
        
    fe_template= string.Template( """</pre></code>
    <p>&loz; <tt>${fullName}</tt> (${seq}).
    ${references}
    </p>\n""")
        
    ref_item_template = string.Template(
    '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    
    ref_template = string.Template( '  Used by ${refList}.'  )
            
    refto_name_template = string.Template(
    '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    refto_seq_template = string.Template( '<a href="#pyweb${seq}">(${seq})</a>' )
 
    xref_head_template = string.Template( "<dl>\n" )
    xref_foot_template = string.Template( "</dl>\n" )
    xref_item_template = string.Template( "<dt>${fullName}</dt><dd>${refList}</dd>\n" )
    
    name_def_template = string.Template( '<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>' )
    name_ref_template = string.Template( '<a href="#pyweb${seq}">${seq}</a>' )


w= pyweb.Web( "pyweb.w" ) # The web we'll work on.

permitList= []
commandChar= '@'
load= pyweb.LoadAction()
load.webReader=  pyweb.WebReader( command=commandChar, permit=permitList )
load.webReader.web( w ).source( "pyweb.w" )
load.web= w
load()
logger.info( load.summary() )

weave= pyweb.WeaveAction()
weave.theWeaver= MyHTML()
weave.web= w
weave()
logger.info( weave.summary() )

