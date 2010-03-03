<!-- pyweb/impl.w -->

<p>The implementation is contained in a file that both defines
the base classes and provides an overall <tt>main()</tt> function.  The <tt>main()</tt> 
function uses these base classes to weave and tangle the output files.
</p>

The broad outline of the presentation is as follows:

<ul>
<li><a href="#base">Base Class Definitions</a>.  This includes the web structure, 
the emitters (Weavers and Tanglers) and the high-level actions.</li>
<li><a href="#mod"><em>pyWeb</em> Module File</a>, including
Module Initialization, Application Class and <span class="code">main</span> function.</li>  
<li><a href="#scripts">Additional Scripts</a></li>
<li><a href="#admin">Administrative Elements</a></li>
</ul>

<a name="base"></a><h2>Base Class Definitions</h2>

<p>There are three major class hierarchies that compose the base of this application.  These are
families of related classes that express the basic relationships among entities.</p>
<ul>
<li>Emitters - An <span class="code">Emitter</span> creates an output file, either source code, LaTeX or HTML from
the chunks that make up the source file.  Two major subclasses are <span class="code">Weaver</span>, which 
has a focus on markup output, and <span class="code">Tangler</span> which has a focus on pure source output.
<span class="code">HTML</span> and <span class="code">LaTeX</span> are further specializations of the <span class="code">Weaver</span> class.  
The <span class="code">TanglerMake</span> subclass of the <span class="code">Tangler</span> class is a make-friendly source-code emitter.</li>
<li>Chunks - a <span class="code">Chunk</span> is a collection of <span class="code">Command</span> instances.  This can be
either an anonymous chunk that will be sent directly to the output, 
or one the classes of named chunks delimited by the
major <tt>@@d</tt> or <tt>@@o</tt> commands.</li>
<li>Commands - A <span class="code">Command</span> contains user input and creates output.  
This can be a block of text from the input file, 
one of the various kinds of cross reference commands (<tt>@@f</tt>, <tt>@@m</tt>, <tt>@@u</tt>) 
or a reference to a chunk (via the <tt>@@&lt;<i>name</i>@@&gt;</tt> sequence).</li>
</ul>
<p>Additionally, there are several supporting classes:</p>
<ul>
<li>a <span class="code">Web</span> class for the interconnected web of Chunks.</li>
<li>a <span class="code">WebReader</span> class that parses the input, creating the Commands and Chunks.</li>
<li>an <span class="code">Error</span> class for exceptions that are unique to this application.</li>
</ul>

@d Base Class Definitions 
@{
@<Error class - defines the errors raised@>
@<Command class hierarchy - used to describe individual commands@>
@<Chunk class hierarchy - used to describe input chunks@>
@<Web class - describes the overall "web" of chunks@>
@<Emitter class hierarchy - used to control output files@>
@<Reference class hierarchy - references to a chunk@> 
@<WebReader class - parses the input file, building the Web structure@>
@<Action class hierarchy - used to describe basic actions of the application@>
@}

<h3>Emitters</h3>

<p>An <span class="code">Emitter</span> instance is resposible for control of an output file format.
This includes the necessary file naming, opening, writing and closing operations.
It also includes providing the correct markup for the file type.
</p>

<p>There are several subclasses of the <span class="code">Emitter</span> superclass, specialized for various file
formats.
</p>
@d Emitter class hierarchy...
@{
@<Emitter superclass@>
@<Weaver subclass of Emitter to create documentation with fancy markup and escapes@>
@<LaTeX subclass of Weaver@>
@<HTML subclass of Weaver@>
@<Tangler subclass of Emitter to create source files with no markup@>
@<Tangler subclass which is make-sensitive@>
@}

<p>An <span class="code">Emitter</span> instance is created to contain the various details of
writing an output file.  Emitters are created as follows:
</p>
<ol>
<li>A <span class="code">Web</span> object will create an <span class="code">Emitter</span> to <em>weave</em> the final document.</li>
<li>A <span class="code">Web</span> object will create an <span class="code">Emitter</span> to <em>tangle</em> each file.</li>
</ol>
<p>Since each <span class="code">Emitter</span> instance is responsible for the details of one file
type, different subclasses of Emitter are used when tangling source code files (<span class="code">Tangler</span>) and 
weaving files that include source code plus markup (<span class="code">Weaver</span>).
</p>
<p>
Further specialization is required when weaving HTML or LaTeX.  Generally, this is 
a matter of providing two things:
<ul>
<li>Boilerplate text to replace various pyWeb constructs</li>
<li>Escape rules to make source code amenable to the markup language</li>
</ul>
</p>
<p>An additional part of the escape rules can include using a syntax coloring 
toolset instead of simply applying escapes.
</p>
<p>In the case of tangling, the following algorithm is used:</p>
<ol>
<li>Visit each each output <span class="code">Chunk</span> (<tt>@@o</tt>), doing the following:
    <ol>
    <li>Open the <span class="code">Tangler</span> instance using the target file name.</li>
    <li>Visit each <span class="code">Chunk</span> directed to the file, calling the chunk's <span class="code">tangle()</span> method.
        <ol>
        <li>Call the Tangler's <span class="code">docBegin()</span> method.  This sets the Tangler's indents.</li>
        <li>Visit each <span class="code">Command</span>, call the command's <span class="code">tangle()</span> method.  For the text
            of the chunk, the
            text is written to the tangler using the <span class="code">codeBlock()</span> method.  For
            references to other chunks, the referenced chunk is tangled using the 
            referenced chunk's <span class="code">tangler()</span> method.</li>
        <li>Call the Tangler's <span class="code">docEnd()</span> method.  This clears the Tangler's indents.</li>
        </ol>
    </li>
    </ol>
</li>
</ol>
<p>In the case of weaving, the following algorithm is used:</p>
<ol>
<li>If no Weaver is given, examine the first Command of the first Chunk and create a weaver
appropriate for the output format.  A leading '<' indicates HTML, otherwise assume LaTeX.
<li>Open the <span class="code">Weaver</span> instance using the source file name.  This name is transformed
by the weaver to an output file name appropriate to the language.</li>
<li>Visit each each sequential <span class="code">Chunk</span> (anonymous, <tt>@@d</tt> or <tt>@@o</tt>), doing the following:
    <ol>
    <li>Visit each <span class="code">Chunk</span>, calling the Chunk's <span class="code">weave()</span> method.
        <ol>
        <li>Call the Weaver's <span class="code">docBegin()</span>, <span class="code">fileBegin()</span> or <span class="code">codeBegin()</span> method, 
        depending on the subclass of Chunk.  For 
        <span class="code">fileBegin()</span> and <span class="code">codeBegin()</span>, this writes the header for
        a code chunk in the weaver's markup language.  A slightly different decoration
        is applied by <span class="code">fileBegin()</span> and <span class="code">codeBegin()</span>.</li>
        <li>Visit each <span class="code">Command</span>, call the Command's <span class="code">weave()</span> method.  
            For ordinary text, the
            text is written to the Weaver using the <span class="code">codeBlock()</span> method.  For
            references to other chunks, the referenced chunk is woven using 
            the Weaver's <span class="code">referenceTo()</span> method.</li>
        <li>Call the Weaver's <span class="code">docEnd()</span>, <span class="code">fileEnd()</span> or <span class="code">codeEnd()</span> method.  
        For <span class="code">fileEnd()</span> or <span class="code">codeEnd()</span>, this writes a trailer for
        a code chunk in the Weaver's markup language.</li>
        </ol>
    </li>
    </ol>
</li>
</ol>

<h4>Emitter Superclass</h4>

<h5>Usage</h5>
<p>The <span class="code">Emitter</span> class is not a concrete class; it is never instantiated.  It
contains common features factored out of the <span class="code">Weaver</span> and <span class="code">Tangler</span> subclasses.</p>
<p>Inheriting from the Emitter class generally requires overriding one or more
of the core methods: <span class="code">doOpen()</span>, <span class="code">doClose()</span> and <span class="code">doWrite()</span>.
A subclass of Tangler, might override the code writing methods: 
<span class="code">codeLine()</span>, <span class="code">codeBlock()</span> or <span class="code">codeFinish()</span>.
</p>

<h5>Design</h5>

<p>The <span class="code">Emitter</span> class is an abstract superclass for all emitters.  It defines the basic
framework used to create and write to an output file.
This class follows the <i>Template</i> design pattern.  This design pattern
directs us to factor the basic open(), close() and write() methods into three step algorithms.
</p>
<pre>
def open( self ):
    <i>common preparation</i>
    self.do_open() <i>#overridden by subclasses</i>
    <i>common finish-up tasks</i>
</pre>
<p>The <i>common preparation</i> and <i>common finish-up</i> sections are generally internal 
housekeeping.  The <span class="code">do_open()</span> method would be overridden by subclasses to change the
basic behavior.
</p>

<h5>Implementation</h5>

<p>The class has the following attributes:</p>
<ul>
<li><i>fileName</i>, the name of the current open file created by the
open method;</li>
<li><i>theFile</i>, the current open file created by the
open method;</li>
<li><i>context</i>, the indentation context stack, updated by setIndent, clrIndent 
and resetIndent methods;</li>
<li><i>indent</i>, the current indentation, the topmost value on the <i>context</i>
stack;</li>
<li><i>lastIndent</i>, the last indent used when writing a line of source code.</li>
<li><i>linesWritten</i>, the total number of '\n' characters written to the file.</li>
</ul>

@d Emitter superclass
@{
class Emitter( object ):
    """Emit an output file; handling indentation context."""
    def __init__( self ):
        self.fileName= ""
        self.theFile= None
        self.context= [0]
        self.indent= 0
        self.lastIndent= 0
        self.linesWritten= 0
        self.totalFiles= 0
        self.totalLines= 0
        self.log_indent= logging.getLogger( "pyweb.%s.indent" % self.__class__.__name__ )
    def __str__( self ):
        return self.__class__.__name__
    @<Emitter core open, close and write@>
    @<Emitter write a block of code@>
    @<Emitter indent control: set, clear and reset@>
@| Emitter 
@}

<p>The core <span class="code">open()</span> method tracks the open files.
A subclass overrides a <span class="code">doOpen()</span> method to name the output file, and
then actually open the file.  The Weaver will create an output file with
a name that's based on the overall project.  The Tangler will open the given file
name.
</p>
<p>The <span class="code">close()</span> method closes the file.  As with  <span class="code">open()</span>, a
<span class="code">doClose()</span> method actually closes the file.  This allows subclasses
to do overrides on the actual file processing.
</p>
<p>The <span class="code">write()</span> method is the lowest-level, unadorned write.
This does no some additional counting as well as moving the
characters to the file.  Any further processing could be added in a function
that overrides <span class="code">doWrite()</span>.
</p>
<p>The default <span class="code">write()</span> method prints to  the standard output file.
</p>

@d Emitter core...
@{
def open( self, aFile ):
    """Open a file."""
    self.fileName= aFile
    self.doOpen( aFile )
    self.linesWritten= 0
@<Emitter doOpen, to be overridden by subclasses@>
def close( self ):
    self.codeFinish()
    self.doClose()
    self.totalFiles += 1
    self.totalLines += self.linesWritten
@<Emitter doClose, to be overridden by subclasses@>
def write( self, text ):
    if text is None: return
    self.linesWritten += text.count('\n')
    self.doWrite( text )
@<Emitter doWrite, to be overridden by subclasses@>
@| open close write
@}

<p>The <span class="code">doOpen()</span>, <span class="code">doClose()</span> and <span class="code">doWrite()</span> 
method is overridden by the various subclasses to
perform the unique operation for the subclass.
</p>
@d Emitter doOpen... @{
def doOpen( self, aFile ):
    self.fileName= aFile
    logger.debug( "creating %r", self.fileName )
@| doOpen
@}

@d Emitter doClose... @{
def doClose( self ):
    logger.debug( "wrote %d lines to %s",
        self.linesWritten, self.fileName )
@| doClose
@}

@d Emitter doWrite... @{
def doWrite( self, text ):
    print( text, end=None )
@| doWrite
@}


<p>The <span class="code">codeBlock()</span> method writes several lines of code.  It calls
the <span class="code">codeLine()</span> method for each line of code after doing the correct indentation.
Often, the last line of code is incomplete, so it is left unterminated.
This last line of code also shows the indentation for any 
additional code to be tangled into this section.
</p>
<p>
Note that tab characters confuse the indent algorithm.  Tabs are 
not expanded to spaces in this application.  They should be expanded 
prior to creating a .w file.
</p>
<p>The algorithm is as follows:</p>
<ol>
<li>Save the topmost value of the context stack as the current indent.</li>
<li>Split the block of text on <tt>'\n'</tt> boundaries.</li>
<li>For each line (except the last), call <span class="code">codeLine()</span> with the indented text, 
ending with a newline.</li>
<li>The string <span class="code">split()</span> method will put a trailing 
zero-length element in the list if the original block ended with a
newline.  We drop this zero length piece to prevent writing a useless fragment 
of indent-only after the final <tt>'\n'</tt>.  
If the last line has content, call codeLine with the indented text, 
but do not write a trailing <tt>'\n'</tt>.</li>
<li>Save the length of the last line as the most recent indent.</li>
</ol>

@d Emitter write a block...
@{
def codeBlock( self, text ):
    """Indented write of a block of code."""
    self.indent= self.context[-1]
    lines= text.split( '\n' )
    for l in lines[:-1]:
        self.write( '%s%s\n' % (self.indent*' ',l) )
    if lines[-1]:
        self.write( '%s%s' % (self.indent*' ',lines[-1]) )
    self.lastIndent= len(lines[-1]) + self.indent
@| codeBlock
@}

<p>The <span class="code">codeLine()</span> method writes a single line of source code.
This is often overridden by Weaver subclasses to transform source into
a form acceptable by the final weave file format.
</p>
<p>In the case of an HTML weaver, the HTML reserved characters
(<tt>&lt;</tt>, <tt>&gt;</tt>, <tt>&amp;</tt>, and <tt>&quot;</tt>) must be replaced in the output
of code.  However, since the author's original document sections contain
HTML these will not be altered.
</p>

@d Emitter write a block...
@{
quoted_chars = [
    # Must be empty for tangling to work.
]

def quote( self, aLine ):
    """Each individual line of code; often overridden by weavers to quote the code."""
    clean= aLine
    for from_, to_ in self.quoted_chars:
        clean= clean.replace( from_, to_ )
    return clean
@| codeLine
@}

<p>The <span class="code">codeFinish()</span> method finishes writing any cached lines when
the emitter is closed.</p>

@d Emitter write a block...
@{
def codeFinish( self ):
    if self.lastIndent > 0:
        self.write('\n')
@| codeFinish
@}

<p>The <span class="code">setIndent()</span> method pushes the last indent on the context stack.  
This is used when tangling source
to be sure that the included text is indented correctly with respect to the
surrounding text.
</p>
<p>The <span class="code">clrIndent()</span> method discards the most recent indent from the context stack.  
This is used when finished
tangling a source chunk.  This restores the indent to the prevailing indent.
</p>
<p>The <span class="code">resetIndent()</span> method removes all indent context information.
</p>

<blockquote><p>TODO:  Note that <span class="code">setIndent()</span> should be
refactored, since tangling uses the <tt>command</tt> option and weaving uses
the <tt>fixed</tt> option.
</blockquote>

@d Emitter indent control...
@{
def setIndent( self, fixed=None, command=None ):
    """Either use a fixed indent (for weaving) or the previous command (for tangling)."""
    self.context.append( self.context[-1]+command.indent() if fixed is None else fixed )
    self.log_indent.debug( "setIndent %s: %r", fixed, self.context )
def clrIndent( self ):
    if len(self.context) > 1:
        self.context.pop()
    self.indent= self.context[-1]
    self.log_indent.debug( "clrIndent %r", self.context )
def resetIndent( self ):
    self.context= [0]
    self.log_indent.debug( "resetIndent %r", self.context )
@| setIndent clrIndent resetIndent
@}

<h4>Weaver subclass of Emitter</h4>
<h5>Usage</h5>
<p>A Weaver is an Emitter that produces the final user-focused document.
This will include the source document with the code blocks surrounded by
markup to present that code properly.  In effect, the pyWeb <tt>@@</tt> commands
are replaced by markup.
</p>
<p>
The Weaver class uses a simple set of templates to product RST markup.
</p>
<p>Most weaver languages don't rely on special indentation rules.
The woven code samples usually start right on the left margin of 
the source document.  However, the RST markup language does rely
on indentation of code blocks.  For that reason, the weavers
have a fixed indent for code blocks.  This is generally 
set to zero, except when generating RST.
</p>

<h5>Design</h5>
<p>The <span class="code">Weaver</span> subclass defines an <span class="code">Emitter</span> used to <em>weave</em> the final
documentation.  This involves decorating source code to make it
displayable.  It also involves creating references and cross
references among the various chunks.
</p>
<p>The <span class="code">Weaver</span> class adds several methods to the basic <span class="code">Emitter</span> methods.  These
additional methods are also included that are used exclusively when weaving, never when tangling.
</p>

<h5>Implementation</h5>
<p>This class hierarch depends heavily on the <span class="code">string</span> module.

@d Imports
@{import string
@| string
@}

@d Weaver subclass of Emitter...
@{
class Weaver( Emitter ):
    """Format various types of XRef's and code blocks when weaving."""
    extension= ".rst" # A subclass will provide their preferred extension
    code_indent= 4
    @<Weaver doOpen, doClose and doWrite overrides@>
    
    # Template Expansions.
    @<Weaver quoted characters@>
    @<Weaver document chunk begin-end@>
    @<Weaver reference summary, used by code chunk and file chunk@>
    @<Weaver code chunk begin-end@>
    @<Weaver file chunk begin-end@>
    @<Weaver reference command output@>
    @<Weaver cross reference output methods@>
@| Weaver 
@}

<p>The open method opens the file for writing.  For weavers, the file extension
is specified part of the target markup language being created.
</p>
<p>The close method overrides the <span class="code">Emitter</span> class <span class="code">close()</span> method by closing the
actual file created by the open() method.
</p>
<p>This write method overrides the <span class="code">Emitter</span> class <span class="code">write()</span> method by writing to the
actual file created by the <span class="code">open()</span> method.
</p>

@d Weaver doOpen...
@{
def doOpen( self, aFile ):
    src, _ = os.path.splitext( aFile )
    self.fileName= src + self.extension
    self.theFile= open( self.fileName, "w" )
    logger.info( "Weaving %r", self.fileName )
def doClose( self ):
    self.theFile.close()
    logger.info( "Wrote %d lines to %r", 
        self.linesWritten, self.fileName )
def doWrite( self, text ):
    self.theFile.write( text )
@| doOpen doClose doWrite
@}

<p>The remaining methods apply a chunk to a template.</p>

@d Weaver quoted characters...
@{
quoted_chars = [
    # prevent some RST markup from being recognized
    ('`',r'\`'),
    ('_',r'\_'), 
    ('*',r'\*'),
    ('|',r'\|'),
]
@}

<p>The <span class="code">docBegin()</span> and <span class="code">docEnd()</span> 
methods are used when weaving a document text chunk.
Typically, nothing is done before emitting these kinds of chunks.
However, putting a <tt>&lt;!--line number--&gt;</tt> comment is an example
of possible additional processing.
</p>

@d Weaver document...
@{
def docBegin( self, aChunk ):
    pass
def docEnd( self, aChunk ):
    pass
@| docBegin docEnd
@}

<p>Each code chunk includes the places where the chunk is referenced</p>
@d Weaver reference summary...
@{
ref_template = string.Template( "\nUsed by: ${refList}\n" )
ref_item_template = string.Template( "$fullName (`${seq}`_)" )
def references( self, aChunk ):
    if aChunk.references_list:
        refList= [ 
            self.ref_item_template.substitute( seq=s, fullName=n )
            for n,s in aChunk.references_list ]
        return self.ref_template.substitute( refList="; ".join( refList ) ) # HTML Separator
    return ""
@| references
@}


<p>The <span class="code">codeBegin()</span> method emits the necessary material prior to 
a chunk of source code, defined with the <tt>@@d</tt> command.
</p>
<p>The <span class="code">codeEnd()</span> method emits the necessary material subsequent to 
a chunk of source code, defined with the <tt>@@d</tt> command.  
Links or cross references to chunks that 
refer to this chunk can be emitted.
</p>

@d Weaver code...
@{
cb_template = string.Template( "\n..  _`${seq}`:\n..  rubric:: ${fullName} (${seq})\n..  parsed-literal::\n    " )
def codeBegin( self, aChunk ):
    tex = self.cb_template.substitute( 
        seq= aChunk.seq,
        lineNumber= aChunk.lineNumber, 
        fullName= aChunk.fullName,
        concat= "=" if aChunk.initial else "+=", # LaTeX Separator
    )
    self.write( tex )
ce_template = string.Template( "\n${references}\n" )
def codeEnd( self, aChunk ):
    tex = self.ce_template.substitute( 
        seq= aChunk.seq,
        lineNumber= aChunk.lineNumber, 
        fullName= aChunk.fullName,
        references= self.references( aChunk ),
    )
    self.write(tex)
@| codeBegin codeEnd
@}

<p>The <span class="code">fileBegin()</span> method emits the necessary material prior to 
a chunk of source code, defined with the <tt>@@o</tt> command.
A subclass would override this to provide specific text
for the intended file type.
</p>
<p>The <span class="code">fileEnd()</span> method emits the necessary material subsequent to 
a chunk of source code, defined with the <tt>@@o</tt> command.  
The list of references
is also provided so that links or cross references to chunks that 
refer to this chunk can be emitted.
A subclass would override this to provide specific text
for the intended file type.
</p>

@d Weaver file...
@{
fb_template = string.Template( "\n..  _`${seq}`:\n..  rubric:: ${fullName} (${seq})\n..  parsed-literal::\n    " )
def fileBegin( self, aChunk ):
    txt= self.fb_template.substitute(
        seq= aChunk.seq, 
        lineNumber= aChunk.lineNumber, 
        fullName= aChunk.fullName,
        concat= "=" if aChunk.initial else "+=", # HTML Separator
    )
    self.write( txt )
fe_template= string.Template( "\n${references}\n" )
def fileEnd( self, aChunk ):
    txt= self.fe_template.substitute(
        seq= aChunk.seq, 
        lineNumber= aChunk.lineNumber, 
        fullName= aChunk.fullName,
        references= self.references( aChunk ) )
    self.write( txt )
@| fileBegin fileEnd
@}

<p>The <span class="code">referenceTo()</span> method emits a reference to 
a chunk of source code.  There reference is made with a
<tt>@@&lt;...@@&gt;</tt> reference  within a <tt>@@d</tt> or <tt>@@o</tt> chunk.
The references are defined with the <tt>@@d</tt> or <tt>@@o</tt> commands.  
A subclass would override this to provide specific text
for the intended file type.
</p>

@d Weaver reference command...
@{
refto_name_template= string.Template("""|srarr| ${fullName} (`${seq}`_)""")
refto_seq_template= string.Template("""|srarr| (`${seq}`_)""")
def referenceTo( self, aName, seq ):
    """Weave a reference to a chunk."""
    # Provide name to get a full reference.
    # Omit name to get a short reference.
    if aName:
        return self.refto_name_template.substitute( fullName= aName, seq= seq )
    else:
        return self.refto_seq_template.substitute( seq= seq )
@| referenceTo
@}

<p>The <span class="code">xrefHead()</span> method puts decoration in front of cross-reference
output.  A subclass may override this to change the look of the final
woven document.
</p>
<p>The <span class="code">xrefFoot()</span> method puts decoration after cross-reference
output.  A subclass may override this to change the look of the final
woven document.
</p>
<p>The <span class="code">xrefLine()</span> method is used for both 
file and chunk ("macro") cross-references to show a name (either file name
or chunk name) and a list of chunks that reference the file or chunk.
</p>
<p>The <span class="code">xrefDefLine()</span> method is used for the user identifier cross-reference.
This shows a name and a list of chunks that 
reference or define the name.  One of the chunks is identified as the
defining chunk, all others are referencing chunks.
</p>
<p>The default behavior simply writes the Python data structure used
to represent cross reference information.  A subclass may override this 
to change the look of the final woven document.
</p>

@d Weaver cross reference...
@{
xref_head_template = string.Template( "\n" )
xref_foot_template = string.Template( "\n" )
xref_item_template = string.Template( ":${fullName}:\n    ${refList}\n" )
def xrefHead( self ):
    txt = self.xref_head_template.substitute()
    self.write( txt )
def xrefFoot( self ):
    txt = self.xref_foot_template.substitute()
    self.write( txt )
def xrefLine( self, name, refList ):
    refList= [ self.referenceTo( None, r ) for r in refList ]
    txt= self.xref_item_template.substitute( fullName= name, refList = " ".join(refList) ) # HTML Separator
    self.write( txt )
@}

<p>xref Def Line...</p>

@d Weaver cross reference...
@{
name_def_template = string.Template( '[`${seq}`_]' )
name_ref_template = string.Template( '`${seq}`_' )
def xrefDefLine( self, name, defn, refList ):
    templates = { defn: self.name_def_template }
    refTxt= [ templates.get(r,self.name_ref_template).substitute( seq= r )
        for r in sorted( refList + [defn] ) 
        ]
    txt= self.xref_item_template.substitute( fullName= name, refList = " ".join(refTxt) ) # HTML Separator
    self.write( txt )
@| xrefHead xrefFoot xrefLine xrefDefLine
@}

<h4>LaTeX subclass of Weaver</h4>
<h5>Usage</h5>
<p>An instance of <span class="code">LaTeX</span> can be used by the <span class="code">Web</span> object to 
weave an output document.  The instance is created outside the Web, and
given to the <span class="code">weave()</span> method of the Web.
</p>
<pre>
w= Web( "someName.w" )
WebReader().web(w).load()
weave_latex= LaTeX()
w.weave( weave_latex )
</pre>

<p>Note that the template language and LaTeX both use <tt>$</tt>.
This means that all  <tt>$</tt> that are intended to be output to LaTeX
must appear as <tt>$$</tt> in the template.
</p>

<h5>Design</h5>
<p>The <span class="code">LaTeX</span> subclass defines a Weaver that is customized to
produce LaTeX output of code sections and cross reference information.
Its markup is pretty rudimentary, but it's also distinctive enough to
function pretty well in most <b>LaTeX</b> documents.
</p>

<h5>Implementation</h5>

@d LaTeX subclass...
@{
class LaTeX( Weaver ):
    """LaTeX formatting for XRef's and code blocks when weaving.
    Requires \\usepackage{fancyvrb}
    """
    extension= ".tex"
    code_indent= 0
    @<LaTeX code chunk begin@>
    @<LaTeX code chunk end@>
    @<LaTeX file output begin@>
    @<LaTeX file output end@>
    @<LaTeX references summary at the end of a chunk@>
    @<LaTeX write a line of code@>
    @<LaTeX reference to a chunk@>
@| LaTeX 
@}

<p>The LaTeX <span class="code">open()</span> method opens the woven file by replacing the
source file's suffix with <tt>".tex"</tt> and creating the resulting file.
</p>

<p>The LaTeX <b>codeBegin()</b> template writes the header prior to a
chunk of source code.  It aligns the block to the left, prints an
italicised header, and opens a preformatted block.
</p>
  
@d LaTeX code chunk begin
@{
cb_template = string.Template( """\\label{pyweb${seq}}
\\begin{flushleft}
\\textit{Code example ${fullName} (${seq})}
\\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]\n""") # Prevent indent
@| codeBegin
@}


<p>The LaTeX <b>codeEnd()</b> template writes the trailer subsequent to
a chunk of source code.  This first closes the preformatted block and
then calls the <b>references()</b> method to write a reference
to the chunk that invokes this chunk; finally, it restores paragraph
indentation.
</p>
  
@d LaTeX code chunk end
@{
ce_template= string.Template("""
\\end{Verbatim}
${references}
\\end{flushleft}\n""") # Prevent indentation
@| codeEnd
@}


<p>The LaTeX <b>fileBegin()</b> template writes the header prior to a
the creation of a tangled file.  Its formatting is identical to the
start of a code chunk.
</p>

@d LaTeX file output begin
@{
fb_template= cb_template
@| fileBegin
@}

<p>The LaTeX <b>fileEnd()</b> template writes the trailer subsequent to
a tangled file.  This closes the preformatted block, calls the LaTeX
<b>references()</b> method to write a reference to the chunk that
invokes this chunk, and restores normal indentation.  </p>

@d LaTeX file output end
@{
fe_template= ce_template
@| fileEnd
@}

<p>The <b>references()</b> template writes a list of references after a
chunk of code.  Each reference includes the example number, the title,
and a reference to the LaTeX section and page numbers on which the
referring block appears.  </p>
  
@d LaTeX references summary...
@{
ref_item_template = string.Template( """
\\item Code example ${fullName} (${seq}) (Sect. \\ref{pyweb${seq}}, p. \\pageref{pyweb${seq}})\n""")
ref_template = string.Template( """
\\footnotesize
Used by:
\\begin{list}{}{}
${refList}
\\end{list}
\\normalsize\n""")
@| references
@}

<p>The <b>codeLine()</b> method quotes a single line of code to the
weaver; since these lines are always in preformatted blocks, no
special formatting is needed, except to avoid ending the preformatted
block.  Our one compromise is a thin space if the phrase
<tt>\\end{Verbatim}</tt> is used in a code block.</p>
  
@d LaTeX write a line...
@{
quoted_chars = [
    ("\\end{Verbatim}", "\\end\,{Verbatim}"), # Allow \end{Verbatim}
    ("\\{","\\\,{"), # Prevent unexpected commands in Verbatim
    ("$","\\$"), # Prevent unexpected math in Verbatim
]
@| quoted_chars
@}

<p>The <span class="code">referenceTo()</span> template writes a reference to another chunk of
code.  It uses write directly as to follow the current indentation on
the current line of code.
</p>

@d LaTeX reference to...
@{
refto_name_template= string.Template("""$$\\triangleright$$ Code Example ${fullName} (${seq})""")
refto_seq_template= string.Template("""(${seq})""")
@| referenceTo
@}

<h4>HTML subclasses of Weaver</h4>
<h5>Usage</h5>
<p>An instance of <span class="code">HTML</span> can be used by the <span class="code">Web</span> object to 
weave an output document.  The instance is created outside the Web, and
given to the <span class="code">weave()</span> method of the Web.
</p>
<pre>
w= Web( "someName.w" )
WebReader().web(w).load()
weave_html= HTML()
w.weave( weave_html )
</pre>

<p>Variations in the output formatting are accomplished by having
variant subclasses of HTML.  In this implementation, we have two
variations: full path references, and short references.  The base class
produces complete reference paths; a subclass produces abbreviated references.
</p>

<h5>Design</h5>
<p>The <span class="code">HTML</span> subclass defines a Weaver that is customized to
produce HTML output of code sections and cross reference information.
</p>
<p>All HTML chunks are identified by anchor names of the form <tt>pyweb<i>n</i></tt>.  Each
<i>n</i> is the unique chunk number, in sequential order.
</p>
<p>An <span class="code">HTMLShort</span> subclass defines a Weaver that produces HTML output
with abbreviated (no name) cross references at the end of the chunk.</p>

<h5>Implementation</h5>

@d HTML subclass...
@{
class HTML( Weaver ):
    """HTML formatting for XRef's and code blocks when weaving."""
    extension= ".html"
    code_indent= 0
    @<HTML code chunk begin@>
    @<HTML code chunk end@>
    @<HTML output file begin@>
    @<HTML output file end@>
    @<HTML references summary at the end of a chunk@>
    @<HTML write a line of code@>
    @<HTML reference to a chunk@>
    @<HTML simple cross reference markup@>
@| HTML 
@}

@d HTML subclass...
@{
class HTMLShort( HTML ):
    """HTML formatting for XRef's and code blocks when weaving with short references."""
    @<HTML short references summary at the end of a chunk@>
@| HTML 
@}

<p>The <span class="code">codeBegin()</span> template starts a chunk of code, defined with <tt>@@d</tt>, providing a label
and HTML tags necessary to set the code off visually.
</p>

@d HTML code chunk begin
@{
cb_template= string.Template("""
<a name="pyweb${seq}"></a>
<!--line number ${lineNumber}-->
<p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
<code><pre>\n""")
@| codeBegin
@}

<p>The <span class="code">codeEnd()</span> template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.
</p>

@d HTML code chunk end
@{
ce_template= string.Template("""
</pre></code>
<p>&loz; <em>${fullName}</em> (${seq}).
${references}
</p>\n""")
@| codeEnd
@}

<p>The <span class="code">fileBegin()</span> template starts a chunk of code, defined with <tt>@@o</tt>, providing a label
and HTML tags necessary to set the code off visually.
</p>

@d HTML output file begin
@{
fb_template= string.Template("""<a name="pyweb${seq}"></a>
<!--line number ${lineNumber}-->
<p><tt>${fullName}</tt> (${seq})&nbsp;${concat}</p>
<code><pre>\n""") # Prevent indent
@| fileBegin
@}

<p>The <span class="code">fileEnd()</span> template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.
</p>

@d HTML output file end
@{
fe_template= string.Template( """</pre></code>
<p>&loz; <tt>${fullName}</tt> (${seq}).
${references}
</p>\n""")
@| fileEnd
@}

<p>The <span class="code">references()</span> template writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.
</p>
@d HTML references summary...
@{
ref_item_template = string.Template(
'<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
)
ref_template = string.Template( '  Used by ${refList}.'  )
@| references
@}

<p>The <span class="code">codeLine()</span> method writes an individual line of code for HTML purposes.
This encodes the four basic HTML entities (&lt;, &gt;, &amp;, &quot;) to prevent code from being interpreted
as HTML.
</p>

@d HTML write a line of code
@{
quoted_chars = [
    ("&", "&amp;"), # Must be first
    ("<", "&lt;"),
    (">", "&gt;"),
    ('"', "&quot;"),
]
@| quoted_chars
@}

<p>The <span class="code">referenceTo()</span> template writes a reference to another chunk.  It uses the 
direct <span class="code">write()</span> method so that the reference is indented properly with the
surrounding source code.
</p>

@d HTML reference to a chunk
@{
refto_name_template = string.Template(
'<a href="#pyweb${seq}">&rarr;<em>${fullName}</em> (${seq})</a>'
)
refto_seq_template = string.Template(
'<a href="#pyweb${seq}">(${seq})</a>'
)
@| referenceTo
@}

<p>The <span class="code">xrefHead()</span> method writes the heading for any of the cross reference blocks created by
<tt>@@f</tt>, <tt>@@m</tt>, or <tt>@@u</tt>.  In this implementation, the cross references are simply unordered lists. 
</p>
<p>The <span class="code">xrefFoot()</span> method writes the footing for any of the cross reference blocks created by
<tt>@@f</tt>, <tt>@@m</tt>, or <tt>@@u</tt>.  In this implementation, the cross references are simply unordered lists. 
</p>
<p>The <span class="code">xrefLine()</span> method writes a line for the file or macro cross reference blocks created by
<tt>@@f</tt> or <tt>@@m</tt>.  In this implementation, the cross references are simply unordered lists. 
</p>

@d HTML simple cross reference markup
@{
xref_head_template = string.Template( "<dl>\n" )
xref_foot_template = string.Template( "</dl>\n" )
xref_item_template = string.Template( "<dt>${fullName}</dt><dd>${refList}</dd>\n" )
@<HTML write user id cross reference line@>
@| xrefHead xrefFoot xrefLine
@}

<p>The <span class="code">xrefDefLine()</span> method writes a line for the user identifier cross reference blocks created by
@@u.  In this implementation, the cross references are simply unordered lists.  The defining instance 
is included in the correct order with the other instances, but is bold and marked with a bullet (&bull;).
</p>

@d HTML write user id cross reference line
@{
name_def_template = string.Template( '<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>' )
name_ref_template = string.Template( '<a href="#pyweb${seq}">${seq}</a>' )
@| xrefDefLine
@}

<p>The HTMLShort subclass enhances the HTML class to provide short 
cross references.
The <span class="code">references()</span> method writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.
</p>
@d HTML short references summary...
@{
ref_item_template = string.Template( '<a href="#pyweb${seq}">(${seq})</a>' )
@| references
@}

<h4>Tangler subclass of Emitter</h4>
<h5>Usage</h5>
<p>The <span class="code">Tangler</span> class is concrete, and can tangle source files.  An
instance of <span class="code">Tangler</span> is given to the <span class="code">Web</span> class <span class="code">tangle()</span> method.
<pre>
w= Web( "someFile.w" )
WebReader().web(w).load()
t= Tangler()
w.tangle( t )
</pre>

<h5>Design</h5>
<p>The <span class="code">Tangler</span> subclass defines an Emitter used to <em>tangle</em> the various
program source files.  The superclass is used to simply emit correctly indented 
source code and do very little else that could corrupt or alter the output.
</p>
<p>Language-specific subclasses could be used to provide additional decoration.
For example, inserting <tt>#line</tt> directives showing the line number
in the original source file.
</p>
<p>For Python, where indentation matters, the indent rules are relatively
simple.  The whitespace berfore a <tt>@@&lt;</tt> command is preserved as
the prevailing indent for the block tangled as a replacement for the  <tt>@@&lt;...@@&gt;</tt>.
</p>
<h5>Implementation</h5>

@d Tangler subclass of Emitter...
@{
class Tangler( Emitter ):
    """Tangle output files."""
    def __init__( self ):
        super( Tangler, self ).__init__()
        self.comment_start= ""
        self.comment_end= ""
        self.debug= False
    @<Tangler doOpen, doClose and doWrite overrides@>
    @<Tangler code chunk begin@>
    @<Tangler code chunk end@>
@| Tangler 
@}

<p>The default for all tanglers is to create the named file.
</p>
<p>This <span class="code">doClose()</span> method overrides the <span class="code">Emitter</span> class <span class="code">doClose()</span> method by closing the
actual file created by open.
</p>
<p>This <span class="code">doWrite()</span> method overrides the <span class="code">Emitter</span> class <span class="code">doWrite()</span> method by writing to the
actual file created by open.
</p>

@d Tangler doOpen...
@{
def doOpen( self, aFile ):
    self.fileName= aFile
    self.theFile= open( aFile, "w" )
    logger.info( "Tangling %r", aFile )
def doClose( self ):
    self.theFile.close()
    logger.info( "Wrote %d lines to %r",
        self.linesWritten, self.fileName )
def doWrite( self, text ):
    self.theFile.write( text )
@| doOpen doClose doWrite
@}

<p>The <span class="code">codeBegin()</span> method starts emitting a new chunk of code.
It does this by setting the Tangler's indent to the
prevailing indent at the start of the <tt>@@&lt;</tt> reference command.</p>

@d Tangler code chunk begin
@{
def codeBegin( self, aChunk ):
    self.log_indent.debug( "<tangle %s:", aChunk.fullName )
    if self.debug:
        self.write( "\n%s %s (%d) -- %s %s\n" % ( 
            self.comment_start, aChunk.fullName, aChunk.seq, aChunk.lineNumber, self.comment_end ) )
@| codeBegin
@}

<p>The <span class="code">codeEnd()</span> method ends emitting a new chunk of code.
It does this by resetting the Tangler's indent to the previous
setting.</p>

@d Tangler code chunk end
@{
def codeEnd( self, aChunk ):
    self.log_indent.debug( ">%s", aChunk.fullName )
@| codeEnd
@}

<h4>TanglerMake subclass of Tangler</h4>

<h5>Usage</h5>
<p>The <span class="code">TanglerMake</span> class is can tangle source files.  An
instance of <span class="code">TanglerMake</span> is given to the <span class="code">Web</span> class <span class="code">tangle()</span> method.
<pre>
w= Web( "someFile.w" )
WebReader().web(w).load()
t= TanglerMake()
w.tangle( t )
</pre>

<h5>Design</h5>
<p>The <span class="code">TanglerMake</span> subclass makes the <span class="code">Tangler</span> used to <em>tangle</em> the various
program source files more make-friendly.  This subclass of <span class="code">Tangler</span> 
does not <i>touch</i> an output file
where there is no change.  This is helpful when <em>pyWeb</em>'s output is
sent to <i>make</i>.  Using <span class="code">TanglerMake</span> assures that only files with real changes
are rewritten, minimizing recompilation of an application for changes to
the associated documentation.
</p>

<h5>Implementation</h5>
<p>This subclass of <span class="code">Tangler</span> changes how files
are opened and closed.</p>

@d Imports
@{import tempfile
import filecmp
@| tempfile filecmp
@}

@d Tangler subclass which is make-sensitive...
@{
class TanglerMake( Tangler ):
    """Tangle output files, leaving files untouched if there are no changes."""
    def __init__( self ):
        Tangler.__init__( self )
        self.tempname= None
    @<TanglerMake doOpen override, using a temporary file@>
    @<TanglerMake doClose override, comparing temporary to original@>
@| TanglerMake 
@}

<p>A <span class="code">TanglerMake</span> creates a temporary file to collect the
tangled output.  When this file is completed, we can compare
it with the original file in this directory, avoiding
a "touch" if the new file is the same as the original.
</p>

@d TanglerMake doOpen...
@{
def doOpen( self, aFile ):
    self.tempname= tempfile.mktemp()
    self.theFile= open( self.tempname, "w" )
    logger.info( "Tangling %r", aFile )
@| doOpen
@}

<p>If there is a previous file: compare the temporary file and the previous file.  
If there was  previous file or the files are different: rename temporary to replace previous;
else: unlink temporary and discard it.  This preserves the original (with the original date
and time) if nothing has changed.
</p>

@d TanglerMake doClose...
@{
def doClose( self ):
    self.theFile.close()
    try:
        same= filecmp.cmp( self.tempname, self.fileName )
    except OSError,e:
        same= 0
    if same:
        logger.info( "No change to %r", self.fileName )
        os.remove( self.tempname )
    else:
        # note the Windows requires the original file name be removed first
        try: 
            os.remove( self.fileName )
        except OSError,e:
            pass
        os.rename( self.tempname, self.fileName )
        logger.info( "Wrote %d lines to %r",
            self.linesWritten, self.fileName )
@| doClose
@}

<h3>Chunks</h3>

<p>A <span class="code">Chunk</span> is a piece of the input file.  It is a collection of <span class="code">Command</span> instances.
A chunk can be woven or tangled to create output.</p>
<p>The two most important methods are the <span class="code">weave()</span> and <span class="code">tangle()</span> methods.  These
visit the commands of this chunk, producing the required output file.
</p>
<p>Additional methods (<span class="code">startswith()</span>, <span class="code">searchForRE()</span> and <span class="code">usedBy()</span>)
 are used to examine the text of the <span class="code">Command</span> instances within
the chunk.</p>
<p>A <span class="code">Chunk</span> instance is created by the <span class="code">WebReader</span> as the input file is parsed.
Each <span class="code">Chunk</span> instance has one or more pieces of the original input text.  This text can be program source,
a reference command, or the documentation source.
</p>

@d Chunk class hierarchy...
@{
@<Chunk class@>
@<NamedChunk class@>
@<OutputChunk class@>
@<NamedDocumentChunk class@>
@}

<p>The <span class="code">Chunk</span> class is both the superclass for this hierarchy and the implementation 
for anonymous chunks.  An anonymous chunk is always documentation in the 
target markup language.  No transformation is ever done on anonymous chunks.
</p>
<p>A <span class="code">NamedChunk</span> is a chunk created with a <tt>@@d</tt> command.  
This is a chunk of source programming language, bracketed with <tt>@@{</tt> and <tt>@@}</tt>.
</p>
<p>An <span class="code">OutputChunk</span> is a named chunk created with a <tt>@@o</tt> command.  
This must be a chunk of source programming language, bracketed with <tt>@@{</tt> and <tt>@@}</tt>.
</p>
<p>A <span class="code">NamedDocumentChunk</span> is a named chunk created with a <tt>@@d</tt> command.  
This is a chunk of documentation in the target markup language,
 bracketed with <tt>@@[</tt> and <tt>@@]</tt>.
</p>

<h4>Chunk Superclass</h4>

<h5>Usage</h5>
<p>An instance of the <span class="code">Chunk</span> class has a life that includes four important events:
creation, cross-reference, weave and tangle.</p>
<p>A <span class="code">Chunk</span> is created by a <span class="code">WebReader</span>, and associated with a <span class="code">Web</span>.
There are several web append methods, depending on the exact subclass of <span class="code">Chunk</span>.
The <span class="code">WebReader</span> calls the chunk's <span class="code">webAdd()</span> method select the correct method
for appending and indexing the chunk.
Individual instances of <span class="code">Command</span> are appended to the chunk.
The basic outline for creating a <span class="code">Chunk</span> instance is as follows:</p>
<pre>
w= Web( "someFile.w" )
c= Chunk()
c.webAdd( w )
c.append( ...some Command... )
c.append( ...some Command... )
</pre>
<p>Before weaving or tangling, a cross reference is created for all
user identifiers in all of the <span class="code">Chunk</span> instances.
This is done by: (1) visit each <span class="code">Chunk</span> and call the 
<span class="code">getUserIDRefs()</span> method to gather all identifiers; (2) for each identifier, 
visit each <span class="code">Chunk</span> and call the <span class="code">searchForRE()</span> method to find uses of
the identifier.</p>
<pre>
ident= []
for c in <i>the Web's named chunk list</i>:
    ident.extend( c.getUserIDRefs() )
for i in ident:
    pattern= re.compile('\W%s\W' % i)
    for c in <i>the Web's named chunk list</i>:
        c.searchForRE( pattern )
</pre>
<p>A <span class="code">Chunk</span> is woven or tangled by the <span class="code">Web</span>.  The basic outline for weaving is
as follows.  The tangling action is essentially the same.</p>
<pre>
for c in <i>the Web's chunk list</i>:
    c.weave( aWeaver )
</pre>

<h5>Design</h5>
<p>The <span class="code">Chunk</span> class contains the overall definitions for all of the
various specialized subclasses.  In particular, it contains the <span class="code">append()</span>,
and <span class="code">appendText()</span> methods used by all of the various <span class="code">Chunk</span> subclasses.
</p>

<p>When a <tt>@@@@</tt> construct is located in the input stream, the stream contains
three text tokens: material before the <tt>@@@@</tt>, the <tt>@@@@</tt>, 
and the material after the <tt>@@@@</tt>.
These three tokens are reassembled into a single block of text.  This reassembly
is accomplished by changing the chunk's state so that the next <span class="code">TextCommand</span> is
appended onto the previous <span class="code">TextCommand</span>.
</p>

<p>The <span class="code">appendText()</span> method either:</p>
<ul>
<li>appends to a previous <span class="code">TextCommand</span>  instance,</li>
<li>or finds that there are not commands at all, and creates a <span class="code">TextCommand</span> instance,</li>
<li>or finds that the last Command isn't a subclass of <span class="code">TextCommand</span>and creates a <span class="code">TextCommand</span> instance.</li>
</ul>

<p>Each subclass of <span class="code">Chunk</span> has a particular type of text that it will process.  Anonymous chunks
only handle document text.  The <span class="code">NamedChunk</span> subclass that handles program source
will override this method to create a different command type.  The <span class="code">makeContent()</span> method
creates the appropriate <span class="code">Command</span> instance for this <span class="code">Chunk</span> subclass.
</p>

<p>The <span class="code">weave()</span> method of an anonymous <span class="code">Chunk</span> uses the weaver's 
<span class="code">docBegin()</span> and <span class="code">docEnd()</span>
methods to insert text that is source markup.  Other subclasses will override this to 
use different <span class="code">Weaver</span> methods for different kinds of text.
</p>

<p>A Chunk has a <span class="code">Strategy</span> object which is a subclass of Reference.  This is
either an instance of SimpleReference or TransitiveReference.  
A SimpleRerence does no additional processing, and locates the proximate reference to 
this chunk.  The TransitiveReference walks "up" the web toward top-level file
definitions that reference this Chunk.
</p>

<h5>Implementation</h5>

<p>The <span class="code">Chunk</span> constructor initializes the following instance variables:</p>
<ul>
<li><i>commands</i> is a sequence of the various <span class="code">Command</span> instances the comprise this
chunk.</li>
<li><i>user_id_list</i> is used the list of user identifiers associated with
this chunk.  This attribute is always <span class="code">None</span> for this class.
The <span class="code">NamedChunk</span> subclass, however, can have user identifiers.</li>
<li><i>initial</i> is True if this is the first
definition (display with <tt>'='</tt>) or a subsequent definition (display with <tt>'+='</tt>).
</li>
<li><i>name</i> has the name of the chunk.  This is '' for anonymous chunks.</li>
<li><i>seq</i> has the sequence number associated with this chunk.  This is None
for anonymous chunks.</li>
<li><i>referencedBy</i> is the list of Chunks which reference this chunk.</li>
<li><i>references</i> is the list of Chunks this chunk references.</li>
</ul>

<blockquote class="note">
<p>These variables are deprecated.</p>
<ul>
<li><i>_lastCommand</i> is used to force a character to be appended to the last
command (which must be a <span class="code">Textcommand</span> instance) instead of appending a new command.
This needs to be removed.  If each Command has trailing text, then this
isn't necessary.</li>
</ul>
</blockquote>

@d Chunk class
@{
class Chunk( object ):
    """Anonymous piece of input file: will be output through the weaver only."""
    # construction and insertion into the web
    def __init__( self ):
        self.commands= [ ] # The list of children of this chunk
        self.user_id_list= None
        self.initial= None
        self.name= ''
        self.fullName= None
        self.seq= None
        self.referencedBy= [] # Chunks which reference this chunk.  Ideally just one.
        self.references= [] # Names that this chunk references
        
        self.reference_style= None # Instance of Reference 
        
        self._lastCommand= None
    def __str__( self ):
        return "\n".join( map( str, self.commands ) )
    def __repr__( self ):
        return "%s('%s')" % ( self.__class__.__name__, self.name )
    @<Chunk append a command@>
    @<Chunk append text@>
    @<Chunk add to the web@>
    @<Chunk generate references from this Chunk@>
    @<Chunk superclass make Content definition@>
    @<Chunk examination: starts with, matches pattern@>
    @<Chunk references to this Chunk@>
    @<Chunk weave this Chunk into the documentation@>
    @<Chunk tangle this Chunk into a code file@>
@| Chunk makeContent
@}

<p>The <span class="code">append()</span> method simply appends a <span class="code">Command</span> instance to this chunk.</p>

@d Chunk append a command
@{
def append( self, command ):
    """Add another Command to this chunk."""
    self.commands.append( command )
    command.chunk= self
@| append
@}


<p>The <span class="code">appendText()</span> method appends a <span class="code">TextCommand</span> to this chunk,
or it concatenates it to the most recent <span class="code">TextCommand</span>.  
</p>

<p>When an <tt>@@@@</tt> construct is located, the <span class="code">appendText()</span> method is
used to accumulate this character.  This means that it will be appended to 
any previous TextCommand, or  new TextCommand will be built.
</p>

<p>The reason for appending is that a TextCommand has an implicit indentation.  The "@@" cannot
be a separate TextCommand because it will wind up indented.
</p>

@d Chunk append text
@{
def appendText( self, text, lineNumber=0 ):
    """Append a single character to the most recent TextCommand."""
    try:
        # Works for TextCommand, otherwise breaks
        self.commands[-1].text += text
    except IndexError, e:
        # First command?  Then the list will have been empty.
        self.commands.append( self.makeContent(text,lineNumber) )
    except AttributeError, e:
        # Not a TextCommand?  Then there won't be a text attribute.
        self.commands.append( self.makeContent(text,lineNumber) )
    self._lastCommand= self.commands[-1]
@| appendText
@}

<p>The <span class="code">webAdd()</span> method adds this chunk to the given document web.
Each subclass of the <span class="code">Chunk</span> class must override this to be sure that the various
<span class="code">Chunk</span> subclasses are indexed properly.  The
<span class="code">Chunk</span> class uses the <span class="code">add()</span> method
of the <span class="code">Web</span> class to append an anonymous, unindexed chunk.
</p>

@d Chunk add to the web
@{
def webAdd( self, web ):
    """Add self to a Web as anonymous chunk."""
    web.add( self )
@| webAdd
@}

<p>This superclass creates a specific Command for a given piece of content.
A subclass can override this to change the underlying assumptions of that Chunk.
The generic chunk doesn't contain code, it contains text and can only be woven,
never tangled.  A Named Chunk using <tt>@@{</tt> and <tt>@@}</tt> creates code.
A Named Chunk using <tt>@@[</tt> and <tt>@@[</tt> creates text.
</p>

@d Chunk superclass make Content...
@{
def makeContent( self, text, lineNumber=0 ):
    return TextCommand( text, lineNumber )
@| makeContent
@}

<p>The <span class="code">startsWith()</span> method examines a the first <span class="code">Command</span> instance this
<span class="code">Chunk</span> instance to see if it starts
with the given prefix string.
</p>
<p>The <span class="code">lineNumber()</span> method returns the line number of the first
<span class="code">Command</span> in this chunk.  This provides some context for where the chunk
occurs in the original input file.
</p>
<p>A <span class="code">NamedChunk</span> instance may define one or more identifiers.  This parent class
provides a dummy version of the <span class="code">getUserIDRefs</span> method.  The <span class="code">NamedChunk</span>
subclass overrides this to provide actual results.  By providing this
at the superclass level, the <span class="code">Web</span> can easily gather identifiers without
knowing the actual subclass of <span class="code">Chunk</span>.
</p>
<p>The <span class="code">searchForRE()</span> method examines each <span class="code">Command</span> instance to see if it matches
with the given regular expression.  If so, this can be reported to the Web instance
and accumulated as part of a cross reference for this <span class="code">Chunk</span>.
</p>

@d Chunk examination...
@{
def startswith( self, prefix ):
    """Examine the first command's starting text."""
    return len(self.commands) >= 1 and self.commands[0].startswith( prefix )
def searchForRE( self, rePat ):
    """Visit each command, applying the pattern."""
    @<Chunk search for user identifiers in each child command@>
@@property
def lineNumber( self ):
    """Return the first command's line number or None."""
    return self.commands[0].lineNumber if len(self.commands) >= 1 else None
def getUserIDRefs( self ):
    return []
@| startswith searchForRE lineNumber getUserIDRefs
@}

<p>The chunk search in the <span class="code">searchForRE()</span> method parallels weaving and tangling a <span class="code">Chunk</span>.
The operation is delegated to each <span class="code">Command</span> instance within the <span class="code">Chunk</span> instance.
</p>

@d Chunk search for user identifiers...
@{
for c in self.commands:
    if c.searchForRE( rePat ):
        return self
return None
@}

<p>The <span class="code">genReferences()</span> method visits each <span class="code">Command</span> instance inside this chunk;
a <span class="code">Command</span> will yield the references.  
</p>
<p>Note that an exception may be raised by this operation if a referenced
<span class="code">Chunk</span> does not actually exist.  If a reference <span class="code">Command</span> does raise an error, 
we append this <span class="code">Chunk</span> information and reraise the error with the additional 
context information.
</p>

@d Chunk generate references...
@{
def genReferences( self, aWeb ):
    """Generate references from this Chunk."""
    try:
        for t in self.commands:
            ref= t.ref( aWeb )
            if ref is not None:
                yield ref
    except Error,e:
        raise Error,e.args+(self,)
@| genReferences
@}

<p>The list of references to a Chunk uses a <span class="code">Strategy</span> plug-in
to either generate a simple parent or a transitive closure of all parents.
</p>

@d Chunk references...
@{
@@property
def references_list( self ):
    """This should return chunks themselves, not (name,seq) pairs."""
    return self.reference_style.chunkReferencedBy( self )
@}

<p>The <span class="code">weave()</span> method weaves this chunk into the final document as follows:</p>
<ol>
<li>call
the <span class="code">Weaver</span> class <span class="code">docBegin()</span> method.  This method does nothing for document content.</li>
<li>visit each <span class="code">Command</span> instance: call the <span class="code">Command</span> instance <span class="code">weave()</span> method to 
emit the content of the <span class="code">Command</span> instance</li>
<li>call the <span class="code">Weaver</span> class <span class="code">docEnd()</span> method.  This method does nothing for document content.</li>
</ol>
<p>Note that an exception may be raised by this action if a referenced
<span class="code">Chunk</span> does not actually exist.  If a reference <span class="code">Command</span> does raise an error, 
we append this <span class="code">Chunk</span> information and reraise the error with the additional 
context information.
</p>

@d Chunk weave...
@{
def weave( self, aWeb, aWeaver ):
    """Create the nicely formatted document from an anonymous chunk."""
    aWeaver.docBegin( self )
    try:
        for t in self.commands:
            t.weave( aWeb, aWeaver )
    except Error, e:
        raise Error,e.args+(self,)
    aWeaver.docEnd( self )
def weaveReferenceTo( self, aWeb, aWeaver ):
    """Create a reference to this chunk -- except for anonymous chunks."""
    raise Exception( "Cannot reference an anonymous chunk.""")
def weaveShortReferenceTo( self, aWeb, aWeaver ):
    """Create a short reference to this chunk -- except for anonymous chunks."""
    raise Exception( "Cannot reference an anonymous chunk.""")
@| weave weaveReferenceTo weaveShortReferenceTo
@}

<p>Anonymous chunks cannot be tangled.  Any attempt indicates a serious
problem with this program or the input file.</p>

@d Chunk tangle...
@{
def tangle( self, aWeb, aTangler ):
    """Create source code -- except anonymous chunks should not be tangled"""
    raise Error( 'Cannot tangle an anonymous chunk', self )
@| tangle
@}

<h4>NamedChunk class</h4>

<h5>Usage</h5>
<p>A <span class="code">NamedChunk</span> is created and used almost identically to an anonymous <span class="code">Chunk</span>.
The most significant difference is that a name is provided when the <span class="code">NamedChunk</span> is created.
This name is used by the <span class="code">Web</span> to organize the chunks.
</p>

<h5>Design</h5>

<p>A <span class="code">NamedChunk</span> is created with a <tt>@@d</tt> or <tt>@@o</tt> command.  
A <span class="code">NamedChunk</span> contains programming language source
 when the brackets are <tt>@@{</tt> and <tt>@@}</tt>.  A
separate subclass of <span class="code">NamedDocumentChunk</span> is used when
the brackets are <tt>@@[</tt> and <tt>@@]</tt>.
</p>
<p>A <span class="code">NamedChunk</span> can be both tangled into the output program files, and
woven into the output document file. 
</p>
<p>The <span class="code">weave()</span> method of a <span class="code">NamedChunk</span> uses the Weaver's 
<span class="code">codeBegin()</span> and <span class="code">codeEnd()</span>
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses can override this to 
use different <span class="code">Weaver</span> methods for different kinds of text.
</p>

<h5>Implementation</h5>

<p>This class introduces some additional attributes.</p>
<ul>
<li><i>fullName</i> is the full name of the chunk.  It's possible for a 
chunk to be an abbreviated forward reference; full names cannot be resolved
until all chunks have been seen.</li>
<li><i>user_id_list</i> is the list of user identifiers associated with this chunk.</li>
<li><i>refCount</i> is the count of references to this chunk.  If this is
zero, the chunk is unused; if this is more than one, this chunk is 
multiply used.  Either of these conditions is a possible error in the input. 
This is set by the <span class="code">usedBy()</span> method.</li>
<li><i>name</i> has the name of the chunk.  Names can be abbreviated.</li>
<li><i>seq</i> has the sequence number associated with this chunk.  This
is set by the Web by the <span class="code">webAdd()</span> method.</li>
</ul>

@d NamedChunk class
@{
class NamedChunk( Chunk ):
    """Named piece of input file: will be output as both tangler and weaver."""
    def __init__( self, name ):
        Chunk.__init__( self )
        self.name= name
        self.user_id_list= []
        self.refCount= 0
    def __str__( self ):
        return "%r: %s" % ( self.name, Chunk.__str__(self) )
    def makeContent( self, text, lineNumber=0 ):
        return CodeCommand( text, lineNumber )
    @<NamedChunk user identifiers set and get@>
    @<NamedChunk add to the web@>
    @<NamedChunk weave@>
    @<NamedChunk tangle into the source file@>
@| NamedChunk makeContent
@}

<p>The <span class="code">setUserIDRefs()</span> method accepts a list of user identifiers that are
associated with this chunk.  These are provided after the <tt>@@|</tt> separator
in a <tt>@@d</tt> named chunk.  These are used by the <tt>@@u</tt> cross reference generator.
</p>

@d NamedChunk user identifiers...
@{
def setUserIDRefs( self, text ):
    """Save user ID's associated with this chunk."""
    self.user_id_list= text.split()
def getUserIDRefs( self ):
    return self.user_id_list
@| setUserIDRefs getUserIDRefs
@}

<p>The <span class="code">webAdd()</span> method adds this chunk to the given document <span class="code">Web</span> instance.
Each class of <span class="code">Chunk</span> must override this to be sure that the various
<span class="code">Chunk</span> classes are indexed properly.  This class uses the <span class="code">addNamed()</span> method
of the <span class="code">Web</span> class to append a named chunk.
</p>

@d NamedChunk add to the web
@{
def webAdd( self, web ):
    """Add self to a Web as named chunk, update xrefs."""
    web.addNamed( self )
@| webAdd
@}

<p>The <span class="code">weave()</span> method weaves this chunk into the final document as follows:</p>
<ol>
<li>call
the <span class="code">Weaver</span> class <span class="code">codeBegin()</span> method.  This method emits the necessary markup
for code appearing in the woven output.</li>
<li>visit each <span class="code">Command</span>, calling the command's <span class="code">weave()</span> method to emit the command's content</li>
<li>call the <span class="code">Weaver</span> class <span class="code">CodeEnd()</span> method.  This method emits the necessary markup
for code appearing in the woven output.</li>
</ol>

<p>The <span class="code">weaveRefenceTo()</span> method weaves a reference to a chunk using both name and sequence number.
The <span class="code">weaveShortReferenceTo()</span> method weaves a reference to a chunk using only the sequence number.
These references are created by <span class="code">ReferenceCommand</span> instances within a chunk being woven.
</p>
<p>If a <span class="code">ReferenceCommand</span> does raise an error during weaving,
we append this <span class="code">Chunk</span> information and reraise the error with the additional 
context information.
</p>

@d NamedChunk weave
@{
def weave( self, aWeb, aWeaver ):
    """Create the nicely formatted document from a chunk of code."""
    # format as <pre> in a different-colored box
    self.fullName= aWeb.fullNameFor( self.name )
    aWeaver.codeBegin( self )
    aWeaver.setIndent( aWeaver.code_indent )
    for t in self.commands:
        try:
            t.weave( aWeb, aWeaver )
        except Error,e:
            raise Error,e.args+(self,)
    aWeaver.clrIndent( )
    aWeaver.codeEnd( self )
def weaveReferenceTo( self, aWeb, aWeaver ):
    """Create a reference to this chunk."""
    self.fullName= aWeb.fullNameFor( self.name )
    txt= aWeaver.referenceTo( self.fullName, self.seq )
    aWeaver.codeBlock( txt )
def weaveShortReferenceTo( self, aWeb, aWeaver ):
    """Create a shortened reference to this chunk."""
    txt= aWeaver.referenceTo( None, self.seq )
    aWeaver.codeBlock( txt )
@| weave weaveReferenceTo weaveShortReferenceTo
@}

<p>The <small>tangle()</small> method tangles this chunk into the final document as follows:</p>
<ol>
<li>call the <span class="code">Tangler</span> class <span class="code">codeBegin()</span> method to set indents properly.</li>
<li>visit each Command, calling the Command's <span class="code">tangle()</span> method to emit the Command's content</li>
<li>call the <span class="code">Tangler</span> class <span class="code">codeEnd()</span> method to restore indents.</li>
</ol>
<p>If a <span class="code">ReferenceCommand</span> does raise an error during tangling,
we append this Chunk information and reraise the error with the additional 
context information.
</p>

@d NamedChunk tangle...
@{
def tangle( self, aWeb, aTangler ):
    """Create source code."""
    # use aWeb to resolve @@<namedChunk@@>
    # format as correctly indented source text
    self.previous_command= TextCommand( "", self.commands[0].lineNumber )
    aTangler.codeBegin( self )
    for t in self.commands:
        try:
            t.tangle( aWeb, aTangler )
        except Error,e:
            raise Error,e.args+(self,)
        self.previous_command= t
    aTangler.codeEnd( self )
@| tangle
@}

<h4>OutputChunk class</h4>
<h5>Usage</h5>
<p>A <span class="code">OutputChunk</span> is created and used identically to a <span class="code">NamedChunk</span>.
The difference between this class and the parent class is the decoration of 
the markup when weaving.
</p>

<h5>Design</h5>

<p>The <span class="code">OutputChunk</span> class is a subclass of <span class="code">NamedChunk</span> that handles 
file output chunks defined with <tt>@@o</tt>. 
</p>
<p>The <span class="code">weave()</span> method of a <span class="code">OutputChunk</span> uses the Weaver's 
<span class="code">fileBegin()</span> and <span class="code">fileEnd()</span>
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses could override this to 
use different <span class="code">Weaver</span> methods for different kinds of text.
</p>
<p>All other methods, including the tangle method are identical to <span class="code">NamedChunk</span>.</p>

<h5>Implementation</h5>

@d OutputChunk class
@{
class OutputChunk( NamedChunk ):
    """Named piece of input file, defines an output tangle."""
    def __init__( self, name, comment_start="", comment_end="" ):
        super( OutputChunk, self ).__init__( name )
        self.comment_start= comment_start
        self.comment_end= comment_end
    @<OutputChunk add to the web@>
    @<OutputChunk weave@>
    @<OutputChunk tangle@>
@| OutputChunk 
@}

<p>The <span class="code">webAdd()</span> method adds this chunk to the given document <span class="code">Web</span>.
Each class of <span class="code">Chunk</span> must override this to be sure that the various
<span class="code">Chunk</span> classes are indexed properly.  This class uses the <span class="code">addOutput()</span> method
of the <span class="code">Web</span> class to append a file output chunk.
</p>

@d OutputChunk add to the web
@{
def webAdd( self, web ):
    """Add self to a Web as output chunk, update xrefs."""
    web.addOutput( self )
@| webAdd
@}

<p>The <span class="code">weave()</span> method weaves this chunk into the final document as follows:</p>
<ol>
<li>call the <span class="code">Weaver</span> class <span class="code">codeBegin()</span> method to emit proper markup for an output file chunk.</li>
<li>visit each <span class="code">Command</span>, call the Command's <span class="code">weave()</span> method to emit the Command's content</li>
<li>call the <span class="code">Weaver</span> class <span class="code">codeEnd()</span> method to emit proper markup for an output file chunk.</li>
</ol>
<p>These chunks of documentation are never tangled.  Any attempt is an
error.</p>
<p>If a <span class="code">ReferenceCommand</span> does raise an error during weaving,
we append this <span class="code">Chunk</span> information and reraise the error with the additional 
context information.
</p>

@d OutputChunk weave
@{
def weave( self, aWeb, aWeaver ):
    """Create the nicely formatted document from a chunk of code."""
    # format as <pre> in a different-colored box
    self.fullName= aWeb.fullNameFor( self.name )
    aWeaver.fileBegin( self )
    try:
        for t in self.commands:
            t.weave( aWeb, aWeaver )
    except Error,e:
        raise Error,e.args+(self,)
    aWeaver.fileEnd( self )
@| weave
@}

@d OutputChunk tangle
@{
def tangle( self, aWeb, aTangler ):
    aTangler.comment_start= self.comment_start
    aTangler.comment_end= self.comment_end
    super( OutputChunk, self ).tangle( aWeb, aTangler )
@}
<h4>NamedDocumentChunk class</h4>
<h5>Usage</h5>
<p>A <span class="code">NamedDocumentChunk</span> is created and used identically to a <span class="code">NamedChunk</span>.
The difference between this class and the parent class is that this chunk
is only woven when referenced.  The original definition is silently skipped.
</p>

<h5>Design</h5>

<p>The <span class="code">NamedDocumentChunk</span> class is a subclass of <span class="code">NamedChunk</span> that handles 
named chunks defined with <tt>@@d</tt> and the <tt>@@[</tt>...<tt>@@]</tt> delimiters.  
These are woven slightly
differently, since they are document source, not programming language source.
</p>
<p>We're not as interested in the cross reference of named document chunks.
They can be used multiple times or never.  They are often referenced
by anonymous chunks.  While this chunk subclass participates in this data 
gathering, it is ignored for reporting purposes.</p>
<p>All other methods, including the tangle method are identical to <span class="code">NamedChunk</span>.</p>

<h5>Implementation</h5>

@d NamedDocumentChunk class
@{
class NamedDocumentChunk( NamedChunk ):
    """Named piece of input file with document source, defines an output tangle."""
    def makeContent( self, text, lineNumber=0 ):
        return TextCommand( text, lineNumber )
    @<NamedDocumentChunk weave@>
    @<NamedDocumentChunk tangle@>
@| NamedDocumentChunk makeContent
@}

<p>The <span class="code">weave()</span> method quietly ignores this chunk in the document.
A named document chunk is only included when it is referenced 
during weaving of another chunk (usually an anonymous document
chunk).
</p>
<p>The <span class="code">weaveReferenceTo()</span> method inserts the content of this
chunk into the output document.  This is done in response to a
<span class="code">ReferenceCommand</span> in another chunk.  
The <span class="code">weaveShortReferenceTo()</span> method calls the <span class="code">weaveReferenceTo()</span>
to insert the entire chunk.
</p>

@d NamedDocumentChunk weave
@{
def weave( self, aWeb, aWeaver ):
    """Ignore this when producing the document."""
    pass
def weaveReferenceTo( self, aWeb, aWeaver ):
    """On a reference to this chunk, expand the body in place."""
    try:
        for t in self.commands:
            t.weave( aWeb, aWeaver )
    except Error,e:
        raise Error,e.args+(self,)
def weaveShortReferenceTo( self, aWeb, aWeaver ):
    """On a reference to this chunk, expand the body in place."""
    self.weaveReferenceTo( aWeb, aWeaver )
@| weave weaveReferenceTo weaveShortReferenceTo
@}

@d NamedDocumentChunk tangle
@{
def tangle( self, aWeb, aTangler ):
    """Raise an exception on an attempt to tangle."""
    raise Error( "Cannot tangle a chunk defined with @@[.""" )
@| tangle
@}

<h3>Commands</h3>

<p>The input stream is broken into individual commands, based on the
various <tt>@@<i>x</i></tt> strings in the file.  There are several subclasses of <span class="code">Command</span>,
each used to describe a different command or block of text in the input.
</p>

<p>All instances of the <span class="code">Command</span> class are created by a <span class="code">WebReader</span> instance.  
In this case, a <span class="code">WebReader</span> can be thought of as a factory for <span class="code">Command</span> instances.
Each <span class="code">Command</span> instance is appended to the sequence of commands that
belong to a <span class="code">Chunk</span>.  A chunk may be as small as a single command, or a long sequence
of commands.</p>

<p>Each command instance responds to methods to examine the content, gather 
cross reference information and tangle a file or weave the final document.
</p>

@d Command class hierarchy...
@{
@<Command superclass@>
@<TextCommand class to contain a document text block@>
@<CodeCommand class to contain a program source code block@>
@<XrefCommand superclass for all cross-reference commands@>
@<FileXrefCommand class for an output file cross-reference@>
@<MacroXrefCommand class for a named chunk cross-reference@>
@<UserIdXrefCommand class for a user identifier cross-reference@>
@<ReferenceCommand class for chunk references@>
@}

<h4>Command Superclass</h4>

<h5>Usage</h5>
<p>A <span class="code">Command</span> is created by the <span class="code">WebReader</span>, and attached to a <span class="code">Chunk</span>.
The Command participates in cross reference creation, weaving and tangling.
</p>
<p>The <span class="code">Command</span> superclass is abstract, and has default methods factored out
of the various subclasses.  When a subclass is created, it will override some
of the methods provided in this superclass.
</p>
<pre>
class MyNewCommand( Command ):
    ... overrides for various methods ...
</pre>
<p>Additionally, a subclass of <span class="code">WebReader</span> must be defined to parse the new command
syntax.  The main <span class="code">process()</span> function must also be updated to use this new subclass
of <span class="code">WebReader</span>.</p>

<h5>Design</h5>

<p>The <span class="code">Command</span> superclass provides the parent class definition
for all of the various command types.  The most common command
is a block of text, which is woven or tangled.  The next most
common command is a reference to a chunk, which is woven as a 
mark-up reference, but tangled as an expansion of the source 
code.
</p>

<ul>
<li>The <span class="code">startswith()</span> method examines any source text to see if
it begins with the given prefix text.</li>
<li>The <span class="code">searchForRE()</span> method examines any source text to see if
it matches the given regular expression, usually a match for a user identifier.</li>
<li>The <span class="code">ref()</span> method is ignored by all but the <span class="code">Reference</span> subclass,
which returns reference made by the command to the parent chunk.</li>
<li>The <span class="code">weave()</span> method weaves this into the output.  If a document text
command, it is emitted directly; if a program source code command, 
markup is applied.  In the case of cross-reference commands,
the actual cross-reference content is emitted.  In the case of 
reference commands, they are woven as a reference to a named
chunk.</li>
<li>The <span class="code">tangle()</span> method tangles this into the output.  If a
this is a document text command, it is ignored; if a this is a
program source code
command, it is indented and emitted.  In the case of cross-reference
commands, no output is produced.  In the case of reference
commands, the named chunk is indented and emitted.</li>
</ul>
<p>The attributes of a <span class="code">Command</span> instance includes the line number on which
the command began, in <i>lineNumber</i>.</p>

<h5>Implementation</h5>

@d Command superclass
@{
class Command( object ):
    """A Command is the lowest level of granularity in the input stream."""
    def __init__( self, fromLine=0 ):
        self.lineNumber= fromLine
        self.chunk= None
    def __str__( self ):
        return "at %r" % self.lineNumber
    @<Command analysis features: starts-with and Regular Expression search@>
    @<Command tangle and weave functions@>
@| Command
@}

@d Command analysis features...
@{
def startswith( self, prefix ):
    return None
def searchForRE( self, rePat ):
    return None
def indent( self ):
    return None
@| startswith searchForRE
@}

@d Command tangle and weave...
@{
def ref( self, aWeb ):
    return None
def weave( self, aWeb, aWeaver ):
    pass
def tangle( self, aWeb, aTangler ):
    pass
@| ref weave tangle
@}

<h4>TextCommand class</h4>
<h5>Usage</h5>

<p>A <span class="code">TextCommand</span> is created by a <span class="code">Chunk</span> or a <span class="code">NamedDocumentChunk</span> when a 
<span class="code">WebReader</span> calls the chunk's <span class="code">appendText()</span> method.
This Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 
</p>

<h5>Design</h5>
<p>An instance of the <span class="code">TextCommand</span> class is a block of document text.  It can originate
in an anonymous block or a named chunk delimited with <tt>@@[</tt> and <tt>@@]</tt>.
</p>
<p>This subclass provides a concrete implementation for all of the methods.  Since
text is the author's original markup language, it is emitted directly to the weaver
or tangler.
</p>

<h5>Implementation</h5>


@d TextCommand class...
@{
class TextCommand( Command ):
    """A piece of document source text."""
    def __init__( self, text, fromLine=0 ):
        super( TextCommand, self ).__init__( fromLine )
        self.text= text
    def __str__( self ):
        return "at %r: %r..." % (self.lineNumber,self.text[:32])
    def startswith( self, prefix ):
        return self.text.startswith( prefix )
    def searchForRE( self, rePat ):
        return rePat.search( self.text )
    def indent( self ):
        if self.text.endswith('\n'):
            return 0
        try:
            last_line = self.text.splitlines()[-1]
            return len(last_line)
        except IndexError:
            return 0
    def weave( self, aWeb, aWeaver ):
        aWeaver.write( self.text )
    def tangle( self, aWeb, aTangler ):
        aTangler.write( self.text )
@| TextCommand startswith searchForRE weave tangle
@}

<h4>CodeCommand class</h4>
<h5>Usage</h5>
<p>A <span class="code">CodeCommand</span> is created by a <span class="code">NamedChunk</span> when a 
<span class="code">WebReader</span> calls the <span class="code">appendText()</span> method.
The Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 
</p>
<h5>Design</h5>
<p>An instance of the <span class="code">CodeCommand</span> class is a block of program source code text.
It can originate in a named chunk (<tt>@@d</tt>) with a <tt>@@{</tt> and <tt>@@}</tt> delimiter.
Or it can be a file output chunk (<tt>@@o</tt>).
</p>
<p>It uses the <span class="code">codeBlock()</span> methods of a <span class="code">Weaver</span> or <span class="code">Tangler</span>.  The weaver will 
insert appropriate markup for this code.  The tangler will assure that the prevailing
indentation is maintained.
<h5>Implementation</h5>

@d CodeCommand class...
@{
class CodeCommand( TextCommand ):
    """A piece of program source code."""
    def weave( self, aWeb, aWeaver ):
        aWeaver.codeBlock( aWeaver.quote( self.text ) )
    def tangle( self, aWeb, aTangler ):
        aTangler.codeBlock( self.text )
@| CodeCommand weave tangle
@}

<h4>XrefCommand superclass</h4>
<h5>Usage</h5>
<p>An <span class="code">XrefCommand</span> is created by the <span class="code">WebReader</span> when any of the 
<tt>@@f</tt>, <tt>@@m</tt>, <tt>@@u</tt> commands are found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.
</p>

<h5>Design</h5>
<p>The <span class="code">XrefCommand</span> superclass defines any common features of the
various cross-reference commands (<tt>@@f</tt>, <tt>@@m</tt>, <tt>@@u</tt>).
</p>
<p>The <span class="code">formatXref()</span> method creates the body of a cross-reference
by the following algorithm:</p>
<ol>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefHead()</span> method to emit the cross-reference header.</li>
<li>Sort the keys in the cross-reference mapping.</li>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefLine()</span> method to emit each line of the cross-reference mapping.</li>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefFoot()</span> method to emit the cross-reference footer.</li>
</ol>
<p>If this command winds up in a tangle action, that use
is illegal.  An exception is raised and processing stops.
</p>
 
<h5>Implementation</h5>

@d XrefCommand superclass...
@{
class XrefCommand( Command ):
    """Any of the Xref-goes-here commands in the input."""
    def __str__( self ):
        return "at %r: cross reference" % (self.lineNumber)
    def formatXref( self, xref, aWeaver ):
        aWeaver.xrefHead()
        for n in sorted(xref):
            aWeaver.xrefLine( n, xref[n] )
        aWeaver.xrefFoot()
    def tangle( self, aWeb, aTangler ):
        raise Error('Illegal tangling of a cross reference command.')
@| XrefCommand formatXref tangle
@}

<h4>FileXrefCommand class</h4>
<h5>Usage</h5>
<p>A <span class="code">FileXrefCommand</span> is created by the <span class="code">WebReader</span> when the 
<tt>@@f</tt> command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.
</p>
<h5>Design</h5>
<p>The <span class="code">FileXrefCommand</span> class weave method gets the
file cross reference from the overall web instance, and uses
the  <span class="code">formatXref()</span> method of the <span class="code">XrefCommand</span> superclass for format this result.
</p>

<h5>Implementation</h5>

@d FileXrefCommand class...
@{
class FileXrefCommand( XrefCommand ):
    """A FileXref command."""
    def weave( self, aWeb, aWeaver ):
        """Weave a File Xref from @@o commands."""
        self.formatXref( aWeb.fileXref(), aWeaver )
@| FileXrefCommand weave
@}

<h4>MacroXrefCommand class</h4>
<h5>Usage</h5>
<p>A <span class="code">MacroXrefCommand</span> is created by the <span class="code">WebReader</span> when the 
<tt>@@m</tt> command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.
</p>
<h5>Design</h5>

<p>The <span class="code">MacroXrefCommand</span> class weave method gets the
named chunk (macro) cross reference from the overall web instance, and uses
the <span class="code">formatXref()</span> method of the <span class="code">XrefCommand</span> superclass method for format this result.
</p>

<h5>Implementation</h5>

@d MacroXrefCommand class...
@{
class MacroXrefCommand( XrefCommand ):
    """A MacroXref command."""
    def weave( self, aWeb, aWeaver ):
        """Weave the Macro Xref from @@d commands."""
        self.formatXref( aWeb.chunkXref(), aWeaver )
@| MacroXrefCommand weave
@}

<h4>UserIdXrefCommand class</h4>
<h5>Usage</h5>
<p>A <span class="code">MacroXrefCommand</span> is created by the <span class="code">WebReader</span> when the 
<tt>@@u</tt> command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.
</p>
<h5>Design</h5>

<p>The <span class="code">UserIdXrefCommand</span> class weave method gets the
user identifier cross reference information from the 
overall web instance.  It then formats this line using the following 
algorithm, which is similar to the algorithm in the <span class="code">XrefCommand</span> superclass.
</p>
<ol>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefHead()</span> method to emit the cross-reference header.</li>
<li>Sort the keys in the cross-reference mapping.</li>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefDefLine()</span> method to emit each line of the cross-reference definition mapping.</li>
<li>Use the <span class="code">Weaver</span> class <span class="code">xrefFoor()</span> method to emit the cross-reference footer.</li>
</ol>
<h5>Implementation</h5>

@d UserIdXrefCommand class...
@{
class UserIdXrefCommand( XrefCommand ):
    """A UserIdXref command."""
    def weave( self, aWeb, aWeaver ):
        """Weave a user identifier Xref from @@d commands."""
        ux= aWeb.userNamesXref()
        aWeaver.xrefHead()
        for u in sorted(ux):
            defn, refList= ux[u]
            aWeaver.xrefDefLine( u, defn, refList )
        aWeaver.xrefFoot()
@| UserIdXrefCommand weave
@}

<h4>ReferenceCommand class</h4>
<h5>Usage</h5>
<p>A <span class="code">ReferenceCommand</span> instance is created by a <span class="code">WebReader</span> when
 a <tt>@@&lt;<i>name</i>@@&gt;</tt> construct in is found in the input stream.  This is attached
 to the current <span class="code">Chunk</span> being built by the WebReader.  
 </p>

<h5>Design</h5>
<p>During a weave, this creates a markup reference to
another <span class="code">NamedChunk</span>.  During tangle, this actually includes the <span class="code">NamedChunk</span> 
at this point in the tangled output file.
</p>

<p>The constructor creates several attributes of an instance
of a <span class="code">ReferenceCommand</span>.
</p>
<ul>
<li><i>refTo</i>, the name of the chunk to which this refers, possibly 
elided with a trailing <tt>'...'</tt>.</li>
<li><i>fullName</i>, the full name of the chunk to which this refers.</li>
<li><i>chunkList</i>, the list of the chunks to which the name refers.</li>
</ul>

<h5>Implementation</h5>


@d ReferenceCommand class...
@{
class ReferenceCommand( Command ):
    """A reference to a named chunk, via @@<name@@>."""
    def __init__( self, refTo, fromLine=0 ):
        Command.__init__( self, fromLine )
        self.refTo= refTo
        self.fullname= None
        self.sequenceList= None
        self.chunkList= []
    def __str__( self ):
        return "at %r: reference to chunk %r" % (self.lineNumber,self.refTo)
    @<ReferenceCommand resolve a referenced chunk name@>
    @<ReferenceCommand refers to a chunk@>
    @<ReferenceCommand weave a reference to a chunk@>
    @<ReferenceCommand tangle a referenced chunk@>
@| ReferenceCommand 
@}

<p>The <span class="code">resolve()</span> method queries the overall <span class="code">Web</span> instance for the full
name and sequence number for this chunk reference.  This is used
by the <span class="code">Weaver</span> class <span class="code">referenceTo()</span> method to write the markup reference
to the chunk.
</p>

@d ReferenceCommand resolve...
@{
def resolve( self, aWeb ):
    """Expand the referenced chunk name into a full name and list of parts"""
    self.fullName= aWeb.fullNameFor( self.refTo )
    self.chunkList= [ c.seq for c in aWeb.getchunk( self.refTo ) ]
@| resolve
@}

<p>The <span class="code">ref()</span> method is a request that is delegated by a <span class="code">Chunk</span>;
it resolves the reference this Command makes within the containing Chunk.
When the Chunk iterates through the Commands, it can accumulate a list of 
Chinks to which it refers.
</p>

@d ReferenceCommand refers to a chunk
@{
def ref( self, aWeb ):
    """Find and return the full name for this reference."""
    self.resolve( aWeb )
    return self.fullName
@| usedBy
@}

<p>The <span class="code">weave()</span> method inserts a markup reference to a named
chunk.  It uses the <span class="code">Weaver</span> class <span class="code">referenceTo()</span> method to format
this appropriately for the document type being woven.
</p>

@d ReferenceCommand weave...
@{
def weave( self, aWeb, aWeaver ):
    """Create the nicely formatted reference to a chunk of code."""
    self.resolve( aWeb )
    aWeb.weaveChunk( self.fullName, aWeaver )
@| weave
@}

<p>The <span class="code">tangle()</span> method inserts the resolved chunk in this
place.  When a chunk is tangled, it sets the indent,
inserts the chunk and resets the indent.
</p>

@d ReferenceCommand tangle...
@{
def tangle( self, aWeb, aTangler ):
    """Create source code."""
    self.resolve( aWeb )
    # Update indent based on last line of previous command. 
    if self.chunk is None or self.chunk.previous_command is None:
        logger.error( "Command disconnected from Chunk." )
        raise Error( "Serious problem in WebReader." )
    logger.debug( "Indent %s + %r", aTangler.context, self.chunk.previous_command.indent() )
    aTangler.setIndent( command=self.chunk.previous_command )
    aWeb.tangleChunk( self.fullName, aTangler )
    aTangler.clrIndent()
@| tangle
@}

<h3>Error class</h3>
<h4>Usage</h4>
<p>An <span class="code">Error</span> is raised whenever processing cannot continue.  Since it
is a subclass of Exception, it takes an arbitrary number of arguments.  The
first should be the basic message text.  Subsequent arguments provide 
additional details.  We will try to be sure that
all of our internal exceptions reference a specific chunk, if possible.
This means either including the chunk as an argument, or catching the 
exception and appending the current chunk to the exception's arguments.
<p>The
Python <tt>raise</tt> statement takes an instance of Error and passes it
to the enclosing <tt>try/except</tt> statement for processing.</p>
<p>The typical creation is as follows:</p>
<pre>
raise Error("No full name for %r" % chunk.name, chunk)
</pre> 
<p>A typical exception-handling suite might look like this:</p>
<pre>
try:
    ...something that may raise an Error or Exception...
except Error,e:
    print( e.args ) # this is a pyWeb internal Error
except Exception,w:
    print( w.args ) # this is some other Python Exception
</pre>

<h4>Design</h4>

<p>The <span class="code">Error</span> class is a subclass of <span class="code">Exception</span> used to differentiate 
application-specific
exceptions from other Python exceptions.  It does no additional processing,
but merely creates a distinct class to facilitate writing <tt>except</tt> statements.
</p>

<h4>Implementation</h4>

@d Error class...
@{
class Error( Exception ): pass
@| Error @}

<h3>The Reference Strategy Hierarchy</h3>
<p>The Reference Strategy has two implementations.  An instance
of this is injected into each Chunk by the Web.  The transitive closure
of references requires walking through the web.  By injecting this
algorithm, we assure that
that (1) each Chunk can produce all relevant information and (2) a
simple configuration change can be applied to the document.
</p>

<h4>Reference Superclass</h4>
<p>The superclass is an abstract class that defines the interface for
this object.
</p>

@d Reference class hierarchy... 
@{
class Reference( object ):
    def __init__( self, aWeb ):
        self.web = aWeb
    def chunkReferencedBy( self, aChunk ):
        """Return a list of Chunks."""
        pass
@}

<h4>SimpleReference Class</h4>
<p>The SimpleReference subclass does the simplest version of resolution.</p>

@d Reference class hierarchy... 
@{
class SimpleReference( Reference ):
    def __init__( self, aWeb ):
        self.web = aWeb
    def chunkReferencedBy( self, aChunk ):
        """:todo: Return the chunks themselves."""
        refBy= aChunk.referencedBy
        return [ (c.fullName, c.seq) for c in refBy ]
@}

<h4>TransitiveReference Class</h4>
<p>The TransitiveReference subclass does a transitive closure of all
references to this Chunkn.</p>

@d Reference class hierarchy... 
@{
class TransitiveReference( Reference ):
    def __init__( self, aWeb ):
        self.web = aWeb
    def chunkReferencedBy( self, aChunk ):
        """:todo: Return the chunks themselves."""
        refBy= aChunk.referencedBy
        logger.debug( "References: %r(%d) %r", aChunk.name, aChunk.seq, refBy )
        closure= self.allParentsOf( refBy )
        return [ (c.fullName, c.seq) for c in closure ]
    def allParentsOf( self, chunkList, depth=0 ):
        """Transitive closure of parents.
        :todo: Return the chunks themselves.
        """
        final = []
        for c in chunkList:
            final.append( c )
            final.extend( self.allParentsOf( c.referencedBy, depth+1 ) )
        logger.debug( "References: %*s %r", 2*depth, '--', final )
        return final
@}


<h3>The Web Class</h3>

<p>The overall web of chunks is carried in a 
single instance of the <span class="code">Web</span> class that drives the weaving and tangling actions.  
Broadly, the functionality of a Web can be separated into several areas.
Fundamentally, a Web is a hybrid list-dictionary.  It's a list of chunks that also offers a 
moderately sophisticated
lookup, including exact match for a chunk name and an approximate match for a chunk name. It's a
dictionary that also retains anonymous chunks in order.
Additionally, there are some methods that can be refactored into the <span class="code">WebReader</span> for 
resolve references among chunks.
</p>
<ul>
<li>construction methods used by <span class="code">Chunks</span> and <span class="code">WebReader</span></li>
<li><span class="code">Chunk</span> name resolution methods</li>
<li>enrichment of the web, once all the Chunks are known; each Chunk is updated
with Chunk references it makes as well as Chunks which reference it.</li>
<li><span class="code">Chunk</span> cross reference methods</li>
<li>miscellaneous access</li>
<li>tangle</li>
<li>weave</li>
</ul>

<p>A web instance has a number of attributes.</p>
<ul>
<li><i>sourceFileName</i>, the name of the original .w file.</li>
<li><i>chunkSeq</i>, the sequence of <span class="code">Chunk</span> instances as seen in the input file.
To support anonymous chunks, and to assure that the original input document order
is preserved, we keep all chunks in a master sequential list.</li>
<li><i>output</i>, the <tt>@@o</tt> named <span class="code">OutputChunk</span> chunks.  
Each element of this  dictionary is a sequence of chunks that have the same name. 
The first is the initial definition (marked with "="), all others a second definitions
(marked with "+=").</li>
<li><i>named</i>, the <tt>@@d</tt> named <span class="code">NamedChunk</span> chunks.  Each element of this 
dictionary is a sequence of chunks that have the same name.  The first is the
initial definition (marked with "="), all others a second definitions
(marked with "+=").</li>
<li><i>usedBy</i>, the cross reference of chunks referenced by commands in other
chunks.</li>
<li><i>sequence</i>, is used to assign a unique sequence number to each
named chunk.</li>
</ul>

@d Web class...
@{
class Web( object ):
    """The overall Web of chunks."""
    def __init__( self, name ):
        self.webFileName= name
        self.chunkSeq= [] 
        self.output= {} # Map filename to Chunk
        self.named= {} # Map chunkname to Chunk
        self.sequence= 0
        self.reference_style = TransitiveReference(self)
    def __str__( self ):
        return "Web %r" % ( self.webFileName, )
    @<Web construction methods used by Chunks and WebReader@>
    @<Web Chunk name resolution methods@>
    @<Web Chunk cross reference methods@>
    @<Web determination of the language from the first chunk@>
    @<Web tangle the output files@>
    @<Web weave the output document@>
@| Web 
@}

<p>During web construction, it is convenient to capture
information about the individual <span class="code">Chunk</span> instances being appended to
the web.  This done using a <i>Callback</i> design pattern.
Each subclass of <span class="code">Chunk</span> provides an override for the <span class="code">Chunk</span> class
<span class="code">webAdd()</span> method.  This override calls one of the appropriate
web construction methods.</p>
<p>Also note that the full name for a chunk can be given
either as part of the definition, or as part a reference.
Typically, the first reference has the full name and the definition
has the elided name.  This allows a reference to a chunk
to contain a more complete description of the chunk.
</p>

@d Web construction...
@{
@<Web add full chunk names, ignoring abbreviated names@>
@<Web add an anonymous chunk@>
@<Web add a named macro chunk@>
@<Web add an output file definition chunk@>
@}

<p>A name is only added to the known names when it is
a full name, not an abbreviation ending with <tt>"..."</tt>.
Abbreviated names are quietly skipped until the full name
is seen.
</p>

<p>The algorithm for the <span class="code">addDefName()</span> method, then is as follows:</p>
<ol>
<li>Use the <span class="code">fullNameFor()</span> method to locate the full name.</li>
<li>If no full name was found (the result of <span class="code">fullNameFor()</span> ends
with <tt>'...'</tt>), ignore this name as an abbreviation with no definition.</li>
<li>If this is a full name and the name was not in the 
<i>named</i> mapping, add this full name to the mapping.
</li>
</ol>

<p>This name resolution approach presents a problem when a chunk is
defined before it is referenced and the first definition
uses an abbreviated name.  This is an atypical construction
of an input document, however, since the intent is to provide
high-level summaries that have forward references to supporting
details.
</p>

@d Web add full chunk names...
@{
def addDefName( self, name ):
    """Reference to or definition of a chunk name."""
    nm= self.fullNameFor( name )
    if nm is None: return None
    if nm[-3:] == '...':
        logger.debug( "Abbreviated reference %r", name )
        return None # first occurance is a forward reference using an abbreviation
    if nm not in self.named:
        self.named[nm]= []
        logger.debug( "Adding empty chunk %r", name )
    return nm
@| addDefName
@}

<p>An anonymous <span class="code">Chunk</span> is kept in a sequence of chunks, used for
tangling.
</p>
@d Web add an anonymous chunk
@{
def add( self, chunk ):
    """Add an anonymous chunk."""
    self.chunkSeq.append( chunk )
@| add
@}

<p>A named <span class="code">Chunk</span> is defined with a <tt>@@d</tt> command.
It is collected into a mapping of <span class="code">NamedChunk</span> instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.
</p>
<p>All chunks are also placed in the overall sequence of chunks.
This overall sequence is used for weaving the document.
</p>
<p>The <span class="code">addDefName()</span> method is used to resolve this name if
it is an abbreviation, or add it to the mapping if this
is the first occurance of the name.  If the name cannot be
added, an instance of our <span class="code">Error</span> class is raised.  If the name exists or 
was added, the chunk is appended to the chunk list associated
with this name.
</p>
<p>The web's sequence counter is incremented, and this 
unique sequence number sets the  <i>seq</i> attribute of the <span class="code">Chunk</span>.
If the chunk list was empty, this is the first chunk, the
<i>initial</i> flag is set to True when there's only one element
in the list.  Otherwise, it's false.
</p>

@d Web add a named macro chunk
@{
def addNamed( self, chunk ):
    """Add a named chunk to a sequence with a given name."""
    chunk.reference_style= self.reference_style
    self.chunkSeq.append( chunk )
    nm= self.addDefName( chunk.name )
    if nm:
        # We found the full name for this chunk
        self.sequence += 1
        chunk.seq= self.sequence
        chunk.fullName= nm
        self.named[nm].append( chunk )
        chunk.initial= len(self.named[nm]) == 1
        logger.debug( "Extending chunk %r from %r", nm, chunk.name )
    else:
        raise Error("No full name for %r" % chunk.name, chunk)
@| addNamed 
@}

<p>An output file definition <span class="code">Chunk</span> is defined with an <tt>@@o</tt>
command.  It is collected into a mapping of <span class="code">OutputChunk</span> instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.
</p>
<p>Note that file names cannot be abbreviated.</p>
<p>All chunks are also placed in overall sequence of chunks.
This overall sequence is used for weaving the document.
</p>
<p>If the name does not exist in the <i>output</i> mapping,
the name is added with an empty sequence of chunks.
In all cases, the chunk is 
appended to the chunk list associated
with this name.
</p>
<p>The web's sequence counter is incremented, and this 
unique sequence number sets the Chunk's <i>seq</i> attribute.
If the chunk list was empty, this is the first chunk, the
<i>initial</i> flag is True if this is the first chunk.
</p>


@d Web add an output file definition chunk
@{
def addOutput( self, chunk ):
    """Add an output chunk to a sequence with a given name."""
    chunk.reference_style= self.reference_style
    self.chunkSeq.append( chunk )
    if chunk.name not in self.output:
        self.output[chunk.name] = []
        logger.debug( "Adding chunk %r", chunk.name )
    self.sequence += 1
    chunk.seq= self.sequence
    chunk.fullName= chunk.name
    self.output[chunk.name].append( chunk )
    chunk.initial = len(self.output[chunk.name]) == 1
@| addOutput
@}

<p>Web chunk name resolution has three aspects.  The first
is resolving elided names (those ending with <tt>...</tt>) to their
actual full names.  The second is finding the named chunk
in the web structure.  The third is returning a reference
to a specific chunk including the name and sequence number.
</p>
<p>Note that a chunk name actually refers to a sequence
of chunks.  Multiple definitions for a chunk are allowed, and
all of the definitions are concatenated to create the complete
chunk.  This complexity makes it unwise to return the sequence
of same-named chunks; therefore, we put the burden on the Web to 
process all chunks with a given name, in sequence.
</p>

<p>The <span class="code">fullNameFor()</span> method resolves full name for a chunk as follows:</p>
<ol>
<li>If the string is already in the <i>named</i> mapping, this is the full name</li>
<li>If the string ends in <tt>'...'</tt>, visit each key in the dictionary to see if the
key starts with the string up to the trailing <tt>'...'</tt>.  If a match is found, the dictionary
key is the full name.</li>
<li>Otherwise, treat this as a full name.</li>
</ol>

@d Web Chunk name resolution...
@{
def fullNameFor( self, name ):
    """Resolve "..." names into the full name."""
    if name in self.named: return name
    if name[-3:] == '...':
        best= [ n for n in self.named.keys()
            if n.startswith( name[:-3] ) ]
        if len(best) > 1:
            raise Error("Ambiguous abbreviation %r, matches %r" % ( name, best ) )
        elif len(best) == 1: 
            return best[0]
    return name
@| fullNameFor
@}

<p>The <span class="code">getchunk()</span> method locates a named sequence of chunks by first determining the full name
for the identifying string.  If full name is in the <i>named</i> mapping, the sequence
of chunks is returned.  Otherwise, an instance of our <span class="code">Error</span> class is raised because the name
is unresolvable.
</p>
<p>It might be more helpful for debugging to emit this as an error in the
weave and tangle results and keep processing.  This would allow an author to
catch multiple errors in a single run of <em>pyWeb</em>.</p>
 
@d Web Chunk name resolution...
@{
def getchunk( self, name ):
    """Locate a named sequence of chunks."""
    nm= self.fullNameFor( name )
    if nm in self.named:
        return self.named[nm]
    raise Error( "Cannot resolve %r in %r" % (name,self.named.keys()) )
@| getchunk
@}

<p>Cross-reference support includes creating and reporting
on the various cross-references available in a web.  This includes
creating the list of chunks that reference a given chunk;
and returning the file, macro and user identifier cross references.
</p>

<p>Each <span class="code">Chunk</span> has a list <span class="code">Reference</span> commands that shows the chunks
to which a chunk refers.  These relationships must be reversed to show
the chunks that refer to a given chunk.  This is done by traversing
the entire web of named chunks and recording each chunk-to-chunk reference.
This mapping has the referred-to chunk as 
the key, and a sequence of referring chunks as the value.
</p>

<p>The accumulation is initiated by the web's <span class="code">createUsedBy()</span> method.  This
method visits a <span class="code">Chunk</span>, calling the <span class="code">genReferences()</span> method, 
passing in the <span class="code">Web</span> instance
as an argument.  Each <span class="code">Chunk</span> class <span class="code">genReferences()</span> method, in turn, 
invokes the <span class="code">usedBy()</span> method
of each <span class="code">Command</span> instance in the chunk.  Most commands do nothing, 
but a <span class="code">ReferenceCommand</span>
will resolve the name to which it refers.
</p>
<p>When the <span class="code">createUsedBy()</span> method has accumulated the entire cross 
reference, it also assures that all chunks are used exactly once.</p>

@d Web Chunk cross reference methods...
@{
def createUsedBy( self ):
    """Update every piece of a Chunk to show how the chunk is referenced.
    Each piece can then report where it's used in the web.
    """
    for aChunk in self.chunkSeq:
        #usage = (self.fullNameFor(aChunk.name), aChunk.seq)
        for aRefName in aChunk.genReferences( self ):
            for c in self.getchunk( aRefName ):
                c.referencedBy.append( aChunk )
                c.refCount += 1
    @<Web Chunk check reference counts are all one@>
@| createUsedBy
@}

<p>We verify that the reference count for a
chunk is exactly one.  We don't gracefully tolerate multiple references to
a chunk or unreferenced chunks.</p>
@d Web Chunk check...
@{
for nm in self.no_reference():
    logger.warn( "No reference to %r", nm )
for nm in self.multi_reference():
    logger.warn( "Multiple references to %r", nm )
for nm in self.no_definition():
    logger.warn( "No definition for %r", nm )
@}

<p>The one-pass version</p>
<pre>
for nm,cl in self.named.items():
   if len(cl) > 0:
       if cl[0].refCount == 0:
           logger.warn( "No reference to %r", nm )
       elif cl[0].refCount > 1:
           logger.warn( "Multiple references to %r", nm )
   else:
       logger.warn( "No definition for %r", nm )
</pre>

<p>We use three methods to filter chunk names into 
the various warning categories.  The <span class="code">no_reference</span> list
is a list of chunks defined by never referenced.
The <span class="code">multi_reference</span> list
is a list of chunks defined by never referenced.
The <span class="code">no_definition</span> list
is a list of chunks referenced but not defined.
</p>

@d Web Chunk cross reference methods...
@{
def no_reference( self ):
    return [ nm for nm,cl in self.named.items() if len(cl)>0 and cl[0].refCount == 0 ]
def multi_reference( self ):
    return [ nm for nm,cl in self.named.items() if len(cl)>0 and cl[0].refCount > 1 ]
def no_definition( self ):
    return [ nm for nm,cl in self.named.items() if len(cl) == 0 ] 
@| no_reference multi_reference no_definition
@}

<p>The <span class="code">fileXref()</span> method visits all named file output chunks in <i>output</i> and
collects the sequence numbers of each section in the sequence of chunks.
</p>
<p>The <span class="code">chunkXref()</span> method uses the same algorithm as a the <span class="code">fileXref()</span> method,
but applies it to the <i>named</i> mapping.
</p>

@d Web Chunk cross reference methods...
@{
def fileXref( self ):
    fx= {}
    for f,cList in self.output.items():
        fx[f]= [ c.seq for c in cList ]
    return fx
def chunkXref( self ):
    mx= {}
    for n,cList in self.named.items():
        mx[n]= [ c.seq for c in cList ]
    return mx
@| fileXref chunkXref
@}

<p>The <span class="code">userNamesXref()</span> method creates a mapping for each
user identifier.  The value for this mapping is a tuple
with the chunk that defined the identifer (via a <tt>@@|</tt> command), 
and a sequence of chunks that reference the identifier. 
</p>
<p>For example:
<tt>{ 'Web': ( 87, (88,93,96,101,102,104) ), 'Chunk': ( 53, (54,55,56,60,57,58,59) ) }</tt>, 
shows that the identifier
<tt>'Web'</tt> is defined in chunk with a sequence number of 87, and referenced
in the sequence of chunks that follow.
</p>
<p>This works in two passes:</p>
<ul>
<li><span class="code">_gatherUserId()</span> gathers all user identifiers</li>
<li><span class="code">_updateUserId()</span> searches all text commands for the identifiers and
updates the <span class="code">Web</span> class cross reference information.</li>
</ul>

@d Web Chunk cross reference methods...
@{
def userNamesXref( self ):
    ux= {}
    self._gatherUserId( self.named, ux )
    self._gatherUserId( self.output, ux )
    self._updateUserId( self.named, ux )
    self._updateUserId( self.output, ux )
    return ux
def _gatherUserId( self, chunkMap, ux ):
    @<collect all user identifiers from a given map into ux@>
def _updateUserId( self, chunkMap, ux ):
    @<find user identifier usage and update ux from the given map@>
@| userNamesXref _gatherUserId _updateUserId
@}

<p>User identifiers are collected by visiting each of the sequence of 
<span class="code">Chunks</span> that share the
same name; within each component chunk, if chunk has identifiers assigned
by the <tt>@@|</tt> command, these are seeded into the dictionary.
If the chunk does not permit identifiers, it simply returns an empty
list as a default action.
</p>
 
@d collect all user identifiers...
@{
for n,cList in chunkMap.items():
    for c in cList:
        for id in c.getUserIDRefs():
            ux[id]= ( c.seq, [] )
@}

<p>User identifiers are cross-referenced by visiting 
each of the sequence of <span class="code">Chunks</span> that share the
same name; within each component chunk, visit each user identifier;
if the <span class="code">Chunk</span> class <span class="code">searchForRE()</span> method matches an identifier, 
this is appended to the sequence of chunks that reference the original user identifier.
</p>

@d find user identifier usage...
@{
# examine source for occurances of all names in ux.keys()
for id in ux.keys():
    logger.debug( "References to %r", id )
    idpat= re.compile( r'\W%s\W' % id )
    for n,cList in chunkMap.items():
        for c in cList:
            if c.seq != ux[id][0] and c.searchForRE( idpat ):
                ux[id][1].append( c.seq )
@}

<p>The <span class="code">language()</span> method determines the output language.
The determination of the language can be done a variety of ways.
One is to use command line parameters, another is to use the filename
extension on the input file.</p>
<p>We examine the first few characters of input.  A proper HTML, XHTML or
XML file begins with '&lt;!', '&lt;?' or '&lt;H'.  LaTeX files
typically begin with '%' or '\'.
</p>

@d Web determination of the language...
@{
def language( self, preferredWeaverClass=None ):
    """Construct a weaver appropriate to the document's language"""
    if preferredWeaverClass:
        return preferredWeaverClass()
    if self.chunkSeq[0].startswith('<'): return HTML()
    if self.chunkSeq[0].startswith('%') or self.chunkSeq[0].startswith('\\'):  return LaTeX()
    return Weaver()
@| language
@}

<p>The <span class="code">tangle()</span> method of the <span class="code">Web</span> class performs 
the <span class="code">tangle()</span> method for each <span class="code">Chunk</span> of each
named output file.  Note that several chunks may share the file name, requiring
the file be composed of material in each chunk.
</p>
<p>During tangling of a chunk, the chunk may reference another
chunk.  This transitive tangling of an individual chunk is handled by the
<span class="code">tangleChunk()</span> method.
</p>

@d Web tangle...
@{
def tangle( self, aTangler ):
    for f,c in self.output.items():
        aTangler.open( f )
        for p in c:
            p.tangle( self, aTangler )
        aTangler.close()
def tangleChunk( self, name, aTangler ):
    logger.debug( "Tangling chunk %r", name )
    chunkList= self.getchunk(name)
    if len(chunkList) == 0:
        raise Error( "Attempt to tangle an undefined Chunk, %s." % ( name, ) )
    for p in chunkList:
        p.tangle( self, aTangler )
@| tangle tangleChunk
@}

<p>The <span class="code">weave()</span> method of the <span class="code">Web</span> class creates the final documentation.
This is done by stepping through each <span class="code">Chunk</span> in sequence
and weaving the chunk into the resulting file via the <span class="code">Chunk</span> class <span class="code">weave()</span> method.
</p>
<p>During weaving of a chunk, the chunk may reference another
chunk.  When weaving a reference to a named chunk (output or ordinary programming
source defined with @@{), this does not lead to transitive weaving: only a
reference is put in from one chunk to another.  However, when weaving
a chunk defined with @@[, the chunk <i>is</i> expanded when weaving.
The decision is delegated to the referenced chunk.
</p>

@d Web weave...
@{
def weave( self, aWeaver ):
    aWeaver.open( self.webFileName )
    for c in self.chunkSeq:
        c.weave( self, aWeaver )
    aWeaver.close()
def weaveChunk( self, name, aWeaver ):
    logger.debug( "Weaving chunk %r", name )
    chunkList= self.getchunk(name)
    if not chunkList:
        raise Error( "No Definition for %s", name )
    chunkList[0].weaveReferenceTo( self, aWeaver )
    for p in chunkList[1:]:
        p.weaveShortReferenceTo( self, aWeaver )
@| weave weaveChunk
@}

<h3>The WebReader Class</h3>

<h4>Usage</h4>

<p>There are two forms of the constructor for a <span class="code">WebReader</span>.  The 
initial <span class="code">WebReader</span> instance is created with code like the following:
</p>
<pre>
p= WebReader( aFileName, command=aCommandCharacter )
</pre>
<p>
This will define the initial input file and the command character, both
of which are command-line parameters to the application.
</p>
<p>When processing an include file (with the @@i command), a child <span class="code">WebReader</span>
instance is created with code like the following:
</p>
<pre>
c= WebReader( anIncludeName, parent=parentWebReader )
</pre>
<p>
This will define the included file, but will inherit the command 
character from the parent <span class="code">WebReader</span>.  This will also include a 
reference from child to parent so that embedded Python expressions
can view the entire input context.
</p>

<h4>Design</h4>

<p>The <span class="code">WebReader</span> class parses the input file into command blocks.
These are assembled into <span class="code">Chunks</span>, and the <span class="code">Chunks</span> are assembled into the document
<span class="code">Web</span>.  Once this input pass is complete, the resulting <span class="code">Web</span> can be tangled or
woven.
</p>

<p>The parser works by reading the entire file and splitting on <tt>@@.</tt> patterns.
The <span class="code">split()</span> method of the Python <span class="code">re</span> module will separate the input
and preserve the actual character sequence on which the input was split.
This breaks the input into blocks of text separated by the <tt>@@.</tt> characters.
</p>

<p>"Major" commands partition the input into <span class="code">Chunks</span>.  The major commands 
are <tt>@@d</tt> and <tt>@@o</tt>, as well as the <tt>@@{</tt>, <tt>@@}</tt>, <tt>@@[</tt>, <tt>@@]</tt> brackets, and the <tt>@@i</tt> command
to include another file.
</p>
<p>"Minor" commands are inserted into a <span class="code">Chunk</span> as a <span class="code">Command</span>.  Blocks of text
are minor commands, as well as the <tt>@@&lt;<i>name</i>@@&gt;</tt> references, 
the various cross-reference commands (<tt>@@f</tt>, <tt>@@m</tt> and <tt>@@u</tt>).  
The <tt>@@@@</tt> escape is also
handled here so that all further processing is independent of any parsing.
</p>

<h4>Implementation</h4>

<p>The class has the following attributes:</p>
<ul>
<li><i>fileName</i> is used to pass the file name to the Web instance.</li>
<li><i>tokenList</i> is the completely tokenized input file.</li>
<li><i>token</i> is the most recently examined token.</li>
<li><i>tokenIndex</i> is an index through the tokenList.</li>
<li><i>lineNumber</i> is the count of <tt>'\n'</tt> characters seen in the tokens.</li>
<li><i>aChunk</i> is the current open Chunk.</li>
<li><i>parent</i> is the outer <span class="code">WebReader</span> when processing a <tt>@@i</tt> command.</li>
<li><i>theWeb</i> is the current open Web.</li>
<li><i>permitList</i> is the list of commands that are permitted to fail.  This
is generally an empty list or <tt>('@@i',)</tt>.</li>
<li><i>command</i> is the command character; a WebReader will use the parent
command character if the parent is not <tt>None</tt>.
<li><i>parsePat</i> is generated from the command character, and is used to parse
the input into tokens.</li>
</ul>

@d WebReader class...
@{
class WebReader( object ):
    """Parse an input file, creating Commands and Chunks."""
    def __init__( self, parent=None, command='@@', permit=None ):
        # Configuration of this reader.
        self._source= None
        self.fileName= None
        self.parent= parent
        self.theWeb= None
        if self.parent: 
            self.command= self.parent.command
            self.permitList= self.parent.permitList
        else:
            self.command= command
            self.permitList= [] if permit is None else permit
            
        self.log_reader= logging.getLogger( "pyweb.%s" % self.__class__.__name__ )

        # State of reading and parsing.
        self.tokenList= []
        self.token= ""
        self.tokenIndex= 0
        self.tokenPushback= []
        self.lineNumber= 0
        self.aChunk= None
        self.totalLines= 0
        self.totalFiles= 0
        self.parsePat= '(%s.)' % self.command
        @<WebReader command literals@>
    def __str__( self ):
        return self.__class__.__name__
    @<WebReader fluent property-like methods@>
    @<WebReader tokenize the input@>
    @<WebReader location in the input stream@>
    @<WebReader handle a command string@>
    @<WebReader load the web@>
@| WebReader @}

<p>A few fluent property-like methods help set the attributes of a WebReader.</p>

@d WebReader fluent property...
@{
def web( self, aWeb ):
    self.theWeb= aWeb
    return self
def source( self, name, source=None ):
    """Set a name to display with error messages; also set the actual file-like source.
    if no source is given, the name is treated as a filename and opened.
    """
    self.fileName= name
    self._source= source
    return self
@}
<p>This tokenizer centralizes a single call to <span class="code">nextToken()</span>.  This assures that
every token is examined by <span class="code">nextToken()</span>, which permits accurate 
counting of the <tt>'\n'</tt> characters
and determining the line numbers of the input file.  This line number
information can then be attached to each <span class="code">Command</span>, directing the user back to 
the correct line of the original input file.
</p>
<p>The tokenizer supports lookahead by allowing the parser to examine tokens
and then push them back into a pushBack stack.  Generally this is used for the
special case of parsing the @@i command, which has no @@-command terminator or
separator.  It ends with the following <tt>'\n'</tt>.
</p>
<p>Python permits a simplified double-ended queue for this kind
of token stream processing.  Ordinary tokens are fetched with a <tt>pop(0)</tt>, and
a pushback is done by prepending the pushback token with a <tt>tokenList = [ token ] + tokenList</tt>.
For this application, however, we need to keep a count of <tt>'\n'</tt>s seen, 
and we want to avoid double-counting <tt>'\n'</tt> pushed back into the token stream.
So we use a queue of tokens and a stack for pushback.
</p>

@d WebReader tokenize...
@{
def openSource( self ):
    if self._source is None:
        self._source= open( self.fileName, "r" )
    text= self._source.read()
    self.tokenList= re.split(self.parsePat, text )
    self.lineNumber= 1
    self.totalLines= 0
    self.totalFiles += 1
    self.tokenPushback= []
def nextToken( self ):
    lines=  self.token.count('\n')
    self.lineNumber += lines
    self.totalLines += lines
    if self.tokenPushback:
        self.token= self.tokenPushback.pop()
    else:
        self.token= self.tokenList.pop(0)
    return self.token
def moreTokens( self ):
    return self.tokenList or self.tokenPushback
def pushBack( self, token ):
    self.tokenPushback.append( token )
@| openSource nextToken moreTokens pushBack totalLines
@}

<p>The <span class="code">location()</span> provides the file name and 
range of lines for a particular command.  This allows error
messages as well as tangled or woven output 
to correctly reference the original input files.
</p>

@d WebReader location...
@{
def location( self ):
    return ( self.fileName, self.lineNumber, self.lineNumber+self.token.count("\n") )
@| location
@}

<p>Command recognition is done via a <i>Chain of Command</i>-like design.
There are two conditions: the command string is recognized or it is not recognized.</p>
<p>If the command is recognized, <span class="code">handleCommand()</span> either:</p>
<ul>
<li>(for major commands) attaches the current <span class="code">Chunk</span> (<i>self.aChunk</i>) to the 
current <span class="code">Web</span> (<i>self.aWeb</i>), <em>or</em></li>
<li>(for minor commands) create a <span class="code">Command</span>, attach it to the current 
<span class="code">Chunk</span> (<i>self.aChunk</i>)</li>
</ul>
<p><em>and</em> returns a true result.</p>
<p>If the command is not recognized, <span class="code">handleCommand()</span> returns false.</p>
<p>
A subclass can override <span class="code">handleCommand()</span> to (1) call this superclass version;
(2) if the command is unknown to the superclass, 
then the subclass can attempt to process it;
(3) if the command is unknown to both classes, 
then return false.  Either a subclass will handle it, or the default activity taken
by <span class="code">load()</span> is to treat the command a text, but also issue a warning.
</p>

@d WebReader handle a command...
@{
def handleCommand( self, token ):
    self.log_reader.debug( "Reading %r", token )
    @<major commands segment the input into separate Chunks@>
    @<minor commands add Commands to the current Chunk@>
    elif token[:2] in (self.cmdlcurl,self.cmdlbrak):
        # These should be consumed as part of @@o and @@d parsing
        raise Error('Extra %r (possibly missing chunk name)' % token, self.aChunk)
    else:
        return None # did not recogize the command
    return True # did recognize the command
@| handleCommand
@}

<p>The following sequence of <span class="code">if</span>-<span class="code">elif</span> statements identifies
the major commands that partition the input into separate <span class="code">Chunks</span>.
</p>
@d major commands...
@{
if token[:2] == self.cmdo:
    @<start an OutputChunk, adding it to the web@>
elif token[:2] == self.cmdd:
    @<start a NamedChunk or NamedDocumentChunk, adding it to the web@>
elif token[:2] == self.cmdi:
    @<import another file@>
elif token[:2] in (self.cmdrcurl,self.cmdrbrak):
    @<finish a chunk, start a new Chunk adding it to the web@>
@}

<p>An output chunk has the form <tt>@@o <i>name</i> @@{ <i>content</i> @@}</tt>.
We use the first two tokens to name the <span class="code">OutputChunk</span>.  We simply expect
the <tt>@@{</tt> separator.  We then attach all subsequent commands
to this chunk while waiting for the final <tt>@@}</tt> token to end the chunk.
</p>

<p><b>TODO</b> The file name information can be split into parts on a <tt>' '</tt>.
We can add escaping (<tt>'\ '</tt>) and quoting to allow more flexibility.
If there's one part, it's the file name.  If there is more than one part, it
will provide comment characters.  The <span class="code">shlex</span> module
will handle the parsing into quoted fields.
</p>

@d Imports
@{import shlex
@| shlex
@}

@d start an OutputChunk...
@{
args= self.nextToken().strip()
values = shlex.split( args )
if len(values) == 1:
    self.aChunk= OutputChunk( values[0], "", "" )
elif len(values) == 2:
    self.aChunk= OutputChunk( values[0], values[1], "" )
else:
    self.aChunk= OutputChunk( values[0], values[1], values[2] )
self.aChunk.webAdd( self.theWeb )
self.expect( (self.cmdlcurl,) )
# capture an OutputChunk up to @@}
@}

<p>An named chunk has the form <tt>@@d <i>name</i> @@{ <i>content</i> @@}</tt> for
code and <tt>@@d <i>name</i> @@[ <i>content</i> @@]</tt> for document source.
We use the first two tokens to name the <span class="code">NamedChunk</span> or <span class="code">NamedDocumentChunk</span>.  
We expect either the <tt>@@{</tt> or <tt>@@[</tt> separator, and use the actual
token found to choose which subclass of <span class="code">Chunk</span> to create.
We then attach all subsequent commands
to this chunk while waiting for the final <tt>@@}</tt> or <tt>@@]</tt> token to 
end the chunk.
</p>

@d start a NamedChunk...
@{
name= self.nextToken().strip()
# next token is @@{ or @@[
brack= self.expect( (self.cmdlcurl,self.cmdlbrak) )
if brack == self.cmdlcurl: 
    self.aChunk= NamedChunk( name )
else: 
    self.aChunk= NamedDocumentChunk( name )
self.aChunk.webAdd( self.theWeb )
# capture a NamedChunk up to @@} or @@]
@}

<p>An import command has the unusual form of <tt>@@i <i>name</i></tt>, with no trailing
separator.  When we encounter the <tt>@@i</tt> token, the next token will start with the
file name, but may continue with an anonymous chunk.  We require that all <tt>@@i</tt> commands
occur at the end of a line, and break on the <tt>'\n'</tt> which must occur after the file name.
This permits file names with embedded spaces.
</p>
<p>Once we have split the file name away from the rest of the following anonymous chunk,
we push the following token back into the token stream, so that it will be the 
first token examined at the top of the <span class="code">load()</span> loop.
</p>
<p>We create a child <span class="code">WebReader</span> instance to process the included file.  The entire file 
is loaded into the current <span class="code">Web</span> instance.  A new, empty <span class="code">Chunk</span> is created at the end
of the file so that processing can resume with an anonymous <span class="code">Chunk</span>.
</p>

@d import another file
@{
# break this token on the '\n' and pushback the new token.
next= self.nextToken().split('\n',1)
self.pushBack('\n')
if len(next) > 1:
    self.pushBack( '\n'.join(next[1:]) )
incFile= next[0].strip()
try:
    with open(incFile,"r") as source:
        logger.info( "Including %r", incFile )
        include= WebReader( parent=self )
        include.source( incFile, source ).web( self.theWeb )
        include.load()
    self.totalLines += include.totalLines
    self.totalFiles += include.totalFiles
except (Error,IOError),e:
    logger.error( 
        "Problems with included file %s, output is incomplete.",
        incFile )
    # Discretionary - sometimes we want total failure
    if self.cmdi in self.permitList: pass
    else: raise
self.aChunk= Chunk()
self.aChunk.webAdd( self.theWeb )
@}

<p>When a <tt>@@}</tt> or <tt>@@]</tt> are found, this finishes a named chunk.  The next
text is therefore part of an anonymous chunk.
</p>
<p>Note that no check is made to assure that the previous <span class="code">Chunk</span> was indeed a named
chunk or output chunk started with <tt>@@{</tt> or <tt>@@[</tt>.  
To do this, an attribute would be
needed for each <span class="code">Chunk</span> subclass that indicated if a trailing bracket was necessary.
For the base <span class="code">Chunk</span> class, this would be false, but for all other subclasses of
<span class="code">Chunk</span>, this would be true.
</p>

@d finish a chunk...
@{
self.aChunk= Chunk()
self.aChunk.webAdd( self.theWeb )
@}

<p>The following sequence of <span class="code">elif</span> statements identifies
the minor commands that add <span class="code">Command</span> instances to the current open <span class="code">Chunk</span>. 
</p>

@d minor commands...
@{
elif token[:2] == self.cmdpipe:
    @<assign user identifiers to the current chunk@>
elif token[:2] == self.cmdf:
    self.aChunk.append( FileXrefCommand(self.lineNumber) )
elif token[:2] == self.cmdm:
    self.aChunk.append( MacroXrefCommand(self.lineNumber) )
elif token[:2] == self.cmdu:
    self.aChunk.append( UserIdXrefCommand(self.lineNumber) )
elif token[:2] == self.cmdlangl:
    @<add a reference command to the current chunk@>
elif token[:2] == self.cmdlexpr:
    @<add an expression command to the current chunk@>
elif token[:2] == self.cmdcmd:
    @<double at-sign replacement, append this character to previous TextCommand@>
@}

<p>User identifiers occur after a <tt>@@|</tt> in a <span class="code">NamedChunk</span>.
<p>Note that no check is made to assure that the previous <span class="code">Chunk</span> was indeed a named
chunk or output chunk started with <tt>@@{</tt>.  
To do this, an attribute would be
needed for each <span class="code">Chunk</span> subclass that indicated if user identifiers are permitted.
For the base <span class="code">Chunk</span> class, this would be false, but for the <span class="code">NamedChunk</span> class and
<span class="code">OutputChunk</span> class, this would be true.
</p>

@d assign user identifiers... 
@{
# variable references at the end of a NamedChunk
# aChunk must be subclass of NamedChunk
# These are accumulated and expanded by @@u reference
try:
    self.aChunk.setUserIDRefs( self.nextToken().strip() )
except AttributeError:
    # Out of place user identifier command
    raise Error("Unexpected references near %s: %s" % (self.location(),token) )
@}

<p>A reference command has the form <tt>@@< <i>name</i> @@></tt>.  We accept three
tokens from the input, the middle token is the referenced name.
</p>

@d add a reference command...
@{
# get the name, introduce into the named Chunk dictionary
expand= self.nextToken().strip()
self.expect( (self.cmdrangl,) )
self.theWeb.addDefName( expand )
self.aChunk.append( ReferenceCommand( expand, self.lineNumber ) )
self.aChunk.appendText( "", self.lineNumber ) # to collect following text
self.log_reader.debug( "Reading %r %r", expand, self.token )
@}

<p>An expression command has the form <tt>@@( <i>Python Expression</i> @@)</tt>.  
We accept three
tokens from the input, the middle token is the expression.
</p>
<p>There are two alternative semantics for an embedded expression.</p>
<ul>
<li>Deferred Execution.  This requires definition of a new subclass of <span class="code">Command</span>, 
<span class="code">ExpressionCommand</span>, and appends it into the current <span class="code">Chunk</span>.  At weave and
tangle time, this expression is evaluated.  The insert might look something like this:
<tt>aChunk.append( ExpressionCommand( expression, self.lineNumber ) )</tt>.
</li>
<li>Immediate Execution.  This simply creates a context and evaluates
the Python expression.  The output from the expression becomes a TextCommand, and
is append to the current <span class="code">Chunk</span>.</li>
</ul>
<p>We use the Immediate Execution semantics.</p>

@d add an expression command...
@{
# get the Python expression, create the expression command
expression= self.nextToken()
self.expect( (self.cmdrexpr,) )
try:
    theLocation= self.location()
    theWebReader= self
    theFile= self.theWeb.webFileName
    thisApplication= sys.argv[0]
    result= str(eval( expression ))
except Exception,e:
    result= '!!!Exception: %s' % e
    logger.exception( 'Failure to process %r: result is %s', expression, e )
self.aChunk.appendText( result, self.lineNumber )
@}

<p>A double command sequence (<tt>'@@@@'</tt>, when the command is an <tt>'@@'</tt>) has the
usual meaning of <tt>'@@'</tt> in the input stream.  We do this via 
the <span class="code">appendText()</span> method of the current <span class="code">Chunk</span>.  This will append the 
character on the end of the most recent <span class="code">TextCommand</span>; if this fails, it will
create a new, empty <span class="code">TextCommand</span>.
</p>
@d double at-sign...
@{
# replace with '@@' here and now!
# Put this at the end of the previous chunk
# AND make sure the next chunk is appended to this.
self.aChunk.appendText( self.command, self.lineNumber )
@}

<p>The <span class="code">expect()</span> method examines the 
next token to see if it is the expected string.  If this is not found, a
standard type of error message is written.
</p>
<p>The <span class="code">load()</span> method reads the entire input file as a sequence
of tokens, split up by the <span class="code">openSource()</span> method.  Each token that appears
to be a command is passed to the <span class="code">handleCommand()</span> method.  If
the <span class="code">handleCommand()</span> method returns a true result, the command was recognized
and placed in the <span class="code">Web</span>.  if <i>handleCommand()</i> returns a false result, the command
was unknown, and some default behavior is used.
</p>
<p>The <span class="code">load()</span> method takes an optional <tt>permit</tt> variable.
This encodes commands where failure is permitted.  Currently, only the @@i command
can be set to permit failure.  This allows including a file that does not yet 
exist.  The primary application of this option is when weaving test output.
The first pass of <em>pyWeb</em> tangles the program source files; they are
then run to create test output; the second pass of <em>pyWeb</em> weaves this
test output into the final document via the @@i command.
</p>

@d WebReader load...
@{
def expect( self, tokens ):
    if not self.moreTokens():
        raise Error("At %r: end of input, %r not found" % (self.location(),tokens) )
    t= self.nextToken()
    if t not in tokens:
        raise Error("At %r: expected %r, found %r" % (self.location(),tokens,t) )
    return t
    
def load( self ):
    self.aChunk= Chunk() # Initial anonymous chunk of text.
    self.aChunk.webAdd( self.theWeb )
    self.openSource()
    while self.moreTokens():
        token= self.nextToken()
        if len(token) >= 2 and token.startswith(self.command):
            if self.handleCommand( token ):
                continue
            else:
                @<other command-like sequences are appended as a TextCommand@>
        elif token:
            # accumulate non-empty block of text in the current chunk
            self.aChunk.appendText( token, self.lineNumber )
@| expect load
@}

@d other command-like sequences...
@{
logger.warn( 'Unknown @@-command in input: %r', token )
self.aChunk.appendText( token, self.lineNumber )
@}


<p>The command character can be changed to permit
some flexibility when working with languages that make extensive
use of the <tt>@@</tt> symbol, <em>i.e.</em>, PERL.
The initialization of the <span class="code">WebReader</span> is based on the selected 
command character.
</p>

@d WebReader command literals
@{
# major commands
self.cmdo= self.command+'o'
self.cmdd= self.command+'d'
self.cmdlcurl= self.command+'{'
self.cmdrcurl= self.command+'}'
self.cmdlbrak= self.command+'['
self.cmdrbrak= self.command+']'
self.cmdi= self.command+'i'
# minor commands
self.cmdlangl= self.command+'<'
self.cmdrangl= self.command+'>'
self.cmdpipe= self.command+'|'
self.cmdlexpr= self.command+'('
self.cmdrexpr= self.command+')'
self.cmdf= self.command+'f'
self.cmdm= self.command+'m'
self.cmdu= self.command+'u'
self.cmdcmd= self.command+self.command
@}

<h3>Action Class Hierarchy</h3>
<p>This application performs three major actions: loading the document web, 
weaving and tangling.  Generally,
the use case is to perform a load, weave and tangle.  However, a less common use case
is to first load and tangle output files, run a regression test and then 
load and weave a result that includes the test output file.
</p>
<p>The <tt>-x</tt> option excludes one of the two output actions.  The <tt>-xw</tt> 
excludes the weave pass, doing only the tangle action.  The <tt>-xt</tt> excludes
the tangle pass, doing the weave action.
</p>
<p>This two pass action might be embedded in the following type of Python program.</p>
<pre>
import pyweb, os
pyweb.tangle( "source.w" )
os.system( "python source.py >source.log" )
pyweb.weave( "source.w" )
</pre>
<p>The first step runs <em>pyWeb</em>, excluding the final weaving pass.  The second
step runs the tangled program, <tt>source.py</tt>, and produces test results in
a log file, <tt>source.log</tt>.  The third step runs <em>pyWeb</em> excluding the
tangle pass.  This produces a final document that includes the <tt>source.log</tt> 
test results.
</p>
<p>To accomplish this, we provide a class hierarchy that defines the various
actions of the <em>pyWeb</em> application.  This class hierarchy defines an extensible set of 
fundamental actions.  This gives us the flexibility to create a simple sequence
of actions and execute any combination of these.  It eliminates the need for a 
forest of <tt>if</tt>-statements to determine precisely what will be done.
</p>
<p>Each action has the potential to update the state of the overall
application.   A partner with this command hierarchy is the Application class
that defines the application options, inputs and results.</p> 

@d Action class hierarchy... 
@{
@<Action superclass has common features of all actions@>
@<ActionSequence subclass that holds a sequence of other actions@>
@<WeaveAction subclass initiates the weave action@>
@<TangleAction subclass initiates the tangle action@>
@<LoadAction subclass loads the document web@>
@}

<h4>Action Class</h4>
<p>The <span class="code">Action</span> class embodies the basic operations of <em>pyWeb</em>.
The intent of this hierarchy is to both provide an easily expanded method of
adding new actions, but an easily specified list of actions for a particular
run of <em>pyWeb</em>.

<h5>Usage</h5>
<p>The overall process of the application is defined by an instance of <span class="code">Action</span>.
This instance may be the <span class="code">WeaveAction</span> instance, the <span class="code">TangleAction</span> instance
or a <span class="code">ActionSequence</span> instance.
</p>
<p>The instance is constructed during parsing of the input parameters.  Then the 
<span class="code">Action</span> class <span class="code">perform()</span> method is called to actually perform the
action.  There are three standard <span class="code">Action</span> instances available: an instance
that is a macro and does both tangling and weaving, an instance that excludes tangling,
and an instance that excludes weaving.  These correspond to the command-line options.
</p>
<pre>
anOp= SomeAction( <i>parameters</i> )
anOp.options= <i>parsed options</i>
anOp.web = <i>Current web</i>
anOp()
</pre>

<h5>Design</h5>
<p>The <span class="code">Action</span> is the superclass for all actions.</p>
<p>An <span class="code">Action</span> has a number of common attributes.</p>
<ul>
<li><span class="code">name</span> A name for this action.</li>
<li><span class="code">Options</span> The <span class="code">optparse</span> options object.</li>
<li><span class="code">web</span> The current web that's being processed.</li>
<li><span class="code">start</span> The time at which the action started.</li>
</ul>

<h5>Implementation</h5>

@d Action superclass... 
@{
class Action( object ):
    """An action performed by pyWeb."""
    def __init__( self, name ):
        self.name= name
        self.web= None
        self.start= None
    def __str__( self ):
        return "%s [%s]" % ( self.name, self.web )
    @<Action call method actually performs the action@>
    @<Action final summary method@>
@| Action
@}

<p>The <span class="code">__call__()</span> method does the real work of the action.
For the superclass, it merely logs a message.  This is overridden 
by a subclass.</p>
@d Action call... 
@{
def __call__( self ):
    logger.info( "Starting %s", self )
    self.start= time.clock()
@| perform
@}

<p>The <span class="code">summary()</span> method returns some basic processing
statistics for this action.
</p>
@d Action final... @{
def duration( self ):
    """Return duration of the action."""
    return (self.start and time.clock()-self.start) or 0
def summary( self, *args ):
    return "%s in %0.1f sec." % ( self.name, self.duration() )
@| duration summary
@}

<h4>ActionSequence Class</h4>
<p>A <span class="code">ActionSequence</span> defines a composite action; it is a sequence of
other actions.  When the macro is performed, it delegates to the 
sub-actions.</p>

<h5>Usage</h5>
<p>The instance is created during parsing of input parameters.  An instance of
this class is one of
the three standard actions available; it generally is the default, "do everything" 
action.</p>

<h5>Design</h5>
<p>This class overrides the <span class="code">perform()</span> method of the superclass.  It also adds
an <span class="code">append()</span> method that is used to construct the sequence of actions.
</p>
<h5>Implementation</h5>

@d ActionSequence subclass... 
@{
class ActionSequence( Action ):
    """An action composed of a sequence of other actions."""
    def __init__( self, name, opSequence=None ):
        super( ActionSequence, self ).__init__( name )
        if opSequence: self.opSequence= opSequence
        else: self.opSequence= []
    def __str__( self ):
        return "; ".join( [ str(x) for x in self.opSequence ] )
    @<ActionSequence call method delegates the sequence of ations@>
    @<ActionSequence append adds a new action to the sequence@>
    @<ActionSequence summary summarizes each step@>
@| ActionSequence
@}

<p>Since the macro <span class="code">__call__()</span> method delegates to other Actions,
it is possible to short-cut argument processing by using the Python
<tt>*args</tt> construct to accept all arguments and pass them to each
sub-action.</p>

@d ActionSequence call... 
@{
def __call__( self ):
    for o in self.opSequence:
        o.web= self.web
        o()
@| perform
@}

<p>Since this class is essentially a wrapper around the built-in sequence type, 
we delegate sequence related actions directly to the underlying sequence.</p>

@d ActionSequence append... @{
def append( self, anAction ):
    self.opSequence.append( anAction )
@| append
@}

<p>The <span class="code">summary()</span> method returns some basic processing
statistics for each step of this action.
</p>
@d ActionSequence summary... @{
def summary( self, *args ):
    return ", ".join( [ x.summary(*args) for x in self.opSequence ] )
@| summary
@}

<h4>WeaveAction Class</h4>
<p>The <span class="code">WeaveAction</span> defines the action of weaving.  This action
logs a message, and invokes the <span class="code">weave()</span> method of the <span class="code">Web</span> instance.
This method also includes the basic decision on which weaver to use.  If a <span class="code">Weaver</span> was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.
</p>

<h5>Usage</h5>
<p>An instance is created during parsing of input parameters.  The instance of this 
class is one of
the standard actions available; it is the "exclude tangling" option and it is
also an element of the "do everything" macro.</p>

<h5>Design</h5>
<p>This class overrides the <span class="code">perform()</span> method of the superclass.
</p>
<h5>Implementation</h5>

@d WeaveAction subclass... @{
class WeaveAction( Action ):
    """An action that weaves a document."""
    def __init__( self ):
        super(WeaveAction, self).__init__( "Weave" )
        self.theWeaver= None
    def __str__( self ):
        return "%s [%s, %s]" % ( self.name, self.web, self.theWeaver )

    @<WeaveAction call method does weaving of the document file@>
    @<WeaveAction summary method provides line counts@>
@| WeaveAction
@}

<a name="pick_language"></a>
<p>The language is picked just prior to weaving.  It is either (1) the language
specified on the command line, or, (2) if no language was specified, a language
is selected based on the first few characters of the input.</p>
<p>Weaving can only raise an exception when there is a reference to a chunk that
is never defined.</p>

@d WeaveAction call... @{
def __call__( self ):
    super( WeaveAction, self ).__call__()
    if not self.theWeaver: 
        # Examine first few chars of first chunk of web to determine language
        self.theWeaver= self.web.language() 
    try:
        self.web.weave( self.theWeaver )
    except Error,e:
        logger.error(
            "Problems weaving document from %s (weave file is faulty).",
            self.web.webFileName )
        raise
@| perform
@}

<p>The <span class="code">summary()</span> method returns some basic processing
statistics for the weave action.
</p>
@d WeaveAction summary... @{
def summary( self, *args ):
    if self.theWeaver and self.theWeaver.linesWritten > 0:
        return "%s %d lines in %0.1f sec." % ( self.name, self.theWeaver.linesWritten, self.duration() )
    return "did not %s" % ( self.name, )
@| summary
@}

<h4>TangleAction Class</h4>
<p>The <span class="code">TangleAction</span> defines the action of tangling.  This operation
logs a message, and invokes the <span class="code">weave()</span> method of the <span class="code">Web</span> instance.
This method also includes the basic decision on which weaver to use.  If a <span class="code">Weaver</span> was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.
</p>

<h5>Usage</h5>
<p>An instance is created during parsing of input parameters.  The instance of this 
class is one of
the standard actions available; it is the "exclude weaving" option, and it is
also an element of the "do everything" macro.</p>

<h5>Design</h5>
<p>This class overrides the <span class="code">perform()</span> method of the superclass.
</p>
<h5>Implementation</h5>

@d TangleAction subclass... @{
class TangleAction( Action ):
    """An action that weaves a document."""
    def __init__( self ):
        super( TangleAction, self ).__init__( "Tangle" )
        self.theTangler= None
    @<TangleAction call method does tangling of the output files@>
    @<TangleAction summary method provides total lines tangled@>
@| TangleAction
@}

<p>Tangling can only raise an exception when a cross reference request (<tt>@@f</tt>, <tt>@@m</tt> or <tt>@@u</tt>)
occurs in a program code chunk.  Program code chunks are defined 
with any of <tt>@@d</tt> or <tt>@@o</tt>  and use <tt>@@{</tt> <tt>@@}</tt> brackets.
</p>

@d TangleAction call... @{
def __call__( self ):
    super( TangleAction, self ).__call__()
    try:
        self.web.tangle( self.theTangler )
    except Error,e:
        logger.error( 
            "Problems tangling outputs from %s (tangle files are faulty).",
            self.web.webFileName )
        raise
@| perform
@}

<p>The <span class="code">summary()</span> method returns some basic processing
statistics for the tangle action.
</p>
@d TangleAction summary... @{
def summary( self, *args ):
    if self.theTangler and self.theTangler.linesWritten > 0:
        return "%s %d lines in %0.1f sec." % ( self.name, self.theTangler.linesWritten, self.duration() )
    return "did not %s" % ( self.name, )
@| summary
@}


<h4>LoadAction Class</h4>
<p>The <span class="code">LoadAction</span> defines the action of loading the web structure.  This action
uses the application's <tt>webReader</tt> to actually do the load.
</p>

<h5>Usage</h5>
<p>An instance is created during parsing of the input parameters.  An instance of
this class is part of any of the weave, tangle and "do everything" action.</p>

<h5>Design</h5>
<p>This class overrides the <span class="code">perform()</span> method of the superclass.
</p>
<h5>Implementation</h5>

@d LoadAction subclass... @{
class LoadAction( Action ):
    """An action that loads the source web for a document."""
    def __init__( self ):
        super( LoadAction, self ).__init__( "Load" )
        self.web= None
        self.webReader= None
    def __str__( self ):
        return "Load [%s, %s]" % ( self.webReader, self.web )
    @<LoadAction call method loads the input files@>
    @<LoadAction summary provides lines read@>
@| LoadAction
@}

<p>Trying to load the web involves two steps, either of which can raise 
exceptions due to incorrect inputs.</p>
<ul>
<li>The <span class="code">WebReader</span> class <span class="code">load()</span> method can raise exceptions for a number of 
syntax errors.
    <ul>
    <li>Missing closing brackets (<tt>@@}</tt>, @@] or <tt>@@&gt;</tt>).</li>
    <li>Missing opening bracket (<tt>@@{</tt> or <tt>@@[</tt>) after a chunk name (<tt>@@d</tt> or <tt>@@o</tt>).</li>
    <li>Extra brackets (<tt>@@{</tt>, <tt>@@[</tt>, <tt>@@}</tt>, <tt>@@]</tt>).</li>
    <li>Extra <tt>@@|</tt>.</li>
    <li>The input file does not exist or is not readable.</li>
    </ul></li>
<li>The <span class="code">Web</span> class <span class="code">createUsedBy()</span> method can raise an exception when a 
chunk reference cannot be resolved to a named chunk.</li>
</ul>

@d LoadAction call... @{
def __call__( self ):
    super( LoadAction, self ).__call__()
    try:
        self.webReader.web(self.web).load()
        self.web.createUsedBy()
    except (Error,IOError),e:
        logger.error(
            "Problems with source file %s, no output produced.",
            self.web.webFileName )
        raise
@| perform
@}

<p>The <span class="code">summary()</span> method returns some basic processing
statistics for the load action.
</p>
@d LoadAction summary... @{
def summary( self, *args ):
    return "%s %d lines from %d files in %01.f sec." % ( 
        self.name, self.webReader.totalLines, 
        self.webReader.totalFiles, self.duration() )
@| summary
@}


<a name="module"></a><h2>Module Components</h2>

<h3>Globals</h3>
<p>It's convenient for a module, as a whole, to have a master logger.
Individual classes may also have loggers, but it's helpful to have 
a global, default, logger.
</p>

@d Module Initialization of global variables
@{
import logging
logger= logging.getLogger( "pyweb" )
@}

<p>Additionally, the global list of weavers will be used by the
Application.
</p>

@d Module Initialization... 
@{
# Module global list of available weavers.
weavers = {
    'html':  HTML(),
    'htmls': HTMLShort(),
    'latex': LaTeX(),
    'rst': Weaver(), # Generic Weaver produces RST.
}
@}


<a name="mod"></a><h3><em>pyWeb</em> Module File</h3>

<p>The <em>pyWeb</em> application file is shown below:</p>

@o pyweb.py 
@{@<Overheads@>
@<Imports@>
@<Base Class Definitions@>
@<Application Class@>
@<Module Initialization of global variables@>
@<Interface Functions@>
@}

<p>The overhead elements are described in separate sub sections as follows:</p>
<ul>
<li>shell escape</li>
<li>from future imports</li>
<li>doc string</li>
<li>CVS cruft</li>
<li>imports</li>
</ul>
<p>The more important elements are described in separate sections:</p>
<ul>
<li>Base Class Definitions</li>
<li>Application Class and Main Functions</li>
<li>Module Initialization</li>
<li>Interface Functions</li>
</ul>

<h4>Python Library Imports</h4>

<p>The following Python library modules are used by this application.</p>
<ul>
<li>The <span class="code">sys</span> module provides access to the command line arguments.</li>
<li>The <span class="code">os</span> module provide os-specific file and path manipulations; it is used
to transform the input file name into the output file name as well as track down file modification
times.</li>
<li>The <span class="code">re</span> module provides regular expressions; these are used to 
parse the input file.</li>
<li>The <span class="code">time</span> module provides a handy current-time string; this is used
to by the HTML Weaver to write a closing timestamp on generated HTML files, 
as well as log messages.</li>
</ul>

@d Imports
@{import sys
import os
import re
import time
@| sys os re time
@}

<h4>Overheads</h4>

<p>The shell escape is provided so that the user can define this
file as executable, and launch it directly from their shell.
The shell reads the first line of a file; when it finds the <tt>'#!'</tt> shell
escape, the remainder of the line is taken as the path to the binary program
that should be run.  The shell runs this binary, providing the 
file as standard input.
</p>

@d Overheads
@{#!/usr/bin/env python
@}

<p>The from-future imports allow us to get ready for Python 3.0 compatibility.
They also limit us to version of Python that support these <tt>__future__</tt>
modules.  That means at least Python 2.6.</p>

@d Overheads
@{from __future__ import print_function
@}

<p>A Python <tt>__doc__</tt> string provides a standard vehicle for documenting
the module or the application program.  The usual style is to provide
a one-sentence summary on the first line.  This is followed by more 
detailed usage information.
</p>

@d Overheads 
@{"""pyWeb Literate Programming - tangle and weave tool.

Yet another simple literate programming tool derived from nuweb, 
implemented entirely in Python.  
This produces any markup for any programming language.

Usage:
    pyweb.py [-dvs] [-c x] [-w format] file.w

Options:
    -v           verbose output (the default)
    -s           silent output
    -d           debugging output
    -c x         change the command character from '@@' to x
    -w format    Use the given weaver for the final document.
                 The default is based on the input file, a leading '<'
                 indicates HTML, otherwise LaTeX.
                 choices are 'html', 'latex', 'rst'.
    -xw          Exclude weaving
    -xt          Exclude tangling
    -pi          Permit include-command errors
    
    file.w       The input file, with @@o, @@d, @@i, @@[, @@{, @@|, @@<, @@f, @@m, @@u commands.
"""
@}

<p>The keyword cruft is a standard way of placing version control information into
a Python module so it is preserved.  See PEP (Python Enhancement Proposal) #8 for information
on recommended styles.
</p>

<p>We also sneak in a "DO NOT EDIT" warning that belongs in all generated application 
source files.</p>

@d Overheads
@{__version__ = """$Revision$"""

### DO NOT EDIT THIS FILE!
### It was created by @(thisApplication@), __version__='@(__version__@)'.
### From source @(theFile@) modified @(time.ctime(os.path.getmtime(theFile))@).
### In working directory '@(os.getcwd()@)'.
@| __version__ @}


<a name="app"></a><h3>The Application Class</h3>

<h4>Design</h4>

<p>The <span class="code">Application</span> class is provided so that the <span class="code">Action</span> instances
have an overall application to update.  This allows the <span class="code">WeaveAction</span> to 
provide the selected <span class="code">Weaver</span> instance to the application.  It also provides a
central location for the various options and alternatives that might be accepted from
the command line.
</p>

<p>The constructor sets the default options for weaving and tangling.</p>

<p>The <span class="code">parseArgs()</span> method uses the <tt>sys.argv</tt> sequence to 
parse the command line arguments and update the options.  This allows a
program to pre-process the arguments, passing other arguments to this module.
</p>

<p>The <span class="code">process()</span> method processes a list of files.  This is either
the list of files passed as an argument, or it is the list of files
parsed by the <span class="code">parseArgs()</span> method.
</p>

<p>The <span class="code">parseArgs()</span> and </b>process()</b> functions are separated so that
another application can <tt>import pyweb</tt>, bypass command-line parsing, yet still perform
the basic actionss simply and consistently.</p>
<p>For example:</p>
<pre>
import pyweb, optparse
p= optparse.OptionParser()
<i>option definition</i>
options, args = p.parse_args()
a= pyweb.Application( <i>My Emitter Factory</i> )
<i>Configure the Application based on options</i>
a.process( args )
</pre>

<p>The <span class="code">main()</span> function creates an <span class="code">Application</span> instance and
calls the <span class="code">parseArgs()</span> and <span class="code">process()</span> methods to provide the
expected default behavior for this module when it is used as the main program.
</p>

<h4>Implementation</h4>

@d Imports...
@{import optparse
@| optparse
@}

@d Application Class 
@{
class Application( object ):
    def __init__( self ):
        @<Application default options@>
    @<Application parse command line@>
    @<Application class process all files@>
@| Application
@}

<p><a name="log_setting"></a>
The first part of parsing the command line is 
setting default values that apply when parameters are omitted.
The default values are set as follows:
</p>
<ul>
<li><i>theTangler</i> is set to a <span class="code">TanglerMake</span> instance 
to create the output files.</li>
<li><i>theWeaver</i> is set to <span class="code">None</span> so that the input
language will be used to select an appropriate weaver.</li>
<li><i>commandChar</i> is set to <b><tt>@@</tt></b> as the 
default command introducer.</li>
<li><i>doWeave</i> and </i>doTangle</i> are instances of <span class="code">Action</span>
that describe two use cases: Tangle only and Weave only.</li>
<li><i>theAction</i> is an instance of <span class="code">Action</span> that describes
the default overall action: load, tangle and weave.  This is the default unless
overridden by an option.</li>
<li><i>permitList</i> provides a list of commands that are permitted
to fail.  Typically this is empty, or contains @@i to allow the include
command to fail.</li>
<li><i>files</i> is the final list of argument files from the command line; 
these will be processed unless overridden in the call to <span class="code">process()</span>.</li>
<li><i>webReader</i> is the <span class="code">WebReader</span> instance created for the current
input file.</i>
</ul>

@d Application default options...
@{
self.theTangler= TanglerMake()
self.theWeaver= None
self.permitList= []
self.commandChar= '@@'
self.loadOp= LoadAction()
self.weaveOp= WeaveAction()
self.tangleOp= TangleAction()
self.doWeave= ActionSequence( "load and weave", [self.loadOp, self.weaveOp] )
self.doTangle= ActionSequence( "load and tangle", [self.loadOp, self.tangleOp] )
self.theAction= ActionSequence( "load, tangle and weave", [self.loadOp, self.tangleOp, self.weaveOp] )
self.files= []
@}

<p>The algorithm for parsing the command line parameters uses the built in
<span class="code">optparse</span> module.  We have to build a parser, define the options,
provide default values, and the parse the command-line arguments.
</p>
@d Application parse command line...
@{
def parseArgs( self ):
    p = optparse.OptionParser()
    p.add_option( "-v", "--verbose", dest="verbosity", action="store_const", const=logging.INFO )
    p.add_option( "-s", "--silent", dest="verbosity", action="store_const", const=logging.WARN )
    p.add_option( "-d", "--debug", dest="verbosity", action="store_const", const=logging.DEBUG )
    p.add_option( "-c", "--command", dest="command", action="store" )
    p.add_option( "-w", "--weaver", dest="weaver", action="store" )
    p.add_option( "-x", "--except", dest="skip", action="store" )
    p.add_option( "-p", "--permit", dest="permit", action="store" )
    opts, self.files= p.parse_args()
    if opts.command:
        logger.info( "Setting command character to %r", opts.command )
        self.commandChar= opts.command
    if opts.weaver:
        self.theWeaver= weavers[ opts.weaver ]
        logger.info( "Setting weaver to %s", self.theWeaver )
    if opts.skip:
        if opts.skip.lower().startswith('w'): # skip weaving
            self.theAction= self.doTangle
        elif opts.skip.lower().startswith('t'): # skip tangling
            self.theAction= self.doWeave
        else:
            raise Exception( "Unknown -x option %r" % opts.skip )
    if opts.permit:
        # save permitted errors, usual case is -pi to permit include errors
        self.permitList= [ '%s%s' % ( commandChar, c ) for c in opts.permit ]
    if opts.verbosity:
        logger.setLevel( opts.verbosity )
    self.options= opts

@| parseArgs
@}

<p>The <span class="code">process()</span> function uses the current <span class="code">Application</span> settings
to process each file as follows:</p>
<ol>
<li>Create a new <span class="code">WebReader</span> for the <span class="code">Application</span>, providing
the parameters required to process the input file.</li>
<li>Create a <span class="code">Web</span> instance, <i>w</i> 
and set the Web's <i>sourceFileName</i> from the WebReader's <i>fileName</i>.</i>
<li>Perform the given command, typically a <span class="code">ActionSequence</span>, 
which does some combination of load, tangle the output files and
weave the final document in the target language; if
necessary, examine the <span class="code">Web</span> to determine the documentation language.</li>
<li>Print a performance summary line that shows lines processed per second.</li>
</ol>

<p>In the event of failure in any of the major processing steps, 
a summary message is produced, to clarify the state of 
the output files, and the exception is reraised.
The re-raising is done so that all exceptions are handled by the 
outermost main program.</p>

@d Application class process all...
@{
def process( self, theFiles=None ):
    self.weaveOp.theWeaver= self.theWeaver
    self.tangleOp.theTangler= self.theTangler
    for f in theFiles or self.files:
        w= Web( f ) # A web to work on.
        try:
            with open(f,"r") as source:
                logger.info( "Reading %r", f )
                webReader= WebReader( command=self.commandChar, permit=self.permitList )
                webReader.source( f, source ).web( w )
                self.loadOp.webReader= webReader
                self.theAction.web= w
                self.theAction()
        except Error,e:
            logger.exception( e )
        except IOError,e:
            logger.exception( e )
        logger.info( 'pyWeb: %s', self.theAction.summary(w,self) )
@| process
@}

<a name="interface"></a><h3>The Main Function</h3>

<p>The top-level interface is the <span class="code">main()</span> function.
This function creates an <span class="code">Application</span> instance.
</p>
<p>The <span class="code">Application</span> object parses the command-line arguments.
Then the <span class="code">Application</span> object does the requested processing.
This two-step process allows for some dependency injection to customize argument processing.
</p>

@d Interface Functions...
@{
def main():
    logging.basicConfig( stream=sys.stderr, level=logging.INFO )
    logging.getLogger( "pyweb.TanglerMake" ).setLevel( logging.WARN )
    logging.getLogger( "pyweb.WebReader" ).setLevel( logging.WARN )
    a= Application()
    a.parseArgs()
    a.process()
    logging.shutdown()

if __name__ == "__main__":
    main( )
@| main @}

<p>This can be extended by doing something like the following.</p>

<ul>
<li>Subclass <span class="code">Weaver</span> create a subclass with different templates.</li>
<li>Update the <tt>pyweb.weavers</tt> dictionary.</li>
<li>Call <tt>pyweb.main()</tt> to run the existing
main program with extra classes available to it.</li>
</ul>
<code><pre>
import pyweb
class MyWeaver( HTML ):
     <i>Any template changes</i>
     
pyweb.weavers['myweaver']= MyWeaver()
pyweb.main()
</pre></code>

<p>This will create a variant on <i>pyWeb</i> that will handle a different
weaver via the command-line option <tt>-w myweaver</tt>.</p>

<a name="scripts"></a><h2>Additional Scripts</h2>
<p>Two aditional scripts are provided as examples 
which an be customized.</p>

<h3><tt>tangle.py</tt> Script</h3>
<p>This script shows a simple version of Tangling.  This has a permitted 
error for '@@i' commands to allow an include file (for example test results)
to be omitted from the tangle operation.
</p>

@o tangle.py 
@{#!/usr/bin/env python
"""Sample tangle.py script."""
import pyweb
import logging, sys

logging.basicConfig( stream=sys.stderr, level=logging.INFO )
logger= logging.getLogger(__file__)

w= pyweb.Web( "pyweb.w" ) # The web we'll work on.

permitList= ['@@i']
commandChar= '@@'
load= pyweb.LoadAction()
load.webReader= pyweb.WebReader( command=commandChar, permit=permitList )
load.webReader.web( w ).source( "pyweb.w" )
load.web= w
load()
logger.info( load.summary() )

tangle= pyweb.TangleAction()
tangle.theTangler= pyweb.TanglerMake()
tangle.web= w
tangle()
logger.info( tangle.summary() )
@}

<h3><tt>weave.py</tt> Script</h3>
<p>This script shows a simple version of Weaving.  This shows how
to define a customized set of templates for a different markup language.
</p>

<p>A customized weaver generally has three parts.</p>

@o weave.py
@{@<weave.py overheads for correct operation of a script@>
@<weave.py weaver definition to customize the Weaver being used@>
@<weaver.py actions to load and weave the document@>
@}

@d weave.py overheads...
@{#!/usr/bin/env python
"""Sample weave.py script."""
import pyweb
import logging, sys, string

logging.basicConfig( stream=sys.stderr, level=logging.INFO )
logger= logging.getLogger(__file__)
@}

@d weave.py weaver definition...
@{
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
@}

@d weaver.py actions...
@{
w= pyweb.Web( "pyweb.w" ) # The web we'll work on.

permitList= []
commandChar= '@@'
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
@}

<a name="admin"></a><h2>Administrative Elements</h2>
<p>In order to support a pleasant installation, the <tt>setup.py</tt> file is helpful.</p>

@o setup.py 
@{#!/usr/bin/env python
"""Setup for pyWeb."""

from distutils.core import setup

setup(name='pyweb',
      version='2.1',
      description='pyWeb 2.1: In Python, Yet Another Literate Programming Tool',
      author='S. Lott',
      author_email='s_lott@@yahoo.com',
      url='http://slott-softwarearchitect.blogspot.com/',
      py_modules=['pyweb'],
      classifiers=[
      'Intended Audience :: Developers',
      'Topic :: Documentation',
      'Topic :: Software Development :: Documentation', 
      'Topic :: Text Processing :: Markup',
      ]
   )
@}

<p>In order build a source distribution kit the <tt>setup.py sdist</tt> requires a
<tt>MANIFEST</tt>.  We can either list all files or provide a   <tt>MANIFEST.in</tt>
that specifies additional rules.
We use a simple inclusion to augment the default manifest rules.
</p>

@o MANIFEST.in
@{include *.w *.css *.html
include test/*.w test/*.css test/*.html test/*.py
@}

<p>Generally, a <tt>README</tt> is also considered to be good form.</p>

@o README
@{pyWeb 2.1: In Python, Yet Another Literate Programming Tool

Literate programming is an attempt to reconcile the opposing needs
of clear presentation to people with the technical issues of 
creating code that will work with our current set of tools.

Presentation to people requires extensive and sophisticated typesetting
techniques.  Further, the "narrative arc" of a presentation may not 
follow the source code as layed out for the compiler.

pyWeb is a literate programming tool that combines the actions
of weaving a document with tangling source files.
It is independent of any particular document markup or source language.
Is uses a simple set of markup tags to define chunks of code and 
documentation.

The pyweb.w file is the source for the various pyweb module and script files, plus
the pyweb.html file.  The various source code files are created by applying a 
tangle operation to the .w file.  The final documentation is created by
applying a weave operation to the .w file.

Installation
-------------

::

    python setup.py install

This will install the pyweb module.  

Authoring
---------

The pyweb document describes the simple markup used to define code chunks
and assemble those code chunks into a coherent document as well as working code.

Operation
---------

You can then run pyweb with

::

    python -m pyweb pyweb.w 

This will create the various output files from the source .w file.

-   pyweb.html is the final woven document.

-   pyweb.py, tangle.py, weave.py, readme, setup.py and MANIFEST.in are tangled output files.

Testing
-------

The test directory includes pyweb_test.w, which will create a 
complete test suite.

This weaves a pyweb_test.html file.

This tangles several test modules:  test.py, test_tangler.py, test_weaver.py,
test_loader.py and test_unit.py.  Running the test.py module will include and
execute all 71 tests.

@}