############################################
pyWeb Literate Programming 3.1 - Test Suite
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

..    test/func.w 

There are several broad areas of unit testing.  There are the 34 classes in this application.
However, it isn't really necessary to test everyone single one of these classes.
We'll decompose these into several hierarchies.


-    Emitters
    
        class Emitter:  
        
        class Weaver(Emitter):  
        
        class LaTeX(Weaver):  
        
        class HTML(Weaver):  
        
        class HTMLShort(HTML):  
        
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


..  _`1`:
..  rubric:: test_unit.py (1) =
..  parsed-literal::
    :class: code

    |srarr|\ Unit Test overheads: imports, etc. (`48`_), |srarr|\ (`49`_)
    |srarr|\ Unit Test of Emitter class hierarchy (`2`_)
    |srarr|\ Unit Test of Chunk class hierarchy (`11`_)
    |srarr|\ Unit Test of Command class hierarchy (`23`_)
    |srarr|\ Unit Test of Reference class hierarchy (`32`_)
    |srarr|\ Unit Test of Web class (`33`_)
    |srarr|\ Unit Test of WebReader class (`39`_), |srarr|\ (`40`_), |srarr|\ (`41`_)
    |srarr|\ Unit Test of Action class hierarchy (`42`_)
    |srarr|\ Unit Test of Application class (`47`_)
    |srarr|\ Unit Test main (`50`_)

..

    ..  class:: small

        |loz| *test_unit.py (1)*.


Emitter Tests
-------------

The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.



..  _`2`:
..  rubric:: Unit Test of Emitter class hierarchy (2) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Unit Test Mock Chunk class (`4`_)
    |srarr|\ Unit Test of Emitter Superclass (`3`_)
    |srarr|\ Unit Test of Weaver subclass of Emitter (`5`_)
    |srarr|\ Unit Test of LaTeX subclass of Emitter (`6`_)
    |srarr|\ Unit Test of HTML subclass of Emitter (`7`_)
    |srarr|\ Unit Test of HTMLShort subclass of Emitter (`8`_)
    |srarr|\ Unit Test of Tangler subclass of Emitter (`9`_)
    |srarr|\ Unit Test of TanglerMake subclass of Emitter (`10`_)

..

    ..  class:: small

        |loz| *Unit Test of Emitter class hierarchy (2)*. Used by: test_unit.py (`1`_)


The Emitter superclass is designed to be extended.  The test 
creates a subclass to exercise a few key features. The default
emitter is Tangler-like.


..  _`3`:
..  rubric:: Unit Test of Emitter Superclass (3) =
..  parsed-literal::
    :class: code

     
    class EmitterExtension(pyweb.Emitter):
        def doOpen(self) -> None:
            self.theFile = io.StringIO()
        def doClose(self) -> None:
            self.theFile.flush()
            
    class TestEmitter(unittest.TestCase):
        def setUp(self) -> None:
            self.emitter = EmitterExtension()
        def test\_emitter\_should\_open\_close\_write(self) -> None:
            self.emitter.open(Path("test.tmp"))
            self.emitter.write("Something")
            self.emitter.close()
            self.assertEqual("Something", self.emitter.theFile.getvalue())
        def test\_emitter\_should\_codeBlock(self) -> None:
            self.emitter.open(Path("test.tmp"))
            self.emitter.codeBlock("Some")
            self.emitter.codeBlock(" Code")
            self.emitter.close()
            self.assertEqual("Some Code\\n", self.emitter.theFile.getvalue())
        def test\_emitter\_should\_indent(self) -> None:
            self.emitter.open(Path("test.tmp"))
            self.emitter.codeBlock("Begin\\n")
            self.emitter.addIndent(4)
            self.emitter.codeBlock("More Code\\n")
            self.emitter.clrIndent()
            self.emitter.codeBlock("End")
            self.emitter.close()
            self.assertEqual("Begin\\n    More Code\\nEnd\\n", self.emitter.theFile.getvalue())
        def test\_emitter\_should\_noindent(self) -> None:
            self.emitter.open(Path("test.tmp"))
            self.emitter.codeBlock("Begin\\n")
            self.emitter.setIndent(0)
            self.emitter.codeBlock("More Code\\n")
            self.emitter.clrIndent()
            self.emitter.codeBlock("End")
            self.emitter.close()
            self.assertEqual("Begin\\nMore Code\\nEnd\\n", self.emitter.theFile.getvalue())

..

    ..  class:: small

        |loz| *Unit Test of Emitter Superclass (3)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


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



..  _`4`:
..  rubric:: Unit Test Mock Chunk class (4) =
..  parsed-literal::
    :class: code

    
    def mock\_chunk\_instance(name: str, seq: int, lineNumber: int) -> Mock:
        def write\_closure(aWeb: pyweb.Web, aTangler: pyweb.Tangler) -> None:
            aTangler.write(name)
            
        chunk = Mock(
            wraps=pyweb.Chunk,
            fullName=name,
            seq=seq,
            lineNumber=lineNumber,
            initial=True,
            commands=[],
            referencedBy=[],
            references=Mock(return\_value=[]),
            reference\_indent=Mock(),
            reference\_dedent=Mock(),
            tangle=Mock(side\_effect=write\_closure)
        )
        chunk.name=name
        return chunk
        
    MockChunk = Mock(
        name="Chunk class",
        side\_effect=mock\_chunk\_instance
    )

..

    ..  class:: small

        |loz| *Unit Test Mock Chunk class (4)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


The default Weaver is an Emitter that uses templates to produce RST markup.


..  _`5`:
..  rubric:: Unit Test of Weaver subclass of Emitter (5) =
..  parsed-literal::
    :class: code

    
    class TestWeaver(unittest.TestCase):
        def setUp(self) -> None:
            self.weaver = pyweb.Weaver()
            self.weaver.reference\_style = pyweb.SimpleReference() 
            self.filepath = Path("testweaver") 
            self.aFileChunk = MockChunk("File", 123, 456)
            self.aFileChunk.referencedBy = []
            self.aChunk = MockChunk("Chunk", 314, 278)
            self.aChunk.referencedBy = [self.aFileChunk]
            self.aChunk.references.return\_value=[(self.aFileChunk.name, self.aFileChunk.seq)]
            
        def tearDown(self) -> None:
            try:
                self.filepath.with\_suffix('.rst').unlink()
            except OSError:
                pass
            
        def test\_weaver\_functions\_generic(self) -> None:
            result = self.weaver.quote("\|char\| \`code\` \*em\* \_em\_")
            self.assertEqual(r"\\\|char\\\| \\\`code\\\` \\\*em\\\* \\\_em\\\_", result)
            result = self.weaver.references(self.aChunk)
            self.assertEqual("File (\`123\`\_)", result)
            result = self.weaver.referenceTo("Chunk", 314)
            self.assertEqual(r"\|srarr\|\\ Chunk (\`314\`\_)", result)
            self.assertEqual(self.aFileChunk.mock\_calls, [])
            self.assertEqual(self.aChunk.mock\_calls, [call.references(self.weaver)])
      
        def test\_weaver\_should\_codeBegin(self) -> None:
            self.weaver.open(self.filepath)
            self.weaver.addIndent()
            self.weaver.codeBegin(self.aChunk)
            self.weaver.codeBlock(self.weaver.quote("\*The\* \`Code\`\\n"))
            self.weaver.clrIndent()
            self.weaver.codeEnd(self.aChunk)
            self.weaver.close()
            txt = self.filepath.with\_suffix(".rst").read\_text()
            self.assertEqual("\\n..  \_\`314\`:\\n..  rubric:: Chunk (314) =\\n..  parsed-literal::\\n    :class: code\\n\\n    \\\\\*The\\\\\* \\\\\`Code\\\\\`\\n\\n..\\n\\n    ..  class:: small\\n\\n        \|loz\| \*Chunk (314)\*. Used by: File (\`123\`\_)\\n", txt)
      
        def test\_weaver\_should\_fileBegin(self) -> None:
            self.weaver.open(self.filepath)
            self.weaver.fileBegin(self.aFileChunk)
            self.weaver.codeBlock(self.weaver.quote("\*The\* \`Code\`\\n"))
            self.weaver.fileEnd(self.aFileChunk)
            self.weaver.close()
            txt = self.filepath.with\_suffix(".rst").read\_text()
            self.assertEqual("\\n..  \_\`123\`:\\n..  rubric:: File (123) =\\n..  parsed-literal::\\n    :class: code\\n\\n    \\\\\*The\\\\\* \\\\\`Code\\\\\`\\n\\n..\\n\\n    ..  class:: small\\n\\n        \|loz\| \*File (123)\*.\\n", txt)
    
        def test\_weaver\_should\_xref(self) -> None:
            self.weaver.open(self.filepath)
            self.weaver.xrefHead( )
            self.weaver.xrefLine("Chunk", [ ("Container", 123) ])
            self.weaver.xrefFoot( )
            #self.weaver.fileEnd(self.aFileChunk) # Why?
            self.weaver.close()
            txt = self.filepath.with\_suffix(".rst").read\_text()
            self.assertEqual("\\n:Chunk:\\n    \|srarr\|\\\\ (\`('Container', 123)\`\_)\\n\\n", txt)
    
        def test\_weaver\_should\_xref\_def(self) -> None:
            self.weaver.open(self.filepath)
            self.weaver.xrefHead( )
            # Seems to have changed to a simple list of lines??
            self.weaver.xrefDefLine("Chunk", 314, [ 123, 567 ])
            self.weaver.xrefFoot( )
            #self.weaver.fileEnd(self.aFileChunk) # Why?
            self.weaver.close()
            txt = self.filepath.with\_suffix(".rst").read\_text()
            self.assertEqual("\\n:Chunk:\\n    \`123\`\_ [\`314\`\_] \`567\`\_\\n\\n", txt)

..

    ..  class:: small

        |loz| *Unit Test of Weaver subclass of Emitter (5)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.

We'll examine a few features of the LaTeX templates.


..  _`6`:
..  rubric:: Unit Test of LaTeX subclass of Emitter (6) =
..  parsed-literal::
    :class: code

     
    class TestLaTeX(unittest.TestCase):
        def setUp(self) -> None:
            self.weaver = pyweb.LaTeX()
            self.weaver.reference\_style = pyweb.SimpleReference() 
            self.filepath = Path("testweaver") 
            self.aFileChunk = MockChunk("File", 123, 456)
            self.aFileChunk.referencedBy = [ ]
            self.aChunk = MockChunk("Chunk", 314, 278)
            self.aChunk.referencedBy = [self.aFileChunk,]
            self.aChunk.references.return\_value=[(self.aFileChunk.name, self.aFileChunk.seq)]
    
        def tearDown(self) -> None:
            try:
                self.filepath.with\_suffix(".tex").unlink()
            except OSError:
                pass
                
        def test\_weaver\_functions\_latex(self) -> None:
            result = self.weaver.quote("\\\\end{Verbatim}")
            self.assertEqual("\\\\end\\\\,{Verbatim}", result)
            result = self.weaver.references(self.aChunk)
            expected = textwrap.indent(
                textwrap.dedent("""
                    \\\\footnotesize
                    Used by:
                    \\\\begin{list}{}{}
                        
                    \\\\item Code example File (123) (Sect. \\\\ref{pyweb123}, p. \\\\pageref{pyweb123})
                    
                    \\\\end{list}
                    \\\\normalsize
                """), 
            '    ')
            self.assertEqual(rstrip\_lines(expected), rstrip\_lines(result))
            result = self.weaver.referenceTo("Chunk", 314)
            self.assertEqual("$\\\\triangleright$ Code Example Chunk (314)", result)
            self.assertEqual(self.aFileChunk.mock\_calls, [])
            self.assertEqual(self.aChunk.mock\_calls, [call.references(self.weaver)])

..

    ..  class:: small

        |loz| *Unit Test of LaTeX subclass of Emitter (6)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


We'll examine a few features of the HTML templates.


..  _`7`:
..  rubric:: Unit Test of HTML subclass of Emitter (7) =
..  parsed-literal::
    :class: code

     
    class TestHTML(unittest.TestCase):
        def setUp(self) -> None:
            self.weaver = pyweb.HTML( )
            self.weaver.reference\_style = pyweb.SimpleReference() 
            self.filepath = Path("testweaver") 
            self.aFileChunk = MockChunk("File", 123, 456)
            self.aFileChunk.referencedBy = []
            self.aChunk = MockChunk("Chunk", 314, 278)
            self.aChunk.referencedBy = [self.aFileChunk,]
            self.aChunk.references.return\_value=[(self.aFileChunk.name, self.aFileChunk.seq)]
    
        def tearDown(self) -> None:
            try:
                self.filepath.with\_suffix(".html").unlink()
            except OSError:
                pass
                
        def test\_weaver\_functions\_html(self) -> None:
            result = self.weaver.quote("a < b && c > d")
            self.assertEqual("a &lt; b &amp;&amp; c &gt; d", result)
            result = self.weaver.references(self.aChunk)
            self.assertEqual('  Used by <a href="#pyweb123"><em>File</em>&nbsp;(123)</a>.', result)
            result = self.weaver.referenceTo("Chunk", 314)
            self.assertEqual('<a href="#pyweb314">&rarr;<em>Chunk</em> (314)</a>', result)
            self.assertEqual(self.aFileChunk.mock\_calls, [])
            self.assertEqual(self.aChunk.mock\_calls, [call.references(self.weaver)])
    

..

    ..  class:: small

        |loz| *Unit Test of HTML subclass of Emitter (7)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


The unique feature of the ``HTMLShort`` class is a template change.

    **TODO:** Test ``HTMLShort``.


..  _`8`:
..  rubric:: Unit Test of HTMLShort subclass of Emitter (8) =
..  parsed-literal::
    :class: code

    # TODO: Finish this
..

    ..  class:: small

        |loz| *Unit Test of HTMLShort subclass of Emitter (8)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


A Tangler emits the various named source files in proper format for the desired
compiler and language.


..  _`9`:
..  rubric:: Unit Test of Tangler subclass of Emitter (9) =
..  parsed-literal::
    :class: code

     
    class TestTangler(unittest.TestCase):
        def setUp(self) -> None:
            self.tangler = pyweb.Tangler()
            self.filepath = Path("testtangler.code") 
            self.aFileChunk = MockChunk("File", 123, 456)
            #self.aFileChunk.references\_list = [ ]
            self.aChunk = MockChunk("Chunk", 314, 278)
            #self.aChunk.references\_list = [ ("Container", 123) ]
        def tearDown(self) -> None:
            try:
                self.filepath.unlink()
            except FileNotFoundError:
                pass
            
        def test\_tangler\_functions(self) -> None:
            result = self.tangler.quote(string.printable)
            self.assertEqual(string.printable, result)
            
        def test\_tangler\_should\_codeBegin(self) -> None:
            self.tangler.open(self.filepath)
            self.tangler.codeBegin(self.aChunk)
            self.tangler.codeBlock(self.tangler.quote("\*The\* \`Code\`\\n"))
            self.tangler.codeEnd(self.aChunk)
            self.tangler.close()
            txt = self.filepath.read\_text()
            self.assertEqual("\*The\* \`Code\`\\n", txt)

..

    ..  class:: small

        |loz| *Unit Test of Tangler subclass of Emitter (9)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.





..  _`10`:
..  rubric:: Unit Test of TanglerMake subclass of Emitter (10) =
..  parsed-literal::
    :class: code

    
    class TestTanglerMake(unittest.TestCase):
        def setUp(self) -> None:
            self.tangler = pyweb.TanglerMake()
            self.filepath = Path("testtangler.code") 
            self.aChunk = MockChunk("Chunk", 314, 278)
            #self.aChunk.references\_list = [("Container", 123)]
            self.tangler.open(self.filepath)
            self.tangler.codeBegin(self.aChunk)
            self.tangler.codeBlock(self.tangler.quote("\*The\* \`Code\`\\n"))
            self.tangler.codeEnd(self.aChunk)
            self.tangler.close()
            self.time\_original = self.filepath.stat().st\_mtime
            self.original = self.filepath.stat()
            
        def tearDown(self) -> None:
            try:
                self.filepath.unlink()
            except OSError:
                pass
            
        def test\_same\_should\_leave(self) -> None:
            self.tangler.open(self.filepath)
            self.tangler.codeBegin(self.aChunk)
            self.tangler.codeBlock(self.tangler.quote("\*The\* \`Code\`\\n"))
            self.tangler.codeEnd(self.aChunk)
            self.tangler.close()
            self.assertTrue(os.path.samestat(self.original, self.filepath.stat()))
            #self.assertEqual(self.time\_original, self.filepath.stat().st\_mtime)
            
        def test\_different\_should\_update(self) -> None:
            self.tangler.open(self.filepath)
            self.tangler.codeBegin(self.aChunk)
            self.tangler.codeBlock(self.tangler.quote("\*Completely Different\* \`Code\`\\n"))
            self.tangler.codeEnd(self.aChunk)
            self.tangler.close()
            self.assertFalse(os.path.samestat(self.original, self.filepath.stat()))
            #self.assertNotEqual(self.time\_original, self.filepath.stat().st\_mtime)

..

    ..  class:: small

        |loz| *Unit Test of TanglerMake subclass of Emitter (10)*. Used by: Unit Test of Emitter class hierarchy... (`2`_)


Chunk Tests
------------

The Chunk and Command class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.



..  _`11`:
..  rubric:: Unit Test of Chunk class hierarchy (11) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Unit Test of Chunk superclass (`12`_), |srarr|\ (`13`_), |srarr|\ (`14`_), |srarr|\ (`15`_)
    |srarr|\ Unit Test of NamedChunk subclass (`19`_)
    |srarr|\ Unit Test of NamedChunk_Noindent subclass (`20`_)
    |srarr|\ Unit Test of OutputChunk subclass (`21`_)
    |srarr|\ Unit Test of NamedDocumentChunk subclass (`22`_)

..

    ..  class:: small

        |loz| *Unit Test of Chunk class hierarchy (11)*. Used by: test_unit.py (`1`_)


In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
mock objects for all of these relationships in which a Chunk participates.

A MockCommand can be attached to a Chunk.


..  _`12`:
..  rubric:: Unit Test of Chunk superclass (12) =
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

        |loz| *Unit Test of Chunk superclass (12)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


A MockWeb can contain a Chunk.


..  _`13`:
..  rubric:: Unit Test of Chunk superclass (13) +=
..  parsed-literal::
    :class: code

    
    
    def mock\_web\_instance() -> Mock:
        web = Mock(
            name="Web instance",
            chunks=[],
            add=Mock(return\_value=None),
            addNamed=Mock(return\_value=None),
            addOutput=Mock(return\_value=None),
            fullNameFor=Mock(side\_effect=lambda name: name),
            fileXref=Mock(return\_value={'file': [1,2,3]}),
            chunkXref=Mock(return\_value={'chunk': [4,5,6]}),
            userNamesXref=Mock(return\_value={'name': (7, [8,9,10])}),
            getchunk=Mock(side\_effect=lambda name: [MockChunk(name, 1, 314)]),
            createUsedBy=Mock(),
            weaveChunk=Mock(side\_effect=lambda name, weaver: weaver.write(name)),
            weave=Mock(return\_value=None),
            tangle=Mock(return\_value=None),
        )
        return web
    
    MockWeb = Mock(
        name="Web class",
        side\_effect=mock\_web\_instance
    )

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (13)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


A MockWeaver or MockTangler appear to process a Chunk.
We can interrogate the ``mock_calls`` to be sure the right things were done.

We need to permit ``__enter__()`` and ``__exit__()``,
which leads to a multi-step instance.
The initial instance with ``__enter__()`` that
returns the context manager instance.



..  _`14`:
..  rubric:: Unit Test of Chunk superclass (14) +=
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

        |loz| *Unit Test of Chunk superclass (14)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


A Chunk is built, interrogated and then emitted.


..  _`15`:
..  rubric:: Unit Test of Chunk superclass (15) +=
..  parsed-literal::
    :class: code

    
    class TestChunk(unittest.TestCase):
        def setUp(self) -> None:
            self.theChunk = pyweb.Chunk()
            
        |srarr|\ Unit Test of Chunk construction (`16`_)
        
        |srarr|\ Unit Test of Chunk interrogation (`17`_)
        
        |srarr|\ Unit Test of Chunk emission (`18`_)

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (15)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


Can we build a Chunk?


..  _`16`:
..  rubric:: Unit Test of Chunk construction (16) =
..  parsed-literal::
    :class: code

    
    def test\_append\_command\_should\_work(self) -> None:
        cmd1 = MockCommand()
        self.theChunk.append(cmd1)
        self.assertEqual(1, len(self.theChunk.commands))
        self.assertEqual(cmd1.chunk, self.theChunk)
        
        cmd2 = MockCommand()
        self.theChunk.append(cmd2)
        self.assertEqual(2, len(self.theChunk.commands))
        self.assertEqual(cmd2.chunk, self.theChunk)
    
    def test\_append\_initial\_and\_more\_text\_should\_work(self) -> None:
        self.theChunk.appendText("hi mom")
        self.assertEqual(1, len(self.theChunk.commands))
        self.theChunk.appendText("&more text")
        self.assertEqual(1, len(self.theChunk.commands))
        self.assertEqual("hi mom&more text", self.theChunk.commands[0].text)
        
    def test\_append\_following\_text\_should\_work(self) -> None:
        cmd1 = MockCommand()
        self.theChunk.append(cmd1)
        self.theChunk.appendText("hi mom")
        self.assertEqual(2, len(self.theChunk.commands))
        assert cmd1.chunk == self.theChunk
    
    def test\_append\_chunk\_to\_web\_should\_work(self) -> None:
        web = MockWeb()
        self.theChunk.webAdd(web)
        self.assertEqual(web.add.mock\_calls, [call(self.theChunk)])

..

    ..  class:: small

        |loz| *Unit Test of Chunk construction (16)*. Used by: Unit Test of Chunk superclass... (`15`_)


Can we interrogate a Chunk?


..  _`17`:
..  rubric:: Unit Test of Chunk interrogation (17) =
..  parsed-literal::
    :class: code

    
    def test\_leading\_command\_should\_not\_find(self) -> None:
        self.assertFalse(self.theChunk.startswith("hi mom"))
        cmd1 = MockCommand()
        self.theChunk.append(cmd1)
        self.assertFalse(self.theChunk.startswith("hi mom"))
        self.theChunk.appendText("hi mom")
        self.assertEqual(2, len(self.theChunk.commands) )
        self.assertFalse(self.theChunk.startswith("hi mom"))
        
    def test\_leading\_text\_should\_not\_find(self) -> None:
        self.assertFalse(self.theChunk.startswith("hi mom"))
        self.theChunk.appendText("hi mom")
        self.assertTrue(self.theChunk.startswith("hi mom"))
        cmd1 = MockCommand()
        self.theChunk.append(cmd1)
        self.assertTrue(self.theChunk.startswith("hi mom"))
        self.assertEqual(2, len(self.theChunk.commands) )
    
    def test\_regexp\_exists\_should\_find(self) -> None:
        self.theChunk.appendText("this chunk has many words")
        pat = re.compile(r"\\Wchunk\\W")
        found = self.theChunk.searchForRE(pat)
        self.assertTrue(found is self.theChunk)
        
    def test\_regexp\_missing\_should\_not\_find(self):
        self.theChunk.appendText("this chunk has many words")
        pat = re.compile(r"\\Warpigs\\W")
        found = self.theChunk.searchForRE(pat)
        self.assertTrue(found is None)
        
    def test\_lineNumber\_should\_work(self) -> None:
        self.assertTrue(self.theChunk.lineNumber is None)
        cmd1 = MockCommand()
        self.theChunk.append(cmd1)
        self.assertEqual(314, self.theChunk.lineNumber)

..

    ..  class:: small

        |loz| *Unit Test of Chunk interrogation (17)*. Used by: Unit Test of Chunk superclass... (`15`_)


Can we emit a Chunk with a weaver or tangler?


..  _`18`:
..  rubric:: Unit Test of Chunk emission (18) =
..  parsed-literal::
    :class: code

    
    def test\_weave\_chunk\_should\_work(self) -> None:
        wvr = MockWeaver()
        web = MockWeb()
        self.theChunk.appendText("this chunk has very & many words")
        self.theChunk.weave(web, wvr)
        self.assertEqual(wvr.docBegin.mock\_calls, [call(self.theChunk)])
        self.assertEqual(wvr.write.mock\_calls, [call("this chunk has very & many words")])
        self.assertEqual(wvr.docEnd.mock\_calls, [call(self.theChunk)])
        
    def test\_tangle\_should\_fail(self) -> None:
        tnglr = MockTangler()
        web = MockWeb()
        self.theChunk.appendText("this chunk has very & many words")
        try:
            self.theChunk.tangle(web, tnglr)
            self.fail()
        except pyweb.Error as e:
            self.assertEqual("Cannot tangle an anonymous chunk", e.args[0])

..

    ..  class:: small

        |loz| *Unit Test of Chunk emission (18)*. Used by: Unit Test of Chunk superclass... (`15`_)


The ``NamedChunk`` is created by a ``@d`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`19`:
..  rubric:: Unit Test of NamedChunk subclass (19) =
..  parsed-literal::
    :class: code

     
    class TestNamedChunk(unittest.TestCase):
        def setUp(self) -> None:
            self.theChunk = pyweb.NamedChunk("Some Name...")
            cmd = self.theChunk.makeContent("the words & text of this Chunk")
            self.theChunk.append(cmd)
            self.theChunk.setUserIDRefs("index terms")
            
        def test\_should\_find\_xref\_words(self) -> None:
            self.assertEqual(2, len(self.theChunk.getUserIDRefs()))
            self.assertEqual("index", self.theChunk.getUserIDRefs()[0])
            self.assertEqual("terms", self.theChunk.getUserIDRefs()[1])
            
        def test\_append\_named\_chunk\_to\_web\_should\_work(self) -> None:
            web = MockWeb()
            self.theChunk.webAdd(web)
            self.assertEqual(web.addNamed.mock\_calls, [call(self.theChunk)])
    
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.theChunk.weave(web, wvr)
            self.assertEqual(wvr.codeBegin.mock\_calls, [call(self.theChunk)])
            self.assertEqual(wvr.quote.mock\_calls, [call('the words & text of this Chunk')])
            self.assertEqual(wvr.codeBlock.mock\_calls, [call('quoted')])
            self.assertEqual(wvr.codeEnd.mock\_calls, [call(self.theChunk)])
    
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            self.theChunk.tangle(web, tnglr)
            self.assertEqual(tnglr.codeBegin.mock\_calls, [call(self.theChunk)])
            self.assertEqual(tnglr.codeBlock.mock\_calls, [call("the words & text of this Chunk")])
            self.assertEqual(tnglr.codeEnd.mock\_calls, [call(self.theChunk)])      

..

    ..  class:: small

        |loz| *Unit Test of NamedChunk subclass (19)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)



..  _`20`:
..  rubric:: Unit Test of NamedChunk_Noindent subclass (20) =
..  parsed-literal::
    :class: code

    
    class TestNamedChunk\_Noindent(unittest.TestCase):
        def setUp(self) -> None:
            self.theChunk = pyweb.NamedChunk\_Noindent("NoIndent Name...")
            cmd = self.theChunk.makeContent("the words & text of this Chunk")
            self.theChunk.append(cmd)
            self.theChunk.setUserIDRefs("index terms")
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            self.theChunk.tangle(web, tnglr)
    
            self.assertEqual(tnglr.mock\_calls, [
                    call.codeBegin(self.theChunk),
                    call.codeBlock('the words & text of this Chunk'),
                    call.codeEnd(self.theChunk)
                ]
            )

..

    ..  class:: small

        |loz| *Unit Test of NamedChunk_Noindent subclass (20)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)



The ``OutputChunk`` is created by a ``@o`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`21`:
..  rubric:: Unit Test of OutputChunk subclass (21) =
..  parsed-literal::
    :class: code

    
    class TestOutputChunk(unittest.TestCase):
        def setUp(self) -> None:
            self.theChunk = pyweb.OutputChunk("filename", "#", "")
            cmd = self.theChunk.makeContent("the words & text of this Chunk")
            self.theChunk.append(cmd)
            self.theChunk.setUserIDRefs("index terms")
            
        def test\_append\_output\_chunk\_to\_web\_should\_work(self) -> None:
            web = MockWeb()
            self.theChunk.webAdd(web)
            self.assertEqual(web.addOutput.mock\_calls, [call(self.theChunk)])
    
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.theChunk.weave(web, wvr)
            self.assertEqual(wvr.mock\_calls, [
                    call.fileBegin(self.theChunk),
                    call.quote('the words & text of this Chunk'),
                    call.codeBlock('quoted'),
                    call.fileEnd(self.theChunk)
                ]
            )
            
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            self.theChunk.tangle(web, tnglr)
            self.assertEqual(tnglr.mock\_calls, [
                    call.codeBegin(self.theChunk),
                    call.codeBlock('the words & text of this Chunk'),
                    call.codeEnd(self.theChunk)
                ]
            )

..

    ..  class:: small

        |loz| *Unit Test of OutputChunk subclass (21)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


The ``NamedDocumentChunk`` is a little-used feature.

    **TODO** Test ``NamedDocumentChunk``.


..  _`22`:
..  rubric:: Unit Test of NamedDocumentChunk subclass (22) =
..  parsed-literal::
    :class: code

    # TODO Test This 
..

    ..  class:: small

        |loz| *Unit Test of NamedDocumentChunk subclass (22)*. Used by: Unit Test of Chunk class hierarchy... (`11`_)


Command Tests
---------------


..  _`23`:
..  rubric:: Unit Test of Command class hierarchy (23) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Unit Test of Command superclass (`24`_)
    |srarr|\ Unit Test of TextCommand class to contain a document text block (`25`_)
    |srarr|\ Unit Test of CodeCommand class to contain a program source code block (`26`_)
    |srarr|\ Unit Test of XrefCommand superclass for all cross-reference commands (`27`_)
    |srarr|\ Unit Test of FileXrefCommand class for an output file cross-reference (`28`_)
    |srarr|\ Unit Test of MacroXrefCommand class for a named chunk cross-reference (`29`_)
    |srarr|\ Unit Test of UserIdXrefCommand class for a user identifier cross-reference (`30`_)
    |srarr|\ Unit Test of ReferenceCommand class for chunk references (`31`_)

..

    ..  class:: small

        |loz| *Unit Test of Command class hierarchy (23)*. Used by: test_unit.py (`1`_)


This Command superclass is essentially an inteface definition, it
has no real testable features.


..  _`24`:
..  rubric:: Unit Test of Command superclass (24) =
..  parsed-literal::
    :class: code

    # No Tests
..

    ..  class:: small

        |loz| *Unit Test of Command superclass (24)*. Used by: Unit Test of Command class hierarchy... (`23`_)


A TextCommand object must be constructed, interrogated and emitted.


..  _`25`:
..  rubric:: Unit Test of TextCommand class to contain a document text block (25) =
..  parsed-literal::
    :class: code

     
    class TestTextCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.cmd = pyweb.TextCommand("Some text & words in the document\\n    ", 314)
            self.cmd2 = pyweb.TextCommand("No Indent\\n", 314)
        def test\_methods\_should\_work(self) -> None:
            self.assertTrue(self.cmd.startswith("Some"))
            self.assertFalse(self.cmd.startswith("text"))
            pat1 = re.compile(r"\\Wthe\\W")
            self.assertTrue(self.cmd.searchForRE(pat1) is not None)
            pat2 = re.compile(r"\\Wnothing\\W")
            self.assertTrue(self.cmd.searchForRE(pat2) is None)
            self.assertEqual(4, self.cmd.indent())
            self.assertEqual(0, self.cmd2.indent())
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.write.mock\_calls, [call('Some text & words in the document\\n    ')])
            
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            self.cmd.tangle(web, tnglr)
            self.assertEqual(tnglr.write.mock\_calls, [call('Some text & words in the document\\n    ')])

..

    ..  class:: small

        |loz| *Unit Test of TextCommand class to contain a document text block (25)*. Used by: Unit Test of Command class hierarchy... (`23`_)


A CodeCommand object is a TextCommand with different processing for being emitted.


..  _`26`:
..  rubric:: Unit Test of CodeCommand class to contain a program source code block (26) =
..  parsed-literal::
    :class: code

    
    class TestCodeCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.cmd = pyweb.CodeCommand("Some text & words in the document\\n    ", 314)
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.codeBlock.mock\_calls, [call('quoted')])
            
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            self.cmd.tangle(web, tnglr)
            self.assertEqual(tnglr.codeBlock.mock\_calls, [call('Some text & words in the document\\n    ')])

..

    ..  class:: small

        |loz| *Unit Test of CodeCommand class to contain a program source code block (26)*. Used by: Unit Test of Command class hierarchy... (`23`_)


The XrefCommand class is largely abstract.


..  _`27`:
..  rubric:: Unit Test of XrefCommand superclass for all cross-reference commands (27) =
..  parsed-literal::
    :class: code

    # No Tests 
..

    ..  class:: small

        |loz| *Unit Test of XrefCommand superclass for all cross-reference commands (27)*. Used by: Unit Test of Command class hierarchy... (`23`_)


The FileXrefCommand command is expanded by a weaver to a list of ``@o``
locations.


..  _`28`:
..  rubric:: Unit Test of FileXrefCommand class for an output file cross-reference (28) =
..  parsed-literal::
    :class: code

     
    class TestFileXRefCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.cmd = pyweb.FileXrefCommand(314)
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.mock\_calls, [call.xrefHead(), call.xrefLine('file', [1, 2, 3]), call.xrefFoot()])
            
        def test\_tangle\_should\_fail(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle(web, tnglr)
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of FileXrefCommand class for an output file cross-reference (28)*. Used by: Unit Test of Command class hierarchy... (`23`_)


The MacroXrefCommand command is expanded by a weaver to a list of all ``@d``
locations.


..  _`29`:
..  rubric:: Unit Test of MacroXrefCommand class for a named chunk cross-reference (29) =
..  parsed-literal::
    :class: code

    
    class TestMacroXRefCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.cmd = pyweb.MacroXrefCommand(314)
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.mock\_calls, [call.xrefHead(), call.xrefLine('chunk', [4, 5, 6]), call.xrefFoot()])
    
        def test\_tangle\_should\_fail(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle(web, tnglr)
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of MacroXrefCommand class for a named chunk cross-reference (29)*. Used by: Unit Test of Command class hierarchy... (`23`_)


The UserIdXrefCommand command is expanded by a weaver to a list of all ``@|``
names.


..  _`30`:
..  rubric:: Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30) =
..  parsed-literal::
    :class: code

    
    class TestUserIdXrefCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.cmd = pyweb.UserIdXrefCommand(314)
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.mock\_calls, [call.xrefHead(), call.xrefDefLine('name', 7, [8, 9, 10]), call.xrefFoot()])
            
        def test\_tangle\_should\_fail(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle(web, tnglr)
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30)*. Used by: Unit Test of Command class hierarchy... (`23`_)


Reference commands require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled.


..  _`31`:
..  rubric:: Unit Test of ReferenceCommand class for chunk references (31) =
..  parsed-literal::
    :class: code

     
    class TestReferenceCommand(unittest.TestCase):
        def setUp(self) -> None:
            self.chunk = MockChunk("Owning Chunk", 123, 456)
            self.cmd = pyweb.ReferenceCommand("Some Name", 314)
            self.cmd.chunk = self.chunk
            self.chunk.commands.append(self.cmd)
            self.chunk.previous\_command = pyweb.TextCommand("", self.chunk.commands[0].lineNumber)
            
        def test\_weave\_should\_work(self) -> None:
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave(web, wvr)
            self.assertEqual(wvr.write.mock\_calls, [call('Some Name')])
    
        def test\_tangle\_should\_work(self) -> None:
            tnglr = MockTangler()
            web = MockWeb()
            web.add(self.chunk)
            self.cmd.tangle(web, tnglr)
            self.assertEqual(tnglr.write.mock\_calls, [call('Some Name')])
    

..

    ..  class:: small

        |loz| *Unit Test of ReferenceCommand class for chunk references (31)*. Used by: Unit Test of Command class hierarchy... (`23`_)


Reference Tests
----------------

The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.

The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.



..  _`32`:
..  rubric:: Unit Test of Reference class hierarchy (32) =
..  parsed-literal::
    :class: code

     
    class TestReference(unittest.TestCase):
        def setUp(self) -> None:
            self.web = MockWeb()
            self.main = MockChunk("Main", 1, 11)
            self.parent = MockChunk("Parent", 2, 22)
            self.parent.referencedBy = [ self.main ]
            self.chunk = MockChunk("Sub", 3, 33)
            self.chunk.referencedBy = [ self.parent ]
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

        |loz| *Unit Test of Reference class hierarchy (32)*. Used by: test_unit.py (`1`_)


Web Tests
-----------

This is more difficult to create mocks for.


..  _`33`:
..  rubric:: Unit Test of Web class (33) =
..  parsed-literal::
    :class: code

     
    class TestWebConstruction(unittest.TestCase):
        def setUp(self) -> None:
            self.web = pyweb.Web()
        |srarr|\ Unit Test Web class construction methods (`34`_)
        
    class TestWebProcessing(unittest.TestCase):
        def setUp(self) -> None:
            self.web = pyweb.Web()
            self.web.web\_path = Path("TestWebProcessing.w")
            self.chunk = pyweb.Chunk()
            self.chunk.appendText("some text")
            self.chunk.webAdd(self.web)
            self.out = pyweb.OutputChunk("A File")
            self.out.appendText("some code")
            nm = self.web.addDefName("A Chunk")
            self.out.append(pyweb.ReferenceCommand(nm))
            self.out.webAdd(self.web)
            self.named = pyweb.NamedChunk("A Chunk...")
            self.named.appendText("some user2a code")
            self.named.setUserIDRefs("user1")
            nm = self.web.addDefName("Another Chunk")
            self.named.append(pyweb.ReferenceCommand(nm))
            self.named.webAdd(self.web)
            self.named2 = pyweb.NamedChunk("Another Chunk...")
            self.named2.appendText("some user1 code")
            self.named2.setUserIDRefs("user2a user2b")
            self.named2.webAdd(self.web)
        |srarr|\ Unit Test Web class name resolution methods (`35`_)
        |srarr|\ Unit Test Web class chunk cross-reference (`36`_)
        |srarr|\ Unit Test Web class tangle (`37`_)
        |srarr|\ Unit Test Web class weave (`38`_)

..

    ..  class:: small

        |loz| *Unit Test of Web class (33)*. Used by: test_unit.py (`1`_)



..  _`34`:
..  rubric:: Unit Test Web class construction methods (34) =
..  parsed-literal::
    :class: code

    
    def test\_names\_definition\_should\_resolve(self) -> None:
        name1 = self.web.addDefName("A Chunk...")
        self.assertTrue(name1 is None)
        self.assertEqual(0, len(self.web.named))
        name2 = self.web.addDefName("A Chunk Of Code")
        self.assertEqual("A Chunk Of Code", name2)
        self.assertEqual(1, len(self.web.named))
        name3 = self.web.addDefName("A Chunk...")
        self.assertEqual("A Chunk Of Code", name3)
        self.assertEqual(1, len(self.web.named))
        
    def test\_chunks\_should\_add\_and\_index(self) -> None:
        chunk = pyweb.Chunk()
        chunk.appendText("some text")
        chunk.webAdd(self.web)
        self.assertEqual(1, len(self.web.chunkSeq))
        self.assertEqual(0, len(self.web.named))
        self.assertEqual(0, len(self.web.output))
        named = pyweb.NamedChunk("A Chunk")
        named.appendText("some code")
        named.webAdd(self.web)
        self.assertEqual(2, len(self.web.chunkSeq))
        self.assertEqual(1, len(self.web.named))
        self.assertEqual(0, len(self.web.output))
        out = pyweb.OutputChunk("A File")
        out.appendText("some code")
        out.webAdd(self.web)
        self.assertEqual(3, len(self.web.chunkSeq))
        self.assertEqual(1, len(self.web.named))
        self.assertEqual(1, len(self.web.output))

..

    ..  class:: small

        |loz| *Unit Test Web class construction methods (34)*. Used by: Unit Test of Web class... (`33`_)



..  _`35`:
..  rubric:: Unit Test Web class name resolution methods (35) =
..  parsed-literal::
    :class: code

     
    def test\_name\_queries\_should\_resolve(self) -> None:
        self.assertEqual("A Chunk", self.web.fullNameFor("A C..."))    
        self.assertEqual("A Chunk", self.web.fullNameFor("A Chunk"))    
        self.assertNotEqual("A Chunk", self.web.fullNameFor("A File"))
        self.assertTrue(self.named is self.web.getchunk("A C...")[0])
        self.assertTrue(self.named is self.web.getchunk("A Chunk")[0])
        try:
            self.assertTrue(None is not self.web.getchunk("A File"))
            self.fail()
        except pyweb.Error as e:
            self.assertTrue(e.args[0].startswith("Cannot resolve 'A File'"))  

..

    ..  class:: small

        |loz| *Unit Test Web class name resolution methods (35)*. Used by: Unit Test of Web class... (`33`_)



..  _`36`:
..  rubric:: Unit Test Web class chunk cross-reference (36) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_createUsedBy(self) -> None:
        self.web.createUsedBy()
        # If it raises an exception, the web structure is damaged
        
    def test\_valid\_web\_should\_createFileXref(self) -> None:
        file\_xref = self.web.fileXref()
        self.assertEqual(1, len(file\_xref))
        self.assertTrue("A File" in file\_xref) 
        self.assertTrue(1, len(file\_xref["A File"]))
        
    def test\_valid\_web\_should\_createChunkXref(self) -> None:
        chunk\_xref = self.web.chunkXref()
        self.assertEqual(2, len(chunk\_xref))
        self.assertTrue("A Chunk" in chunk\_xref)
        self.assertEqual(1, len(chunk\_xref["A Chunk"]))
        self.assertTrue("Another Chunk" in chunk\_xref)
        self.assertEqual(1, len(chunk\_xref["Another Chunk"]))
        self.assertFalse("Not A Real Chunk" in chunk\_xref)
        
    def test\_valid\_web\_should\_create\_userNamesXref(self) -> None:
        user\_xref = self.web.userNamesXref() 
        self.assertEqual(3, len(user\_xref))
        self.assertTrue("user1" in user\_xref)
        defn, reflist = user\_xref["user1"]
        self.assertEqual(1, len(reflist), "did not find user1")
        self.assertTrue("user2a" in user\_xref)
        defn, reflist = user\_xref["user2a"]
        self.assertEqual(1, len(reflist), "did not find user2a")
        self.assertTrue("user2b" in user\_xref)
        defn, reflist = user\_xref["user2b"]
        self.assertEqual(0, len(reflist))
        self.assertFalse("Not A User Symbol" in user\_xref)

..

    ..  class:: small

        |loz| *Unit Test Web class chunk cross-reference (36)*. Used by: Unit Test of Web class... (`33`_)



..  _`37`:
..  rubric:: Unit Test Web class tangle (37) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_tangle(self) -> None:
        tangler = MockTangler()
        self.web.tangle(tangler)
        self.assertEqual(tangler.codeBlock.mock\_calls, [
                call('some code'),
                call('some user2a code'),
                call('some user1 code'),
            ]
        )

..

    ..  class:: small

        |loz| *Unit Test Web class tangle (37)*. Used by: Unit Test of Web class... (`33`_)



..  _`38`:
..  rubric:: Unit Test Web class weave (38) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_weave(self) -> None:
        weaver = MockWeaver()
        self.web.weave(weaver)
        self.assertEqual(weaver.write.mock\_calls, [
                call('some text'),
            ]
        )
        self.assertEqual(weaver.quote.mock\_calls, [
                call('some code'),
                call('some user2a code'),
                call('some user1 code'),
            ]
        )

..

    ..  class:: small

        |loz| *Unit Test Web class weave (38)*. Used by: Unit Test of Web class... (`33`_)



WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

We should test this through some clever mocks that produce the
proper sequence of tokens to parse the various kinds of Commands.


..  _`39`:
..  rubric:: Unit Test of WebReader class (39) =
..  parsed-literal::
    :class: code

    
    # Tested via functional tests

..

    ..  class:: small

        |loz| *Unit Test of WebReader class (39)*. Used by: test_unit.py (`1`_)


Some lower-level units: specifically the tokenizer and the option parser.


..  _`40`:
..  rubric:: Unit Test of WebReader class (40) +=
..  parsed-literal::
    :class: code

    
    class TestTokenizer(unittest.TestCase):
        def test\_should\_split\_tokens(self) -> None:
            input = io.StringIO("@@ word @{ @[ @< @>\\n@] @} @i @\| @m @f @u\\n")
            self.tokenizer = pyweb.Tokenizer(input)
            tokens = list(self.tokenizer)
            self.assertEqual(24, len(tokens))
            self.assertEqual( ['@@', ' word ', '@{', ' ', '@[', ' ', '@<', ' ', 
            '@>', '\\n', '@]', ' ', '@}', ' ', '@i', ' ', '@\|', ' ', '@m', ' ', 
            '@f', ' ', '@u', '\\n'], tokens )
            self.assertEqual(2, self.tokenizer.lineNumber)

..

    ..  class:: small

        |loz| *Unit Test of WebReader class (40)*. Used by: test_unit.py (`1`_)



..  _`41`:
..  rubric:: Unit Test of WebReader class (41) +=
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

        |loz| *Unit Test of WebReader class (41)*. Used by: test_unit.py (`1`_)



Action Tests
-------------

Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  


..  _`42`:
..  rubric:: Unit Test of Action class hierarchy (42) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Unit test of Action Sequence class (`43`_)
    |srarr|\ Unit test of LoadAction class (`46`_)
    |srarr|\ Unit test of TangleAction class (`45`_)
    |srarr|\ Unit test of WeaverAction class (`44`_)

..

    ..  class:: small

        |loz| *Unit Test of Action class hierarchy (42)*. Used by: test_unit.py (`1`_)


**TODO:** Replace with Mock


..  _`43`:
..  rubric:: Unit test of Action Sequence class (43) =
..  parsed-literal::
    :class: code

    
    class TestActionSequence(unittest.TestCase):
        def setUp(self) -> None:
            self.web = MockWeb()
            self.a1 = MagicMock(name="Action1")
            self.a2 = MagicMock(name="Action2")
            self.action = pyweb.ActionSequence("TwoSteps", [self.a1, self.a2])
            self.action.web = self.web
            self.action.options = argparse.Namespace()
        def test\_should\_execute\_both(self) -> None:
            self.action()
            self.assertEqual(self.a1.call\_count, 1)
            self.assertEqual(self.a2.call\_count, 1)

..

    ..  class:: small

        |loz| *Unit test of Action Sequence class (43)*. Used by: Unit Test of Action class hierarchy... (`42`_)



..  _`44`:
..  rubric:: Unit test of WeaverAction class (44) =
..  parsed-literal::
    :class: code

     
    class TestWeaveAction(unittest.TestCase):
        def setUp(self) -> None:
            self.web = MockWeb()
            self.action = pyweb.WeaveAction()
            self.weaver = MockWeaver()
            self.action.web = self.web
            self.action.options = argparse.Namespace( 
                theWeaver=self.weaver,
                reference\_style=pyweb.SimpleReference(),
                output=Path.cwd(),
            )
        def test\_should\_execute\_weaving(self) -> None:
            self.action()
            self.assertEqual(self.web.weave.mock\_calls, [call(self.weaver)])

..

    ..  class:: small

        |loz| *Unit test of WeaverAction class (44)*. Used by: Unit Test of Action class hierarchy... (`42`_)



..  _`45`:
..  rubric:: Unit test of TangleAction class (45) =
..  parsed-literal::
    :class: code

     
    class TestTangleAction(unittest.TestCase):
        def setUp(self) -> None:
            self.web = MockWeb()
            self.action = pyweb.TangleAction()
            self.tangler = MockTangler()
            self.action.web = self.web
            self.action.options = argparse.Namespace( 
                theTangler = self.tangler,
                tangler\_line\_numbers = False, 
                output=Path.cwd()
            )
        def test\_should\_execute\_tangling(self) -> None:
            self.action()
            self.assertEqual(self.web.tangle.mock\_calls, [call(self.tangler)])

..

    ..  class:: small

        |loz| *Unit test of TangleAction class (45)*. Used by: Unit Test of Action class hierarchy... (`42`_)


The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.


..  _`46`:
..  rubric:: Unit test of LoadAction class (46) =
..  parsed-literal::
    :class: code

     
    class TestLoadAction(unittest.TestCase):
        def setUp(self) -> None:
            self.web = MockWeb()
            self.action = pyweb.LoadAction()
            self.webReader = Mock(
                name="WebReader",
                errors=0,
            )
            self.action.web = self.web
            self.source\_path = Path("TestLoadAction.w")
            self.action.options = argparse.Namespace( 
                webReader = self.webReader, 
                source\_path=self.source\_path,
                command="@",
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
            self.action()
            # Old: self.assertEqual(1, self.webReader.count)
            print(self.webReader.load.mock\_calls)
            self.assertEqual(self.webReader.load.mock\_calls, [call(self.web, self.source\_path)])
            self.webReader.web.assert\_not\_called()  # Deprecated
            self.webReader.source.assert\_not\_called()  # Deprecated

..

    ..  class:: small

        |loz| *Unit test of LoadAction class (46)*. Used by: Unit Test of Action class hierarchy... (`42`_)


Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.

**TODO:** Test Application class


..  _`47`:
..  rubric:: Unit Test of Application class (47) =
..  parsed-literal::
    :class: code

    # TODO Test Application class 
..

    ..  class:: small

        |loz| *Unit Test of Application class (47)*. Used by: test_unit.py (`1`_)


Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.


..  _`48`:
..  rubric:: Unit Test overheads: imports, etc. (48) =
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
    from typing import Any, TextIO
    import unittest
    from unittest.mock import Mock, call, MagicMock, sentinel
    import warnings
    
    import pyweb

..

    ..  class:: small

        |loz| *Unit Test overheads: imports, etc. (48)*. Used by: test_unit.py (`1`_)


One more overhead is a function we can inject into selected subclasses
of ``unittest.TestCase``. This is monkeypatch feature that seems useful.


..  _`49`:
..  rubric:: Unit Test overheads: imports, etc. (49) +=
..  parsed-literal::
    :class: code

    
    def rstrip\_lines(source: str) -> list[str]:
        return list(l.rstrip() for l in source.splitlines())    

..

    ..  class:: small

        |loz| *Unit Test overheads: imports, etc. (49)*. Used by: test_unit.py (`1`_)



..  _`50`:
..  rubric:: Unit Test main (50) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)
        unittest.main()

..

    ..  class:: small

        |loz| *Unit Test main (50)*. Used by: test_unit.py (`1`_)


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


..  _`51`:
..  rubric:: test_loader.py (51) =
..  parsed-literal::
    :class: code

    |srarr|\ Load Test overheads: imports, etc. (`53`_), |srarr|\ (`58`_)
    
    |srarr|\ Load Test superclass to refactor common setup (`52`_)
    
    |srarr|\ Load Test error handling with a few common syntax errors (`54`_)
    
    |srarr|\ Load Test include processing with syntax errors (`56`_)
    
    |srarr|\ Load Test main program (`59`_)

..

    ..  class:: small

        |loz| *test_loader.py (51)*.


Parsing test cases have a common setup shown in this superclass.

By using some class-level variables ``text``,
``file_path``, we can simply provide a file-like
input object to the ``WebReader`` instance.


..  _`52`:
..  rubric:: Load Test superclass to refactor common setup (52) =
..  parsed-literal::
    :class: code

    
    class ParseTestcase(unittest.TestCase):
        text: ClassVar[str]
        file\_path: ClassVar[Path]
        
        def setUp(self) -> None:
            self.source = io.StringIO(self.text)
            self.web = pyweb.Web()
            self.rdr = pyweb.WebReader()

..

    ..  class:: small

        |loz| *Load Test superclass to refactor common setup (52)*. Used by: test_loader.py (`51`_)


There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.


..  _`53`:
..  rubric:: Load Test overheads: imports, etc. (53) =
..  parsed-literal::
    :class: code

    
    import logging.handlers
    from pathlib import Path
    from typing import ClassVar

..

    ..  class:: small

        |loz| *Load Test overheads: imports, etc. (53)*. Used by: test_loader.py (`51`_)



..  _`54`:
..  rubric:: Load Test error handling with a few common syntax errors (54) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 1 with correct and incorrect syntax (`55`_)
    
    class Test\_ParseErrors(ParseTestcase):
        text = test1\_w
        file\_path = Path("test1.w")
        def test\_error\_should\_count\_1(self) -> None:
            with self.assertLogs('WebReader', level='WARN') as log\_capture:
                self.rdr.load(self.web, self.file\_path, self.source)
            self.assertEqual(3, self.rdr.errors)
            self.assertEqual(log\_capture.output, 
                [
                    "ERROR:WebReader:At ('test1.w', 8): expected ('@{',), found '@o'",
                    "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)",
                    "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)"
                ]
            )

..

    ..  class:: small

        |loz| *Load Test error handling with a few common syntax errors (54)*. Used by: test_loader.py (`51`_)



..  _`55`:
..  rubric:: Sample Document 1 with correct and incorrect syntax (55) =
..  parsed-literal::
    :class: code

    
    test1\_w = """Some anonymous chunk
    @o test1.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    Okay, now for an error.
    @o show how @o commands work
    @{ @{ @] @]
    """

..

    ..  class:: small

        |loz| *Sample Document 1 with correct and incorrect syntax (55)*. Used by: Load Test error handling... (`54`_)


All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

In order to test the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing,
since it's a nested instance of the tokenizer.


..  _`56`:
..  rubric:: Load Test include processing with syntax errors (56) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 8 and the file it includes (`57`_)
    
    class Test\_IncludeParseErrors(ParseTestcase):
        text = test8\_w
        file\_path = Path("test8.w")
        def setUp(self) -> None:
            super().setUp()
            Path('test8\_inc.tmp').write\_text(test8\_inc\_w)
        def test\_error\_should\_count\_2(self) -> None:
            with self.assertLogs('WebReader', level='WARN') as log\_capture:
                self.rdr.load(self.web, self.file\_path, self.source)
            self.assertEqual(1, self.rdr.errors)
            self.assertEqual(log\_capture.output,
                [
                    "ERROR:WebReader:At ('test8\_inc.tmp', 4): end of input, ('@{', '@[') not found", 
                    "ERROR:WebReader:Errors in included file 'test8\_inc.tmp', output is incomplete."
                ]
            ) 
        def tearDown(self) -> None:
            super().tearDown()
            Path('test8\_inc.tmp').unlink()

..

    ..  class:: small

        |loz| *Load Test include processing with syntax errors (56)*. Used by: test_loader.py (`51`_)


The sample document must reference the correct name that will
be given to the included document by ``setUp``.


..  _`57`:
..  rubric:: Sample Document 8 and the file it includes (57) =
..  parsed-literal::
    :class: code

    
    test8\_w = """Some anonymous chunk.
    @d title @[the title of this document, defined with @@[ and @@]@]
    A reference to @<title@>.
    @i test8\_inc.tmp
    A final anonymous chunk from test8.w
    """
    
    test8\_inc\_w="""A chunk from test8a.w
    And now for an error - incorrect syntax in an included file!
    @d yap
    """

..

    ..  class:: small

        |loz| *Sample Document 8 and the file it includes (57)*. Used by: Load Test include... (`56`_)


<p>The overheads for a Python unittest.</p>


..  _`58`:
..  rubric:: Load Test overheads: imports, etc. (58) +=
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

        |loz| *Load Test overheads: imports, etc. (58)*. Used by: test_loader.py (`51`_)


A main program that configures logging and then runs the test.


..  _`59`:
..  rubric:: Load Test main program (59) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)
        unittest.main()

..

    ..  class:: small

        |loz| *Load Test main program (59)*. Used by: test_loader.py (`51`_)


Tests for Tangling
------------------

We need to be able to tangle a web.


..  _`60`:
..  rubric:: test_tangler.py (60) =
..  parsed-literal::
    :class: code

    |srarr|\ Tangle Test overheads: imports, etc. (`74`_)
    |srarr|\ Tangle Test superclass to refactor common setup (`61`_)
    |srarr|\ Tangle Test semantic error 2 (`62`_)
    |srarr|\ Tangle Test semantic error 3 (`64`_)
    |srarr|\ Tangle Test semantic error 4 (`66`_)
    |srarr|\ Tangle Test semantic error 5 (`68`_)
    |srarr|\ Tangle Test semantic error 6 (`70`_)
    |srarr|\ Tangle Test include error 7 (`72`_)
    |srarr|\ Tangle Test main program (`75`_)

..

    ..  class:: small

        |loz| *test_tangler.py (60)*.


Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.



..  _`61`:
..  rubric:: Tangle Test superclass to refactor common setup (61) =
..  parsed-literal::
    :class: code

    
    class TangleTestcase(unittest.TestCase):
        text: ClassVar[str]
        error: ClassVar[str]
        file\_path: ClassVar[Path]
        
        def setUp(self) -> None:
            self.source = io.StringIO(self.text)
            self.web = pyweb.Web()
            self.rdr = pyweb.WebReader()
            self.tangler = pyweb.Tangler()
            
        def tangle\_and\_check\_exception(self, exception\_text: str) -> None:
            try:
                self.rdr.load(self.web, self.file\_path, self.source)
                self.web.tangle(self.tangler)
                self.web.createUsedBy()
                self.fail("Should not tangle")
            except pyweb.Error as e:
                self.assertEqual(exception\_text, e.args[0])
                
        def tearDown(self) -> None:
            try:
                self.file\_path.with\_suffix(".tmp").unlink()
            except FileNotFoundError:
                pass  # If the test fails, nothing to remove...

..

    ..  class:: small

        |loz| *Tangle Test superclass to refactor common setup (61)*. Used by: test_tangler.py (`60`_)



..  _`62`:
..  rubric:: Tangle Test semantic error 2 (62) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 2 (`63`_)
    
    class Test\_SemanticError\_2(TangleTestcase):
        text = test2\_w
        file\_path = Path("test2.w")
        def test\_should\_raise\_undefined(self) -> None:
            self.tangle\_and\_check\_exception("Attempt to tangle an undefined Chunk, part2.")

..

    ..  class:: small

        |loz| *Tangle Test semantic error 2 (62)*. Used by: test_tangler.py (`60`_)



..  _`63`:
..  rubric:: Sample Document 2 (63) =
..  parsed-literal::
    :class: code

    
    test2\_w = """Some anonymous chunk
    @o test2.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    Okay, now for some errors: no part2!
    """

..

    ..  class:: small

        |loz| *Sample Document 2 (63)*. Used by: Tangle Test semantic error 2... (`62`_)



..  _`64`:
..  rubric:: Tangle Test semantic error 3 (64) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 3 (`65`_)
    
    class Test\_SemanticError\_3(TangleTestcase):
        text = test3\_w
        file\_path = Path("test3.w")
        def test\_should\_raise\_bad\_xref(self) -> None:
            self.tangle\_and\_check\_exception("Illegal tangling of a cross reference command.")

..

    ..  class:: small

        |loz| *Tangle Test semantic error 3 (64)*. Used by: test_tangler.py (`60`_)



..  _`65`:
..  rubric:: Sample Document 3 (65) =
..  parsed-literal::
    :class: code

    
    test3\_w = """Some anonymous chunk
    @o test3.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    @d part2 @{This is part 2, with an illegal: @f.@}
    Okay, now for some errors: attempt to tangle a cross-reference!
    """

..

    ..  class:: small

        |loz| *Sample Document 3 (65)*. Used by: Tangle Test semantic error 3... (`64`_)




..  _`66`:
..  rubric:: Tangle Test semantic error 4 (66) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 4 (`67`_)
    
    class Test\_SemanticError\_4(TangleTestcase):
        text = test4\_w
        file\_path = Path("test4.w")
        def test\_should\_raise\_noFullName(self) -> None:
            self.tangle\_and\_check\_exception("No full name for 'part1...'")

..

    ..  class:: small

        |loz| *Tangle Test semantic error 4 (66)*. Used by: test_tangler.py (`60`_)



..  _`67`:
..  rubric:: Sample Document 4 (67) =
..  parsed-literal::
    :class: code

    
    test4\_w = """Some anonymous chunk
    @o test4.tmp
    @{@<part1...@>
    @<part2@>
    @}@@
    @d part1... @{This is part 1.@}
    @d part2 @{This is part 2.@}
    Okay, now for some errors: attempt to weave but no full name for part1....
    """

..

    ..  class:: small

        |loz| *Sample Document 4 (67)*. Used by: Tangle Test semantic error 4... (`66`_)



..  _`68`:
..  rubric:: Tangle Test semantic error 5 (68) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 5 (`69`_)
    
    class Test\_SemanticError\_5(TangleTestcase):
        text = test5\_w
        file\_path = Path("test5.w")
        def test\_should\_raise\_ambiguous(self) -> None:
            self.tangle\_and\_check\_exception("Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']")

..

    ..  class:: small

        |loz| *Tangle Test semantic error 5 (68)*. Used by: test_tangler.py (`60`_)



..  _`69`:
..  rubric:: Sample Document 5 (69) =
..  parsed-literal::
    :class: code

    
    test5\_w = """
    Some anonymous chunk
    @o test5.tmp
    @{@<part1...@>
    @<part2@>
    @}@@
    @d part1a @{This is part 1 a.@}
    @d part1b @{This is part 1 b.@}
    @d part2 @{This is part 2.@}
    Okay, now for some errors: part1... is ambiguous
    """

..

    ..  class:: small

        |loz| *Sample Document 5 (69)*. Used by: Tangle Test semantic error 5... (`68`_)



..  _`70`:
..  rubric:: Tangle Test semantic error 6 (70) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Sample Document 6 (`71`_)
    
    class Test\_SemanticError\_6(TangleTestcase):
        text = test6\_w
        file\_path = Path("test6.w")
        def test\_should\_warn(self) -> None:
            self.rdr.load(self.web, self.file\_path, self.source)
            self.web.tangle(self.tangler)
            self.web.createUsedBy()
            self.assertEqual(1, len(self.web.no\_reference()))
            self.assertEqual(1, len(self.web.multi\_reference()))
            self.assertEqual(0, len(self.web.no\_definition()))

..

    ..  class:: small

        |loz| *Tangle Test semantic error 6 (70)*. Used by: test_tangler.py (`60`_)



..  _`71`:
..  rubric:: Sample Document 6 (71) =
..  parsed-literal::
    :class: code

    
    test6\_w = """Some anonymous chunk
    @o test6.tmp
    @{@<part1...@>
    @<part1a@>
    @}@@
    @d part1a @{This is part 1 a.@}
    @d part2 @{This is part 2.@}
    Okay, now for some warnings: 
    - part1 has multiple references.
    - part2 is unreferenced.
    """

..

    ..  class:: small

        |loz| *Sample Document 6 (71)*. Used by: Tangle Test semantic error 6... (`70`_)



..  _`72`:
..  rubric:: Tangle Test include error 7 (72) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 7 and it's included file (`73`_)
    
    class Test\_IncludeError\_7(TangleTestcase):
        text = test7\_w
        file\_path = Path("test7.w")
        def setUp(self) -> None:
            Path('test7\_inc.tmp').write\_text(test7\_inc\_w)
            super().setUp()
        def test\_should\_include(self) -> None:
            self.rdr.load(self.web, self.file\_path, self.source)
            self.web.tangle(self.tangler)
            self.web.createUsedBy()
            self.assertEqual(5, len(self.web.chunkSeq))
            self.assertEqual(test7\_inc\_w, self.web.chunkSeq[3].commands[0].text)
        def tearDown(self) -> None:
            Path('test7\_inc.tmp').unlink()
            super().tearDown()

..

    ..  class:: small

        |loz| *Tangle Test include error 7 (72)*. Used by: test_tangler.py (`60`_)



..  _`73`:
..  rubric:: Sample Document 7 and it's included file (73) =
..  parsed-literal::
    :class: code

    
    test7\_w = """
    Some anonymous chunk.
    @d title @[the title of this document, defined with @@[ and @@]@]
    A reference to @<title@>.
    @i test7\_inc.tmp
    A final anonymous chunk from test7.w
    """
    
    test7\_inc\_w = """The test7a.tmp chunk for test7.w
    """

..

    ..  class:: small

        |loz| *Sample Document 7 and it's included file (73)*. Used by: Tangle Test include error 7... (`72`_)



..  _`74`:
..  rubric:: Tangle Test overheads: imports, etc. (74) =
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

        |loz| *Tangle Test overheads: imports, etc. (74)*. Used by: test_tangler.py (`60`_)



..  _`75`:
..  rubric:: Tangle Test main program (75) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)
        unittest.main()

..

    ..  class:: small

        |loz| *Tangle Test main program (75)*. Used by: test_tangler.py (`60`_)



Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.


..  _`76`:
..  rubric:: test_weaver.py (76) =
..  parsed-literal::
    :class: code

    |srarr|\ Weave Test overheads: imports, etc. (`83`_)
    |srarr|\ Weave Test superclass to refactor common setup (`77`_)
    |srarr|\ Weave Test references and definitions (`78`_)
    |srarr|\ Weave Test evaluation of expressions (`81`_)
    |srarr|\ Weave Test main program (`84`_)

..

    ..  class:: small

        |loz| *test_weaver.py (76)*.


Weaving test cases have a common setup shown in this superclass.


..  _`77`:
..  rubric:: Weave Test superclass to refactor common setup (77) =
..  parsed-literal::
    :class: code

    
    class WeaveTestcase(unittest.TestCase):
        text: ClassVar[str]
        error: ClassVar[str]
        file\_path: ClassVar[Path]
        
        def setUp(self) -> None:
            self.source = io.StringIO(self.text)
            self.web = pyweb.Web()
            self.rdr = pyweb.WebReader()
            
        def tearDown(self) -> None:
            try:
                self.file\_path.with\_suffix(".html").unlink()
            except FileNotFoundError:
                pass  # if the test failed, nothing to remove

..

    ..  class:: small

        |loz| *Weave Test superclass to refactor common setup (77)*. Used by: test_weaver.py (`76`_)



..  _`78`:
..  rubric:: Weave Test references and definitions (78) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 0 (`79`_)
    |srarr|\ Expected Output 0 (`80`_)
    
    class Test\_RefDefWeave(WeaveTestcase):
        text = test0\_w
        file\_path = Path("test0.w")
        def test\_load\_should\_createChunks(self) -> None:
            self.rdr.load(self.web, self.file\_path, self.source)
            self.assertEqual(3, len(self.web.chunkSeq))
        def test\_weave\_should\_createFile(self) -> None:
            self.rdr.load(self.web, self.file\_path, self.source)
            doc = pyweb.HTML()
            doc.reference\_style = pyweb.SimpleReference() 
            self.web.weave(doc)
            actual = self.file\_path.with\_suffix(".html").read\_text()
            self.maxDiff = None
            self.assertEqual(test0\_expected, actual)
    

..

    ..  class:: small

        |loz| *Weave Test references and definitions (78)*. Used by: test_weaver.py (`76`_)



..  _`79`:
..  rubric:: Sample Document 0 (79) =
..  parsed-literal::
    :class: code

     
    test0\_w = """<html>
    <head>
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />
    </head>
    <body>
    @<some code@>
    
    @d some code 
    @{
    def fastExp(n, p):
        r = 1
        while p > 0:
            if p%2 == 1: return n\*fastExp(n,p-1)
        return n\*n\*fastExp(n,p/2)
    
    for i in range(24):
        fastExp(2,i)
    @}
    </body>
    </html>
    """

..

    ..  class:: small

        |loz| *Sample Document 0 (79)*. Used by: Weave Test references... (`78`_)



..  _`80`:
..  rubric:: Expected Output 0 (80) =
..  parsed-literal::
    :class: code

    
    test0\_expected = """<html>
    <head>
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />
    </head>
    <body>
    <a href="#pyweb1">&rarr;<em>some code</em> (1)</a>
    
    
        <a name="pyweb1"></a>
        <!--line number 10-->
        <p><em>some code</em> (1)&nbsp;=</p>
        <pre><code>
    
    def fastExp(n, p):
        r = 1
        while p &gt; 0:
            if p%2 == 1: return n\*fastExp(n,p-1)
        return n\*n\*fastExp(n,p/2)
    
    for i in range(24):
        fastExp(2,i)
    
        </code></pre>
        <p>&loz; <em>some code</em> (1).
        
        </p>
    
    </body>
    </html>
    """

..

    ..  class:: small

        |loz| *Expected Output 0 (80)*. Used by: Weave Test references... (`78`_)


Note that this really requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.


..  _`81`:
..  rubric:: Weave Test evaluation of expressions (81) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 9 (`82`_)
    
    from unittest.mock import Mock
    
    class TestEvaluations(WeaveTestcase):
        text = test9\_w
        file\_path = Path("test9.w")
        def setUp(self):
            super().setUp()
            self.mock\_time = Mock(asctime=Mock(return\_value="mocked time"))
        def test\_should\_evaluate(self) -> None:
            self.rdr.load(self.web, self.file\_path, self.source)
            doc = pyweb.HTML( )
            doc.reference\_style = pyweb.SimpleReference() 
            self.web.weave(doc)
            actual = self.file\_path.with\_suffix(".html").read\_text().splitlines()
            #print(actual)
            self.assertEqual("An anonymous chunk.", actual[0])
            self.assertTrue("Time = mocked time", actual[1])
            self.assertEqual("File = ('test9.w', 3)", actual[2])
            self.assertEqual('Version = 3.1', actual[3])
            self.assertEqual(f'CWD = {os.getcwd()}', actual[4])

..

    ..  class:: small

        |loz| *Weave Test evaluation of expressions (81)*. Used by: test_weaver.py (`76`_)



..  _`82`:
..  rubric:: Sample Document 9 (82) =
..  parsed-literal::
    :class: code

    
    test9\_w= """An anonymous chunk.
    Time = @(time.asctime()@)
    File = @(theLocation@)
    Version = @(\_\_version\_\_@)
    CWD = @(os.path.realpath('.')@)
    """

..

    ..  class:: small

        |loz| *Sample Document 9 (82)*. Used by: Weave Test evaluation... (`81`_)



..  _`83`:
..  rubric:: Weave Test overheads: imports, etc. (83) =
..  parsed-literal::
    :class: code

    
    """Weaver tests exercise various weaving features."""
    import io
    import logging
    import os
    from pathlib import Path
    import string
    import sys
    from typing import ClassVar
    import unittest
    
    import pyweb

..

    ..  class:: small

        |loz| *Weave Test overheads: imports, etc. (83)*. Used by: test_weaver.py (`76`_)



..  _`84`:
..  rubric:: Weave Test main program (84) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        logging.basicConfig(stream=sys.stderr, level=logging.WARN)
        unittest.main()

..

    ..  class:: small

        |loz| *Weave Test main program (84)*. Used by: test_weaver.py (`76`_)



Additional Scripts Testing
==========================

.. test/scripts.w

We provide these two additional scripts; effectively command-line short-cuts:

-   ``tangle.py``

-   ``weave.py``

These need their own test cases.


This gives us the following outline for the script testing.


..  _`85`:
..  rubric:: test_scripts.py (85) =
..  parsed-literal::
    :class: code

    |srarr|\ Script Test overheads: imports, etc. (`90`_)
    
    |srarr|\ Sample web file to test with (`86`_)
    
    |srarr|\ Superclass for test cases (`87`_)
    
    |srarr|\ Test of weave.py (`88`_)
    
    |srarr|\ Test of tangle.py (`89`_)
    
    |srarr|\ Scripts Test main (`91`_)

..

    ..  class:: small

        |loz| *test_scripts.py (85)*.


Sample Web File
---------------

This is a web ``.w`` file to create a document and tangle a small file.


..  _`86`:
..  rubric:: Sample web file to test with (86) =
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
            
        @o sample\_tangle.code
        @{
        @<preamble@>
        @<body@>
        @}
        
        @d preamble
        @{
        #include <stdio.h>
        @}
        
        @d body
        @{
        int main() {
            println("Hello, World!")
        }
        @}
        
          </body>
        </html>
        """)

..

    ..  class:: small

        |loz| *Sample web file to test with (86)*. Used by: test_scripts.py (`85`_)


Superclass for test cases
-------------------------

This superclass definition creates a consistent test fixture for both test cases.
The sample ``test_sample.w`` file is created and removed after the test.


..  _`87`:
..  rubric:: Superclass for test cases (87) =
..  parsed-literal::
    :class: code

    
    class SampleWeb(unittest.TestCase):
        def setUp(self) -> None:
            self.sample\_path = Path("test\_sample.w")
            self.sample\_path.write\_text(sample)
        def tearDown(self) -> None:
            self.sample\_path.unlink()
    

..

    ..  class:: small

        |loz| *Superclass for test cases (87)*. Used by: test_scripts.py (`85`_)


Weave Script Test
-----------------

We check the weave output to be sure it's what we expected. 
This could be altered to check a few features of the weave file rather than compare the entire file.


..  _`88`:
..  rubric:: Test of weave.py (88) =
..  parsed-literal::
    :class: code

    
    expected\_weave = textwrap.dedent("""
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
        
        <a name="pyweb1"></a>
            <!--line number 16-->
            <p>\`\`sample\_tangle.code\`\` (1)&nbsp;=</p>
            <pre><code>
        
        <a href="#pyweb2">&rarr;<em>preamble</em>&nbsp;(2)</a>
        <a href="#pyweb3">&rarr;<em>body</em>&nbsp;(3)</a>
        </code></pre>
            <p>&loz; \`\`sample\_tangle.code\`\` (1).
            []
            </p>
        
        
        <a name="pyweb2"></a>
            <!--line number 22-->
            <p><em>preamble</em> (2)&nbsp;=</p>
            <pre><code>
        
        #include &lt;stdio.h&gt;
        
            </code></pre>
            <p>&loz; <em>preamble</em> (2).
              Used by <a href="#pyweb1"><em>sample\_tangle.code</em>&nbsp;(1)</a>.
            </p>
        
        
        <a name="pyweb3"></a>
            <!--line number 27-->
            <p><em>body</em> (3)&nbsp;=</p>
            <pre><code>
        
        int main() {
            println(&quot;Hello, World!&quot;)
        }
        
            </code></pre>
            <p>&loz; <em>body</em> (3).
              Used by <a href="#pyweb1"><em>sample\_tangle.code</em>&nbsp;(1)</a>.
            </p>
        
        
          </body>
        </html>
        """)
        
    class TestWeave(SampleWeb):
        def setUp(self) -> None:
            super().setUp()
            self.output = self.sample\_path.with\_suffix(".html")
        def test(self) -> None:
            weave.main(self.sample\_path)
            result = self.output.read\_text()
            self.assertEqual(result, expected\_weave)
        def tearDown(self) -> None:
            super().tearDown()
            self.output.unlink()

..

    ..  class:: small

        |loz| *Test of weave.py (88)*. Used by: test_scripts.py (`85`_)


Tangle Script Test
------------------

We check the tangle output to be sure it's what we expected. 


..  _`89`:
..  rubric:: Test of tangle.py (89) =
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
            self.assertEqual(result, expected\_tangle)
        def tearDown(self) -> None:
            super().tearDown()
            self.output.unlink()

..

    ..  class:: small

        |loz| *Test of tangle.py (89)*. Used by: test_scripts.py (`85`_)


Overheads and Main Script
--------------------------

This is typical of the other test modules. We provide a unittest runner 
here in case we want to run these tests in isolation.


..  _`90`:
..  rubric:: Script Test overheads: imports, etc. (90) =
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

        |loz| *Script Test overheads: imports, etc. (90)*. Used by: test_scripts.py (`85`_)



..  _`91`:
..  rubric:: Scripts Test main (91) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        logging.basicConfig(stream=sys.stdout, level=logging.WARN)
        unittest.main()

..

    ..  class:: small

        |loz| *Scripts Test main (91)*. Used by: test_scripts.py (`85`_)


We run the default ``unittest.main()`` to execute the entire suite of tests.


No Longer supported: @i runner.w, using pytest seems better.

Additional Files
=================

To get the RST to look good, there are two additional files.
These are clones of what's in the ``src`` directory.

``docutils.conf`` defines two CSS files to use.
	The default CSS file may need to be customized.


..  _`92`:
..  rubric:: docutils.conf (92) =
..  parsed-literal::
    :class: code

    # docutils.conf
    
    [html4css1 writer]
    stylesheet-path: /Users/slott/miniconda3/envs/pywebtool/lib/python3.10/site-packages/docutils/writers/html4css1/html4css1.css,
        page-layout.css
    syntax-highlight: long

..

    ..  class:: small

        |loz| *docutils.conf (92)*.


``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. These are minor
tweaks to the default CSS.


..  _`93`:
..  rubric:: page-layout.css (93) =
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

        |loz| *page-layout.css (93)*.


Indices
=======

Files
-----


:docutils.conf:
    |srarr|\ (`92`_)
:page-layout.css:
    |srarr|\ (`93`_)
:test_loader.py:
    |srarr|\ (`51`_)
:test_scripts.py:
    |srarr|\ (`85`_)
:test_tangler.py:
    |srarr|\ (`60`_)
:test_unit.py:
    |srarr|\ (`1`_)
:test_weaver.py:
    |srarr|\ (`76`_)



Macros
------


:Expected Output 0:
    |srarr|\ (`80`_)
:Load Test error handling with a few common syntax errors:
    |srarr|\ (`54`_)
:Load Test include processing with syntax errors:
    |srarr|\ (`56`_)
:Load Test main program:
    |srarr|\ (`59`_)
:Load Test overheads: imports, etc.:
    |srarr|\ (`53`_) |srarr|\ (`58`_)
:Load Test superclass to refactor common setup:
    |srarr|\ (`52`_)
:Sample Document 0:
    |srarr|\ (`79`_)
:Sample Document 1 with correct and incorrect syntax:
    |srarr|\ (`55`_)
:Sample Document 2:
    |srarr|\ (`63`_)
:Sample Document 3:
    |srarr|\ (`65`_)
:Sample Document 4:
    |srarr|\ (`67`_)
:Sample Document 5:
    |srarr|\ (`69`_)
:Sample Document 6:
    |srarr|\ (`71`_)
:Sample Document 7 and it's included file:
    |srarr|\ (`73`_)
:Sample Document 8 and the file it includes:
    |srarr|\ (`57`_)
:Sample Document 9:
    |srarr|\ (`82`_)
:Sample web file to test with:
    |srarr|\ (`86`_)
:Script Test overheads: imports, etc.:
    |srarr|\ (`90`_)
:Scripts Test main:
    |srarr|\ (`91`_)
:Superclass for test cases:
    |srarr|\ (`87`_)
:Tangle Test include error 7:
    |srarr|\ (`72`_)
:Tangle Test main program:
    |srarr|\ (`75`_)
:Tangle Test overheads: imports, etc.:
    |srarr|\ (`74`_)
:Tangle Test semantic error 2:
    |srarr|\ (`62`_)
:Tangle Test semantic error 3:
    |srarr|\ (`64`_)
:Tangle Test semantic error 4:
    |srarr|\ (`66`_)
:Tangle Test semantic error 5:
    |srarr|\ (`68`_)
:Tangle Test semantic error 6:
    |srarr|\ (`70`_)
:Tangle Test superclass to refactor common setup:
    |srarr|\ (`61`_)
:Test of tangle.py:
    |srarr|\ (`89`_)
:Test of weave.py:
    |srarr|\ (`88`_)
:Unit Test Mock Chunk class:
    |srarr|\ (`4`_)
:Unit Test Web class chunk cross-reference:
    |srarr|\ (`36`_)
:Unit Test Web class construction methods:
    |srarr|\ (`34`_)
:Unit Test Web class name resolution methods:
    |srarr|\ (`35`_)
:Unit Test Web class tangle:
    |srarr|\ (`37`_)
:Unit Test Web class weave:
    |srarr|\ (`38`_)
:Unit Test main:
    |srarr|\ (`50`_)
:Unit Test of Action class hierarchy:
    |srarr|\ (`42`_)
:Unit Test of Application class:
    |srarr|\ (`47`_)
:Unit Test of Chunk class hierarchy:
    |srarr|\ (`11`_)
:Unit Test of Chunk construction:
    |srarr|\ (`16`_)
:Unit Test of Chunk emission:
    |srarr|\ (`18`_)
:Unit Test of Chunk interrogation:
    |srarr|\ (`17`_)
:Unit Test of Chunk superclass:
    |srarr|\ (`12`_) |srarr|\ (`13`_) |srarr|\ (`14`_) |srarr|\ (`15`_)
:Unit Test of CodeCommand class to contain a program source code block:
    |srarr|\ (`26`_)
:Unit Test of Command class hierarchy:
    |srarr|\ (`23`_)
:Unit Test of Command superclass:
    |srarr|\ (`24`_)
:Unit Test of Emitter Superclass:
    |srarr|\ (`3`_)
:Unit Test of Emitter class hierarchy:
    |srarr|\ (`2`_)
:Unit Test of FileXrefCommand class for an output file cross-reference:
    |srarr|\ (`28`_)
:Unit Test of HTML subclass of Emitter:
    |srarr|\ (`7`_)
:Unit Test of HTMLShort subclass of Emitter:
    |srarr|\ (`8`_)
:Unit Test of LaTeX subclass of Emitter:
    |srarr|\ (`6`_)
:Unit Test of MacroXrefCommand class for a named chunk cross-reference:
    |srarr|\ (`29`_)
:Unit Test of NamedChunk subclass:
    |srarr|\ (`19`_)
:Unit Test of NamedChunk_Noindent subclass:
    |srarr|\ (`20`_)
:Unit Test of NamedDocumentChunk subclass:
    |srarr|\ (`22`_)
:Unit Test of OutputChunk subclass:
    |srarr|\ (`21`_)
:Unit Test of Reference class hierarchy:
    |srarr|\ (`32`_)
:Unit Test of ReferenceCommand class for chunk references:
    |srarr|\ (`31`_)
:Unit Test of Tangler subclass of Emitter:
    |srarr|\ (`9`_)
:Unit Test of TanglerMake subclass of Emitter:
    |srarr|\ (`10`_)
:Unit Test of TextCommand class to contain a document text block:
    |srarr|\ (`25`_)
:Unit Test of UserIdXrefCommand class for a user identifier cross-reference:
    |srarr|\ (`30`_)
:Unit Test of Weaver subclass of Emitter:
    |srarr|\ (`5`_)
:Unit Test of Web class:
    |srarr|\ (`33`_)
:Unit Test of WebReader class:
    |srarr|\ (`39`_) |srarr|\ (`40`_) |srarr|\ (`41`_)
:Unit Test of XrefCommand superclass for all cross-reference commands:
    |srarr|\ (`27`_)
:Unit Test overheads: imports, etc.:
    |srarr|\ (`48`_) |srarr|\ (`49`_)
:Unit test of Action Sequence class:
    |srarr|\ (`43`_)
:Unit test of LoadAction class:
    |srarr|\ (`46`_)
:Unit test of TangleAction class:
    |srarr|\ (`45`_)
:Unit test of WeaverAction class:
    |srarr|\ (`44`_)
:Weave Test evaluation of expressions:
    |srarr|\ (`81`_)
:Weave Test main program:
    |srarr|\ (`84`_)
:Weave Test overheads: imports, etc.:
    |srarr|\ (`83`_)
:Weave Test references and definitions:
    |srarr|\ (`78`_)
:Weave Test superclass to refactor common setup:
    |srarr|\ (`77`_)



User Identifiers
----------------

(None)


----------

..	class:: small

	Created by pyweb.py at Sun Jun 12 19:07:28 2022.

    Source tests/pyweb_test.w modified Sat Jun 11 08:30:06 2022.

	pyweb.__version__ '3.1'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool'.
