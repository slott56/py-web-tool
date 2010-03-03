<p>Changes since version 1.4.</p>
<ol>
<li>Removed home-brewed logger.</li>
<li>Replaced getopt with optparse.</li>
<li>Replaced LaTeX markup.</li>
<li>Corrected significant problems in cross-reference resolution.</li>
<li>Replaced all HTML and LaTeX-specific features with a much simpler template
engine which applies a template to a Chunk.  The Templates are separate
configuration items.  The big issue with templates are conditional processing
and the use of loops to handle multiple references in a transitive closure.
While it's nice to depend on Jinja2, it's also nice to be totally stand-alone.
Sigh.  Choices include the no-logic <tt>string.Template</tt> in the standard library
an the <tt>Templite+</tt> Recipe 576663.
</li>
<li>Looked at SCons API.  Renamed "Operation" to "Action"; renamed "perform" to "__call__".  
Consider having "__call__" which does logging, then call "execute".  Weaver fits nicely with SCons
Builder since we can see <tt>Weave( "someFile.w" )</tt> as sensible.  Tangling is tougher
because the <tt>@@o</tt> commands define the dependencies there.  
</li>
<li>Eliminated the EmitterFactory; replace this with simple injection of
the proper template configuration.  
</li>
<li>Removed the <tt>@@O</tt> command; it was essentially a variant template for LaTeX.</li>
<li>Disentangled indentation and quoting in the codeBlock.
Everyone needs indentation -- it's a lower-level feature of write.
Quoting, however, is unique to a woven codeBlock.  Fix referenceTo  to write
indented without code quoting.
</li>
<li>Offer an RST template.
Note that colorizing may be easier to handle with an RST template.
The weaving markup template degenerates 
to <tt>..   parsed-literal::</tt> and indent.  By doing this,
the RST output from <em>pyWeb</em> can be run through DocUtils <b>rst2html.py</b>
or perhaps <b>Sphix</b> to create final HTML.  <b>The hard part is the indent.</b>
</li> 
<li>Fixed ReferenceCommand tangle and all setIndent/clrIndent operations. 
Only a ReferenceCommand actually cares about indentation.  And that indentation
is totally based on the "context" plus the text in the Command immediate in front
of the ReferenceCommand.
</li>

</ol>