
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

-   A ``Web`` object will create a ``Weaver`` to **weave** a final document file.

-   A ``Web`` object will create a ``Tangler`` to **tangle** each source code file.

Since each ``Emitter`` instance is responsible for the details of one file
type, different subclasses of ``Emitter`` are used when tangling source code files 
(``Tangler``) and  weaving files that include source code plus markup (``Weaver``).

Further specialization is required when weaving HTML or LaTeX or some other markup language.  
Generally, this is a matter of providing three things:

-   Templates with markup to replace various **py-web-tool** constructs,

-   Escape rules to make source code amenable to the markup language,

-   A header to provide overall includes or other setup.

An additional part of the escape rules could be expanded to include using a syntax coloring 
toolset instead of simply applying escapes.

In the case of **tangle**, the following algorithm is used:

    Visit each each output ``Chunk`` (``@@o`` command), doing the following:
    
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

    1.  Open the ``Weaver`` instance using the target file name.  This name is transformed
        by the weaver to an output file name appropriate to the target markup language.

    2.  Visit each each sequential ``Chunk`` (anonymous, ``@@d`` or ``@@o``), doing the following:

        1.  When visiting each ``Chunk``, call the Chunk's ``weave()`` method.
        
            1.  Call the Weaver's ``docBegin()``, ``fileBegin()`` or ``codeBegin()`` method, 
                depending on the subclass of Chunk.  For 
                ``fileBegin()`` and ``codeBegin()``, this writes the header for
                a code chunk in the weaver's markup language.  

            2.  Visit each ``Command``, calling the Command's ``weave()`` method.  
                For ordinary text, the
                text is written to the Weaver using the ``codeBlock()`` method.  For
                references to other chunks, the referenced chunk is woven using 
                the Weaver's ``referenceTo()`` method.

            3.  Call the Weaver's ``docEnd()``, ``fileEnd()`` or ``codeEnd()`` method.  
                For ``fileEnd()`` or ``codeEnd()``, this writes a trailer for
                a code chunk in the Weaver's markup language.


Emitter Superclass
~~~~~~~~~~~~~~~~~~

The ``Emitter`` class is an abstract base class.  It
contains common features factored out of the ``Weaver`` and ``Tangler`` subclasses.

Inheriting from the ``Emitter`` class generally requires overriding one or more
of the core methods: ``doOpen()``, and ``doClose()``.
A subclass of Tangler, might override the code writing methods: 
``quote()``, ``codeBlock()`` or ``codeFinish()``.

The ``Emitter`` class defines the basic
framework used to create and write to an output file.
This class follows the **Template** design pattern.  This design pattern
directs us to factor the basic ``open()``, ``close()`` and ``write()`` methods into two step algorithms.

..  parsed-literal::

    def open(self) -> "Emitter":
        *common preparation*
        self.doOpen()  *# overridden by subclasses*
        return self

The *common preparation* section is generally internal 
housekeeping.  The ``doOpen()`` method is overridden by subclasses to change the
basic behavior.

The class has the following attributes:

:filePath:
    the ``Path`` object for the target file created by the
    ``open()`` method.

:theFile:
    the current open file object created by the
    open method.

:linesWritten:
    the total number of ``'\n'`` characters written to the file.

:totalFiles:
    count of total number of files processed.

:totalLines:
    count of total number of lines.

Additionally, an ``Emitter`` object tracks an indentation context used by
The ``codeBlock()`` method to indent each line written.

:context:
    the indentation context stack, updated by ``addIndent()``, 
    ``clrIndent()`` and ``readdIndent()`` methods.
        
:lastIndent:
    the last indent used after writing a line of source code;
    this is used to track places where a partial line of code has a substitution into it.

:fragment:
    the last line written was a fragment and needs a ``'\n'``.

:code_indent:
    Any initial code indent. RST weavers needs additional code indentation.
    Other weavers don't care. Tanglers must have this set to zero.

@d Imports
@{from pathlib import Path
import abc
@| Path
@}

@d Emitter superclass
@{
class Emitter:
    """Emit an output file; handling indentation context."""
    
    code_indent = 0  #: Used by a Tangler
    filePath : Path  #: Path within the base directory (on the name is used)
    output : Path  #: Base directory to write
    theFile: TextIO  #: Open file being written
    
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
        self.log_indent = logging.getLogger("indent." + self.__class__.__qualname__)
        # Working State
        self.lastIndent = 0
        self.fragment = False
        self.context: list[int] = []
        self.readdIndent(self.code_indent)  # Create context and initial lastIndent values
        # Summary
        self.linesWritten = 0
        self.totalFiles = 0
        self.totalLines = 0

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
def open(self, aPath: Path) -> "Emitter":
    """Open a file."""
    if not hasattr(self, 'output'):
        self.output = Path.cwd()
    self.filePath = self.output / aPath.name
    self.logger.debug(f"Writing to {self.output} / {aPath.name} == {self.filePath}")
    self.linesWritten = 0
    self.doOpen()
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
    self.theFile.write(text)
    self.linesWritten += text.count('\n')

# Context Manager Interface -- used by ``open()`` method
def __enter__(self) -> "Emitter":
    return self
    
def __exit__(self, *exc: Any) -> Literal[False]:
    self.close()
    return False
@| open close write __enter__ __exit__
@}

The ``doOpen()``, and ``doClose()``
methods are overridden by the various subclasses to
perform the unique operation for the subclass.

@d Emitter doOpen... @{
def doOpen(self) -> None:
    self.logger.debug("Creating %r", self.filePath)
@| doOpen
@}

@d Emitter doClose... @{
def doClose(self) -> None:
    self.logger.debug("Wrote %d lines to %r", self.linesWritten, self.filePath)
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
    """Indented write of a block of code. 
    Buffers the spaces from the last line provided to act as the indent for the next line.
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
            # Buffer the next indent
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
@| addIndent setIndent clrIndent readdIndent
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
    The Path's suffix used by this weaver.
    
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
from textwrap import dedent, indent, shorten
@| string
@}

@d Weaver subclass of Emitter...
@{
class Weaver(Emitter):
    """Format various types of XRef's and code blocks when weaving.
    
    For RST format we splice in the following two lines
    ::
     
        ..  include:: <isoamsa.txt>
        ..  include:: <isopub.txt>
    """
    extension = ".rst" 
    code_indent = 4
    # Not actually used.
    header = dedent("""
        ..  include:: <isoamsa.txt>
        ..  include:: <isopub.txt>
    """)
    
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
def doOpen(self) -> None:
    """Create the final woven document."""
    self.filePath = self.filePath.with_suffix(self.extension)
    self.logger.info("Weaving '%s'", self.filePath)
    self.theFile = self.filePath.open("w")
    self.readdIndent(self.code_indent)
    
def doClose(self) -> None:
    self.theFile.close()
    self.logger.info("Wrote %d lines to %r", self.linesWritten, self.filePath)
    
def addIndent(self, increment: int = 0) -> None:
    """increment not used when weaving"""
    self.context.append(self.context[-1])
    self.log_indent.debug("addIndent %d: %r", self.lastIndent, self.context)
    
def codeFinish(self) -> None:
    pass # Not needed when weaving
@| doOpen doClose addIndent codeFinish
@}

The following list of markup escapes for RST may not be **all** that are requiresd. 
The general template for cude uses ``parsed-literal``
directive because it can include links comingled with the code.
We have to quote certain inline markup -- but only when the
characters are paired in a way that might confuse RST.

We could use patterns like ```.*?```, ``_.*?_``, ``\*.*?\*``, and ``\|.*?\|``
to look for paired RST inline markup and quote just these special character occurrences. 

@d Weaver quoted characters...
@{
# Prevent some RST markup from being recognized (and processed) in code.
quoted_chars: list[tuple[str, str]] = [
    ('\\', r'\\'), # Must be first.
    ('`', r'\`'),
    ('_', r'\_'), 
    ('*', r'\*'),
    ('|', r'\|'),
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
ref_template = string.Template(
    "${refList}"
)
ref_separator = "; "
ref_item_template = string.Template(
    "$fullName (`${seq}`_)"
)

def references(self, aChunk: Chunk) -> str:
    references = aChunk.references(self)
    if len(references) != 0:
        refList = [ 
            self.ref_item_template.substitute(seq=s, fullName=n)
            for n, s in references 
        ]
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
cb_template = string.Template(
    dedent("""
        ..  _`${seq}`:
        ..  rubric:: ${fullName} (${seq}) ${concat}
        ..  parsed-literal::
            :class: code
            
    """)
)

ce_template = string.Template(
    dedent("""
        ..
            
            ..  class:: small
                
                |loz| *${fullName} (${seq})*. Used by: ${references}
    """)
)

def codeBegin(self, aChunk: Chunk) -> None:
    txt = self.cb_template.substitute( 
        seq=aChunk.seq,
        lineNumber=aChunk.lineNumber, 
        fullName=aChunk.fullName,
        concat="=" if aChunk.initial else "+=",
    )
    self.write(txt)
    
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

**TODO:** Is this really necessary? Should we inject additional material
into the woven output? It seems like a potentially bad idea because
of the complications of various markup tool chains.

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
fb_template = string.Template(
    dedent("""
        ..  _`${seq}`:
        ..  rubric:: ${fullName} (${seq}) ${concat}
        ..  parsed-literal::
            :class: code
    
    """)
)

fe_template = string.Template(
    dedent("""
        ..
            
            ..  class:: small
                    
                |loz| *${fullName} (${seq})*.
    """)
)

def fileBegin(self, aChunk: Chunk) -> None:
    txt = self.fb_template.substitute(
        seq=aChunk.seq, 
        lineNumber=aChunk.lineNumber, 
        fullName=aChunk.fullName,
        concat="=" if aChunk.initial else "+=",
    )
    self.write(txt)

def fileEnd(self, aChunk: Chunk) -> None:
    assert len(self.references(aChunk)) == 0
    txt = self.fe_template.substitute(
        seq=aChunk.seq, 
        lineNumber=aChunk.lineNumber, 
        fullName=aChunk.fullName,
        references=[])
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
refto_name_template = string.Template(
    r"|srarr|\ ${fullName} (`${seq}`_)"
)
refto_seq_template = string.Template(
    r"|srarr|\ (`${seq}`_)"
)
refto_seq_separator = ", "

def referenceTo(self, aName: str | None, seq: int) -> str:
    """Weave a reference to a chunk.
    Provide name to get a full reference.
    name=None to get a short reference.
    """
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

Note that the ``xref_item_template`` and ``xref_empty_template`` have no leading ``\n`` character. They have
an indentation on the first line, however, to make ``dedent()`` work. The spaces to create proper
RST indentation are a bit fiddly here.

@d Weaver cross reference...
@{
xref_head_template = string.Template(
    dedent("""
    """)
)
xref_foot_template = string.Template(
    dedent("""
    """)
)
xref_item_template = string.Template(
    dedent("""    :${fullName}:
    ${refList}
    """)
)
xref_empty_template = string.Template(
    dedent("""    (None)
    """)
)

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
name_def_template = string.Template(
    '[`${seq}`_]'
)
name_ref_template = string.Template(
    '`${seq}`_'
)

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

A degenerate case: the base ``Weaver`` class does ``RST``.
Using this class name slightly simplifies the configuration and makes the output
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
    WebReader().load(w, "somefile.w") 
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
    Requires ``\\usepackage{fancyvrb}``
    """
    extension = ".tex"
    code_indent = 0
    # Not actually used
    header = dedent("""
        \\usepackage{fancyvrb}
    """)

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

There's no leading ``\n`` in the template -- we're trying to avoid an indent when weaving.
To make ``dedent()`` work, we have to provide the same leading whitespace on the first line
to match the subsequent lines.

@d LaTeX code chunk begin
@{
cb_template = string.Template(
    dedent("""        \\label{pyweb${seq}}
        \\begin{flushleft}
        \\textit{Code example ${fullName} (${seq})}
        \\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]
    """)
)
@| codeBegin
@}

The LaTeX ``codeEnd()`` template writes the trailer subsequent to
a chunk of source code.  This first closes the preformatted block and
then calls the ``references()`` method to write a reference
to the chunk that invokes this chunk; finally, it restores paragraph
indentation.
  
@d LaTeX code chunk end
@{
ce_template = string.Template(
    dedent("""
        \\end{Verbatim}
        ${references}
        \\end{flushleft}
    """)
)
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

The spacing around ``ref_item_template`` and ``ref_template`` are particularly fiddly.
This isn't easy to prepare with ``dedent()``. The ``indent()`` provides the indent
that makes the resulting LaTeX readable, distinct from the indent that makes the code readable.
  
@d LaTeX references summary...
@{
ref_item_template = string.Template(
    indent(
        dedent("""
            \\item Code example ${fullName} (${seq}) (Sect. \\ref{pyweb${seq}}, p. \\pageref{pyweb${seq}})
            """),
        '    '
    )
)

ref_template = string.Template(
    indent(
        dedent("""
            \\footnotesize
            Used by:
            \\begin{list}{}{}
            ${refList}
            \\end{list}
            \\normalsize"""),
        '    '
    )
)
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
    ("\\end{Verbatim}", "\\end\\,{Verbatim}"),  # Allow \end{Verbatim} in a Verbatim context
    ("\\{", "\\\\,{"), # Prevent unexpected commands in Verbatim
    ("$", "\\$"), # Prevent unexpected math in Verbatim
]
@| quoted_chars
@}

The ``referenceTo()`` template writes a reference to another chunk of
code.  It uses write directly as to follow the current indentation on
the current line of code.


@d LaTeX reference to...
@{
refto_name_template = string.Template(
    """$$\\triangleright$$ Code Example ${fullName} (${seq})"""
)

refto_seq_template = string.Template(
    """(${seq})"""
)
@| referenceTo
@}

HTML subclasses of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

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
cb_template = string.Template(
    indent(
        dedent("""
            <a name="pyweb${seq}"></a>
            <!--line number ${lineNumber}-->
            <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
            <pre><code>
            """),
        '    '
    )
)
@| codeBegin
@}

The ``codeEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.

@d HTML code chunk end
@{
ce_template = string.Template(
    indent(
        dedent("""
            </code></pre>
            <p>&loz; <em>${fullName}</em> (${seq}).
            ${references}
            </p>
            """),
        '    '
    )
)
@| codeEnd
@}

The ``fileBegin()`` template starts a chunk of code, defined with ``@@o``, providing a label
and HTML tags necessary to set the code off visually.

@d HTML output file begin
@{
fb_template = string.Template(
    indent(
        dedent("""            <a name="pyweb${seq}"></a>
            <!--line number ${lineNumber}-->
            <p>``${fullName}`` (${seq})&nbsp;${concat}</p>
            <pre><code>
        """), # No leading \\n.
        '    '
    )
)
@| fileBegin
@}

The ``fileEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.

@d HTML output file end
@{
fe_template = string.Template(
    indent(
        dedent("""            </code></pre>
            <p>&loz; ``${fullName}`` (${seq}).
            ${references}
            </p>
            """),
        '    '
    )
)
@| fileEnd
@}

The ``references()`` template writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.

@d HTML references summary...
@{
ref_item_template = string.Template(
    '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
)

ref_template = string.Template(
    '  Used by ${refList}.'
)
@| references
@}

The ``quote()`` method quotes an individual line of code for HTML purposes.
This encodes the four basic HTML entities (``<``, ``>``, ``&``, ``"``) to prevent code from being interpreted
as HTML.

@d HTML write a line of code
@{
quoted_chars: list[tuple[str, str]] = [
    ("&", "&amp;"),  # Must be first
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
refto_name_template = string.Template(
    '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em> (${seq})</a>'
)

refto_seq_template = string.Template(
    '<a href="#pyweb${seq}">(${seq})</a>'
)
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
xref_head_template = string.Template(
    dedent("""    <dl>
    """)
)
xref_foot_template = string.Template(
    dedent("""    </dl>
    """)
)
xref_item_template = string.Template(
    dedent("""    <dt>${fullName}</dt><dd>${refList}</dd>
    """)
)

@<HTML write user id cross reference line@>
@| xrefHead xrefFoot xrefLine
@}

The ``xrefDefLine()`` method writes a line for the user identifier cross reference blocks created by
@@u.  In this implementation, the cross references are simply unordered lists.  The defining instance 
is included in the correct order with the other instances, but is bold and marked with a bullet (&bull;).


@d HTML write user id cross reference line
@{
name_def_template = string.Template(
    '<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>'
)

name_ref_template = string.Template(
    '<a href="#pyweb${seq}">${seq}</a>'
)
@| xrefDefLine
@}

The HTMLShort subclass enhances the HTML class to provide short 
cross references.
The ``references()`` method writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.

@d HTML short references summary...
@{
ref_item_template = string.Template(
    '<a href="#pyweb${seq}">(${seq})</a>'
)
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
    self.filePath.parent.mkdir(parents=True, exist_ok=True)

def doOpen(self) -> None:
    """Tangle out of the output files."""
    self.checkPath()
    self.theFile = self.filePath.open("w")
    self.logger.info("Tangling '%s'", self.filePath)
    
def doClose(self) -> None:
    self.theFile.close()
    self.logger.info("Wrote %d lines to %r", self.linesWritten, self.filePath)
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
            f"{aChunk.filePath.name!s}:{aChunk.lineNumber!r} " 
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
def doOpen(self) -> None:
    fd, self.tempname = tempfile.mkstemp(dir=os.curdir)
    self.theFile = os.fdopen(fd, "w")
    self.logger.info("Tangling  '%s'", self.filePath)
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
        same = filecmp.cmp(self.tempname, self.filePath)
    except OSError as e:
        same = False  # Doesn't exist. (Could check for errno.ENOENT)
    if same:
        self.logger.info("Unchanged '%s'", self.filePath)
        os.remove(self.tempname)
    else:
        # Windows requires the original file name be removed first.
        try: 
            self.filePath.unlink()
        except OSError as e:
            pass  # Doesn't exist. (Could check for errno.ENOENT)
        self.checkPath()
        self.filePath.hardlink_to(self.tempname)
        os.remove(self.tempname)
        self.logger.info("Wrote %d lines to %s", self.linesWritten, self.filePath)
@| doClose
@}
