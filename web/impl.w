.. py-web-tool/src/impl.w

Implementation
==============

The implementation is contained in a single Python module defining the all of the classes and functions, as well as an overall ``main()`` function.
The ``main()`` function uses these base classes to weave and tangle the output files.

The broad outline of the presentation is as follows:

-   `Base Classes`_ that define a model for the ``.w`` file.

    -   `Web Class`_ contains the overall Web of Chunks.
        A Web is a sequence of `Chunk` objects.
        It's also a mapping from chunk name to definition.
    
    -   `Chunk Class Hierarchy`_ are pieces of the source document, built into a Web.
        A ``Chunk`` is a collection of ``Command`` instances.
        This can be either an anonymous chunk that will be sent directly to the output,
        or a named chunks delimited by the structural ``@@d`` or ``@@o`` commands.
    
    -   `Command Class Hierarchy`_ are the items within a ``Chunk``.
        The text and the inline ``@@<name@@>`` references are the principle command classes.
        Additionally, there are some cross reference commands (``@@f``, ``@@m``, and ``@@u``) that generate content.

-   `Output Serialization`_. The ``Emitter`` class hierarchy writes various kinds of files.
    These decompose into two subclasses:
            
         -  A ``Tangler`` creates source code. 
         
         -  A ``Weaver`` creates documentation.
            The various Jinja-based templates are part of weaving.
         
-   `Input Parsing`_ covers deserialization from the source ``.w`` file
    to the base model of ``Web``, ``Chunk``, and ``Command``.
    
    -   `The WebReader class`_ which parses the Web structure.
    
    -   `The Tokenizer class`_ which tokenizes the raw input.
        
-   Other application components:
        
    -   `Error Class`_ defines an application-specific exception.
        This covers all of the various kinds of problems that might arise.

    -   `Action class hierarchy`_ defines things this program does.
    
    -   `The Application class`_. This is an overall class definition that includes
        command line parsing, picking an Action, configuring and executing the Action.
        It could be a set of related functions, but we've bound them into a class.
    
    -   `Logging setup`_. This includes a simple context manager for logging.
    
    -   `The Main Function`_.
    
    -   `pyWeb Module File`_ defines the final module file that contains the application.

We'll start with the base classes that define the data model for the source WEB of chunks.

Base Classes
-------------

Here are some of the base classes that define the structure and meaning of a ``.w`` source file.

@d Base Class Definitions 
@{
@<Command class hierarchy -- used to describe individual commands in a chunk@>

@<Chunk class hierarchy -- used to describe individual chunks@>

@<Web class -- describes the overall "web" of chunks@>
@}

The above order is reasonably helpful for Python and minimizes forward references.
The ``Chunk``, ``Command``, and ``Web`` instances do have a circular relationship, making a strict ordering a bit complex.

We'll start at the central collection of information, the ``Web`` class of objects.

Web Class
~~~~~~~~~

The overall web of chunks is contained in a single instance of the ``Web`` class.
This is the principle parameter for the weaving and tangling actions.
Broadly, the functionality of a Web can be separated into the following areas:

- It is constructed by a ``WebReader``.

- It also supports "enrichment" of the web, once all the ``Chunk`` instances are known. 
  This is a stateful update to the web.
  Each ``Chunk`` is updated with  references it makes as well as references to it.

- It supports ``Chunk`` cross-reference methods that traverse this enriched data.
  This includes a kind of validity check to be sure that everything is used once
  and once only. 
  

Fundamentally, a ``Web`` is a hybrid list+mapping. It as the following features:

-   It's a ``Sequence`` to retain all ``Chunk`` instances in order.

-   It's a mapping of name-to-Chunk that also offers a moderately sophisticated lookup, including exact match for a ``Chunk`` name and an approximate match for an abbreviated name.

The ``Web`` is built by the parser by loading the sequence of ``Chunk`` instances.

Note that the WEB source language has a "mixed content model".
This means the code chunks have specific tags with names.
The text, on the other hand, is interspersed among the code chunks.
The text belongs to implicit, unnamed text chunks.

A web instance has a number of attributes.

:chunks:
    the sequence of ``Chunk`` instances as seen in the input file.
    To support anonymous chunks, and to assure that the original input document order
    is preserved, we keep all chunks in a master sequential list.

:files:
    the ``@@o`` named ``OutputChunk`` chunks.  
    Each element of this  dictionary is a sequence of chunks that have the same name. 
    The first is the initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:macros:
    the ``@@d`` named ``NamedChunk`` chunks.  Each element of this 
    dictionary is a sequence of chunks that have the same name.  The first is the
    initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:userids:
    the cross reference of chunks referenced by commands in other
    chunks.

This relies on the way a ``@@dataclass`` does post-init processing.
One the raw sequence of ``Chunks`` has been presented, some additional processing is done to link each ``Chunk`` to the web.
This permits the ``full_name`` property to expand abbreviated names to full names,
and, consequently, chunk references.

@d Imports
@{from collections import defaultdict
from collections.abc import Iterator
from dataclasses import dataclass, field
from functools import cache
import logging
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Literal, ClassVar
from weakref import ref, ReferenceType
@}

The class defines one visible element of a ``Web`` instance, the ``chunks`` list of ``Chunk`` instances.
From this list of ``Chunk`` objects, the remaining internal objects are built.
These include the following:
 
-  ``chunk_map`` has the mapping of chunk names to list of chunks that provide the definition for the chunk.

-   ``userid_map`` has the mapping of user-defined names to the list of chunks that define the name.

-   ``references`` is the set of all referenced chunks.

Additionally there are attributes to contain a logger, a reference to the WEB file path,
used to evaluate expressions, and a "strict-match" option that can report errors during
name resolution.
Disabling strict-match will allow documents to be tangled that are potentially incomplete.

Generally, a parser will create a list of ``Chunk`` objects.
From this, the parser can create the final ``Web``.

@d Web class...
@{
@@dataclass
class Web:
    chunks: list["Chunk"]  #: The source sequence of chunks.

    # The ``@@d`` chunk names and locations where they're defined.
    chunk_map: dict[str, list["Chunk"]] = field(init=False)
    
    # The ``@@|`` defined names and chunks with which they're associated.
    userid_map: defaultdict[str, list["Chunk"]] = field(init=False)
        
    logger: logging.Logger = field(init=False, default=logging.getLogger("Web"))
    
    web_path: Path = field(init=False)  #: Source WEB file; set by ```WebParse``

    strict_match: ClassVar[bool] = True  #: Report ... names without a definition.
@| Web
@}

The  ``__post_init__()`` special method populates the detailed structure of the WEB document. 
There are several passes through the WEB to digest the data:

1.  Set all ``Chunk`` and ``Command`` back references to the ``Web`` container.
    This is required so a ``Chunk`` with a ``ReferenceCommand`` instance can properly
    refer to a chunk elsewhere in the ``Web`` container.
    There are all weak references to faciliate garbgage collection.

2.  Locate the unabbreviated names in chunks and references to chunks.
    Names can found in two places:
    the ``@@d`` command provides a name, and
    a ``@@<name@@>`` command provides a reference to a name.
    The unabbreviated names define the structure.
    Unambiguous abbreviations can be used freely, since full names are located first.

3.  Accumulate chunk lists, output lists, and name definition lists.
    This pass does two things.
    First any user-defined name after a ``@@|`` command is accumulated.
    Second, any abbreviated name is resolved to the full name,
    and the complete mapping from chunk name to a sequence of defining chunks is completed.

4.  Set the ``referencedBy`` attribute of a ``Chunk`` instance with all of the
    commands that point to it.
    The idea here is that a top-level ``Chunk`` instance may have references to other ``Chunk`` isntances.
    This forms a kind of tree.
    Any given low-level ``Chunk`` object is named by a sequence of parent ``Chunk`` objects.

Once the initialization is complete, the ``Web`` instance can be woven or tangled.

@d Web class...
@{
    def __post_init__(self) -> None:
        """
        Populate weak references throughout the web to make full_name properties work.
        Then. Locate all macro definitions and userid references. 
        """
        # Pass 1 -- set all Chunk and Command back references.
        for c in self.chunks:
            c.web = ref(self)
            for cmd in c.commands:
                cmd.web = ref(self)
                
        # Named Chunks = Union of macro_iter and file_iter
        named_chunks = list(filter(lambda c: c.name is not None, self.chunks))

        # Pass 2 -- locate the unabbreviated names in chunks and references to chunks.
        self.chunk_map = {}
        for seq, c in enumerate(named_chunks, start=1):
            c.seq = seq
            if not c.path:
                # Use ``@@d name`` chunks (reject ``@@o`` and text)
                if c.name and not c.name.endswith('...'):
                    self.logger.debug(f"__post_init__ 2a {c.name=!r}")
                    self.chunk_map.setdefault(c.name, [])
            for cmd in c.commands:
                # Find ``@@< name @@>`` in ``@@d name`` chunks or ``@@o`` chunks 
                if cmd.has_name:
                    if not cast(ReferenceCommand, cmd).name.endswith('...'):
                        self.logger.debug(f"__post_init__ 2b {cast(ReferenceCommand, cmd).name=!r}")
                        self.chunk_map.setdefault(cast(ReferenceCommand, cmd).name, [])
                    
        # Pass 3 -- accumulate chunk lists, output lists, and name definition lists.
        self.userid_map = defaultdict(list)
        for c in named_chunks:
            for name in c.def_names:
                self.userid_map[name].append(c)
            if not c.path:
                # Named ``@@d name`` chunks
                if full_name := c.full_name:
                    c.initial = len(self.chunk_map[full_name]) == 0
                    self.chunk_map[full_name].append(c)
                    self.logger.debug(f"__post_init__ 3 {c.name=!r} -> {c.full_name=!r}")
            else:
                # Output ``@@o`` and anonymous chunks.
                # Assume all @@o chunks are unique. If they're not, they overwrite each other.
                # Also, there's not ``full_name`` for these chunks.
                c.initial = True
                
            # TODO: Accumulate all chunks that contribute to a named file...

        # Pass 4 -- set referencedBy a command in a chunk.
        # ONLY set this in references embedded in named chunk or output chunk.
        # In a generic Chunk (which is text) there's no anchor to refer to.
        # NOTE: Assume single references *only*
        # We should raise an exception when updating a non-None referencedBy value.
        # Or incrementing ref_chunk.references > 1.
        for c in named_chunks:
            for cmd in c.commands:
                if cmd.has_name:
                    ref_to_list = self.resolve_chunk(cast(ReferenceCommand, cmd).name)
                    for ref_chunk in ref_to_list:
                        ref_chunk.referencedBy = c
                        ref_chunk.references += 1
@}

The representation of a ``Web`` instance is a sequence of ``Chunk`` instances.
This can be long and difficult to read.
It is, however, complete, and can be  used to build instances of ``Web`` objects from a variety of sources.

@d Web class...
@{            
    def __repr__(self) -> str:
        NL = ",\n"
        return (
            f"{self.__class__.__name__}("
            f"{NL.join(repr(c) for c in self.chunks)}"
            f")"
        )
@}

Name and Chunk resolution are similar.
Name resolution provides only the expanded name. 
Chunk resolution provides the list of chunks that define a name.
Chunk resolution expands on the basic features of Name resolution.

The complex ``target.endswith('...')`` processing only happens once during ``__post_init__()`` processing.
After the initalization is complete, all ``ReferenceCommand`` objects will have a ``full_name`` attribute that avoids the complication of resolving a name with a ``...`` ellipsis.

@d Web class...
@{
    def resolve_name(self, target: str) -> str:
        """Map short names to full names, if possible."""
        if target in self.chunk_map:
            # self.logger.debug(f"resolve_name {target=} in self.chunk_map")
            return target
        elif target.endswith('...'):
            # The ... is equivalent to regular expression .*
            matches = list(
                c_name
                for c_name in self.chunk_map
                if c_name.startswith(target[:-3])
            )
            # self.logger.debug(f"resolve_name {target=} {matches=} in self.chunk_map")
            match matches:
                case []:
                    if self.strict_match:
                        raise Error(f"No full name for {target!r}")
                    else:
                        self.logger.warning(f"resolve_name {target=} unknown")
                        self.chunk_map[target] = []
                    return target
                case [head]:
                    return head
                case [head, *tail]:
                    message = f"Ambiguous abbreviation {target!r}, matches {[head] + tail!r}"
                    raise Error(message)
            raise RuntimeError(f"unexpected {matches}")
        else:
            self.logger.warning(f"resolve_name {target=} unknown")
            self.chunk_map[target] = []
            return target

    def resolve_chunk(self, target: str) -> list["Chunk"]:
        """Map name (short or full) to the defining sequence of chunks."""
        full_name = self.resolve_name(target)
        chunk_list = self.chunk_map[full_name]
        self.logger.debug(f"resolve_chunk {target=!r} -> {full_name=!r} -> {chunk_list=}")
        return chunk_list
@}

The point of the ``Web`` object is to be able to manage a variety of  structures.
These iterator methods and properties provide the list of ``@@o`` chunks, ``@@d`` chunks, and the usernames after ``@@|`` in a chunk.

Additionally, we can confirm the overall structure by asserting that each ``@@d`` name has one reference.
A name with no references indicates an omission, a name with multiple references suggests a spelling or ellipsis problem.

@d Web class...
@{
    def file_iter(self) -> Iterator[OutputChunk]:
        return (cast(OutputChunk, c) for c in self.chunks if c.type_is("OutputChunk"))

    def macro_iter(self) -> Iterator[NamedChunk]:
        return (cast(NamedChunk, c) for c in self.chunks if c.type_is("NamedChunk"))

    def userid_iter(self) -> Iterator[SimpleNamespace]:
        yield from (SimpleNamespace(def_name=n, chunk=c) for c in self.file_iter() for n in c.def_names)
        yield from (SimpleNamespace(def_name=n, chunk=c) for c in self.macro_iter() for n in c.def_names)

    @@property
    def files(self) -> list["OutputChunk"]:
        return list(self.file_iter())

    @@property
    def macros(self) -> list[SimpleNamespace]:
        """
        The chunk_map has the list of Chunks that comprise a macro definition.
        We separate those to make it slightly easier to format the first definition.
        """
        first_list = (
            (self.chunk_map[name][0], self.chunk_map[name])
            for name in sorted(self.chunk_map)
            if self.chunk_map[name]
        )
        macro_list = list(
            SimpleNamespace(name=first_def.name, full_name=first_def.full_name, seq=first_def.seq, def_list=def_list)
            for first_def, def_list in first_list
        )
        # self.logger.debug(f"macros: {defs}")
        return macro_list

    @@property
    def userids(self) -> list[SimpleNamespace]:
        userid_list = list(
            SimpleNamespace(userid=userid, ref_list=self.userid_map[userid])
            for userid in sorted(self.userid_map)
        )
        # self.logger.debug(f"userids: {userid_list}")
        return userid_list
            
    def no_reference(self) -> list[Chunk]:
        return list(filter(lambda c: c.name and not c.path and c.references == 0, self.chunks))
        
    def multi_reference(self) -> list[Chunk]:
        return list(filter(lambda c: c.name and not c.path and c.references > 1, self.chunks))
@| Web
@}

A ``Web`` instance is built by a ``WebReader``. 
It's used by an ``Emitter``, including a ``Weaver`` as well as a ``Tangler``.
A ``Web`` is composed of individual ``Chunk`` instances.

Chunk Class Hierarchy
~~~~~~~~~~~~~~~~~~~~~

A ``Chunk`` is a piece of the input file.
It is a collection of ``Command`` instances.
A ``Chunk`` can be woven or tangled to create output.

..  uml::

    class Chunk {
        options: list[str]
        name: str
        seq: int
        commands: list[Command]
        def_names: list[str]
        initial: bool
    }
    
    class OutputChunk
    Chunk <|-- OutputChunk
    
    class NamedChunk
    Chunk <|-- NamedChunk
    
These subclasss reflect three kinds of content in the WEB source document:

-  ``Chunk`` is the anonymous text context. 
        Text in the body generally becomes a ``TextCommand``.
        Also, the various XREF commands (``@@m``, ``@@f``, ``@@u``) can *only* appear here.
        In principle, a ``@@< reference @@>`` can appear in text. 
        It must name a ``@@d name @@[...@@]`` NamedDocumentChunk, which is expanded in place, not linked.

-  ``OutputChunk`` is the ``@@o`` context. 
        Text in the body becomes a ``CodeCommand``.
        Any ``@@< reference @@>`` will be expanded when tangling, but become a link when weaving.
        This defines an output file.

-  ``NamedChunk`` is the ``@@d`` context. 
        Text in the body becomes a ``CodeCommand``.
        Any ``@@< reference @@>`` will be expanded when tangling, but become a link when weaving.

Most of the attributes are pushed up to the base class.
This makes type checking the complex WEB tree simpler.

The attributes are visible to the Jinja templates.
In particular the sequence number, ``seq``,  and the initial definition indicator, ``initial``, are often used to customize presentation of the woven content.

A ``type_is()`` method is used to discern the various subtypes.
This slightly simplifies the work done by a template.
It's not easy to rely on proper inheritance because the templates are implemented in a separate language with their own processing rules.

@d Chunk class hierarchy...
@{
@@dataclass
class Chunk:
    """Base class for OutputChunk, NamedChunk, NamedDocumentChunk.
    """
    #: Parsed options for @@d and @@o chunks; used by __post_init__() to set other attributes.
    options: list[str] = field(default_factory=list)

    #: Short name of the chunk.
    name: str | None = None
    
    #: Unique sequence number of chunk in the WEB.
    seq: int | None = None  
    
    #: Sequence of commands inside this chunk.
    commands: list["Command"] = field(default_factory=list)

    #: Names defined after ``@@|`` in this chunk.
    def_names: list[str] = field(default_factory=list)
      
    #: Is this the first use of a given Chunk name?
    initial: bool = False  
    
    #: If injecting location details when tangling, this is the comment prefix.
    comment_start: str | None = None
    
    #: If injecting location details, this is the comment suffix. 
    comment_end: str | None = None

    #: When weaving, set weave=False to skip this.
    weave: bool = True

    #: When weaving, this is a style to use.
    style: str | None = None

    #: Count of references to this Chunk.
    references: int = field(init=False, default=0)
    
    #: The immediate reference to this chunk.
    referencedBy: "Chunk | None" = field(init=False, default=None)
    
    #: Weak reference to the ``Web`` containing this ``Chunk``.
    web: ReferenceType["Web"] | None = field(init=False, repr=False, default=None)
    
    #: Logger for any chunk-specific messages.
    logger: logging.Logger = field(init=False, default=logging.getLogger("Chunk"))

    #: Indentation Rule; None means indent; number is the amount to indent.
    indent: None | int = None

    def __post_init__(self) -> None:
        """Parse options."""
        if self.options:
            self.logger.warning("attempt to create %s with options %r", self.__class__.__name__, self.options)

    @@property
    def full_name(self) -> str | None:
        if self.web is None:
            raise ValueError("no web assigned to chunk {self!s}")
        if self.name:
            return cast(Web, self.web()).resolve_name(self.name)
        else:
            return None

    @@property
    def path(self) -> Path | None:
        return None

    @@property
    def location(self) -> tuple[str, int]:
        return self.commands[0].location

    @@property
    def transitive_referencedBy(self) -> list["Chunk"]:
        if self.referencedBy:
            return [self.referencedBy] + self.referencedBy.transitive_referencedBy
        else:
            return []
        
    def add_text(self, text: str, location: tuple[str, int]) -> "Chunk":
        if self.commands and self.commands[-1].typeid.TextCommand:
            cast(HasText, self.commands[-1]).text += text
        else:
            # Empty list OR previous command was not ``TextCommand``
            self.commands.append(TextCommand(text, location))
        return self
             
    def type_is(self, name: str) -> bool:
        """
        Instead of type name matching, we could check for these features:
        - has_code() (i.e., NamedChunk and OutputChunk)
        - has_text() (i.e., Chunk and NamedDocumentChunk)
        Since this is for template rendering, where proper Liskov
        Substitution is irrelevant, we match class names.

        This can't **easily** use the ``typeid`` metaclass because it's a dataclass.
        """
        return self.__class__.__name__ == name
@}

The subclasses do little more than partition the Chunks in a way that permits customization in the template rendering process.

An ``OutputChunk`` is distinguished from ``NamedChunk`` by having a ``path`` property and not having a ``full_name`` property.

@d Chunk class hierarchy...
@{
class OutputChunk(Chunk):
    """An output file from an ``@@o`` Chunk"""
    option_parser: argparse.ArgumentParser | None = None

    def __post_init__(self) -> None:
        """Parse options."""
        if not self.option_parser:
            self.option_parser = argparse.ArgumentParser(add_help=False, exit_on_error=False)
            self.option_parser.add_argument("-start", dest='start', type=str, default=None)
            self.option_parser.add_argument("-end", dest='end', type=str, default="")
            self.option_parser.add_argument("-noweave", dest="weave", action='store_false', default=True)
            # All remaining arguments form the chunk name
            self.option_parser.add_argument("argument", type=str, nargs="*")
        options = self.option_parser.parse_args(self.options)
        self.name = ' '.join(options.argument)
        self.comment_start = options.start if '-start' in options else "# "
        self.comment_end = options.end if '-end' in options else ""
        self.weave = options.weave

    @@property
    def path(self) -> Path | None:
        if self.name:
            return Path(self.name)
        else:
            return None

    @@property
    def full_name(self) -> str | None:
        return None

    def add_text(self, text: str, location: tuple[str, int]) -> Chunk:
        if self.commands and self.commands[-1].typeid.CodeCommand:
            cast(HasText, self.commands[-1]).text += text
        else:
            # Empty list OR previous command was not ``CodeCommand``
            self.commands.append(CodeCommand(text, location))
        return self
             
class NamedChunk(Chunk): 
    """
    A defined name with code from a ``@@d`` Chunk

    ..  note:: syntex for ``-indent``/``-noindent``.

        - ``-indent`` provides None, normal indent

        - ``-noindent`` is effectively ``-indent 0``.
    """

    option_parser: argparse.ArgumentParser | None = None

    def __post_init__(self) -> None:
        if not self.option_parser:
            self.option_parser = argparse.ArgumentParser(add_help=False, exit_on_error=False)
            self.option_parser.add_argument("-style", dest="style", action="store", default=None)
            self.option_parser.add_argument("-indent", dest='indent', action='store_const',
             const=None, default=None)
            self.option_parser.add_argument("-noindent", dest='indent', action='store_const', const=0, default=None)
            self.option_parser.add_argument("argument", type=str, nargs="*")
        options = self.option_parser.parse_args(self.options)
        self.name = ' '.join(options.argument)
        if 'noindent' in options and options.noindent:
            self.indent = 0
        elif 'indent' in options and options.indent:
            self.indent = int(options.indent)
        self.style = options.style

    def add_text(self, text: str, location: tuple[str, int]) -> Chunk:
        if self.commands and self.commands[-1].typeid.CodeCommand:
            cast(HasText, self.commands[-1]).text += text
        else:
            # Empty list OR previous command was not ``CodeCommand``
            self.commands.append(CodeCommand(text, location))
        return self
             
class NamedDocumentChunk(Chunk):
    """
    A defined name with text.

    ..  todo:: Refactor parse_options to base class
    """
    option_parser: argparse.ArgumentParser | None = None

    def __post_init__(self) -> None:
        if not self.option_parser:
            self.option_parser = argparse.ArgumentParser(add_help=False, exit_on_error=False)
            self.option_parser.add_argument("-style", action="store", type=str, default=None)
            # All remaining arguments form the chunk name
            self.option_parser.add_argument("argument", type=str, nargs="*")
        options = self.option_parser.parse_args(self.options)
        self.name = ' '.join(options.argument)

@| Chunk NamedChunk OutputChunk NamedDocumentChunk
@}

Command Class Hierarchy
~~~~~~~~~~~~~~~~~~~~~~~

A ``Chunk`` is a sequence of ``Command`` instances.
For the generic ``Chunk`` base class, the commands are -- mostly -- the ``TextCommand`` subclass of ``Command``; these are blocks of text.
A ``Chunk`` may also include some ``XRefCommand`` instances which expand to cross-reference material for an index.

For the ``CodeChunk`` and ``NamedChunk`` subclasses, the commands are ``CodeCommand`` instances intermixed with ``ReferenceCommand`` instances.
A ``CodeCommand`` has a wrapper applied to it when weaving.
Additionally, it will be tangled into the output.
A ``ReferenceCommand`` becomes a link when weaving, and expands to its full body when being tangled.

..  uml::

    class Chunk {
        name: str
        commands: list[Command]
    }
    abstract class Command {
        {static} has_name: bool
        {static} has_text: bool
        {static} typeid: TypeId
        text: str
        tangle(Tangler, Target)
    }
    
    Chunk *-- "1..*" Command

    abstract HasText
    Command <|-- HasText

    class TextCommand
    HasText <|-- TextCommand
    
    class CodeCommand
    HasText <|-- CodeCommand
    
    class ReferenceCommand
    Command <|-- ReferenceCommand
    
    abstract XRefCommand
    Command <|-- XRefCommand
    
    class FileXRefCommand
    XRefCommand <|-- FileXRefCommand
    
    class MacroXRefCommand
    XRefCommand <|-- MacroXRefCommand
    
    class UseridXRefCommand
    XRefCommand <|-- UseridXRefCommand
    
    class TypeId {
        __getattr__(str) : bool
    }

    Command -- TypeId

Each of these variants has the possibility of distinct processing when weaving the final document.
The type information must be  visibile to the Jinja template processing.
This is done through an instance of the ``TypeId`` class attached to each of these classes.

The input stream is broken into individual commands, based on the various ``@@``\ *x* strings in the file.
There are several subclasses of ``Command``, each used to describe a different command or block of text in the input.

All instances of the ``Command`` class are created by the ``WebReader`` instance.  
In this case, a ``WebReader`` can be thought of as a factory for ``Command`` instances.
Each ``Command`` instance is appended to the sequence of commands that
belong to a ``Chunk``.

This model permits two kinds of serialization:

-   Weaving a document from the WEB source file. This uses the various attributes
    of the various subclasses.

-   Tangling target documents with code. This relies on a ``tangle()`` method 
    in each subclass.

We'll address the run-time type identification first,
the the definitions of the various ``Command`` subclasses.

@d Command class hierarchy...
@{
@<The TypeId Class -- to help the template engine@>

@<The Command Abstract Base Class@>

@<The HasText Type Hint -- used instead of another abstract class@>

@<The TextCommand Class@>
@<The CodeCommand Class@>
@<The ReferenceCommand Class@>
@<The XrefCommand Subclasses -- files, macros, and user names@>
@}

The TypeId Class
****************

The ``TypeId`` class provides run-time type identification to the Jinja templates.
The idea is ``object.typeid.AClass`` is  equivalent to ``isinstance(object, pyweb.AClass)``.
It has simpler syntax and works better with Jinja templates.
It helps sort out the various nodes of the AST built from the source WEB document.

There are three parts to the ``TypeId`` implementation:

-   A ``TypeId`` class definition to handle the attribute access.
    A reference to ``object.typeid.Name`` evaluates ``__getattr__(object, 'Name')``.
    
-   A metaclass definition, ``TypeIdMeta``, to inject the new ``typeid`` attribute into each class.

-   The normal class initialization process, which evaluates ``__set_name__()``
    for each attribute of a class that defines the method.
    This provides the containing class to the ``TypeId`` instance.

The idea of run-time type identification is -- in a way -- a failure to properly
define the classes to follow the Liskov Substitution design principle.
This becomes awkwardly complex in the Jinja templates, because the templates exist
outside the class hierarchy.
We rely on the ``typeid`` to map classes to macros appropriate to the class.

@d Imports
@{from typing import TypeVar, Generic
@}

@d The TypeId Class...
@{
class TypeId:
    """
    This makes a given class name into an attribute with a 
    True value. Any other attribute reference will return False.
    
    >>> class A:
    ...     typeid = TypeId()
    >>> a = A()
    >>> a.typeid.A 
    True
    >>> a.typeid.B
    False
    """             
    def __set_name__(self, owner: type, name: str) -> "TypeId":
        """Invoked automatically during object construction."""
        self.my_class = owner
        return self

    def __getattr__(self, item: str) -> bool:
        return self.my_class.__name__ == item
        
from collections.abc import Mapping

class TypeIdMeta(type):
    """Inject the ``typeid`` attribute into a class definition."""
    @@classmethod
    def __prepare__(metacls, name: str, bases: tuple[type, ...], **kwds: Any) -> Mapping[str, object]:  # type: ignore[override]
        return {"typeid": TypeId()}
@| TypeId TypeIdMeta
@}

The ``TypeIdMeta`` metaclass sets the ``typeid`` attribute of each class defined by this metaclass. 
The ordinary class preparation automatically invokes the ``__set_name__()`` special method to provide details to the attribute.

Once set, any reference to ``c.typeid.name`` will be evaluated as ``__getattr__(c, 'name')``.
This permits the typeid to compare the name provided by ``__set_name__()`` with the name
being inquired about.

The Command Class
********************

The ``Command`` class is abstract, and describes most of the features of the various subclasses.

@d The Command Abstract Base Class...
@{
class Command(metaclass=TypeIdMeta):
    typeid: TypeId
    has_name = False
    has_text = False
        
    def __init__(self, location: tuple[str, int]) -> None:
        self.location = location  #: The (filename, line number)
        self.logger = logging.getLogger(self.__class__.__name__)
        self.web: ReferenceType["Web"]
        self.text: str  #: The body of this command
        
    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(location={self.location!r})"
        
    @@abc.abstractmethod
    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        ...
@}

The HasText Classes
*******************

An Annotation summarizes some of the subclass relationships.
   
@d The HasText Type Hint...
@{
type HasText = "CodeCommand | TextCommand"
@}

We don't formalize this as proper subclass definitions.
We probably should, but it doesn't seem to add any clarity.

The TextCommand Class
*********************

The ``TextCommand`` class describes all of the text **outside** the ``@@d`` and ``@@o`` chunks.
These are **not** tangled, and any attempt to do this raises an exception .
 
@d The TextCommand Class...
@{
class TextCommand(Command):
    """Text outside any other command."""    
    has_text = True
    
    def __init__(self, text: str, location: tuple[str, int]) -> None:
        super().__init__(location)
        self.text = text  #: The text
            
    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        message = f"attempt to tangle a text block {self.location} {shorten(self.text, 32)!r}"
        self.logger.error(message)
        raise Error(message)

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(text={self.text!r}, location={self.location!r})"
@}

The CodeCommand Class
*********************

The ``CodeCommand`` class describes the text **inside** the ``@@d`` and ``@@o``  chunks.
These are tangled without change.
 
@d The CodeCommand Class...
@{
class CodeCommand(Command):
    """Code inside a ``@@o``, or ``@@d`` command."""    
    has_text = True

    def __init__(self, text: str, location: tuple[str, int]) -> None:
        super().__init__(location)
        self.text = text  #: The text

    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        self.logger.debug(f"tangle {self.text=!r}")
        aTangler.codeBlock(target, self.text)

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(text={self.text!r}, location={self.location!r})"
@}

The ReferenceCommand Class
**************************

The ``ReferenceCommand`` class describes a ``@@< name @@>`` construct inside a chunk. 
When tangled, these lead to inserting the referenced chunk's content.
Because this a reference to another chunk, the properties provide the values for the other chunk.
 
@d The ReferenceCommand Class...
@{
class ReferenceCommand(Command):
    """
    Reference to a ``NamedChunk`` in code, a ``@@< name @@>`` construct.
    In a CodeChunk or OutputChunk, it tangles to the definition from a ``NamedChunk``.
    In text, it can weave to the text of a ``NamedDocumentChunk``.
    """    
    has_name = True

    def __init__(self, name: str, location: tuple[str, int]) -> None:
        super().__init__(location)
        self.name = name  #: The name that is referenced.
    
    @@property
    def full_name(self) -> str:
        return cast(Web, self.web()).resolve_name(self.name)

    @@property
    def seq(self) -> int | None:
        return cast(Web, self.web()).resolve_chunk(self.name)[0].seq

    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        """Expand this reference.
        The starting position is the indentation for all **subsequent** lines.
        Provide the indent before ``@@<``, in ``tangler.fragment`` back to the tangler. 
        """
        self.logger.debug(f"tangle reference to {self.name=}, context: {aTangler.fragment=}")
        chunk_list = cast(Web, self.web()).resolve_chunk(self.name)
        if len(chunk_list) == 0:
            message = f"Attempt to tangle an undefined Chunk, {self.name!r}"
            self.logger.error(message)
            raise Error(message) 
        aTangler.reference_names.add(self.name)
        aTangler.addIndent(len(aTangler.fragment))
        aTangler.fragment = ""

        for chunk in chunk_list:
            # TODO: if chunk.indent is not None: do a setIndent before tangling.
            for command in chunk.commands:
                command.tangle(aTangler, target)
                
        aTangler.clrIndent()

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(name={self.name!r}, location={self.location!r})"
@}

The XrefCommand Classes
**************************

The ``XRefCommand`` classes describes a ``@@f``, ``@@m``, and ``@@u`` constructs inside a chunk. 
These are **not** Tangled; they're only woven.

Each offers a unique property that can be used by the template rending to  get data about the WEB content.
 
@d The XrefCommand Subclasses...
@{
class FileXrefCommand(Command):
    """The ``@@f`` command."""    
    def __init__(self, location: tuple[str, int]) -> None:
        super().__init__(location)

    @@property
    def files(self) -> list["OutputChunk"]:
        return cast(Web, self.web()).files

    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        raise Error('Illegal tangling of a cross reference command.')

class MacroXrefCommand(Command):
    """The ``@@m`` command."""    
    def __init__(self, location: tuple[str, int]) -> None:
        super().__init__(location)

    @@property
    def macros(self) -> list[SimpleNamespace]:
        return cast(Web, self.web()).macros

    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        raise Error('Illegal tangling of a cross reference command.')

class UserIdXrefCommand(Command):
    """The ``@@u`` command."""    
    def __init__(self, location: tuple[str, int]) -> None:
        super().__init__(location)

    @@property
    def userids(self) -> list[SimpleNamespace]:
        return cast(Web, self.web()).userids
        
    def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
        raise Error('Illegal tangling of a cross reference command.')
@}

Output Serialization
--------------------

The ``Emitter`` class hierarchy writes the output from the source ``Web`` instance. 
An ``Emitter`` instance is responsible for control of an output file format.
This includes the necessary file naming, opening, writing and closing operations.

..  uml::

    abstract class Emitter {
        output: Path
        emit(Web)
    }
    
    class Web
    Emitter ..> Web
    
    class Weaver
    Emitter <|-- Weaver
    
    class Tangler
    Emitter <|-- Tangler
    class TanglerMake
    Tangler <|-- TanglerMake
    
    package jinja {
        class Environment
    }
    
    Weaver --> Environment
    
    object template
    
    Weaver *-- template
    Environment --> template

Here's how the definitions are provided in the application.
The two reference class definitions are used by by the ``Emitter`` class, and needs to be defined first.
We'll look at them later, since they're a tiny strategy change in how cross-references
are displayed.

@d Base Class Definitions
@{
@<Emitter base class@>

@<Weaver Subclass -- Uses Jinja templates to weave documentation@>

@<Tangler Subclass -- emits the output files@> 

@<TanglerMake Subclass -- extends Tangler to avoid touching files that didn't change@>
@}

@d Imports
@{import abc
from collections import ChainMap
from textwrap import dedent, shorten
from jinja2 import Environment, DictLoader, select_autoescape
import jinja2.nodes
@}

The ``Emitter`` class is an abstraction, used to check the consistency
of the subclasses.

@d Emitter base class...
@{
class Emitter(abc.ABC):
    def __init__(self, output: Path): 
        self.logger = logging.getLogger(self.__class__.__qualname__)
        self.log_indent = logging.getLogger("indent." + self.__class__.__qualname__)
        self.output = output
    
    @@abc.abstractmethod
    def emit(self, web: Web) -> None:
        pass
@}

The Weaver Subclass
~~~~~~~~~~~~~~~~~~~~

The ``Weaver`` is a **Facade** that wraps Jinja template processing.
The job is to build the necessary environment, locate the templates,
and then evaluate the template's ``generate()`` method to fill the values
into the template to create the woven document.

A single ``base_weaver_template`` template contains the essential structure of the woven document.
It's a series of chunks.
Code chunks get a wrapper and quoting rules, text chunks are emitted unchanged.
Each chunk contains a sequence of commands.

The ``base_weaver_template`` relies on a number of macros that customize the output by injecting repetitive boiler-plate markup constructs around code blocks and references between code blocks.

Each markup language requires unique macros.
A default set of macros will yield a readable document.
The macros can be customized via the configuration file and via ``@@t`` commands in the WEB file.
This permits some customization of the markup.

As an example, consider RST-formatted output. There are two variants on the way containers and classes work:

- When used with Sphinx, the "small" caption at the end of a code block uses ``..  rst-class:: small``.

- When used without Sphinx, i.e., native docutils, the the "small" caption at the end of a code block can use ``..  class:: small``.

This distinction is a minor change to the template being used.
The question is how to make that distinction in the weaver? There are several choices:

-   Use subclasses of :py:class:`Weaver` for this.

-   Note that templates are found by string name in the ``template_name_map`` within the :py:class:`Weaver` class.
    The ``--weaver`` command-line option provides a string (e.g., ``rst`` or ``html``) used to build a key into the template map.
    We can extend this string with options and features.

Using the ``--weaver`` command-line option allows us to provide an expanded set of names for RST processing.

- ``-w rst`` is the baseline, Sphinx option.

- ``-w rst-sphinx`` is an alias for ``rst``. The dictionary key points to the same templates as ``rst``.

- ``-w rst-nosphinx`` is the "pure-docutils" version, using ``.. class::`` instead of ``.. rst-class::``.

- ``-w rst-docutils`` is an alias for the ``rst-nosphinx`` option.

..  sidebar::

    While this works out nicely, it turns out that the ``..  container:: small`` is, perhaps, a better markup that ``..  class:: small``.
    This work in both docutils **and** Sphinx.

To match user expectations ``template_name_map`` must have a number of markup-related names.

-   ``markup``. A 1-tuple with the default list.

-   ``markup-option``. A 2-tuple with the default list and an override list that extends or customizes the defaults.

As noted above, there will be aliases in the markup-option category to provide alternative names for feature sets.

@d Weaver Subclass...
@{
# Template Definitions

@<Quote Rules Base Class@>

@<Debug Macros -- these display debugging information@>

@<RST Macros -- the default weave output@>

@<HTML Macros -- emit HTML weave output@>

@<LaTeX Macros -- emit LaTeX weave output@>

@<Common base template -- this is used for ALL weaving@>

class Weaver(Emitter):

    def __init__(self, output: Path = Path.cwd()) -> None:
        super().__init__(output)
        #: map markup name to macros in priority order: override, base
        self.template_name_map = {
            "debug": (debug_macros,),
            "rst": (rst_macros,),
            "html": (html_macros,),
            "tex": (tex_macros,),
            "latex": (tex_macros,),

            "rst-sphinx": (rst_macros,),
            "rst-nosphinx": (rst_docutils_macros, rst_macros,),
            "rst-docutils": (rst_docutils_macros, rst_macros,),

            "tex-verbatim": (tex_macros,),
            "tex-minted": (tex_minted_macros, tex_macros),
            "latex-verbatim": (tex_macros,),
            "latex-minted": (tex_minted_macros, tex_macros),
        }

        #: map markup name to quote rules.
        self.quote_rules = {
        "debug": debug_quote_rules,
        "rst": rst_quote_rules,
        "rst-sphinx": rst_quote_rules,
        "rst-nosphinx": rst_quote_rules,
        "rst-docutils": rst_quote_rules,
        "html": html_quote_rules,
        "tex": latex_quote_rules,
        "tex-verbatim": latex_quote_rules,
        "tex-minted": latex_minted_quote_rules,
        "latex": latex_quote_rules,
        "latex-verbatim": latex_quote_rules,
        "latex-minted": latex_minted_quote_rules,
        }

        #: macros found in the config file.
        self.config_macros = []

        #: final mapping from macro name to definition.
        self.template_map = {}

        #: Working JINJA environment.
        self.env = Environment(
            autoescape=select_autoescape()
        )

        #: Summary
        self.linesWritten = 0
        
    def set_markup(self, markup: str = "rst") -> "Weaver":
        self.markup = markup
        return self

    def emit(self, web: Web) -> None:
        """Open output files. Then generate woven text."""
        self.target_path = (self.output / web.web_path.name).with_suffix(f".{self.markup}")
        self.logger.info("Weaving %s using %s markup", self.target_path, self.markup)
        with self.target_path.open('w') as target_file:
            for text in self.generate_text(web):
                self.linesWritten += text.count("\n")
                target_file.write(text)

    def macro_name_iter(self, source: list[str]) -> Iterator[tuple[str, str]]:
        for m in source:
            ast = self.env.parse(m)
            for child in ast.iter_child_nodes():
                match child:
                    case jinja2.nodes.Macro() as macro:
                        yield macro.name, m
                    case _:
                        raise RuntimeError(f"improper macro text {type(child)!s}: {child!r}")

    def configure_macros(self, web: Web) -> None:
        if self.template_map: return
        self.env.filters |= {
            "quote_rules": self.quote_rules[self.markup]
        }
        ordered_definitions = (
            # list(web_template_iter())
            [self.config_macros] +
            list(self.template_name_map[self.markup])
        )
        ordered_macro_name_maps = [
            dict(self.macro_name_iter(priority))
            for priority in ordered_definitions
        ]
        all_macros = ChainMap(*ordered_macro_name_maps)
        macro_template = "\n\n".join(
            all_macros[k] for k in all_macros.keys()
        )
        self.template_map = {
            'base_weaver_template': base_weaver_template,
            'macros': macro_template
        }
        self.env.loader=DictLoader(self.template_map)

    def generate_text(self, web: Web) -> Iterator[str]:
        self.configure_macros(web)
        macros = self.env.get_template(f"macros")
        base_weaver_template = self.env.get_template("base_weaver_template")
        return base_weaver_template.generate(web=web, macros=macros)
@}

Within the Jinja framework, the macro definitions amount to **Strategy** plug-ins to the weaver.
Each set of macro definitions is unique for a particular flavor of markup.
The strategies include the quoting function used to escape markup characters.

A generic "base_weaver_template" template relies on macros.
The macro definitions come from four sources:

1. Application defaults, defined here.
2. Application overrides to the defaults, also defined here.
3. Configured overrides from ``pyweb.toml``.
4. Document overrides from the ``.w`` file in ``@@t name @@{...@@}`` commands.

The document overrides are the highest priority.

The ``Weaver`` class must populate the environment very late in the process.
This must be done **after** the configuration files are read and **after** the web has been parsed to locate template definitions.
We can then pick the templates to put into a ``DictLoader`` to support the standard weaving structure.

Additionally, quoting rules apply to some template languages.
The idea is that a few characters must be escaped for proper presentation in the code sample sections.

Common Base Template
********************

The common base template expands each chunk and each command in order.
This involves some special case processing for ``OutputChunk`` and ``NamedChunk``
which have a "wrapper" woven around the chunk's sequence of commands so that it's typeset in a distinctive style.

The base template relies on a number of individual macros:

-   ``text(command)``.
    Emits a block of text -- this should do *nothing* with the text.
    The author's original markup passes through untouched.
    
-   ``begin_code(chunk)``.
    Starts a block of code, either ``@@d`` or ``@@o``.
 
-   ``code(command)``.
    Emits a block fo code.
    This may require escapes for special characters that would break the markup being used.
    
-   ``ref(command)``.
    Emits a reference to a named block of code.

-   ``end_code(chunk)``.
    Ends a block of code.

-   ``file_xref(command)``.
    Emit the full ``@@f`` output, usually some kind of definition list.

-   ``macro_xref(command)``.
    Emit the full ``@@m`` output, usually some kind of definition list.

-   ``userid_xref(command)``.
    Emit the full ``@@u`` output, usually some kind of definition list.

The ``ref()`` macro can also be used in the XREF output macros. It can also be used in the ``end_code()`` macro.
After a block of code, some tools (like Interscript) will show where the block was referenced.
The point of using the ``ref()`` macro in multiple places is to make all of them look identical.

There are a some optional formatting considerations.
These include cross-references as well as the variety of ``begin_code()`` options.

There are four styles for the "referencedBy" information in a ``Chunk``.

-   Nothing. 

-   The immediate ``@@<name@@>`` Chunk.

-   The entire transitive sequence of parents for the ``@@<name@@>`` Chunk. There
    are two forms for this:
    
    -   Top-down path. ``→ Named (1) / → Sub-Named (2) / → Sub-Sub-Named (3)``.
    
    -   Bottom-up path.  ``→ Sub-Sub-Named (3) ∈ → Sub-Named (2) ∈ → Named (1)``.

These require four distinct versions of the ``end_code()`` macro.
This macro uses the ``transitive_referencedBy`` property of a ``Chunk`` producing a sequence of ``ref()`` values.

(Note the ``&rarr;`` characters is a preface characters for a link.)

The ``begin_code()`` and ``end_code()`` macros will bracket a code block.
In LaTeX, there are a number of ways to bracket a literal block, including ``Verbatim``, ``lstlisting``, ``minted``, or a custom-defined ``TColorBox``.
The ``begin_code()`` and ``end_code()`` macros must match, of course.
There may be distinct parameters, also, to provide additional parameters to the chunk.

@d Common base template...
@{
base_weaver_template = dedent("""\
    {%- from macros import text, begin_code, code, ref, end_code, file_xref, macro_xref, userid_xref -%}
    {% for chunk in web.chunks -%}
        {%- if chunk.type_is('OutputChunk') or chunk.type_is('NamedChunk') -%}
            {% if chunk.weave -%}
                {{begin_code(chunk)}}
                {%- for command in chunk.commands -%}
                    {%- if command.typeid.CodeCommand -%}{{code(command)}}
                    {%- elif command.typeid.ReferenceCommand -%}{{ref(command)}}
                    {%- endif -%}
                {%- endfor -%}
                {{end_code(chunk)}}
            {%- endif -%}
        {%- elif chunk.type_is('Chunk') -%}
            {%- for command in chunk.commands -%}
                {%- if command.typeid.TextCommand %}{{text(command)}}
                {%- elif command.typeid.ReferenceCommand %}{{ref(command)}}
                {%- elif command.typeid.FileXrefCommand %}{{file_xref(command)}}
                {%- elif command.typeid.MacroXrefCommand %}{{macro_xref(command)}}
                {%- elif command.typeid.UserIdXrefCommand %}{{userid_xref(command)}}
                {%- endif -%}
            {%- endfor -%}
        {%- endif -%}
    {%- endfor %}
""")
@}

The QuoteRule class lets us define a quote rule as a callable object.
The result of ``qr = QuoteRules(("this", "that"))`` is a callable object, ``qr()`` that performs the replacement.

@d Quote Rules Base Class
@{
class QuoteRules:
    def __init__(self, *mapping: tuple[str, str]) -> None:
        self.mapping = mapping
    def __call__(self, text: str) -> str:
        clean = text
        for from_, to_ in self.mapping:
            clean = clean.replace(from_, to_)
        return clean
@}


Debug Macros
***************

The debug macros don't use a quote rule with individual replacements. In this case, the quote rule is the built-in ``repr()`` function.

@d Debug Macros...
@{
debug_quote_rules = repr
    
debug_macros = [
    dedent("""\
        {%- macro text(command) -%}
        text: {{command}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro begin_code(chunk) %}
        begin_code: {{chunk}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro code(command) %}
        code: {{command}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro ref(id) %}
        ref: {{id}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro end_code(chunk) %}
        end_code: {{chunk}}
        {% endmacro -%}
    """),
    dedent("""\
        {%- macro file_xref(command) -%}
        file_xref {{command.files}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro macro_xref(command) -%}
        macro_xref {{command.macros}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro userid_xref(command) -%}
        userid_xref {{command.userids}}
        {%- endmacro -%}
    """)
    ]
@}

RST Macros
***************

The RST Macros produce ReStructuredText for the various web commands.
Note that code lines must be indented when using this markup.

There is a base set of template macros.
The ``rst_weaver_template`` variable defines the default macros.
The ``rst-sphinx`` key makes these defaults active.

These can be overridden by macros defined in
the ``rst_nosphinx_template`` variable.
This defines  updates to the base templates focused on **docutils**.
The ``rst-nosphinx`` and ``rst-docutils`` keys provides updates to the base temples focused on docutils.

@d RST Macros...
@{
rst_quote_rules = str

 # Old rules, used with ``..  parsed-literal::``
 #rst_quote_rules = QuoteRules(
 #       ('\\', r'\\'), # Must be first.
 #       ('`', r'\`'),
 #       ('_', r'\_'),
 #       ('*', r'\*'),
 #       ('|', r'\|'),
 #   )

rst_macros = [
    dedent("""
        {%- macro text(command) -%}
        {{command.text}}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro begin_code(chunk) %}
        ..  _`{{chunk.full_name or chunk.name}} ({{chunk.seq}})`:
        ..  rubric:: {{chunk.full_name or chunk.name}} ({{chunk.seq}}) {% if chunk.initial %}={% else %}+={% endif %}
        ..  code-block::
            :class: code

        {% endmacro -%}
    """),
    dedent("""\
        {# For RST, each line must be indented. #}
        {%- macro code(command) %}{% for line in command.text.splitlines() %}    {{line | quote_rules}}
        {% endfor -%}{% endmacro -%}
    """),
    dedent("""\
        {%- macro ref(id) %}    \N{RIGHTWARDS ARROW} `{{id.full_name or id.name}} ({{id.seq}})`_{% endmacro -%}
    """),
   dedent("""\
        {%- macro end_code(chunk) %}
        ..

        ..  container:: small

            \N{END OF PROOF} *{{chunk.full_name or chunk.name}} ({{chunk.seq}})*.
            {% if chunk.referencedBy %}Used by {{ref(chunk.referencedBy)}}.{% endif %}

        {% endmacro -%}
    """),
    dedent("""\
        {%- macro file_xref(command) -%}
        {% for file in command.files -%}
        :{{file.name}}:
            \N{RIGHTWARDS ARROW} `{{file.name}} ({{file.seq}})`_
        {%- endfor %}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro macro_xref(command) -%}
        {% for macro in command.macros -%}
        :{{macro.full_name}}:
            {% for d in macro.def_list -%}\N{RIGHTWARDS ARROW} `{{d.full_name or d.name}} ({{d.seq}})`_{% if loop.last %}{% else %}, {% endif %}{%- endfor %}

        {% endfor %}
        {%- endmacro -%}
    """),
    dedent("""\
        {%- macro userid_xref(command) -%}
        {% for userid in command.userids -%}
        :{{userid.userid}}:
            {% for r in userid.ref_list -%}\N{RIGHTWARDS ARROW} `{{r.full_name or r.name}} ({{r.seq}})`_{% if loop.last %}{% else %}, {% endif %}{%- endfor %}

        {% endfor %}
        {%- endmacro -%}
    """)
    ]

rst_docutils_macros = [
    dedent("""\
        {%- macro end_code(chunk) %}
        ..

        ..  class:: small

            \N{END OF PROOF} *{{chunk.full_name or chunk.name}} ({{chunk.seq}})*

        {% endmacro -%}
    """)
    ]
@}

HTML Macros
***************

The HTML macros use a relatively simple markup, avoiding any CSS names.
A slightly more flexible approach might be to name specific CSS styles, and provide generic definitions for those styles.
This would make it easier to tailor HTML output via CSS changes, avoiding any HTML modifications.

The ``ref()`` macro injects ``&rarr;`` characters into the chunk references as an attempt to make it clear they are links.

@d HTML Macros...
@{
html_quote_rules = QuoteRules(
        ("&", "&amp;"),  # Must be first
        ("<", "&lt;"),
        (">", "&gt;"),
        ('"', "&quot;"),  # Only applies inside tags...
    )

html_macros = [
    dedent("""\
    {%- macro text(command) -%}
    {{command.text}}
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro begin_code(chunk) %}
    <a name="pyweb_{{chunk.seq}}"></a>
    <!--line number {{chunk.location}}-->
    <p><em>{{chunk.full_name or chunk.name}} ({{chunk.seq}})</em> {% if chunk.initial %}={% else %}+={% endif %}</p>
    <pre><code>
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro code(command) -%}{{command.text | quote_rules}}{%- endmacro -%}
    """),
    dedent("""\
    {%- macro ref(id) %}&rarr;<a href="#pyweb_{{id.seq}}"><em>{{id.full_name or id.name}} ({{id.seq}})</em></a>{% endmacro -%}
    """),
    dedent("""\
    {%- macro end_code(chunk) %}
    </code></pre>
    <p>&#8718; <em>{{chunk.full_name or chunk.name}} ({{chunk.seq}})</em>.
    {% if chunk.referencedBy %}Used by {{ref(chunk.referencedBy)}}.{% endif %}
    </p> 
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro file_xref(command) %}
    <dl>
    {% for file in command.files -%}
      <dt>{{file.name}}</dt><dd>{{ref(file)}}</dd>
    {%- endfor %}
    </dl>
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro macro_xref(command) %}
    <dl>
    {% for macro in command.macros -%}
      <dt>{{macro.full_name}}<dt>
      <dd>{% for d in macro.def_list -%}{{ref(d)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}</dd>
    {% endfor %}
    </dl>
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro userid_xref(command) %}
    <dl>
    {% for userid in command.userids -%}
      <dt>{{userid.userid}}</dt>
      <dd>{% for r in userid.ref_list -%}{{ref(r)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}</dd>
    {% endfor %}
    </dl>
    {% endmacro -%}
    """)
    ]
@}

LaTeX Macros
***************

The LaTeX macros defined here use a markup focused on using the ``Verbatim`` environment.
Common alternatives include ``lstlistings`` and ``minted``.
A particular popular form uses Text Color Block (TCB) to create distinctive code formatting.

@d LaTeX Macros...
@{
latex_quote_rules = QuoteRules(
        ("\\end{Verbatim}", "\\end\\,{Verbatim}"),  # Allow \end{Verbatim} in a Verbatim context
        ("\\{", "\\\\,{"), # Prevent unexpected commands in Verbatim
        ("$", "\\$"), # Prevent unexpected math in Verbatim
    )

latex_minted_quote_rules = QuoteRules(
        ("\\end{minted}", "\\end\\,{minted}"),  # Allow \end{minted} in a minted context
    )

tex_macros = [
    dedent("""\
    {%- macro text(command) -%}
    {{command.text}}
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro begin_code(chunk) %}
    \\label{pyweb-{{chunk.seq}}}
    \\begin{flushleft}
    \\textit{Code example {{chunk.full_name or chunk.name}} ({{chunk.seq}})}
    \\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro code(command) -%}{{command.text | quote_rules}}{%- endmacro -%}
    """),
    dedent("""\
    {%- macro ref(id) %}$$\\rightarrow$$ Code Example {{id.full_name or id.name}} ({{id.seq}}){% endmacro -%}
    """),
    dedent("""\
    {%- macro end_code(chunk) %}
    \\end{Verbatim}
    \\end{flushleft}
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro file_xref(command) %}
    \\begin{itemize}
    {% for file in command.files -%}
      \\item {{file.name}}: {{ref(file)}}
    {%- endfor %}
    \\end{itemize}
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro macro_xref(command) %}
    \\begin{itemize}
    {% for macro in command.macros -%}
      \\item {{macro.full_name}} \\\\
            {% for d in macro.def_list -%}{{ref(d)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
    {% endfor %}
    \\end{itemize}
    {% endmacro -%}
    """),
    dedent("""\
    {%- macro userid_xref(command) %}
    \\begin{itemize}
    {% for userid in command.userids -%}
      \\item {{userid.userid}} \\\\
            {% for r in userid.ref_list -%}{{ref(r)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
    {% endfor %}
    \\end{itemize}
    {% endmacro -%}
    """)
    ]

tex_minted_macros = [
    dedent("""\
    {%- macro begin_code(chunk) %}
    \\label{pyweb-{{chunk.seq}}}
    \\textit{Code example {{chunk.full_name or chunk.name}} ({{chunk.seq}})}
    \\begin{minted}{{'{'}}{{chunk.style}}{{'}'}}
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro end_code(chunk) %}
    \\end{minted}
    {% endmacro -%}
    """),
    ]
@}

The Tangler Subclasses
~~~~~~~~~~~~~~~~~~~~~~

Tangling is a variation on emitting that includes all the code in the order defined by the ``@@o`` file commands.
This is not necessarily the order they're presented in the document.

The whole point of Weaving and Tangling is to write a document in an order that's sensible for people to understand.
The tangled output is for compilers and run-time environments.

Each file is individually tangled, unrelated to the order of the source
WEB document.
The ``emit()`` process, therefore, iterates through all of the files defined in the WEB.

There's a complex interplay between ``Tangler`` and ``CodeCommand``
to maintain the indentations.

..  uml::

    participant Tangler
    
    participant ReferenceCommand
    
    participant Command
    
    Tangler --> ReferenceCommand : tangle()
    ReferenceCommand --> Tangler : get len(fragment)
    ReferenceCommand --> Tangler : addIndent(i)
    group [for all] commands in the referenced chunk
        ReferenceCommand --> Command : tangle()
    end 
    ReferenceCommand --> Tangler : clrIndent()

This approach can preserves the indentation in front of a ``@@< reference @@>`` command.

@d Tangler Subclass...
@{
class Tangler(Emitter):
    code_indent = 0  #: Initial indent

    def __init__(self, output: Path = Path.cwd()) -> None:
        super().__init__(output)
        self.include_line_numbers = False
        self.context: list[int] = []  #: Indentations
        self.fragment = ""  # Nothing written yet.
        # Create context and initial lastIndent values
        self.resetIndent(self.code_indent)
        # Summaries
        self.reference_names: set[str] = set()
        self.linesWritten = 0
        self.totalFiles = 0
        self.totalLines = 0
        self.logger.debug("output base: %r, line numbers %s", self.output, self.include_line_numbers)

    def emit(self, web: Web) -> None:
        for file_chunk in web.files:
            self.logger.info("Tangling %s", file_chunk.name)
            self.emit_file(web, file_chunk)
            
    def emit_file(self, web: Web, file_chunk: Chunk) -> None:
        target_path = self.output / (file_chunk.name or "Untitled.out")
        self.logger.debug("Writing %s", target_path)
        self.logger.debug("Chunk %r", file_chunk)
        with target_path.open("w") as target:
            # An initial command to provide indentations.
            for command in file_chunk.commands:
                command.tangle(self, target)
                
    @< Emitter write a block of code with proper indents @>

    @< Emitter indent control: set, clear and reset @>
@}

The ``codeBlock()`` method is used by each block of code tangled into 
a document. There are two sources of indentation:

-   A ``Chunk`` can provide an indent setting as an option. This is provided by the ``indent`` attribute
    of the tangle context. If specified, this is the indentation. 
    
-   A ``@@< name @@>`` ``ReferenceCommand`` may be indented. This will be in a ``Chunk`` as the following three commands:

    1.  A ``CodeCommand`` with only spaces and no trailing ``\n``. 
        The indent is buffered -- not written -- and the ``fragment`` attribute is set.
    
    2.  The ``ReferenceCommand``. This interpolates text from a ``NamedChunk`` using the prevailing indent.
        The ``tangle()`` method uses ``addIndent()`` and ``clrIndent()`` to mark this. The processing depends 
        on this tangler's ``fragment`` attribute to provide the pending indentation; the ``addIndent()`` 
        must consume the fragment to prevent confusion with subsequent indentations.
    
    3.  A ``CodeCommand`` with a trailing ``\n``. (Often it's only the newline.)  If the ``fragment`` attribute
        is set, there's a pending indentation that hasn't yet been written.
        This can happen with there's a ``@@@@`` command at the left end of a line; often a Python decorator. 
        The fragment is written and the ``fragment`` attribute cleared.  No ``addIdent()`` will have
        been done to consume the fragment. 

..  todo:: Insert line numbers into the code

    This is inserted before the first (``CodeCommand`` with a trailing ``\n``, and there is no pending ``fragment``) condition.

    This supports the ``include_line_numbers`` feature.

While the WEB language permits multiple ``@@<name@@> @@<name@@>`` on a single line,
this is odd and potentially confusing. It isn't clear how the second reference
should be indented.

The ``ReferenceCommand`` ``tangle()`` implementation handles much of this. 
The following two rules apply:
    
-   A line of text that does not end with a newline,
    sets a new prevailing indent for the following command(s).

-   A line of text ending with a newline resets the prevailing indent.

This a stack of indentations, maintained by the ``Tangler``.


@d Emitter write a block of code...
@{
def codeBlock(self, target: TextIO, text: str) -> None:
    """Indented write of text in a ``CodeCommand``. 
    Counts lines and saves position to indent to when expanding ``@@<...@@>`` references.
    
    The ``fragment`` is the prevailing indent used in reference expansion.
    """
    for line in text.splitlines(keepends=True):
        self.logger.debug("codeBlock(%r)", line)
        indent = self.context[-1]
        if len(line) == 0:
            # Degenerate case of empty CodeText command. Should not occur.
            pass
        elif not line.endswith('\n'):
            # Possible start of indentation prior to a ``@@<name@@>``
            target.write(indent*' ')
            wrote = target.write(line)
            self.fragment = ' ' * wrote
            # May be used by a ``ReferenceCommand``, if needed.
        elif line.endswith('\n'):
            target.write(indent*' ')
            target.write(line)
            self.linesWritten += 1
        else:
            raise RuntimeError("Non-exhaustive if statement.")

@| codeBlock
@}

The ``addIndent()`` increments the indent. 
Used by ``@@<name@@>`` to set a prevailing indent.

The ``setIndent()`` pushes a fixed indent instead adding an increment. 
Used by a ``Chunk`` with an ``-indent`` option.
    
The ``clrIndent()`` method discards the most recent indent from the context stack.  
This is used when finished
tangling a source chunk.  This restores the indent to the prevailing indent.

The ``resetIndent()`` method removes all indent context information and resets the indent
to a default.

@d Emitter indent control...
@{
def addIndent(self, increment: int) -> None:
    self.lastIndent = self.context[-1]+increment
    self.context.append(self.lastIndent)
    self.log_indent.debug("addIndent %d: %r", increment, self.context)
    self.fragment = ""
    
def setIndent(self, indent: int) -> None:
    self.context.append(indent)
    self.lastIndent = self.context[-1]
    self.log_indent.debug("setIndent %d: %r", indent, self.context)
    self.fragment = ""

def clrIndent(self) -> None:
    if len(self.context) > 1:
        self.context.pop()
    self.lastIndent = self.context[-1]
    self.log_indent.debug("clrIndent %r", self.context)
    self.fragment = ""

def resetIndent(self, indent: int = 0) -> None:
    """Resets the indentation context."""
    self.lastIndent = indent
    self.context = [self.lastIndent]
    self.log_indent.debug("resetIndent %d: %r", indent, self.context)
@| addIndent setIndent clrIndent resetIndent
@}

An extension to the ``Tangler`` class that only updates a file if the content has changed.
This tangles to a temporary file.
If the content is identical, the temporary file is quietly disposed of.
Otherwise, the temporary file is linked to the original name.

Files are compared with the ``filecmp`` module.

@d Imports
@{import filecmp
import tempfile
import os
@}

@d TanglerMake Subclass...
@{
class TanglerMake(Tangler):
    def emit_file(self, web: Web, file_chunk: Chunk) -> None:
        target_path = self.output / (file_chunk.name or "Untitled.out")
        self.logger.debug("Writing %s via a temp file", target_path)
        self.logger.debug("Chunk %r", file_chunk)

        fd, tempname = tempfile.mkstemp(dir=os.curdir)
        with os.fdopen(fd, "w") as target:
            for command in file_chunk.commands:
                command.tangle(self, target)
                
        try:
            same = filecmp.cmp(tempname, target_path)
        except OSError as e:
            same = False  # Doesn't exist. (Could check for errno.ENOENT)
            
        if same:
            self.logger.info("Unchanged '%s'", target_path)
            os.remove(tempname)
        else:
            # Windows requires the original file name be removed first.
            try: 
                target_path.unlink()
            except OSError as e:
                pass  # Doesn't exist. (Could check for errno.ENOENT)
            target_path.parent.mkdir(parents=True, exist_ok=True)
            target_path.hardlink_to(tempname)
            os.remove(tempname)
            self.logger.info("Wrote %d lines to %s", self.linesWritten, target_path)
@}

Input Parsing
-------------

There are three tiers to the input parsing:

-   A base tokenizer.

-   Additionally, a separate parser is used for options in ``@@d`` and ``@@o`` commands.

-   The overall ``WebReader`` class.


..  uml::

    class WebReader {
        load(path) : Web
        parse_source()
    }
    
    class Tokenizer <<Iterator>> {
        __next__(self) : str
    }
        
    WebReader --> Tokenizer
    WebReader --> WebReader : "parent"
    WebReader --> argparse.ArgumentParser
    
We'll start with the ``WebReader`` class definition


@d Base Class Definitions
@{
@<Tokenizer class - breaks input into tokens@>

@<WebReader class - parses the input file, building the Web structure@>
@}

The WebReader Class
~~~~~~~~~~~~~~~~~~~

There are two forms of the constructor for a ``WebReader``.
The  initial ``WebReader`` instance is created with code like the following:


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

The commands have three general types:

-   "Structural" commands define the structure of the ``Chunks``.  The  structural commands 
    are ``@@d`` and ``@@o``, as well as the ``@@{``, ``@@}``, ``@@[``, ``@@]`` brackets, 
    and the ``@@i`` command to include another file.

-   "Inline" commands are inline within a ``Chunk``: they define internal ``Commands``.  
    Blocks of text are minor commands, as well as the ``@@<``\ *name*\ ``@@>`` references.
    The ``@@@@`` escape is also
    handled here so that all further processing is independent of any parsing.

-   "Content" commands generate woven content. These include 
    the various cross-reference commands (``@@f``, ``@@m`` and ``@@u``).  

There are two class-level ``argparse.ArgumentParser`` instances used by this class.

:output_option_parser:
    An ``argparse.ArgumentParser`` used to parse the ``@@o`` command's options.
    
:definition_option_parser:
    An ``argparse.ArgumentParser`` used to parse the ``@@d`` command's options.

The class has the following attributes:

:parent:
    is the outer ``WebReader`` when processing a ``@@i`` command.

:command:
    is the command character; a WebReader will use the parent command 
    character if the parent is not ``None``. Default is ``@@``.

:permitList:
    is the list of commands that are permitted to fail.  This is generally 
    an empty list or ``('@@i',)``.

:_source:
    The open file-like object being used by ``load()``.
    
:filePath:
    The path being processed; this provides a visible file name.

:tokenizer:
    An instance of ``Tokenizer`` used to parse the input. This is built
    when ``load()`` is called.
    
:totalLines:
:totalFiles:
:errors:
    Summary counts.

@d WebReader class...
@{
class WebReader:
    """Parse an input file, creating Chunks and Commands."""

    # Configuration
    #: The command prefix, default ``@@``.
    command: str 
    #: Permitted errors, usually @@i commands
    permitList: list[str]
    #: Working directory to resolve @@i commands  
    base_path: Path  
    #: The tokenizer used to find commands
    tokenizer: Tokenizer  
    
    # State of the reader
    #: Parent context for @@i commands      
    parent: "WebReader | None"
    #: Input Path 
    filePath: Path 
    #: Input file-like object, default is self.filePath.open()
    _source: TextIO  
    #: The sequence of Chunk instances being built
    content: list[Chunk] 
    
    def __init__(self, parent: "WebReader | None" = None) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)

        # Configuration comes from the parent or defaults if there is no parent.
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

The reader maintains a context into which constructs are added.
The ``Web`` contains ``Chunk`` instances in ``self.web.chunks``.
The current chunk is ``self.web.chunks[-1]``.
Each ``Chunk``, similarly, has a command context in ``chunk.commands[-1]``.

This works because the language is "flat": there are no nested ``@@d`` or ``@@o``
chunks.

Command recognition is done via a **Chain of Command**-like design.
There are two conditions: the command string is recognized or it is not recognized.
If the command is recognized, ``handleCommand()`` will do one of the following:

-   For "structural" commands, it will attach the current ``Chunk`` (*self.aChunk*) to the 
    current ``Web`` (*self.aWeb*), and start a new ``Chunk``. This becomes the context
    for processing commands. By default an anonymous ``Chunk`` used to accumulate text
    is available for all of the content outside named chunks.

-   For "inline" and "content" commands, create a ``Command``, attach it to the current 
    ``Chunk`` (*self.aChunk*).

If the command is not recognized, ``handleCommand()`` returns false, and this is a syntax error.

A subclass can override ``handleCommand()`` to 

(1) Evaluate the base class ``handleCommand()`` method;

(2) If the command is unknown to the base,
    then the current class can process it;

(3) If the command is unknown to both classes, 
    then return ``False``.  Either a subclass will handle it, or the default activity taken
    by ``load()`` is to treat the command as a syntax error.

The ``handleCommand()`` implementation is a massive ``match`` statement.
It might be a good idea to decompose this into a number of separate methods.
This would make the ``match`` statement shorter and easier to understand.

@d WebReader handle a command...
@{
def handleCommand(self, token: str) -> bool:
    self.logger.debug("Reading %r", token)
    new_chunk: Chunk | None = None
    match token[:2]:
        case self.cmdo:
            @<start an OutputChunk, adding it to the web@>
        case self.cmdd:
            @<start a NamedChunk or NamedDocumentChunk, adding it to the web@>
        case self.cmdi:
            @<include another file@>
        case self.cmdrcurl | self.cmdrbrak:
            @<finish a chunk, start a new Chunk adding it to the web@>
        case self.cmdpipe:
            @<assign user identifiers to the current chunk@>
        case self.cmdf:
            self.content[-1].commands.append(FileXrefCommand(self.location()))
        case self.cmdm:
            self.content[-1].commands.append(MacroXrefCommand(self.location()))
        case self.cmdu:
            self.content[-1].commands.append(UserIdXrefCommand(self.location()))
        case self.cmdlangl:
            @<add a reference command to the current chunk@>
        case self.cmdlexpr:
            @<add an expression command to the current chunk@>
        case self.cmdcmd:
            @<double at-sign replacement, append this character to previous TextCommand@>
        case self.cmdlcurl | self.cmdlbrak:
            # These should have been consumed as part of @@o and @@d parsing
            self.logger.error("Extra %r (possibly missing chunk name) near %r", token, self.location())
            self.errors += 1
        case _:
            return False  # did not recogize the command
    return True  # did recognize the command
@| handleCommand
@}


An output chunk has the form ``@@o`` *name* ``@@{`` *content* ``@@}``.
We use the first two tokens to name the ``OutputChunk``.  We expect
the ``@@{`` separator.  We then attach all subsequent commands
to this chunk while waiting for the final ``@@}`` token to end the chunk.

We'll use an ``ArgumentParser`` to locate the optional parameters.  This will then let
us build an appropriate instance of ``OutputChunk``.

With some small additional changes, we could use ``OutputChunk(**options)``.
    
@d start an OutputChunk...
@{
arg_str = next(self.tokenizer)
self.expect({self.cmdlcurl})
new_chunk = OutputChunk(options=shlex.split(arg_str))
self.content.append(new_chunk)
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

We'll use an ``ArgumentParser`` to locate the optional parameter of ``-noindent``.

..  todo:: Extend the ``@@d`` argument parser to support ``-indent`` *number*

Then we can use the ``options`` value to create an appropriate subclass of ``NamedChunk``.
        
If ```"-indent"`` is in options, this is the default. 
If both are in the options, we should provide a warning.

..  todo:: Add a warning for conflicting options.

@d start a NamedChunk...
@{
arg_str = next(self.tokenizer)
brack = self.expect({self.cmdlcurl, self.cmdlbrak})

# REFACTOR parse_options into various CHUNK types.
# REFACTOR remove NamedChunk_Noindent as a distinct subclass.
if brack == self.cmdlbrak:
    # options = NamedDocumentChunk.parse_options(shlex.split(arg_str))
    # name = ' '.join(options.argument)
    new_chunk = NamedDocumentChunk(options=shlex.split(arg_str))
elif brack == self.cmdlcurl:
    # options = NamedChunk.parse_options(shlex.split(arg_str))
    # indent: None | int = None
    # name = ' '.join(options.argument)
    # if 'noindent' in options and options.noindent:
    #     indent = 0
    # elif 'indent' in options and options.indent:
    #     indent = int(options.indent)
    new_chunk = NamedChunk(options=shlex.split(arg_str))
elif brack == None:
    new_chunk = None
    pass  # Error already noted by ``expect()``
else:
    raise RuntimeError("Design Error")

if new_chunk:
    self.content.append(new_chunk)
# capture a NamedChunk up to @@} or @@]
@}

An import command has the unusual form of ``@@i`` *name*, with no trailing
separator.  When we encounter the ``@@i`` token, the next token will start with the
file name, but may continue with an anonymous chunk.  To avoid confusion,
we require that all ``@@i`` commands occur at the end of a line, 
The break on the ``'\n'`` which ends the file name.
This permits file names with embedded spaces. It also permits arguments and options,
if really necessary.

Once we have split the file name away from the rest of the following anonymous chunk,
we push the following token (a ``\n``) back into the token stream, so that it will be the 
first token examined at the top of the ``load()`` loop.

We create a child ``WebReader`` instance to process the included file.  The entire file 
is loaded into the current ``Web`` instance.  A new, empty ``Chunk`` is created at the end
of the file so that processing can resume with an anonymous ``Chunk``.

The reader has a ``permitList`` attribute.
This lists any commands where failure is permitted.  Currently, only the ``@@i`` command
can be set to permit failure; this allows a ``.w`` to include
a file that does not yet exist.  
 
The primary use case for this permitted error feature is when weaving test output.
A first use of the **py-web-lp** can be used to tangle the program source files,
ignoring a missing test output file, named in an ``@@i`` command.
The application can then be run to create the missing test output file. 
After this, a second use of the **py-web-lp**
can weave the test output file into a final, complete document.

@d include another file
@{
incPath = Path(next(self.tokenizer).strip())
try:
    include = WebReader(parent=self)
    if not incPath.is_absolute():
        incPath = self.base_path / incPath
    self.logger.info("Including '%s'", incPath)
    self.content.extend(include.load(incPath))
    self.totalLines += include.tokenizer.lineNumber
    self.totalFiles += include.totalFiles
    if include.errors:
        self.errors += include.errors
        self.logger.error("Errors in included file '%s', output is incomplete.", incPath.relative_to(self.base_path))
except Error as e:
    self.logger.error("Problems with included file '%s', output is incomplete.", incPath)
    self.errors += 1
except IOError as e:
    self.logger.error("Problems finding included file '%s', output is incomplete.", incPath)
    # Discretionary -- sometimes we want to continue
    if self.cmdi in self.permitList: pass
    else: raise  # Seems heavy-handed, but, the file wasn't found!
# Start a new context for text or commands *after* the ``@@i``.
self.content.append(Chunk())
@}

When a ``@@}`` or ``@@]`` are found, this finishes a named chunk.
The next text is therefore part of an anonymous chunk.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@@{`` or ``@@[``.  
To do this, an attribute would be needed for each ``Chunk`` subclass that indicated if a trailing bracket was necessary.
For the base ``Chunk`` class, this would be false, but for all other subclasses of
``Chunk``, this would be true.


@d finish a chunk...
@{
# Start a new context for text or commands *after* this command.
self.content.append(Chunk())
@}

User identifiers occur after a ``@@|`` command inside a ``NamedChunk``.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@@{``.  
To do this, an attribute would be needed for each ``Chunk`` subclass that indicated if user identifiers are permitted.
For the base ``Chunk`` class, this would be false, but for the ``NamedChunk`` class and
``OutputChunk`` class, this would be true.

User identifiers are name references at the end of a NamedChunk
These are accumulated and expanded by ``@@u`` reference

@d assign user identifiers... 
@{
try:
    names = next(self.tokenizer).strip().split()
    self.content[-1].def_names.extend(names)
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
name = next(self.tokenizer).strip()
closing = self.expect({self.cmdrangl})
self.content[-1].commands.append(ReferenceCommand(name, self.location()))
self.logger.debug("Reading %r %r", name, closing)
@}

An expression command has the form ``@@(``\ *Python Expression*\ ``@@)``.  
We accept three tokens from the input, the middle token is the expression.

There are two alternative semantics for an embedded expression.

-   **Deferred Execution**.  This requires definition of a new subclass of ``Command``, 
    ``ExpressionCommand``, and appends it into the current ``Chunk``.  At weave and
    tangle time, this expression is evaluated.  The insert might look something like this:
    ``aChunk.append(ExpressionCommand(expression, self.location()))``.

-   **Immediate Execution**.  This simply creates a context and evaluates
    the Python expression.  The output from the expression becomes a ``TextCommand``, and
    is append to the current ``Chunk``.

We use the **Immediate Execution** semantics -- the expression is immediately appended
to the current chunk's text.

We provide a few elements of the ``os`` module.  We provide ``os.path`` library.
The ``os.getcwd()`` could be changed to ``os.path.realpath('.')``, but that seems too long-winded.

@d Imports 
@{import builtins
import sys
import platform
@| builtins sys platform
@}

..  todo:: Appending the text should be a method of a ``Chunk`` -- either append text, or append a command.

@d add an expression command...
@{
# get the Python expression, create the expression result
expression = next(self.tokenizer)
self.expect({self.cmdrexpr})
try:
    # Build Context
    # **TODO:** Parts of this are static and can be built as part of ``__init__()``.
    dangerous = {
        'breakpoint', 'compile', 'eval', 'exec', 'execfile', 'globals', 'help', 'input', 
        'memoryview', 'open', 'print', 'super', '__import__'
    }
    safe = types.SimpleNamespace(**dict(
        (name, obj) 
        for name,obj in builtins.__dict__.items() 
        if name not in dangerous
    ))
    globals = dict(
        __builtins__=safe, 
        os=types.SimpleNamespace(path=os.path, getcwd=os.getcwd, name=os.name),
        time=time,
        datetime=datetime,
        platform=platform,
        theWebReader=self,
        theFile=self.filePath,
        thisApplication=sys.argv[0],
        __version__=__version__,  # Legacy compatibility. Deprecated.
        version=__version__,
        theLocation=str(self.location()),  # The only thing that's dynamic
        )
    # Evaluate
    result = str(eval(expression, globals))
except Exception as exc:
    self.logger.error('Failure to process %r: exception is %r', expression, exc)
    self.errors += 1
    result = f"@@({expression!r}: Error {exc!r}@@)"
self.content[-1].add_text(result, self.location())
@}

A double command sequence (``'@@@@'``, when the command is an ``'@@'``) has the usual meaning of ``'@@'`` in the input stream.
We do this by appending text to the last command in the current ``Chunk``.
This will append the  character on the end of the most recent ``TextCommand`` or ``CodeCommand```.
If this fails, it will create a new, empty ``TextCommand`` or ``CodeCommand``.

..  todo:: Appending a ``'@@'`` command character should be a method of a Chunk -- either append text, or append a command.

@d double at-sign replacement...
@{
self.logger.debug(f"double-command: {self.content[-1]=}")
self.content[-1].add_text(self.command, self.location())
@}

The ``expect()`` method examines the next token to see if it is the expected item.
Any ``'\n'`` characters are absorbed.
If this is not found, a standard type of error message is raised. 
This is used by ``handleCommand()``.

@d WebReader handle a command...
@{
def expect(self, tokens: set[str]) -> str | None:
    """Compare next token with expectation, quietly skipping whitespace (i.e., ``\n``)."""
    try:
        t = next(self.tokenizer)
        while t == '\n':
            t = next(self.tokenizer)
    except StopIteration:
        self.logger.error("At %r: end of input, %r not found", self.location(), tokens)
        self.errors += 1
        return None
    if t in tokens:
        return t
    else:
        self.logger.error("At %r: expected %r, found %r", self.location(), tokens, t)
        self.errors += 1
        return None
@| expect
@}

The ``location()`` provides the file name and line number.
This allows error messages as well as tangled or woven output 
to correctly reference the original input files.

@d WebReader location...
@{
def location(self) -> tuple[str, int]:
    return (str(self.filePath.relative_to(self.base_path)), self.tokenizer.lineNumber+1)
@| location
@}

The ``load()`` method reads the entire input file as a sequence of tokens, split up by the ``Tokenizer``.
Each token that appears to be a command is passed to the ``handleCommand()`` method.
If the ``handleCommand()`` method returns a True result, the command was recognized and placed in the ``Web``.
If ``handleCommand()`` returns a False result, the command was unknown, and we write a warning but treat it as text.

The ``load()`` method is used recursively to handle the ``@@i`` command.
The issue is that it's always loading a single top-level web.

@d Imports
@{from typing import TextIO, cast
@}

@d WebReader load...
@{
def load(self, filepath: Path, source: TextIO | None = None) -> list[Chunk]:
    """Returns a flat list of chunks to be made into a Web. 
    Also used to expand ``@@i`` included files.
    """
    self.filePath = filepath
    self.base_path = self.filePath.parent

    if source:
        self._source = source
        self.parse_source()
    else:
        with self.filePath.open() as self._source:
            self.parse_source()
    return self.content

def parse_source(self) -> None:
    """Builds a sequence of Chunks."""
    self.tokenizer = Tokenizer(self._source, self.command)
    self.totalFiles += 1

    # Initial anonymous chunk.
    self.content = [Chunk()]

    for token in self.tokenizer:
        if len(token) >= 2 and token.startswith(self.command):
            if self.handleCommand(token):
                continue
            else:
                self.logger.error('Unknown @@-command in input: %r near %r', token, self.location())
                self.content[-1].add_text(token, self.location())
                
        elif token:
            # Accumulate a non-empty block of text in the current chunk.
            self.content[-1].add_text(token, self.location())

        else:
            # Whitespace
            pass
    self.logger.debug("parse_source: [")
    for c in self.content:
        self.logger.debug("  %r", c)
    self.logger.debug("]")
@| load parse
@}

The command character can be changed to permit
some flexibility when working with languages that make extensive use of the ``@@`` symbol.
The initialization of the ``WebReader`` is based on the selected command character.


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

The ``WebReader`` requires a tokenizer. The tokenizer breaks the input text into a stream of tokens.
There are two broad classes of tokens:

-   ``r'@@.'`` command tokens, including the structural, inline, and content
    commands.

-   ``r'\n'``. Inside text, these matter.
    Within structural command tokens, these don't matter.
    Except after the filename after an ``@@i`` command, where one of these end the command.

-   The remaining text; neither newlines nor commands.

The tokenizer works by reading the entire file and splitting on ``r'@@.'`` patterns.
The ``re.split()`` function will separate the input and preserve the actual character sequence on which the input was split.
This breaks the input into blocks of text separated by the ``r'@@.'`` characters.

For example:

..  parsed-literal::

    >>> pat.split( "@@{hi mom@@}")
    ['', '@@{', 'hi mom', '@@}', '']
    
This tokenizer splits the input using ``r'@@.|\n'``.
The idea is that  we locate commands, newlines and the interstitial text as three classes of tokens.
We can then assemble each ``Command`` instance from a short sequence of tokens.
The core ``TextCommand`` and ``CodeCommand`` will be a line of text ending with the ``\n``.

The tokenizer counts newline characters for us, so that error messages can include a line number.
Also, we can tangle extract comments into a file to reveal source line numbers.

Since the tokenizer is a proper iterator, we can use ``tokens = iter(Tokenizer(source))`` and ``next(tokens)`` to step through the sequence of tokens until we raise a ``StopIteration``
exception.

@d Imports
@{import re
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

Other Application Components
----------------------------

There are a number of other components:

-   `Error class`_ Defines a uniform exception for this module.

-   `Action Class Hierarchy`_ defines the actions the application can perform.
    This includes loading the WEB file, weaving, tangling, and doing combinations of actions.
    
-   `The Application Class`_ is a high-level definition of the **py-web-lp** application as a whole.

-   `Logging setup`_ defines a handy context manager to configure and shut down logging.

-   `The Main Function`_ is a top-level function to create an instance of ``Application``,
    and execute it with either supplied arguments or (by default) the actual command-line
    arguments. This makes it easy to import and reuse ``main()`` in other applications.

Error class
~~~~~~~~~~~

An ``Error`` is raised whenever processing cannot continue.
Since it is a subclass of ``Exception``, it takes an arbitrary number of arguments.
The first should be the basic message text.
Subsequent arguments provide additional details.
We will try to be sure that all of our internal exceptions reference a specific chunk, if possible.
This means either including the chunk as an argument, or catching the  exception and appending the current chunk to the exception's arguments.

The Python ``raise`` statement takes an instance of ``Error`` and passes it to the enclosing ``try/except`` statement for processing.

The typical creation is as follows:

..  parsed-literal::

    raise Error(f"no full name for {chunk.name!r}", chunk)

A typical exception-handling suite might look like this:

..  parsed-literal::

    try:
        *...something that may raise an Error or Exception...*
    except Error as e:
        print(e.args) # this is a pyWeb internal Error
    except Exception as w:
        print(w.args) # this is some other Python Exception

The ``Error`` class is a subclass of ``Exception`` used to differentiate 
application-specific exceptions from other Python exceptions.
It does no additional processing, but merely creates a distinct class to facilitate writing ``except`` statements.


@d Error class -- defines the errors raised
@{
class Error(Exception): pass
@| Error @}

Action Class Hierarchy
~~~~~~~~~~~~~~~~~~~~~~

This application performs three major actions: loading the document web, weaving and tangling.
Generally, the use case is to perform a load, weave and tangle.
However, a less common use case is to first load and tangle output files, run a regression test and then load and weave a result that includes the test output file.

The ``-xw`` option excludes the weave pass, doing only the tangle action.
The ``-xt`` option excludes the tangle pass, doing the weave action.

This two pass action might be embedded in the following type of Python program.

..  parsed-literal::

    import pyweb, os, runpy, sys, pathlib, contextlib
    log = pathlib.Path("source.log")
    Tangler().emit(web)
    with log.open("w") as target:
        with contextlib.redirect_stdout(target):
            # run the app, capturing the output
            runpy.run_path('source.py')
            # Alternatives include using pytest or doctest
    Weaver().emit(web, "something.rst")


The first step runs **py-web-lp** , excluding the final weaving pass.
The second step runs the tangled program, ``source.py``, and produces test results in
some log file, ``source.log``.
The third step runs **py-web-lp**  excluding the tangle pass.
This produces a final document that includes the ``source.log``  test results.

To accomplish this, we provide a class hierarchy that defines the various actions of the **py-web-lp**  application.
This class hierarchy defines an extensible set of fundamental actions.
This gives us the flexibility to create a simple sequence of actions and execute any combination of these.
It eliminates the need for a  forest of ``if``-statements to determine precisely what will be done.

Each action has the potential to update the state of the overall application.
A partner with this command hierarchy is the ``Application`` class
that defines the application options, inputs and results. 

@d Action class hierarchy -- used to describe actions of the application 
@{
@<Action base class has common features of all actions@>
@<ActionSequence subclass that holds a sequence of other actions@>
@<WeaveAction subclass initiates the weave action@>
@<TangleAction subclass initiates the tangle action@>
@<LoadAction subclass loads the document web@>
@}


The ``Action`` class embodies the basic operations of **py-web-lp** .
The intent of this hierarchy is to both provide an easily expanded method of
adding new actions, but an easily specified list of actions for a particular
run of **py-web-lp** .

The overall process of the application is defined by an instance of ``Action``.
This instance may be the ``WeaveAction`` instance, the ``TangleAction`` instance
or a ``ActionSequence`` instance.

The instance is constructed during parsing of the input parameters.
Then the  ``Action`` class ``perform()`` method is called to actually perform the action.
There are three standard ``Action`` instances available: an instance
that is a macro and does both tangling and weaving, an instance that excludes tangling, and an instance that excludes weaving.
These correspond to the command-line options.

..  parsed-literal::

    anOp = SomeAction("name")
    anOp(*argparse.Namespace*)


The ``Action`` is the base class for all action class definitions.
An ``Action`` has a number of common attributes.

:name:
    A name for this action.
    
:options:
    The ``argparse.Namespace`` object.
    A LoadAction will update this with the ``Web`` object that was loaded.
    
!start:
    The time at which the action started.



@d Action base class...
@{
class Action:
    """An action performed by pyWeb."""
    start: float
    options: argparse.Namespace

    def __init__(self, name: str) -> None:
        self.name = name
        self.logger = logging.getLogger(self.__class__.__qualname__)

    def __str__(self) -> str:
        return f"{self.name!s} [{self.options.web!s}]"
        
    @<Action call method actually does the real work@>
    
    @<Action final summary of what was done@>
@| Action
@}

The ``__call__()`` method does the real work of the action.
For the base class, it merely logs a message.  This is overridden
by a subclass.

@d Action call... 
@{
def __call__(self, options: argparse.Namespace) -> None:
    self.logger.info("Starting %s", self.name)
    self.options = options
    self.start = time.process_time()
@| perform
@}

The ``summary()`` method returns some basic processing statistics for this action.

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

A ``ActionSequence`` defines a composite action; it is a sequence of other actions.
When the macro is performed, it delegates to the  sub-actions.

The instance is created during parsing of input parameters.
An instance of this class is one of the three standard actions available;
it generally is the default, "do everything"  action.

This class overrides the ``perform()`` method of the superclass.
It also adds an ``append()`` method that is used to construct the sequence of actions.


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
        
    @<ActionSequence summary summarizes each step@>
@| ActionSequence
@}

Since the macro ``__call__()`` method delegates to other Actions,
it is possible to short-cut argument processing by using the Python
``*args`` construct to accept all arguments and pass them to each
sub-action.

@d ActionSequence call... 
@{
def __call__(self, options: argparse.Namespace) -> None:
    super().__call__(options)
    for o in self.opSequence:
        o(self.options)
@| perform
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

The ``WeaveAction`` defines the action of weaving.
This action logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.
If a ``Weaver`` was specified on the command line, this instance is used.
Otherwise, the first few characters are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

If the options include ``theWeaver``, specifying the ``Weaver`` instance to be used.

@d WeaveAction subclass... @{
class WeaveAction(Action):
    """Weave the final document."""
    def __init__(self) -> None:
        super().__init__("Weave")
        
    def __str__(self) -> str:
        return f"{self.name!s} [{self.options.web!s}, {self.options.theWeaver!s}]"

    @<WeaveAction call method to weave@>
    
    @<WeaveAction summary@>
@| WeaveAction
@}

The language for the weaver templates is set just prior to weaving.
Weaving can only raise an exception when there is a reference to a chunk that
is never defined.

@d WeaveAction call... @{
def __call__(self, options: argparse.Namespace) -> None:
    super().__call__(options)
    try:
        self.options.theWeaver.set_markup(self.options.weaver)
        self.options.theWeaver.emit(self.options.web)
        self.logger.info("Finished Normally")
    except Error as e:
        self.logger.error("Problems weaving document from %r (weave file is faulty).", self.options.web.web_path)
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

The ``TangleAction`` defines the action of tangling.
This operation logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.
If a ``Weaver`` was specified on the command line, this instance is used.  Otherwise, the first few characters are examined and a weaver is selected.

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

Tangling can only raise an exception when a cross reference request (``@@f``, ``@@m`` or ``@@u``) occurs in a program code chunk.
Program code chunks are defined  with any of ``@@d`` or ``@@o``  and use ``@@{`` ``@@}`` brackets.


@d TangleAction call... @{
def __call__(self, options: argparse.Namespace) -> None:
    super().__call__(options)
    self.options.theTangler.include_line_numbers = self.options.tangler_line_numbers
    try:
        self.options.theTangler.emit(self.options.web)
    except Error as e:
        self.logger.error("Problems tangling outputs from %r (tangle files are faulty).", self.options.web.web_path)
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

The ``LoadAction`` defines the action of loading the web structure.
This action uses the application's ``webReader`` to actually do the load.

An instance is created during parsing of the input parameters.
An instance of this class is part of any of the weave, tangle and "do everything" action.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``webReader``, with the ``WebReader`` instance to be used.


@d LoadAction subclass... @{
class LoadAction(Action):
    """Load the source web."""
    def __init__(self) -> None:
        super().__init__("Load")
        
    def __str__(self) -> str:
        return f"Load [{self.webReader!s}, {self.options.web!s}]"
        
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
def __call__(self, options: argparse.Namespace) -> None:
    super().__call__(options)
    self.webReader = self.options.webReader
    self.webReader.command = self.options.command
    self.webReader.permitList = self.options.permitList
    self.logger.debug("Reader Class %s", self.webReader.__class__.__name__)

    error = f"Problems with source file {self.options.source_path!r}, no output produced."
    try:
        chunks = self.webReader.load(self.options.source_path)
        if self.webReader.errors != 0:
            raise Error("Syntax Errors in the Web")
        self.logger.debug("Read %d Chunks", len(chunks))
        self.options.web = Web(chunks)
        self.options.web.web_path = self.options.source_path
        self.logger.debug("Web contains %3d chunks", len(self.options.web.chunks))
        self.logger.debug("Web defines  %3d files", len(self.options.web.files))
        self.logger.debug("Web defines  %3d macros", len(self.options.web.macros))
        self.logger.debug("Web defines  %3d names", len(self.options.web.userids))
    except Error as e:
        self.logger.error(error)
        raise  # Could not be parsed or built.
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


The Application Class
~~~~~~~~~~~~~~~~~~~~~

The ``Application`` class is provided so that the ``Action`` instances have an overall application to update.
This allows the ``WeaveAction`` to  provide the selected ``Weaver`` instance to the application.
It also provides a central location for the various options and alternatives that might be accepted from the the configuration file and the command line.

Note the binding of working directories:

-   Weaver writes to ``Path.cwd() / "docs"``. The ``-o`` option resets this.
    ``-o .`` is previous version behavior.

-   Tangler writes to ``Path.cwd()``. Previously, the ``-o`` option controlled this.
    Now, there's a ``-t`` ``--target`` option for a tangling directory, if needed.

The constructor creates a default ``argparse.Namespace`` with values
suitable for weaving and tangling.

The ``parseArgs()`` method uses the ``sys.argv`` sequence to  parse the command line arguments and update the options.
This allows another application to pre-process the arguments, passing other arguments to this module's class definitions.

After this, the ``process()`` method processes the list of files defined by given argument values.
The configuration can be either a ``types.SimpleNamespace`` or an
``argparse.Namespace`` instance.

The ``parseArgs()`` and ``process()`` functions are separated so that
another application can ``import pyweb``, bypass command-line parsing, yet still perform
the basic actions consistently.
For example:

..  parsed-literal::

    import pyweb, argparse, sys, tomllib

    config = tomlib.load((Path.cwd() / "yourapp.toml").read_bytes())

    p = argparse.ArgumentParser()
    *argument definitions*
    p.set_defaults(\*\*config)
    args = p.parse_args(sys.argv[1:])
    
    a = pyweb.Application()
    args = a.expand(args)
    a.process(args)

The built-in behavior is defined by the ``main()`` function.
This creates an ``Application`` instance and calls the ``args = application.parseArgs(sys.argv[1:], **defaults)``, and ``process(args)`` methods.
This provides the expected behavior for this module when it is used as the main program.


@d Imports
@{import argparse
import shlex
@| argparse shlex
@}

@d Application Class for overall CLI operation
@{
class Application:
    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__qualname__)
        @<Application default options@>
        
    @<Application parse command line@>
    
    @<Application class process all files@>
@| Application
@}

The first part of parsing the command line uses application defaults and an application configuration file to set default parameter values.
The default values are set as follows:

:webReader:
    is the ``WebReader`` instance created for the current input file.
 
:doWeave:
    instance of ``Action`` that does weaving only.

:doTangle:
    instance of ``Action`` that does tangling only.
    
:theAction:
    is an instance of ``Action`` that describes
    the default overall action: often load, tangle and weave.  This is the default unless
    overridden by an option.
    
Here are the configuration values.
These are attributes of an ``argparse.Namespace`` default as well as the updated namespace returned by ``parseArgs()``.

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

:skip:
    a list of steps to skip: perhaps ``'w'`` or ``'t'`` to skip weaving or tangling.
    
:weaver:
    the short name of the weaver.
    
:theTangler:
    is set to a ``TanglerMake`` instance 
    to create the output files.

:theWeaver:
    is set to an instance of a subclass of ``Weaver`` based on ``weaver``

@d Application default options...
@{
self.defaults = argparse.Namespace(
    verbosity=logging.INFO,
    command='@@',
    weaver='rst', 
    skip='',  # Don't skip any steps
    permit='',  # Don't tolerate failing commands
    reference='s',  # Simple references
    tangler_line_numbers=False,
    output=Path.cwd() / "docs",  # Weaving output
    target=Path.cwd(),  # Tangling output
    )
@}

The algorithm for parsing the command line parameters uses the built in ``argparse`` module.
We have to build a parser, define the options, and the parse the command-line arguments, updating the default namespace.

The last step is to create argument values where string values are transformed into more useful objects.
Also, in some cases, derived objects are created from the parameterv values.

@d Application parse command line...
@{
def parseArgs(self, argv: list[str], **config: str) -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("-v", "--verbose", dest="verbosity", action="store_const", const=logging.INFO)
    p.add_argument("-s", "--silent", dest="verbosity", action="store_const", const=logging.WARN)
    p.add_argument("-d", "--debug", dest="verbosity", action="store_const", const=logging.DEBUG)
    p.add_argument("-c", "--command", dest="command", action="store")
    p.add_argument("-w", "--weaver", dest="weaver", action="store")
    p.add_argument("-x", "--except", dest="skip", action="store", choices=('w', 't'))
    p.add_argument("-p", "--permit", dest="permit", action="store")
    p.add_argument("-n", "--linenumbers", dest="tangler_line_numbers", action="store_true")
    p.add_argument("-o", "--output", dest="output", action="store", type=Path, help="Weaver output")
    p.add_argument("-t", "--target", dest="target", action="store", type=Path, help="Tangler output")
    p.add_argument("-V", "--Version", action='version', version=f"py-web-lp pyweb.py {__version__}")
    p.add_argument("files", nargs='+', type=Path)

    defaults = vars(self.defaults) | config
    args = argparse.Namespace(**defaults)
    p.parse_args(argv, namespace=args)

    # Expand the permitted errors, usual case is ``-pi`` to permit the ``@@i`` command to fail.
    if args.permit:
        args.permitList = [f'{args.command!s}{c!s}' for c in args.permit]
    else:
        args.permitList = []

    return args

def inject(self, args: argparse.Namespace) -> argparse.Namespace:
    """Inject final classes by creating instances.
    This **updates** the args namespace.
    It puts concrete classes in place.
    """
    # Primitive Actions
    self.loadOp = LoadAction()
    self.weaveOp = WeaveAction()
    self.tangleOp = TangleAction()

    # Composite Actions
    self.doWeave = ActionSequence("load and weave", [self.loadOp, self.weaveOp])
    self.doTangle = ActionSequence("load and tangle", [self.loadOp, self.tangleOp])
    self.theAction = ActionSequence("load, tangle and weave", [self.loadOp, self.tangleOp, self.weaveOp])

    # Create Weaver & Tangler used by the Actions.
    # Update Weaver macros from config file.
    args.theWeaver = Weaver(args.output)
    if "macros" in args:
        args.theWeaver.config_macros = args.macros
    args.theTangler = TanglerMake(args.target)

    # Create the configured WebReader used by the Actions.
    args.webReader = WebReader()

    self.logger.debug("config: %r", args)
    return args
@| parseArgs
@}

The ``process()`` function uses the final ``argparse.Namespace`` to process each file as follows:

1.  Create a new ``WebReader`` for the ``Application``, providing
    the parameters required to process the input file.

2.  Create a ``Web`` instance, *w*,
    and set the Web's *sourceFileName* from the WebReader's *filePath*.

3.  Perform the given command, typically a ``ActionSequence``, 
    which does some combination of load, tangle the output files and
    weave the final document in the target markup language.

4.  Print a performance summary line that shows lines processed per second.

In the event of failure in any of the major processing steps, a summary message is produced to clarify the state of the output files, and the exception is reraised.
The re-raising is done so that all exceptions are handled by the outermost main program.

@d Application class process all...
@{
def process(self, config: argparse.Namespace) -> None:
    root = logging.getLogger()
    root.setLevel(config.verbosity)
    self.logger.debug("Setting root log level to %r", logging.getLevelName(root.getEffectiveLevel()))

    self.inject(config)

    if config.command:
        self.logger.debug("Command character %r", config.command)
        
    if config.skip:
        if config.skip.lower().startswith('w'):  # not weaving == tangling
            self.theAction = self.doTangle
        elif config.skip.lower().startswith('t'):  # not tangling == weaving
            self.theAction = self.doWeave
        else:
            raise Exception(f"Unknown -x option {config.skip!r}")

    for f in config.files:
        self.logger.info("%s %s %r", self.theAction.name, __version__, f)
        config.source_path = f
        self.theAction(config)
        self.logger.info(self.theAction.summary())
@| process
@}

Logging Setup
~~~~~~~~~~~~~~~~~~~~~

We'll create a logging context manager.
This allows us to wrap the ``main()`` function in an explicit ``with`` statement that assures that logging is configured and cleaned up politely.

@d Imports...
@{import logging
import logging.config
@| logging logging.config
@}

This has two configuration approaches.
If a positional argument is given, that dictionary is used for ``logging.config.dictConfig``.
Otherwise, keyword arguments are provided to ``logging.basicConfig``.

A subclass might properly load a dictionary encoded in TOML or YAML and use that with ``logging.config.dictConfig``.

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

Here's a sample logging setup.
This creates a simple console handler and a formatter that matches the ``basicConfig`` formatter.

This configuration dictionary defines the root logger plus some overrides for class loggers that might be used to gather additional information.

@d Logging Setup
@{
default_logging_config = {
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
    
    # For specific debugging support...
    'loggers': {
        'Weaver': {'level': logging.INFO},
        'WebReader': {'level': logging.INFO},
        'Tangler': {'level': logging.INFO},
        'TanglerMake': {'level': logging.INFO},
        'indent.TanglerMake': {'level': logging.INFO},
        'Web': {'level': logging.INFO},
        # Unit test requires this...
        'ReferenceCommand': {'level': logging.INFO},
    },
}
@}

The above is wired into the application as a default. 
Exposing this via a configuration file is better.

@o pyweb.toml
@{
[pyweb]
# PyWeb options go here.
# Override macro definitions.
# macros = [
# """{% macro begin_code(chunk) %}...{% endmacro %}""",
# """{% macro end_code(chunk) %}...{% endmacro %}"""
# ]

[logging]
version = 1
disable_existing_loggers = false

[logging.root]
handlers = ["console",]
level = "DEBUG"

[logging.handlers.console]
class = "logging.StreamHandler"
stream = "ext://sys.stderr"
formatter = "basic"

[logging.formatters.basic]
format = "{levelname}:{name}:{message}"
style = "{"

[logging.loggers.Application]
level = "INFO"

[logging.loggers.Weaver]
level = "INFO"

[logging.loggers.WebReader]
level = "INFO"

[logging.loggers.Tangler]
level = "INFO"

[logging.loggers.TanglerMake]
level = "INFO"

[logging.loggers.indent.TanglerMake]
level = "INFO"

[logging.loggers.ReferenceCommand]
# Unit test requires this...
level = "INFO"

@}

We can load this with something like the following:

..  parsed-literal::

    config_path = Path("pyweb.toml")
    with config_path.open('rb') as config_file:
        config = toml.load(config_file)
    log_config = config.get('logging', {'version': 1, level=logging.INFO})

This makes it slightly easier to add and change debuging alternatives.
Rather then use the ``-v`` and ``-d`` options, the ``pyweb.toml`` 
provides a complete logging config. 

Also, we might want a decorator to define loggers more consistently for each class definition.

The Main Function
~~~~~~~~~~~~~~~~~~~~~

The top-level interface is the ``main()`` function.
This function creates an ``Application`` instance.

The ``Application`` object parses the command-line arguments.
Then the ``Application`` object does the requested processing.
This two-step process allows for some dependency injection to customize argument processing.

We might also want to parse a logging configuration file, as well
as a weaver template configuration file.

@d Interface Functions
@{
def main(argv: list[str] = sys.argv[1:], base_config: dict[str, Any] | None=None) -> None:
    a = Application()
    config = a.parseArgs(argv, **(base_config or {}))
    a.process(config)
@}

**pyWeb** Module File
------------------------

The **pyWeb** application file is shown below:

@o pyweb.py 
@{@<Overheads@>
@<Imports@>
@<Error class...@>
@<Base Class Definitions@>
@<Action class hierarchy...@>
@<Application Class...@>
@<Logging Setup@>
@<Interface Functions@>

if __name__ == "__main__":
    config_dirs = Path.cwd(), Path.home(), Path(__file__).parent
    base_config: dict[str, Any] = {}
    for dir in config_dirs:
        cp = dir / "pyweb.toml"
        if cp.exists():
            with cp.open('rb') as config_file:
                base_config = toml.load(config_file)
            break
    log_config = base_config.get('logging', default_logging_config)
    with Logger(log_config):
        main(base_config=base_config.get('pyweb', {}))
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
@{import os
import time
import datetime
import sys
import tomllib as toml
import types

@|  os time datetime sys tomllib types
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
@{"""py-web-lp Literate Programming.

Yet another simple literate programming tool derived from **nuweb**, 
implemented entirely in Python.
With a suitable configuration, this weaves documents with any markup language,
and tangles source files for any programming language.
"""
@}

The keyword cruft is a standard way of placing version control information into
a Python module so it is preserved.  See PEP (Python Enhancement Proposal) #8 for information
on recommended styles.


We also sneak in a "DO NOT EDIT" warning that belongs in all generated application 
source files.

@d Overheads
@{__version__ = """3.3"""

### DO NOT EDIT THIS FILE!
### It was created by @(thisApplication@), __version__='@(__version__@)'.
### From source @(theFile@) modified @(datetime.datetime.fromtimestamp(os.path.getmtime(theFile)).ctime()@).
### In working directory '@(os.path.realpath('.')@)'.
@| __version__ @}

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


This will create a variant on **py-web-lp** that will handle a different
weaver via the command-line option ``-w myweaver``.
