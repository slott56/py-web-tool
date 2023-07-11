"""
Spike of using jinja2==3.1.2 to weave with Jinja-defined templates.

This replaces all ``Template`` instances with configurable Jinja2 macros.

This defines weaving as the following macros

:begin_code(chunk):
    Emit preface for a chunk of code ``@@d`` or a file ``@@f``.

:code(command):
    Emit this command's lines, applying ``quote_rules`` function.
    For some markup, each line must be processed individually.
    
:ref(id):
    Emit a reference to another chunk.
    
:file_xref(command):
    Handle the ``@@f`` output, a list of ``@@o`` chunks.

:macro_xref(command):
    Handle the ``@@m`` output, a list of ``@@d`` chunks.
    The special ``def_list`` attribute is the complete list of chunks with the same name.

:userid_xref(command):
    Handle the ``@@u`` output, a list of ``@@|`` names and the chunks they're referenced.
    Each entry has two attributes.
    
    :userid:
        The id
        
    :ref_list:
        The referencing chunks
"""
from collections.abc import Iterator
from collections import defaultdict
from textwrap import dedent
from dataclasses import dataclass, field
from pathlib import Path
from types import SimpleNamespace
from typing import Any
from weakref import ref, ReferenceType

from jinja2 import Environment, DictLoader, select_autoescape


def rst_quote_rules(text):
    return text


rst_weaver_template = dedent("""\
    {%- macro text(command) -%}
    {{command.text}}
    {%- endmacro -%}
    
    {%- macro begin_code(chunk) %}
    ..  _`{{chunk.full_name}} ({{chunk.seq}})`:
    ..  rubric:: {{chunk.name}} ({{chunk.seq}}) =
    ..  parsed-literal::
        :class: code
    {% endmacro -%}
    
    {% macro code(command) %}
        {% for line in command.lines -%}
        {{line | quote_rules}}
        {% endfor -%}
    {% endmacro -%}
    
    {% macro ref(id) -%}
    \N{RIGHTWARDS ARROW}\ `{{id.name}} ({{id.seq}})`_
    {%- endmacro -%}
    
    {%- macro end_code(chunk) %}
    ..
    
    ..  class:: small
    
        \N{END OF PROOF} *{{chunk.name}} ({{chunk.seq}})*
        
    {% endmacro -%}
    
    {% macro file_xref(command) -%}
    {% for file in command.files -%}
    :{{file.name}}:
        {{ref(file)}}
    {%- endfor %}
    {%- endmacro -%}
    
    {% macro macro_xref(command) -%}
    {% for macro in command.macros -%}
    :{{macro.full_name}}:
        {% for d in macro.def_list -%}{{ref(d)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
        
    {% endfor %}
    {%- endmacro -%}

    {% macro userid_xref(command) -%}
    {% for userid in command.userids -%}
    :{{userid.userid}}:
        {% for r in userid.ref_list -%}{{ref(r)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
        
    {% endfor %}
    {%- endmacro -%}
    """)

rst_overrides_template = dedent("""\
    {# Write override macros here #}
    """)

base_weaver_template_1 = dedent("""\
    {%- from macros import text, begin_code, code, end_code, file_xref, macro_xref, userid_xref, ref, ref_list -%}
    {% for chunk in web.chunks -%}
        {%- if chunk.typeid.OutputChunk or chunk.typeid.NamedChunk -%}{{begin_code(chunk)}}{%- endif -%}
        {% for command in chunk.commands -%}
            {%- if command.typeid.TextCommand %}{{text(command)}}
            {%- elif command.typeid.CodeCommand %}{{code(command)}}
            {%- elif command.typeid.ReferenceCommand %}{{ref(command)}}
            {%- elif command.typeid.FileXrefCommand %}{{file_xref(command)}}
            {%- elif command.typeid.MacroXrefCommand %}{{macro_xref(command)}}
            {%- elif command.typeid.UserIdXrefCommand %}{{userid_xref(command)}}
            {% endif -%}
        {%- endfor %}
        {%- if chunk.typeid.OutputChunk or chunk.typeid.NamedChunk -%}{{end_code(chunk)}}{%- endif -%}
    {%- endfor %}
    """)

base_weaver_template_2 = dedent("""\
    {%- from macros import text, begin_code, code, end_code, file_xref, macro_xref, userid_xref, ref, ref_list -%}
    {%- if not text is defined %}{%- from defaults import text -%}{%- endif -%}
    {%- if not begin_code is defined %}{%- from defaults import begin_code -%}{%- endif -%}
    {%- if not code is defined %}{%- from defaults import code -%}{%- endif -%}
    {%- if not end_code is defined %}{%- from defaults import end_code -%}{%- endif -%}
    {%- if not file_xref is defined %}{%- from defaults import file_xref -%}{%- endif -%}
    {%- if not macro_xref is defined %}{%- from defaults import macro_xref -%}{%- endif -%}
    {%- if not userid_xref is defined %}{%- from defaults import userid_xref -%}{%- endif -%}
    {%- if not ref is defined %}{%- from defaults import ref -%}{%- endif -%}
    {%- if not ref_list is defined %}{%- from defaults import ref_list -%}{%- endif -%}
    {% for chunk in web.chunks -%}
        {%- if chunk.typeid.OutputChunk or chunk.typeid.NamedChunk -%}
            {{begin_code(chunk)}}
            {% for command in chunk.commands -%}
                {%- if command.typeid.CodeCommand %}{{code(command)}}
                {%- elif command.typeid.ReferenceCommand %}{{ref(command)}}
                {%- endif -%}
            {% endfor %}
            {{end_code(chunk)}}
        {%- elif chunk.typeid.Chunk -%}
            {% for command in chunk.commands -%}
                {%- if command.typeid.TextCommand %}{{text(command)}}
                {%- elif command.typeid.ReferenceCommand %}{{text(command)}}
                {%- elif command.typeid.FileXrefCommand %}{{file_xref(command)}}
                {%- elif command.typeid.MacroXrefCommand %}{{macro_xref(command)}}
                {%- elif command.typeid.UserIdXrefCommand %}{{userid_xref(command)}}
                {% endif -%}
            {%- endfor %}
        {%- endif -%}
    {%- endfor %}
    """)


@dataclass
class Web:
    chunks: list["Chunk"]

    # The ``@@d`` chunk names and locations where they're defined.
    chunk_map: defaultdict[str, list["Chunk"]] = field(init=False, default_factory=lambda: defaultdict(list))
    
    # The ``@@|`` defined names and chunks with which they're associated.
    userid_map: defaultdict[str, list["Chunk"]] = field(init=False, default_factory=lambda: defaultdict(list))

    def __post_init__(self) -> None:
        """
        Populate weak references throughout the web to make full_name properties work.
        Then. Locate all macro definitions and userid references. 
        """
        for c in self.chunks:
            c.web = ref(self)
            for cmd in c.commands:
                cmd.web = ref(self)
        named_chunks = filter(lambda c: c.name is not None, self.chunks)
        for seq, c in enumerate(named_chunks, start=1):
            c.seq = seq
            for name in c.def_names:
                self.userid_map[name].append(c)
            if not hasattr(c, 'path'):
                # ``@@d`` chunks, excluding ``@@o`` and text
                self.chunk_map[c.full_name].append(c) 

    def resolve_name(self, target: str) -> str:
        """Map short names to full names, if possible."""
        if target.endswith('...'):
            matches = list(
                c.name
                for c in self.macro_iter()
                if c.name.startswith(target)
            )
            match matches:
                case []:
                    return target
                case [head]:
                    return head
                case [head, *tail]:
                    raise ValueError(f"Multiple matching names: {[head] + tail}")
        else:
            return target

    def resolve_chunk(self, target: str) -> list["Chunk"]:
        """Map name (short or full) to the defining sequence of chunks."""
        name = self.resolve_name(target)
        return self.chunk_map[name]

    def file_iter(self) -> Iterator[SimpleNamespace]:
        return filter(lambda c: c.typeid.OutputChunk, self.chunks)

    def macro_iter(self) -> Iterator[SimpleNamespace]:
        return filter(lambda c: c.typeid.NamedChunk, self.chunks)

    def userid_iter(self) -> Iterator[SimpleNamespace]:
        yield from (SimpleNamespace(def_name=n, chunk=c) for c in self.file_iter() for n in c.def_names)
        yield from (SimpleNamespace(def_name=n, chunk=c) for c in self.macro_iter() for n in c.def_names)

    @property
    def files(self) -> list["OutputChunk"]:
        return list(self.file_iter())

    @property
    def macros(self) -> list[SimpleNamespace]:
        """
        The chunk_map has the list of Chunks that comprise a macro definition.
        We separate those to make it slightly easier to format the first definition.
        """
        first_list = (
            (self.chunk_map[name][0], self.chunk_map[name])
            for name in sorted(self.chunk_map)
        )
        macro_list = list(
            SimpleNamespace(name=first_def.name, full_name=first_def.full_name, seq=first_def.seq, def_list=def_list)
            for first_def, def_list in first_list
        )
        # print(f"macros: {defs}")
        return macro_list

    @property
    def userids(self) -> list[SimpleNamespace]:
        userid_list = list(
            SimpleNamespace(userid=userid, ref_list=self.userid_map[userid])
            for userid in sorted(self.userid_map)
        )
        # print(f"userids: {userid_list}")
        return userid_list
    
class TypeId:
    """
    This makes the class name into an attribute with a 
    True value. Any other attribute is False.
    """
    def __init__(self, member_of: type[Any]) -> None:
        self.my_class = member_of.__name__

    def __getattr__(self, item: str) -> bool:
        return item == self.my_class


@dataclass
class Chunk:
    """Superclass for OutputChunk, NamedChunk, NamedDocumentChunk.

    Chunk is the anonymous text context. 
        The Text, Ref, and the various XREF commands can *only* appear here.
        A REF must be do a ``@@d name @[...@]`` NamedDocumentChunk, which is expanded, not linked.

    OutputChunk is the ``@@o`` context. 
        The Code and Ref commands appear here.
        This is tangled to a file.

    NamedChunk is the ``@@d`` context. 
        The Code and Ref commands appear here.
        This is tangled where referenced.
    """
    name: str | None = None  #: Short name of the chunk
    seq: int | None = None  #: Unique sequence number of chunk in the WEB
    initial : bool = False  #: First or Subsequent definition of this name
    options: list[str] | None = None  #: Parsed options for @d and @o chunks.
    commands: list["Command"] | None = None  #: Sequence of commands inside this chunk
    def_names: list[str] = field(default_factory=list)  #: Names defined after ``@@|`` in this chunk
    web: ReferenceType[Web] = field(init=False)

    @property
    def full_name(self) -> str | None:
        return self.web().resolve_name(self.name)

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


class OutputChunk(Chunk):
    @property
    def path(self) -> Path:
        return Path(self.name)

    @property
    def full_name(self) -> str | None:
        return None

class NamedChunk(Chunk): 
    pass


class NamedDocumentChunk(Chunk): 
    pass


@dataclass
class TextCommand:
    text: str  #: The text
    web: ReferenceType[Web] = field(init=False)

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


@dataclass
class CodeCommand:
    lines: list[str]  #: The code
    web: ReferenceType[Web] = field(init=False)

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


@dataclass
class ReferenceCommand:
    """
    Reference to a ``NamedChunk`` in code.
    On text, however, it expands to the text of a ``NamedDocumentChunk``.
    """
    name: str  #: The name provided
    web: ReferenceType[Web] = field(init=False)

    # These *could* be properties.
    # full_name: str  #: The name as resolved in the Web
    seq: int  #: The unique sequence number found for the name

    @property
    def text(self) -> str:
        return self.web().get_text(self.full_name)
    
    @property
    def full_name(self) -> str:
        return self.web().resolve_name(self.name)

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


@dataclass
class FileXrefCommand:
    web: ReferenceType[Web] = field(init=False)

    @property
    def files(self):
        return self.web().files

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


@dataclass
class MacroXrefCommand:
    web: ReferenceType[Web] = field(init=False)

    @property
    def macros(self):
        return self.web().macros

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)


@dataclass
class UserIdXrefCommand:
    web: ReferenceType[Web] = field(init=False)

    @property
    def userids(self):
        return self.web().userids

    @classmethod
    @property
    def typeid(cls) -> TypeId:
        return TypeId(cls)



# Fixture 1: 

source_1 = dedent("""
    Title
    =====
    
    @o hw.py @{
    print("Hello, World!")
    @| print
    @}
    
    Conclusion...
    
    More thoughts.
    
    Appendices
    ==========
    
    Files
    -----
    
    @f
    
    Macros
    ------
    
    @m
    
    Names
    -----
    
    @u
""")

web_1 = Web(
    chunks=[
        Chunk(commands=[TextCommand(text="Web 1\n======\n\n\n")]),
        OutputChunk(name="hw.py", commands=[CodeCommand(lines='\nprint("Hello, World!")\n'.splitlines())], def_names=['print']),
        Chunk(commands=[TextCommand(text="Conclusion...\n\nMore thoughts.\n\n")]),
        Chunk(commands=[TextCommand(text="Appendices\n==========\n\n")]),
        Chunk(commands=[TextCommand(text="Files\n-----\n\n")]),
        Chunk(commands=[FileXrefCommand()]),
        Chunk(commands=[TextCommand(text="\n\nMacros\n------\n\n")]),
        Chunk(commands=[MacroXrefCommand()]),
        Chunk(commands=[TextCommand(text="\n\nNames\n------\n\n")]),
        Chunk(commands=[UserIdXrefCommand()]),
    ],
)

# Fixture 2:

source_2 = dedent("""
Fast Exponentiation
===================

A classic divide-and-conquer algorithm.

@d fast exp @{
def fast_exp(n: int, p: int) -> int:
    match p:
        case 0: 
            return 1
        case _ if p % 2 == 0:
            t = fast_exp(n, p // 2)
            return t * t
        case _ if p % 1 == 0:
            return n * fast_exp(n, p - 1)
@| fast_exp
@}

With a test case.

@d test case @{
>>> fast_exp(2, 30)
1073741824
@}

@o example.py @{
@< fast exp @>

__test__ = {
    "test 1": '''
@< test case @>
    '''
}
@| __test__
@}

Use ``python -m doctest`` to test.

Macros
------

@m

Names
-----

@u
""")


web_2 = Web(
    chunks=[
        Chunk(commands=[TextCommand(text=dedent("""\
            Fast Exponentiation
            ===================
            
            A classic divide-and-conquer algorithm.
            
            """))]),
        NamedChunk(name="fast exp", def_names=["fast_exp"], commands=[CodeCommand(lines=dedent("""
            def fast_exp(n: int, p: int) -> int:
                match p:
                    case 0: 
                        return 1
                    case _ if p % 2 == 0:
                        t = fast_exp(n, p // 2)
                        return t * t
                    case _ if p % 1 == 0:
                        return n * fast_exp(n, p - 1)
            """).splitlines())]),
        Chunk(commands=[TextCommand(text=dedent("""
            
            With a test case.
            
            """))]),
        NamedChunk(name="test case", commands=[CodeCommand(lines=dedent("""
            >>> fast_exp(2, 30)
            1073741824
            """).splitlines())]),
        Chunk(commands=[TextCommand(text=dedent("""
            
            """))]),
        OutputChunk(name="example.py", def_names=["__test__"], commands=[
            CodeCommand(lines=dedent("""
            """).splitlines()),
            ReferenceCommand(name="fast exp", seq=1),
            CodeCommand(lines=dedent("""
            __test__ = {
                "test 1": '''
            """).splitlines()),
            ReferenceCommand(name="test case", seq=2),
            CodeCommand(lines=dedent("""
                '''
            }
            """).splitlines())
            ]
        ),
        Chunk(commands=[TextCommand(text=dedent("""
            
            Use ``python -m doctest`` to test.
            
            Macros
            ------
            
            """))]),
        Chunk(commands=[MacroXrefCommand()]),
        Chunk(commands=[TextCommand(text=dedent("""

        Names
        ------

        """))]),
        Chunk(commands=[UserIdXrefCommand()]),
    ],
)


def weave(web):
    """
    Given a template and a quoting rule function, weave a document.
    
    The base weaver template doesn't change.
    
    The template imports two definitions:
    
    """
    env = Environment(
        loader=DictLoader(
            {
                'rst_defaults': rst_weaver_template,
                'rst_macros': rst_overrides_template,
                'base_weaver': base_weaver_template_2,
            }
        ),
        autoescape=select_autoescape()
    )
    env.filters |= {"quote_rules": rst_quote_rules}

    defaults = env.get_template("rst_defaults")
    macros = env.get_template("rst_macros")
    template = env.get_template("base_weaver")
    return template.render(web=web, macros=macros, defaults=defaults)


def test_template_whitespace():
    document = weave(SimpleNamespace(chunks=[]))
    assert document == "", f"Not '': {document!r}"


def demo_1():
    print(weave(web=web_1))


def demo_2():
    print(weave(web=web_2))


if __name__ == "__main__":
    test_template_whitespace()
    # demo_1()
    demo_2()
