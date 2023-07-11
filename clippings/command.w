
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
class Command(abc.ABC):
    """A Command is the lowest level of granularity in the input stream."""
    chunk : "Chunk"
    text : str
    def __init__(self, fromLine: int = 0) -> None:
        self.lineNumber = fromLine+1 # tokenizer is zero-based
        self.logger = logging.getLogger(self.__class__.__qualname__)
        
    def __str__(self) -> str:
        return f"at {self.lineNumber!r}"
        
    def __eq__(self, other: Any) -> bool:
        match other:
            case Command():
                return self.lineNumber == other.lineNumber and self.text == other.text
            case _:
                return NotImplemented
                
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
    
@@abc.abstractmethod
def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
    ...
    
@@abc.abstractmethod
def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
    ...
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

**TODO:** Use textwrap.shorten to snip off first 32 chars of the text.

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
