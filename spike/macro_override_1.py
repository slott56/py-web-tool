"""
Macro override using lists of simple text definitions.
Each macro is a block of text.
These are compiled to locate the name.

1.  Build a mapping from macro name to macro body.
    These mappings can be built for defaults, application overrides, config file overrides, AND WEB file @t overrides.

2.  Build a ``ChainMap`` using various sources in priority order:
    [@t, config, app overrides, app defaults].

3.  Reduce the chain map to a template using the high-priority version.
    This creates a single, definitive set of macros to use.
"""
from collections.abc import Iterable, Iterator
from collections import ChainMap
from dataclasses import dataclass
from textwrap import dedent
import types
from pprint import pprint


import jinja2
from jinja2 import Environment, DictLoader, select_autoescape
import jinja2.nodes

rst_default_weaver_macros = [
    dedent("""\
    {%- macro text(command) -%}
    {{command.text}}
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro begin_code(chunk) %}
    ..  _`{{chunk.full_name}} ({{chunk.seq}})`:
    ..  rubric:: {{chunk.name}} ({{chunk.seq}}) =
    ..  parsed-literal::
        :class: code
    {% endmacro -%}
    """),
    dedent("""\
    {% macro code(command) %}
        {% for line in command.lines -%}
        {{line | quote_rules}}
        {% endfor -%}
    {% endmacro -%}
    """),
    dedent("""\
    {% macro ref(id) -%}
    \N{RIGHTWARDS ARROW}\\ `{{id.name}} ({{id.seq}})`_
    {%- endmacro -%}
    """),
    dedent("""\
    {%- macro end_code(chunk) %}
    ..

    ..  class:: small

        \N{END OF PROOF} *{{chunk.name}} ({{chunk.seq}})*

    {% endmacro -%}
    """),
    dedent("""\
    {% macro file_xref(command) -%}
    {% for file in command.files -%}
    :{{file.name}}:
        {{ref(file)}}
    {%- endfor %}
    {%- endmacro -%}
    """),
    dedent("""\
    {% macro macro_xref(command) -%}
    {% for macro in command.macros -%}
    :{{macro.full_name}}:
        {% for d in macro.def_list -%}{{ref(d)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}

    {% endfor %}
    {%- endmacro -%}
    """),
    dedent("""\
    {% macro userid_xref(command) -%}
    {% for userid in command.userids -%}
    :{{userid.userid}}:
        {% for r in userid.ref_list -%}{{ref(r)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}

    {% endfor %}
    {%- endmacro -%}
    """)
    ]

rst_override_weaver_macros = [
]

def macro_iter(e: Environment, source: list[str]) -> Iterator[tuple[str, str]]:
    for m in source:
        ast = e.parse(m)
        for child in ast.iter_child_nodes():
            match child:
                case jinja2.nodes.Macro() as macro:
                    yield macro.name, m
                case _:
                    print("***NOT A MACRO", child, type(child))

base_template = dedent("""\
    {%- from macros import text, begin_code, code, end_code, file_xref, macro_xref, userid_xref, ref, ref_list -%}
    {{begin_code(chunk)}}
    {% for command in chunk.commands -%}
        {%- if command.typeid.CodeCommand %}{{code(command)}}
        {%- elif command.typeid.ReferenceCommand %}{{ref(command)}}
        {%- endif -%}
    {% endfor %}
    {{end_code(chunk)}}
    """)

@dataclass
class Chunk:
    name: str
    seq: int
    commands: list["Command"]

@dataclass
class Command:
    typeid: types.SimpleNamespace
    lines: list[str]

web_chunk = Chunk(
    name="code",
    seq=1,
    commands=[
        Command(
            typeid=types.SimpleNamespace(CodeCommand=True, ReferenceCommand=False),
            lines=["print('Hello, world!')"]
        )
    ]
)

def rst_quote_rules(text):
    return text

def main():
    e = Environment()
    app_default_macros = dict(macro_iter(e, rst_default_weaver_macros))
    app_override_macros = dict(macro_iter(e, rst_override_weaver_macros))
    config_macros = {}
    web_file_macros = {}
    # In priority order.
    all_macros = ChainMap(web_file_macros, config_macros, app_override_macros, app_default_macros)
    resolved_macros = [all_macros[k] for k in all_macros.keys()]
    macro_template = "\n\n".join(resolved_macros)
    # print(macro_template)
    e.loader=DictLoader(
            {
                'macros': macro_template,
                'base_weaver': base_template,
            }
        )
    e.autoescape=select_autoescape()
    e.filters |= {"quote_rules": rst_quote_rules}

    weaver = e.get_template("base_weaver")
    macros = e.get_template("macros")
    print(weaver.render(chunk=web_chunk, macros=macros))

if __name__ == "__main__":
    main()
