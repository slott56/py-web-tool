"""Unit tests."""
import argparse
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
import unittest
from unittest.mock import Mock, call, MagicMock, sentinel
import warnings

import pyweb

def rstrip_lines(source: str) -> list[str]:
    return list(l.rstrip() for l in source.splitlines())    



def mock_chunk_instance(name: str, seq: int, location: tuple[str, int]) -> Mock:
    chunk = Mock(
        wraps=pyweb.Chunk,
        full_name=name,
        seq=seq,
        location=location,
        commands=[],
        referencedBy=None,
        references=0,
        def_names=[],
        path=None,
        tangle=Mock(),
        type_is=Mock(side_effect=lambda x: x == "Chunk"),
        # reference_indent=Mock(),
        # reference_dedent=Mock(),
    )
    chunk.name = name
    return chunk
    
MockChunk = Mock(
    name="Chunk class",
    side_effect=mock_chunk_instance
)

def mock_web() -> pyweb.Web:
    def tangle_method(aTangler: pyweb.Tangler, target: TextIO) -> None:
        aTangler.codeBlock(target, "Mocked Tangle Output\n")

    mock_file = Mock(full_name="sample.out", seq=1)
    mock_file.name = "sample.out"
    mock_output = Mock(full_name="named chunk", seq=2, def_list=[3])
    mock_output.name = "named chunk"
    mock_uid_1 = Mock(userid="user_id_1", ref_list=[mock_output])
    mock_uid_2 = Mock(userid="user_id_2", ref_list=[mock_output])
    mock_ref = Mock(typeid=pyweb.TypeId(), full_name="named chunk", seq=42)
    mock_ref.typeid.__set_name__(pyweb.ReferenceCommand, "typeid")
    mock_ref.name = "named..."
    
    c_0 = Mock(
        name="mock Chunk",
        type_is=Mock(side_effect = lambda n: n == "Chunk"),
        commands=[
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
        ],
        referencedBy=None,
    )
    c_1 = Mock(
        name="mock OutputChunk",
        type_is=Mock(side_effect = lambda n: n == "OutputChunk"),
        seq=42,
        full_name="sample.out",
        commands=[
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
            mock_ref,
        ],
        def_names=["some_name"],
        referencedBy=None,
    )
    c_2 = Mock(
        name="mock NamedChunk",
        type_is=Mock(side_effect = lambda n: n == "NamedChunk"),
        seq=42,
        full_name="named chunk",
        commands=[
            Mock(
                typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
                text="|char| `code` *em* _em_",
            ),
            Mock(
                typeid=pyweb.TypeId().__set_name__(pyweb.CodeCommand, "typeid"),
                text="\n",
                tangle=Mock(),
            ),
        ],
        def_names=["another_name"],
        referencedBy=c_1
    )
    web = Mock(
        name="mock web",
        web_path=Path("TestWeaver.w"),
        chunks=[c_0, c_1, c_2],
    )
    web.chunks[1].name="sample.out"
    web.chunks[2].name="named..."
    web.files = [web.chunks[1]]
    return web

 
class EmitterExtension(pyweb.Emitter):
    mock_emit = Mock()
    def emit(self, web: pyweb.Web) -> None:
        self.mock_emit(web)

class TestEmitter(unittest.TestCase):
    def setUp(self) -> None:
        self.output = Path("TestEmitter.out")
        self.emitter = EmitterExtension(self.output)
        self.web = Mock(name="mock web")
    def test_emitter_should_open_close_write(self) -> None:
        self.emitter.emit(self.web)
        self.emitter.mock_emit.called_once_with(self.web)
        self.assertEqual(self.emitter.output, self.output)


def test_rst_quote_rules():
    assert pyweb.rst_quote_rules("|char| `code` *em* _em_") == r"\|char\| \`code\` \*em\* \_em\_"

def test_html_quote_rules():
    assert pyweb.html_quote_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"


class TestWeaver(unittest.TestCase):
    def setUp(self) -> None:
        self.filepath = Path.cwd()
        self.weaver = pyweb.Weaver(self.filepath)
        self.weaver.set_markup("rst")
        # self.weaver.reference_style = pyweb.SimpleReference()  # Remove this
        self.output_path = self.filepath / "TestWeaver.rst"
        self.web = mock_web()
        self.maxDiff = None
        
    def tearDown(self) -> None:
        try:
            self.output_path.unlink()
        except OSError:
            pass
        
    def test_weaver_functions_generic(self) -> None:
        self.weaver.emit(self.web)
        result = self.output_path.read_text()
        expected = ('text with |char| untouched.\n'
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
            '..  parsed-literal::\n'
            '    :class: code\n'
            '\n'
            '    \\|char\\| \\`code\\` \\*em\\* \\_em\\_\n'
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
            '..  _`named chunk (42)`:\n'
            '..  rubric:: named chunk (42) =\n'
            '..  parsed-literal::\n'
            '    :class: code\n'
            '\n'
            '    \\|char\\| \\`code\\` \\*em\\* \\_em\\_\n'
            '    \n'
            '\n'
            '..\n'
            '\n'
            '..  container:: small\n'
            '\n'
            '    ∎ *named chunk (42)*.\n'
            '    Used by     → `sample.out (42)`_.\n'
            '\n')
        self.assertEqual(expected, result)

 
class TestLaTeX(unittest.TestCase):
    def setUp(self) -> None:
        self.weaver = pyweb.Weaver()
        self.weaver.set_markup("tex")
        # self.weaver.reference_style = pyweb.SimpleReference()  # Remove this 
        self.filepath = Path("testweaver") 
        self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))
        self.aFileChunk.referencedBy = [ ]
        self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))
        self.aChunk.type_is = Mock(side_effect=lambda n: n == "OutputChunk")
        self.aChunk.referencedBy = [self.aFileChunk,]
        self.aChunk.references = [(self.aFileChunk.name, self.aFileChunk.seq)]

    def tearDown(self) -> None:
        try:
            self.filepath.with_suffix(".tex").unlink()
        except OSError:
            pass
            
    def test_weaver_functions_latex(self) -> None:
        result = pyweb.latex_quote_rules("\\end{Verbatim}")
        self.assertEqual("\\end\\,{Verbatim}", result)
        web = Mock(chunks=[self.aChunk])
        result = list(self.weaver.generate_text(web))
        expected = [
            '\n'
            '\\label{pyweb-314}\n'
            '\\begin{flushleft}\n'
            '\\textit{Code example Chunk (314)}\n'
            '\\begin{Verbatim}[commandchars=\\\\\\{\\},codes={\\catcode`$$=3\\catcode`^=7},frame=single]',
            '\n'
            '\\end{Verbatim}\n'
            '\\end{flushleft}\n'
        ]
        self.assertEqual(expected, result)

 
class TestHTML(unittest.TestCase):
    def setUp(self) -> None:
        self.maxDiff = None
        self.weaver = pyweb.Weaver( )
        self.weaver.set_markup("html")
        # self.weaver.reference_style = pyweb.SimpleReference()  # Remove this 
        self.filepath = Path("testweaver") 
        self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))
        self.aFileChunk.referencedBy = []
        self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))
        self.aChunk.type_is = Mock(side_effect=lambda n: n == "OutputChunk")
        self.aChunk.referencedBy = [self.aFileChunk,]
        self.aChunk.references = [(self.aFileChunk.name, self.aFileChunk.seq)]

    def tearDown(self) -> None:
        try:
            self.filepath.with_suffix(".html").unlink()
        except OSError:
            pass
            
    def test_weaver_functions_html(self) -> None:
        result = pyweb.html_quote_rules("a < b && c > d")
        self.assertEqual("a &lt; b &amp;&amp; c &gt; d", result)
        web = Mock(chunks=[self.aChunk])
        result = list(self.weaver.generate_text(web))
        expected = [
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
        self.assertEqual(expected, result)


 
class TestTangler(unittest.TestCase):
    def setUp(self) -> None:
        self.filepath = Path.cwd() 
        self.tangler = pyweb.Tangler(self.filepath)
        
    def tearDown(self) -> None:
        try:
            target = self.filepath / "sample.out"
            target.unlink()
        except FileNotFoundError:
            pass
                
    def test_tangler_should_codeBlock(self) -> None:
        target = io.StringIO()
        self.tangler.codeBlock(target, "Some")
        self.tangler.codeBlock(target, " Code")
        self.tangler.codeBlock(target, "\n")
        output = target.getvalue()
        self.assertEqual("Some Code\n", output)
        
    def test_tangler_should_indent(self) -> None:
        target = io.StringIO()
        self.tangler.codeBlock(target, "Begin\n")
        self.tangler.addIndent(4)
        self.tangler.codeBlock(target, "More Code\n")
        self.tangler.clrIndent()
        self.tangler.codeBlock(target, "End\n")
        output = target.getvalue()
        self.assertEqual("Begin\n    More Code\nEnd\n", output)
        
    def test_tangler_should_noindent(self) -> None:
        target = io.StringIO()
        self.tangler.codeBlock(target, "Begin")
        self.tangler.codeBlock(target, "\n")
        self.tangler.setIndent(0)
        self.tangler.codeBlock(target, "More Code")
        self.tangler.codeBlock(target, "\n")
        self.tangler.clrIndent()
        self.tangler.codeBlock(target, "End")
        self.tangler.codeBlock(target, "\n")
        output = target.getvalue()
        self.assertEqual("Begin\nMore Code\nEnd\n", output)


class TestTanglerMake(unittest.TestCase):
    def setUp(self) -> None:
        self.filepath = Path.cwd()
        self.tangler = pyweb.TanglerMake()
        self.web = mock_web()
        self.output = self.filepath / "sample.out"
        self.tangler.emit(self.web)
        self.time_original = self.output.stat().st_mtime
        self.original = self.output.stat()
        
    def tearDown(self) -> None:
        try:
            self.output.unlink()
        except OSError:
            pass
        
    def test_confirm_tanged_output(self) -> None:
        tangled = self.output.read_text()
        expected = (
            'Mocked Tangle Output\n'
        )
        self.assertEqual(expected, tangled)
        
        
    def test_same_should_leave(self) -> None:
        self.tangler.emit(self.web)
        self.assertTrue(os.path.samestat(self.original, self.output.stat()))
        #self.assertEqual(self.time_original, self.output.stat().st_mtime)
        
    def test_different_should_update(self) -> None:
        # Modify the web in some way to create a distinct value.
        def tangle_method(aTangler: pyweb.Tangler, target: TextIO) -> None:
            aTangler.codeBlock(target, "Updated Tangle Output\n")
        self.web.chunks[1].commands[0].tangle = Mock(side_effect=tangle_method) 
        self.tangler.emit(self.web)
        print(self.output.read_text())
        self.assertFalse(os.path.samestat(self.original, self.output.stat()))
        #self.assertNotEqual(self.time_original, self.output.stat().st_mtime)




MockCommand = Mock(
    name="Command class",
    side_effect=lambda: Mock(
        name="Command instance",
        # text="",  # Only used for TextCommand.
        lineNumber=314,
        startswith=Mock(return_value=False)
    )
)


def mock_web_instance() -> Mock:
    web = Mock(
        name="Web instance",
        chunks=[],
        # add=Mock(return_value=None),
        # addNamed=Mock(return_value=None),
        # addOutput=Mock(return_value=None),
        fullNameFor=Mock(side_effect=lambda name: name),
        fileXref=Mock(return_value={'file': [1,2,3]}),
        chunkXref=Mock(return_value={'chunk': [4,5,6]}),
        userNamesXref=Mock(return_value={'name': (7, [8,9,10])}),
        # getchunk=Mock(side_effect=lambda name: [MockChunk(name, 1, ("sample.w", 314))]),
        createUsedBy=Mock(),
        weaveChunk=Mock(side_effect=lambda name, weaver: weaver.write(name)),
        weave=Mock(return_value=None),
        tangle=Mock(return_value=None),
    )
    return web

MockWeb = Mock(
    name="Web class",
    side_effect=mock_web_instance,
    file_path="sample.input",
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


class TestChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.Chunk()
        
        
    def test_append_command_should_work(self) -> None:
        cmd1 = MockCommand()
        self.theChunk.commands.append(cmd1)
        self.assertEqual(1, len(self.theChunk.commands))
        self.assertEqual([cmd1], self.theChunk.commands)
        
        cmd2 = MockCommand()
        self.theChunk.commands.append(cmd2)
        self.assertEqual(2, len(self.theChunk.commands))
        self.assertEqual([cmd1, cmd2], self.theChunk.commands)

    
        
    def test_lineNumber_should_work(self) -> None:
        cmd1 = MockCommand()
        self.theChunk.commands.append(cmd1)
        self.assertEqual(314, self.theChunk.commands[0].lineNumber)

    
        
    def test_properties(self) -> None:
        self.theChunk.name = "some name"
        web = MockWeb()
        self.theChunk.web = Mock(return_value=web)
        self.theChunk.full_name
        web.resolve_name.assert_called_once_with(self.theChunk.name)
        self.assertIsNone(self.theChunk.path)
        self.assertTrue(self.theChunk.type_is('Chunk'))
        self.assertFalse(self.theChunk.type_is('OutputChunk'))
        self.assertIsNone(self.theChunk.referencedBy)


 
class TestNamedChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.NamedChunk(name="Some Name...")
        cmd = MockCommand()
        self.theChunk.commands.append(cmd)
        self.theChunk.def_names = ["index", "terms"]
        
    def test_should_find_xref_words(self) -> None:
        self.assertEqual(2, len(self.theChunk.def_names))
        self.assertEqual({"index", "terms"}, set(self.theChunk.def_names))
        
    def test_properties(self) -> None:
        web = MockWeb()
        self.theChunk.web = Mock(return_value=web)
        self.theChunk.full_name
        web.resolve_name.assert_called_once_with(self.theChunk.name)
        self.assertIsNone(self.theChunk.path)
        self.assertTrue(self.theChunk.type_is("NamedChunk"))
        self.assertFalse(self.theChunk.type_is("OutputChunk"))
        self.assertFalse(self.theChunk.type_is("Chunk"))
        self.assertIsNone(self.theChunk.referencedBy)


class TestNamedChunk_Noindent(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.NamedChunk("NoIndent Name...", options="-noindent")
        cmd = MockCommand()
        self.theChunk.commands.append(cmd)
        self.theChunk.def_names = ["index", "terms"]

    def test_should_find_xref_words(self) -> None:
        self.assertEqual(2, len(self.theChunk.def_names))
        self.assertEqual({"index", "terms"}, set(self.theChunk.def_names))
        
    def test_properties(self) -> None:
        web = MockWeb()
        self.theChunk.web = Mock(return_value=web)
        self.theChunk.full_name
        web.resolve_name.assert_called_once_with(self.theChunk.name)
        self.assertIsNone(self.theChunk.path)
        self.assertTrue(self.theChunk.type_is("NamedChunk"))
        self.assertFalse(self.theChunk.type_is("Chunk"))
        self.assertIsNone(self.theChunk.referencedBy)


class TestOutputChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.OutputChunk("filename.out")
        self.theChunk.comment_start = "# "
        self.theChunk.comment_end = ""
        cmd = MockCommand()
        self.theChunk.commands.append(cmd)
        self.theChunk.def_names = ["index", "terms"]
        
    def test_should_find_xref_words(self) -> None:
        self.assertEqual(2, len(self.theChunk.def_names))
        self.assertEqual({"index", "terms"}, set(self.theChunk.def_names))
        
    def test_properties(self) -> None:
        web = MockWeb()
        self.theChunk.web = Mock(return_value=web)
        self.assertIsNone(self.theChunk.full_name)
        web.resolve_name.assert_not_called()
        self.assertEqual(self.theChunk.path, Path("filename.out"))
        self.assertTrue(self.theChunk.type_is("OutputChunk"))
        self.assertFalse(self.theChunk.type_is("Chunk"))
        self.assertIsNone(self.theChunk.referencedBy)


class TestNamedDocumentChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.NamedDocumentChunk("Document Chunk Name...")
        cmd = MockCommand()
        self.theChunk.commands.append(cmd)
        self.theChunk.def_names = ["index", "terms"]

    def test_should_find_xref_words(self) -> None:
        self.assertEqual(2, len(self.theChunk.def_names))
        self.assertEqual({"index", "terms"}, set(self.theChunk.def_names))
        
    def test_properties(self) -> None:
        web = MockWeb()
        self.theChunk.web = Mock(return_value=web)
        self.theChunk.full_name
        web.resolve_name.assert_called_once_with(self.theChunk.name)
        self.assertIsNone(self.theChunk.path)
        self.assertTrue(self.theChunk.type_is("NamedDocumentChunk"))
        self.assertFalse(self.theChunk.type_is("OutputChunk"))
        self.assertIsNone(self.theChunk.referencedBy)


 
class TestReferences(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.main = pyweb.NamedChunk("Main", 1)
        self.main.referencedBy = None
        self.main.web = Mock(return_value=self.web)
        self.parent = pyweb.NamedChunk("Parent", 2)
        self.parent.referencedBy = self.main
        self.parent.web = Mock(return_value=self.web)
        self.chunk = pyweb.NamedChunk("Sub", 3)
        self.chunk.referencedBy = self.parent
        self.chunk.web = Mock(return_value=self.web)

    def test_simple(self) -> None:
        self.assertEqual(self.chunk.referencedBy, self.parent)
        
    def test_transitive_sub_sub(self) -> None:
        theList = self.chunk.transitive_referencedBy
        self.assertEqual(2, len(theList))
        self.assertEqual(self.parent, theList[0])
        self.assertEqual(self.main, theList[1])

    def test_transitive_sub(self) -> None:
        theList = self.parent.transitive_referencedBy
        self.assertEqual(1, len(theList))
        self.assertEqual(self.main, theList[0])

    def test_transitive_top(self) -> None:
        theList = self.main.transitive_referencedBy
        self.assertEqual(0, len(theList))

 
# No Tests
 
class TestTextCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.TextCommand("Some text & words in the document\n    ", ("sample.w", 314))
        self.cmd2 = pyweb.TextCommand("No Indent\n", ("sample.w", 271))
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.TextCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
             
    def test_tangle_should_error(self) -> None:
        tnglr = MockTangler()
        with self.assertRaises(pyweb.Error) as exc_info:
            self.cmd.tangle(tnglr, sentinel.TARGET)
        assert exc_info.exception.args == (
            "attempt to tangle a text block ('sample.w', 314) 'Some text & words in the [...]'",
        )


class TestCodeCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.CodeCommand("Some code in the document\n    ", ("sample.w", 314))
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.CodeCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
             
    def test_tangle_should_work(self) -> None:
        tnglr = MockTangler()
        self.cmd.tangle(tnglr, sentinel.TARGET)
        tnglr.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some code in the document\n    ')

# No Tests 
 
class TestFileXRefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.FileXrefCommand(("sample.w", 314))
        self.web = Mock(files=sentinel.FILES)
        self.cmd.web = Mock(return_value=self.web)
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.FileXrefCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.FILES, self.cmd.files)
        
    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass


class TestMacroXRefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.MacroXrefCommand(("sample.w", 314))
        self.web = Mock(macros=sentinel.MACROS)
        self.cmd.web = Mock(return_value=self.web)

    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.MacroXrefCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.MACROS, self.cmd.macros)

    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass


class TestUserIdXrefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.UserIdXrefCommand(("sample.w", 314))
        self.web = Mock(userids=sentinel.USERIDS)
        self.cmd.web = Mock(return_value=self.web)

    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.UserIdXrefCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.USERIDS, self.cmd.userids)
        
    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass

 
class TestReferenceCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.chunk = MockChunk("name", 123, ("sample.w", 456))
        self.cmd = pyweb.ReferenceCommand("Some Name", ("sample.w", 314))
        self.chunk.commands = [self.cmd]
        self.referenced_chunk = Mock(seq=sentinel.SEQUENCE, references=1, referencedBy=self.chunk, commands=[Mock()])
        self.web = Mock(
            resolve_name=Mock(return_value=sentinel.FULL_NAME),
            resolve_chunk=Mock(return_value=[self.referenced_chunk])
        )
        self.cmd.web = Mock(return_value=self.web)
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.ReferenceCommand)
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.FULL_NAME, self.cmd.full_name)
        self.assertEqual(sentinel.SEQUENCE, self.cmd.seq)

    def test_tangle_should_work(self) -> None:
        tnglr = MockTangler()
        self.cmd.tangle(tnglr, sentinel.TARGET)
        self.web.resolve_chunk.assert_called_once_with("Some Name")
        tnglr.reference_names.add.assert_called_once_with('Some Name') 
        self.assertEqual(1, self.referenced_chunk.references)
        self.referenced_chunk.commands[0].tangle.assert_called_once_with(tnglr, sentinel.TARGET)


 
class TestWebConstruction(unittest.TestCase):
    def setUp(self) -> None:
        self.c1 = MockChunk("c1", 1, ("sample.w", 11))
        self.c1.type_is = Mock(side_effect = lambda n: n == "Chunk")
        self.c1.referencedBy = None
        self.c1.name = None
        self.c2 = MockChunk("c2", 2, ("sample.w", 22))
        self.c2.type_is = Mock(side_effect = lambda n: n == "OutputChunk")
        self.c2.commands = [Mock()]
        self.c2.commands[0].name = "c3..."
        self.c2.commands[0].typeid = Mock(ReferenceCommand=True, TextCommand=False, CodeCommand=False)
        self.c2.referencedBy = None
        self.c3 = MockChunk("c3 has a long name", 3, ("sample.w", 33))
        self.c3.type_is = Mock(side_effect = lambda n: n == "NamedChunk")
        self.c3.referencedBy = None
        self.c3.def_names = ["userid"]
        self.web = pyweb.Web([self.c1, self.c2, self.c3])
    
    def test_name_resolution(self) -> None:
        self.assertEqual(self.web.resolve_name("c1"), "c1")
        self.assertEqual(self.web.resolve_chunk("c2"), [self.c2])
        self.assertEqual(self.web.resolve_name("c1..."), "c1")
        self.assertEqual(self.web.resolve_name("c3..."), "c3 has a long name")
        
    def test_chunks_should_iterate(self) -> None:
        self.assertEqual([self.c2], list(self.web.file_iter()))
        self.assertEqual([self.c3], list(self.web.macro_iter()))
        self.assertEqual([SimpleNamespace(def_name="userid", chunk=self.c3)], list(self.web.userid_iter()))
        self.assertEqual([self.c2], self.web.files)
        self.assertEqual(
            [
                SimpleNamespace(name="c2", full_name="c2", seq=1, def_list=[self.c2]),
                SimpleNamespace(name="c3 has a long name", full_name="c3 has a long name", seq=2, def_list=[self.c3])
            ], 
            self.web.macros)
        self.assertEqual([SimpleNamespace(userid='userid', ref_list=[self.c3])], self.web.userids)
        self.assertEqual([self.c2], self.web.no_reference())
        self.assertEqual([], self.web.multi_reference())
        
    def test_valid_web_should_tangle(self) -> None:
        """This is the entire interface used by tangling.
        The details are pushed down to ```command.tangle()`` for each command in each chunk.
        """
        self.assertEqual([self.c2], self.web.files)
        
    def test_valid_web_should_weave(self) -> None:
        """This is the entire interface used by tangling.
        The details are pushed down to unique processing based on ``chunk.type_is``.
        """
        self.assertEqual([self.c1, self.c2, self.c3], self.web.chunks)


# Tested via functional tests

class TestTokenizer(unittest.TestCase):
    def test_should_split_tokens(self) -> None:
        input = io.StringIO("@@ word @{ @[ @< @>\n@] @} @i @| @m @f @u @( @)\n")
        self.tokenizer = pyweb.Tokenizer(input)
        tokens = list(self.tokenizer)
        self.assertEqual(28, len(tokens))
        self.assertEqual( ['@@', ' word ', '@{', ' ', '@[', ' ', '@<', ' ', 
        '@>', '\n', '@]', ' ', '@}', ' ', '@i', ' ', '@|', ' ', '@m', ' ', 
        '@f', ' ', '@u', ' ', '@(', ' ', '@)', '\n'], tokens )
        self.assertEqual(2, self.tokenizer.lineNumber)

class TestOptionParser_OutputChunk(unittest.TestCase):
    def setUp(self) -> None:
        rdr = pyweb.WebReader()
        self.option_parser = rdr.output_option_parser
    def test_with_options_should_parse(self) -> None:
        text1 = " -start /* -end */ something.css "
        options1 = self.option_parser.parse_args(shlex.split(text1))
        self.assertEqual(argparse.Namespace(start='/*', end='*/', argument=['something.css']), options1)
    def test_without_options_should_parse(self) -> None:
        text2 = " something.py "
        options2 = self.option_parser.parse_args(shlex.split(text2))
        self.assertEqual(argparse. Namespace(start=None, end='', argument=['something.py']), options2)
        
class TestOptionParser_NamedChunk(unittest.TestCase):
    def setUp(self) -> None:
        rdr = pyweb.WebReader()
        self.option_parser = rdr.definition_option_parser        
    def test_with_options_should_parse(self) -> None:
        text1 = " -indent the name of test1 chunk... "
        options1 = self.option_parser.parse_args(shlex.split(text1))
        self.assertEqual(argparse.Namespace(argument=['the', 'name', 'of', 'test1', 'chunk...'], indent=True, noindent=False), options1)
    def test_without_options_should_parse(self) -> None:
        text2 = " the name of test2 chunk... "
        options2 = self.option_parser.parse_args(shlex.split(text2))
        self.assertEqual(argparse.Namespace(argument=['the', 'name', 'of', 'test2', 'chunk...'], indent=False, noindent=False), options2)

class TestWebReader_Immediate(unittest.TestCase):
    def setUp(self) -> None:
        self.reader = pyweb.WebReader()
    
    def test_should_build_escape_chunk(self):
        chunks = self.reader.load(Path(), io.StringIO("Escape: @@ Example"))
        self.assertEqual(1, len(chunks))
        self.assertEqual(1, len(chunks[0].commands))
        self.assertEqual("Escape: @ Example", chunks[0].commands[0].text)
        
    def test_expressions(self):
        chunks = self.reader.load(Path("sample.w"), io.StringIO("Filename: @(theFile@)"))
        self.assertEqual(1, len(chunks))
        self.assertEqual(1, len(chunks[0].commands))
        self.assertEqual("Filename: sample.w", chunks[0].commands[0].text)

 

class TestActionSequence(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.a1 = MagicMock(name="Action1")
        self.a2 = MagicMock(name="Action2")
        self.action = pyweb.ActionSequence("TwoSteps", [self.a1, self.a2])
        self.action.web = self.web
        self.options = argparse.Namespace()
    def test_should_execute_both(self) -> None:
        self.action(self.options)
        self.assertEqual(self.a1.call_count, 1)
        self.assertEqual(self.a2.call_count, 1)

 
class TestLoadAction(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.action = pyweb.LoadAction()
        self.webReader = Mock(
            name="WebReader",
            errors=0,
            load=Mock(return_value=[])
        )
        self.source_path = Path("TestLoadAction.w")
        self.options = argparse.Namespace( 
            webReader = self.webReader, 
            source_path=self.source_path,
            command="@",
            permitList = [], 
            output=Path.cwd(),
        )
        Path("TestLoadAction.w").write_text("")
    def tearDown(self) -> None:
        try:
            Path("TestLoadAction.w").unlink()
        except IOError:
            pass
    def test_should_execute_loading(self) -> None:
        self.action(self.options)
        print(self.webReader.load.mock_calls)
        self.assertEqual(self.webReader.load.mock_calls, [call(self.source_path)])
        self.webReader.web.assert_not_called()  # Deprecated
        self.webReader.source.assert_not_called()  # Deprecated

 
class TestTangleAction(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.action = pyweb.TangleAction()
        self.tangler = MockTangler()
        self.options = argparse.Namespace( 
            theTangler = self.tangler,
            tangler_line_numbers = False, 
            output=Path.cwd(),
            web = self.web
        )
    def test_should_execute_tangling(self) -> None:
        self.action(self.options)
        self.assertEqual(self.tangler.emit.mock_calls, [call(self.web)])

 
class TestWeaveAction(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.action = pyweb.WeaveAction()
        self.weaver = MockWeaver()
        self.options = argparse.Namespace( 
            theWeaver=self.weaver,
            # reference_style=pyweb.SimpleReference(),  # Remove this
            output=Path.cwd(),
            web=self.web,
            weaver='rst',
        )
    def test_should_execute_weaving(self) -> None:
        self.action(self.options)
        self.assertEqual(self.weaver.emit.mock_calls, [call(self.web)])


# TODO Test Application class 

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

