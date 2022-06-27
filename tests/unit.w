Unit Testing
============

..    test/unit.w 

There are several broad areas of unit testing.  There are the 34 classes in this application.
However, it isn't really necessary to test everyone single one of these classes.
We'll decompose these into several hierarchies.


-    Emitters
    
        class Emitter:  
        
        class Weaver(Emitter):  
        
        class LaTeX(Weaver):  
        
        class HTML(Weaver):  
                
        class Tangler(Emitter):  
        
        class TanglerMake(Tangler):  
    
    
-    Structure: Chunk, Command
    
        class Chunk:  
        
        class NamedChunk(Chunk):  

        class NamedChunk_Noindent(Chunk):  
        
        class OutputChunk(NamedChunk):  
        
        class NamedDocumentChunk(NamedChunk):  
                
        class Command:  
        
        class TextCommand(Command):  
        
        class CodeCommand(TextCommand):  
        
        class XrefCommand(Command):  
        
        class FileXrefCommand(XrefCommand):  
        
        class MacroXrefCommand(XrefCommand):  
        
        class UserIdXrefCommand(XrefCommand):  
        
        class ReferenceCommand(Command):  
    
    
-    class Error(Exception):   
    
-    Reference Handling
    
        class Reference:  
        
        class SimpleReference(Reference):  
        
        class TransitiveReference(Reference):  
    
    
-    class Web:  

-    class WebReader:  

        class Tokenizer:
        
        class OptionParser:
    
-    Action
    
        class Action:  
        
        class ActionSequence(Action):  
        
        class WeaveAction(Action):  
        
        class TangleAction(Action):  
        
        class LoadAction(Action):  
    
    
-    class Application:  
    
-    class MyWeaver(HTML):  
    
-    class MyHTML(pyweb.HTML):


This gives us the following outline for unit testing.

@o test_unit.py 
@{@<Unit Test overheads: imports, etc.@>
@<Unit Test of Emitter class hierarchy@>
@<Unit Test of Chunk class hierarchy@>
@<Unit Test of Command class hierarchy@>
@<Unit Test of Reference class hierarchy@>
@<Unit Test of Web class@>
@<Unit Test of WebReader class@>
@<Unit Test of Action class hierarchy@>
@<Unit Test of Application class@>
@<Unit Test main@>
@}

Emitter Tests
-------------

The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.


@d Unit Test of Emitter class hierarchy... @{
@<Unit Test Mock Chunk class@>
@<Unit Test of Emitter Superclass@>
@<Unit Test of Weaver subclass of Emitter@>
@<Unit Test of LaTeX subclass of Emitter@>
@<Unit Test of HTML subclass of Emitter@>
@<Unit Test of Tangler subclass of Emitter@>
@<Unit Test of TanglerMake subclass of Emitter@>
@}

The Emitter superclass is designed to be extended.  The test 
creates a subclass to exercise a few key features. The default
emitter is Tangler-like.

@d Unit Test of Emitter Superclass... @{ 
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
@}

A mock Chunk is a Chunk-like object that we can use to test Weavers.

Some tests will create multiple chunks. To keep their state separate,
we define a function to return each mocked ``Chunk`` instance as a new Mock
object. The overall ``MockChunk`` class, uses a side effect to 
invoke the the ``mock_chunk_instance()`` function.

The ``write_closure()`` is a function that calls the ``Tangler.write()`` 
method. This is *not* consistent with best unit testing practices.
It is merely a hold-over from an older testing strategy. The mock call
history to the ``tangle()`` method of each ``Chunk`` instance is a better
test strategy. 

**TODO:** Simplify the following definition. A great deal of these features are legacy definitions.

@d Unit Test Mock Chunk...
@{
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
    mock_ref = Mock(typeid=pyweb.TypeId(pyweb.ReferenceCommand), full_name="named chunk", seq=42)
    mock_ref.name = "named..."
    web = Mock(
        name="mock web",
        web_path=Path("TestWeaver.w"),
        chunks=[
            Mock(
                name="mock Chunk",
                typeid=pyweb.TypeId(pyweb.Chunk),
                commands=[
                    Mock(
                        typeid=pyweb.TypeId(pyweb.TextCommand),
                        text="text with |char| untouched.",
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.TextCommand),
                        text="\n",
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.FileXrefCommand),
                        location=1,
                        files=[mock_file],
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.TextCommand),
                        text="\n",
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.MacroXrefCommand),
                        location=2,
                        macros=[mock_output],
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.TextCommand),
                        text="\n",
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.UserIdXrefCommand),
                        location=3,
                        userids=[mock_uid_1, mock_uid_2]
                    ),
                ],
            ),
            Mock(
                name="mock OutputChunk",
                typeid=pyweb.TypeId(pyweb.OutputChunk),
                seq=42,
                full_name="sample.out",
                commands=[
                    Mock(
                        typeid=pyweb.TypeId(pyweb.CodeCommand),
                        text="|char| `code` *em* _em_",
                        tangle=Mock(side_effect=tangle_method),
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.CodeCommand),
                        text="\n",
                        tangle=Mock(),
                    ),
                    mock_ref,
                ],
                def_names = ["some_name"],
            ),
            Mock(
                name="mock NamedChunk",
                typeid=pyweb.TypeId(pyweb.NamedChunk),
                seq=42,
                full_name="named chunk",
                commands=[
                    Mock(
                        typeid=pyweb.TypeId(pyweb.CodeCommand),
                        text="|char| `code` *em* _em_",
                    ),
                    Mock(
                        typeid=pyweb.TypeId(pyweb.CodeCommand),
                        text="\n",
                        tangle=Mock(),
                    ),
                ],
                def_names = ["another_name"]
            ),
        ],
    )
    web.chunks[1].name="sample.out"
    web.chunks[2].name="named..."
    web.files = [web.chunks[1]]
    return web
@}

The default Weaver is an Emitter that uses templates to produce RST markup.

@d Unit Test of Weaver... @{
def test_rst_quote_rules():
    assert pyweb.rst_quote_rules("|char| `code` *em* _em_") == r"\|char\| \`code\` \*em\* \_em\_"

def test_html_quote_rules():
    assert pyweb.html_quote_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"


class TestWeaver(unittest.TestCase):
    def setUp(self) -> None:
        self.filepath = Path.cwd()
        self.weaver = pyweb.Weaver(self.filepath)
        self.weaver.set_markup("rst")
        self.weaver.reference_style = pyweb.SimpleReference()
        self.output_path = self.filepath / "TestWeaver.rst"
        self.web = mock_web()
        
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
             '    →\\ `sample.out (1)`_\n'
             ':named chunk:\n'
             '    →\\ ` ()`_\n'
             '\n'
             '\n'
             ':user_id_1:\n'
             '    →\\ `named chunk (2)`_\n'
             '\n'
             ':user_id_2:\n'
             '    →\\ `named chunk (2)`_\n'
             '\n'
             '\n'
            '..  _`sample.out (42)`:\n'
            '..  rubric:: sample.out (42) =\n'
            '..  parsed-literal::\n'
            '    :class: code\n'
            '\n'
            '    \\|char\\| \\`code\\` \\*em\\* \\_em\\_\n'
            '    \n'
            '\n'
            '    →\\ `named chunk (42)`_\n'
            '..\n'
            '\n'
            '..  class:: small\n'
            '\n'
            '    ∎ *sample.out (42)*\n'
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
            '..  class:: small\n'
            '\n'
            '    ∎ *named chunk (42)*\n'
            '\n')
        self.assertEqual(expected, result)
@}

A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.

We'll examine a few features of the LaTeX templates.

@d Unit Test of LaTeX... @{ 
class TestLaTeX(unittest.TestCase):
    def setUp(self) -> None:
        self.weaver = pyweb.Weaver()
        self.weaver.set_markup("tex")
        self.weaver.reference_style = pyweb.SimpleReference() 
        self.filepath = Path("testweaver") 
        self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))
        self.aFileChunk.referencedBy = [ ]
        self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))
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
@}

We'll examine a few features of the HTML templates.

@d Unit Test of HTML subclass... @{ 
class TestHTML(unittest.TestCase):
    def setUp(self) -> None:
        self.weaver = pyweb.Weaver( )
        self.weaver.set_markup("html")
        self.weaver.reference_style = pyweb.SimpleReference() 
        self.filepath = Path("testweaver") 
        self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))
        self.aFileChunk.referencedBy = []
        self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))
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
             '</p> \n'
        ]
        self.assertEqual(expected, result)

@}

A Tangler emits the various named source files in proper format for the desired
compiler and language.

@d Unit Test of Tangler subclass... 
@{ 
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
        self.tangler.codeBlock(target, "Begin")
        self.tangler.codeBlock(target, "\n")
        self.tangler.addIndent(4)
        self.tangler.codeBlock(target, "More Code")
        self.tangler.codeBlock(target, "\n")
        self.tangler.clrIndent()
        self.tangler.codeBlock(target, "End")
        self.tangler.codeBlock(target, "\n")
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
@}

A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.




@d Unit Test of TanglerMake subclass... @{
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
@}

Chunk Tests
------------

The Chunk and Command class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.


@d Unit Test of Chunk class hierarchy... 
@{
@<Unit Test of Chunk superclass@>
@<Unit Test of NamedChunk subclass@>
@<Unit Test of NamedChunk_Noindent subclass@>
@<Unit Test of OutputChunk subclass@>
@<Unit Test of NamedDocumentChunk subclass@>
@}

In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
mock objects for all of these relationships in which a Chunk participates.

A MockCommand can be attached to a Chunk.

@d Unit Test of Chunk superclass...
@{
MockCommand = Mock(
    name="Command class",
    side_effect=lambda: Mock(
        name="Command instance",
        # text="",  # Only used for TextCommand.
        lineNumber=314,
        startswith=Mock(return_value=False)
    )
)
@}

A MockWeb can contain a Chunk.

@d Unit Test of Chunk superclass...
@{

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
@}

A MockWeaver or MockTangler appear to process a Chunk.
We can interrogate the ``mock_calls`` to be sure the right things were done.

We need to permit ``__enter__()`` and ``__exit__()``,
which leads to a multi-step instance.
The initial instance with ``__enter__()`` that
returns the context manager instance.


@d Unit Test of Chunk superclass...
@{
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
        __exit__=Mock()
    )
    
    tangler = MagicMock(
        name="Tangler instance",
        __enter__=Mock(return_value=context)
    )
    return tangler

MockTangler = Mock(
    name="Tangler class",
    side_effect=mock_tangler_instance
)

@}

A Chunk is built, interrogated and then emitted.

@d Unit Test of Chunk superclass...
@{
class TestChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.theChunk = pyweb.Chunk()
        
    @<Unit Test of Chunk construction@>
    
    @<Unit Test of Chunk interrogation@>
    
    @<Unit Test of Chunk properties@>
@}

Can we build a Chunk?

@d Unit Test of Chunk construction...
@{
def test_append_command_should_work(self) -> None:
    cmd1 = MockCommand()
    self.theChunk.commands.append(cmd1)
    self.assertEqual(1, len(self.theChunk.commands))
    self.assertEqual([cmd1], self.theChunk.commands)
    
    cmd2 = MockCommand()
    self.theChunk.commands.append(cmd2)
    self.assertEqual(2, len(self.theChunk.commands))
    self.assertEqual([cmd1, cmd2], self.theChunk.commands)
@}

Can we interrogate a Chunk?

@d Unit Test of Chunk interrogation...
@{
def test_lineNumber_should_work(self) -> None:
    cmd1 = MockCommand()
    self.theChunk.commands.append(cmd1)
    self.assertEqual(314, self.theChunk.commands[0].lineNumber)
@}

Can we emit a Chunk with a weaver or tangler?

@d Unit Test of Chunk properties...
@{
def test_properties(self) -> None:
    web = MockWeb()
    self.theChunk.web = Mock(return_value=web)
    self.theChunk.full_name
    web.resolve_name.assert_called_once_with(self.theChunk.name)
    self.assertIsNone(self.theChunk.path)
    self.assertTrue(self.theChunk.typeid.Chunk)
    self.assertFalse(self.theChunk.typeid.OutputChunk)
@}

The ``NamedChunk`` is created by a ``@@d`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.

@d Unit Test of NamedChunk subclass... @{ 
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
        self.assertTrue(self.theChunk.typeid.NamedChunk)
        self.assertFalse(self.theChunk.typeid.OutputChunk)
        self.assertFalse(self.theChunk.typeid.Chunk)
@}

@d Unit Test of NamedChunk_Noindent subclass...
@{
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
        self.assertTrue(self.theChunk.typeid.NamedChunk)
        self.assertFalse(self.theChunk.typeid.Chunk)
@}


The ``OutputChunk`` is created by a ``@@o`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks of text.
This defines the files of tangled code. 

@d Unit Test of OutputChunk subclass... @{
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
        self.assertTrue(self.theChunk.typeid.OutputChunk)
        self.assertFalse(self.theChunk.typeid.Chunk)

@}

The ``NamedDocumentChunk`` is a way to define substitutable text, similar to
tabled code, but it applies to document chunks. It's not clear how useful this really
is.

@d Unit Test of NamedDocumentChunk subclass... @{
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
        self.assertTrue(self.theChunk.typeid.NamedDocumentChunk)
        self.assertFalse(self.theChunk.typeid.OutputChunk)
@}

Command Tests
---------------

@d Unit Test of Command class hierarchy... @{ 
@<Unit Test of Command superclass@>
@<Unit Test of TextCommand class to contain a document text block@>
@<Unit Test of CodeCommand class to contain a program source code block@>
@<Unit Test of XrefCommand superclass for all cross-reference commands@>
@<Unit Test of FileXrefCommand class for an output file cross-reference@>
@<Unit Test of MacroXrefCommand class for a named chunk cross-reference@>
@<Unit Test of UserIdXrefCommand class for a user identifier cross-reference@>
@<Unit Test of ReferenceCommand class for chunk references@>
@}

This Command superclass is essentially an inteface definition, it
has no real testable features.

@d Unit Test of Command superclass... @{# No Tests@}

A ``TextCommand`` object must be built from source text, interrogated, and emitted.
A ``TextCommand`` should not (generally) be created in a ``Chunk``, it should
only be part of a ``NamedChunk`` or ``OutputChunk``.

@d Unit Test of TextCommand class... @{ 
class TestTextCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.TextCommand("Some text & words in the document\n    ", ("sample.w", 314))
        self.cmd2 = pyweb.TextCommand("No Indent\n", ("sample.w", 271))
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.TextCommand)
        self.assertEqual(4, self.cmd.indent())
        self.assertEqual(0, self.cmd2.indent())
        self.assertEqual(("sample.w", 314), self.cmd.location)
             
    def test_tangle_should_work(self) -> None:
        tnglr = MockTangler()
        self.cmd.tangle(tnglr, sentinel.TARGET)
        tnglr.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some text & words in the document\n    ')
@}

A ``CodeCommand`` object is a ``TextCommand`` with different processing for being emitted.
It represents a block of code in a ``NamedChunk`` or ``OutputChunk``. 

@d Unit Test of CodeCommand class... @{
class TestCodeCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.CodeCommand("Some code in the document\n    ", ("sample.w", 314))
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.CodeCommand)
        self.assertEqual(4, self.cmd.indent())
        self.assertEqual(("sample.w", 314), self.cmd.location)
             
    def test_tangle_should_work(self) -> None:
        tnglr = MockTangler()
        self.cmd.tangle(tnglr, sentinel.TARGET)
        tnglr.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some code in the document\n    ')
@}

An ``XrefCommand`` class (if defined) would be abstract. We could formalize this,
but it seems easier to have a collection of ``@@dataclass`` definitions a 
``Union[...]`` type hint.


@d Unit Test of XrefCommand superclass... @{# No Tests @}

The ``FileXrefCommand`` command is expanded by a weaver to a list of ``@@o``
locations.

@d Unit Test of FileXrefCommand class... @{ 
class TestFileXRefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.FileXrefCommand(("sample.w", 314))
        self.web = Mock(files=sentinel.FILES)
        self.cmd.web = Mock(return_value=self.web)
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.FileXrefCommand)
        self.assertEqual(0, self.cmd.indent())
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.FILES, self.cmd.files)
        
    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass
@}

The ``MacroXrefCommand`` command is expanded by a weaver to a list of all ``@@d``
locations.

@d Unit Test of MacroXrefCommand class... @{
class TestMacroXRefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.MacroXrefCommand(("sample.w", 314))
        self.web = Mock(macros=sentinel.MACROS)
        self.cmd.web = Mock(return_value=self.web)

    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.MacroXrefCommand)
        self.assertEqual(0, self.cmd.indent())
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.MACROS, self.cmd.macros)

    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass
@}

The ``UserIdXrefCommand`` command is expanded by a weaver to a list of all ``@@|``
names.

@d Unit Test of UserIdXrefCommand class... @{
class TestUserIdXrefCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.cmd = pyweb.UserIdXrefCommand(("sample.w", 314))
        self.web = Mock(userids=sentinel.USERIDS)
        self.cmd.web = Mock(return_value=self.web)

    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.UserIdXrefCommand)
        self.assertEqual(0, self.cmd.indent())
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.USERIDS, self.cmd.userids)
        
    def test_tangle_should_fail(self) -> None:
        tnglr = MockTangler()
        try:
            self.cmd.tangle(tnglr, sentinel.TARGET)
            self.fail()
        except pyweb.Error:
            pass
@}

Instances of the ``Reference`` command reflect ``@@< name @@>`` locations in code.
These require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled, since the expand to code that may (transitively) 
have more references to more code.

The document here is a mock-up of the following

..  parsed-literal::

    @@d name @@{ @@<Some Name@@> @@}
    
    @@d Some Name @@{ code @@}
    
This is a single Chunk with a reference to another Chunk.

The ``Web`` class ``__post_init__`` sets the references and referencedBy attributes of each Chunk.

@d Unit Test of ReferenceCommand class... @{ 
class TestReferenceCommand(unittest.TestCase):
    def setUp(self) -> None:
        self.chunk = MockChunk("name", 123, ("sample.w", 456))
        self.cmd = pyweb.ReferenceCommand("Some Name", ("sample.w", 314))
        self.chunk.commands = [self.cmd]
        self.referenced_chunk = Mock(seq=sentinel.SEQUENCE, references=1, referencedBy=self.chunk, commands=[Mock()])
        self.web = Mock(
            get_text=Mock(return_value=sentinel.TEXT),
            resolve_name=Mock(return_value=sentinel.FULL_NAME),
            resolve_chunk=Mock(return_value=[self.referenced_chunk])
        )
        self.cmd.web = Mock(return_value=self.web)
        
    def test_methods_should_work(self) -> None:
        self.assertTrue(self.cmd.typeid.ReferenceCommand)
        self.assertIsNone(self.cmd.indent())  # Depends on aTangler.lastIndent.
        self.assertEqual(("sample.w", 314), self.cmd.location)
        self.assertEqual(sentinel.TEXT, self.cmd.text)
        self.assertEqual(sentinel.FULL_NAME, self.cmd.full_name)
        self.assertEqual(sentinel.SEQUENCE, self.cmd.seq)

    def test_tangle_should_work(self) -> None:
        tnglr = MockTangler()
        self.cmd.tangle(tnglr, sentinel.TARGET)
        self.web.resolve_chunk.assert_called_once_with("Some Name")
        self.assertTrue(self.cmd.definition)
        self.assertEqual(1, self.referenced_chunk.references)
        self.referenced_chunk.commands[0].tangle.assert_called_once_with(tnglr, sentinel.TARGET)
@}

Reference Tests
----------------

The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.

The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.

The test fixture is this

..  parsed-literal::

    @@d main @@{ @@< parent @@> @@}
    
    @@d parent @@{ @@< sub @@> @@}
    
    @@d sub @@{ something @@}
    
The ``sub`` item is used by ``parent`` which is used by ``main``.

The simple reference is ``sub`` referenced by ``parent``.

The transitive references are ``sub`` referenced by ``parent`` which is referenced by ``main``.


@d Unit Test of Reference class hierarchy... @{ 
class TestReference(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.main = MockChunk("Main", 1, ("sample.w", 11))
        self.main.referencedBy = None
        self.parent = MockChunk("Parent", 2, ("sample.w", 11))
        self.parent.referencedBy = self.main
        self.chunk = MockChunk("Sub", 3, ("sample.w", 33))
        self.chunk.referencedBy = self.parent
        
    def test_simple_should_find_one(self) -> None:
        self.reference = pyweb.SimpleReference()
        theList = self.reference.chunkReferencedBy(self.chunk)
        self.assertEqual(1, len(theList))
        self.assertEqual(self.parent, theList[0])
        
    def test_transitive_should_find_all(self) -> None:
        self.reference = pyweb.TransitiveReference()
        theList = self.reference.chunkReferencedBy(self.chunk)
        self.assertEqual(2, len(theList))
        self.assertEqual(self.parent, theList[0])
        self.assertEqual(self.main, theList[1])
@}

Web Tests
-----------

We create a ``Web`` instance with mocked Chunks and mocked Commands.
The point is to test the ``Web`` features in isolation. This is tricky
because some state is recorded in the Chunk instances.

@d Unit Test of Web class... 
@{ 
class TestWebConstruction(unittest.TestCase):
    def setUp(self) -> None:
        self.c1 = MockChunk("c1", 1, ("sample.w", 11))
        self.c1.typeid = Mock(Chunk=True, OutputChunk=False, NamedChunk=False)
        self.c1.referencedBy = None
        self.c1.name = None
        self.c2 = MockChunk("c2", 2, ("sample.w", 22))
        self.c2.typeid = Mock(Chunk=False, OutputChunk=True, NamedChunk=False)
        self.c2.commands = [Mock()]
        self.c2.commands[0].name = "c3..."
        self.c2.commands[0].typeid = Mock(ReferenceCommand=True, TextCommand=False, CodeCommand=False)
        self.c2.referencedBy = None
        self.c3 = MockChunk("c3 has a long name", 3, ("sample.w", 33))
        self.c3.typeid = Mock(Chunk=False, OutputChunk=False, NamedChunk=True)
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
        self.assertEqual([], self.web.no_definition())
        
    def test_valid_web_should_tangle(self) -> None:
        """This is the entire interface used by tangling.
        The details are pushed down to ```command.tangle()`` for each command in each chunk.
        """
        self.assertEqual([self.c2], self.web.files)
        
    def test_valid_web_should_weave(self) -> None:
        """This is the entire interface used by tangling.
        The details are pushed down to unique processing based on ``chunk.typeid``.
        """
        self.assertEqual([self.c1, self.c2, self.c3], self.web.chunks)
@}



WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

We should test this through some clever mocks that produce the
proper sequence of tokens to parse the various kinds of Commands.

@d Unit Test of WebReader... @{
# Tested via functional tests
@}

Some lower-level units: specifically the tokenizer and the option parser.

@d Unit Test of WebReader... @{
class TestTokenizer(unittest.TestCase):
    def test_should_split_tokens(self) -> None:
        input = io.StringIO("@@@@ word @@{ @@[ @@< @@>\n@@] @@} @@i @@| @@m @@f @@u\n")
        self.tokenizer = pyweb.Tokenizer(input)
        tokens = list(self.tokenizer)
        self.assertEqual(24, len(tokens))
        self.assertEqual( ['@@@@', ' word ', '@@{', ' ', '@@[', ' ', '@@<', ' ', 
        '@@>', '\n', '@@]', ' ', '@@}', ' ', '@@i', ' ', '@@|', ' ', '@@m', ' ', 
        '@@f', ' ', '@@u', '\n'], tokens )
        self.assertEqual(2, self.tokenizer.lineNumber)
@}

@d Unit Test of WebReader... @{
class TestOptionParser_OutputChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.option_parser = pyweb.OptionParser(        
            pyweb.OptionDef("-start", nargs=1, default=None),
            pyweb.OptionDef("-end", nargs=1, default=""),
            pyweb.OptionDef("argument", nargs='*'),
        )
    def test_with_options_should_parse(self) -> None:
        text1 = " -start /* -end */ something.css "
        options1 = self.option_parser.parse(text1)
        self.assertEqual({'-end': ['*/'], '-start': ['/*'], 'argument': ['something.css']}, options1)
    def test_without_options_should_parse(self) -> None:
        text2 = " something.py "
        options2 = self.option_parser.parse(text2)
        self.assertEqual({'argument': ['something.py']}, options2)
        
class TestOptionParser_NamedChunk(unittest.TestCase):
    def setUp(self) -> None:
        self.option_parser = pyweb.OptionParser(        pyweb.OptionDef( "-indent", nargs=0),
        pyweb.OptionDef("-noindent", nargs=0),
        pyweb.OptionDef("argument", nargs='*'),
        )
    def test_with_options_should_parse(self) -> None:
        text1 = " -indent the name of test1 chunk... "
        options1 = self.option_parser.parse(text1)
        self.assertEqual({'-indent': [], 'argument': ['the', 'name', 'of', 'test1', 'chunk...']}, options1)
    def test_without_options_should_parse(self) -> None:
        text2 = " the name of test2 chunk... "
        options2 = self.option_parser.parse(text2)
        self.assertEqual({'argument': ['the', 'name', 'of', 'test2', 'chunk...']}, options2)
@}


Action Tests
-------------

Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  

@d Unit Test of Action class hierarchy... @{ 
@<Unit test of Action Sequence class@>
@<Unit test of LoadAction class@>
@<Unit test of TangleAction class@>
@<Unit test of WeaverAction class@>
@}

**TODO:** Replace with Mock

@d Unit test of Action Sequence class... @{
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
@}

@d Unit test of WeaverAction class... @{ 
class TestWeaveAction(unittest.TestCase):
    def setUp(self) -> None:
        self.web = MockWeb()
        self.action = pyweb.WeaveAction()
        self.weaver = MockWeaver()
        self.options = argparse.Namespace( 
            theWeaver=self.weaver,
            reference_style=pyweb.SimpleReference(),
            output=Path.cwd(),
            web=self.web,
            weaver='rst',
        )
    def test_should_execute_weaving(self) -> None:
        self.action(self.options)
        self.assertEqual(self.weaver.emit.mock_calls, [call(self.web)])
@}

@d Unit test of TangleAction class... @{ 
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
@}

The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.

@d Unit test of LoadAction class... @{ 
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
            command="@@",
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
        # Old: self.assertEqual(1, self.webReader.count)
        print(self.webReader.load.mock_calls)
        self.assertEqual(self.webReader.load.mock_calls, [call(self.source_path)])
        self.webReader.web.assert_not_called()  # Deprecated
        self.webReader.source.assert_not_called()  # Deprecated
@}

Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.

**TODO:** Test Application class

@d Unit Test of Application... @{# TODO Test Application class @}

Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.

@d Unit Test overheads...
@{"""Unit tests."""
import argparse
import io
import logging
import os
from pathlib import Path
import re
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
@}

One more overhead is a function we can inject into selected subclasses
of ``unittest.TestCase``. This is monkeypatch feature that seems useful.

@d Unit Test overheads...
@{
def rstrip_lines(source: str) -> list[str]:
    return list(l.rstrip() for l in source.splitlines())    
@}

@d Unit Test main...
@{
if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()
@}

We run the default ``unittest.main()`` to execute the entire suite of tests.