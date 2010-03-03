<!-- pyweb/intro.w -->

<p>Literate programming was pioneered by Knuth as a method for
developing readable, understandable presentations of programs.
These would present a program in a literate fashion for people
to read and understand; this would be in parallel with presentation as source text
for a compiler to process and both would be generated from a common source file.
</p>
<p>
One intent is to synchronize the program source with the
documentation about that source.  If the program and the documentation
have a common origin, then the traditional gaps between intent 
(expressed in the documentation) and action (expressed in the
working program) are significantly reduced.
</p>
<p><em>pyWeb</em> is a literate programming tool that combines the actions
of <em>weaving</em> a document with <em>tangling</em> source files.
It is independent of any particular document markup or source language.
Is uses a simple set of markup tags to define chunks of code and 
documentation.
</p>

<h2>Background</h2>

<p>The following is an almost verbatim quote from Briggs' <i>nuweb</i> documentation, and provides an apt summary of Literate Programming.</p>

<div>
<p class="quote">In 1984, Knuth introduced the idea of <em>literate programming</em> and
described a pair of tools to support the practise (Donald E. Knuth, <i>Literate Programming</i>, The Computer Journal <b>27</b> (1984), no. 2, 97-111.)
His approach was to combine Pascal code with T<small>E</small>X documentation to
produce a new language, <tt>WEB</tt>, that offered programmers a superior
approach to programming. He wrote several programs in <tt>WEB</tt>,
including <tt>weave</tt> and <tt>tangle</tt>, the programs used to support
literate programming.
The idea was that a programmer wrote one document, the web file, that
combined documentation written in T<small>E</small>X (Donald E. Knuth, 
<i>The T<small>E</small>Xbook</i>, Computers and Typesetting, 1986) with code (written in Pascal).
</p>
<p class="quote">
Running <tt>tangle</tt> on the web file would produce a complete
Pascal program, ready for compilation by an ordinary Pascal compiler.
The primary function of <tt>tangle</tt> is to allow the programmer to
present elements of the program in any desired order, regardless of
the restrictions imposed by the programming language. Thus, the
programmer is free to present his program in a top-down fashion,
bottom-up fashion, or whatever seems best in terms of promoting
understanding and maintenance.
</p>
<p class="quote">
Running <tt>weave</tt> on the web file would produce a T<small>E</small>X file, ready
to be processed by T<small>E</small>X. The resulting document included a variety of
automatically generated indices and cross-references that made it much
easier to navigate the code. Additionally, all of the code sections
were automatically prettyprinted, resulting in a quite impressive
document. 
</p>
<p class="quote">
Knuth also wrote the programs for T<small>E</small>X and <small><i>METAFONT</i></small>
entirely in <tt>WEB</tt>, eventually publishing them in book
form. These are probably the
largest programs ever published in a readable form.
</p>
</div>

<h2>Other Tools</h2>

<p>Numerous tools have been developed based on Knuth's initial
work.  A relatively complete survey is available at sites
like <a href="http://www.literateprogramming.com/">Literate Programming</a>, 
and the OASIS
<a href="http://www.oasis-open.org/cover/xmlLitProg.html">XML Cover Pages: Literate Programming with SGML and XML</a>.
</p>
<p>The immediate predecessors to this <em>pyWeb</em> tool are 
<a href="http://www.ross.net/funnelweb/"><i>FunnelWeb</i></a>,
<a href="http://www.eecs.harvard.edu/~nr/noweb/"><i>noweb</i></a> and 
<a href="http://sourceforge.net/projects/nuweb/"><i>nuweb</i></a>.  The ideas lifted from these other
tools created the foundation for <em>pyWeb</em>.
</p>
<p>There are several Python-oriented literate programming tools.  
These include 
<a href="http://personalpages.tds.net/~edream/front.html"><i>LEO</i></a>, 
<a href="http://interscript.sourceforge.net/"><i>interscript</i></a>, 
<a href="http://www.danbala.com/python/lpy/"><i>lpy</i></a>, 
<a href="http://www.egenix.com/files/python/SoftwareDescriptions.html#py2html.py"><i>py2html</i></a>,
<a href="http://pylit.berlios.de/"><i>PyLit</i></a>.
</p>
<p>The <i>FunnelWeb</i> tool is independent of any programming language
and only mildly dependent on T<small>E</small>X.
It has 19 commands, many of which duplicate features of HTML or 
L<sup><small>A</small></sup>T<small>E</small>X.
</p>
<p>The <i>noweb</i> tool was written by Norman Ramsey.
This tool uses a sophisticated multi-processing framework, via Unix
pipes, to permit flexible manipulation of the source file to tangle
and weave the programming language and documentation markup files.
</p>
<p>The <i>nuweb</i> Simple Literate Programming Tool was developed by
Preston Briggs (preston@@tera.com).  His work was supported by ARPA,
through ONR grant N00014-91-J-1989.  It is written
in C, and very focused on producing L<sup><small>A</small></sup>T<small>E</small>X documents.  It can 
produce HTML, but this is clearly added after the fact.  It cannot be 
easily extended, and is not object-oriented.
</p>
<p>The <i>LEO</i> tool, is a structured GUI editor for creating
source.  It uses XML and <i>noweb</i>-style chunk management.  It is more
than a simple weave and tangle tool.</p>
<p>The <i>interscript</i> tool is very large and sophisticated, but doesn't gracefully
tolerate HTML markup in the document.  It can create a variety of 
markup languages from the interscript source, making it suitable for
creating HTML as well as L<sup><small>A</small></sup>T<small>E</small>X.</p>
<p>The <i>lpy</i> tool can produce very complex HTML representations of
a Python program.  It works by locating documentation markup embedded
in Python comments and docstrings.  This is called "inverted literate
programming".</p>
<p>The <i>py2html</i> tool does very sophisticated syntax coloring.</p>
<p>The <i>PyLit</i> tool is perhaps the very best approach to simple Literate
programming, since it leverages an existing lightweight markup language
and it's output formatting.</p>

<h2><em>pyWeb</em></h2>
<p><em>pyWeb</em> works with any 
programming language and any markup language.  This philosophy
comes from <i>FunnelWeb</i>,
<i>noweb</i>, <i>nuweb</i> and <i>interscript</i>.  The primary differences
between <em>pyWeb</em> and other tools are the following.</p>
<ul>
<li><em>pyWeb</em> is object-oriented, permitting easy extension.  
<i>noweb</i> extensions
are separate processes that communicate through a sophisticated protocol.
<i>nuweb</i> is not easily extended without rewriting and recompiling
the C programs.</li>
<li><em>pyWeb</em> is built in the very portable Python programming 
language.  This allows it to run anywhere that Python 2.6 runs, with
no additional tool or compiler dependencies.  This makes it a useful
tool for programmers in any language.</li>
<li><em>pyWeb</em> is much simpler than <i>FunnelWeb</i>, <i>LEO</i> or <i>Interscript</i>.  It has 
a very limited selection of commands, but can still produce 
complex programs and HTML documents.</li>
<li><em>pyWeb</em> does not invent its own markup language like <i>Interscript</i>.
Because <i>Interscript</i> has its own markup, it can generate LaTex or HTML or other
output formats from a unique input format.  While powerful, it seems simpler to
avoid inventing yet another sophisticated markup language.  The language <em>pyWeb</em>
uses is very simple, and the author's use their preferred markup language almost
exclusively.</li>
<li><em>pyWeb</em> supports the forward literate programming philosophy, 
where a source document creates programming language and markup language.
The alternative, deriving the document from markup embedded in 
program comments ("inverted literate programming"), seems less appealing.
The disadvantage of inverted literate programming is that the final document
can't reflect the original author's preferred order of exposition,
since that informtion generally isn't part of the source code.
</li>
<li><em>pyWeb</em> also specifically rejects some features of <i>nuweb</i>
and <i>FunnelWeb</i>.  These include the macro capability with parameter
substitution, and multiple references to a chunk.  These two capabilities
can be used to grow object-like applications from non-object programming
languages (<em>e.g.</em> C or Pascal).  Since most modern languages (Python,
Java, C++) are object-oriented, this macro capability is more of a problem
than a help.</li>
<li>Since <em>pyWeb</em> is built in the Python interpreter, a source document
can include Python expressions that are evaluated during weave operation to
produce time stamps, source file descriptions or other information in the woven 
or tangled output.</li>
</ul>

<p><em>pyWeb</em> works with any programming language and any markup language.
The initial release supports HTML and 
L<sup><small>A</small></sup>T<small>E</small>X via simple templates.
</p>

<p>The following is extensively quoted from Briggs' <i>nuweb</i> documentation, 
and provides an excellent background in the advantages of the very
simple approach started by <i>nuweb</i> and adopted by <em>pyWeb</em>.</p>

<div>
<p class="quote">
The need to support arbitrary
programming languages has many consequences:</p>
<dl class="quote">
<dt>No prettyprinting</dt><dd class="quote"> Both <tt>WEB</tt> and <tt>CWEB</tt> are able to
  prettyprint the code sections of their documents because they
  understand the language well enough to parse it. Since we want to use
  <em>any</em> language, we've got to abandon this feature.
  However, we do allow particular individual formulas or fragments
  of L<sup><small>A</small></sup>T<small>E</small>X
  or HTML code to be formatted and still be part of the output files.</dd>
<dt>Limited index of identifiers</dt><dd class="quote"> Because <tt>WEB</tt> knows about Pascal,
  it is able to construct an index of all the identifiers occurring in
  the code sections (filtering out keywords and the standard type
  identifiers). Unfortunately, this isn't as easy in our case. We don't
  know what an identifier looks like in each language and we certainly
  don't know all the keywords.  We provide a mechanism to mark 
  identifiers, and we use a pretty standard pattern for recognizing
  identifiers almost most programming languages.</dd>
</dl>
<p class="quote">
Of course, we've got to have some compensation for our losses or the
whole idea would be a waste. Here are the advantages I [Briggs] can see:
</p>

<dl class="quote">
    <dt>Simplicity</dt>
        <dd class="quote">The majority of the commands in <tt>WEB</tt> are concerned with control of the automatic prettyprinting. Since we don't prettyprint, many commands are eliminated. A further set of commands is subsumed by L<sup><small>A</small></sup>T<small>E</small>X  and may also be eliminated. As a result, our set of commands is reduced to only about seven members (explained in the next section). This simplicity is also reflected in the size of this tool, which is quite a bit smaller than the tools used with other approaches.</dd>

    <dt>No prettyprinting</dt>
        <dd class="quote">Everyone disagrees about how their code should look, so automatic formatting annoys many people. One approach is to provide ways to control the formatting. Our approach is simpler -- we perform no automatic formatting and therefore allow the programmer complete control of code layout.</dd>

    <dt>Control</dt>
        <dd class="quote">We also offer the programmer reasonably complete control of the layout of his output files (the files generated during tangling). Of course, this is essential for languages that are sensitive to layout; but it is also important in many practical situations, <em>e.g.</em>, debugging.</dd>

    <dt>Speed</dt>
        <dd class="quote">Since [<em>pyWeb</em>] doesn't do too much, it runs very quickly. It combines the functions of <tt>tangle</tt> and <tt>weave</tt> into a single program that performs both functions at once.</dd>

    <dt>Chunk numbers</dt>
        <dd class="quote">Inspired by the example of <i>noweb</i>, [<em>pyWeb</em>] refers to all program code chunks by a simple, ascending sequence number through the file.  This becomes the HTML anchor name, also.</dd>

    <dt>Multiple file output</dt>
        <dd class="quote">The programmer may specify more than one output file in a single [<em>pyWeb</em>] source file. This is required when constructing programs in a combination of languages (say, Fortran and C). It's also an advantage when constructing very large programs.</dd>
</dl>

</div>

<h2>Use Cases</h2>
<p><em>pyWeb</em> supports two use cases, <i>Tangle Source Files</i> and <i>Weave Documentation</i>.
These are often combined into a single request of the application that will both
weave and tangle.</p>
<h3>Tangle Source Files</h3>
<p>A user initiates this process when they have a complete <tt>.w</tt> file that contains 
a description of source files.  These source files are described with <tt>@@o</tt> commands
in the <tt>.w</tt> file.</p>
<p>The use case is successful when the source files are produced.</p>
<p>Outside this use case, the user will debug those source files, possibly updating the
<tt>.w</tt> file.  This will lead to a need to restart this use case.</p>
<p>The use case is a failure when the source files cannot be produced, due to 
errors in the <tt>.w</tt> file.  These must be corrected based on information in log messages.</p>
<p>The sequence is simply <tt>./pyweb.py <i>theFile</i>.w</tt>.</p>

<h3>Weave Source Files</h3>
<p>A user initiates this process when they have a <tt>.w</tt> file that contains 
a description of a document to produce.  The document is described by the entire
<tt>.w</tt> file.</p>
<p>The use case is successful when the documentation file is produced.</p>
<p>Outside this use case, the user will edit the documentation file, possibly updating the
<tt>.w</tt> file.  This will lead to a need to restart this use case.</p>
<p>The use case is a failure when the documentation file cannot be produced, due to 
errors in the <tt>.w</tt> file.  These must be corrected based on information in log messages.</p>
<p>The sequence is simply <tt>./pyweb.py <i>theFile</i>.w</tt>.</p>

<h3>Tangle, Regression Test and Weave</h3>
<p>A user initiates this process when they have a <tt>.w</tt> file that contains 
a description of a document to produce.  The document is described by the entire
<tt>.w</tt> file.  Further, their final document should include regression test output 
from the source files created by the tangle operation.</p>
<p>The use case is successful when the documentation file is produced, including
current regression test output.</p>
<p>Outside this use case, the user will edit the documentation file, possibly updating the
<tt>.w</tt> file.  This will lead to a need to restart this use case.</p>
<p>The use case is a failure when the documentation file cannot be produced, due to 
errors in the <tt>.w</tt> file.  These must be corrected based on information in log messages.</p>
<p>The use case is a failure when the documentation file does not include current
regression test output.</p>
<p>The sequence is as follows:</p>
<pre>
./pyweb.py -xw -pi <i>theFile</i>.w
python <i>theTest</i> &gt;<i>aLog</i>
./pyweb.py -xt <i>theFile</i>.w
</pre>
<p>The first step excludes weaving and permits errors on the <tt>@@i</tt> command.  The <tt>-pi</tt> option
is necessary in the event that the log file does not yet exist.  The second step 
runs the regression test, creating a log file.  The third step weaves the final document,
including the regression test output.</p> 

<h2>Writing <em>pyWeb</em> .w Files</h2>
<p>The input to <em>pyWeb</em> is a <tt>.w</tt> file that consists of a
series of <i>Chunks</i>.  Each Chunk is either program source code to 
be <i>tangled</i> or it is documentation to be <i>woven</i>.  The bulk of
the file is typically documentation chunks that describe the program in
some human-oriented markup language like HTML 
or L<sup><small>A</small></sup>T<small>E</small>X.
</p>

<p>The <em>pyWeb</em> tool parses the input, and performs the
tangle and weave operations.  It <em>tangles</em> each individual output file
from the program source chunks.  It <em>weaves</em> a final documentation file
file from the entire sequence of chunks provided, mixing the author's 
original documentation with some markup around the embedded program source.
</p>

<p><em>pyWeb</em> defines a very simple markup system in which the code
chunks are surrounded with  tags.   The tags are used to assemble the tangled output
into the requested file(s).  The tags are replaced with markup so that 
a resulting woven document will process correctly through a browser
or LaTeX tool.
</p>

<p>The non-code chunks are not marked up in any way.  Everything that's not
explicitly a code chunk is simply output without modification.
</p>

<p>All of the <em>pyWeb</em> tags begin with <tt>@@</tt>.  This can be changed.</p>

<p>The <i>Structural</i> tags (historically called "major commands") partition the input and define the
various chunks.  The <i>Inline</i> tags are (called "minor commands") are used to control the
woven and tangled output from those chunks.
</p>


<h3>Structure Tags</h3>
<p>There are two definitional tags; these define the various chunks
in an input file.  The </p>
<dl>
    <dt><tt>@@o <i>file</i> @@{ <i>text</i> @@}</tt></dt>
        <dd>The <tt>@@o</tt> (output) command defines a named output file chunk.  
        The text is tangled to the named
        file with no alteration.  It is woven into the document
        in an appropriate fixed-width font.</dd>
    <dt><tt>@@d <i>name</i> @@{ <i>text</i> @@}</tt></dt>
        <dd>The <tt>@@d</tt> (define) command defines a named chunk of program source. 
        This text is tangled
        or woven when it is referenced by the <i>reference</i> inline tag.</dd>
</dl

<p>Each <tt>@@o</tt> and <tt>@@d</tt> tag is followed by a chunk which is
delited by <tt>@@{</tt> and <tt>@@}</tt> tags.  
End the end of that chunk, there is an optional "major" tag.  
</p>
<dl>
    <dt><tt>@@|</tt></dt>
        <dd>A chunk may define user identifiers.  The list of defined identifiers is placed
in the chunk, separated by the <tt>@@|</tt> separator.</dd>
</dl>

Additionally, these tags provide for the inclusion of additional input files.
This is necessary for decomposing a long document into easy-to-edit sections.
<dl>
    <dt><tt>@@i <i>file</i></tt></dt>
        <dd>The <tt>@@i</tt> (include) command includes another file.  The previous chunk
        is ended.  The file is processed completely, then a new chunk
        is started for the text after the <tt>@@i</tt> command.</dd>
</dl>

<p>All material that is not explicitly in a <tt>@@o</tt> or <tt>@@d</tt> named chunk is
implicitly collected into a sequence of anonymous document source chunks.
These anonymous chunks form the backbone of the document that is woven.
The anonymous chunks are never tangled into output program source files.
They are woven into the document without any alteration.
</p>
<p>Note that white space (line breaks (<tt>'\n'</tt>), tabs and spaces) have no effect on the input parsing.
They are completely preserved on output.</p>

<p>The following example has three chunks.  An anonymous chunk of
documentation, a named output chunk, and an anonymous chunk of documentation.
</p>
<pre><code>
&lt;p&gt;Some HTML documentation that describes the following piece of the
program.&lt;/p&gt;
@@o myFile.py 
@@{
import math
print math.pi
@@| math math.pi
@@}
&lt;p&gt;Some more HTML documentation.&lt;/p&gt;
</code></pre>

<h3>Inline Tags</h3>
<p>There are several tags that are replaced by content in the woven output.</p>
<dl>
    <dt><tt>@@@@</tt></dt>
        <dd>The <tt>@@@@</tt> command creates a single <tt>@@</tt> in the output file.
        This is replaced in tangled as well as woven output.</dd>
    <dt><tt>@@&lt;<i>name</i>@@&gt;</tt></dt>
        <dd>The <i>name</i> references a named chunk.
        When tangling, the referenced chunk replaces the reference command.
        When weaving, a reference marker is used.  For example, in HTML, this can be 
        replaced with  <tt>&lt;A HREF=...&gt;</tt> markup.
        Note that the indentation of the <tt>@@&lt;</tt> tag is preserved
        for the tangled chunk that replaces the tag.
        </dd>
    <dt><tt>@@(<i>Python expression</i>@@)</tt></dt>
        <dd>The <i>Python expression</i> is evaluated and the result is tangled or
        woven in place.  A few global variables and modules are available.
        These are described <a href="#expressionContext">below</a>.</dd>
</dl>

<p>There are three index creation tags that are replaced by content in the woven output.</p>

<dl>
    <dt><tt>@@f</tt></dt>
        <dd>The <tt>@@f</tt> command inserts a file cross reference.  This
        lists the name of each file created by an <tt>@@o</tt> command, and all of the various
        chunks that are concatenated to create this file.</dd>
    <dt><tt>@@m</tt></dt>
        <dd>The <tt>@@m</tt> command inserts a named chunk ("macro") cross reference.  This
        lists the name of each chunk created by an @@d command, and all of the various
        chunks that are concatenated to create the complete chunk.</dd>
    <dt><tt>@@u</tt></dt>
        <dd>The <tt>@@u</tt> command inserts a user identifier cross reference.  This
        lists the name of each chunk created by an <tt>@@d</tt> command, and all of the various
        chunks that are concatenated to create the complete chunk.</dd>
</dl>

<h3>Document Overhead</h3>
<p>The documents generally need some minimal overheads to work correctly.</p>
<p>The <b>RST</b> weaver requires that you have <tt>..  include &lt;isoamsa.txt&gt;</tt></p>
<p>The <b>LaTeX</b> weaver requires that you have <tt>\usepackage{fancyvrb}</tt></p>

<h3>Additional Features</h3>
<p>The named chunks (from both <tt>@@o</tt> and <tt>@@d</tt> commands) are assigned 
unique sequence numbers to simplify cross references.  In LaTex it is possible 
to determine the page breaks and assign the sequence numbers based on
the physical pages.</p>
<p>Chunk names and file names are case sensitive.</p>

<p>Chunk names can be abbreviated.  A partial name can have a trailing ellipsis (...), 
this will be resolved to the full name.  The most typical use for this
is shown in the following example.</p>

<pre><code>
&lt;p&gt;Some HTML documentation.&lt;/p&gt;
@@o myFile.py 
@@{
@@&lt;imports of the various packages used@@&gt;
print math.pi,time.time()
@@}
&lt;p&gt;Some notes on the packages used.&lt;/p&gt;
@@d imports...
@@{
import math,time
@@| math time
@@}
&lt;p&gt;Some more HTML documentation.&lt;/p&gt;
</code></pre>

<ol>
<li>An anonymous chunk of documentation.</li>
<li>A named chunk that tangles the <tt>myFile.py</tt> output.  It has
a reference to the <i>imports of the various packages used</i> chunk.
Note that the full name of the chunk is essentially a line of 
documentation, traditionally done as a comment line in a non-literate
programming environment.</li>
<li>An anonymous chunk of documentation.</li>
<li>A named chunk with an abbreviated name.  The <i>imports...</i>
matches the complete name.  Set off after the <tt>@@|</tt> separator is
the list of identifiers defined in this chunk.</li>
<li>An anonymous chunk of documentation.</li>
</ol>

<p>Note that the first time a name appears (in a reference or definition),
it must be the full name.  All subsequent uses can be elisions.
Also not that ambiguous elision is an annoying problem when you 
first start creating a document.
</p>
<p>Named chunks are concatenated from their various pieces.
This allows a named chunk to be broken into several pieces, simplifying
the description.  This is most often used when producing 
fairly complex output files.</p>

<pre><code>
&lt;p&gt;An anonymous chunk with some HTML documentation.&lt;/p&gt;
@@o myFile.py 
@@{
import math,time
@@}
&lt;p&gt;Some notes on the packages used.&lt;/p&gt;
@@o myFile.py
@@{
print math.pi,time.time()
@@}
&lt;p&gt;Some more HTML documentation.&lt;/p&gt;
</code></pre>

<ol>
<li>An anonymous chunk of documentation.</li>
<li>A named chunk that tangles the <tt>myFile.py</tt> output.  It has
the first part of the file.  In the woven document
this is marked with <tt>"="</tt>.</li>
<li>An anonymous chunk of documentation.</li>
<li>A named chunk that also tangles the <tt>myFile.py</tt> output. This
chunk's content is appended to the first chunk.  In the woven document
this is marked with <tt>"+="</tt>.</li>
<li>An anonymous chunk of documentation.</li>
</ol>

<p>Newline characters are preserved on input.  Because of this the output may appear to have excessive newlines.  In all of the above examples, each
named chunk was defined with the following.</p>
<pre><code>
@@{
import math,time
@@}
</code></pre>
<p>This puts a newline character before and after the import line.</p>

<p>One transformation is performed when tangling output.  The indentation
of a chunk reference is applied to the entire chunk.  This makes it
simpler to prepare source for languages (like Python) where indentation
is important.  It also gives the author control over how the final
tangled output looks.</p>

<p>Also, note that the <tt>myFile.py</tt> uses the <tt>@@|</tt> command
to show that this chunk defines the identifier <tt>aFunction</tt>.
</p>
<pre><code>
&lt;p&gt;An anonymous chunk with some HTML documentation.&lt;/p&gt;
@@o myFile.py 
@@{
def aFunction( a, b ):
    @@&lt;body of the aFunction@@&gt;
@@| aFunction @@}
&lt;p&gt;Some notes on the packages used.&lt;/p&gt;
@@d body...
@@{
"""doc string"""
return a + b
@@}
&lt;p&gt;Some more HTML documentation.&lt;/p&gt;
</code></pre>

<p>The tangled output from this will look like the following.
All of the newline characters are preserved, and the reference to
<i>body of the aFunction</i> is indented to match the prevailing
indent where it was referenced.  In the following example, 
explicit line markers of <b><tt>~</tt></b> are provided to make the blank lines 
more obvious.
</p>
<pre><code>
~
~def aFunction( a, b ):
~        
~    """doc string"""
~    return a + b
~
</code></pre>

<p>There are two possible implementations for evaluation of a Python
expression in the input.</p>
<ol>
<li>Create an <b>ExpressionCommand</b>, and append this to the current <b>Chunk</b>.
This will allow evaluation during weave processing and during tangle processing.  This
makes the entire weave (or tangle) context available to the expression, including
completed cross reference information.</li>
<li>Evaluate the expression during input parsing, and append the resulting text
as a <b>TextCommand</b> to the current <b>Chunk</b>.  This provides a common result
available to both weave and parse, but the only context available is the <b>WebReader</b> and
the incomplete <b>Web</b>, built up to that point.</li>
</ol>
<a name="expressionContext"></a>
<p>In this implementation, we adopt the latter approach, and evaluate expressions immediately.
A simple global context is created with the following variables defined.</p>
<dl>
    <dt><tt>time</tt></dt><dd>This is the standard time module.</dd>
    <dt><tt>os</tt></dt><dd>This is the standard os module.</dd>
    <dt><tt>theLocation</tt></dt><dd>A tuple with the file name, first line number and last line number
    for the original expression's location</dd>
    <dt><tt>theWebReader</tt></dt><dd>The <b>WebReader</b> instance doing the parsing.</dd>
    <dt><tt>thisApplication</tt></dt><dd>The name of the running <em>pyWeb</em> application.</dd>
    <dt><tt>__version__</tt></dt><dd>The version string in the <em>pyWeb</em> application.</dd>
</dl>

<h2>Running <em>pyWeb</em> to Tangle and Weave</h2>

<p>Assuming that you have marked <tt>pyweb.py</tt> as executable,
you do the following.</p>
<pre>
./pyweb.py <i>file</i>...
</pre>
<p>This will tangle the <tt>@@o</tt> commands in each <i>file</i>.
It will also weave the output, and create <i>file</i>.html.
</p>

<h3>Command Line Options</h3>
<p>Currently, the following command line options are accepted.</p>
<dl>
    <dt><tt>-v</tt></dt>
        <dd>Verbose logging.  The default is changed by updating the 
        <a href="#log_setting">constructor</a>
        for <i>theLog</i> from <tt>Logger(standard)</tt> to <tt>Logger(verbose)</tt>.</dd>
    <dt><tt>-s</tt></dt>
        <dd>Silent operation.  The default is changed by updating the 
        <a href="#log_setting">constructor</a>
        for <i>theLog</i> from <tt>Logger(standard)</tt> to <tt>Logger(silent)</tt>.</dd>
    <dt><tt>-c <i>x</i></tt></dt>
        <dd>Change the command character from <tt>@@</tt> to <tt><i>x</i></tt>.
        The default is changed by updating the 
        <a href="#command_setting">constructor</a> for <i>theWebReader</i> from
        <tt>WebReader(f,'@@')</tt> to <tt>WebReader(f,'<i>x</i>')</tt>.</dd>
    <dt><tt>-w <i>weaver</i></tt></dt>
        <dd>Choose a particular documentation weaver, for instance 'rst', 'html', 'latex'.  
        The default is based on the first few characters of the input file.
        You can do this by updating the 
        <a href="#pick_language">language determination</a> call in the application
        main function from <tt>l= w.language()</tt> to <tt>l= HTML()</tt>.</dd>
    <dt><tt>-xw</tt></dt>
        <dd>Exclude weaving.  This does tangling of source program files only.</dd>
    <dt><tt>-xt</tt></dt>
        <dd>Exclude tangling.  This does weaving of the document file only.</dd>
    <dt><tt>-p<i>command</i></tt></dt>
        <dd>Permit errors in the given list of commands.  The most common
        version is <tt>-pi</tt> to permit errors in locating an include file.
        This is done in the following scenario: pass 1 uses <tt>-xw -pi</tt> to exclude
        weaving and permit include-file errors; 
        the tangled program is run to create test results; pass 2 uses
        <tt>-xt</tt> to exclude tangling and include the test results.</dd>
</dl>


<h2>Restrictions</h2>
<p><em>pyWeb</em> requires any Python that supports <tt>from __future__ import print_function</tt>.
Generally  version 2.6. or newer.
</p>
<p>Currently, input is not detabbed; Python users generally are discouraged from using tab characters in their files.</p>

<h2>Installation</h2>
<p>You must have <a href="http://www.python.org">Python 2.6</a>.</p>
<ol>
<li>Download and expand pyweb.zip.  You will get pyweb.css, pyweb.html, pyweb.pdf,
pyweb.py and pyweb.w.</li>
<li>Except on Windows, <tt>chmod +x pyweb.py</tt>.</li>
<li>If you like, <tt>cp pyweb.py /usr/local/bin/pyweb</tt> to make a global command.</li>
<li>Make a bootstrap copy of pyweb.py (I copy it to pyweb-2.1.py).  
You can run <tt>./pyweb.py pyweb.w</tt> to generate the latest and greatest pyweb.py file,
as well as this documentation, pyweb.html.</li>
</ol>
<p>Be sure to save a bootstrap copy of pyweb.py before changing pyweb.w.  
Should your changes to pyweb.w introduce a bug into pyweb.py, you will need a fall-back version
of <em>pyWeb</em> that you can use in place of the one you just damaged.
</p>

<h2>Acknowledgements</h2>
<p>This application is very directly based on (derived from?) work that
 preceded this, particularly the following:</p>
<ul>
<li>Ross N. Williams' <a href="http://www.ross.net/funnelweb/"><i>FunnelWeb</i></a></li>
<li>Norman Ramsey's <a href="http://www.eecs.harvard.edu/~nr/noweb/"><i>noweb</i></a></li> 
<li>Preston Briggs' <a href="http://sourceforge.net/projects/nuweb/"><i>nuweb</i></a>, 
currently supported by Charles Martin and Marc W. Mengel</li>
</ul>
<p>Also, after using John Skaller's <a href="http://interscript.sourceforge.net/"><i>interscript</i></a>
for two large development efforts, I finally understood the feature set I really needed.
</p>
<p>Jason Fruit contributed the current LaTeX template segments being used.</p>