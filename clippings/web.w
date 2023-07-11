
@d Web class...
@{
class Web:
    """The overall Web of chunks."""
    def __init__(self, file_path: Path | None = None) -> None:
        self.web_path = file_path
        self.chunkSeq: list[Chunk] = [] 
        self.output: dict[str, list[Chunk]] = {} # Map filename to Chunk
        self.named: dict[str, list[Chunk]] = {} # Map chunkname to Chunk
        self.sequence = 0
        self.errors = 0
        self.logger = logging.getLogger(self.__class__.__qualname__)
        
    def __str__(self) -> str:
        return f"Web {self.web_path!r}"

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

@d Imports
@{import weakref
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
        problem = f"No full name for {chunk.name!r}"
        self.errors += 1
        self.logger.error(problem)
        raise Error(problem)
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
    if name in self.named: 
        return name
    elif name.endswith('...'):
        best = [n 
            for n in self.named
            if n.startswith(name[:-3])
        ]
        match best:
            case []:
                return name
            case [singleton]:
                return singleton
            case _:
                raise Error(f"Ambiguous abbreviation {name!r}, matches {sorted(best)!r}")
    else:
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

An alternative one-pass version of the above algorithm:

..  parsed-literal::

    for nm, cl in self.named.items():
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
        with aTangler.open(Path(f)):
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
    self.logger.debug("Weaving file from '%s'", self.web_path)
    if not self.web_path:
        raise Error("No filename supplied for weaving.")
    with aWeaver.open(self.web_path):
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
