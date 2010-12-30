<!-- pyweb/todo.w -->

<ol>
<li>Fix OutputChunk to also include the comment convention for the file 
being produced.  While it's possible to guess from the file extension, 
this can be unwise.  '.py' is "#", '.java' or '.cpp' is '//', etc.
</li>
<li>Offer an HTML template with a code-quoting filter like 
<a href="http://www.reportlab.com/apis/reportlab/reportlab.lib.PyFontify-module.html">
PyFontify</a> or <a href="http://pygments.org/">Pygments</a> to add Syntax coloring
to a Python-specific HTML weaver.  
See <a href="http://docutils.sourceforge.net/sandbox/code-block-directive/docs/syntax-highlight.html">
Syntax Highlight</a> for more information.
</li>
<li>Rethink the MacroAction.  Is this really necessary?  Wouldn't the Application
be simpler without it?</li>
<li>Consider getting templates from a "header" section in the <tt>.w</tt> file.  This removes
any weaver command-line option; it's defined within the file.
Also, setting the command character can be done in the header.  
To support multiple projects, the header would probably be included with @@i, indicating
that embedding in the <tt>.w</tt> file isn't as useful as keeping it separate.
See the <tt>weave.py</tt> example.</li>
<li>Offer a basic XHTML template that uses CDATA sections instead of quoting.
Does require the standard quoting for the CDATA end tag.</li>
<li>The <b>createUsedBy()</b> method can be done incrementally by 
accumulating a list of forward references to chunks; as each
new chunk is added, any references to the chunk are removed from
the forward references list, and a call is made to the Web's
setUsage method.  References backward to already existing chunks
are easily resolved with a simple lookup.</li>
<li>Use a <b>Builder</b> pattern to plug an explicit <tt>WebBuilder</tt> instance
into the <tt>WebReader</tt> class to build the parse tree.   This can be overridden to,
for example, do incremental building in one pass.</li>
<li>Note that the Web is a lot like a NamedChunk; this could be factored out.
This will create a more proper Composition pattern implementation.</li>
</ol>
