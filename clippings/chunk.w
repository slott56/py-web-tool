
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
@<Chunk base class for anonymous chunks of the file@>

@<NamedChunk class for defined names@>

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
    
:filePath:
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

@d Chunk base class...
@{
class Chunk:
    """Anonymous piece of input file: will be output through the weaver only."""
    web: weakref.ReferenceType["Web"]
    previous_command: "Command"
    initial: bool
    filePath: Path
    
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
        self.commands: list["Command"] = []  # The list of children of this chunk
        self.user_id_list: list[str] = []
        self.name: str = ""
        self.fullName: str = ""
        self.seq: int = 0
        self.referencedBy: list[Chunk] = []  # Chunks which reference this chunk.  Ideally just one.
        self.references_list: list[str] = []  # Names that this chunk references
        self.refCount = 0
        
    def __str__(self) -> str:
        return "\n".join(map(str, self.commands))
    def __repr__(self) -> str:
        return f"{self.__class__.__name__!s}({self.name!r})"
    def __eq__(self, other: Any) -> bool:
        match other:
            case Chunk():
                return self.name == other.name and self.commands == other.commands
            case _:
                return NotImplemented
        
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
    """Append a string to the most recent TextCommand."""
    match self.commands:
        case [*Command, TextCommand()]:
            self.commands[-1].text += text
        case _:
            self.commands.append(self.makeContent(text, lineNumber))
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

@d Imports
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


@d NamedChunk class...
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

@d NamedChunk class...
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

@d OutputChunk class...
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


@d NamedDocumentChunk class...
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
