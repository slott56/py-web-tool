.. pyweb/impl.w

Implementation
==============

The implementation is contained in a file that both defines
the base classes and provides an overall ``main()`` function.  The ``main()``
function uses these base classes to weave and tangle the output files.

The broad outline of the presentation is as follows:

-   `Base Class Definitions`_ is largely an overview of the important features.

-   `Emitters`_ write various kinds of files. We'll present this first because
    the output shapes other parts of what the program does.

-   `Chunks`_ are pieces of the source document, built into a Web.

-   `Commands`_ are the items within a ``Chunk``.

-   `The Web and WebReader Classes`_ includes the web and the parser which produces a web.

    -   `The WebReader class`_ which parses the Web structure.
    
    -   `The Tokenizer class`_ which tokenizes the raw input.
    
    -   `The Option Parser Class`_ which tokenizes just the arguments to ``@@d`` and ``@@o``
        commands.
    
-   `Error class`_ defines an application-specific Error.

-   `Reference Strategy`_ defines ways to manage cross-references among chunks.
    These support the ``Weaver`` subclasses of the ``Emitters``.

-   `Action class hierarchy`_ defines things this program does.

-   `pyWeb Module File`_ defines the final module file that's created.

-   `The Application class`_. This is an overall class definition that includes
    command line parsing, picking an Action, configuring and executing the Action.
    It could be a set of related functions, but we've bound them into a class.

-   `Logging setup`_. This includes a simple context manager for logging.

-   `The Main Function`_.


Base Class Definitions
----------------------

There are the core classes that define the enduring application objects. These form
fairly complex hierarchies.

-   **Commands**. A ``Command`` contains user input and creates output.  
    This can be a block of text from the input file, 
    one of the various kinds of cross reference commands (``@@f``, ``@@m``, or ``@@u``) 
    or a reference to a chunk (via the ``@@<``\ *name*\ ``@@>`` sequence.)

-   **Chunks**. A ``Chunk`` is a collection of ``Command`` instances.  This can be
    either an anonymous chunk that will be sent directly to the output, 
    or one the classes of named chunks delimited by the
    structural ``@@d`` or ``@@o`` commands.

There are classes for reading the input. These don't form a complex hierarchy.

The ``Web`` as a whole is a collection of ``Chunk`` instances. It's built by 
a ``WebReader`` which uses a ``Tokenizer``.

There is a hierarchy for the various kinds of output.

-   **Emitters**. An ``Emitter`` creates an output file, either tangled code or some kind of markup from
    the chunks that make up the source file.  Two major subclasses are the ``Weaver``, which 
    has a focus on markup output, and ``Tangler`` which has a focus on pure source output.

    We have further specialization of the weavers for RST,  HTML or LaTeX. The issue is
    generating proper markup to surround the code and include cross-references among code
    blocks. A number of simple templates are used for this.

-   **Reference Strategy**. We can have references resolved transitively or simply. A transitive
    reference becomes a list of parent ``@@d`` ``NamedChunk`` instances.

Hovering at the edge of the base class definitions is the Action Class Hierarchy.
It's not an essential part of the base class definitions. But it doesn't seem to
fit elsewhere

@d Base Class Definitions 
@{
@<Error class - defines the errors raised@>
@<Command class hierarchy - used to describe individual commands@>
@<Chunk class hierarchy - used to describe input chunks@>
@<Web class - describes the overall "web" of chunks@>
@<Tokenizer class - breaks input into tokens@>
@<Option Parser class - locates optional values on commands@>
@<WebReader class - parses the input file, building the Web structure@>
@<Emitter class hierarchy - used to control output files@>
@<Reference class hierarchy - strategies for references to a chunk@> 

@<Action class hierarchy - used to describe basic actions of the application@>
@}

Emitters
---------

An ``Emitter`` instance is resposible for control of an output file format.
This includes the necessary file naming, opening, writing and closing operations.
It also includes providing the correct markup for the file type.

There are several subclasses of the ``Emitter`` superclass, specialized for various file
formats.

@d Emitter class hierarchy...
@{
@<Emitter superclass@>
@<Weaver subclass of Emitter to create documentation@>
@<RST subclass of Weaver@>
@<LaTeX subclass of Weaver@>
@<HTML subclass of Weaver@>
@<Tangler subclass of Emitter to create source files with no markup@>
@<TanglerMake subclass which is make-sensitive@>
@}

An ``Emitter`` instance is created to contain the various details of
writing an output file.  Emitters are created as follows:

-   A ``Web`` object will create a ``Weaver`` to **weave** the final document.

-   A ``Web`` object will create a ``Tangler`` to **tangle** each file.

Since each ``Emitter`` instance is responsible for the details of one file
type, different subclasses of ``Emitter`` are used when tangling source code files 
(``Tangler``) and 
weaving files that include source code plus markup (``Weaver``).

Further specialization is required when weaving HTML or LaTeX.  Generally, this is 
a matter of providing three things:

-   Boilerplate text to replace various **py-web-tool** constructs,

-   Escape rules to make source code amenable to the markup language,

-   A header to provide overall includes or other setup.


An additional part of the escape rules can include using a syntax coloring 
toolset instead of simply applying escapes.

In the case of **tangle**, the following algorithm is used:

    Visit each each output ``Chunk`` (``@@o``), doing the following:
    
    1.  Open the ``Tangler`` instance using the target file name.

    2.  Visit each ``Chunk`` directed to the file, calling the chunk's ``tangle()`` method.
        
        1.  Call the Tangler's ``docBegin()`` method.  This sets the Tangler's indents.

        2.  Visit each ``Command``, call the command's ``tangle()`` method.  
            For the text of the chunk, the
            text is written to the tangler using the ``codeBlock()`` method.  For
            references to other chunks, the referenced chunk is tangled using the 
            referenced chunk's ``tangler()`` method.

        3.  Call the Tangler's ``docEnd()`` method.  This clears the Tangler's indents.


In the case of **weave**, the following algorithm is used:

    1.  Open the ``Weaver`` instance using the source file name.  This name is transformed
        by the weaver to an output file name appropriate to the language.

    2.  Visit each each sequential ``Chunk`` (anonymous, ``@@d`` or ``@@o``), doing the following:

        1.  Visit each ``Chunk``, calling the Chunk's ``weave()`` method.
        
            1.  Call the Weaver's ``docBegin()``, ``fileBegin()`` or ``codeBegin()`` method, 
                depending on the subclass of Chunk.  For 
                ``fileBegin()`` and ``codeBegin()``, this writes the header for
                a code chunk in the weaver's markup language.  

            2.  Visit each ``Command``, call the Command's ``weave()`` method.  
                For ordinary text, the
                text is written to the Weaver using the ``codeBlock()`` method.  For
                references to other chunks, the referenced chunk is woven using 
                the Weaver's ``referenceTo()`` method.

            3.  Call the Weaver's ``docEnd()``, ``fileEnd()`` or ``codeEnd()`` method.  
                For ``fileEnd()`` or ``codeEnd()``, this writes a trailer for
                a code chunk in the Weaver's markup language.


Emitter Superclass
~~~~~~~~~~~~~~~~~~

The ``Emitter`` class is not a concrete class; it is never instantiated.  It
contains common features factored out of the ``Weaver`` and ``Tangler`` subclasses.

Inheriting from the Emitter class generally requires overriding one or more
of the core methods: ``doOpen()``, and ``doClose()``.
A subclass of Tangler, might override the code writing methods: 
``quote()``, ``codeBlock()`` or ``codeFinish()``.

The ``Emitter`` class defines the basic
framework used to create and write to an output file.
This class follows the **Template** design pattern.  This design pattern
directs us to factor the basic open(), close() and write() methods into two step algorithms.

..  parsed-literal::

    def open(self) -> "Emitter":
        *common preparation*
        self.doOpen() *#overridden by subclasses*
        return self

The *common preparation* section is generally internal 
housekeeping.  The ``doOpen()`` method would be overridden by subclasses to change the
basic behavior.

The class has the following attributes:

:fileName:
    the name of the current open file created by the
    open method

:theFile:
    the current open file created by the
    open method

:linesWritten:
    the total number of ``'\n'`` characters written to the file

:totalFiles:
    count of total number of files

:totalLines:
    count of total number of lines

Additionally, an emitter tracks an indentation context used by
The ``codeBlock()`` method to indent each line written.

:context:
    the indentation context stack, updated by ``addIndent()``, 
    ``clrIndent()`` and ``readdIndent()`` methods.
        
:lastIndent:
    the last indent used after writing a line of source code

:fragment:
    the last line written was a fragment and needs a ``'\n'``.

:code_indent:
    Any initial code indent. RST weavers needs additional code indentation.
    Other weavers don't care. Tanglers must have this set to zero.

@d Emitter superclass
@{
class Emitter:
    """Emit an output file; handling indentation context."""
    code_indent = 0 # Used by a Tangler
    
    theFile: TextIO
    def __init__(self) -> None:
        self.fileName = ""
        self.logger = logging.getLogger(self.__class__.__qualname__)
        self.log_indent = logging.getLogger("indent." + self.__class__.__qualname__)
        # Summary
        self.linesWritten = 0
        self.totalFiles = 0
        self.totalLines = 0
        # Working State
        self.lastIndent = 0
        self.fragment = False
        self.context: list[int] = []
        self.readdIndent(self.code_indent) # Create context and initial lastIndent values
        
    def __str__(self) -> str:
        return self.__class__.__name__
        
    @<Emitter core open, close and write@>
    @<Emitter write a block of code@>
    @<Emitter indent control: set, clear and reset@>
@| Emitter 
@}

The core ``open()`` method tracks the open files.
A subclass overrides a ``doOpen()`` method to name the output file, and
then actually open the file.  The Weaver will create an output file with
a name that's based on the overall project.  The Tangler will open the given file
name.

The ``close()`` method closes the file.  As with  ``open()``, a
``doClose()`` method actually closes the file.  This allows subclasses
to do overrides on the actual file processing.

The ``write()`` method is the lowest-level, unadorned write.
This does some additional counting as well as writing the
characters to the file.

@d Emitter core...
@{
def open(self, aFile: str) -> "Emitter":
    """Open a file."""
    self.fileName = aFile
    self.linesWritten = 0
    self.doOpen(aFile)
    return self
    
@<Emitter doOpen, to be overridden by subclasses@>

def close(self) -> None:
    self.codeFinish() # Trailing newline for tangler only.
    self.doClose()
    self.totalFiles += 1
    self.totalLines += self.linesWritten
    
@<Emitter doClose, to be overridden by subclasses@>

def write(self, text: str) -> None:
    if text is None: return
    self.linesWritten += text.count('\n')
    self.theFile.write(text)

# Context Manager Interface -- used by ``open()`` method
def __enter__(self) -> "Emitter":
    return self
def __exit__(self, *exc: Any) -> Literal[False]:
    self.close()
    return False
    
@| open close write
@}

The ``doOpen()``, and ``doClose()``
methods are overridden by the various subclasses to
perform the unique operation for the subclass.

@d Emitter doOpen... @{
def doOpen(self, aFile: str) -> None:
    self.logger.debug("creating %r", self.fileName)
@| doOpen
@}

@d Emitter doClose... @{
def doClose(self) -> None:
    self.logger.debug( 
        "wrote %d lines to %r", self.linesWritten, self.fileName
    )
@| doClose
@}

The ``codeBlock()`` method writes several lines of code.  It calls
the ``quote()`` method to quote each line of code after doing the correct indentation.
Often, the last line of code is incomplete, so it is left unterminated.
This last line of code also sets the indentation for any 
additional code to be tangled into this section.

..  important::

    Tab characters confuse the indent algorithm.  Tabs are 
    not expanded to spaces in this application.  They should be expanded 
    prior to creating a ``.w`` file.

The algorithm is as follows:

1.  Save the topmost value of the context stack as the current indent.

2.  Split the block of text on ``'\n'`` boundaries. 
    There are two cases.
    
    -   One line only, no newline. 
    
        Write this with the saved lastIndent. 
        The lastIndent is reset to zero since we've only written a fragmentary line.
    
    -   Multiple lines.

        1.  Write the first line with saved lastIndent.
        
        2.  For each remaining line (except the last), write with the indented text, 
            ending with a newline.
    
        #.  The string ``split()`` method will put a trailing 
            zero-length element in the list if the original block ended with a
            newline.  We drop this zero length piece to prevent writing a useless fragment 
            of indent-only after the final ``'\n'``.
      
        #.  If the last line has content: Write with the indented text, 
            but do not write a trailing ``'\n'``. Set lastIndent to zero because
            the next ``codeBlock()`` will continue this fragmentary line.
    
            If the last line has no content: Write nothing.
            Save the length of the last line as the most recent indent for any ``@@<``\ *name*\ ``@@>``
            reference to.

This feels a bit too complex. Indentation is a feature of a tangling a reference to 
a NamedChunk. It's not really a general feature of emitters or even tanglers.

@d Emitter write a block...
@{
def codeBlock(self, text: str) -> None:
    """Indented write of a block of code. We buffer
    The spaces from the last line to act as the indent for the next line.
    """
    indent = self.context[-1]
    lines = text.split('\n')
    if len(lines) == 1: 
        # Fragment with no newline.
        self.logger.debug("Fragment: %d, %r", self.lastIndent, lines[0])
        self.write(f"{self.lastIndent*' '!s}{lines[0]!s}")
        self.lastIndent = 0
        self.fragment = True
    else:
        # Multiple lines with one or more newlines.
        first, rest = lines[:1], lines[1:]
        self.logger.debug("First Line: %d, %r", self.lastIndent, first[0])
        self.write(f"{self.lastIndent*' '!s}{first[0]!s}\n")
        for l in rest[:-1]:
            self.logger.debug("Next Line: %d, %r", indent, l)
            self.write(f"{indent*' '!s}{l!s}\n")
        if rest[-1]:
            # Last line is non-empty.
            self.logger.debug("Last (Partial) Line: %d, %r", indent, rest[-1])
            self.write(f"{indent*' '!s}{rest[-1]!s}")
            self.lastIndent = 0
            self.fragment = True
        else:
            # Last line was empty, a trailing newline.
            self.logger.debug("Last (Empty) Line: indent is %d", len(rest[-1]) + indent)
            # Buffer a next indent
            self.lastIndent = len(rest[-1]) + indent
            self.fragment = False
@| codeBlock
@}

The ``quote()`` method quotes a single line of source code.
This is used by Weaver subclasses to transform source into
a form acceptable by the final weave file format.

In the case of an HTML weaver, the HTML reserved characters -- 
``<``, ``>``, ``&``, and ``"`` -- must be replaced in the output
of code with ``&lt;``, ``&gt;``, ``&amp;``, and ``&quot;``.  
However, since the author's original document sections contain
HTML these will not be altered.

@d Emitter write a block...
@{
quoted_chars: list[tuple[str, str]] = [
    # Must be empty for tangling.
]

def quote(self, aLine: str) -> str:
    """Each individual line of code; often overridden by weavers to quote the code."""
    clean = aLine
    for from_, to_ in self.quoted_chars:
        clean = clean.replace(from_, to_)
    return clean
@| quote
@}

The ``codeFinish()`` method handles a trailing fragmentary line when tangling.

@d Emitter write a block...
@{
def codeFinish(self) -> None:
    if self.fragment:
        self.write('\n')
@| codeFinish
@}

These three methods are used when to be sure that the included text is indented correctly with respect to the
surrounding text.

The ``addIndent()`` method pushes the next indent on the context stack
using an increment to the previous indent.

When tangling, a "previous" value is set from the indent left over from the
previous command. This allows ``@@<``\ *name*\ ``@@>`` references to be indented 
properly. A tangle must track all nested ``@@d`` contexts to create a proper
global indent.

Weaving, however, is entirely localized to the block of code. There's no 
real context tracking. Just "lastIndent" from the previous command's ``codeBlock()``.

The ``setIndent()`` pushes a fixed indent instead adding an increment.
    
The ``clrIndent()`` method discards the most recent indent from the context stack.  
This is used when finished
tangling a source chunk.  This restores the indent to the prevailing indent.

The ``readdIndent()`` method removes all indent context information and resets the indent
to a default.

Weaving may use an initial offset. 
It's an additional indent for woven code; not used for tangled code. In particular, RST
requires this. ``readdIndent()`` uses this initial offset for weaving.

@d Emitter indent control...
@{
def addIndent(self, increment: int) -> None:
    self.lastIndent = self.context[-1]+increment
    self.context.append(self.lastIndent)
    self.log_indent.debug("addIndent %d: %r", increment, self.context)
def setIndent(self, indent: int) -> None:
    self.context.append(indent)
    self.lastIndent = self.context[-1]
    self.log_indent.debug("setIndent %d: %r", indent, self.context)
def clrIndent(self) -> None:
    if len(self.context) > 1:
        self.context.pop()
    self.lastIndent = self.context[-1]
    self.log_indent.debug("clrIndent %r", self.context)
def readdIndent(self, indent: int = 0) -> None:
    """Resets the indentation context."""
    self.lastIndent = indent
    self.context = [self.lastIndent]
    self.log_indent.debug("readdIndent %d: %r", indent, self.context)
@| addIndent clrIndent readdIndent addIndent
@}

Weaver subclass of Emitter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Weaver is an Emitter that produces the final user-focused document.
This will include the source document with the code blocks surrounded by
markup to present that code properly.  In effect, the **py-web-tool**  ``@@`` commands
are replaced by markup.

The Weaver class uses a simple set of templates to product RST markup as the default
Subclasses can introduce other templates to produce HTML or LaTeX output.

Most Weaver languages don't rely on special indentation rules.
The woven code samples usually start right on the left margin of 
the source document.  However, the RST markup language does rely
on extra indentation of code blocks.  For that reason, the weavers
have an additional indent for code blocks.  This is generally 
set to zero, except when generating RST where 4 spaces is good.

The ``Weaver`` subclass extends an ``Emitter`` to **weave** the final
documentation.  This involves decorating source code to make it
displayable.  It also involves creating references and cross
references among the various chunks.

The ``Weaver`` class adds several methods to the basic ``Emitter`` methods.  These
additional methods are also included that are used exclusively when weaving, never when tangling.

This class hierarch depends heavily on the ``string`` module.

Class-level variables include the following

:extension:
    The filename extension used by this weaver.
    
:code_indent:
    The number of spaces to indent code to separate code blocks from
    surrounding text. Mostly this is used by RST where a non-zero value
    is required.
    
:header:
    Any additional header material this weaver requires.

Instance-level configuration values:

:reference_style:
    Either an instance of ``TransitiveReference()`` or ``SimpleReference()``
        
@d Imports
@{import string
@| string
@}

@d Weaver subclass of Emitter...
@{
class Weaver(Emitter):
    """Format various types of XRef's and code blocks when weaving.
    RST format. 
    Requires ``..  include:: <isoamsa.txt>``
    and      ``..  include:: <isopub.txt>``
    """
    extension = ".rst" 
    code_indent = 4
    header = """\n..  include:: <isoamsa.txt>\n..  include:: <isopub.txt>\n"""
    
    reference_style : "Reference"
    
    def __init__(self) -> None:
        super().__init__()
    
    @<Weaver doOpen, doClose and addIndent overrides@>
    
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

The ``doOpen()`` method opens the file for writing.  For weavers, the file extension
is specified part of the target markup language being created.

The ``doClose()`` method extends the ``Emitter`` class ``close()`` method by closing the
actual file created by the open() method.

The ``addIndent()`` reflects the fact that we're not tracking global indents, merely
the local indentation required to weave a code chunk. The "indent" can vary because
we're not always starting a fresh line with ``weaveReferenceTo()``.

@d Weaver doOpen...
@{
def doOpen(self, basename: str) -> None:
    self.fileName = basename + self.extension
    self.logger.info("Weaving %r", self.fileName)
    self.theFile = open(self.fileName, "w")
    self.readdIndent(self.code_indent)
def doClose(self) -> None:
    self.theFile.close()
    self.logger.info("Wrote %d lines to %r", self.linesWritten, self.fileName)
def addIndent(self, increment: int = 0) -> None:
    """increment not used when weaving"""
    self.context.append(self.context[-1])
    self.log_indent.debug("addIndent %d: %r", self.lastIndent, self.context)
def codeFinish(self) -> None:
    pass # Not needed when weaving
@| doOpen doClose addIndent codeFinish
@}

This is an overly simplistic list. We use the ``parsed-literal``
directive because we're including links and what-not in the code.
We have to quote certain inline markup -- but only when the
characters are paired in a way that might confuse RST.

We really should use patterns like ```.*?```, ``_.*?_``, ``\*.*?\*``, and ``\|.*?\|``
to look for paired RST inline markup and quote just these special character occurrences. 

@d Weaver quoted characters...
@{
quoted_chars: list[tuple[str, str]] = [
    # prevent some RST markup from being recognized
    ('\\',r'\\'), # Must be first.
    ('`',r'\`'),
    ('_',r'\_'), 
    ('*',r'\*'),
    ('|',r'\|'),
]
@}

The remaining methods apply a chunk to a template.

The ``docBegin()`` and ``docEnd()`` 
methods are used when weaving a document text chunk.
Typically, nothing is done before emitting these kinds of chunks.
However, putting a ``.. line line number`` RST comment is an example
of possible additional processing.


@d Weaver document...
@{
def docBegin(self, aChunk: Chunk) -> None:
    pass
def docEnd(self, aChunk: Chunk) -> None:
    pass
@| docBegin docEnd
@}

Each code chunk includes the places where the chunk is referenced.

..  note::

    This may be one of the rare places where ``for... else:`` could be the correct statement.
    
    Currently, something more complex is used.

@d Weaver reference summary...
@{
ref_template = string.Template("${refList}")
ref_separator = "; "
ref_item_template = string.Template("$fullName (`${seq}`_)")
def references(self, aChunk: Chunk) -> str:
    references = aChunk.references(self)
    if len(references) != 0:
        refList = [ 
            self.ref_item_template.substitute(seq=s, fullName=n)
            for n,s in references ]
        return self.ref_template.substitute(refList=self.ref_separator.join(refList))
    else:
        return ""
@| references
@}


The ``codeBegin()`` method emits the necessary material prior to 
a chunk of source code, defined with the ``@@d`` command.

The ``codeEnd()`` method emits the necessary material subsequent to 
a chunk of source code, defined with the ``@@d`` command.  
Links or cross references to chunks that 
refer to this chunk can be emitted.


@d Weaver code...
@{
cb_template = string.Template("\n..  _`${seq}`:\n..  rubric:: ${fullName} (${seq}) ${concat}\n..  parsed-literal::\n    :class: code\n\n")

def codeBegin(self, aChunk: Chunk) -> None:
    txt = self.cb_template.substitute( 
        seq = aChunk.seq,
        lineNumber = aChunk.lineNumber, 
        fullName = aChunk.fullName,
        concat = "=" if aChunk.initial else "+=", # RST Separator
    )
    self.write(txt)
    
ce_template = string.Template("\n..\n\n    ..  class:: small\n\n        |loz| *${fullName} (${seq})*. Used by: ${references}\n")

def codeEnd(self, aChunk: Chunk) -> None:
    txt = self.ce_template.substitute( 
        seq = aChunk.seq,
        lineNumber = aChunk.lineNumber, 
        fullName = aChunk.fullName,
        references = self.references(aChunk),
    )
    self.write(txt)
@| codeBegin codeEnd
@}

The ``fileBegin()`` method emits the necessary material prior to 
a chunk of source code, defined with the ``@@o`` command.
A subclass would override this to provide specific text
for the intended file type.

The ``fileEnd()`` method emits the necessary material subsequent to 
a chunk of source code, defined with the ``@@o`` command.  

There shouldn't be a list of references to a file. We assert that this
list is always empty.

@d Weaver file...
@{
fb_template = string.Template("\n..  _`${seq}`:\n..  rubric:: ${fullName} (${seq}) ${concat}\n..  parsed-literal::\n    :class: code\n\n")

def fileBegin(self, aChunk: Chunk) -> None:
    txt = self.fb_template.substitute(
        seq = aChunk.seq, 
        lineNumber = aChunk.lineNumber, 
        fullName = aChunk.fullName,
        concat = "=" if aChunk.initial else "+=", # RST Separator
    )
    self.write(txt)

fe_template = string.Template("\n..\n\n    ..  class:: small\n\n        |loz| *${fullName} (${seq})*.\n")

def fileEnd(self, aChunk: Chunk) -> None:
    assert len(self.references(aChunk)) == 0
    txt = self.fe_template.substitute(
        seq = aChunk.seq, 
        lineNumber = aChunk.lineNumber, 
        fullName = aChunk.fullName,
        references = [] )
    self.write(txt)
@| fileBegin fileEnd
@}

The ``referenceTo()`` method emits a reference to 
a chunk of source code.  There reference is made with a
``@@<``\ *name*\ ``@@>`` reference  within a ``@@d`` or ``@@o`` chunk.
The references are defined with the ``@@d`` or ``@@o`` commands.  
A subclass would override this to provide specific text
for the intended file type.


The ``referenceSep()`` method emits a separator to be used
in a sequence of references. It's usually a ``", "``, but that might be changed to
a simple ``" "`` because it looks better.

@d Weaver reference command...
@{
refto_name_template = string.Template(r"|srarr|\ ${fullName} (`${seq}`_)")
refto_seq_template = string.Template("|srarr|\ (`${seq}`_)")
refto_seq_separator = ", "

def referenceTo(self, aName: str | None, seq: int) -> str:
    """Weave a reference to a chunk.
    Provide name to get a full reference.
    name=None to get a short reference."""
    if aName:
        return self.refto_name_template.substitute(fullName=aName, seq=seq)
    else:
        return self.refto_seq_template.substitute(seq=seq)
        
def referenceSep(self) -> str:
    """Separator between references."""
    return self.refto_seq_separator
@| referenceTo referenceSep
@}

The ``xrefHead()`` method puts decoration in front of cross-reference
output.  A subclass may override this to change the look of the final
woven document.

The ``xrefFoot()`` method puts decoration after cross-reference
output.  A subclass may override this to change the look of the final
woven document.

The ``xrefLine()`` method is used for both 
file and chunk ("macro") cross-references to show a name (either file name
or chunk name) and a list of chunks that reference the file or chunk.

The ``xrefDefLine()`` method is used for the user identifier cross-reference.
This shows a name and a list of chunks that 
reference or define the name.  One of the chunks is identified as the
defining chunk, all others are referencing chunks.

An ``xrefEmpty()`` is used in the rare case of no user identifiers present.

The default behavior simply writes the Python data structure used
to represent cross reference information.  A subclass may override this 
to change the look of the final woven document.

@d Weaver cross reference...
@{
xref_head_template = string.Template("\n")
xref_foot_template = string.Template("\n")
xref_item_template = string.Template(":${fullName}:\n    ${refList}\n")
xref_empty_template = string.Template("(None)\n")

def xrefHead(self) -> None:
    txt = self.xref_head_template.substitute()
    self.write(txt)

def xrefFoot(self) -> None:
    txt = self.xref_foot_template.substitute()
    self.write(txt)

def xrefLine(self, name: str, refList: list[int]) -> None:
    refList_txt = [self.referenceTo(None, r) for r in refList]
    txt = self.xref_item_template.substitute(fullName=name, refList = " ".join(refList_txt)) # RST Separator
    self.write(txt)

def xrefEmpty(self) -> None:
    self.write(self.xref_empty_template.substitute())
@}

Cross-reference definition line 

@d Weaver cross reference...
@{
name_def_template = string.Template('[`${seq}`_]')
name_ref_template = string.Template('`${seq}`_')

def xrefDefLine(self, name: str, defn: int, refList: list[int]) -> None:
    """Special template for the definition, default reference for all others."""
    templates = {defn: self.name_def_template}
    refTxt = [
        templates.get(r, self.name_ref_template).substitute(seq=r)
        for r in sorted(refList + [defn]) 
    ]
    # Generic space separator
    txt = self.xref_item_template.substitute(fullName=name, refList=" ".join(refTxt)) 
    self.write(txt)
@| xrefHead xrefFoot xrefLine xrefDefLine
@}

RST subclass of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

A degenerate case. This slightly simplifies the configuration and makes the output
look a little nicer.

@d RST subclass...
@{
class RST(Weaver):
    pass
@}


LaTeX subclass of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

Experimental, at best. 

An instance of ``LaTeX`` can be used by the ``Web`` object to 
weave an output document.  The instance is created outside the Web, and
given to the ``weave()`` method of the Web.

..  parsed-literal::

    w = Web()
    WebReader().load(w,"somefile.w") 
    weave_latex = LaTeX()
    w.weave(weave_latex)

Note that the template language and LaTeX both use ``$``.
This means that all  ``$`` that are intended to be output to LaTeX
must appear as ``$$`` in the template.


The ``LaTeX`` subclass defines a Weaver that is customized to
produce LaTeX output of code sections and cross reference information.
Its markup is pretty rudimentary, but it's also distinctive enough to
function pretty well in most L\ !sub:`A`\ T\ !sub:`E`\ X documents.


@d LaTeX subclass...
@{
class LaTeX(Weaver):
    """LaTeX formatting for XRef's and code blocks when weaving.
    Requires \\usepackage{fancyvrb}
    """
    extension = ".tex"
    code_indent = 0
    header = """\n\\usepackage{fancyvrb}\n"""

    @<LaTeX code chunk begin@>
    @<LaTeX code chunk end@>
    @<LaTeX file output begin@>
    @<LaTeX file output end@>
    @<LaTeX references summary at the end of a chunk@>
    @<LaTeX write a line of code@>
    @<LaTeX reference to a chunk@>
@| LaTeX 
@}

The LaTeX ``open()`` method opens the woven file by replacing the
source file's suffix with ``".tex"`` and creating the resulting file.


The LaTeX ``codeBegin()`` template writes the header prior to a
chunk of source code.  It aligns the block to the left, prints an
italicised header, and opens a preformatted block.

  
@d LaTeX code chunk begin
@{
cb_template = string.Template( """\\label{pyweb${seq}}
\\begin{flushleft}
\\textit{Code example ${fullName} (${seq})}
\\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]\n""") # Prevent indent
@| codeBegin
@}


The LaTeX ``codeEnd()`` template writes the trailer subsequent to
a chunk of source code.  This first closes the preformatted block and
then calls the ``references()`` method to write a reference
to the chunk that invokes this chunk; finally, it restores paragraph
indentation.
  
@d LaTeX code chunk end
@{
ce_template = string.Template("""
\\end{Verbatim}
${references}
\\end{flushleft}\n""") # Prevent indentation
@| codeEnd
@}


The LaTeX ``fileBegin()`` template writes the header prior to a
the creation of a tangled file.  Its formatting is identical to the
start of a code chunk.


@d LaTeX file output begin
@{
fb_template = cb_template
@| fileBegin
@}

The LaTeX ``fileEnd()`` template writes the trailer subsequent to
a tangled file.  This closes the preformatted block, calls the LaTeX
``references()`` method to write a reference to the chunk that
invokes this chunk, and restores normal indentation.

@d LaTeX file output end
@{
fe_template = ce_template
@| fileEnd
@}

The ``references()`` template writes a list of references after a
chunk of code.  Each reference includes the example number, the title,
and a reference to the LaTeX section and page numbers on which the
referring block appears.
  
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

The ``quote()`` method quotes a single line of code to the
weaver; since these lines are always in preformatted blocks, no
special formatting is needed, except to avoid ending the preformatted
block.  Our one compromise is a thin space if the phrase
``\\end{Verbatim}`` is used in a code block.

  
@d LaTeX write a line...
@{
quoted_chars: list[tuple[str, str]] = [
    ("\\end{Verbatim}", "\\end\,{Verbatim}"), # Allow \end{Verbatim}
    ("\\{","\\\,{"), # Prevent unexpected commands in Verbatim
    ("$","\\$"), # Prevent unexpected math in Verbatim
]
@| quoted_chars
@}

The ``referenceTo()`` template writes a reference to another chunk of
code.  It uses write directly as to follow the current indentation on
the current line of code.


@d LaTeX reference to...
@{
refto_name_template = string.Template("""$$\\triangleright$$ Code Example ${fullName} (${seq})""")
refto_seq_template = string.Template("""(${seq})""")
@| referenceTo
@}

HTML subclasses of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

This works, but, it's not clear that it should be kept.

An instance of ``HTML`` can be used by the ``Web`` object to 
weave an output document.  The instance is created outside the Web, and
given to the ``weave()`` method of the Web.

..  parsed-literal::


    w = Web()
    WebReader().load(w,"somefile.w") 
    weave_html = HTML()
    w.weave(weave_html)


Variations in the output formatting are accomplished by having
variant subclasses of HTML.  In this implementation, we have two
variations: full path references, and short references.  The base class
produces complete reference paths; a subclass produces abbreviated references.


The ``HTML`` subclass defines a Weaver that is customized to
produce HTML output of code sections and cross reference information.

All HTML chunks are identified by anchor names of the form ``pyweb*n*``.  Each
*n* is the unique chunk number, in sequential order.

An ``HTMLShort`` subclass defines a Weaver that produces HTML output
with abbreviated (no name) cross references at the end of the chunk.

@d HTML subclass...
@{
class HTML(Weaver):
    """HTML formatting for XRef's and code blocks when weaving."""
    extension = ".html"
    code_indent = 0
    header = ""
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
class HTMLShort(HTML):
    """HTML formatting for XRef's and code blocks when weaving with short references."""
    @<HTML short references summary at the end of a chunk@>
@| HTML 
@}

The ``codeBegin()`` template starts a chunk of code, defined with ``@@d``, providing a label
and HTML tags necessary to set the code off visually.


@d HTML code chunk begin
@{
cb_template = string.Template("""
<a name="pyweb${seq}"></a>
<!--line number ${lineNumber}-->
<p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
<pre><code>\n""")
@| codeBegin
@}

The ``codeEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.

@d HTML code chunk end
@{
ce_template = string.Template("""
</code></pre>
<p>&loz; <em>${fullName}</em> (${seq}).
${references}
</p>\n""")
@| codeEnd
@}

The ``fileBegin()`` template starts a chunk of code, defined with ``@@o``, providing a label
and HTML tags necessary to set the code off visually.

@d HTML output file begin
@{
fb_template = string.Template("""<a name="pyweb${seq}"></a>
<!--line number ${lineNumber}-->
<p>``${fullName}`` (${seq})&nbsp;${concat}</p>
<pre><code>\n""") # Prevent indent
@| fileBegin
@}

The ``fileEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.

@d HTML output file end
@{
fe_template = string.Template( """</code></pre>
<p>&loz; ``${fullName}`` (${seq}).
${references}
</p>\n""")
@| fileEnd
@}

The ``references()`` template writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.

@d HTML references summary...
@{
ref_item_template = string.Template('<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>')
ref_template = string.Template('  Used by ${refList}.' )
@| references
@}

The ``quote()`` method quotes an individual line of code for HTML purposes.
This encodes the four basic HTML entities (``<``, ``>``, ``&``, ``"``) to prevent code from being interpreted
as HTML.

@d HTML write a line of code
@{
quoted_chars: list[tuple[str, str]] = [
    ("&", "&amp;"), # Must be first
    ("<", "&lt;"),
    (">", "&gt;"),
    ('"', "&quot;"),
]
@| quoted_chars
@}

The ``referenceTo()`` template writes a reference to another chunk.  It uses the 
direct ``write()`` method so that the reference is indented properly with the
surrounding source code.

@d HTML reference to a chunk
@{
refto_name_template = string.Template('<a href="#pyweb${seq}">&rarr;<em>${fullName}</em> (${seq})</a>')
refto_seq_template = string.Template('<a href="#pyweb${seq}">(${seq})</a>')
@| referenceTo
@}

The ``xrefHead()`` method writes the heading for any of the cross reference blocks created by
``@@f``, ``@@m``, or ``@@u``.  In this implementation, the cross references are simply unordered lists. 

The ``xrefFoot()`` method writes the footing for any of the cross reference blocks created by
``@@f``, ``@@m``, or ``@@u``.  In this implementation, the cross references are simply unordered lists. 

The ``xrefLine()`` method writes a line for the file or macro cross reference blocks created by
``@@f`` or ``@@m``.  In this implementation, the cross references are simply unordered lists. 

@d HTML simple cross reference markup
@{
xref_head_template = string.Template("<dl>\n")
xref_foot_template = string.Template("</dl>\n")
xref_item_template = string.Template("<dt>${fullName}</dt><dd>${refList}</dd>\n")
@<HTML write user id cross reference line@>
@| xrefHead xrefFoot xrefLine
@}

The ``xrefDefLine()`` method writes a line for the user identifier cross reference blocks created by
@@u.  In this implementation, the cross references are simply unordered lists.  The defining instance 
is included in the correct order with the other instances, but is bold and marked with a bullet (&bull;).


@d HTML write user id cross reference line
@{
name_def_template = string.Template('<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>')
name_ref_template = string.Template('<a href="#pyweb${seq}">${seq}</a>')
@| xrefDefLine
@}

The HTMLShort subclass enhances the HTML class to provide short 
cross references.
The ``references()`` method writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.

@d HTML short references summary...
@{
ref_item_template = string.Template('<a href="#pyweb${seq}">(${seq})</a>')
@| references
@}

Tangler subclass of Emitter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``Tangler`` class is concrete, and can tangle source files.  An
instance of ``Tangler`` is given to the ``Web`` class ``tangle()`` method.

..  parsed-literal::

    w = Web()
    WebReader().load(w,"somefile.w") 
    t = Tangler()
    w.tangle(t)


The ``Tangler`` subclass extends an Emitter to **tangle** the various
program source files.  The superclass is used to simply emit correctly indented 
source code and do very little else that could corrupt or alter the output.

Language-specific subclasses could be used to provide additional decoration.
For example, inserting ``#line`` directives showing the line number
in the original source file.

For Python, where indentation matters, the indent rules are relatively
simple.  The whitespace berfore a ``@@<`` command is preserved as
the prevailing indent for the block tangled as a replacement for the  ``@@<``\ *name*\ ``@@>``.

There are three configurable values:

:comment_start:
    If not None, this is the leading character for a line-number comment
    
:comment_end:
    This is the trailing character for a line-number comment
    
:include_line_numbers:
    Show the source line numbers in the output via additional comments.

@d Tangler subclass of Emitter...
@{
class Tangler(Emitter):
    """Tangle output files."""
    def __init__(self) -> None:
        super().__init__()
        self.comment_start: str = "#"
        self.comment_end: str = ""
        self.include_line_numbers = False
    @<Tangler doOpen, and doClose overrides@>
    @<Tangler code chunk begin@>
    @<Tangler code chunk end@>
@| Tangler 
@}

The default for all tanglers is to create the named file.
In order to handle paths, we will examine the file name for any ``"/"``
characters and perform the required ``os.makedirs`` functions to
allow creation of files with a path.  We don't use Windows ``"\"``
characters, but rely on Python to handle this automatically.

This ``doClose()`` method overrides the ``Emitter`` class ``doClose()`` method by closing the
actual file created by open.

@d Tangler doOpen...
@{
def checkPath(self) -> None:
    if "/" in self.fileName:
        dirname, _, _ = self.fileName.rpartition("/")
        try:
            os.makedirs(dirname)
            self.logger.info("Creating %r", dirname)
        except OSError as exc:
            # Already exists.  Could check for errno.EEXIST.
            self.logger.debug("Exception %r creating %r", exc, dirname)
def doOpen(self, aFile: str) -> None:
    self.fileName = aFile
    self.checkPath()
    self.theFile = open(aFile, "w")
    self.logger.info("Tangling %r", aFile)
def doClose(self) -> None:
    self.theFile.close()
    self.logger.info( "Wrote %d lines to %r", self.linesWritten, self.fileName)
@| doOpen doClose
@}

The ``codeBegin()`` method starts emitting a new chunk of code.
It does this by setting the Tangler's indent to the
prevailing indent at the start of the ``@@<`` reference command.

@d Tangler code chunk begin
@{
def codeBegin(self, aChunk: Chunk) -> None:
    self.log_indent.debug("<tangle %r:", aChunk.fullName)
    if self.include_line_numbers:
        self.write(
            f"\n{self.comment_start!s} Web: " 
            f"{aChunk.fileName!s}:{aChunk.lineNumber!r} " 
            f"{aChunk.fullName!s}({aChunk.seq:d}) {self.comment_end!s}\n"
        )
@| codeBegin
@}

The ``codeEnd()`` method ends emitting a new chunk of code.
It does this by resetting the Tangler's indent to the previous
setting.


@d Tangler code chunk end
@{
def codeEnd(self, aChunk: Chunk) -> None:
    self.log_indent.debug(">%r", aChunk.fullName)
@| codeEnd
@}

TanglerMake subclass of Tangler
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``TanglerMake`` class is can tangle source files.  An
instance of ``TanglerMake`` is given to the ``Web`` class ``tangle()`` method.

..  parsed-literal::

    w = Web()
    WebReader().load(w,"somefile.w") 
    t = TanglerMake()
    w.tangle(t)

The ``TanglerMake`` subclass extends ``Tangler`` to make the source files
more make-friendly.  This subclass of ``Tangler`` 
does not **touch** an output file
where there is no change.  This is helpful when **py-web-tool**\ 's output is
sent to **make**.  Using ``TanglerMake`` assures that only files with real changes
are rewritten, minimizing recompilation of an application for changes to
the associated documentation.

This subclass of ``Tangler`` changes how files
are opened and closed.

@d Imports
@{import tempfile
import filecmp
@| tempfile filecmp
@}

@d TanglerMake subclass...
@{
class TanglerMake(Tangler):
    """Tangle output files, leaving files untouched if there are no changes."""
    tempname : str
    def __init__(self, *args: Any) -> None:
        super().__init__(*args)

    @<TanglerMake doOpen override, using a temporary file@>

    @<TanglerMake doClose override, comparing temporary to original@>
@| TanglerMake 
@}

A ``TanglerMake`` creates a temporary file to collect the
tangled output.  When this file is completed, we can compare
it with the original file in this directory, avoiding
a "touch" if the new file is the same as the original.


@d TanglerMake doOpen...
@{
def doOpen(self, aFile: str) -> None:
    fd, self.tempname = tempfile.mkstemp(dir=os.curdir)
    self.theFile = os.fdopen(fd, "w")
    self.logger.info("Tangling %r", aFile)
@| doOpen
@}

If there is a previous file: compare the temporary file and the previous file.  

If there was no previous file or the files are different: rename temporary to replace previous;
else there was a previous file and the files were the same: unlink temporary and discard it.  

This preserves the original (with the original date
and time) if nothing has changed.


@d TanglerMake doClose...
@{
def doClose(self) -> None:
    self.theFile.close()
    try:
        same = filecmp.cmp(self.tempname, self.fileName)
    except OSError as e:
        same = False # Doesn't exist.  Could check for errno.ENOENT
    if same:
        self.logger.info("No change to %r", self.fileName)
        os.remove(self.tempname)
    else:
        # Windows requires the original file name be removed first.
        self.checkPath()
        try: 
            os.remove(self.fileName)
        except OSError as e:
            pass # Doesn't exist.  Could check for errno.ENOENT
        os.rename(self.tempname, self.fileName)
        self.logger.info("Wrote %e lines to %r", self.linesWritten, self.fileName)
@| doClose
@}

Chunks
--------

A ``Chunk`` is a piece of the input file.  It is a collection of ``Command`` instances.
A chunk can be woven or tangled to create output.

The two most important methods are the ``weave()`` and ``tangle()`` methods.  These
visit the commands of this chunk, producing the required output file.

Additional methods (``startswith()``, ``searchForRE()`` and ``usedBy()``)
are used to examine the text of the ``Command`` instances within
the chunk.

A ``Chunk`` instance is created by the ``WebReader`` as the input file is parsed.
Each ``Chunk`` instance has one or more pieces of the original input text.  
This text can be program source, a reference command, or the documentation source.

@d Chunk class hierarchy...
@{
@<Chunk class@>
@<NamedChunk class@>
@<OutputChunk class@>
@<NamedDocumentChunk class@>
@}

The ``Chunk`` class is both the superclass for this hierarchy and the implementation 
for anonymous chunks.  An anonymous chunk is always documentation in the 
target markup language.  No transformation is ever done on anonymous chunks.

A ``NamedChunk`` is a chunk created with a ``@@d`` command.  
This is a chunk of source programming language, bracketed with ``@@{`` and ``@@}``.

An ``OutputChunk`` is a named chunk created with a ``@@o`` command.  
This must be a chunk of source programming language, bracketed with ``@@{`` and ``@@}``.

A ``NamedDocumentChunk`` is a named chunk created with a ``@@d`` command.  
This is a chunk of documentation in the target markup language,
bracketed with ``@@[`` and ``@@]``.

Chunk Superclass
~~~~~~~~~~~~~~~~~

An instance of the ``Chunk`` class has a life that includes four important events:

-   creation, 

-   cross-reference, 

-   weave,

-   and tangle.

A ``Chunk`` is created by a ``WebReader``, and associated with a ``Web``.
There are several web append methods, depending on the exact subclass of ``Chunk``.
The ``WebReader`` calls the chunk's ``webAdd()`` method select the correct method
for appending and indexing the chunk.
Individual instances of ``Command`` are appended to the chunk.
The basic outline for creating a ``Chunk`` instance is as follows:

..  parsed-literal::

    w = Web()
    c = Chunk()
    c.webAdd(w)
    c.append(*...some Command...*)
    c.append(*...some Command...*)

Before weaving or tangling, a cross reference is created for all
user identifiers in all of the ``Chunk`` instances.
This is done by: (1) visit each ``Chunk`` and call the 
``getUserIDRefs()`` method to gather all identifiers; (2) for each identifier, 
visit each ``Chunk`` and call the ``searchForRE()`` method to find uses of
the identifier.

..  parsed-literal::

    ident = []
    for c in *the Web's named chunk list*:
        ident.extend(c.getUserIDRefs())
    for i in ident:
        pattern = re.compile(f'\\W{i!s}\\W' )
        for c in *the Web's named chunk list*:
            c.searchForRE(pattern)

A ``Chunk`` is woven or tangled by the ``Web``.  The basic outline for weaving is
as follows.  The tangling action is essentially the same.

..  parsed-literal::

    for c in *the Web's chunk list*:
        c.weave(aWeaver)

The ``Chunk`` class contains the overall definitions for all of the
various specialized subclasses.  In particular, it contains the ``append()``,
and ``appendText()`` methods used by all of the various ``Chunk`` subclasses.


When a ``@@@@`` construct is located in the input stream, the stream contains
three text tokens: material before the ``@@@@``, the ``@@@@``, 
and the material after the ``@@@@``.
These three tokens are reassembled into a single block of text.  This reassembly
is accomplished by changing the chunk's state so that the next ``TextCommand`` is
appended onto the previous ``TextCommand``.

The ``appendText()`` method either:

-   appends to a previous ``TextCommand``  instance,

-   or finds that there are no commands at all, and creates an initial
    ``TextCommand`` instance,

-   or finds that the last ``Command`` isn't a subclass of ``TextCommand``
    and creates a ``TextCommand`` instance.

Each subclass of ``Chunk`` has a particular type of text that it will process.  Anonymous chunks
only handle document text.  The ``NamedChunk`` subclass that handles program source
will override this method to create a different command type.  The ``makeContent()`` method
creates the appropriate ``Command`` instance for this ``Chunk`` subclass.

The ``weave()`` method of an anonymous ``Chunk`` uses the weaver's 
``docBegin()`` and ``docEnd()``
methods to insert text that is source markup.  Other subclasses will override this to 
use different ``Weaver`` methods for different kinds of text.

A ``Chunk`` has a **Strategy** object which is a subclass of ``Reference``.  This is
either an instance of ``SimpleReference`` or ``TransitiveReference``.  
A ``SimpleRerence`` does no additional processing, and locates the proximate reference to 
this chunk.  The ``TransitiveReference`` walks "up" the web toward top-level file
definitions that reference this ``Chunk``.


The ``Chunk`` constructor initializes the following instance variables:

:commands:
    is a sequence of the various ``Command`` instances the comprise this
    chunk.

:user_id_list:
    is used the list of user identifiers associated with
    this chunk.  This attribute is always ``None`` for this class.
    The ``NamedChunk`` subclass, however, can have user identifiers.
    
:initial:
    is True if this is the first
    definition (display with ``'='``) or a subsequent definition (display with ``'+='``).

:web:
    A weakref to the web which contains this Chunk. We want to inherit information
    from the ``Web`` overall.
    
:fileName:
    The file which contained this chunk's initial ``@@o`` or ``@@d``.
    
:name:
    has the name of the chunk.  This is '' for anonymous chunks.

!seq:
    has the sequence number associated with this chunk.  This is None
    for anonymous chunks.

:referencedBy:
    is the list of Chunks which reference this chunk.

:references:
    is the list of Chunks this chunk references.

@d Chunk class
@{
class Chunk:
    """Anonymous piece of input file: will be output through the weaver only."""
    web : weakref.ReferenceType["Web"]
    previous_command : "Command"
    initial: bool
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
        self.commands: list["Command"] = [ ]  # The list of children of this chunk
        self.user_id_list: list[str] = []
        self.name: str = ''
        self.fullName: str = ""
        self.seq: int = 0
        self.fileName = ''
        self.referencedBy: list[Chunk] = []  # Chunks which reference this chunk.  Ideally just one.
        self.references_list: list[str] = []  # Names that this chunk references
        self.refCount = 0
        
    def __str__(self) -> str:
        return "\n".join(map(str, self.commands))
    def __repr__(self) -> str:
        return f"{self.__class__.__name__!s}({self.name!r})"
        
    @<Chunk append a command@>
    @<Chunk append text@>
    @<Chunk add to the web@>
    
    @<Chunk generate references from this Chunk@>
    @<Chunk superclass make Content definition@>
    @<Chunk examination: starts with, matches pattern@>
    @<Chunk references to this Chunk@>
    
    @<Chunk weave this Chunk into the documentation@>
    @<Chunk tangle this Chunk into a code file@>
    @<Chunk indent adjustments@>
@| Chunk makeContent
@}

The ``append()`` method simply appends a ``Command`` instance to this chunk.

@d Chunk append a command
@{
def append(self, command: Command) -> None:
    """Add another Command to this chunk."""
    self.commands.append(command)
    command.chunk = self
@| append
@}

The ``appendText()`` method appends a ``TextCommand`` to this chunk,
or it concatenates it to the most recent ``TextCommand``.  

When an ``@@@@`` construct is located, the ``appendText()`` method is
used to accumulate this character.  This means that it will be appended to 
any previous TextCommand, or  new TextCommand will be built.

The reason for appending is that a ``TextCommand`` has an implicit indentation.  The "@@" cannot
be a separate ``TextCommand`` because it will wind up indented.

@d Chunk append text
@{
def appendText(self, text: str, lineNumber: int = 0) -> None:
    """Append a single character to the most recent TextCommand."""
    try:
        # Works for TextCommand, otherwise breaks
        self.commands[-1].text += text
    except IndexError as e:
        # First command?  Then the list will have been empty.
        self.commands.append(self.makeContent(text,lineNumber))
    except AttributeError as e:
        # Not a TextCommand?  Then there won't be a text attribute.
        self.commands.append(self.makeContent(text,lineNumber))
@| appendText
@}

The ``webAdd()`` method adds this chunk to the given document web.
Each subclass of the ``Chunk`` class must override this to be sure that the various
``Chunk`` subclasses are indexed properly.  The
``Chunk`` class uses the ``add()`` method
of the ``Web`` class to append an anonymous, unindexed chunk.

@d Chunk add to the web
@{
def webAdd(self, web: "Web") -> None:
    """Add self to a Web as anonymous chunk."""
    web.add(self)
@| webAdd
@}

This superclass creates a specific Command for a given piece of content.
A subclass can override this to change the underlying assumptions of that Chunk.
The generic chunk doesn't contain code, it contains text and can only be woven,
never tangled.  A Named Chunk using ``@@{`` and ``@@}`` creates code.
A Named Chunk using ``@@[`` and ``@@]`` creates text.


@d Chunk superclass make Content...
@{
def makeContent(self, text: str, lineNumber: int = 0) -> Command:
    return TextCommand(text, lineNumber)
@| makeContent
@}

The ``startsWith()`` method examines a the first ``Command`` instance this
``Chunk`` instance to see if it starts
with the given prefix string.

The ``lineNumber()`` method returns the line number of the first
``Command`` in this chunk.  This provides some context for where the chunk
occurs in the original input file.

A ``NamedChunk`` instance may define one or more identifiers.  This parent class
provides a dummy version of the ``getUserIDRefs`` method.  The ``NamedChunk``
subclass overrides this to provide actual results.  By providing this
at the superclass-level, the ``Web`` can easily gather identifiers without
knowing the actual subclass of ``Chunk``.

The ``searchForRE()`` method examines each ``Command`` instance to see if it matches
with the given regular expression.  If so, this can be reported to the Web instance
and accumulated as part of a cross reference for this ``Chunk``.

@d Imports...
@{from typing import Pattern, Match, Optional, Any, Literal
@}

@d Chunk examination...
@{
def startswith(self, prefix: str) -> bool:
    """Examine the first command's starting text."""
    return len(self.commands) >= 1 and self.commands[0].startswith(prefix)

def searchForRE(self, rePat: Pattern[str]) -> Optional["Chunk"]:
    """Visit each command, applying the pattern."""
    for c in self.commands:
        if c.searchForRE(rePat):
            return self
    return None

@@property
def lineNumber(self) -> int | None:
    """Return the first command's line number or None."""
    return self.commands[0].lineNumber if len(self.commands) >= 1 else None

def setUserIDRefs(self, text: str) -> None:
    """Used by NamedChunk subclass."""
    pass
    
def getUserIDRefs(self) -> list[str]:
    """Used by NamedChunk subclass."""
    return []
@| startswith searchForRE lineNumber getUserIDRefs
@}

The chunk search in the ``searchForRE()`` method parallels weaving and tangling a ``Chunk``.
The operation is delegated to each ``Command`` instance within the ``Chunk`` instance.

The ``genReferences()`` method visits each ``Command`` instance inside this chunk;
a ``Command`` will yield the references.  

Note that an exception may be raised by this operation if a referenced
``Chunk`` does not actually exist.  If a reference ``Command`` does raise an error, 
we append this ``Chunk`` information and reraise the error with the additional 
context information.


@d Chunk generate references...
@{
def genReferences(self, aWeb: "Web") -> Iterator[str]:
    """Generate references from this Chunk."""
    try:
        for t in self.commands:
            ref = t.ref(aWeb)
            if ref is not None:
                yield ref
    except Error as e:
        raise
@| genReferences
@}

The list of references to a Chunk uses a **Strategy** plug-in
to either generate a simple parent or a transitive closure of all parents.

Note that we need to get the ``Weaver.reference_style`` which is a
configuration item. This is a **Strategy** showing how to compute the list of references.
The Weaver pushed it into the Web so that it is available for each ``Chunk``.

@d Chunk references...
@{
def references(self, theWeaver: "Weaver") -> list[tuple[str, int]]:
    """Extract name, sequence from Chunks into a list."""
    return [ 
        (c.name, c.seq) 
        for c in theWeaver.reference_style.chunkReferencedBy(self) 
    ]
@}

The ``weave()`` method weaves this chunk into the final document as follows:

1.  Call the ``Weaver`` class ``docBegin()`` method.  This method does nothing for document content.

2.  Visit each ``Command`` instance: call the ``Command`` instance ``weave()`` method to 
    emit the content of the ``Command`` instance

3.  Call the ``Weaver`` class ``docEnd()`` method.  This method does nothing for document content.

Note that an exception may be raised by this action if a referenced
``Chunk`` does not actually exist.  If a reference ``Command`` does raise an error, 
we append this ``Chunk`` information and reraise the error with the additional 
context information.


@d Chunk weave...
@{
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create the nicely formatted document from an anonymous chunk."""
    aWeaver.docBegin(self)
    for cmd in self.commands:
        cmd.weave(aWeb, aWeaver)
    aWeaver.docEnd(self)
def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create a reference to this chunk -- except for anonymous chunks."""
    raise Exception( "Cannot reference an anonymous chunk.""")
def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create a short reference to this chunk -- except for anonymous chunks."""
    raise Exception( "Cannot reference an anonymous chunk.""")
@| weave weaveReferenceTo weaveShortReferenceTo
@}

Anonymous chunks cannot be tangled.  Any attempt indicates a serious
problem with this program or the input file.

@d Chunk tangle...
@{
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    """Create source code -- except anonymous chunks should not be tangled"""
    raise Error('Cannot tangle an anonymous chunk', self)
@| tangle
@}

Generally, a Chunk with a reference will adjust the indentation for
that referenced material. However, this is not universally true,
a subclass may not indent when tangling and may -- instead -- put stuff flush at the
left margin by forcing the local indent to zero.

@d Chunk indent adjustments...
@{
def reference_indent(self, aWeb: "Web", aTangler: "Tangler", amount: int) -> None:
    aTangler.addIndent(amount)  # Or possibly set indent to local zero.
    
def reference_dedent(self, aWeb: "Web", aTangler: "Tangler") -> None:
    aTangler.clrIndent()
@}

NamedChunk class
~~~~~~~~~~~~~~~~

A ``NamedChunk`` is created and used almost identically to an anonymous ``Chunk``.
The most significant difference is that a name is provided when the ``NamedChunk`` is created.
This name is used by the ``Web`` to organize the chunks.

A ``NamedChunk`` is created with a ``@@d`` or ``@@o`` command.  
A ``NamedChunk`` contains programming language source
when the brackets are ``@@{`` and ``@@}``.  A
separate subclass of ``NamedDocumentChunk`` is used when
the brackets are ``@@[`` and ``@@]``.

A ``NamedChunk`` can be both tangled into the output program files, and
woven into the output document file. 

The ``weave()`` method of a ``NamedChunk`` uses the Weaver's 
``codeBegin()`` and ``codeEnd()``
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses can override this to 
use different ``Weaver`` methods for different kinds of text.

By inheritance from the superclass, this class indents. A separate subclass provides a no-indent
implementation of a ``NamedChunk``.

This class introduces some additional attributes.

:fullName:
    is the full name of the chunk.  It's possible for a 
    chunk to be an abbreviated forward reference; full names cannot be resolved
    until all chunks have been seen.

:user_id_list:
    is the list of user identifiers associated with this chunk.

:refCount:
    is the count of references to this chunk.  If this is
    zero, the chunk is unused; if this is more than one, this chunk is 
    multiply used.  Either of these conditions is a possible error in the input. 
    This is set by the ``usedBy()`` method.

:name: 
    has the name of the chunk.  Names can be abbreviated.

!seq:
    has the sequence number associated with this chunk.  This
    is set by the Web by the ``webAdd()`` method.


@d NamedChunk class
@{
class NamedChunk(Chunk):
    """Named piece of input file: will be output as both tangler and weaver."""
    def __init__(self, name: str) -> None:
        super().__init__()
        self.name = name
        self.user_id_list = []
        self.refCount = 0
        
    def __str__(self) -> str:
        return f"{self.name!r}: {self!s}"
        
    def makeContent(self, text: str, lineNumber: int = 0) -> Command:
        return CodeCommand(text, lineNumber)
        
    @<NamedChunk user identifiers set and get@>
    @<NamedChunk add to the web@>
    @<NamedChunk weave into the documentation@>
    @<NamedChunk tangle into the source file@>
@| NamedChunk makeContent
@}

The ``setUserIDRefs()`` method accepts a list of user identifiers that are
associated with this chunk.  These are provided after the ``@@|`` separator
in a ``@@d`` named chunk.  These are used by the ``@@u`` cross reference generator.

@d NamedChunk user identifiers...
@{
def setUserIDRefs(self, text: str) -> None:
    """Save user ID's associated with this chunk."""
    self.user_id_list = text.split()
def getUserIDRefs(self) -> list[str]:
    return self.user_id_list
@| setUserIDRefs getUserIDRefs
@}

The ``webAdd()`` method adds this chunk to the given document ``Web`` instance.
Each class of ``Chunk`` must override this to be sure that the various
``Chunk`` classes are indexed properly.  This class uses the ``Web.addNamed()`` method
of the ``Web`` class to append a named chunk.

@d NamedChunk add to the web
@{
def webAdd(self, web: "Web") -> None:
    """Add self to a Web as named chunk, update xrefs."""
    web.addNamed(self)
@| webAdd
@}

The ``weave()`` method weaves this chunk into the final document as follows:

1.  call the ``Weaver`` class ``codeBegin()`` method.  This method emits the necessary markup
    for code appearing in the woven output.

2.  visit each ``Command``, calling the command's ``weave()`` method to emit the command's content.

3.  call the ``Weaver`` class ``CodeEnd()`` method.  This method emits the necessary markup
    for code appearing in the woven output.


For an RST weaver this becomes a ``parsed-literal``, which requires a extra indent.
For an HTML weaver this becomes a ``<pre>`` in a different-colored box.

References generate links in a woven document. In a tangled document, they create the actual
code. The ``weaveRefenceTo()`` method weaves a reference to a chunk using both name and sequence number.
The ``weaveShortReferenceTo()`` method weaves a reference to a chunk using only the sequence number.
These references are created by ``ReferenceCommand`` instances within a chunk being woven.

The woven references simply follow whatever preceded them on the line; the indent
(if any) doesn't change from the default.


@d NamedChunk weave...
@{
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create the nicely formatted document from a chunk of code."""
    self.fullName = aWeb.fullNameFor(self.name)
    aWeaver.addIndent()
    aWeaver.codeBegin(self)
    for cmd in self.commands:
        cmd.weave(aWeb, aWeaver)
    aWeaver.clrIndent( )
    aWeaver.codeEnd(self)
def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create a reference to this chunk."""
    self.fullName = aWeb.fullNameFor(self.name)
    txt = aWeaver.referenceTo(self.fullName, self.seq)
    aWeaver.codeBlock(txt)
def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create a shortened reference to this chunk."""
    txt = aWeaver.referenceTo(None, self.seq)
    aWeaver.codeBlock(txt)
@| weave weaveReferenceTo weaveShortReferenceTo
@}

The ``tangle()`` method tangles this chunk into the final document as follows:

1.  call the ``Tangler`` class ``codeBegin()`` method to set indents properly.

2.  visit each Command, calling the Command's ``tangle()`` method to emit the Command's content.

3.  call the ``Tangler`` class ``codeEnd()`` method to restore indents.

If a ``ReferenceCommand`` does raise an error during tangling,
we append this Chunk information and reraise the error with the additional 
context information.


@d NamedChunk tangle...
@{
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    """Create source code.
    Use aWeb to resolve @@<namedChunk@@>.
    Format as correctly indented source text
    """
    self.previous_command = TextCommand("", self.commands[0].lineNumber)
    aTangler.codeBegin(self)
    for t in self.commands:
        try:
            t.tangle(aWeb, aTangler)
        except Error as e:
            raise
        self.previous_command = t
    aTangler.codeEnd(self)
@| tangle
@}

There's a second variation on NamedChunk, one that doesn't indent based on 
context. It simply sets an indent at the left margin.

@d NamedChunk class
@{
class NamedChunk_Noindent(NamedChunk):
    """Named piece of input file: will be output as both tangler and weaver."""
    def reference_indent(self, aWeb: "Web", aTangler: "Tangler", amount: int) -> None:
        aTangler.setIndent(0)
    
    def reference_dedent(self, aWeb: "Web", aTangler: "Tangler") -> None:
        aTangler.clrIndent()
@}
    
OutputChunk class
~~~~~~~~~~~~~~~~~~~

A ``OutputChunk`` is created and used identically to a ``NamedChunk``.
The difference between this class and the parent class is the decoration of 
the markup when weaving.

The ``OutputChunk`` class is a subclass of ``NamedChunk`` that handles 
file output chunks defined with ``@@o``. 

The ``weave()`` method of a ``OutputChunk`` uses the Weaver's 
``fileBegin()`` and ``fileEnd()``
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses could override this to 
use different ``Weaver`` methods for different kinds of text.

All other methods, including the tangle method are identical to ``NamedChunk``.

@d OutputChunk class
@{
class OutputChunk(NamedChunk):
    """Named piece of input file, defines an output tangle."""
    def __init__(self, name: str, comment_start: str = "", comment_end: str = "") -> None:
        super().__init__(name)
        self.comment_start = comment_start
        self.comment_end = comment_end
    @<OutputChunk add to the web@>
    @<OutputChunk weave@>
    @<OutputChunk tangle@>
@| OutputChunk 
@}

The ``webAdd()`` method adds this chunk to the given document ``Web``.
Each class of ``Chunk`` must override this to be sure that the various
``Chunk`` classes are indexed properly.  This class uses the ``addOutput()`` method
of the ``Web`` class to append a file output chunk.

@d OutputChunk add to the web
@{
def webAdd(self, web: "Web") -> None:
    """Add self to a Web as output chunk, update xrefs."""
    web.addOutput(self)
@| webAdd
@}

The ``weave()`` method weaves this chunk into the final document as follows:

1.  call the ``Weaver`` class ``codeBegin()`` method to emit proper markup for an output file chunk.

2.  visit each ``Command``, call the Command's ``weave()`` method to emit the Command's content.

3.  call the ``Weaver`` class ``codeEnd()`` method to emit proper markup for an output file chunk.

These chunks of documentation are never tangled.  Any attempt is an
error.

If a ``ReferenceCommand`` does raise an error during weaving,
we append this ``Chunk`` information and reraise the error with the additional 
context information.


@d OutputChunk weave
@{
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create the nicely formatted document from a chunk of code."""
    self.fullName = aWeb.fullNameFor(self.name)
    aWeaver.fileBegin(self)
    for cmd in self.commands:
        cmd.weave(aWeb, aWeaver)
    aWeaver.fileEnd(self)
@| weave
@}

When we tangle, we provide the output Chunk's comment information to the Tangler
to be sure that -- if line numbers were requested -- they can be included properly.

@d OutputChunk tangle
@{
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    aTangler.comment_start = self.comment_start
    aTangler.comment_end = self.comment_end
    super().tangle(aWeb, aTangler)
@}

NamedDocumentChunk class
~~~~~~~~~~~~~~~~~~~~~~~~~

A ``NamedDocumentChunk`` is created and used identically to a ``NamedChunk``.
The difference between this class and the parent class is that this chunk
is only woven when referenced.  The original definition is silently skipped.

The ``NamedDocumentChunk`` class is a subclass of ``NamedChunk`` that handles 
named chunks defined with ``@@d`` and the ``@@[``\ ...\ ``@@]`` delimiters.  
These are woven slightly
differently, since they are document source, not programming language source.

We're not as interested in the cross reference of named document chunks.
They can be used multiple times or never.  They are expected to be referenced
by anonymous chunks.  While this chunk subclass participates in this data 
gathering, it is ignored for reporting purposes.

All other methods, including the tangle method are identical to ``NamedChunk``.


@d NamedDocumentChunk class
@{
class NamedDocumentChunk(NamedChunk):
    """Named piece of input file with document source, defines an output tangle."""
    
    def makeContent(self, text: str, lineNumber: int = 0) -> Command:
        return TextCommand(text, lineNumber)
        
    @<NamedDocumentChunk weave@>
    @<NamedDocumentChunk tangle@>
@| NamedDocumentChunk makeContent
@}

The ``weave()`` method quietly ignores this chunk in the document.
A named document chunk is only included when it is referenced 
during weaving of another chunk (usually an anonymous document
chunk).

The ``weaveReferenceTo()`` method inserts the content of this
chunk into the output document.  This is done in response to a
``ReferenceCommand`` in another chunk.  
The ``weaveShortReferenceTo()`` method calls the ``weaveReferenceTo()``
to insert the entire chunk.


@d NamedDocumentChunk weave
@{
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Ignore this when producing the document."""
    pass
def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """On a reference to this chunk, expand the body in place."""
    for cmd in self.commands:
        cmd.weave(aWeb, aWeaver)
def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """On a reference to this chunk, expand the body in place."""
    self.weaveReferenceTo(aWeb, aWeaver)
@| weave weaveReferenceTo weaveShortReferenceTo
@}

@d NamedDocumentChunk tangle
@{
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    """Raise an exception on an attempt to tangle."""
    raise Error("Cannot tangle a chunk defined with @@[.""")
@| tangle
@}

Commands
--------

The input stream is broken into individual commands, based on the
various ``@@*x*`` strings in the file.  There are several subclasses of ``Command``,
each used to describe a different command or block of text in the input.


All instances of the ``Command`` class are created by a ``WebReader`` instance.  
In this case, a ``WebReader`` can be thought of as a factory for ``Command`` instances.
Each ``Command`` instance is appended to the sequence of commands that
belong to a ``Chunk``.  A chunk may be as small as a single command, or a long sequence
of commands.

Each ``Command`` instance responds to methods to examine the content, gather 
cross reference information and tangle a file or weave the final document.


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

Command Superclass
~~~~~~~~~~~~~~~~~~~~

A ``Command`` is created by the ``WebReader``, and attached to a ``Chunk``.
The Command participates in cross reference creation, weaving and tangling.

The ``Command`` superclass is abstract, and has default methods factored out
of the various subclasses.  When a subclass is created, it will override some
of the methods provided in this superclass.

..  parsed-literal::

    class MyNewCommand(Command):
        *... overrides for various methods ...*

Additionally, a subclass of ``WebReader`` must be defined to parse the new command
syntax.  The main ``process()`` function must also be updated to use this new subclass
of ``WebReader``.


The ``Command`` superclass provides the parent class definition
for all of the various command types.  The most common command
is a block of text.
For tangling it is presented with no changes. For weaving, 
quoting is used to make it work nicely with the given markup language.

The next most
common command is a reference to a chunk. This is woven as a 
mark-up reference: a link. It is tangled as an expansion of the source 
code.

Additional methods include the following:

-   The ``startswith()`` method examines any source text to see if
    it begins with the given prefix text. 

-   The ``searchForRE()`` method examines any source text to see if
    it matches the given regular expression, usually a match for a user identifier.

-   The ``ref()`` method is ignored by all but the ``Reference`` subclass,
    which returns reference made by the command to the parent chunk.

-   The ``weave()`` method weaves this into the output.  If a document text
    command, it is emitted directly; if a program source code command, 
    markup is applied.  In the case of cross-reference commands,
    the actual cross-reference content is emitted.  In the case of 
    reference commands, they are woven as a reference to a named
    chunk.

-   The ``tangle()`` method tangles this into the output.  If a
    this is a document text command, it is ignored; if a this is a
    program source code
    command, it is indented and emitted.  In the case of cross-reference
    commands, no output is produced.  In the case of reference
    commands, the named chunk is indented and emitted.


The attributes of a ``Command`` instance includes the line number on which
the command began, in ``lineNumber``.

@d Command superclass
@{
class Command:
    """A Command is the lowest level of granularity in the input stream."""
    chunk : "Chunk"
    text : str
    def __init__(self, fromLine: int = 0) -> None:
        self.lineNumber = fromLine+1 # tokenizer is zero-based
        self.logger = logging.getLogger(self.__class__.__qualname__)
        
    def __str__(self) -> str:
        return f"at {self.lineNumber!r}"
        
    @<Command analysis features: starts-with and Regular Expression search@>
    @<Command tangle and weave functions@>
@| Command
@}

@d Command analysis features...
@{
def startswith(self, prefix: str) -> bool:
    return False
def searchForRE(self, rePat: Pattern[str]) -> Match[str] | None:
    return None
def indent(self) -> int:
    return 0
@| startswith searchForRE
@}

@d Command tangle and weave...
@{
def ref(self, aWeb: "Web") -> str | None:
    return None
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    pass
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    pass
@| ref weave tangle
@}

TextCommand class
~~~~~~~~~~~~~~~~~~

A ``TextCommand`` is created by a ``Chunk`` or a ``NamedDocumentChunk`` when a 
``WebReader`` calls the chunk's ``appendText()`` method.

This Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 

An instance of the ``TextCommand`` class is a block of document text.  It can originate
in an anonymous block or a named chunk delimited with ``@@[`` and ``@@]``.

This subclass provides a concrete implementation for all of the methods.  Since
text is the author's original markup language, it is emitted directly to the weaver
or tangler.

..  todo::

    Use textwrap to snip off first 32 chars of the text.

@d TextCommand class...
@{
class TextCommand(Command):
    """A piece of document source text."""
    def __init__(self, text: str, fromLine: int = 0) -> None:
        super().__init__(fromLine)
        self.text = text
    def __str__(self) -> str:
        return f"at {self.lineNumber!r}: {self.text[:32]!r}..."
    def startswith(self, prefix: str) -> bool:
        return self.text.startswith(prefix)
    def searchForRE(self, rePat: Pattern[str]) -> Match[str] | None:
        return rePat.search(self.text)
    def indent(self) -> int:
        if self.text.endswith('\n'):
            return 0
        try:
            last_line = self.text.splitlines()[-1]
            return len(last_line)
        except IndexError:
            return 0
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        aWeaver.write(self.text)
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        aTangler.write(self.text)
@| TextCommand startswith searchForRE weave tangle
@}

CodeCommand class
~~~~~~~~~~~~~~~~~~

A ``CodeCommand`` is created by a ``NamedChunk`` when a 
``WebReader`` calls the ``appendText()`` method.
The Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 


An instance of the ``CodeCommand`` class is a block of program source code text.
It can originate in a named chunk (``@@d``) with a ``@@{`` and ``@@}`` delimiter.
Or it can be a file output chunk (``@@o``).


It uses the ``codeBlock()`` methods of a ``Weaver`` or ``Tangler``.  The weaver will 
insert appropriate markup for this code.  The tangler will assure that the prevailing
indentation is maintained.


@d CodeCommand class...
@{
class CodeCommand(TextCommand):
    """A piece of program source code."""
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        aWeaver.codeBlock(aWeaver.quote(self.text))
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        aTangler.codeBlock(self.text)
@| CodeCommand weave tangle
@}

XrefCommand superclass
~~~~~~~~~~~~~~~~~~~~~~~

An ``XrefCommand`` is created by the ``WebReader`` when any of the 
``@@f``, ``@@m``, ``@@u`` commands are found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``XrefCommand`` superclass defines any common features of the
various cross-reference commands (``@@f``, ``@@m``, ``@@u``).

The ``formatXref()`` method creates the body of a cross-reference
by the following algorithm:

1. Use the ``Weaver`` class ``xrefHead()`` method to emit the cross-reference header.

2. Sort the keys in the cross-reference mapping.

3. Use the ``Weaver`` class ``xrefLine()`` method to emit each line of the cross-reference mapping.

4. Use the ``Weaver`` class ``xrefFoot()`` method to emit the cross-reference footer.

If this command winds up in a tangle action, that use
is illegal.  An exception is raised and processing stops.

 
@d XrefCommand superclass...
@{
class XrefCommand(Command):
    """Any of the Xref-goes-here commands in the input."""
    def __str__(self) -> str:
        return f"at {self.lineNumber!r}: cross reference"
        
    def formatXref(self, xref: dict[str, list[int]], aWeaver: "Weaver") -> None:
        aWeaver.xrefHead()
        for n in sorted(xref):
            aWeaver.xrefLine(n, xref[n])
        aWeaver.xrefFoot()
        
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        raise Error('Illegal tangling of a cross reference command.')
@| XrefCommand formatXref tangle
@}

FileXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``FileXrefCommand`` is created by the ``WebReader`` when the 
``@@f`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``FileXrefCommand`` class weave method gets the
file cross reference from the overall web instance, and uses
the  ``formatXref()`` method of the ``XrefCommand`` superclass for format this result.


@d FileXrefCommand class...
@{
class FileXrefCommand(XrefCommand):
    """A FileXref command."""
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Weave a File Xref from @@o commands."""
        self.formatXref(aWeb.fileXref(), aWeaver)
@| FileXrefCommand weave
@}

MacroXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~

A ``MacroXrefCommand`` is created by the ``WebReader`` when the 
``@@m`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``MacroXrefCommand`` class weave method gets the
named chunk (macro) cross reference from the overall web instance, and uses
the ``formatXref()`` method of the ``XrefCommand`` superclass method for format this result.


@d MacroXrefCommand class...
@{
class MacroXrefCommand(XrefCommand):
    """A MacroXref command."""
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Weave the Macro Xref from @@d commands."""
        self.formatXref(aWeb.chunkXref(), aWeaver)
@| MacroXrefCommand weave
@}

UserIdXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``MacroXrefCommand`` is created by the ``WebReader`` when the 
``@@u`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``UserIdXrefCommand`` class weave method gets the
user identifier cross reference information from the 
overall web instance.  It then formats this line using the following 
algorithm, which is similar to the algorithm in the ``XrefCommand`` superclass.

1.  Use the ``Weaver`` class ``xrefHead()`` method to emit the cross-reference header.

2.  Sort the keys in the cross-reference mapping.

3.  Use the ``Weaver`` class ``xrefDefLine()`` method to emit each line of the cross-reference definition mapping.

4.  Use the ``Weaver`` class ``xrefFoor()`` method to emit the cross-reference footer.


@d UserIdXrefCommand class...
@{
class UserIdXrefCommand(XrefCommand):
    """A UserIdXref command."""
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Weave a user identifier Xref from @@d commands."""
        ux = aWeb.userNamesXref()
        if len(ux) != 0:
            aWeaver.xrefHead()
            for u in sorted(ux):
                defn, refList = ux[u]
                aWeaver.xrefDefLine(u, defn, refList)
            aWeaver.xrefFoot()
        else:
            aWeaver.xrefEmpty()
@| UserIdXrefCommand weave
@}

ReferenceCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``ReferenceCommand`` instance is created by a ``WebReader`` when
a ``@@<``\ *name*\ ``@@>`` construct in is found in the input stream.  This is attached
to the current ``Chunk`` being built by the WebReader.  
 

During a weave, this creates a markup reference to
another ``NamedChunk``.  During tangle, this actually includes the ``NamedChunk`` 
at this point in the tangled output file.


The constructor creates several attributes of an instance
of a ``ReferenceCommand``.


:refTo:
    the name of the chunk to which this refers, possibly 
    elided with a trailing ``'...'``.

:fullName:
    the full name of the chunk to which this refers.

:chunkList:
    the list of the chunks to which the name refers.


@d ReferenceCommand class...
@{
class ReferenceCommand(Command):
    """A reference to a named chunk, via @@<name@@>."""
    def __init__(self, refTo: str, fromLine: int = 0) -> None:
        super().__init__(fromLine)
        self.refTo = refTo
        self.fullname = None
        self.sequenceList = None
        self.chunkList: list[Chunk] = []
        
    def __str__(self) -> str:
        return "at {self.lineNumber!r}: reference to chunk {self.refTo!r}"
        
    @<ReferenceCommand resolve a referenced chunk name@>
    @<ReferenceCommand refers to a chunk@>
    @<ReferenceCommand weave a reference to a chunk@>
    @<ReferenceCommand tangle a referenced chunk@>
@| ReferenceCommand 
@}

The ``resolve()`` method queries the overall ``Web`` instance for the full
name and sequence number for this chunk reference.  This is used
by the ``Weaver`` class ``referenceTo()`` method to write the markup reference
to the chunk.


@d ReferenceCommand resolve...
@{
def resolve(self, aWeb: "Web") -> None:
    """Expand our chunk name and list of parts"""
    self.fullName = aWeb.fullNameFor(self.refTo)
    self.chunkList = aWeb.getchunk(self.refTo)
@| resolve
@}

The ``ref()`` method is a request that is delegated by a ``Chunk``;
it resolves the reference this Command makes within the containing Chunk.
When the Chunk iterates through the Commands, it can accumulate a list of 
Chinks to which it refers.


@d ReferenceCommand refers to a chunk
@{
def ref(self, aWeb: "Web") -> str:
    """Find and return the full name for this reference."""
    self.resolve(aWeb)
    return self.fullName
@| usedBy
@}

The ``weave()`` method inserts a markup reference to a named
chunk.  It uses the ``Weaver`` class ``referenceTo()`` method to format
this appropriately for the document type being woven.


@d ReferenceCommand weave...
@{
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    """Create the nicely formatted reference to a chunk of code."""
    self.resolve(aWeb)
    aWeb.weaveChunk(self.fullName, aWeaver)
@| weave
@}

The ``tangle()`` method inserts the resolved chunk in this
place.  When a chunk is tangled, it sets the indent,
inserts the chunk and resets the indent.

This is where the Tangler indentation is updated by a reference.
Or where indentation is set to a local zero because the included
Chunk is a no-indent Chunk.

@d ReferenceCommand tangle...
@{
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    """Create source code."""
    self.resolve(aWeb)
    
    self.logger.debug("Indent %r + %r", aTangler.context, self.chunk.previous_command.indent())    
    self.chunk.reference_indent(aWeb, aTangler, self.chunk.previous_command.indent())
    
    self.logger.debug("Tangling %r with chunks %r", self.fullName, self.chunkList)
    if len(self.chunkList) != 0:
        for p in self.chunkList:
            p.tangle(aWeb, aTangler)
    else:
        raise Error(f"Attempt to tangle an undefined Chunk, {self.fullName!s}.")

    self.chunk.reference_dedent(aWeb, aTangler)
@| tangle
@}

Reference Strategy
---------------------------------

The Reference Strategy has two implementations.  An instance
of this is injected into each Chunk by the Web.  By injecting this
algorithm, we assure that:

(1) each Chunk can produce all relevant reference information and 

(2) a simple configuration change can be applied to the document.


Reference Superclass
~~~~~~~~~~~~~~~~~~~~~

The superclass is an abstract class that defines the interface for
this object.


@d Reference class hierarchy... 
@{
class Reference:
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
    def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
        """Return a list of Chunks."""
        return []
@}

SimpleReference Class
~~~~~~~~~~~~~~~~~~~~~

The SimpleReference subclass does the simplest version of resolution. It returns
the ``Chunks`` referenced.
    
@d Reference class hierarchy... 
@{
class SimpleReference(Reference):
    def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
        refBy = aChunk.referencedBy
        return refBy
@}

TransitiveReference Class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The TransitiveReference subclass does a transitive closure of all
references to this Chunk.

This requires walking through the ``Web`` to locate "parents" of each referenced
``Chunk``.

@d Reference class hierarchy... 
@{
class TransitiveReference(Reference):
    def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
        refBy = aChunk.referencedBy
        self.logger.debug("References: %r(%d) %r", aChunk.name, aChunk.seq, refBy)
        return self.allParentsOf(refBy)
    def allParentsOf(self, chunkList: list[Chunk], depth: int = 0) -> list[Chunk]:
        """Transitive closure of parents via recursive ascent.
        """
        final = []
        for c in chunkList:
            final.append(c)
            final.extend(self.allParentsOf(c.referencedBy, depth+1))
        self.logger.debug(f"References: {'--':>{2*depth}s} {final!s}")
        return final
@}


Error class
------------

An ``Error`` is raised whenever processing cannot continue.  Since it
is a subclass of Exception, it takes an arbitrary number of arguments.  The
first should be the basic message text.  Subsequent arguments provide 
additional details.  We will try to be sure that
all of our internal exceptions reference a specific chunk, if possible.
This means either including the chunk as an argument, or catching the 
exception and appending the current chunk to the exception's arguments.

The Python ``raise`` statement takes an instance of ``Error`` and passes it
to the enclosing ``try/except`` statement for processing.

The typical creation is as follows:

..  parsed-literal::

    raise Error(f"No full name for {chunk.name!r}", chunk)

A typical exception-handling suite might look like this:

..  parsed-literal::

    try:
        *...something that may raise an Error or Exception...*
    except Error as e:
        print(e.args) # this is a pyWeb internal Error
    except Exception as w:
        print(w.args) # this is some other Python Exception

The ``Error`` class is a subclass of ``Exception`` used to differentiate 
application-specific
exceptions from other Python exceptions.  It does no additional processing,
but merely creates a distinct class to facilitate writing ``except`` statements.


@d Error class...
@{
class Error(Exception): pass
@| Error @}

The Web and WebReader Classes
-----------------------------

The overall web of chunks is carried in a 
single instance of the ``Web`` class that is the principle parameter for the weaving and tangling actions.  
Broadly, the functionality of a Web can be separated into several areas.

It supports  construction methods used by ``Chunks`` and ``WebReader``.

It also supports "enrichment" of the web, once all the Chunks are known. 
This is a stateful update to the web.  Each Chunk is updated with Chunk 
references it makes as well as Chunks which reference it.

It supports ``Chunk`` cross-reference methods that traverse this enriched data.
This includes a kind of validity check to be sure that everything is used once
and once only. 

More importantly, it supports tangle and weave operations.

Fundamentally, a ``Web`` is a hybrid list-dictionary.  

-   It's a mapping of chunks that also offers a 
    moderately sophisticated
    lookup, including exact match for a chunk name and an approximate match for a chunk name. 
    There are several methods to  resolve references among chunks.

-   It's a sequence that retains all chunks in order, also. 
    It may be a good candidate to be an ``OrderedDict``, but there are multiple keys. Both Chunk
    names and chunk numbers are used. 

A web instance has a number of attributes.

:webFileName:
    the name of the original .w file.

:chunkSeq:
    the sequence of ``Chunk`` instances as seen in the input file.
    To support anonymous chunks, and to assure that the original input document order
    is preserved, we keep all chunks in a master sequential list.

:output:
    the ``@@o`` named ``OutputChunk`` chunks.  
    Each element of this  dictionary is a sequence of chunks that have the same name. 
    The first is the initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:named:
    the ``@@d`` named ``NamedChunk`` chunks.  Each element of this 
    dictionary is a sequence of chunks that have the same name.  The first is the
    initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:usedBy:
    the cross reference of chunks referenced by commands in other
    chunks.

!sequence:
    is used to assign a unique sequence number to each
    named chunk.
    
@d Web class...
@{
class Web:
    """The overall Web of chunks."""
    def __init__(self, filename: str | None = None) -> None:
        self.webFileName = filename
        self.chunkSeq: list[Chunk] = [] 
        self.output: dict[str, list[Chunk]] = {} # Map filename to Chunk
        self.named: dict[str, list[Chunk]] = {} # Map chunkname to Chunk
        self.sequence = 0
        self.errors = 0
        self.logger = logging.getLogger(self.__class__.__qualname__)
        
    def __str__(self) -> str:
        return f"Web {self.webFileName!r}"

    @<Web construction methods used by Chunks and WebReader@>
    @<Web Chunk name resolution methods@>
    @<Web Chunk cross reference methods@>
    @<Web determination of the language from the first chunk@>
    @<Web tangle the output files@>
    @<Web weave the output document@>
@| Web 
@}

Web Construction
~~~~~~~~~~~~~~~~~

During web construction, it is convenient to capture
information about the individual ``Chunk`` instances being appended to
the web.  This done using a **Callback** design pattern.
Each subclass of ``Chunk`` provides an override for the ``Chunk`` class
``webAdd()`` method.  This override calls one of the appropriate
web construction methods.

Also note that the full name for a chunk can be given
either as part of the definition, or as part a reference.
Typically, the first reference has the full name and the definition
has the elided name.  This allows a reference to a chunk
to contain a more complete description of the chunk.

We include a weakref to the ``Web`` to each ``Chunk``.

@d Imports...
@{
import weakref
@| weakref
@}

@d Web construction...
@{
@<Web add full chunk names, ignoring abbreviated names@>
@<Web add an anonymous chunk@>
@<Web add a named macro chunk@>
@<Web add an output file definition chunk@>
@}

A name is only added to the known names when it is
a full name, not an abbreviation ending with ``"..."``.
Abbreviated names are quietly skipped until the full name
is seen.


The algorithm for the ``addDefName()`` method, then is as follows:

1.  Use the ``fullNameFor()`` method to locate the full name.

2.  If no full name was found (the result of ``fullNameFor()`` ends with ``'...'``), 
    ignore this name as an abbreviation with no definition.

3.  If this is a full name and the name was not in the ``named`` mapping, add this full name to the mapping.



This name resolution approach presents a problem when a chunk's first definition
uses an abbreviated name.  

..  note:: Improved use case needed.

    We can be more flexible about assembling the web if we 
    tolerate "..." elipsis as the initial use of a name.
        
    We have to fold the abbreviated name(s) 
    into the Web. Prior to tangling, we have to
    resolve the various abbreviated names to their proper
    full names. This would then merge the chunks into a single
    sequence. 

    We preserve source document ordering between the variations
    on the name using the chunk sequence numbers.
    
    Here "prior to tangling" means either eagerly -- as each full name arrives -- 
    or lazily -- after the entire Web is built.
    
    We would no longer need to return a value from this function, either.

@d Web add full chunk names...
@{
def addDefName(self, name: str) -> str | None:
    """Reference to or definition of a chunk name."""
    nm = self.fullNameFor(name)
    if nm is None: return None
    if nm[-3:] == '...':
        self.logger.debug("Abbreviated reference %r", name)
        return None # first occurance is a forward reference using an abbreviation
    if nm not in self.named:
        self.named[nm] = []
        self.logger.debug("Adding empty chunk %r", name)
    return nm
@| addDefName
@}

An anonymous ``Chunk`` is kept in a sequence of Chunks, used for
tangling.


@d Web add an anonymous chunk
@{
def add(self, chunk: Chunk) -> None:
    """Add an anonymous chunk."""
    self.chunkSeq.append(chunk)
    chunk.web = weakref.ref(self)
@| add
@}

A named ``Chunk`` is defined with a ``@@d`` command.
It is collected into a mapping of ``NamedChunk`` instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.


All chunks are also placed in the overall sequence of chunks.
This overall sequence is used for weaving the document.


The ``addDefName()`` method is used to resolve this name if
it is an abbreviation, or add it to the mapping if this
is the first occurance of the name.  If the name cannot be
added, an instance of our ``Error`` class is raised.  If the name exists or 
was added, the chunk is appended to the chunk list associated
with this name.


The Web's sequence counter is incremented, and this 
unique sequence number sets the ``seq`` attribute of the ``Chunk``.
If the chunk list was empty, this is the first chunk, the
``initial`` flag is set to True when there's only one element
in the list.  Otherwise, it's False.

..  note:: Improved use case.

    If we improve name resolution, then the if and exception can go away.
    The ``addDefName()`` no longer needs to return a value. 

@d Web add a named macro chunk
@{
def addNamed(self, chunk: Chunk) -> None:
    """Add a named chunk to a sequence with a given name."""
    self.chunkSeq.append(chunk)
    chunk.web = weakref.ref(self)
    nm = self.addDefName(chunk.name)
    if nm:
        # We found the full name for this chunk
        self.sequence += 1
        chunk.seq = self.sequence
        chunk.fullName = nm
        self.named[nm].append(chunk)
        chunk.initial = len(self.named[nm]) == 1
        self.logger.debug("Extending chunk %r from %r", nm, chunk.name)
    else:
        raise Error(f"No full name for {chunk.name!r}", chunk)
@| addNamed 
@}

An output file definition ``Chunk`` is defined with an ``@@o``
command.  It is collected into a mapping of ``OutputChunk`` instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.


Note that file names cannot be abbreviated.

All chunks are also placed in overall sequence of chunks.
This overall sequence is used for weaving the document.


If the name does not exist in the ``output`` mapping,
the name is added with an empty sequence of chunks.
In all cases, the chunk is 
appended to the chunk list associated
with this name.


The web's sequence counter is incremented, and this 
unique sequence number sets the Chunk's ``seq`` attribute.
If the chunk list was empty, this is the first chunk, the
``initial`` flag is True if this is the first chunk.



@d Web add an output file definition chunk
@{
def addOutput(self, chunk: Chunk) -> None:
    """Add an output chunk to a sequence with a given name."""
    self.chunkSeq.append(chunk)
    chunk.web = weakref.ref(self)
    if chunk.name not in self.output:
        self.output[chunk.name] = []
        self.logger.debug("Adding chunk %r", chunk.name)
    self.sequence += 1
    chunk.seq = self.sequence
    chunk.fullName = chunk.name
    self.output[chunk.name].append(chunk)
    chunk.initial = len(self.output[chunk.name]) == 1
@| addOutput
@}

Web Chunk Name Resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~

Web Chunk name resolution has three aspects.  The first
is resolving elided names (those ending with ``...``) to their
full names.  The second is finding the named chunk
in the web structure.  The third is returning a reference
to a specific chunk including the name and sequence number.

Note that a Chunk name actually refers to a sequence
of Chunk instances.  Multiple definitions for a Chunk are allowed, and
all of the definitions are concatenated to create the complete
Chunk.  This complexity makes it unwise to return the sequence
of same-named Chunk; therefore, we put the burden on the Web to 
process all Chunk with a given name, in sequence.

The ``fullNameFor()`` method resolves full name for a chunk as follows:

1.  If the string is already in the ``named`` mapping, this is the full name

2.  If the string ends in ``'...'``, visit each key in the dictionary 
    to see if the key starts with the string up to the trailing ``'...'``.  
    If a match is found, the dictionary key is the full name.

3.  Otherwise, treat this as a full name.


@d Web Chunk name resolution...
@{
def fullNameFor(self, name: str) -> str:
    """Resolve "..." names into the full name."""
    if name in self.named: return name
    if name[-3:] == '...':
        best = [ n for n in self.named.keys()
            if n.startswith(name[:-3]) ]
        if len(best) > 1:
            raise Error(f"Ambiguous abbreviation {name!r}, matches {list(sorted(best))!r}")
        elif len(best) == 1: 
            return best[0]
    return name
@| fullNameFor
@}

The ``getchunk()`` method locates a named sequence of chunks by first determining the full name
for the identifying string.  If full name is in the ``named`` mapping, the sequence
of chunks is returned.  Otherwise, an instance of our ``Error`` class is raised because the name
is unresolvable.


It might be more helpful for debugging to emit this as an error in the
weave and tangle results and keep processing.  This would allow an author to
catch multiple errors in a single run of **py-web-tool** .
 
@d Web Chunk name resolution...
@{
def getchunk(self, name: str) -> list[Chunk]:
    """Locate a named sequence of chunks."""
    nm = self.fullNameFor(name)
    if nm in self.named:
        return self.named[nm]
    raise Error(f"Cannot resolve {name!r} in {self.named.keys()!r}")
@| getchunk
@}

Web Cross-Reference Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Cross-reference support includes creating and reporting
on the various cross-references available in a web.  This includes
creating the list of chunks that reference a given chunk;
and returning the file, macro and user identifier cross references.


Each ``Chunk`` has a list ``Reference`` commands that shows the chunks
to which a chunk refers.  These relationships must be reversed to show
the chunks that refer to a given chunk.  This is done by traversing
the entire web of named chunks and recording each chunk-to-chunk reference.
This mapping has the referred-to chunk as 
the key, and a sequence of referring chunks as the value.


The accumulation is initiated by the web's ``createUsedBy()`` method.  This
method visits a ``Chunk``, calling the ``genReferences()`` method, 
passing in the ``Web`` instance
as an argument.  Each ``Chunk`` class ``genReferences()`` method, in turn, 
invokes the ``usedBy()`` method
of each ``Command`` instance in the chunk.  Most commands do nothing, 
but a ``ReferenceCommand``
will resolve the name to which it refers.


When the ``createUsedBy()`` method has accumulated the entire cross 
reference, it also assures that all chunks are used exactly once.

@d Web Chunk cross reference methods...
@{
def createUsedBy(self) -> None:
    """Update every piece of a Chunk to show how the chunk is referenced.
    Each piece can then report where it's used in the web.
    """
    for aChunk in self.chunkSeq:
        #usage = (self.fullNameFor(aChunk.name), aChunk.seq)
        for aRefName in aChunk.genReferences(self):
            for c in self.getchunk(aRefName):
                c.referencedBy.append(aChunk)
                c.refCount += 1
    @<Web Chunk check reference counts are all one@>
@| createUsedBy
@}

We verify that the reference count for a
Chunk is exactly one.  We don't gracefully tolerate multiple references to
a Chunk or unreferenced chunks.

@d Web Chunk check...
@{
for nm in self.no_reference():
    self.logger.warning("No reference to %r", nm)
for nm in self.multi_reference():
    self.logger.warning("Multiple references to %r", nm)
for nm in self.no_definition():
    self.logger.error("No definition for %r", nm)
    self.errors += 1
@}

The one-pass version:

..  parsed-literal::

    for nm,cl in self.named.items():
        if len(cl) > 0:
            if cl[0].refCount == 0:
               self.logger.warning("No reference to %r", nm)
            elif cl[0].refCount > 1:
               self.logger.warning("Multiple references to %r", nm)
        else:
            self.logger.error("No definition for %r", nm)


We use three methods to filter chunk names into 
the various warning categories.  The ``no_reference`` list
is a list of chunks defined by never referenced.
The ``multi_reference`` list
is a list of chunks defined by never referenced.
The ``no_definition`` list
is a list of chunks referenced but not defined.


@d Web Chunk cross reference methods...
@{
def no_reference(self) -> list[str]:
    return [nm for nm, cl in self.named.items() if len(cl)>0 and cl[0].refCount == 0]
def multi_reference(self) -> list[str]:
    return [nm for nm, cl in self.named.items() if len(cl)>0 and cl[0].refCount > 1]
def no_definition(self) -> list[str]:
    return [nm for nm, cl in self.named.items() if len(cl) == 0] 
@| no_reference multi_reference no_definition
@}

The ``fileXref()`` method visits all named file output chunks in ``output`` and
collects the sequence numbers of each section in the sequence of chunks.


The ``chunkXref()`` method uses the same algorithm as a the ``fileXref()`` method,
but applies it to the ``named`` mapping.


@d Web Chunk cross reference methods...
@{
def fileXref(self) -> dict[str, list[int]]:
    fx = {}
    for f, cList in self.output.items():
        fx[f] = [c.seq for c in cList]
    return fx
def chunkXref(self) -> dict[str, list[int]]:
    mx = {}
    for n, cList in self.named.items():
        mx[n] = [c.seq for c in cList]
    return mx
@| fileXref chunkXref
@}

The ``userNamesXref()`` method creates a mapping for each
user identifier.  The value for this mapping is a tuple
with the chunk that defined the identifer (via a ``@@|`` command), 
and a sequence of chunks that reference the identifier. 


For example:
``{'Web': (87, (88,93,96,101,102,104)), 'Chunk': (53, (54,55,56,60,57,58,59))}``, 
shows that the identifier
``'Web'`` is defined in chunk with a sequence number of 87, and referenced
in the sequence of chunks that follow.


This works in two passes:

1.  ``_gatherUserId()`` gathers all user identifiers

2.  ``_updateUserId()`` searches all text commands for the identifiers 
    and updates the ``Web`` class cross reference information.



@d Web Chunk cross reference methods...
@{
def userNamesXref(self) -> dict[str, tuple[int, list[int]]]:
    ux: dict[str, tuple[int, list[int]]] = {}
    self._gatherUserId(self.named, ux)
    self._gatherUserId(self.output, ux)
    self._updateUserId(self.named, ux)
    self._updateUserId(self.output, ux)
    return ux
    
def _gatherUserId(self, chunkMap: dict[str, list[Chunk]], ux: dict[str, tuple[int, list[int]]]) -> None:
    @<collect all user identifiers from a given map into ux@>
    
def _updateUserId(self, chunkMap: dict[str, list[Chunk]], ux: dict[str, tuple[int, list[int]]]) -> None:
    @<find user identifier usage and update ux from the given map@>
@| userNamesXref _gatherUserId _updateUserId
@}

User identifiers are collected by visiting each of the sequence of 
``Chunks`` that share the
same name; within each component chunk, if chunk has identifiers assigned
by the ``@@|`` command, these are seeded into the dictionary.
If the chunk does not permit identifiers, it simply returns an empty
list as a default action.

 
@d collect all user identifiers...
@{
for n,cList in chunkMap.items():
    for c in cList:
        for id in c.getUserIDRefs():
            ux[id] = (c.seq, [])
@}

User identifiers are cross-referenced by visiting 
each of the sequence of ``Chunks`` that share the
same name; within each component chunk, visit each user identifier;
if the ``Chunk`` class ``searchForRE()`` method matches an identifier, 
this is appended to the sequence of chunks that reference the original user identifier.


@d find user identifier usage...
@{
# examine source for occurrences of all names in ux.keys()
for id in ux.keys():
    self.logger.debug("References to %r", id)
    idpat = re.compile(f'\\W{id}\\W')
    for n,cList in chunkMap.items():
        for c in cList:
            if c.seq != ux[id][0] and c.searchForRE(idpat):
                ux[id][1].append(c.seq)
@}

Loop Detection
~~~~~~~~~~~~~~~~~~~~~~~~~~

How do we assure that the web is a proper tree and doesn't contain any loops?

Consider this example web 

..  parsed-literal::

    @@o example1 @@{
        @@<part 1A@@>
    @@}
    
    @@d part 1A @@{
        @@<part 1B@@>
    @@}
    
    @@d part 1B @@{
        @@<part 1A@@>
    @@}
    
All valid chunks are must be referenced from a ``@@o`` chunk, either directly,
or indirectly via one or more ``@@<``\ *name*\ ``@@>`` references. This defines a 
proper tree with ``@@o`` at the root and children at each ``@@d``.

Each chunk can have multiple references to further ``@@d`` definitions.
No chunk can reference the ``@@o`` definition at the root.

To be circular, two ``@@d`` chunks must reference each other.  

To be valid, either (or both) must be named by the ``@@o``. There will, therefore,
be two references: from the ``@@o`` and a ``@@d``. Our check for duplicate references will spot this.

We do not need to do a proper BFS or DFS through the graph to check for loops.
The simple reference count will do.

Tangle and Weave Support
~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``language()`` method makes a stab at determining the output language.
The determination of the language can be done a variety of ways.
One is to use command line parameters, another is to use the filename
extension on the input file.

We examine the first few characters of input.  A proper HTML, XHTML or
XML file begins with '<!', '<?' or '<H'.  
LaTeX files typically begin with '%' or '\'.
Everything else is probably RST.

@d Web determination of the language...
@{
def language(self, preferredWeaverClass: type["Weaver"] | None = None) -> "Weaver":
    """Construct a weaver appropriate to the document's language"""
    if preferredWeaverClass:
        return preferredWeaverClass()
    self.logger.debug("Picking a weaver based on first chunk %r", str(self.chunkSeq[0])[:4])
    if self.chunkSeq[0].startswith('<'): 
        return HTML()
    if self.chunkSeq[0].startswith('%') or self.chunkSeq[0].startswith('\\'):  
        return LaTeX()
    return RST()
@| language
@}

The ``tangle()`` method of the ``Web`` class performs 
the ``tangle()`` method for each ``Chunk`` of each
named output file.  Note that several ``Chunks`` may share the file name, requiring
the file be composed of material from each ``Chunk``, in order.

@d Web tangle...
@{
def tangle(self, aTangler: "Tangler") -> None:
    for f, c in self.output.items():
        with aTangler.open(f):
            for p in c:
                p.tangle(self, aTangler)
@| tangle
@}

The ``weave()`` method of the ``Web`` class creates the final documentation.
This is done by stepping through each ``Chunk`` in sequence
and weaving the chunk into the resulting file via the ``Chunk`` class ``weave()`` method.

During weaving of a chunk, the chunk may reference another
chunk.  When weaving a reference to a named chunk (output or ordinary programming
source defined with ``@@{``), this does not lead to transitive weaving: only a
reference is put in from one chunk to another.  However, when weaving
a chunk defined with ``@@[``, the chunk *is* expanded when weaving.
The decision is delegated to the referenced chunk.

**TODO** Can we refactor weaveChunk out of here entirely?
    Should it go in ``ReferenceCommand weave...``?

@d Web weave...
@{
def weave(self, aWeaver: "Weaver") -> None:
    self.logger.debug("Weaving file from %r", self.webFileName)
    if not self.webFileName:
        raise Error("No filename supplied for weaving.")
    basename, _ = os.path.splitext(self.webFileName)
    with aWeaver.open(basename):
        for c in self.chunkSeq:
            c.weave(self, aWeaver)
            
def weaveChunk(self, name: str, aWeaver: "Weaver") -> None:
    self.logger.debug("Weaving chunk %r", name)
    chunkList = self.getchunk(name)
    if not chunkList:
        raise Error(f"No Definition for {name!r}")
    chunkList[0].weaveReferenceTo(self, aWeaver)
    for p in chunkList[1:]:
        aWeaver.write(aWeaver.referenceSep())
        p.weaveShortReferenceTo(self, aWeaver)
@| weave weaveChunk
@}

The WebReader Class
~~~~~~~~~~~~~~~~~~~~~~

There are two forms of the constructor for a ``WebReader``.  The 
initial ``WebReader`` instance is created with code like the following:


..  parsed-literal::

    p = WebReader()
    p.command = options.commandCharacter 

This will define the command character; usually provided as a command-line parameter to the application.

When processing an include file (with the ``@@i`` command), a child ``WebReader``
instance is created with code like the following:

..  parsed-literal::

    c = WebReader(parent=parentWebReader)



This will inherit the configuration from the parent ``WebReader``.  
This will also include a  reference from child to parent so that embedded Python expressions
can view the entire input context.


The ``WebReader`` class parses the input file into command blocks.
These are assembled into ``Chunks``, and the ``Chunks`` are assembled into the document
``Web``.  Once this input pass is complete, the resulting ``Web`` can be tangled or
woven.


"Structural" commands define the structure of the ``Chunks``.  The  structural commands 
are ``@@d`` and ``@@o``, as well as the ``@@{``, ``@@}``, ``@@[``, ``@@]`` brackets, 
and the ``@@i`` command to include another file.


"Inline" commands are inline within a ``Chunk``: they define internal ``Commands``.  
Blocks of text are minor commands, as well as the ``@@<``\ *name*\ ``@@>`` references.
The ``@@@@`` escape is also
handled here so that all further processing is independent of any parsing.

"Content" commands generate woven content. These include 
the various cross-reference commands (``@@f``, ``@@m`` and ``@@u``).  


There are two class-level ``OptionParser`` instances used by this class.

:output_option_parser:
    An ``OptionParser`` used to parse the ``@@o`` command.
    
:definition_option_parser:
    An ``OptionParser`` used to parse the ``@@d`` command.

The class has the following attributes:

:parent:
    is the outer ``WebReader`` when processing a ``@@i`` command.

:command:
    is the command character; a WebReader will use the parent command 
    character if the parent is not ``None``.

:permitList:
    is the list of commands that are permitted to fail.  This is generally 
    an empty list or ``('@@i',)``.

:_source:
    The open source being used by ``load()``.
    
:fileName:
    is used to pass the file name to the Web instance.

:theWeb:
    is the current open Web.

:tokenizer:
    An instance of ``Tokenizer`` used to parse the input. This is built
    when ``load()`` is called.
    
:aChunk:
    is the current open Chunk being built.
    
:totalLines:
:totalFiles:
    Summaries

@d WebReader class...
@{
class WebReader:
    """Parse an input file, creating Chunks and Commands."""

    output_option_parser = OptionParser(
        OptionDef("-start", nargs=1, default=None),
        OptionDef("-end", nargs=1, default=""),
        OptionDef("argument", nargs='*'),
    )

    definition_option_parser = OptionParser(
        OptionDef("-indent", nargs=0),
        OptionDef("-noindent", nargs=0),
        OptionDef("argument", nargs='*'),
    )

    # State of reading and parsing.
    tokenizer: Tokenizer
    aChunk: Chunk
    
    # Configuration
    command: str
    permitList: list[str]
    
    # State of the reader
    _source: TextIO
    fileName: str
    theWeb: "Web"

    def __init__(self, parent: Optional["WebReader"] = None) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)

        # Configuration of this reader.
        self.parent = parent
        if self.parent: 
            self.command = self.parent.command
            self.permitList = self.parent.permitList
        else: # Defaults until overridden
            self.command = '@@'
            self.permitList = []
                    
        # Summary
        self.totalLines = 0
        self.totalFiles = 0
        self.errors = 0 
        
        @<WebReader command literals@>
        
    def __str__(self) -> str:
        return self.__class__.__name__
        
    @<WebReader location in the input stream@>
    @<WebReader load the web@>
    @<WebReader handle a command string@>
@| WebReader @}

Command recognition is done via a **Chain of Command**-like design.
There are two conditions: the command string is recognized or it is not recognized.
If the command is recognized, ``handleCommand()`` either:

    -   (for "structural" commands) attaches the current ``Chunk`` (*self.aChunk*) to the 
        current ``Web`` (*self.aWeb*), **or**

    -   (for "inline" and "content" commands) create a ``Command``, attach it to the current 
        ``Chunk`` (*self.aChunk*)

and returns a true result.

If the command is not recognized, ``handleCommand()`` returns false.

A subclass can override ``handleCommand()`` to 

(1) call this superclass version;

(2) if the command is unknown to the superclass, 
    then the subclass can attempt to process it;

(3) if the command is unknown to both classes, 
    then return false.  Either a subclass will handle it, or the default activity taken
    by ``load()`` is to treat the command a text, but also issue a warning.

@d WebReader handle a command...
@{
def handleCommand(self, token: str) -> bool:
    self.logger.debug("Reading %r", token)
    @<major commands segment the input into separate Chunks@>
    @<minor commands add Commands to the current Chunk@>
    elif token[:2] in (self.cmdlcurl,self.cmdlbrak):
        # These should have been consumed as part of @@o and @@d parsing
        self.logger.error("Extra %r (possibly missing chunk name) near %r", token, self.location())
        self.errors += 1
    else:
        return False  # did not recogize the command
    return True  # did recognize the command
@| handleCommand
@}

The following sequence of ``if``-``elif`` statements identifies
the structural commands that partition the input into separate ``Chunks``.

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

An output chunk has the form ``@@o`` *name* ``@@{`` *content* ``@@}``.
We use the first two tokens to name the ``OutputChunk``.  We simply expect
the ``@@{`` separator.  We then attach all subsequent commands
to this chunk while waiting for the final ``@@}`` token to end the chunk.

We'll use an ``OptionParser`` to locate the optional parameters.  This will then let
us build an appropriate instance of ``OutputChunk``.

With some small additional changes, we could use ``OutputChunk(**options)``.
    
@d start an OutputChunk...
@{
args = next(self.tokenizer)
self.expect((self.cmdlcurl,))
options = self.output_option_parser.parse(args)
self.aChunk = OutputChunk(
    name=' '.join(options['argument']),
    comment_start=''.join(options.get('start', "# ")),
    comment_end=''.join(options.get('end', "")),
)
self.aChunk.fileName = self.fileName 
self.aChunk.webAdd(self.theWeb)
# capture an OutputChunk up to @@}
@}

A named chunk has the form ``@@d`` *name* ``@@{`` *content* ``@@}`` for
code and ``@@d`` *name* ``@@[`` *content* ``@@]`` for document source.
We use the first two tokens to name the ``NamedChunk`` or ``NamedDocumentChunk``.  
We expect either the ``@@{`` or ``@@[`` separator, and use the actual
token found to choose which subclass of ``Chunk`` to create.
We then attach all subsequent commands
to this chunk while waiting for the final ``@@}`` or ``@@]`` token to 
end the chunk.

We'll use an ``OptionParser`` to locate the optional parameter of ``-noindent``.

[Or possibly ``-indent`` *number*?]

Then we can use options to create an appropriate subclass of ``NamedChunk``.
        
If "-indent" is in options, this is the default. 
If both are in the options, we can provide a warning, I guess.

    **TODO** Add a warning for conflicting options.

@d start a NamedChunk...
@{
args = next(self.tokenizer)
brack = self.expect((self.cmdlcurl,self.cmdlbrak))
options = self.output_option_parser.parse(args)
name = ' '.join(options['argument'])

if brack == self.cmdlbrak:
    self.aChunk = NamedDocumentChunk(name)
elif brack == self.cmdlcurl:
    if '-noindent' in options:
        self.aChunk = NamedChunk_Noindent(name)
    else:
        self.aChunk = NamedChunk(name)
elif brack == None:
    pass # Error noted by expect()
else:
    raise Error("Design Error")

self.aChunk.fileName = self.fileName 
self.aChunk.webAdd(self.theWeb)
# capture a NamedChunk up to @@} or @@]
@}

An import command has the unusual form of ``@@i`` *name*, with no trailing
separator.  When we encounter the ``@@i`` token, the next token will start with the
file name, but may continue with an anonymous chunk.  We require that all ``@@i`` commands
occur at the end of a line, and break on the ``'\n'`` which must occur after the file name.
This permits file names with embedded spaces. It also permits arguments and options,
if really necessary.

Once we have split the file name away from the rest of the following anonymous chunk,
we push the following token back into the token stream, so that it will be the 
first token examined at the top of the ``load()`` loop.

We create a child ``WebReader`` instance to process the included file.  The entire file 
is loaded into the current ``Web`` instance.  A new, empty ``Chunk`` is created at the end
of the file so that processing can resume with an anonymous ``Chunk``.

The reader has a ``permitList`` attribute.
This lists any commands where failure is permitted.  Currently, only the ``@@i`` command
can be set to permit failure; this allows a ``.w`` to include
a file that does not yet exist.  
 
The primary use case for this feature is when weaving test output.
The first pass of **py-web-tool**  tangles the program source files; they are
then run to create test output; the second pass of **py-web-tool**  weaves this
test output into the final document via the ``@@i`` command.

@d import another file
@{
incFile = next(self.tokenizer).strip()
try:
    self.logger.info("Including %r", incFile)
    include = WebReader(parent=self)
    include.load(self.theWeb, incFile)
    self.totalLines += include.tokenizer.lineNumber
    self.totalFiles += include.totalFiles
    if include.errors:
        self.errors += include.errors
        self.logger.error("Errors in included file %r, output is incomplete.", incFile)
except Error as e:
    self.logger.error("Problems with included file %r, output is incomplete.", incFile)
    self.errors += 1
except IOError as e:
    self.logger.error("Problems finding included file %r, output is incomplete.", incFile)
    # Discretionary -- sometimes we want to continue
    if self.cmdi in self.permitList: pass
    else: raise  # Seems heavy-handed, but, the file wasn't found!
self.aChunk = Chunk()
self.aChunk.webAdd(self.theWeb)
@}

When a ``@@}`` or ``@@]`` are found, this finishes a named chunk.  The next
text is therefore part of an anonymous chunk.


Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@@{`` or ``@@[``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if a trailing bracket was necessary.
For the base ``Chunk`` class, this would be false, but for all other subclasses of
``Chunk``, this would be true.


@d finish a chunk...
@{
self.aChunk = Chunk()
self.aChunk.webAdd(self.theWeb)
@}

The following sequence of ``elif`` statements identifies
the minor commands that add ``Command`` instances to the current open ``Chunk``. 


@d minor commands...
@{
elif token[:2] == self.cmdpipe:
    @<assign user identifiers to the current chunk@>
elif token[:2] == self.cmdf:
    self.aChunk.append(FileXrefCommand(self.tokenizer.lineNumber))
elif token[:2] == self.cmdm:
    self.aChunk.append(MacroXrefCommand(self.tokenizer.lineNumber))
elif token[:2] == self.cmdu:
    self.aChunk.append(UserIdXrefCommand(self.tokenizer.lineNumber))
elif token[:2] == self.cmdlangl:
    @<add a reference command to the current chunk@>
elif token[:2] == self.cmdlexpr:
    @<add an expression command to the current chunk@>
elif token[:2] == self.cmdcmd:
    @<double at-sign replacement, append this character to previous TextCommand@>
@}

User identifiers occur after a ``@@|`` in a ``NamedChunk``.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@@{``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if user identifiers are permitted.
For the base ``Chunk`` class, this would be false, but for the ``NamedChunk`` class and
``OutputChunk`` class, this would be true.

User identifiers are name references at the end of a NamedChunk
These are accumulated and expanded by ``@@u`` reference

@d assign user identifiers... 
@{
try:
    self.aChunk.setUserIDRefs(next(self.tokenizer).strip())
except AttributeError:
    # Out of place @@| user identifier command
    self.logger.error("Unexpected references near %r: %r", self.location(), token)
    self.errors += 1
@}

A reference command has the form ``@@<``\ *name*\ ``@@>``.  We accept three
tokens from the input, the middle token is the referenced name.


@d add a reference command...
@{
# get the name, introduce into the named Chunk dictionary
expand = next(self.tokenizer).strip()
closing = self.expect((self.cmdrangl,))
self.theWeb.addDefName(expand)
self.aChunk.append(ReferenceCommand(expand, self.tokenizer.lineNumber))
self.aChunk.appendText("", self.tokenizer.lineNumber) # to collect following text
self.logger.debug("Reading %r %r", expand, closing)
@}

An expression command has the form ``@@(``\ *Python Expression*\ ``@@)``.  
We accept three
tokens from the input, the middle token is the expression.

There are two alternative semantics for an embedded expression.

-   **Deferred Execution**.  This requires definition of a new subclass of ``Command``, 
    ``ExpressionCommand``, and appends it into the current ``Chunk``.  At weave and
    tangle time, this expression is evaluated.  The insert might look something like this:
    ``aChunk.append(ExpressionCommand(expression, self.tokenizer.lineNumber))``.

-   **Immediate Execution**.  This simply creates a context and evaluates
    the Python expression.  The output from the expression becomes a ``TextCommand``, and
    is append to the current ``Chunk``.

We use the **Immediate Execution** semantics.

Note that we've removed the blanket ``os``.  We provide ``os.path`` library.
An ``os.getcwd()`` could be changed to ``os.path.realpath('.')``.

@d Imports... 
@{
import builtins
import sys
import platform
@| builtins sys platform
@}

@d add an expression command...
@{
# get the Python expression, create the expression result
expression = next(self.tokenizer)
self.expect((self.cmdrexpr,))
try:
    # Build Context
    safe = types.SimpleNamespace(**dict(
        (name, obj) 
        for name,obj in builtins.__dict__.items() 
        if name not in ('breakpoint', 'compile', 'eval', 'exec', 'execfile', 'globals', 'help', 'input', 'memoryview', 'open', 'print', 'super', '__import__')
    ))
    globals = dict(
        __builtins__=safe, 
        os=types.SimpleNamespace(path=os.path, getcwd=os.getcwd, name=os.name),
        time=time,
        datetime=datetime,
        platform=platform,
        theLocation=self.location(),
        theWebReader=self,
        theFile=self.theWeb.webFileName,
        thisApplication=sys.argv[0],
        __version__=__version__,
        )
    # Evaluate
    result = str(eval(expression, globals))
except Exception as exc:
    self.logger.error('Failure to process %r: result is %r', expression, exc)
    self.errors += 1
    result = f"@@({expression!r}: Error {exc!r}@@)"
self.aChunk.appendText(result, self.tokenizer.lineNumber)
@}

A double command sequence (``'@@@@'``, when the command is an ``'@@'``) has the
usual meaning of ``'@@'`` in the input stream.  We do this via 
the ``appendText()`` method of the current ``Chunk``.  This will append the 
character on the end of the most recent ``TextCommand``; if this fails, it will
create a new, empty ``TextCommand``.

We replace with '@@' here and now! This is put this at the end of the previous chunk.
And we make sure the next chunk will be appended to this so that it's 
largely seamless.

@d double at-sign...
@{
self.aChunk.appendText(self.command, self.tokenizer.lineNumber)
@}

The ``expect()`` method examines the 
next token to see if it is the expected item. ``'\n'`` are absorbed.  
If this is not found, a standard type of error message is raised. 
This is used by ``handleCommand()``.

@d WebReader handle a command...
@{
def expect(self, tokens: Iterable[str]) -> str | None:
    try:
        t = next(self.tokenizer)
        while t == '\n':
            t = next(self.tokenizer)
    except StopIteration:
        self.logger.error("At %r: end of input, %r not found", self.location(),tokens)
        self.errors += 1
        return None
    if t not in tokens:
        self.logger.error("At %r: expected %r, found %r", self.location(),tokens,t)
        self.errors += 1
        return None
    return t
@| expect
@}

The ``location()`` provides the file name and line number.
This allows error messages as well as tangled or woven output 
to correctly reference the original input files.

@d WebReader location...
@{
def location(self) -> tuple[str, int]:
    return (self.fileName, self.tokenizer.lineNumber+1)
@| location
@}

The ``load()`` method reads the entire input file as a sequence
of tokens, split up by the ``Tokenizer``.  Each token that appears
to be a command is passed to the ``handleCommand()`` method.  If
the ``handleCommand()`` method returns a True result, the command was recognized
and placed in the ``Web``.  If ``handleCommand()`` returns a False result, the command
was unknown, and we write a warning but treat it as text.

The ``load()`` method is used recursively to handle the ``@@i`` command. The issue
is that it's always loading a single top-level web. 

@d Imports...
@{from typing import TextIO
@}

@d WebReader load...
@{
def load(self, web: "Web", filename: str, source: TextIO | None = None) -> "WebReader":
    self.theWeb = web
    self.fileName = filename

    # Only set the a web filename once using the first file.
    # This should be a setter property of the web.
    if self.theWeb.webFileName is None:
        self.theWeb.webFileName = self.fileName
    
    if source:
        self._source = source
        self.parse_source()
    else:
        with open(self.fileName, "r") as self._source:
            self.parse_source()
    return self

def parse_source(self) -> None:
    self.tokenizer = Tokenizer(self._source, self.command)
    self.totalFiles += 1

    self.aChunk = Chunk() # Initial anonymous chunk of text.
    self.aChunk.webAdd(self.theWeb)

    for token in self.tokenizer:
        if len(token) >= 2 and token.startswith(self.command):
            if self.handleCommand(token):
                continue
            else:
                self.logger.warning('Unknown @@-command in input: %r', token)
                self.aChunk.appendText(token, self.tokenizer.lineNumber)
        elif token:
            # Accumulate a non-empty block of text in the current chunk.
            self.aChunk.appendText(token, self.tokenizer.lineNumber)
@| load parse
@}

The command character can be changed to permit
some flexibility when working with languages that make extensive
use of the ``@@`` symbol, i.e., PERL.
The initialization of the ``WebReader`` is based on the selected 
command character.


@d WebReader command literals
@{
# Structural ("major") commands
self.cmdo = self.command+'o'
self.cmdd = self.command+'d'
self.cmdlcurl = self.command+'{'
self.cmdrcurl = self.command+'}'
self.cmdlbrak = self.command+'['
self.cmdrbrak = self.command+']'
self.cmdi = self.command+'i'

# Inline ("minor") commands
self.cmdlangl = self.command+'<'
self.cmdrangl = self.command+'>'
self.cmdpipe = self.command+'|'
self.cmdlexpr = self.command+'('
self.cmdrexpr = self.command+')'
self.cmdcmd = self.command+self.command

# Content "minor" commands
self.cmdf = self.command+'f'
self.cmdm = self.command+'m'
self.cmdu = self.command+'u'
@}


The Tokenizer Class
~~~~~~~~~~~~~~~~~~~~

The ``WebReader`` requires a tokenizer. The tokenizer breaks the input text
into a stream of tokens. There are two broad classes of tokens:

-   ``@@.`` command tokens, including the structural, inline, and content
    commands.

-   ``\n``. Inside text, these matter. Within structure command tokens, these don't matter.
    Except after the filename after an ``@@i`` command, where it ends the command. 

-   The remaining text.

The tokenizer works by reading the entire file and splitting on ``@@.`` patterns.
The ``split()`` method of the Python ``re`` module will separate the input
and preserve the actual character sequence on which the input was split.
This breaks the input into blocks of text separated by the ``@@.`` characters.

This tokenizer splits the input using ``(r'@@.|\n')``. The idea is that 
we locate commands, newlines and the interstitial text as three classes of tokens.  
We can then assemble each ``Command`` instance from a short sequence of tokens.
The core ``TextCommand`` and ``CodeCommand`` will be a line of text ending with
the ``\n``. 

The re.split() method will include an empty string when the split pattern occurs
at the very beginning or very end of the input. For example:

..  parsed-literal::

    >>> pat.split( "@@{hi mom@@}")
    ['', '@@{', 'hi mom', '@@}', '']
    
We can safely filter these via a generator expression.

The tokenizer counts newline characters for us, so that error messages can include
a line number. Also, we can tangle comments into the file that include line numbers.

Since the tokenizer is a proper iterator, we can use ``tokens = iter(Tokenizer(source))``
and ``next(tokens)`` to step through the sequence of tokens until we raise a ``StopIteration``
exception.

@d Imports
@{
import re
from collections.abc import Iterator, Iterable
@| re
@}

@d Tokenizer class...
@{
class Tokenizer(Iterator[str]):
    def __init__(self, stream: TextIO, command_char: str='@@') -> None:
        self.command = command_char
        self.parsePat = re.compile(f'({self.command}.|\\n)')
        self.token_iter = (t for t in self.parsePat.split(stream.read()) if len(t) != 0)
        self.lineNumber = 0
    def __next__(self) -> str:
        token = next(self.token_iter)
        self.lineNumber += token.count('\n')
        return token
    def __iter__(self) -> Iterator[str]:
        return self
@| Tokenizer
@}

The Option Parser Class
~~~~~~~~~~~~~~~~~~~~~~~~~

For some commands (``@@d`` and ``@@o``) we have options as well as the chunk name
or file name. This roughly parallels the way Tcl or the shell works.

The two examples are 

-   ``@@o`` which has an optional ``-start`` and ``-end`` that are used to 
    provide comment bracketing information. For example:
    
    ``@@0 -start /* -end */ something.css``
    
    Provides two options in addition to the required filename.
    
-   ``@@d`` which has an optional ``-noident`` or ``-indent`` that is used to
    provide the indentation rules for this chunk. Some chunks are not indented 
    automatically. It's up to the author to get the indentation right. This is
    used in the case of a Python """ string that would be ruined by indentation.
    
To handle this, we have a separate lexical scanner and parser for these
two commands.

@d Imports...
@{
import shlex
@| shlex
@}

Here's how we can define an option.

..  parsed-literal::

    OptionParser(
        OptionDef("-start", nargs=1, default=None),
        OptionDef("-end", nargs=1, default=""),
        OptionDef("-indent", nargs=0), # A default
        OptionDef("-noindent", nargs=0),
        OptionDef("argument", nargs='*'),
        )
        
The idea is to parallel ``argparse.add_argument()`` syntax.

@d Option Parser class...
@{
class ParseError(Exception): pass
@}

@d Option Parser class...
@{
class OptionDef:
    def __init__(self, name: str, **kw: Any) -> None:
        self.name = name
        self.__dict__.update(kw)
@}

The parser breaks the text into words using ``shelex`` rules. 
It then steps through the words, accumulating the options and the
final argument value.

@d Option Parser class...
@{
class OptionParser:
    def __init__(self, *arg_defs: Any) -> None:
        self.args = dict((arg.name, arg) for arg in arg_defs)
        self.trailers = [k for k in self.args.keys() if not k.startswith('-')]
        
    def parse(self, text: str) -> dict[str, list[str]]:
        try:
            word_iter = iter(shlex.split(text))
        except ValueError as e:
            raise Error(f"Error parsing options in {text!r}")
        options = dict(self._group(word_iter))
        return options
        
    def _group(self, word_iter: Iterator[str]) -> Iterator[tuple[str, list[str]]]:
        option: str | None
        value: list[str]
        final: list[str]
        option, value, final = None, [], []
        for word in word_iter:
            if word == '--':
                if option:
                    yield option, value
                try:
                    final = [next(word_iter)] 
                except StopIteration:
                    final = [] # Special case of '--' at the end.
                break
            elif word.startswith('-'):
                if word in self.args:
                    if option: 
                        yield option, value
                    option, value = word, []
                else:
                    raise ParseError(f"Unknown option {word!r}")
            else:
                if option:
                    if self.args[option].nargs == len(value):
                        yield option, value
                        final = [word]
                        break
                    else:                
                        value.append(word)
                else:
                    final = [word]
                    break
        # In principle, we step through the trailers based on nargs counts.
        for word in word_iter:
            final.append(word)
        yield self.trailers[0], final
@}

In principle, we step through the trailers based on nargs counts.
Since we only ever have the one trailer, we skate by.

The loop becomes a bit more complex to capture the positional arguments, in order.
First, we have to use an ``OrderedDict`` instead of a ``dict``.

Then we'd have a loop something like this. (Untested, incomplete, just hand-waving.)

..  parsed-literal::

    trailers = self.trailers[:] # Stateful shallow copy
    for word in word_iter:
        if len(final) == trailers[-1].nargs: # nargs=='*' vs. nargs=int??
            yield trailers[0], " ".join(final)
            final = 0
            trailers.pop(0)
    yield trailers[0], " ".join(final)
    
Action Class Hierarchy
-----------------------

This application performs three major actions: loading the document web, 
weaving and tangling.  Generally,
the use case is to perform a load, weave and tangle.  However, a less common use case
is to first load and tangle output files, run a regression test and then 
load and weave a result that includes the test output file.

The ``-x`` option excludes one of the two output actions.  The ``-xw`` 
excludes the weave pass, doing only the tangle action.  The ``-xt`` excludes
the tangle pass, doing the weave action.

This two pass action might be embedded in the following type of Python program.

..  parsed-literal::

    import pyweb, os, runpy, sys
    pyweb.tangle("source.w")
    with open("source.log", "w") as target:
        sys.stdout = target
        runpy.run_path('source.py')
        sys.stdout = sys.__stdout__
    pyweb.weave("source.w")


The first step runs **py-web-tool** , excluding the final weaving pass.  The second
step runs the tangled program, ``source.py``, and produces test results in
some log file, ``source.log``.  The third step runs **py-web-tool**  excluding the
tangle pass.  This produces a final document that includes the ``source.log`` 
test results.


To accomplish this, we provide a class hierarchy that defines the various
actions of the **py-web-tool**  application.  This class hierarchy defines an extensible set of 
fundamental actions.  This gives us the flexibility to create a simple sequence
of actions and execute any combination of these.  It eliminates the need for a 
forest of ``if``-statements to determine precisely what will be done.

Each action has the potential to update the state of the overall
application.   A partner with this command hierarchy is the Application class
that defines the application options, inputs and results. 

@d Action class hierarchy... 
@{
@<Action superclass has common features of all actions@>
@<ActionSequence subclass that holds a sequence of other actions@>
@<WeaveAction subclass initiates the weave action@>
@<TangleAction subclass initiates the tangle action@>
@<LoadAction subclass loads the document web@>
@}

Action Class
~~~~~~~~~~~~~

The ``Action`` class embodies the basic operations of **py-web-tool** .
The intent of this hierarchy is to both provide an easily expanded method of
adding new actions, but an easily specified list of actions for a particular
run of **py-web-tool** .

The overall process of the application is defined by an instance of ``Action``.
This instance may be the ``WeaveAction`` instance, the ``TangleAction`` instance
or a ``ActionSequence`` instance.

The instance is constructed during parsing of the input parameters.  Then the 
``Action`` class ``perform()`` method is called to actually perform the
action.  There are three standard ``Action`` instances available: an instance
that is a macro and does both tangling and weaving, an instance that excludes tangling,
and an instance that excludes weaving.  These correspond to the command-line options.

..  parsed-literal::

    anOp = SomeAction(*parameters*)
    anOp.options = *argparse.Namespace*
    anOp.web = *Current web*
    anOp()


The ``Action`` is the superclass for all actions.
An ``Action`` has a number of common attributes.

:name:
    A name for this action.
    
:options:
    The ``argparse.Namespace`` object.
    
:web:
    The current web that's being processed.
    
!start:
    The time at which the action started.



@d Action superclass... 
@{
class Action:
    """An action performed by pyWeb."""
    options : argparse.Namespace
    web : "Web"
    def __init__(self, name: str) -> None:
        self.name = name
        self.start: float | None = None
        self.logger = logging.getLogger(self.__class__.__qualname__)
        
    def __str__(self) -> str:
        return f"{self.name!s} [{self.web!s}]"
        
    @<Action call method actually does the real work@>
    @<Action final summary of what was done@>
@| Action
@}

The ``__call__()`` method does the real work of the action.
For the superclass, it merely logs a message.  This is overridden 
by a subclass.

@d Action call... 
@{
def __call__(self) -> None:
    self.logger.info("Starting %s", self.name)
    self.start = time.process_time()
@| perform
@}

The ``summary()`` method returns some basic processing
statistics for this action.


@d Action final... @{
def duration(self) -> float:
    """Return duration of the action."""
    return (self.start and time.process_time()-self.start) or 0
    
def summary(self) -> str:
    return f"{self.name!s} in {self.duration():0.3f} sec."
@| duration summary
@}

ActionSequence Class
~~~~~~~~~~~~~~~~~~~~

A ``ActionSequence`` defines a composite action; it is a sequence of
other actions.  When the macro is performed, it delegates to the 
sub-actions.

The instance is created during parsing of input parameters.  An instance of
this class is one of
the three standard actions available; it generally is the default, "do everything" 
action.

This class overrides the ``perform()`` method of the superclass.  It also adds
an ``append()`` method that is used to construct the sequence of actions.


@d ActionSequence subclass... 
@{
class ActionSequence(Action):
    """An action composed of a sequence of other actions."""
    def __init__(self, name: str, opSequence: list[Action] | None = None) -> None:
        super().__init__(name)
        if opSequence: self.opSequence = opSequence
        else: self.opSequence = []
        
    def __str__(self) -> str:
        return "; ".join([str(x) for x in self.opSequence])
        
    @<ActionSequence call method delegates the sequence of ations@>
    @<ActionSequence append adds a new action to the sequence@>
    @<ActionSequence summary summarizes each step@>
@| ActionSequence
@}

Since the macro ``__call__()`` method delegates to other Actions,
it is possible to short-cut argument processing by using the Python
``*args`` construct to accept all arguments and pass them to each
sub-action.

@d ActionSequence call... 
@{
def __call__(self) -> None:
    super().__call__()
    for o in self.opSequence:
        o.web = self.web
        o.options = self.options
        o()
@| perform
@}

Since this class is essentially a wrapper around the built-in sequence type, 
we delegate sequence related actions directly to the underlying sequence.

@d ActionSequence append... @{
def append(self, anAction: Action) -> None:
    self.opSequence.append(anAction)
@| append
@}

The ``summary()`` method returns some basic processing
statistics for each step of this action.

@d ActionSequence summary... @{
def summary(self) -> str:
    return ", ".join([o.summary() for o in self.opSequence])
@| summary
@}

WeaveAction Class
~~~~~~~~~~~~~~~~~~

The ``WeaveAction`` defines the action of weaving.  This action
logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.  If a ``Weaver`` was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

If the options include ``theWeaver``, that ``Weaver`` instance will be used.
Otherwise, the ``web.language()`` method function is used to guess what weaver to use.

@d WeaveAction subclass... @{
class WeaveAction(Action):
    """Weave the final document."""
    def __init__(self) -> None:
        super().__init__("Weave")
        
    def __str__(self) -> str:
        return f"{self.name!s} [{self.web!s}, {self.options.theWeaver!s}]"

    @<WeaveAction call method to pick the language@>
    @<WeaveAction summary of language choice@>
@| WeaveAction
@}

The language is picked just prior to weaving.  It is either (1) the language
specified on the command line, or, (2) if no language was specified, a language
is selected based on the first few characters of the input.

Weaving can only raise an exception when there is a reference to a chunk that
is never defined.

@d WeaveAction call... @{
def __call__(self) -> None:
    super().__call__()
    if not self.options.theWeaver: 
        # Examine first few chars of first chunk of web to determine language
        self.options.theWeaver = self.web.language() 
        self.logger.info("Using %s", self.options.theWeaver.__class__.__name__)
    self.options.theWeaver.reference_style = self.options.reference_style
    try:
        self.web.weave(self.options.theWeaver)
        self.logger.info("Finished Normally")
    except Error as e:
        self.logger.error("Problems weaving document from %r (weave file is faulty).", self.web.webFileName)
        #raise
@| perform
@}

The ``summary()`` method returns some basic processing
statistics for the weave action.


@d WeaveAction summary... @{
def summary(self) -> str:
    if self.options.theWeaver and self.options.theWeaver.linesWritten > 0:
        return (
            f"{self.name!s} {self.options.theWeaver.linesWritten:d} lines in {self.duration():0.3f} sec."
        )
    return f"did not {self.name!s}"
@| summary
@}

TangleAction Class
~~~~~~~~~~~~~~~~~~~

The ``TangleAction`` defines the action of tangling.  This operation
logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.  If a ``Weaver`` was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``theTangler``, with the ``Tangler`` instance to be used.

@d TangleAction subclass... @{
class TangleAction(Action):
    """Tangle source files."""
    def __init__(self) -> None:
        super().__init__("Tangle")
        
    @<TangleAction call method does tangling of the output files@>
    @<TangleAction summary method provides total lines tangled@>
@| TangleAction
@}

Tangling can only raise an exception when a cross reference request (``@@f``, ``@@m`` or ``@@u``)
occurs in a program code chunk.  Program code chunks are defined 
with any of ``@@d`` or ``@@o``  and use ``@@{`` ``@@}`` brackets.


@d TangleAction call... @{
def __call__(self) -> None:
    super().__call__()
    self.options.theTangler.include_line_numbers = self.options.tangler_line_numbers
    try:
        self.web.tangle(self.options.theTangler)
    except Error as e:
        self.logger.error("Problems tangling outputs from %r (tangle files are faulty).", self.web.webFileName)
        #raise
@| perform
@}

The ``summary()`` method returns some basic processing
statistics for the tangle action.

@d TangleAction summary... @{
def summary(self) -> str:
    if self.options.theTangler and self.options.theTangler.linesWritten > 0:
        return (
            f"{self.name!s} {self.options.theTangler.totalLines:d} lines in {self.duration():0.3f} sec."
        )
    return f"did not {self.name!r}"
@| summary
@}


LoadAction Class
~~~~~~~~~~~~~~~~~~

The ``LoadAction`` defines the action of loading the web structure.  This action
uses the application's ``webReader`` to actually do the load.

An instance is created during parsing of the input parameters.  An instance of
this class is part of any of the weave, tangle and "do everything" action.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``webReader``, with the ``WebReader`` instance to be used.


@d LoadAction subclass... @{
class LoadAction(Action):
    """Load the source web."""
    def __init__(self) -> None:
        super().__init__("Load")
    def __str__(self) -> str:
        return f"Load [{self.webReader!s}, {self.web!s}]"
    @<LoadAction call method loads the input files@>
    @<LoadAction summary provides lines read@>
@| LoadAction
@}

Trying to load the web involves two steps, either of which can raise 
exceptions due to incorrect inputs.

1.  The ``WebReader`` class ``load()`` method can raise exceptions for a number of 
    syntax errors as well as OS errors.

    -     Missing closing brackets (``@@}``, ``@@]`` or ``@@>``).

    -     Missing opening bracket (``@@{`` or ``@@[``) after a chunk name (``@@d`` or ``@@o``).

    -     Extra brackets (``@@{``, ``@@[``, ``@@}``, ``@@]``).

    -     Extra ``@@|``.

    -     The input file does not exist or is not readable.

2.  The ``Web`` class ``createUsedBy()`` method can raise an exception when a 
    chunk reference cannot be resolved to a named chunk.

@d LoadAction call... @{
def __call__(self) -> None:
    super().__call__()
    self.webReader = self.options.webReader
    self.webReader.command = self.options.command
    self.webReader.permitList = self.options.permitList 
    self.web.webFileName = self.options.webFileName
    error = f"Problems with source file {self.options.webFileName!r}, no output produced."
    try:
        self.webReader.load(self.web, self.options.webFileName)
        if self.webReader.errors != 0:
            self.logger.error(error)
            raise Error("Syntax Errors in the Web")
        self.web.createUsedBy()
        if self.webReader.errors != 0:
            self.logger.error(error)
            raise Error("Internal Reference Errors in the Web")        
    except Error as e:
        self.logger.error(error)
        raise # Older design.
    except IOError as e:
        self.logger.error(error)
        raise
@| perform
@}

The ``summary()`` method returns some basic processing
statistics for the load action.

@d LoadAction summary... @{
def summary(self) -> str:
    return (
        f"{self.name!s} {self.webReader.totalLines:d} lines from {self.webReader.totalFiles:d} files in {self.duration():0.3f} sec."
    )
@| summary
@}


**pyWeb** Module File
------------------------

The **pyWeb** application file is shown below:

@o pyweb.py 
@{@<Overheads@>
@<Imports@>
@<Base Class Definitions@>
@<Application Class@>
@<Logging Setup@>
@<Interface Functions@>
@}

The `Overheads`_ are described below, they include things like:

-     shell escape

-     doc string

-     ``__version__`` setting


`Python Library Imports`_ are actually scattered in various places in this description.


The more important elements are described in separate sections:

-     Base Class Definitions

-     Application Class and Main Functions

-     Interface Functions

Python Library Imports
~~~~~~~~~~~~~~~~~~~~~~~

Numerous Python library modules are used by this application. 

A few are listed here because they're used widely. Others are listed
closer to where they're referenced.

-   The ``os`` module provide os-specific file and path manipulations; it is used
    to transform the input file name into the output file name as well as track down file modification
    times.

-   The ``time`` module provides a handy current-time string; this is used
    to by the HTML Weaver to write a closing timestamp on generated HTML files, 
    as well as log messages.
    
-   The ``datetime`` module is used to format times, phasing out use of ``time``.

-   The ``types`` module is used to get at ``SimpleNamespace`` for configuration.



@d Imports
@{
import os
import time
import datetime
import types
@|  os time datetime types
@}

Note that ``os.path``, ``time``, ``datetime`` and ``platform```
are provided in the expression context.

Overheads
~~~~~~~~~~~~

The shell escape is provided so that the user can define this
file as executable, and launch it directly from their shell.
The shell reads the first line of a file; when it finds the ``'#!'`` shell
escape, the remainder of the line is taken as the path to the binary program
that should be run.  The shell runs this binary, providing the 
file as standard input.


@d Overheads
@{#!/usr/bin/env python
@}

A Python ``__doc__`` string provides a standard vehicle for documenting
the module or the application program.  The usual style is to provide
a one-sentence summary on the first line.  This is followed by more 
detailed usage information.


@d Overheads 
@{"""py-web-tool Literate Programming.

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
                 Choices are rst, html, latex and htmlshort.
                 Additionally, a `module.class` name can be used.
    -xw          Exclude weaving
    -xt          Exclude tangling
    -pi          Permit include-command errors
    -rt          Transitive references
    -rs          Simple references (default)
    -n           Include line number comments in the tangled source; requires
                 comment start and stop on the @@o commands.
        
    file.w       The input file, with @@o, @@d, @@i, @@[, @@{, @@|, @@<, @@f, @@m, @@u commands.
"""
@}

The keyword cruft is a standard way of placing version control information into
a Python module so it is preserved.  See PEP (Python Enhancement Proposal) #8 for information
on recommended styles.


We also sneak in a "DO NOT EDIT" warning that belongs in all generated application 
source files.

@d Overheads
@{__version__ = """3.1"""

### DO NOT EDIT THIS FILE!
### It was created by @(thisApplication@), __version__='@(__version__@)'.
### From source @(theFile@) modified @(datetime.datetime.fromtimestamp(os.path.getmtime(theFile)).ctime()@).
### In working directory '@(os.path.realpath('.')@)'.
@| __version__ @}


The Application Class
-----------------------

The ``Application`` class is provided so that the ``Action`` instances
have an overall application to update.  This allows the ``WeaveAction`` to 
provide the selected ``Weaver`` instance to the application.  It also provides a
central location for the various options and alternatives that might be accepted from
the command line.


The constructor creates a default ``argparse.Namespace`` with values
suitable for weaving and tangling.

The ``parseArgs()`` method uses the ``sys.argv`` sequence to 
parse the command line arguments and update the options.  This allows a
program to pre-process the arguments, passing other arguments to this module.


The ``process()`` method processes a list of files.  This is either
the list of files passed as an argument, or it is the list of files
parsed by the ``parseArgs()`` method.


The ``parseArgs()`` and process() functions are separated so that
another application can ``import pyweb``, bypass command-line parsing, yet still perform
the basic actionss simply and consistently.
For example:

..  parsed-literal::

    import pyweb, argparse
    
    p = argparse.ArgumentParser()
    *argument definition*
    config = p.parse_args()
    
    a = pyweb.Application()
    *Configure the Application based on options*
    a.process(config)


The ``main()`` function creates an ``Application`` instance and
calls the ``parseArgs()`` and ``process()`` methods to provide the
expected default behavior for this module when it is used as the main program.

The configuration can be either a ``types.SimpleNamespace`` or an
``argparse.Namespace`` instance.


@d Imports...
@{import argparse
@| argparse
@}

@d Application Class...
@{
class Application:
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
        @<Application default options@>
        
    @<Application parse command line@>
    @<Application class process all files@>
@| Application
@}

The first part of parsing the command line is 
setting default values that apply when parameters are omitted.
The default values are set as follows:

:defaults:
    A default configuration.

:webReader:
    is the ``WebReader`` instance created for the current
    input file.
 
:doWeave:
    instance of ``Action``
    that does weaving only.

:doTangle:
    instance of ``Action``
    that does tangling only.
    
:theAction:
    is an instance of ``Action`` that describes
    the default overall action: load, tangle and weave.  This is the default unless
    overridden by an option.
    
Here are the configuration values. These are attributes
of the ``argparse.namespace`` default as well as the updated
namespace returned by ``parseArgs()``.

:verbosity:
    Either ``logging.INFO``, ``logging.WARN`` or ``logging.DEBUG``
    
:command:
    is set to ``@@`` as the  default command introducer.

:permit:
    The raw list of permitted command characters, perhaps ``'i'``.
    
:permitList:
    provides a list of commands that are permitted
    to fail.  Typically this is empty, or contains ``@@i`` to allow the include
    command to fail.

:files:
    is the final list of argument files from the command line; 
    these will be processed unless overridden in the call to ``process()``.

!skip:
    a list of steps to skip: perhaps ``'w'`` or ``'t'`` to skip weaving or tangling.
    
:weaver:
    the short name of the weaver.
    
:theTangler:
    is set to a ``TanglerMake`` instance 
    to create the output files.

:theWeaver:
    is set to an instance of a subclass of ``Weaver`` based on ``weaver``

Other instance variables.
   
Here's the global list of available weavers. Essentially this is the subclass
list of ``Weaver``.  Essentially, the list is this:

..  parsed-literal::

    weavers = dict( 
        (x.__class__.__name__.lower(), x) 
        for x in Weaver.__subclasses__()
    )

Rather than automate this, and potentially expose elements of the class hierarchy
that aren't really meant to be used, we provide a manually-developed list. 

@d Application Class... 
@{
# Global list of available weaver classes.
weavers = {
    'html':  HTML,
    'htmlshort': HTMLShort,
    'latex': LaTeX,
    'rst': RST, 
}
@}

The defaults used for application configuration. The ``expand()`` method expands
on these simple text values to create more useful objects.

@d Application default options...
@{
self.defaults = argparse.Namespace(
    verbosity=logging.INFO,
    command='@@',
    weaver='rst', 
    skip='', # Don't skip any steps
    permit='', # Don't tolerate missing includes
    reference='s', # Simple references
    tangler_line_numbers=False,
    )
self.expand(self.defaults)

# Primitive Actions
self.loadOp = LoadAction()
self.weaveOp = WeaveAction()
self.tangleOp = TangleAction()

# Composite Actions
self.doWeave = ActionSequence("load and weave", [self.loadOp, self.weaveOp])
self.doTangle = ActionSequence("load and tangle", [self.loadOp, self.tangleOp])
self.theAction = ActionSequence("load, tangle and weave", [self.loadOp, self.tangleOp, self.weaveOp])
@}

The algorithm for parsing the command line parameters uses the built in
``argparse`` module.  We have to build a parser, define the options,
and the parse the command-line arguments, updating the default namespace.

We further expand on the arguments. This transforms simple strings into object
instances.


@d Application parse command line...
@{
def parseArgs(self, argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("-v", "--verbose", dest="verbosity", action="store_const", const=logging.INFO)
    p.add_argument("-s", "--silent", dest="verbosity", action="store_const", const=logging.WARN)
    p.add_argument("-d", "--debug", dest="verbosity", action="store_const", const=logging.DEBUG)
    p.add_argument("-c", "--command", dest="command", action="store")
    p.add_argument("-w", "--weaver", dest="weaver", action="store")
    p.add_argument("-x", "--except", dest="skip", action="store", choices=('w','t'))
    p.add_argument("-p", "--permit", dest="permit", action="store")
    p.add_argument("-r", "--reference", dest="reference", action="store", choices=('t', 's'))
    p.add_argument("-n", "--linenumbers", dest="tangler_line_numbers", action="store_true")
    p.add_argument("files", nargs='+')
    config = p.parse_args(argv, namespace=self.defaults)
    self.expand(config)
    return config
    
def expand(self, config: argparse.Namespace) -> argparse.Namespace:
    """Translate the argument values from simple text to useful objects.
    Weaver. Tangler. WebReader.
    """
    if config.reference == 't':
        config.reference_style = TransitiveReference() 
    elif config.reference == 's':
        config.reference_style = SimpleReference()
    else:
        raise Error("Improper configuration")

    try:
        weaver_class = weavers[config.weaver.lower()]
    except KeyError:
        module_name, _, class_name = config.weaver.partition('.')
        weaver_module = __import__(module_name)
        weaver_class = weaver_module.__dict__[class_name]
        if not issubclass(weaver_class, Weaver):
            raise TypeError(f"{weaver_class!r} not a subclass of Weaver")
    config.theWeaver = weaver_class()
    
    config.theTangler = TanglerMake()
    
    if config.permit:
        # save permitted errors, usual case is ``-pi`` to permit ``@@i`` include errors
        config.permitList = [f'{config.command!s}{c!s}' for c in config.permit]
    else:
        config.permitList = []

    config.webReader = WebReader()

    return config

@| parseArgs expand
@}

The ``process()`` function uses the current ``Application`` settings
to process each file as follows:

1.  Create a new ``WebReader`` for the ``Application``, providing
    the parameters required to process the input file.

2.  Create a ``Web`` instance, *w* 
    and set the Web's *sourceFileName* from the WebReader's *fileName*.

3.  Perform the given command, typically a ``ActionSequence``, 
    which does some combination of load, tangle the output files and
    weave the final document in the target language; if
    necessary, examine the ``Web`` to determine the documentation language.

4.  Print a performance summary line that shows lines processed per second.

In the event of failure in any of the major processing steps, 
a summary message is produced, to clarify the state of 
the output files, and the exception is reraised.
The re-raising is done so that all exceptions are handled by the 
outermost main program.

@d Application class process all...
@{
def process(self, config: argparse.Namespace) -> None:
    root = logging.getLogger()
    root.setLevel(config.verbosity)
    self.logger.debug("Setting root log level to %r", logging.getLevelName(root.getEffectiveLevel()))
    
    if config.command:
        self.logger.debug("Command character %r", config.command)
        
    if config.skip:
        if config.skip.lower().startswith('w'): # not weaving == tangling
            self.theAction = self.doTangle
        elif config.skip.lower().startswith('t'): # not tangling == weaving
            self.theAction = self.doWeave
        else:
            raise Exception(f"Unknown -x option {config.skip!r}")

    self.logger.info("Weaver %s", config.theWeaver)

    for f in config.files:
        w = Web() # New, empty web to load and process.
        self.logger.info("%s %r", self.theAction.name, f)
        config.webFileName = f
        self.theAction.web = w
        self.theAction.options = config
        self.theAction()
        self.logger.info(self.theAction.summary())
@| process
@}

Logging Setup
--------------

We'll create a logging context manager. This allows us to wrap the ``main()`` 
function in an explicit ``with`` statement that assures that logging is
configured and cleaned up politely.

@d Imports...
@{
import logging
import logging.config
@| logging logging.config
@}

This has two configuration approaches. If a positional argument is given,
that dictionary is used for ``logging.config.dictConfig``. Otherwise,
keyword arguments are provided to ``logging.basicConfig``.

A subclass might properly load a dictionary 
encoded in YAML and use that with ``logging.config.dictConfig``.

@d Logging Setup
@{
class Logger:
    def __init__(self, dict_config: dict[str, Any] | None = None, **kw_config: Any) -> None:
        self.dict_config = dict_config
        self.kw_config = kw_config
    def __enter__(self) -> "Logger":
        if self.dict_config:
            logging.config.dictConfig(self.dict_config)
        else:
            logging.basicConfig(**self.kw_config)
        return self
    def __exit__(self, *args: Any) -> Literal[False]:
        logging.shutdown()
        return False
@}

Here's a sample logging setup. This creates a simple console handler and 
a formatter that matches the ``basicConfig`` formatter.

It defines the root logger plus two overrides for class loggers that might be
used to gather additional information.

@d Logging Setup
@{
log_config = {
    'version': 1,
    'disable_existing_loggers': False, # Allow pre-existing loggers to work.
    'style': '{',
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'stream': 'ext://sys.stderr',
            'formatter': 'basic',
        },
    },
    'formatters': {
        'basic': {
            'format': "{levelname}:{name}:{message}",
            'style': "{",
        }
    },
    
    'root': {'handlers': ['console'], 'level': logging.INFO,},
    
    #For specific debugging support...
    'loggers': {
    #    'RST': {'level': logging.DEBUG},
    #    'TanglerMake': {'level': logging.DEBUG},
    #    'WebReader': {'level': logging.DEBUG},
    },
}
@}

This seems a bit verbose; a separate configuration file might be better.

Also, we might want a decorator to define loggers consistently for each class.


The Main Function
------------------

The top-level interface is the ``main()`` function.
This function creates an ``Application`` instance.

The ``Application`` object parses the command-line arguments.
Then the ``Application`` object does the requested processing.
This two-step process allows for some dependency injection to customize argument processing.

We might also want to parse a logging configuration file, as well
as a weaver template configuration file.

@d Interface Functions...
@{
def main(argv: list[str] = sys.argv[1:]) -> None:
    a = Application()
    config = a.parseArgs(argv)
    a.process(config)

if __name__ == "__main__":
    with Logger(log_config):
        main()
@| main @}

This can be extended by doing something like the following.

1.  Subclass ``Weaver`` create a subclass with different templates.

2.  Update the ``pyweb.weavers`` dictionary.

3.  Call ``pyweb.main()`` to run the existing
    main program with extra classes available to it.


..  parsed-literal::

    import pyweb
    class MyWeaver(HTML):
       *Any template changes*
     
    pyweb.weavers['myweaver']= MyWeaver()
    pyweb.main()


This will create a variant on **py-web-tool** that will handle a different
weaver via the command-line option ``-w myweaver``.
