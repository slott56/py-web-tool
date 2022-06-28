############################################
pyWeb Literate Programming 3.2 - Test Suite
############################################    
    
    
=================================================
Yet Another Literate Programming Tool
=================================================

..	include:: <isoamsa.txt>
..	include:: <isopub.txt>

..	contents::


Introduction
============

..	test/intro.w 

There are two levels of testing in this document.

-	`Unit Testing`_

-	`Functional Testing`_

Other testing, like performance or security, is possible.
But for this application, not very interesting.

This doument builds a complete test suite, ``test.py``.

..	parsed-literal::

	MacBookPro-SLott:test slott$ python3.3 ../pyweb.py pyweb_test.w
	INFO:Application:Setting root log level to 'INFO'
	INFO:Application:Setting command character to '@'
	INFO:Application:Weaver RST
	INFO:Application:load, tangle and weave 'pyweb_test.w'
	INFO:LoadAction:Starting Load
	INFO:WebReader:Including 'intro.w'
	WARNING:WebReader:Unknown @-command in input: "@'"
	INFO:WebReader:Including 'unit.w'
	INFO:WebReader:Including 'func.w'
	INFO:WebReader:Including 'combined.w'
	INFO:TangleAction:Starting Tangle
	INFO:TanglerMake:Tangling 'test_unit.py'
	INFO:TanglerMake:No change to 'test_unit.py'
	INFO:TanglerMake:Tangling 'test_loader.py'
	INFO:TanglerMake:No change to 'test_loader.py'
	INFO:TanglerMake:Tangling 'test.py'
	INFO:TanglerMake:No change to 'test.py'
	INFO:TanglerMake:Tangling 'page-layout.css'
	INFO:TanglerMake:No change to 'page-layout.css'
	INFO:TanglerMake:Tangling 'docutils.conf'
	INFO:TanglerMake:No change to 'docutils.conf'
	INFO:TanglerMake:Tangling 'test_tangler.py'
	INFO:TanglerMake:No change to 'test_tangler.py'
	INFO:TanglerMake:Tangling 'test_weaver.py'
	INFO:TanglerMake:No change to 'test_weaver.py'
	INFO:WeaveAction:Starting Weave
	INFO:RST:Weaving 'pyweb_test.rst'
	INFO:RST:Wrote 3173 lines to 'pyweb_test.rst'
	INFO:WeaveAction:Finished Normally
	INFO:Application:Load 1911 lines from 5 files in 0.05 sec., Tangle 138 lines in 0.03 sec., Weave 3173 lines in 0.02 sec.
	MacBookPro-SLott:test slott$ PYTHONPATH=.. python3.3 test.py
	ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, ('@{', '@[') not found
	ERROR:WebReader:Errors in included file test8_inc.tmp, output is incomplete.
	.ERROR:WebReader:At ('test1.w', 8): expected ('@{',), found '@o'
	ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)
	ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)
	.............................................................................
	----------------------------------------------------------------------
	Ran 78 tests in 0.025s

	OK
	MacBookPro-SLott:test slott$ rst2html.py pyweb_test.rst pyweb_test.html


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


..  _`test_unit.py (1)`:
..  rubric:: test_unit.py (1) =
..  parsed-literal::
    :class: code

    →\ `Unit Test overheads: imports, etc. (42)`_    
    →\ `Unit Test of Emitter class hierarchy (2)`_    
    →\ `Unit Test of Chunk class hierarchy (10)`_    
    →\ `Unit Test of Command class hierarchy (22)`_    
    →\ `Unit Test of Reference class hierarchy (31)`_    
    →\ `Unit Test of Web class (32)`_    
    →\ `Unit Test of WebReader class (33)`_    
    →\ `Unit Test of Action class hierarchy (36)`_    
    →\ `Unit Test of Application class (41)`_    
    →\ `Unit Test main (44)`_    

..

..  class:: small

    ∎ *test_unit.py (1)*



Emitter Tests
-------------

The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.



..  _`Unit Test of Emitter class hierarchy (2)`:
..  rubric:: Unit Test of Emitter class hierarchy (2) =
..  parsed-literal::
    :class: code

    
    →\ `Unit Test Mock Chunk class (4)`_    
    →\ `Unit Test of Emitter Superclass (3)`_    
    →\ `Unit Test of Weaver subclass of Emitter (5)`_    
    →\ `Unit Test of LaTeX subclass of Emitter (6)`_    
    →\ `Unit Test of HTML subclass of Emitter (7)`_    
    →\ `Unit Test of Tangler subclass of Emitter (8)`_    
    →\ `Unit Test of TanglerMake subclass of Emitter (9)`_    

..

..  class:: small

    ∎ *Unit Test of Emitter class hierarchy (2)*



The Emitter superclass is designed to be extended.  The test 
creates a subclass to exercise a few key features. The default
emitter is Tangler-like.


..  _`Unit Test of Emitter Superclass (3)`:
..  rubric:: Unit Test of Emitter Superclass (3) =
..  parsed-literal::
    :class: code

         
    class EmitterExtension(pyweb.Emitter):    
        mock\_emit = Mock()    
        def emit(self, web: pyweb.Web) -> None:    
            self.mock\_emit(web)    
    
    class TestEmitter(unittest.TestCase):    
        def setUp(self) -> None:    
            self.output = Path("TestEmitter.out")    
            self.emitter = EmitterExtension(self.output)    
            self.web = Mock(name="mock web")    
        def test\_emitter\_should\_open\_close\_write(self) -> None:    
            self.emitter.emit(self.web)    
            self.emitter.mock\_emit.called\_once\_with(self.web)    
            self.assertEqual(self.emitter.output, self.output)    

..

..  class:: small

    ∎ *Unit Test of Emitter Superclass (3)*



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


..  _`Unit Test Mock Chunk class (4)`:
..  rubric:: Unit Test Mock Chunk class (4) =
..  parsed-literal::
    :class: code

    
    def mock\_chunk\_instance(name: str, seq: int, location: tuple[str, int]) -> Mock:    
        chunk = Mock(    
            wraps=pyweb.Chunk,    
            full\_name=name,    
            seq=seq,    
            location=location,    
            commands=[],    
            referencedBy=None,    
            references=0,    
            def\_names=[],    
            path=None,    
            tangle=Mock(),    
            # reference\_indent=Mock(),    
            # reference\_dedent=Mock(),    
        )    
        chunk.name = name    
        return chunk    
            
    MockChunk = Mock(    
        name="Chunk class",    
        side\_effect=mock\_chunk\_instance    
    )    
    
    def mock\_web() -> pyweb.Web:    
        def tangle\_method(aTangler: pyweb.Tangler, target: TextIO) -> None:    
            aTangler.codeBlock(target, "Mocked Tangle Output\\n")    
    
        mock\_file = Mock(full\_name="sample.out", seq=1)    
        mock\_file.name = "sample.out"    
        mock\_output = Mock(full\_name="named chunk", seq=2, def\_list=[3])    
        mock\_output.name = "named chunk"    
        mock\_uid\_1 = Mock(userid="user\_id\_1", ref\_list=[mock\_output])    
        mock\_uid\_2 = Mock(userid="user\_id\_2", ref\_list=[mock\_output])    
        mock\_ref = Mock(typeid=pyweb.TypeId(pyweb.ReferenceCommand), full\_name="named chunk", seq=42)    
        mock\_ref.name = "named..."    
        web = Mock(    
            name="mock web",    
            web\_path=Path("TestWeaver.w"),    
            chunks=[    
                Mock(    
                    name="mock Chunk",    
                    typeid=pyweb.TypeId(pyweb.Chunk),    
                    commands=[    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.TextCommand),    
                            text="text with \|char\| untouched.",    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.TextCommand),    
                            text="\\n",    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.FileXrefCommand),    
                            location=1,    
                            files=[mock\_file],    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.TextCommand),    
                            text="\\n",    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.MacroXrefCommand),    
                            location=2,    
                            macros=[mock\_output],    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.TextCommand),    
                            text="\\n",    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.UserIdXrefCommand),    
                            location=3,    
                            userids=[mock\_uid\_1, mock\_uid\_2]    
                        ),    
                    ],    
                ),    
                Mock(    
                    name="mock OutputChunk",    
                    typeid=pyweb.TypeId(pyweb.OutputChunk),    
                    seq=42,    
                    full\_name="sample.out",    
                    commands=[    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.CodeCommand),    
                            text="\|char\| \`code\` \*em\* \_em\_",    
                            tangle=Mock(side\_effect=tangle\_method),    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.CodeCommand),    
                            text="\\n",    
                            tangle=Mock(),    
                        ),    
                        mock\_ref,    
                    ],    
                    def\_names = ["some\_name"],    
                ),    
                Mock(    
                    name="mock NamedChunk",    
                    typeid=pyweb.TypeId(pyweb.NamedChunk),    
                    seq=42,    
                    full\_name="named chunk",    
                    commands=[    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.CodeCommand),    
                            text="\|char\| \`code\` \*em\* \_em\_",    
                        ),    
                        Mock(    
                            typeid=pyweb.TypeId(pyweb.CodeCommand),    
                            text="\\n",    
                            tangle=Mock(),    
                        ),    
                    ],    
                    def\_names = ["another\_name"]    
                ),    
            ],    
        )    
        web.chunks[1].name="sample.out"    
        web.chunks[2].name="named..."    
        web.files = [web.chunks[1]]    
        return web    

..

..  class:: small

    ∎ *Unit Test Mock Chunk class (4)*



The default Weaver is an Emitter that uses templates to produce RST markup.


..  _`Unit Test of Weaver subclass of Emitter (5)`:
..  rubric:: Unit Test of Weaver subclass of Emitter (5) =
..  parsed-literal::
    :class: code

    
    def test\_rst\_quote\_rules():    
        assert pyweb.rst\_quote\_rules("\|char\| \`code\` \*em\* \_em\_") == r"\\\|char\\\| \\\`code\\\` \\\*em\\\* \\\_em\\\_"    
    
    def test\_html\_quote\_rules():    
        assert pyweb.html\_quote\_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"    
    
    
    class TestWeaver(unittest.TestCase):    
        def setUp(self) -> None:    
            self.filepath = Path.cwd()    
            self.weaver = pyweb.Weaver(self.filepath)    
            self.weaver.set\_markup("rst")    
            self.weaver.reference\_style = pyweb.SimpleReference()    
            self.output\_path = self.filepath / "TestWeaver.rst"    
            self.web = mock\_web()    
                
        def tearDown(self) -> None:    
            try:    
                self.output\_path.unlink()    
            except OSError:    
                pass    
                
        def test\_weaver\_functions\_generic(self) -> None:    
            self.weaver.emit(self.web)    
            result = self.output\_path.read\_text()    
            expected = ('text with \|char\| untouched.\\n'    
                 ':sample.out:\\n'    
                 '    →\\\\ \`sample.out (1)\`\_\\n'    
                 ':named chunk:\\n'    
                 '    →\\\\ \` ()\`\_\\n'    
                 '\\n'    
                 '\\n'    
                 ':user\_id\_1:\\n'    
                 '    →\\\\ \`named chunk (2)\`\_\\n'    
                 '\\n'    
                 ':user\_id\_2:\\n'    
                 '    →\\\\ \`named chunk (2)\`\_\\n'    
                 '\\n'    
                 '\\n'    
                '..  \_\`sample.out (42)\`:\\n'    
                '..  rubric:: sample.out (42) =\\n'    
                '..  parsed-literal::\\n'    
                '    :class: code\\n'    
                '\\n'    
                '    \\\\\|char\\\\\| \\\\\`code\\\\\` \\\\\*em\\\\\* \\\\\_em\\\\\_    \\n'    
                '    →\\\\ \`named chunk (42)\`\_\\n'    
                '..\\n'    
                '\\n'    
                '..  class:: small\\n'    
                '\\n'    
                '    ∎ \*sample.out (42)\*\\n'    
                '\\n'    
                '\\n'    
                '..  \_\`named chunk (42)\`:\\n'    
                '..  rubric:: named chunk (42) =\\n'    
                '..  parsed-literal::\\n'    
                '    :class: code\\n'    
                '\\n'    
                '    \\\\\|char\\\\\| \\\\\`code\\\\\` \\\\\*em\\\\\* \\\\\_em\\\\\_    \\n'    
                '\\n'    
                '..\\n'    
                '\\n'    
                '..  class:: small\\n'    
                '\\n'    
                '    ∎ \*named chunk (42)\*\\n'    
                '\\n')    
            self.assertEqual(expected, result)    

..

..  class:: small

    ∎ *Unit Test of Weaver subclass of Emitter (5)*



A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.

We'll examine a few features of the LaTeX templates.


..  _`Unit Test of LaTeX subclass of Emitter (6)`:
..  rubric:: Unit Test of LaTeX subclass of Emitter (6) =
..  parsed-literal::
    :class: code

         
    class TestLaTeX(unittest.TestCase):    
        def setUp(self) -> None:    
            self.weaver = pyweb.Weaver()    
            self.weaver.set\_markup("tex")    
            self.weaver.reference\_style = pyweb.SimpleReference()     
            self.filepath = Path("testweaver")     
            self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))    
            self.aFileChunk.referencedBy = [ ]    
            self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))    
            self.aChunk.referencedBy = [self.aFileChunk,]    
            self.aChunk.references = [(self.aFileChunk.name, self.aFileChunk.seq)]    
    
        def tearDown(self) -> None:    
            try:    
                self.filepath.with\_suffix(".tex").unlink()    
            except OSError:    
                pass    
                    
        def test\_weaver\_functions\_latex(self) -> None:    
            result = pyweb.latex\_quote\_rules("\\\\end{Verbatim}")    
            self.assertEqual("\\\\end\\\\,{Verbatim}", result)    
            web = Mock(chunks=[self.aChunk])    
            result = list(self.weaver.generate\_text(web))    
            expected = [    
                '\\n'    
                '\\\\label{pyweb-314}\\n'    
                '\\\\begin{flushleft}\\n'    
                '\\\\textit{Code example Chunk (314)}\\n'    
                '\\\\begin{Verbatim}[commandchars=\\\\\\\\\\\\{\\\\},codes={\\\\catcode\`$$=3\\\\catcode\`^=7},frame=single]',    
                '\\n'    
                '\\\\end{Verbatim}\\n'    
                '\\\\end{flushleft}\\n'    
            ]    
            self.assertEqual(expected, result)    

..

..  class:: small

    ∎ *Unit Test of LaTeX subclass of Emitter (6)*



We'll examine a few features of the HTML templates.


..  _`Unit Test of HTML subclass of Emitter (7)`:
..  rubric:: Unit Test of HTML subclass of Emitter (7) =
..  parsed-literal::
    :class: code

         
    class TestHTML(unittest.TestCase):    
        def setUp(self) -> None:    
            self.weaver = pyweb.Weaver( )    
            self.weaver.set\_markup("html")    
            self.weaver.reference\_style = pyweb.SimpleReference()     
            self.filepath = Path("testweaver")     
            self.aFileChunk = MockChunk("File", 123, ("sample.w", 456))    
            self.aFileChunk.referencedBy = []    
            self.aChunk = MockChunk("Chunk", 314, ("sample.w", 789))    
            self.aChunk.referencedBy = [self.aFileChunk,]    
            self.aChunk.references = [(self.aFileChunk.name, self.aFileChunk.seq)]    
    
        def tearDown(self) -> None:    
            try:    
                self.filepath.with\_suffix(".html").unlink()    
            except OSError:    
                pass    
                    
        def test\_weaver\_functions\_html(self) -> None:    
            result = pyweb.html\_quote\_rules("a < b && c > d")    
            self.assertEqual("a &lt; b &amp;&amp; c &gt; d", result)    
            web = Mock(chunks=[self.aChunk])    
            result = list(self.weaver.generate\_text(web))    
            expected = [    
                '\\n'    
                '<a name="pyweb\_314"></a>\\n'    
                "<!--line number ('sample.w', 789)-->\\n"    
                '<p><em>Chunk (314)</em> =</p>\\n'    
                '<pre><code>',    
                 '\\n'    
                 '</code></pre>\\n'    
                 '<p>&#8718; <em>Chunk (314)</em>.\\n'    
                 '</p> \\n'    
            ]    
            self.assertEqual(expected, result)    
    

..

..  class:: small

    ∎ *Unit Test of HTML subclass of Emitter (7)*



A Tangler emits the various named source files in proper format for the desired
compiler and language.


..  _`Unit Test of Tangler subclass of Emitter (8)`:
..  rubric:: Unit Test of Tangler subclass of Emitter (8) =
..  parsed-literal::
    :class: code

         
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
                        
        def test\_tangler\_should\_codeBlock(self) -> None:    
            target = io.StringIO()    
            self.tangler.codeBlock(target, "Some")    
            self.tangler.codeBlock(target, " Code")    
            self.tangler.codeBlock(target, "\\n")    
            output = target.getvalue()    
            self.assertEqual("Some Code\\n", output)    
                
        def test\_tangler\_should\_indent(self) -> None:    
            target = io.StringIO()    
            self.tangler.codeBlock(target, "Begin")    
            self.tangler.codeBlock(target, "\\n")    
            self.tangler.addIndent(4)    
            self.tangler.codeBlock(target, "More Code")    
            self.tangler.codeBlock(target, "\\n")    
            self.tangler.clrIndent()    
            self.tangler.codeBlock(target, "End")    
            self.tangler.codeBlock(target, "\\n")    
            output = target.getvalue()    
            self.assertEqual("Begin\\n    More Code\\nEnd\\n", output)    
                
        def test\_tangler\_should\_noindent(self) -> None:    
            target = io.StringIO()    
            self.tangler.codeBlock(target, "Begin")    
            self.tangler.codeBlock(target, "\\n")    
            self.tangler.setIndent(0)    
            self.tangler.codeBlock(target, "More Code")    
            self.tangler.codeBlock(target, "\\n")    
            self.tangler.clrIndent()    
            self.tangler.codeBlock(target, "End")    
            self.tangler.codeBlock(target, "\\n")    
            output = target.getvalue()    
            self.assertEqual("Begin\\nMore Code\\nEnd\\n", output)    

..

..  class:: small

    ∎ *Unit Test of Tangler subclass of Emitter (8)*



A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.





..  _`Unit Test of TanglerMake subclass of Emitter (9)`:
..  rubric:: Unit Test of TanglerMake subclass of Emitter (9) =
..  parsed-literal::
    :class: code

    
    class TestTanglerMake(unittest.TestCase):    
        def setUp(self) -> None:    
            self.filepath = Path.cwd()    
            self.tangler = pyweb.TanglerMake()    
            self.web = mock\_web()    
            self.output = self.filepath / "sample.out"    
            self.tangler.emit(self.web)    
            self.time\_original = self.output.stat().st\_mtime    
            self.original = self.output.stat()    
                
        def tearDown(self) -> None:    
            try:    
                self.output.unlink()    
            except OSError:    
                pass    
                
        def test\_confirm\_tanged\_output(self) -> None:    
            tangled = self.output.read\_text()    
            expected = (    
                'Mocked Tangle Output\\n'    
            )    
            self.assertEqual(expected, tangled)    
                
                
        def test\_same\_should\_leave(self) -> None:    
            self.tangler.emit(self.web)    
            self.assertTrue(os.path.samestat(self.original, self.output.stat()))    
            #self.assertEqual(self.time\_original, self.output.stat().st\_mtime)    
                
        def test\_different\_should\_update(self) -> None:    
            # Modify the web in some way to create a distinct value.    
            def tangle\_method(aTangler: pyweb.Tangler, target: TextIO) -> None:    
                aTangler.codeBlock(target, "Updated Tangle Output\\n")    
            self.web.chunks[1].commands[0].tangle = Mock(side\_effect=tangle\_method)     
            self.tangler.emit(self.web)    
            print(self.output.read\_text())    
            self.assertFalse(os.path.samestat(self.original, self.output.stat()))    
            #self.assertNotEqual(self.time\_original, self.output.stat().st\_mtime)    

..

..  class:: small

    ∎ *Unit Test of TanglerMake subclass of Emitter (9)*



Chunk Tests
------------

The Chunk and Command class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.



..  _`Unit Test of Chunk class hierarchy (10)`:
..  rubric:: Unit Test of Chunk class hierarchy (10) =
..  parsed-literal::
    :class: code

    
    →\ `Unit Test of Chunk superclass (11)`_    
    →\ `Unit Test of NamedChunk subclass (18)`_    
    →\ `Unit Test of NamedChunk_Noindent subclass (19)`_    
    →\ `Unit Test of OutputChunk subclass (20)`_    
    →\ `Unit Test of NamedDocumentChunk subclass (21)`_    

..

..  class:: small

    ∎ *Unit Test of Chunk class hierarchy (10)*



In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
mock objects for all of these relationships in which a Chunk participates.

A MockCommand can be attached to a Chunk.


..  _`Unit Test of Chunk superclass (11)`:
..  rubric:: Unit Test of Chunk superclass (11) =
..  parsed-literal::
    :class: code

    
    MockCommand = Mock(    
        name="Command class",    
        side\_effect=lambda: Mock(    
            name="Command instance",    
            # text="",  # Only used for TextCommand.    
            lineNumber=314,    
            startswith=Mock(return\_value=False)    
        )    
    )    

..

..  class:: small

    ∎ *Unit Test of Chunk superclass (11)*



A MockWeb can contain a Chunk.


..  _`Unit Test of Chunk superclass (12)`:
..  rubric:: Unit Test of Chunk superclass (12) +=
..  parsed-literal::
    :class: code

    
    
    def mock\_web\_instance() -> Mock:    
        web = Mock(    
            name="Web instance",    
            chunks=[],    
            # add=Mock(return\_value=None),    
            # addNamed=Mock(return\_value=None),    
            # addOutput=Mock(return\_value=None),    
            fullNameFor=Mock(side\_effect=lambda name: name),    
            fileXref=Mock(return\_value={'file': [1,2,3]}),    
            chunkXref=Mock(return\_value={'chunk': [4,5,6]}),    
            userNamesXref=Mock(return\_value={'name': (7, [8,9,10])}),    
            # getchunk=Mock(side\_effect=lambda name: [MockChunk(name, 1, ("sample.w", 314))]),    
            createUsedBy=Mock(),    
            weaveChunk=Mock(side\_effect=lambda name, weaver: weaver.write(name)),    
            weave=Mock(return\_value=None),    
            tangle=Mock(return\_value=None),    
        )    
        return web    
    
    MockWeb = Mock(    
        name="Web class",    
        side\_effect=mock\_web\_instance,    
        file\_path="sample.input",    
    )    

..

..  class:: small

    ∎ *Unit Test of Chunk superclass (12)*



A MockWeaver or MockTangler appear to process a Chunk.
We can interrogate the ``mock_calls`` to be sure the right things were done.

We need to permit ``__enter__()`` and ``__exit__()``,
which leads to a multi-step instance.
The initial instance with ``__enter__()`` that
returns the context manager instance.



..  _`Unit Test of Chunk superclass (13)`:
..  rubric:: Unit Test of Chunk superclass (13) +=
..  parsed-literal::
    :class: code

    
    def mock\_weaver\_instance() -> MagicMock:    
        context = MagicMock(    
            name="Weaver instance context",    
            \_\_exit\_\_=Mock()    
        )    
            
        weaver = MagicMock(    
            name="Weaver instance",    
            quote=Mock(return\_value="quoted"),    
            \_\_enter\_\_=Mock(return\_value=context)    
        )    
        return weaver    
    
    MockWeaver = Mock(    
        name="Weaver class",    
        side\_effect=mock\_weaver\_instance    
    )    
    
    def mock\_tangler\_instance() -> MagicMock:    
        context = MagicMock(    
            name="Tangler instance context",    
            \_\_exit\_\_=Mock()    
        )    
            
        tangler = MagicMock(    
            name="Tangler instance",    
            \_\_enter\_\_=Mock(return\_value=context)    
        )    
        return tangler    
    
    MockTangler = Mock(    
        name="Tangler class",    
        side\_effect=mock\_tangler\_instance    
    )    
    

..

..  class:: small

    ∎ *Unit Test of Chunk superclass (13)*



A Chunk is built, interrogated and then emitted.


..  _`Unit Test of Chunk superclass (14)`:
..  rubric:: Unit Test of Chunk superclass (14) +=
..  parsed-literal::
    :class: code

    
    class TestChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.theChunk = pyweb.Chunk()    
                
            →\ `Unit Test of Chunk construction (15)`_    
            
            →\ `Unit Test of Chunk interrogation (16)`_    
            
            →\ `Unit Test of Chunk properties (17)`_    

..

..  class:: small

    ∎ *Unit Test of Chunk superclass (14)*



Can we build a Chunk?


..  _`Unit Test of Chunk construction (15)`:
..  rubric:: Unit Test of Chunk construction (15) =
..  parsed-literal::
    :class: code

    
    def test\_append\_command\_should\_work(self) -> None:    
        cmd1 = MockCommand()    
        self.theChunk.commands.append(cmd1)    
        self.assertEqual(1, len(self.theChunk.commands))    
        self.assertEqual([cmd1], self.theChunk.commands)    
            
        cmd2 = MockCommand()    
        self.theChunk.commands.append(cmd2)    
        self.assertEqual(2, len(self.theChunk.commands))    
        self.assertEqual([cmd1, cmd2], self.theChunk.commands)    

..

..  class:: small

    ∎ *Unit Test of Chunk construction (15)*



Can we interrogate a Chunk?


..  _`Unit Test of Chunk interrogation (16)`:
..  rubric:: Unit Test of Chunk interrogation (16) =
..  parsed-literal::
    :class: code

    
    def test\_lineNumber\_should\_work(self) -> None:    
        cmd1 = MockCommand()    
        self.theChunk.commands.append(cmd1)    
        self.assertEqual(314, self.theChunk.commands[0].lineNumber)    

..

..  class:: small

    ∎ *Unit Test of Chunk interrogation (16)*



Can we emit a Chunk with a weaver or tangler?


..  _`Unit Test of Chunk properties (17)`:
..  rubric:: Unit Test of Chunk properties (17) =
..  parsed-literal::
    :class: code

    
    def test\_properties(self) -> None:    
        web = MockWeb()    
        self.theChunk.web = Mock(return\_value=web)    
        self.theChunk.full\_name    
        web.resolve\_name.assert\_called\_once\_with(self.theChunk.name)    
        self.assertIsNone(self.theChunk.path)    
        self.assertTrue(self.theChunk.typeid.Chunk)    
        self.assertFalse(self.theChunk.typeid.OutputChunk)    

..

..  class:: small

    ∎ *Unit Test of Chunk properties (17)*



The ``NamedChunk`` is created by a ``@d`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`Unit Test of NamedChunk subclass (18)`:
..  rubric:: Unit Test of NamedChunk subclass (18) =
..  parsed-literal::
    :class: code

         
    class TestNamedChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.theChunk = pyweb.NamedChunk(name="Some Name...")    
            cmd = MockCommand()    
            self.theChunk.commands.append(cmd)    
            self.theChunk.def\_names = ["index", "terms"]    
                
        def test\_should\_find\_xref\_words(self) -> None:    
            self.assertEqual(2, len(self.theChunk.def\_names))    
            self.assertEqual({"index", "terms"}, set(self.theChunk.def\_names))    
                
        def test\_properties(self) -> None:    
            web = MockWeb()    
            self.theChunk.web = Mock(return\_value=web)    
            self.theChunk.full\_name    
            web.resolve\_name.assert\_called\_once\_with(self.theChunk.name)    
            self.assertIsNone(self.theChunk.path)    
            self.assertTrue(self.theChunk.typeid.NamedChunk)    
            self.assertFalse(self.theChunk.typeid.OutputChunk)    
            self.assertFalse(self.theChunk.typeid.Chunk)    

..

..  class:: small

    ∎ *Unit Test of NamedChunk subclass (18)*




..  _`Unit Test of NamedChunk_Noindent subclass (19)`:
..  rubric:: Unit Test of NamedChunk_Noindent subclass (19) =
..  parsed-literal::
    :class: code

    
    class TestNamedChunk\_Noindent(unittest.TestCase):    
        def setUp(self) -> None:    
            self.theChunk = pyweb.NamedChunk("NoIndent Name...", options="-noindent")    
            cmd = MockCommand()    
            self.theChunk.commands.append(cmd)    
            self.theChunk.def\_names = ["index", "terms"]    
    
        def test\_should\_find\_xref\_words(self) -> None:    
            self.assertEqual(2, len(self.theChunk.def\_names))    
            self.assertEqual({"index", "terms"}, set(self.theChunk.def\_names))    
                
        def test\_properties(self) -> None:    
            web = MockWeb()    
            self.theChunk.web = Mock(return\_value=web)    
            self.theChunk.full\_name    
            web.resolve\_name.assert\_called\_once\_with(self.theChunk.name)    
            self.assertIsNone(self.theChunk.path)    
            self.assertTrue(self.theChunk.typeid.NamedChunk)    
            self.assertFalse(self.theChunk.typeid.Chunk)    

..

..  class:: small

    ∎ *Unit Test of NamedChunk_Noindent subclass (19)*




The ``OutputChunk`` is created by a ``@o`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks of text.
This defines the files of tangled code. 


..  _`Unit Test of OutputChunk subclass (20)`:
..  rubric:: Unit Test of OutputChunk subclass (20) =
..  parsed-literal::
    :class: code

    
    class TestOutputChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.theChunk = pyweb.OutputChunk("filename.out")    
            self.theChunk.comment\_start = "# "    
            self.theChunk.comment\_end = ""    
            cmd = MockCommand()    
            self.theChunk.commands.append(cmd)    
            self.theChunk.def\_names = ["index", "terms"]    
                
        def test\_should\_find\_xref\_words(self) -> None:    
            self.assertEqual(2, len(self.theChunk.def\_names))    
            self.assertEqual({"index", "terms"}, set(self.theChunk.def\_names))    
                
        def test\_properties(self) -> None:    
            web = MockWeb()    
            self.theChunk.web = Mock(return\_value=web)    
            self.assertIsNone(self.theChunk.full\_name)    
            web.resolve\_name.assert\_not\_called()    
            self.assertEqual(self.theChunk.path, Path("filename.out"))    
            self.assertTrue(self.theChunk.typeid.OutputChunk)    
            self.assertFalse(self.theChunk.typeid.Chunk)    
    

..

..  class:: small

    ∎ *Unit Test of OutputChunk subclass (20)*



The ``NamedDocumentChunk`` is a way to define substitutable text, similar to
tabled code, but it applies to document chunks. It's not clear how useful this really
is.


..  _`Unit Test of NamedDocumentChunk subclass (21)`:
..  rubric:: Unit Test of NamedDocumentChunk subclass (21) =
..  parsed-literal::
    :class: code

    
    class TestNamedDocumentChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.theChunk = pyweb.NamedDocumentChunk("Document Chunk Name...")    
            cmd = MockCommand()    
            self.theChunk.commands.append(cmd)    
            self.theChunk.def\_names = ["index", "terms"]    
    
        def test\_should\_find\_xref\_words(self) -> None:    
            self.assertEqual(2, len(self.theChunk.def\_names))    
            self.assertEqual({"index", "terms"}, set(self.theChunk.def\_names))    
                
        def test\_properties(self) -> None:    
            web = MockWeb()    
            self.theChunk.web = Mock(return\_value=web)    
            self.theChunk.full\_name    
            web.resolve\_name.assert\_called\_once\_with(self.theChunk.name)    
            self.assertIsNone(self.theChunk.path)    
            self.assertTrue(self.theChunk.typeid.NamedDocumentChunk)    
            self.assertFalse(self.theChunk.typeid.OutputChunk)    

..

..  class:: small

    ∎ *Unit Test of NamedDocumentChunk subclass (21)*



Command Tests
---------------


..  _`Unit Test of Command class hierarchy (22)`:
..  rubric:: Unit Test of Command class hierarchy (22) =
..  parsed-literal::
    :class: code

         
    →\ `Unit Test of Command superclass (23)`_    
    →\ `Unit Test of TextCommand class to contain a document text block (24)`_    
    →\ `Unit Test of CodeCommand class to contain a program source code block (25)`_    
    →\ `Unit Test of XrefCommand superclass for all cross-reference commands (26)`_    
    →\ `Unit Test of FileXrefCommand class for an output file cross-reference (27)`_    
    →\ `Unit Test of MacroXrefCommand class for a named chunk cross-reference (28)`_    
    →\ `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29)`_    
    →\ `Unit Test of ReferenceCommand class for chunk references (30)`_    

..

..  class:: small

    ∎ *Unit Test of Command class hierarchy (22)*



This Command superclass is essentially an inteface definition, it
has no real testable features.


..  _`Unit Test of Command superclass (23)`:
..  rubric:: Unit Test of Command superclass (23) =
..  parsed-literal::
    :class: code

    # No Tests
..

..  class:: small

    ∎ *Unit Test of Command superclass (23)*



A ``TextCommand`` object must be built from source text, interrogated, and emitted.
A ``TextCommand`` should not (generally) be created in a ``Chunk``, it should
only be part of a ``NamedChunk`` or ``OutputChunk``.


..  _`Unit Test of TextCommand class to contain a document text block (24)`:
..  rubric:: Unit Test of TextCommand class to contain a document text block (24) =
..  parsed-literal::
    :class: code

         
    class TestTextCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.cmd = pyweb.TextCommand("Some text & words in the document\\n    ", ("sample.w", 314))    
            self.cmd2 = pyweb.TextCommand("No Indent\\n", ("sample.w", 271))    
                
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.TextCommand)    
            self.assertEqual(4, self.cmd.indent())    
            self.assertEqual(0, self.cmd2.indent())    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
                     
        def test\_tangle\_should\_work(self) -> None:    
            tnglr = MockTangler()    
            self.cmd.tangle(tnglr, sentinel.TARGET)    
            tnglr.codeBlock.assert\_called\_once\_with(sentinel.TARGET, 'Some text & words in the document\\n    ')    

..

..  class:: small

    ∎ *Unit Test of TextCommand class to contain a document text block (24)*



A ``CodeCommand`` object is a ``TextCommand`` with different processing for being emitted.
It represents a block of code in a ``NamedChunk`` or ``OutputChunk``. 


..  _`Unit Test of CodeCommand class to contain a program source code block (25)`:
..  rubric:: Unit Test of CodeCommand class to contain a program source code block (25) =
..  parsed-literal::
    :class: code

    
    class TestCodeCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.cmd = pyweb.CodeCommand("Some code in the document\\n    ", ("sample.w", 314))    
                
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.CodeCommand)    
            self.assertEqual(4, self.cmd.indent())    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
                     
        def test\_tangle\_should\_work(self) -> None:    
            tnglr = MockTangler()    
            self.cmd.tangle(tnglr, sentinel.TARGET)    
            tnglr.codeBlock.assert\_called\_once\_with(sentinel.TARGET, 'Some code in the document\\n    ')    

..

..  class:: small

    ∎ *Unit Test of CodeCommand class to contain a program source code block (25)*



An ``XrefCommand`` class (if defined) would be abstract. We could formalize this,
but it seems easier to have a collection of ``@dataclass`` definitions a 
``Union[...]`` type hint.



..  _`Unit Test of XrefCommand superclass for all cross-reference commands (26)`:
..  rubric:: Unit Test of XrefCommand superclass for all cross-reference commands (26) =
..  parsed-literal::
    :class: code

    # No Tests 
..

..  class:: small

    ∎ *Unit Test of XrefCommand superclass for all cross-reference commands (26)*



The ``FileXrefCommand`` command is expanded by a weaver to a list of ``@o``
locations.


..  _`Unit Test of FileXrefCommand class for an output file cross-reference (27)`:
..  rubric:: Unit Test of FileXrefCommand class for an output file cross-reference (27) =
..  parsed-literal::
    :class: code

         
    class TestFileXRefCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.cmd = pyweb.FileXrefCommand(("sample.w", 314))    
            self.web = Mock(files=sentinel.FILES)    
            self.cmd.web = Mock(return\_value=self.web)    
                
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.FileXrefCommand)    
            self.assertEqual(0, self.cmd.indent())    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
            self.assertEqual(sentinel.FILES, self.cmd.files)    
                
        def test\_tangle\_should\_fail(self) -> None:    
            tnglr = MockTangler()    
            try:    
                self.cmd.tangle(tnglr, sentinel.TARGET)    
                self.fail()    
            except pyweb.Error:    
                pass    

..

..  class:: small

    ∎ *Unit Test of FileXrefCommand class for an output file cross-reference (27)*



The ``MacroXrefCommand`` command is expanded by a weaver to a list of all ``@d``
locations.


..  _`Unit Test of MacroXrefCommand class for a named chunk cross-reference (28)`:
..  rubric:: Unit Test of MacroXrefCommand class for a named chunk cross-reference (28) =
..  parsed-literal::
    :class: code

    
    class TestMacroXRefCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.cmd = pyweb.MacroXrefCommand(("sample.w", 314))    
            self.web = Mock(macros=sentinel.MACROS)    
            self.cmd.web = Mock(return\_value=self.web)    
    
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.MacroXrefCommand)    
            self.assertEqual(0, self.cmd.indent())    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
            self.assertEqual(sentinel.MACROS, self.cmd.macros)    
    
        def test\_tangle\_should\_fail(self) -> None:    
            tnglr = MockTangler()    
            try:    
                self.cmd.tangle(tnglr, sentinel.TARGET)    
                self.fail()    
            except pyweb.Error:    
                pass    

..

..  class:: small

    ∎ *Unit Test of MacroXrefCommand class for a named chunk cross-reference (28)*



The ``UserIdXrefCommand`` command is expanded by a weaver to a list of all ``@|``
names.


..  _`Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29)`:
..  rubric:: Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29) =
..  parsed-literal::
    :class: code

    
    class TestUserIdXrefCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.cmd = pyweb.UserIdXrefCommand(("sample.w", 314))    
            self.web = Mock(userids=sentinel.USERIDS)    
            self.cmd.web = Mock(return\_value=self.web)    
    
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.UserIdXrefCommand)    
            self.assertEqual(0, self.cmd.indent())    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
            self.assertEqual(sentinel.USERIDS, self.cmd.userids)    
                
        def test\_tangle\_should\_fail(self) -> None:    
            tnglr = MockTangler()    
            try:    
                self.cmd.tangle(tnglr, sentinel.TARGET)    
                self.fail()    
            except pyweb.Error:    
                pass    

..

..  class:: small

    ∎ *Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29)*



Instances of the ``Reference`` command reflect ``@< name @>`` locations in code.
These require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled, since the expand to code that may (transitively) 
have more references to more code.

The document here is a mock-up of the following

..  parsed-literal::

    @d name @{ @<Some Name@> @}
    
    @d Some Name @{ code @}
    
This is a single Chunk with a reference to another Chunk.

The ``Web`` class ``__post_init__`` sets the references and referencedBy attributes of each Chunk.


..  _`Unit Test of ReferenceCommand class for chunk references (30)`:
..  rubric:: Unit Test of ReferenceCommand class for chunk references (30) =
..  parsed-literal::
    :class: code

         
    class TestReferenceCommand(unittest.TestCase):    
        def setUp(self) -> None:    
            self.chunk = MockChunk("name", 123, ("sample.w", 456))    
            self.cmd = pyweb.ReferenceCommand("Some Name", ("sample.w", 314))    
            self.chunk.commands = [self.cmd]    
            self.referenced\_chunk = Mock(seq=sentinel.SEQUENCE, references=1, referencedBy=self.chunk, commands=[Mock()])    
            self.web = Mock(    
                get\_text=Mock(return\_value=sentinel.TEXT),    
                resolve\_name=Mock(return\_value=sentinel.FULL\_NAME),    
                resolve\_chunk=Mock(return\_value=[self.referenced\_chunk])    
            )    
            self.cmd.web = Mock(return\_value=self.web)    
                
        def test\_methods\_should\_work(self) -> None:    
            self.assertTrue(self.cmd.typeid.ReferenceCommand)    
            self.assertIsNone(self.cmd.indent())  # Depends on aTangler.lastIndent.    
            self.assertEqual(("sample.w", 314), self.cmd.location)    
            self.assertEqual(sentinel.TEXT, self.cmd.text)    
            self.assertEqual(sentinel.FULL\_NAME, self.cmd.full\_name)    
            self.assertEqual(sentinel.SEQUENCE, self.cmd.seq)    
    
        def test\_tangle\_should\_work(self) -> None:    
            tnglr = MockTangler()    
            self.cmd.tangle(tnglr, sentinel.TARGET)    
            self.web.resolve\_chunk.assert\_called\_once\_with("Some Name")    
            self.assertTrue(self.cmd.definition)    
            self.assertEqual(1, self.referenced\_chunk.references)    
            self.referenced\_chunk.commands[0].tangle.assert\_called\_once\_with(tnglr, sentinel.TARGET)    

..

..  class:: small

    ∎ *Unit Test of ReferenceCommand class for chunk references (30)*



Reference Tests
----------------

The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.

The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.

The test fixture is this

..  parsed-literal::

    @d main @{ @< parent @> @}
    
    @d parent @{ @< sub @> @}
    
    @d sub @{ something @}
    
The ``sub`` item is used by ``parent`` which is used by ``main``.

The simple reference is ``sub`` referenced by ``parent``.

The transitive references are ``sub`` referenced by ``parent`` which is referenced by ``main``.



..  _`Unit Test of Reference class hierarchy (31)`:
..  rubric:: Unit Test of Reference class hierarchy (31) =
..  parsed-literal::
    :class: code

         
    class TestReference(unittest.TestCase):    
        def setUp(self) -> None:    
            self.web = MockWeb()    
            self.main = MockChunk("Main", 1, ("sample.w", 11))    
            self.main.referencedBy = None    
            self.parent = MockChunk("Parent", 2, ("sample.w", 11))    
            self.parent.referencedBy = self.main    
            self.chunk = MockChunk("Sub", 3, ("sample.w", 33))    
            self.chunk.referencedBy = self.parent    
                
        def test\_simple\_should\_find\_one(self) -> None:    
            self.reference = pyweb.SimpleReference()    
            theList = self.reference.chunkReferencedBy(self.chunk)    
            self.assertEqual(1, len(theList))    
            self.assertEqual(self.parent, theList[0])    
                
        def test\_transitive\_should\_find\_all(self) -> None:    
            self.reference = pyweb.TransitiveReference()    
            theList = self.reference.chunkReferencedBy(self.chunk)    
            self.assertEqual(2, len(theList))    
            self.assertEqual(self.parent, theList[0])    
            self.assertEqual(self.main, theList[1])    

..

..  class:: small

    ∎ *Unit Test of Reference class hierarchy (31)*



Web Tests
-----------

We create a ``Web`` instance with mocked Chunks and mocked Commands.
The point is to test the ``Web`` features in isolation. This is tricky
because some state is recorded in the Chunk instances.


..  _`Unit Test of Web class (32)`:
..  rubric:: Unit Test of Web class (32) =
..  parsed-literal::
    :class: code

         
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
            self.c3.def\_names = ["userid"]    
            self.web = pyweb.Web([self.c1, self.c2, self.c3])    
            
        def test\_name\_resolution(self) -> None:    
            self.assertEqual(self.web.resolve\_name("c1"), "c1")    
            self.assertEqual(self.web.resolve\_chunk("c2"), [self.c2])    
            self.assertEqual(self.web.resolve\_name("c1..."), "c1")    
            self.assertEqual(self.web.resolve\_name("c3..."), "c3 has a long name")    
                
        def test\_chunks\_should\_iterate(self) -> None:    
            self.assertEqual([self.c2], list(self.web.file\_iter()))    
            self.assertEqual([self.c3], list(self.web.macro\_iter()))    
            self.assertEqual([SimpleNamespace(def\_name="userid", chunk=self.c3)], list(self.web.userid\_iter()))    
            self.assertEqual([self.c2], self.web.files)    
            self.assertEqual(    
                [    
                    SimpleNamespace(name="c2", full\_name="c2", seq=1, def\_list=[self.c2]),    
                    SimpleNamespace(name="c3 has a long name", full\_name="c3 has a long name", seq=2, def\_list=[self.c3])    
                ],     
                self.web.macros)    
            self.assertEqual([SimpleNamespace(userid='userid', ref\_list=[self.c3])], self.web.userids)    
            self.assertEqual([self.c2], self.web.no\_reference())    
            self.assertEqual([], self.web.multi\_reference())    
            self.assertEqual([], self.web.no\_definition())    
                
        def test\_valid\_web\_should\_tangle(self) -> None:    
            """This is the entire interface used by tangling.    
            The details are pushed down to \`\`\`command.tangle()\`\` for each command in each chunk.    
            """    
            self.assertEqual([self.c2], self.web.files)    
                
        def test\_valid\_web\_should\_weave(self) -> None:    
            """This is the entire interface used by tangling.    
            The details are pushed down to unique processing based on \`\`chunk.typeid\`\`.    
            """    
            self.assertEqual([self.c1, self.c2, self.c3], self.web.chunks)    

..

..  class:: small

    ∎ *Unit Test of Web class (32)*





WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

We should test this through some clever mocks that produce the
proper sequence of tokens to parse the various kinds of Commands.


..  _`Unit Test of WebReader class (33)`:
..  rubric:: Unit Test of WebReader class (33) =
..  parsed-literal::
    :class: code

    
    # Tested via functional tests    

..

..  class:: small

    ∎ *Unit Test of WebReader class (33)*



Some lower-level units: specifically the tokenizer and the option parser.


..  _`Unit Test of WebReader class (34)`:
..  rubric:: Unit Test of WebReader class (34) +=
..  parsed-literal::
    :class: code

    
    class TestTokenizer(unittest.TestCase):    
        def test\_should\_split\_tokens(self) -> None:    
            input = io.StringIO("    @    @     word     @    {     @    [     @    <     @    >\\n    @    ]     @    }     @    i     @    \|     @    m     @    f     @    u\\n")    
            self.tokenizer = pyweb.Tokenizer(input)    
            tokens = list(self.tokenizer)    
            self.assertEqual(24, len(tokens))    
            self.assertEqual( ['    @    @    ', ' word ', '    @    {', ' ', '    @    [', ' ', '    @    <', ' ',     
            '    @    >', '\\n', '    @    ]', ' ', '    @    }', ' ', '    @    i', ' ', '    @    \|', ' ', '    @    m', ' ',     
            '    @    f', ' ', '    @    u', '\\n'], tokens )    
            self.assertEqual(2, self.tokenizer.lineNumber)    

..

..  class:: small

    ∎ *Unit Test of WebReader class (34)*




..  _`Unit Test of WebReader class (35)`:
..  rubric:: Unit Test of WebReader class (35) +=
..  parsed-literal::
    :class: code

    
    class TestOptionParser\_OutputChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.option\_parser = pyweb.OptionParser(            
                pyweb.OptionDef("-start", nargs=1, default=None),    
                pyweb.OptionDef("-end", nargs=1, default=""),    
                pyweb.OptionDef("argument", nargs='\*'),    
            )    
        def test\_with\_options\_should\_parse(self) -> None:    
            text1 = " -start /\* -end \*/ something.css "    
            options1 = self.option\_parser.parse(text1)    
            self.assertEqual({'-end': ['\*/'], '-start': ['/\*'], 'argument': ['something.css']}, options1)    
        def test\_without\_options\_should\_parse(self) -> None:    
            text2 = " something.py "    
            options2 = self.option\_parser.parse(text2)    
            self.assertEqual({'argument': ['something.py']}, options2)    
                
    class TestOptionParser\_NamedChunk(unittest.TestCase):    
        def setUp(self) -> None:    
            self.option\_parser = pyweb.OptionParser(        pyweb.OptionDef( "-indent", nargs=0),    
            pyweb.OptionDef("-noindent", nargs=0),    
            pyweb.OptionDef("argument", nargs='\*'),    
            )    
        def test\_with\_options\_should\_parse(self) -> None:    
            text1 = " -indent the name of test1 chunk... "    
            options1 = self.option\_parser.parse(text1)    
            self.assertEqual({'-indent': [], 'argument': ['the', 'name', 'of', 'test1', 'chunk...']}, options1)    
        def test\_without\_options\_should\_parse(self) -> None:    
            text2 = " the name of test2 chunk... "    
            options2 = self.option\_parser.parse(text2)    
            self.assertEqual({'argument': ['the', 'name', 'of', 'test2', 'chunk...']}, options2)    

..

..  class:: small

    ∎ *Unit Test of WebReader class (35)*




Action Tests
-------------

Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  


..  _`Unit Test of Action class hierarchy (36)`:
..  rubric:: Unit Test of Action class hierarchy (36) =
..  parsed-literal::
    :class: code

         
    →\ `Unit test of Action Sequence class (37)`_    
    →\ `Unit test of LoadAction class (40)`_    
    →\ `Unit test of TangleAction class (39)`_    
    →\ `Unit test of WeaverAction class (38)`_    

..

..  class:: small

    ∎ *Unit Test of Action class hierarchy (36)*



**TODO:** Replace with Mock


..  _`Unit test of Action Sequence class (37)`:
..  rubric:: Unit test of Action Sequence class (37) =
..  parsed-literal::
    :class: code

    
    class TestActionSequence(unittest.TestCase):    
        def setUp(self) -> None:    
            self.web = MockWeb()    
            self.a1 = MagicMock(name="Action1")    
            self.a2 = MagicMock(name="Action2")    
            self.action = pyweb.ActionSequence("TwoSteps", [self.a1, self.a2])    
            self.action.web = self.web    
            self.options = argparse.Namespace()    
        def test\_should\_execute\_both(self) -> None:    
            self.action(self.options)    
            self.assertEqual(self.a1.call\_count, 1)    
            self.assertEqual(self.a2.call\_count, 1)    

..

..  class:: small

    ∎ *Unit test of Action Sequence class (37)*




..  _`Unit test of WeaverAction class (38)`:
..  rubric:: Unit test of WeaverAction class (38) =
..  parsed-literal::
    :class: code

         
    class TestWeaveAction(unittest.TestCase):    
        def setUp(self) -> None:    
            self.web = MockWeb()    
            self.action = pyweb.WeaveAction()    
            self.weaver = MockWeaver()    
            self.options = argparse.Namespace(     
                theWeaver=self.weaver,    
                reference\_style=pyweb.SimpleReference(),    
                output=Path.cwd(),    
                web=self.web,    
                weaver='rst',    
            )    
        def test\_should\_execute\_weaving(self) -> None:    
            self.action(self.options)    
            self.assertEqual(self.weaver.emit.mock\_calls, [call(self.web)])    

..

..  class:: small

    ∎ *Unit test of WeaverAction class (38)*




..  _`Unit test of TangleAction class (39)`:
..  rubric:: Unit test of TangleAction class (39) =
..  parsed-literal::
    :class: code

         
    class TestTangleAction(unittest.TestCase):    
        def setUp(self) -> None:    
            self.web = MockWeb()    
            self.action = pyweb.TangleAction()    
            self.tangler = MockTangler()    
            self.options = argparse.Namespace(     
                theTangler = self.tangler,    
                tangler\_line\_numbers = False,     
                output=Path.cwd(),    
                web = self.web    
            )    
        def test\_should\_execute\_tangling(self) -> None:    
            self.action(self.options)    
            self.assertEqual(self.tangler.emit.mock\_calls, [call(self.web)])    

..

..  class:: small

    ∎ *Unit test of TangleAction class (39)*



The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.


..  _`Unit test of LoadAction class (40)`:
..  rubric:: Unit test of LoadAction class (40) =
..  parsed-literal::
    :class: code

         
    class TestLoadAction(unittest.TestCase):    
        def setUp(self) -> None:    
            self.web = MockWeb()    
            self.action = pyweb.LoadAction()    
            self.webReader = Mock(    
                name="WebReader",    
                errors=0,    
                load=Mock(return\_value=[])    
            )    
            self.source\_path = Path("TestLoadAction.w")    
            self.options = argparse.Namespace(     
                webReader = self.webReader,     
                source\_path=self.source\_path,    
                command="    @    ",    
                permitList = [],     
                output=Path.cwd(),    
            )    
            Path("TestLoadAction.w").write\_text("")    
        def tearDown(self) -> None:    
            try:    
                Path("TestLoadAction.w").unlink()    
            except IOError:    
                pass    
        def test\_should\_execute\_loading(self) -> None:    
            self.action(self.options)    
            # Old: self.assertEqual(1, self.webReader.count)    
            print(self.webReader.load.mock\_calls)    
            self.assertEqual(self.webReader.load.mock\_calls, [call(self.source\_path)])    
            self.webReader.web.assert\_not\_called()  # Deprecated    
            self.webReader.source.assert\_not\_called()  # Deprecated    

..

..  class:: small

    ∎ *Unit test of LoadAction class (40)*



Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.

**TODO:** Test Application class


..  _`Unit Test of Application class (41)`:
..  rubric:: Unit Test of Application class (41) =
..  parsed-literal::
    :class: code

    # TODO Test Application class 
..

..  class:: small

    ∎ *Unit Test of Application class (41)*



Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.


..  _`Unit Test overheads: imports, etc. (42)`:
..  rubric:: Unit Test overheads: imports, etc. (42) =
..  parsed-literal::
    :class: code

    """Unit tests."""    
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

..

..  class:: small

    ∎ *Unit Test overheads: imports, etc. (42)*



One more overhead is a function we can inject into selected subclasses
of ``unittest.TestCase``. This is monkeypatch feature that seems useful.


..  _`Unit Test overheads: imports, etc. (43)`:
..  rubric:: Unit Test overheads: imports, etc. (43) +=
..  parsed-literal::
    :class: code

    
    def rstrip\_lines(source: str) -> list[str]:    
        return list(l.rstrip() for l in source.splitlines())        

..

..  class:: small

    ∎ *Unit Test overheads: imports, etc. (43)*




..  _`Unit Test main (44)`:
..  rubric:: Unit Test main (44) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":    
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)    
        unittest.main()    

..

..  class:: small

    ∎ *Unit Test main (44)*



We run the default ``unittest.main()`` to execute the entire suite of tests.


Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-   `Tests for Loading`_

-   `Tests for Tangling`_

-   `Tests for Weaving`_

There are a total of 11 test cases.

Tests for Loading
------------------

We need to be able to load a web from one or more source files.


..  _`test_loader.py (45)`:
..  rubric:: test_loader.py (45) =
..  parsed-literal::
    :class: code

    →\ `Load Test overheads: imports, etc. (47)`_    
    
    →\ `Load Test superclass to refactor common setup (46)`_    
    
    →\ `Load Test error handling with a few common syntax errors (48)`_    
    
    →\ `Load Test include processing with syntax errors (50)`_    
    
    →\ `Load Test main program (53)`_    

..

..  class:: small

    ∎ *test_loader.py (45)*



Parsing test cases have a common setup shown in this superclass.

By using some class-level variables ``text``,
``file_path``, we can simply provide a file-like
input object to the ``WebReader`` instance.


..  _`Load Test superclass to refactor common setup (46)`:
..  rubric:: Load Test superclass to refactor common setup (46) =
..  parsed-literal::
    :class: code

    
    class ParseTestcase(unittest.TestCase):    
        text: ClassVar[str]    
        file\_path: ClassVar[Path]    
            
        def setUp(self) -> None:    
            self.source = io.StringIO(self.text)    
            self.rdr = pyweb.WebReader()    

..

..  class:: small

    ∎ *Load Test superclass to refactor common setup (46)*



There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.


..  _`Load Test overheads: imports, etc. (47)`:
..  rubric:: Load Test overheads: imports, etc. (47) =
..  parsed-literal::
    :class: code

    
    import logging.handlers    
    from pathlib import Path    
    from textwrap import dedent    
    from typing import ClassVar    

..

..  class:: small

    ∎ *Load Test overheads: imports, etc. (47)*




..  _`Load Test error handling with a few common syntax errors (48)`:
..  rubric:: Load Test error handling with a few common syntax errors (48) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 1 with correct and incorrect syntax (49)`_    
    
    class Test\_ParseErrors(ParseTestcase):    
        text = test1\_w    
        file\_path = Path("test1.w")    
        def test\_error\_should\_count\_1(self) -> None:    
            with self.assertLogs('WebReader', level='WARN') as log\_capture:    
                chunks = self.rdr.load(self.file\_path, self.source)    
            self.assertEqual(3, self.rdr.errors)    
            self.assertEqual(log\_capture.output,     
                [    
                    "ERROR:WebReader:At ('test1.w', 8): expected {'    @    {'}, found '    @    o'",    
                    "ERROR:WebReader:Extra '    @    {' (possibly missing chunk name) near ('test1.w', 9)",    
                    "ERROR:WebReader:Extra '    @    {' (possibly missing chunk name) near ('test1.w', 9)"    
                ]    
            )    

..

..  class:: small

    ∎ *Load Test error handling with a few common syntax errors (48)*




..  _`Sample Document 1 with correct and incorrect syntax (49)`:
..  rubric:: Sample Document 1 with correct and incorrect syntax (49) =
..  parsed-literal::
    :class: code

    
    test1\_w = """Some anonymous chunk    
    @    o test1.tmp    
    @    {    @    <part1    @    >    
    @    <part2    @    >    
    @    }    @    @    
    @    d part1     @    {This is part 1.    @    }    
    Okay, now for an error.    
    @    o show how     @    o commands work    
    @    {     @    {     @    ]     @    ]    
    """    

..

..  class:: small

    ∎ *Sample Document 1 with correct and incorrect syntax (49)*



All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

In order to test the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing,
since it's a nested instance of the tokenizer.


..  _`Load Test include processing with syntax errors (50)`:
..  rubric:: Load Test include processing with syntax errors (50) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 8 and the file it includes (51)`_    
    
    class Test\_IncludeParseErrors(ParseTestcase):    
        text = test8\_w    
        file\_path = Path("test8.w")    
        def setUp(self) -> None:    
            super().setUp()    
            Path('test8\_inc.tmp').write\_text(test8\_inc\_w)    
        def test\_error\_should\_count\_2(self) -> None:    
            with self.assertLogs('WebReader', level='WARN') as log\_capture:    
                chunks = self.rdr.load(self.file\_path, self.source)    
            self.assertEqual(1, self.rdr.errors)    
            self.assertEqual(log\_capture.output,    
                [    
                    "ERROR:WebReader:At ('test8\_inc.tmp', 4): end of input, {'    @    {', '    @    ['} not found",     
                    "ERROR:WebReader:Errors in included file 'test8\_inc.tmp', output is incomplete."    
                ]    
            )     
        def tearDown(self) -> None:    
            super().tearDown()    
            Path('test8\_inc.tmp').unlink()    

..

..  class:: small

    ∎ *Load Test include processing with syntax errors (50)*



The sample document must reference the correct name that will
be given to the included document by ``setUp``.


..  _`Sample Document 8 and the file it includes (51)`:
..  rubric:: Sample Document 8 and the file it includes (51) =
..  parsed-literal::
    :class: code

    
    test8\_w = """Some anonymous chunk.    
    @    d title     @    [the title of this document, defined with     @    @    [ and     @    @    ]    @    ]    
    A reference to     @    <title    @    >.    
    @    i test8\_inc.tmp    
    A final anonymous chunk from test8.w    
    """    
    
    test8\_inc\_w="""A chunk from test8a.w    
    And now for an error - incorrect syntax in an included file!    
    @    d yap    
    """    

..

..  class:: small

    ∎ *Sample Document 8 and the file it includes (51)*



<p>The overheads for a Python unittest.</p>


..  _`Load Test overheads: imports, etc. (52)`:
..  rubric:: Load Test overheads: imports, etc. (52) +=
..  parsed-literal::
    :class: code

    
    """Loader and parsing tests."""    
    import io    
    import logging    
    import os    
    from pathlib import Path    
    import string    
    import sys    
    import types    
    import unittest    
    
    import pyweb    

..

..  class:: small

    ∎ *Load Test overheads: imports, etc. (52)*



A main program that configures logging and then runs the test.


..  _`Load Test main program (53)`:
..  rubric:: Load Test main program (53) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":    
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)    
        unittest.main()    

..

..  class:: small

    ∎ *Load Test main program (53)*



Tests for Tangling
------------------

We need to be able to tangle a web.


..  _`test_tangler.py (54)`:
..  rubric:: test_tangler.py (54) =
..  parsed-literal::
    :class: code

    →\ `Tangle Test overheads: imports, etc. (68)`_    
    →\ `Tangle Test superclass to refactor common setup (55)`_    
    →\ `Tangle Test semantic error 2 (56)`_    
    →\ `Tangle Test semantic error 3 (58)`_    
    →\ `Tangle Test semantic error 4 (60)`_    
    →\ `Tangle Test semantic error 5 (62)`_    
    →\ `Tangle Test semantic error 6 (64)`_    
    →\ `Tangle Test include error 7 (66)`_    
    →\ `Tangle Test main program (69)`_    

..

..  class:: small

    ∎ *test_tangler.py (54)*



Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.



..  _`Tangle Test superclass to refactor common setup (55)`:
..  rubric:: Tangle Test superclass to refactor common setup (55) =
..  parsed-literal::
    :class: code

    
    class TangleTestcase(unittest.TestCase):    
        text: ClassVar[str]    
        error: ClassVar[str]    
        file\_path: ClassVar[Path]    
            
        def setUp(self) -> None:    
            self.source = io.StringIO(self.text)    
            self.rdr = pyweb.WebReader()    
            self.tangler = pyweb.Tangler()    
                
        def tangle\_and\_check\_exception(self, exception\_text: str) -> None:    
            with self.assertRaises(pyweb.Error) as exc\_mgr:    
                chunks = self.rdr.load(self.file\_path, self.source)    
                self.web = pyweb.Web(chunks)    
                self.tangler.emit(self.web)    
                # Old: self.web.createUsedBy()    
                self.fail("Should not tangle")    
            exc = exc\_mgr.exception    
            self.assertEqual(exception\_text, exc.args[0])    
                    
        def tearDown(self) -> None:    
            try:    
                self.file\_path.with\_suffix(".tmp").unlink()    
            except FileNotFoundError:    
                pass  # If the test fails, nothing to remove...    

..

..  class:: small

    ∎ *Tangle Test superclass to refactor common setup (55)*




..  _`Tangle Test semantic error 2 (56)`:
..  rubric:: Tangle Test semantic error 2 (56) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 2 (57)`_    
    
    class Test\_SemanticError\_2(TangleTestcase):    
        text = test2\_w    
        file\_path = Path("test2.w")    
        def test\_should\_raise\_undefined(self) -> None:    
            self.tangle\_and\_check\_exception("Attempt to tangle an undefined Chunk, 'part2'")    

..

..  class:: small

    ∎ *Tangle Test semantic error 2 (56)*




..  _`Sample Document 2 (57)`:
..  rubric:: Sample Document 2 (57) =
..  parsed-literal::
    :class: code

    
    test2\_w = """Some anonymous chunk    
    @    o test2.tmp    
    @    {    @    <part1    @    >    
    @    <part2    @    >    
    @    }    @    @    
    @    d part1     @    {This is part 1.    @    }    
    Okay, now for some errors: no part2!    
    """    

..

..  class:: small

    ∎ *Sample Document 2 (57)*




..  _`Tangle Test semantic error 3 (58)`:
..  rubric:: Tangle Test semantic error 3 (58) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 3 (59)`_    
    
    class Test\_SemanticError\_3(TangleTestcase):    
        text = test3\_w    
        file\_path = Path("test3.w")    
        def test\_should\_raise\_bad\_xref(self) -> None:    
            self.tangle\_and\_check\_exception("Illegal tangling of a cross reference command.")    

..

..  class:: small

    ∎ *Tangle Test semantic error 3 (58)*




..  _`Sample Document 3 (59)`:
..  rubric:: Sample Document 3 (59) =
..  parsed-literal::
    :class: code

    
    test3\_w = """Some anonymous chunk    
    @    o test3.tmp    
    @    {    @    <part1    @    >    
    @    <part2    @    >    
    @    }    @    @    
    @    d part1     @    {This is part 1.    @    }    
    @    d part2     @    {This is part 2, with an illegal:     @    f.    @    }    
    Okay, now for some errors: attempt to tangle a cross-reference!    
    """    

..

..  class:: small

    ∎ *Sample Document 3 (59)*





..  _`Tangle Test semantic error 4 (60)`:
..  rubric:: Tangle Test semantic error 4 (60) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 4 (61)`_    
    
    class Test\_SemanticError\_4(TangleTestcase):    
        """An optional feature of a Web."""    
        text = test4\_w    
        file\_path = Path("test4.w")    
        def test\_should\_raise\_noFullName(self) -> None:    
            self.tangle\_and\_check\_exception("No full name for 'part1...'")    

..

..  class:: small

    ∎ *Tangle Test semantic error 4 (60)*




..  _`Sample Document 4 (61)`:
..  rubric:: Sample Document 4 (61) =
..  parsed-literal::
    :class: code

    
    test4\_w = """Some anonymous chunk    
    @    o test4.tmp    
    @    {    @    <part1...    @    >    
    @    <part2    @    >    
    @    }    @    @    
    @    d part1...     @    {This is part 1.    @    }    
    @    d part2     @    {This is part 2.    @    }    
    Okay, now for some errors: attempt to weave but no full name for part1....    
    """    

..

..  class:: small

    ∎ *Sample Document 4 (61)*




..  _`Tangle Test semantic error 5 (62)`:
..  rubric:: Tangle Test semantic error 5 (62) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 5 (63)`_    
    
    class Test\_SemanticError\_5(TangleTestcase):    
        text = test5\_w    
        file\_path = Path("test5.w")    
        def test\_should\_raise\_ambiguous(self) -> None:    
            self.tangle\_and\_check\_exception("Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']")    

..

..  class:: small

    ∎ *Tangle Test semantic error 5 (62)*




..  _`Sample Document 5 (63)`:
..  rubric:: Sample Document 5 (63) =
..  parsed-literal::
    :class: code

    
    test5\_w = """    
    Some anonymous chunk    
    @    o test5.tmp    
    @    {    @    <part1...    @    >    
    @    <part2    @    >    
    @    }    @    @    
    @    d part1a     @    {This is part 1 a.    @    }    
    @    d part1b     @    {This is part 1 b.    @    }    
    @    d part2     @    {This is part 2.    @    }    
    Okay, now for some errors: part1... is ambiguous    
    """    

..

..  class:: small

    ∎ *Sample Document 5 (63)*




..  _`Tangle Test semantic error 6 (64)`:
..  rubric:: Tangle Test semantic error 6 (64) =
..  parsed-literal::
    :class: code

         
    →\ `Sample Document 6 (65)`_    
    
    class Test\_SemanticError\_6(TangleTestcase):    
        text = test6\_w    
        file\_path = Path("test6.w")    
        def test\_should\_warn(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.web = pyweb.Web(chunks)    
            self.tangler.emit(self.web)    
            # Old: self.web.createUsedBy()    
            print(self.web.no\_reference())    
            self.assertEqual(1, len(self.web.no\_reference()))    
            self.assertEqual(1, len(self.web.multi\_reference()))    
            self.assertEqual(0, len(self.web.no\_definition()))    

..

..  class:: small

    ∎ *Tangle Test semantic error 6 (64)*




..  _`Sample Document 6 (65)`:
..  rubric:: Sample Document 6 (65) =
..  parsed-literal::
    :class: code

    
    test6\_w = """Some anonymous chunk    
    @    o test6.tmp    
    @    {    @    <part1...    @    >    
    @    <part1a    @    >    
    @    }    @    @    
    @    d part1a     @    {This is part 1 a.    @    }    
    @    d part2     @    {This is part 2.    @    }    
    Okay, now for some warnings:     
    - part1 has multiple references.    
    - part2 is unreferenced.    
    """    

..

..  class:: small

    ∎ *Sample Document 6 (65)*




..  _`Tangle Test include error 7 (66)`:
..  rubric:: Tangle Test include error 7 (66) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 7 and it's included file (67)`_    
    
    class Test\_IncludeError\_7(TangleTestcase):    
        text = test7\_w    
        file\_path = Path("test7.w")    
        def setUp(self) -> None:    
            Path('test7\_inc.tmp').write\_text(test7\_inc\_w)    
            super().setUp()    
        def test\_should\_include(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.web = pyweb.Web(chunks)    
            self.tangler.emit(self.web)    
            # Old: self.web.createUsedBy()    
            self.assertEqual(5, len(self.web.chunks))    
            self.assertEqual(test7\_inc\_w, self.web.chunks[3].commands[0].text)    
        def tearDown(self) -> None:    
            Path('test7\_inc.tmp').unlink()    
            super().tearDown()    

..

..  class:: small

    ∎ *Tangle Test include error 7 (66)*




..  _`Sample Document 7 and it's included file (67)`:
..  rubric:: Sample Document 7 and it's included file (67) =
..  parsed-literal::
    :class: code

    
    test7\_w = """    
    Some anonymous chunk.    
    @    d title     @    [the title of this document, defined with     @    @    [ and     @    @    ]    @    ]    
    A reference to     @    <title    @    >.    
    @    i test7\_inc.tmp    
    A final anonymous chunk from test7.w    
    """    
    
    test7\_inc\_w = """The test7a.tmp chunk for test7.w"""    

..

..  class:: small

    ∎ *Sample Document 7 and it's included file (67)*




..  _`Tangle Test overheads: imports, etc. (68)`:
..  rubric:: Tangle Test overheads: imports, etc. (68) =
..  parsed-literal::
    :class: code

    
    """Tangler tests exercise various semantic features."""    
    import io    
    import logging    
    import os    
    from pathlib import Path    
    from typing import ClassVar    
    import unittest    
    
    import pyweb    

..

..  class:: small

    ∎ *Tangle Test overheads: imports, etc. (68)*




..  _`Tangle Test main program (69)`:
..  rubric:: Tangle Test main program (69) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":    
        import sys    
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)    
        unittest.main()    

..

..  class:: small

    ∎ *Tangle Test main program (69)*




Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.


..  _`test_weaver.py (70)`:
..  rubric:: test_weaver.py (70) =
..  parsed-literal::
    :class: code

    →\ `Weave Test overheads: imports, etc. (78)`_    
    →\ `Weave Test superclass to refactor common setup (71)`_    
    →\ `Weave Test references and definitions (72)`_    
    →\ `Weave Test evaluation of expressions (76)`_    
    →\ `Weave Test main program (79)`_    

..

..  class:: small

    ∎ *test_weaver.py (70)*



Weaving test cases have a common setup shown in this superclass.


..  _`Weave Test superclass to refactor common setup (71)`:
..  rubric:: Weave Test superclass to refactor common setup (71) =
..  parsed-literal::
    :class: code

    
    class WeaveTestcase(unittest.TestCase):    
        text: ClassVar[str]    
        error: ClassVar[str]    
        file\_path: ClassVar[Path]    
            
        def setUp(self) -> None:    
            self.source = io.StringIO(self.text)    
            self.rdr = pyweb.WebReader()    
            self.maxDiff = None    
    
        def tearDown(self) -> None:    
            try:    
                self.file\_path.with\_suffix(".html").unlink()    
            except FileNotFoundError:    
                pass  # if the test failed, nothing to remove    

..

..  class:: small

    ∎ *Weave Test superclass to refactor common setup (71)*




..  _`Weave Test references and definitions (72)`:
..  rubric:: Weave Test references and definitions (72) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 0 (73)`_    
    →\ `Expected Output 0 (74)`_    
    
    class Test\_RefDefWeave(WeaveTestcase):    
        text = test0\_w    
        file\_path = Path("test0.w")    
        def test\_load\_should\_createChunks(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.assertEqual(3, len(chunks))    
                
        def test\_weave\_should\_create\_html(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.web = pyweb.Web(chunks)    
            self.web.web\_path = self.file\_path    
            doc = pyweb.Weaver( )    
            doc.set\_markup("html")    
            doc.reference\_style = pyweb.SimpleReference()     
            doc.emit(self.web)    
            actual = self.file\_path.with\_suffix(".html").read\_text()    
            self.maxDiff = None    
            self.assertEqual(test0\_expected\_html, actual)    
                
        def test\_weave\_should\_create\_debug(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.web = pyweb.Web(chunks)    
            self.web.web\_path = self.file\_path    
            doc = pyweb.Weaver( )    
            doc.set\_markup("debug")    
            doc.reference\_style = pyweb.SimpleReference()     
            doc.emit(self.web)    
            actual = self.file\_path.with\_suffix(".debug").read\_text()    
            self.maxDiff = None    
            self.assertEqual(test0\_expected\_debug, actual)    

..

..  class:: small

    ∎ *Weave Test references and definitions (72)*




..  _`Sample Document 0 (73)`:
..  rubric:: Sample Document 0 (73) =
..  parsed-literal::
    :class: code

         
    test0\_w = """<html>    
    <head>    
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />    
    </head>    
    <body>    
    @    <some code    @    >    
    
    @    d some code     
    @    {    
    def fastExp(n, p):    
        r = 1    
        while p > 0:    
            if p%2 == 1: return n\*fastExp(n,p-1)    
        return n\*n\*fastExp(n,p/2)    
    
    for i in range(24):    
        fastExp(2,i)    
    @    }    
    </body>    
    </html>    
    """    

..

..  class:: small

    ∎ *Sample Document 0 (73)*




..  _`Expected Output 0 (74)`:
..  rubric:: Expected Output 0 (74) =
..  parsed-literal::
    :class: code

    
    test0\_expected\_html = """<html>    
    <head>    
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />    
    </head>    
    <body>    
    &rarr;<a href="#pyweb\_1"><em>some code (1)</em></a>    
    
    
    <a name="pyweb\_1"></a>    
    <!--line number ('test0.w', 10)-->    
    <p><em>some code (1)</em> =</p>    
    <pre><code>    
    def fastExp(n, p):    
        r = 1    
        while p &gt; 0:    
            if p%2 == 1: return n\*fastExp(n,p-1)    
        return n\*n\*fastExp(n,p/2)    
    
    for i in range(24):    
        fastExp(2,i)    
    
    </code></pre>    
    <p>&#8718; <em>some code (1)</em>.    
    </p>     
    
    </body>    
    </html>    
    """    

..

..  class:: small

    ∎ *Expected Output 0 (74)*




..  _`Expected Output 0 (75)`:
..  rubric:: Expected Output 0 (75) +=
..  parsed-literal::
    :class: code

    
    test0\_expected\_debug = dedent("""\\    
        text: TextCommand(text='<html>', location=('test0.w', 1), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 2), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='<head>', location=('test0.w', 2), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 3), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='    <link rel="StyleSheet" href="pyweb.css" type="text/css" />', location=('test0.w', 3), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 4), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</head>', location=('test0.w', 4), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 5), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='<body>', location=('test0.w', 5), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 6), logger=<Logger TextCommand (INFO)>, definition=True)    
        ref: ReferenceCommand(name='some code', location=('test0.w', 6), definition=False, logger=<Logger ReferenceCommand (INFO)>)text: TextCommand(text='\\\\n', location=('test0.w', 7), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 8), logger=<Logger TextCommand (INFO)>, definition=True)    
        begin\_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='        if p%2 == 1: return n\*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    return n\*n\*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)], options=[], def\_names=[], initial=True, comment\_start=None, comment\_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='        if p%2 == 1: return n\*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='    return n\*n\*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True)    
        code: CodeCommand(text='\\\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)    
        end\_code: NamedChunk(name='some code', seq=1, commands=[CodeCommand(text='\\\\n', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='def fastExp(n, p):', location=('test0.w', 10), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    r = 1', location=('test0.w', 11), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    while p > 0:', location=('test0.w', 12), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='        if p%2 == 1: return n\*fastExp(n,p-1)', location=('test0.w', 13), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    return n\*n\*fastExp(n,p/2)', location=('test0.w', 14), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 15), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='for i in range(24):', location=('test0.w', 16), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='    fastExp(2,i)', location=('test0.w', 17), logger=<Logger CodeCommand (INFO)>, definition=True), CodeCommand(text='\\\\n', location=('test0.w', 18), logger=<Logger CodeCommand (INFO)>, definition=True)], options=[], def\_names=[], initial=True, comment\_start=None, comment\_end=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>)    
        text: TextCommand(text='\\\\n', location=('test0.w', 19), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</body>', location=('test0.w', 19), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 20), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='</html>', location=('test0.w', 20), logger=<Logger TextCommand (INFO)>, definition=True)text: TextCommand(text='\\\\n', location=('test0.w', 21), logger=<Logger TextCommand (INFO)>, definition=True)""")    

..

..  class:: small

    ∎ *Expected Output 0 (75)*



Note that this really requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.


..  _`Weave Test evaluation of expressions (76)`:
..  rubric:: Weave Test evaluation of expressions (76) =
..  parsed-literal::
    :class: code

    
    →\ `Sample Document 9 (77)`_    
    
    from unittest.mock import Mock    
    
    class TestEvaluations(WeaveTestcase):    
        text = test9\_w    
        file\_path = Path("test9.w")    
        def setUp(self):    
            super().setUp()    
            self.mock\_time = Mock(asctime=Mock(return\_value="mocked time"))    
        def test\_should\_evaluate(self) -> None:    
            chunks = self.rdr.load(self.file\_path, self.source)    
            self.web = pyweb.Web(chunks)    
            self.web.web\_path = self.file\_path    
            doc = pyweb.Weaver( )    
            doc.set\_markup("html")    
            doc.reference\_style = pyweb.SimpleReference()     
            doc.emit(self.web)    
            actual = self.file\_path.with\_suffix(".html").read\_text().splitlines()    
            #print(actual)    
            self.assertEqual("An anonymous chunk.", actual[0])    
            self.assertTrue("Time = mocked time", actual[1])    
            self.assertEqual("File = ('test9.w', 3)", actual[2])    
            self.assertEqual('Version = 3.2', actual[3])    
            self.assertEqual(f'CWD = {os.getcwd()}', actual[4])    

..

..  class:: small

    ∎ *Weave Test evaluation of expressions (76)*




..  _`Sample Document 9 (77)`:
..  rubric:: Sample Document 9 (77) =
..  parsed-literal::
    :class: code

    
    test9\_w= """An anonymous chunk.    
    Time =     @    (time.asctime()    @    )    
    File =     @    (theLocation    @    )    
    Version =     @    (\_\_version\_\_    @    )    
    CWD =     @    (os.path.realpath('.')    @    )    
    """    

..

..  class:: small

    ∎ *Sample Document 9 (77)*




..  _`Weave Test overheads: imports, etc. (78)`:
..  rubric:: Weave Test overheads: imports, etc. (78) =
..  parsed-literal::
    :class: code

    
    """Weaver tests exercise various weaving features."""    
    import io    
    import logging    
    import os    
    from pathlib import Path    
    import string    
    import sys    
    from textwrap import dedent    
    from typing import ClassVar    
    import unittest    
    
    import pyweb    

..

..  class:: small

    ∎ *Weave Test overheads: imports, etc. (78)*




..  _`Weave Test main program (79)`:
..  rubric:: Weave Test main program (79) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":    
        logging.basicConfig(stream=sys.stderr, level=logging.WARN)    
        unittest.main()    

..

..  class:: small

    ∎ *Weave Test main program (79)*




Additional Scripts Testing
==========================

.. test/scripts.w

We provide these two additional scripts; effectively command-line short-cuts:

-   ``tangle.py``

-   ``weave.py``

These need their own test cases.


This gives us the following outline for the script testing.


..  _`test_scripts.py (80)`:
..  rubric:: test_scripts.py (80) =
..  parsed-literal::
    :class: code

    →\ `Script Test overheads: imports, etc. (85)`_    
    
    →\ `Sample web file to test with (81)`_    
    
    →\ `Superclass for test cases (82)`_    
    
    →\ `Test of weave.py (83)`_    
    
    →\ `Test of tangle.py (84)`_    
    
    →\ `Scripts Test main (86)`_    

..

..  class:: small

    ∎ *test_scripts.py (80)*



Sample Web File
---------------

This is a web ``.w`` file to create a document and tangle a small file.


..  _`Sample web file to test with (81)`:
..  rubric:: Sample web file to test with (81) =
..  parsed-literal::
    :class: code

    
    sample = textwrap.dedent("""    
        <!doctype html>    
        <html lang="en">    
          <head>    
            <meta charset="utf-8">    
            <meta name="viewport" content="width=device-width, initial-scale=1">    
            <title>Sample HTML web file</title>    
          </head>    
          <body>    
            <h1>Sample HTML web file</h1>    
            <p>We're avoiding using Python specifically.    
            This hints at other languages being tangled by this tool.</p>    
                
            @    o sample\_tangle.code    
            @    {    
            @    <preamble    @    >    
            @    <body    @    >    
            @    }    
            
            @    d preamble    
            @    {    
        #include <stdio.h>    
            @    }    
            
            @    d body    
            @    {    
        int main() {    
            println("Hello, World!")    
        }    
            @    }    
            
          </body>    
        </html>    
        """)    

..

..  class:: small

    ∎ *Sample web file to test with (81)*



Superclass for test cases
-------------------------

This superclass definition creates a consistent test fixture for both test cases.
The sample ``test_sample.w`` file is created and removed after the test.


..  _`Superclass for test cases (82)`:
..  rubric:: Superclass for test cases (82) =
..  parsed-literal::
    :class: code

    
    class SampleWeb(unittest.TestCase):    
        def setUp(self) -> None:    
            self.sample\_path = Path("test\_sample.w")    
            self.sample\_path.write\_text(sample)    
                
        def tearDown(self) -> None:    
            self.sample\_path.unlink()    
    
        def assertEqual\_Ignore\_Blank\_Lines(self, first: str, second: str, msg: str=None) -> None:    
            """Skips blank lines and trailing whitespace that (generally) aren't problems when weaving."""    
            def non\_blank(line: str) -> bool:    
                return len(line) > 0    
            first\_nb = list(filter(non\_blank, (line.rstrip() for line in first.splitlines())))    
            second\_nb = list(filter(non\_blank, (line.rstrip() for line in second.splitlines())))    
            self.assertListEqual(first\_nb, second\_nb, msg)    

..

..  class:: small

    ∎ *Superclass for test cases (82)*



Weave Script Test
-----------------

We check the weave output to be sure it's what we expected. 
This could be altered to check a few features of the weave file rather than compare the entire file.


..  _`Test of weave.py (83)`:
..  rubric:: Test of weave.py (83) =
..  parsed-literal::
    :class: code

    
    expected\_weave = ('\\n'    
        '<!doctype html>\\n'    
        '<html lang="en">\\n'    
        '  <head>\\n'    
        '    <meta charset="utf-8">\\n'    
        '    <meta name="viewport" content="width=device-width, initial-scale=1">\\n'    
        '    <title>Sample HTML web file</title>\\n'    
        '  </head>\\n'    
        '  <body>\\n'    
        '    <h1>Sample HTML web file</h1>\\n'    
        "    <p>We're avoiding using Python specifically.\\n"    
        '    This hints at other languages being tangled by this tool.</p>\\n'    
        '\\n'    
        '\\n'    
        '<a name="pyweb\_1"></a>\\n'    
        "<!--line number ('test\_sample.w', 16)-->\\n"    
        '<p><em>sample\_tangle.code (1)</em> =</p>\\n'    
        '<pre><code>\\n'    
        '\\n'    
        '        \\n'    
        '&rarr;<a href="#pyweb\_2"><em>preamble (2)</em></a>\\n'    
        '&rarr;<a href="#pyweb\_3"><em>body (3)</em></a>\\n'    
        '\\n'    
        '        \\n'    
        '</code></pre>\\n'    
        '<p>&#8718; <em>sample\_tangle.code (1)</em>.\\n'    
        '</p> \\n'    
        '\\n'    
        '\\n'    
        '\\n'    
        '<a name="pyweb\_2"></a>\\n'    
        "<!--line number ('test\_sample.w', 22)-->\\n"    
        '<p><em>preamble (2)</em> =</p>\\n'    
        '<pre><code>\\n'    
        '\\n'    
        '        \\n'    
        '#include &lt;stdio.h&gt;\\n'    
        '\\n'    
        '        \\n'    
        '</code></pre>\\n'    
        '<p>&#8718; <em>preamble (2)</em>.\\n'    
        '</p> \\n'    
        '\\n'    
        '\\n'    
        '\\n'    
        '<a name="pyweb\_3"></a>\\n'    
        "<!--line number ('test\_sample.w', 27)-->\\n"    
        '<p><em>body (3)</em> =</p>\\n'    
        '<pre><code>\\n'    
        '\\n'    
        '        \\n'    
        'int main() {\\n'    
        '    println(&quot;Hello, World!&quot;)\\n'    
        '}\\n'    
        '\\n'    
        '        \\n'    
        '</code></pre>\\n'    
        '<p>&#8718; <em>body (3)</em>.\\n'    
        '</p> \\n'    
        '\\n'    
        '\\n'    
        '  </body>\\n'    
        '</html>\\n'    
    )    
            
    class TestWeave(SampleWeb):    
        def setUp(self) -> None:    
            super().setUp()    
            self.output = self.sample\_path.with\_suffix(".html")    
            self.maxDiff = None    
    
        def test(self) -> None:    
            weave.main(self.sample\_path)    
            result = self.output.read\_text()    
            self.assertEqual\_Ignore\_Blank\_Lines(expected\_weave, result)    
    
        def tearDown(self) -> None:    
            super().tearDown()    
            self.output.unlink()    

..

..  class:: small

    ∎ *Test of weave.py (83)*



Tangle Script Test
------------------

We check the tangle output to be sure it's what we expected. 


..  _`Test of tangle.py (84)`:
..  rubric:: Test of tangle.py (84) =
..  parsed-literal::
    :class: code

    
    
    expected\_tangle = textwrap.dedent("""    
    
        #include <stdio.h>    
            
            
        int main() {    
            println("Hello, World!")    
        }    
            
        """)    
            
    class TestTangle(SampleWeb):    
        def setUp(self) -> None:    
            super().setUp()    
            self.output = Path("sample\_tangle.code")    
    
        def test(self) -> None:    
            tangle.main(self.sample\_path)    
            result = self.output.read\_text()    
            self.assertEqual(expected\_tangle, result)    
    
        def tearDown(self) -> None:    
            super().tearDown()    
            self.output.unlink()    

..

..  class:: small

    ∎ *Test of tangle.py (84)*



Overheads and Main Script
--------------------------

This is typical of the other test modules. We provide a unittest runner 
here in case we want to run these tests in isolation.


..  _`Script Test overheads: imports, etc. (85)`:
..  rubric:: Script Test overheads: imports, etc. (85) =
..  parsed-literal::
    :class: code

    """Script tests."""    
    import logging    
    from pathlib import Path    
    import sys    
    import textwrap    
    import unittest    
    
    import tangle    
    import weave    

..

..  class:: small

    ∎ *Script Test overheads: imports, etc. (85)*




..  _`Scripts Test main (86)`:
..  rubric:: Scripts Test main (86) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":    
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)    
        unittest.main()    

..

..  class:: small

    ∎ *Scripts Test main (86)*



We run the default ``unittest.main()`` to execute the entire suite of tests.


No Longer supported: @i runner.w, using **pytest** seems better.

Additional Files
=================

To get the RST to look good, there are two additional files.
These are clones of what's in the ``src`` directory.

``docutils.conf`` defines two CSS files to use.
	The default CSS file may need to be customized.


..  _`docutils.conf (87)`:
..  rubric:: docutils.conf (87) =
..  parsed-literal::
    :class: code

    # docutils.conf    
    
    [html4css1 writer]    
    stylesheet-path: /Users/slott/miniconda3/envs/pywebtool/lib/python3.10/site-packages/docutils/writers/html4css1/html4css1.css,    
        page-layout.css    
    syntax-highlight: long    

..

..  class:: small

    ∎ *docutils.conf (87)*



``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. These are minor
tweaks to the default CSS.


..  _`page-layout.css (88)`:
..  rubric:: page-layout.css (88) =
..  parsed-literal::
    :class: code

    /\* Page layout tweaks \*/    
    div.document { width: 7in; }    
    .small { font-size: smaller; }    
    .code    
    {    
    	color: #101080;    
    	display: block;    
    	border-color: black;    
    	border-width: thin;    
    	border-style: solid;    
    	background-color: #E0FFFF;    
    	/\*#99FFFF\*/    
    	padding: 0 0 0 1%;    
    	margin: 0 6% 0 6%;    
    	text-align: left;    
    	font-size: smaller;    
    }    

..

..  class:: small

    ∎ *page-layout.css (88)*




Indices
=======

Files
-----

:test_unit.py:
    →\ `test_unit.py (1)`_:test_loader.py:
    →\ `test_loader.py (45)`_:test_tangler.py:
    →\ `test_tangler.py (54)`_:test_weaver.py:
    →\ `test_weaver.py (70)`_:test_scripts.py:
    →\ `test_scripts.py (80)`_:docutils.conf:
    →\ `docutils.conf (87)`_:page-layout.css:
    →\ `page-layout.css (88)`_

Macros
------

:Expected Output 0:
    →\ `Expected Output 0 (74)`_, →\ `Expected Output 0 (75)`_

:Load Test error handling with a few common syntax errors:
    →\ `Load Test error handling with a few common syntax errors (48)`_

:Load Test include processing with syntax errors:
    →\ `Load Test include processing with syntax errors (50)`_

:Load Test main program:
    →\ `Load Test main program (53)`_

:Load Test overheads: imports, etc.:
    →\ `Load Test overheads: imports, etc. (47)`_, →\ `Load Test overheads: imports, etc. (52)`_

:Load Test superclass to refactor common setup:
    →\ `Load Test superclass to refactor common setup (46)`_

:Sample Document 0:
    →\ `Sample Document 0 (73)`_

:Sample Document 1 with correct and incorrect syntax:
    →\ `Sample Document 1 with correct and incorrect syntax (49)`_

:Sample Document 2:
    →\ `Sample Document 2 (57)`_

:Sample Document 3:
    →\ `Sample Document 3 (59)`_

:Sample Document 4:
    →\ `Sample Document 4 (61)`_

:Sample Document 5:
    →\ `Sample Document 5 (63)`_

:Sample Document 6:
    →\ `Sample Document 6 (65)`_

:Sample Document 7 and it's included file:
    →\ `Sample Document 7 and it's included file (67)`_

:Sample Document 8 and the file it includes:
    →\ `Sample Document 8 and the file it includes (51)`_

:Sample Document 9:
    →\ `Sample Document 9 (77)`_

:Sample web file to test with:
    →\ `Sample web file to test with (81)`_

:Script Test overheads: imports, etc.:
    →\ `Script Test overheads: imports, etc. (85)`_

:Scripts Test main:
    →\ `Scripts Test main (86)`_

:Superclass for test cases:
    →\ `Superclass for test cases (82)`_

:Tangle Test include error 7:
    →\ `Tangle Test include error 7 (66)`_

:Tangle Test main program:
    →\ `Tangle Test main program (69)`_

:Tangle Test overheads: imports, etc.:
    →\ `Tangle Test overheads: imports, etc. (68)`_

:Tangle Test semantic error 2:
    →\ `Tangle Test semantic error 2 (56)`_

:Tangle Test semantic error 3:
    →\ `Tangle Test semantic error 3 (58)`_

:Tangle Test semantic error 4:
    →\ `Tangle Test semantic error 4 (60)`_

:Tangle Test semantic error 5:
    →\ `Tangle Test semantic error 5 (62)`_

:Tangle Test semantic error 6:
    →\ `Tangle Test semantic error 6 (64)`_

:Tangle Test superclass to refactor common setup:
    →\ `Tangle Test superclass to refactor common setup (55)`_

:Test of tangle.py:
    →\ `Test of tangle.py (84)`_

:Test of weave.py:
    →\ `Test of weave.py (83)`_

:Unit Test Mock Chunk class:
    →\ `Unit Test Mock Chunk class (4)`_

:Unit Test main:
    →\ `Unit Test main (44)`_

:Unit Test of Action class hierarchy:
    →\ `Unit Test of Action class hierarchy (36)`_

:Unit Test of Application class:
    →\ `Unit Test of Application class (41)`_

:Unit Test of Chunk class hierarchy:
    →\ `Unit Test of Chunk class hierarchy (10)`_

:Unit Test of Chunk construction:
    →\ `Unit Test of Chunk construction (15)`_

:Unit Test of Chunk interrogation:
    →\ `Unit Test of Chunk interrogation (16)`_

:Unit Test of Chunk properties:
    →\ `Unit Test of Chunk properties (17)`_

:Unit Test of Chunk superclass:
    →\ `Unit Test of Chunk superclass (11)`_, →\ `Unit Test of Chunk superclass (12)`_, →\ `Unit Test of Chunk superclass (13)`_, →\ `Unit Test of Chunk superclass (14)`_

:Unit Test of CodeCommand class to contain a program source code block:
    →\ `Unit Test of CodeCommand class to contain a program source code block (25)`_

:Unit Test of Command class hierarchy:
    →\ `Unit Test of Command class hierarchy (22)`_

:Unit Test of Command superclass:
    →\ `Unit Test of Command superclass (23)`_

:Unit Test of Emitter Superclass:
    →\ `Unit Test of Emitter Superclass (3)`_

:Unit Test of Emitter class hierarchy:
    →\ `Unit Test of Emitter class hierarchy (2)`_

:Unit Test of FileXrefCommand class for an output file cross-reference:
    →\ `Unit Test of FileXrefCommand class for an output file cross-reference (27)`_

:Unit Test of HTML subclass of Emitter:
    →\ `Unit Test of HTML subclass of Emitter (7)`_

:Unit Test of LaTeX subclass of Emitter:
    →\ `Unit Test of LaTeX subclass of Emitter (6)`_

:Unit Test of MacroXrefCommand class for a named chunk cross-reference:
    →\ `Unit Test of MacroXrefCommand class for a named chunk cross-reference (28)`_

:Unit Test of NamedChunk subclass:
    →\ `Unit Test of NamedChunk subclass (18)`_

:Unit Test of NamedChunk_Noindent subclass:
    →\ `Unit Test of NamedChunk_Noindent subclass (19)`_

:Unit Test of NamedDocumentChunk subclass:
    →\ `Unit Test of NamedDocumentChunk subclass (21)`_

:Unit Test of OutputChunk subclass:
    →\ `Unit Test of OutputChunk subclass (20)`_

:Unit Test of Reference class hierarchy:
    →\ `Unit Test of Reference class hierarchy (31)`_

:Unit Test of ReferenceCommand class for chunk references:
    →\ `Unit Test of ReferenceCommand class for chunk references (30)`_

:Unit Test of Tangler subclass of Emitter:
    →\ `Unit Test of Tangler subclass of Emitter (8)`_

:Unit Test of TanglerMake subclass of Emitter:
    →\ `Unit Test of TanglerMake subclass of Emitter (9)`_

:Unit Test of TextCommand class to contain a document text block:
    →\ `Unit Test of TextCommand class to contain a document text block (24)`_

:Unit Test of UserIdXrefCommand class for a user identifier cross-reference:
    →\ `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29)`_

:Unit Test of Weaver subclass of Emitter:
    →\ `Unit Test of Weaver subclass of Emitter (5)`_

:Unit Test of Web class:
    →\ `Unit Test of Web class (32)`_

:Unit Test of WebReader class:
    →\ `Unit Test of WebReader class (33)`_, →\ `Unit Test of WebReader class (34)`_, →\ `Unit Test of WebReader class (35)`_

:Unit Test of XrefCommand superclass for all cross-reference commands:
    →\ `Unit Test of XrefCommand superclass for all cross-reference commands (26)`_

:Unit Test overheads: imports, etc.:
    →\ `Unit Test overheads: imports, etc. (42)`_, →\ `Unit Test overheads: imports, etc. (43)`_

:Unit test of Action Sequence class:
    →\ `Unit test of Action Sequence class (37)`_

:Unit test of LoadAction class:
    →\ `Unit test of LoadAction class (40)`_

:Unit test of TangleAction class:
    →\ `Unit test of TangleAction class (39)`_

:Unit test of WeaverAction class:
    →\ `Unit test of WeaverAction class (38)`_

:Weave Test evaluation of expressions:
    →\ `Weave Test evaluation of expressions (76)`_

:Weave Test main program:
    →\ `Weave Test main program (79)`_

:Weave Test overheads: imports, etc.:
    →\ `Weave Test overheads: imports, etc. (78)`_

:Weave Test references and definitions:
    →\ `Weave Test references and definitions (72)`_

:Weave Test superclass to refactor common setup:
    →\ `Weave Test superclass to refactor common setup (71)`_



User Identifiers
----------------



----------

..	class:: small

	Created by src/pyweb.py at Tue Jun 28 13:50:36 2022.

    Source tests/pyweb_test.w modified Sat Jun 18 10:00:51 2022.

	pyweb.__version__ '3.2'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool'.
