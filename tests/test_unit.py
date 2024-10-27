"""Unit tests."""
import argparse
from dataclasses import asdict
import io
import logging
import os
from pathlib import Path
import re
import shlex
import string
import sys
import textwrap
import time
from types import SimpleNamespace
from typing import Any, TextIO
from unittest.mock import Mock, call, MagicMock, sentinel
import warnings

import pytest

import pyweb

def rstrip_lines(source: str) -> list[str]:
    return list(l.rstrip() for l in source.splitlines())    




def mock_chunk_instance(name: str, seq: int, location: tuple[str, int], commands=None) -> Mock:
    chunk = Mock(
        wraps=pyweb.Chunk,
        seq=seq,
        commands=commands or [],
        def_names=[],
        references=0,
        referencedBy=None,
        # Properties
        full_name=name,
        path=None,
        location=location,
        # Methods
        type_is=Mock(side_effect=lambda x: x == "Chunk"),
        tangle=Mock(),
    )
    # Peculiarity of mocks, ``name`` as mocked property must be set separately.
    chunk.name = name
    return chunk

# Remove this...
MockChunk = Mock(
    name="Chunk class",
    side_effect=mock_chunk_instance
)

# TODO: Make this a fixture used by the mock web fixture.
def mock_chunks() -> list[pyweb.Chunk]:
    def tangle_method(aTangler: pyweb.Tangler, target: TextIO) -> None:
        aTangler.codeBlock(target, "Mocked Tangle Output\n")

    # Pre-built references for a mock web.
    mock_file = Mock(full_name="sample.out", seq=1)
    mock_file.name = "sample.out"

    mock_output = Mock(full_name="named chunk", seq=2, def_list=[3])
    mock_output.name = "named chunk"

    mock_uid_1 = Mock(userid="user_id_1", ref_list=[mock_output])
    mock_uid_2 = Mock(userid="user_id_2", ref_list=[mock_output])

    c_0 = mock_chunk_instance("c1", 1, (mock_file.name, 11))
    c_0.type_is=Mock(side_effect = lambda n: n == "Chunk")
    c_0.referenced_by = None
    c_0.commands=[
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.TextCommand, "typeid"),
            text="text with |char| untouched.",
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.TextCommand, "typeid"),
            text="\n",
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.FileXrefCommand, "typeid"),
            location=1,
            files=[mock_file],
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.TextCommand, "typeid"),
            text="\n",
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.MacroXrefCommand, "typeid"),
            location=2,
            macros=[mock_output],
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.TextCommand, "typeid"),
            text="\n",
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.UserIdXrefCommand, "typeid"),
            location=3,
            userids=[mock_uid_1, mock_uid_2]
        ),
    ]

    c_1 = mock_chunk_instance("c3...", 42, (mock_file.name, 22))
    c_1.type_is=Mock(side_effect = lambda n: n == "OutputChunk")
    c_1.full_name=mock_file.name
    c_1.referencedBy = None
    c_1.commands=[
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
            text="|char| `code` *em* _em_",
            tangle=Mock(side_effect=tangle_method),
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
            text="\n",
            tangle=Mock(),
        ),
        Mock(
            typeid=pyweb.TypeId(), full_name="named chunk", seq=42
        ),
    ]
    # Tweak mocked command's name
    c_1.commands[0].name = "c3..."
    # Tweak mocked reference command's name
    c_1.commands[2].typeid.__set_name__(pyweb.ReferenceCommand, "typeid")
    c_1.commands[2].name = "named..."

    c_2 = mock_chunk_instance("c3 has a long name", 3, (mock_file.name, 33))
    c_2.type_is=Mock(side_effect = lambda n: n == "NamedChunk")
    c_2.def_names = ["userid"]
    c_2.referencedBy = c_1
    c_2.commands=[
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
            text="|char| `code` *em* _em_",
        ),
        Mock(
            typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
            text="\n",
            tangle=Mock(),
        ),
    ]

    return [c_0, c_1, c_2]

# TODO: Make this a fixture.
def mock_web() -> pyweb.Web:
    """Complex WEB for weaver testing."""
    chunk_list = mock_chunks()
    web = Mock(
        name="mock web",
        web_path=Path("TestWeaver.w"),
        chunks=chunk_list,
    )
    web.chunks[1].name="sample.out"
    web.chunks[2].name="named..."
    web.files = [web.chunks[1]]
    return web

 
@pytest.fixture
def emitter_subclass():
    mock_emit_method = Mock()

    class EmitterExtension(pyweb.Emitter):
        def emit(self, web: pyweb.Web) -> None:
            mock_emit_method(web)
    return EmitterExtension, mock_emit_method

def test_emitter_should_open_close_write(tmp_path, emitter_subclass):
    emitter_subclass, mock_emit_method = emitter_subclass

    output = tmp_path / "TestEmitter.out"
    emitter = emitter_subclass(output)
    web = Mock(name="mock web")
    emitter.emit(web)

    mock_emit_method.assert_called_once_with(web)
    assert emitter.output == output


def test_rst_quote_rules():
    assert pyweb.rst_quote_rules("|char| `code` *em* _em_") == "|char| `code` *em* _em_"

def test_html_quote_rules():
    assert pyweb.html_quote_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"


expected_rst_output = ('text with |char| untouched.\n'
     ':sample.out:\n'
     '    → `sample.out (1)`_\n'
     ':named chunk:\n'
     '    → ` ()`_\n'
     '\n'
     '\n'
     ':user_id_1:\n'
     '    → `named chunk (2)`_\n'
     '\n'
     ':user_id_2:\n'
     '    → `named chunk (2)`_\n'
     '\n'
     '\n'
    '..  _`sample.out (42)`:\n'
    '..  rubric:: sample.out (42) =\n'
    '..  code-block::\n'
    '    :class: code\n'
    '\n'
    '    |char| `code` *em* _em_\n'
    '    \n'
    '    → `named chunk (42)`_\n'
    '..\n'
    '\n'
    '..  container:: small\n'
    '\n'
    '    ∎ *sample.out (42)*.\n'
    '    \n'
    '\n'
    '\n'
    '..  _`c3 has a long name (3)`:\n'
    '..  rubric:: c3 has a long name (3) =\n'
    '..  code-block::\n'
    '    :class: code\n'
    '\n'
    '    |char| `code` *em* _em_\n'
    '    \n'
    '\n'
    '..\n'
    '\n'
    '..  container:: small\n'
    '\n'
    '    ∎ *c3 has a long name (3)*.\n'
    '    Used by     → `sample.out (42)`_.\n'
    '\n')


@pytest.fixture
def web_rst_weaver(tmp_path):
    weaver = pyweb.Weaver(tmp_path)
    weaver.set_markup("rst")
    web = mock_web()
    return web, weaver

def test_weaver_functions_generic(tmp_path, web_rst_weaver):
    web, weaver = web_rst_weaver
    weaver.emit(web)
    output_path = tmp_path / "TestWeaver.rst"
    actual = output_path.read_text()
    assert expected_rst_output == actual




expected_tex_output = [
    '\n'
    '\\label{pyweb-314}\n'
    '\\begin{flushleft}\n'
    '\\textit{Code example Chunk (314)}\n'
    '\\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]',
    '\n'
    '\\end{Verbatim}\n'
    '\\end{flushleft}\n'
]


expected_tex_minted_output = [
    '\n'
    '\\label{pyweb-314}\n'
    '\\textit{Code example Chunk (314)}\n'
    '\\begin{minted}{python}',
    '\n'
    '\\end{minted}\n'
]


@pytest.fixture
def mock_tiny_web():
    aFileChunk = mock_chunk_instance("File", 123, ("sample.w", 456))
    aFileChunk.referencedBy = [ ]

    aChunk = mock_chunk_instance("Chunk", 314, ("sample.w", 789))
    aChunk.style = "python"
    aChunk.type_is = Mock(side_effect=lambda n: n == "OutputChunk")
    aChunk.referencedBy = [aFileChunk,]
    aChunk.references = [(aFileChunk.name, aFileChunk.seq)]

    web = Mock(chunks=[aChunk])
    return web

@pytest.fixture
def weaver_instance(tmp_path):
    weaver = pyweb.Weaver(tmp_path)
    return weaver

def test_weaver_functions_latex(weaver_instance, mock_tiny_web):
    weaver_instance.set_markup("tex")

    quote_result = pyweb.latex_quote_rules("\\end{Verbatim}")
    assert "\\end\\,{Verbatim}" == quote_result

    weave_result = list(weaver_instance.generate_text(mock_tiny_web))
    assert expected_tex_output == weave_result

def test_weaver_functions_latex_minted(weaver_instance, mock_tiny_web):
    weaver_instance.set_markup("tex-minted")
    quote_result = pyweb.latex_minted_quote_rules("\\end{minted}")
    assert "\\end\\,{minted}" == quote_result

    weave_result = list(weaver_instance.generate_text(mock_tiny_web))
    assert expected_tex_minted_output == weave_result



expected_html_output = [
    '\n'
    '<a name="pyweb_314"></a>\n'
    "<!--line number ('sample.w', 789)-->\n"
    '<p><em>Chunk (314)</em> =</p>\n'
    '<pre><code>',
    '\n'
    '</code></pre>\n'
    '<p>&#8718; <em>Chunk (314)</em>.\n'
    'Used by &rarr;<a href="#pyweb_"><em> ()</em></a>.\n'
    '</p> \n'
]


def test_weaver_functions_html(weaver_instance, mock_tiny_web):
    weaver_instance.set_markup("html")

    quote_result = pyweb.html_quote_rules("a < b && c > d")
    assert "a &lt; b &amp;&amp; c &gt; d" == quote_result

    weave_result = list(weaver_instance.generate_text(mock_tiny_web))
    assert expected_html_output == weave_result


def test_tangler_should_codeBlock(tmp_path) -> None:
    tangler = pyweb.Tangler(tmp_path)
    target = io.StringIO()
    tangler.codeBlock(target, "Some")
    tangler.codeBlock(target, " Code")
    tangler.codeBlock(target, "\n")
    output = target.getvalue()
    assert "Some Code\n" == output

def test_tangler_should_indent(tmp_path) -> None:
    tangler = pyweb.Tangler(tmp_path)
    target = io.StringIO()
    tangler.codeBlock(target, "Begin\n")
    tangler.addIndent(4)
    tangler.codeBlock(target, "More Code\n")
    tangler.clrIndent()
    tangler.codeBlock(target, "End\n")
    output = target.getvalue()
    assert "Begin\n    More Code\nEnd\n" == output

def test_tangler_should_noindent(tmp_path) -> None:
    tangler = pyweb.Tangler(tmp_path)
    target = io.StringIO()
    tangler.codeBlock(target, "Begin")
    tangler.codeBlock(target, "\n")
    tangler.setIndent(0)
    tangler.codeBlock(target, "More Code")
    tangler.codeBlock(target, "\n")
    tangler.clrIndent()
    tangler.codeBlock(target, "End")
    tangler.codeBlock(target, "\n")
    output = target.getvalue()
    assert "Begin\nMore Code\nEnd\n" == output



@pytest.fixture
def web_output_tangler(tmp_path):
    tangler = pyweb.TanglerMake()
    web = mock_web()
    tangler.output = tmp_path
    tangler.emit(web)
    return web, tmp_path / "sample.out", tangler

def test_confirm_tanged_output(web_output_tangler) -> None:
    web, output, tangler = web_output_tangler
    tangled = output.read_text()
    expected = (
        'Mocked Tangle Output\n'
    )
    assert expected == tangled


def test_same_should_leave(web_output_tangler) -> None:
    web, output, tangler = web_output_tangler
    original_stat = output.stat()
    tangler.emit(web)
    assert os.path.samestat(original_stat, output.stat())
    assert original_stat.st_mtime == output.stat().st_mtime

def test_different_should_update(web_output_tangler) -> None:
    web, output, tangler = web_output_tangler
    original_stat = output.stat()

    # Modify the web in some way to create a distinct value.
    def tangle_method(aTangler: pyweb.Tangler, target: TextIO) -> None:
        aTangler.codeBlock(target, "Updated Tangle Output\n")
    web.chunks[1].commands[0].tangle = Mock(side_effect=tangle_method)

    tangler.emit(web)

    assert not os.path.samestat(original_stat, output.stat())
    # Not **always** true...
    # Would require a short sleep to assure time stamps don't match.
    # assert original_stat.st_mtime != output.stat().st_mtime




MockCommand = Mock(
    name="Command class",
    side_effect=lambda: Mock(
        name="Command instance",
        # text="",  # Only used for TextCommand.
        lineNumber=314,
        startswith=Mock(return_value=False)
    )
)


# Remove These...
def mock_web_instance() -> Mock:
    web = Mock(
        name="Web instance",
        chunks=[],
        # Methods
        # fullNameFor=Mock(side_effect=lambda name: name),
        # fileXref=Mock(return_value={'file': [1,2,3]}),
        # chunkXref=Mock(return_value={'chunk': [4,5,6]}),
        # userNamesXref=Mock(return_value={'name': (7, [8,9,10])}),
        createUsedBy=Mock(),
        # weaveChunk=Mock(side_effect=lambda name, weaver: weaver.write(name)),
        # weave=Mock(return_value=None),
        # tangle=Mock(return_value=None),
        web_path="sample.input",
    )
    return web

MockWeb = Mock(
    name="Web class",
    side_effect=mock_web_instance,
)

def mock_weaver_instance() -> MagicMock:
    context = MagicMock(
        name="Weaver instance context",
        __exit__=Mock()
    )
    
    weaver = MagicMock(
        name="Weaver instance",
        quote=Mock(return_value="quoted"),
        __enter__=Mock(return_value=context)
    )
    return weaver

MockWeaver = Mock(
    name="Weaver class",
    side_effect=mock_weaver_instance
)

def mock_tangler_instance() -> MagicMock:
    context = MagicMock(
        name="Tangler instance context",
        reference_names=Mock(add=Mock()),
        __exit__=Mock()
    )
    
    tangler = MagicMock(
        name="Tangler instance",
        __enter__=Mock(return_value=context),
    )
    return tangler

MockTangler = Mock(
    name="Tangler class",
    side_effect=mock_tangler_instance
)


@pytest.fixture
def chunk_instance():
    return pyweb.Chunk()


def test_append_command_should_work(chunk_instance) -> None:
    cmd1 = MockCommand()
    chunk_instance.commands.append(cmd1)
    assert 1 == len(chunk_instance.commands)
    assert [cmd1] == chunk_instance.commands
    
    cmd2 = MockCommand()
    chunk_instance.commands.append(cmd2)
    assert 2 == len(chunk_instance.commands)
    assert [cmd1, cmd2] == chunk_instance.commands


def test_lineNumber_should_work(chunk_instance) -> None:
    cmd1 = MockCommand()
    chunk_instance.commands.append(cmd1)
    assert 314 == chunk_instance.commands[0].lineNumber


def test_chunk_properties(chunk_instance) -> None:
    chunk_instance.name = "some name"
    web = mock_web()
    chunk_instance.web = Mock(return_value=web)

    chunk_instance.full_name
    web.resolve_name.assert_called_once_with(chunk_instance.name)
    assert chunk_instance.path is None
    assert chunk_instance.type_is('Chunk')
    assert not chunk_instance.type_is('OutputChunk')
    assert chunk_instance.referencedBy is None



@pytest.fixture
def namedchunk_instance():
    chunk = pyweb.NamedChunk(options=["Some Name..."])
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk


def test_should_find_xref_words(namedchunk_instance) -> None:
    assert 2 == len(namedchunk_instance.def_names)
    assert {"index", "terms"} == set(namedchunk_instance.def_names)


def test_namedchunk_properties(namedchunk_instance) -> None:
    web = mock_web()
    namedchunk_instance.web = Mock(return_value=web)
    namedchunk_instance.full_name
    web.resolve_name.assert_called_once_with(namedchunk_instance.name)
    assert namedchunk_instance.path is None
    assert namedchunk_instance.type_is("NamedChunk")
    assert not namedchunk_instance.type_is("OutputChunk")
    assert not namedchunk_instance.type_is("Chunk")
    assert namedchunk_instance.referencedBy is None



@pytest.fixture
def namedchunk_noindent_instance():
    chunk = pyweb.NamedChunk(options=["-noindent", "NoIndent Name..."])
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk


def test_should_find_xref_words(namedchunk_noindent_instance) -> None:
    assert 2 == len(namedchunk_noindent_instance.def_names)
    assert {"index", "terms"} == set(namedchunk_noindent_instance.def_names)


def test_namedchunk_ni_properties(namedchunk_noindent_instance) -> None:
    web = mock_web()
    namedchunk_noindent_instance.web = Mock(return_value=web)
    namedchunk_noindent_instance.full_name
    web.resolve_name.assert_called_once_with(namedchunk_noindent_instance.name)
    assert namedchunk_noindent_instance.path is None
    assert namedchunk_noindent_instance.type_is("NamedChunk")
    assert not namedchunk_noindent_instance.type_is("Chunk")
    assert namedchunk_noindent_instance.referencedBy is None



@pytest.fixture
def outputchunk_instance():
    chunk = pyweb.OutputChunk(options=["filename.out"])
    chunk.comment_start = "# "
    chunk.comment_end = ""
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk


def test_should_find_xref_words(outputchunk_instance) -> None:
    assert 2 == len(outputchunk_instance.def_names)
    assert {"index", "terms"} == set(outputchunk_instance.def_names)


def test_outputchunk_properties(outputchunk_instance) -> None:
    web = mock_web()
    outputchunk_instance.web = Mock(return_value=web)
    assert outputchunk_instance.full_name is None
    web.resolve_name.assert_not_called()
    assert outputchunk_instance.path == Path("filename.out")
    assert outputchunk_instance.type_is("OutputChunk")
    assert not outputchunk_instance.type_is("Chunk")
    assert outputchunk_instance.referencedBy is None



@pytest.fixture
def named_documentchunk_instance():
    chunk = pyweb.NamedDocumentChunk("Document Chunk Name...")
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk


def test_should_find_xref_words(named_documentchunk_instance) -> None:
    assert 2 == len(named_documentchunk_instance.def_names)
    assert {"index", "terms"} == set(named_documentchunk_instance.def_names)


def test_nameddocument_chunk_properties(named_documentchunk_instance) -> None:
    web = mock_web()
    named_documentchunk_instance.web = Mock(return_value=web)
    named_documentchunk_instance.full_name
    web.resolve_name.assert_called_once_with(named_documentchunk_instance.name)
    assert named_documentchunk_instance.path is None
    assert named_documentchunk_instance.type_is("NamedDocumentChunk")
    assert not named_documentchunk_instance.type_is("OutputChunk")
    assert named_documentchunk_instance.referencedBy is None



 
@pytest.fixture
def main_parent_sub_chunks():
    web = MockWeb()
    main = pyweb.NamedChunk("Main", 1)
    main.referencedBy = None
    main.web = Mock(return_value=web)
    parent = pyweb.NamedChunk("Parent", 2)
    parent.referencedBy = main
    parent.web = Mock(return_value=web)
    chunk = pyweb.NamedChunk("Sub", 3)
    chunk.referencedBy = parent
    chunk.web = Mock(return_value=web)
    return main, parent, chunk


def test_simple(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    assert chunk.referencedBy == parent


def test_transitive_sub_sub(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = chunk.transitive_referencedBy
    assert 2 == len(theList)
    assert parent == theList[0]
    assert main == theList[1]


def test_transitive_sub(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = parent.transitive_referencedBy
    assert 1 == len(theList)
    assert main == theList[0]


def test_transitive_top(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = main.transitive_referencedBy
    assert 0 == len(theList)


 
# No Tests
 
@pytest.fixture
def text_command_instances():
    cmd = pyweb.TextCommand("Some text & words in the document\n    ", ("sample.w", 314))
    cmd2 = pyweb.TextCommand("No Indent\n", ("sample.w", 271))
    return cmd, cmd2


def test_textcommand_methods(text_command_instances) -> None:
    cmd, cmd2 = text_command_instances
    assert cmd.typeid.TextCommand
    assert ("sample.w", 314) == cmd.location


def test_textcommamnd_tangle_should_error(text_command_instances) -> None:
    cmd, cmd2 = text_command_instances
    tangler = MockTangler()
    with pytest.raises(pyweb.Error) as exc_info:
        cmd.tangle(tangler, sentinel.TARGET)
    assert exc_info.value.args == (
        "attempt to tangle a text block ('sample.w', 314) 'Some text & words in the [...]'",
    )



@pytest.fixture
def code_command_instance():
    cmd = pyweb.CodeCommand("Some code in the document\n    ", ("sample.w", 314))
    return cmd


def test_codecommand_methods(code_command_instance) -> None:
    assert code_command_instance.typeid.CodeCommand
    assert ("sample.w", 314)== code_command_instance.location


def test_codecommand_tangle_should_work(code_command_instance) -> None:
    tangler = MockTangler()
    code_command_instance.tangle(tangler, sentinel.TARGET)
    tangler.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some code in the document\n    ')


# No Tests 
 
@pytest.fixture
def filexref_command_instance():
    web = Mock(files=sentinel.FILES)
    cmd = pyweb.FileXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd


def test_filexrefcommand_methods(filexref_command_instance) -> None:
    assert filexref_command_instance.typeid.FileXrefCommand
    assert ("sample.w", 314) == filexref_command_instance.location
    assert sentinel.FILES == filexref_command_instance.files


def test_filexrefcommand_tangle_should_fail(filexref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        filexref_command_instance.tangle(tangler, sentinel.TARGET)



@pytest.fixture
def macroxref_command_instance():
    web = Mock(macros=sentinel.MACROS)
    cmd = pyweb.MacroXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd


def test_macroxrefcommand_methods(macroxref_command_instance) -> None:
    assert macroxref_command_instance.typeid.MacroXrefCommand
    assert ("sample.w", 314) == macroxref_command_instance.location
    assert sentinel.MACROS == macroxref_command_instance.macros


def test_macroxrefcommand_tangle_should_fail(macroxref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        macroxref_command_instance.tangle(tangler, sentinel.TARGET)



@pytest.fixture
def useridxref_command_instance():
    web = Mock(userids=sentinel.USERIDS)
    cmd = pyweb.UserIdXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd


def test_useridxref_command_methods(useridxref_command_instance) -> None:
    assert useridxref_command_instance.typeid.UserIdXrefCommand
    assert ("sample.w", 314) == useridxref_command_instance.location
    assert sentinel.USERIDS == useridxref_command_instance.userids


def test_useridxref_command_tangle_should_fail(useridxref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        useridxref_command_instance.tangle(tangler, sentinel.TARGET)




def test_reference_command_methods(reference_command_instance) -> None:
    assert reference_command_instance.typeid.ReferenceCommand
    assert ("sample.w", 314) == reference_command_instance.location
    assert sentinel.FULL_NAME == reference_command_instance.full_name
    assert sentinel.SEQUENCE == reference_command_instance.seq


def test_reference_command_tangle_should_work(reference_command_instance) -> None:
    tangler = MockTangler()
    reference_command_instance.tangle(tangler, sentinel.TARGET)
    web = reference_command_instance.web()
    web.resolve_chunk.assert_called_once_with("Some Name")
    tangler.reference_names.add.assert_called_once_with('Some Name')
    referenced_chunk = web.resolve_chunk("Some Name")[0]
    referenced_chunk.commands[0].tangle.assert_called_once_with(tangler, sentinel.TARGET)


@pytest.fixture
def reference_command_instance():
    cmd = pyweb.ReferenceCommand("Some Name", ("sample.w", 314))
    chunk = mock_chunk_instance("name", 123, ("sample.w", 456), commands=[cmd])
    referenced_chunk = Mock(seq=sentinel.SEQUENCE, references=1, referencedBy=chunk, commands=[Mock()])
    web = Mock(
        resolve_name=Mock(return_value=sentinel.FULL_NAME),
        resolve_chunk=Mock(return_value=[referenced_chunk])
    )
    cmd.web = Mock(return_value=web)
    return cmd



@pytest.fixture
def web_instance():
    c1 = mock_chunk_instance("c1", 1, ("sample.w", 11))
    c1.type_is = Mock(side_effect = lambda n: n == "Chunk")
    c1.referencedBy = None
    c1.name = None

    c2 = mock_chunk_instance("c2", 2, ("sample.w", 22))
    c2.type_is = Mock(side_effect = lambda n: n == "OutputChunk")
    c2.commands = [Mock()]
    c2.commands[0].name = "c3..."
    c2.commands[0].typeid = Mock(ReferenceCommand=True, TextCommand=False, CodeCommand=False)
    c2.referencedBy = None

    c3 = mock_chunk_instance("c3 has a long name", 3, ("sample.w", 33))
    c3.type_is = Mock(side_effect = lambda n: n == "NamedChunk")
    c3.referencedBy = None
    c3.def_names = ["userid"]

    raw_chunks = [c1, c2, c3]
    web = pyweb.Web(raw_chunks)
    return web


def test_web_name_resolution(web_instance) -> None:
    assert web_instance.resolve_name("c1") == "c1"
    assert web_instance.resolve_chunk("c2") == [web_instance.chunks[1]]
    assert web_instance.resolve_name("c1...") == "c1"
    assert web_instance.resolve_name("c3...") == "c3 has a long name"


def test_chunks_should_iterate(web_instance) -> None:
    web = web_instance
    c1, c2, c3 = web_instance.chunks
    assert [c2] == list(web.file_iter())
    assert [c3] == list(web.macro_iter())
    assert [SimpleNamespace(def_name="userid", chunk=c3)] == list(web.userid_iter())
    assert [c2] == web.files
    assert [
            SimpleNamespace(name="c2", full_name="c2", seq=1, def_list=[c2]),
            SimpleNamespace(name="c3 has a long name", full_name="c3 has a long name", seq=2, def_list=[c3])
        ] == web.macros
    assert [SimpleNamespace(userid='userid', ref_list=[c3])] == web.userids
    assert [c2] == web.no_reference()
    assert [] == web.multi_reference()


def test_valid_web_should_tangle(web_instance) -> None:
    web = web_instance
    c1, c2, c3 = web_instance.chunks
    assert [c2], web.files

# No tests


# Tested via functional tests

@pytest.fixture
def tokenizer():
    input = io.StringIO("@@ word @{ @[ @< @>\n@] @} @i @| @m @f @u @( @)\n")
    tokenizer = pyweb.Tokenizer(input)
    return tokenizer

def test_should_split_tokens(tokenizer) -> None:
    tokens = list(tokenizer)
    assert len(tokens) == 28
    assert tokens == ['@@', ' word ', '@{', ' ', '@[', ' ', '@<', ' ',
    '@>', '\n', '@]', ' ', '@}', ' ', '@i', ' ', '@|', ' ', '@m', ' ',
    '@f', ' ', '@u', ' ', '@(', ' ', '@)', '\n']
    assert tokenizer.lineNumber == 2

def test_output_chunk_with_options_should_parse() -> None:
    text1 = " -start /* -end */ -noweave something.css "
    chunk1 = pyweb.OutputChunk(options=shlex.split(text1))
    assert asdict(chunk1) == {
        'commands': [],
        'comment_end': '',
        'comment_start': '# ',
        'def_names': [],
        'indent': None,
        'initial': False,
        'logger': chunk1.logger,
        'name': 'something.css',
        'options': ['-start', '/*', '-end', '*/', '-noweave', 'something.css'],
        'referencedBy': None,
        'references': 0,
        'seq': None,
        'style': None,
        'weave': False,
        'web': None}

def test_output_chunk_without_options_should_parse() -> None:
    text2 = " something.py "
    chunk2 = pyweb.OutputChunk(options=shlex.split(text2))
    assert asdict(chunk2) == {
        'commands': [],
        'comment_end': '',
        'comment_start': '# ',
        'def_names': [],
        'indent': None,
        'initial': False,
        'logger': chunk2.logger,
        'name': 'something.py',
        'options': ['something.py'],
        'referencedBy': None,
        'references': 0,
        'seq': None,
        'style': None,
        'weave': True,
        'web': None}

def test_namedchunk_with_options_should_parse() -> None:
    text1 = " -indent the name of test1 chunk... "
    chunk1 = pyweb.NamedChunk(options=shlex.split(text1))
    assert asdict(chunk1) == {
        'commands': [],
        'comment_end': None,
        'comment_start': None,
        'def_names': [],
        'indent': None,
        'initial': False,
        'logger': chunk1.logger,
        'name': 'the name of test1 chunk...',
        'options': ['-indent', 'the', 'name', 'of', 'test1', 'chunk...'],
        'referencedBy': None,
        'references': 0,
        'seq': None,
        'style': None,
        'weave': True,
        'web': None}

def test_namedchunk_without_options_should_parse() -> None:
    text2 = " the name of test2 chunk... "
    chunk2 = pyweb.NamedChunk(options=shlex.split(text2))
    assert asdict(chunk2) == {
        'commands': [],
        'comment_end': None,
        'comment_start': None,
        'def_names': [],
        'indent': None,
        'initial': False,
        'logger': chunk2.logger,
        'name': 'the name of test2 chunk...',
        'options': ['the', 'name', 'of', 'test2', 'chunk...'],
        'referencedBy': None,
        'references': 0,
        'seq': None,
        'style': None,
        'weave': True,
        'web': None}

ex1 = ("Escape: @@ Example", "Escape: @ Example")
ex2 = ("Filename: @(theFile@)", "Filename: sample.w")

@pytest.fixture(params=(ex1, ex2))
def chunks_text(request) -> tuple[list[pyweb.Chunk], str]:
    input, expected = request.param
    reader = pyweb.WebReader()
    chunks = reader.load(Path("sample.w"), io.StringIO(input))
    return chunks, expected

def test_web_reader_builds_escape_chunk(chunks_text):
    chunks, expected = chunks_text
    assert len(chunks) == 1
    assert len(chunks[0].commands) == 1
    assert chunks[0].commands[0].text == expected

 

@pytest.fixture
def action_sequence_instance():
    a1 = MagicMock(name="Action1")
    a2 = MagicMock(name="Action2")
    action = pyweb.ActionSequence("TwoSteps", [a1, a2])
    action.web = mock_web()
    return action


def test_action_sequence_execute_both(action_sequence_instance) -> None:
    action_sequence_instance(sentinel.OPTIONS)
    action_sequence_instance.opSequence[0].assert_called_once_with(sentinel.OPTIONS)
    action_sequence_instance.opSequence[1].assert_called_once_with(sentinel.OPTIONS)


 
@pytest.fixture
def action_loader_instance(tmp_path):
    action = pyweb.LoadAction()
    web = MockWeb()
    webReader = Mock(
            name="WebReader",
            errors=0,
            load=Mock(return_value=[])
        )
    options = argparse.Namespace(
        webReader=webReader,
        source_path=tmp_path,
        command="@",
        permitList=[],
        output=tmp_path,
    )
    return action, options


def test_loader_action(action_loader_instance) -> None:
    action, options = action_loader_instance
    action(options)
    options.webReader.load.assert_called_once_with(options.source_path)



@pytest.fixture
def action_tangle_instance(tmp_path):
    action = pyweb.TangleAction()
    web = mock_web()
    tangler = MockTangler()
    options = argparse.Namespace(
        theTangler=tangler,
        output=tmp_path,
        tangler_line_numbers=False,
        web=web,
    )
    return action, options


def test_tangle_action(action_tangle_instance) -> None:
    action, options = action_tangle_instance
    action(options)
    options.theTangler.emit.assert_called_once_with(options.web)


 
@pytest.fixture
def action_weave_instance(tmp_path):
    action = pyweb.WeaveAction()
    web = mock_web()
    weaver = MockWeaver()
    options = argparse.Namespace(
        theWeaver=weaver,
        output=tmp_path,
        web=web,
        weaver='rst',
    )
    return action, options


def test_weave_action(action_weave_instance) -> None:
    action, options = action_weave_instance
    action(options)
    options.theWeaver.emit.assert_called_once_with(options.web)



# TODO Test Application class 
