############################################
pyWeb Literate Programming 3.3 - Test Suite
############################################    

** Yet Another Literate Programming Tool**

..	contents::


Introduction
============

..	test/test_intro.w

There are two levels of testing in this document.

-	`Unit Testing`_

-	`Functional Testing`_

Other testing, like performance or security, is possible.
But for this application, not very interesting.

The ``pyweb_test.w`` WEB creates the test suite.
This source will weave a ``pyweb_test.rst`` file.
It tangles several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py``, ``test_unit.py``, and ``test_scripts.py``.

Use **pytest** to discover and run all 80+ test cases.

Here's a script that works out well for running this without disturbing the development
environment. The ``PYTHONPATH`` setting is essential to support importing ``pyweb``.

..	parsed-literal::

	python pyweb.py -o tests tests/pyweb_test.w
	PYTHONPATH=$(PWD) pytest

Note that the last line sets an environment variable and runs
the ``pytest`` tool on a single line.


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


..  _`tests/test_unit.py (1)`:
..  rubric:: tests/test_unit.py (1) =
..  code-block::
    :class: code

    → `Unit Test overheads: imports, etc. (79)`_    
    
    → `Unit Test of Emitter class hierarchy (2)`_    
    → `Unit Test of Chunk class hierarchy (14)`_    
    → `Unit Test of Chunk References (34)`_    
    → `Unit Test of Command class hierarchy (39)`_    
    → `Unit Test of Web class (60)`_    
    → `Unit Test of WebReader class (65)`_    
    → `Unit Test of Action class hierarchy (69)`_    
    → `Unit Test of Application class (78)`_    

..

..  container:: small

    ∎ *tests/test_unit.py (1)*.
    



Emitter Tests
-------------

The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.



..  _`Unit Test of Emitter class hierarchy (2)`:
..  rubric:: Unit Test of Emitter class hierarchy (2) =
..  code-block::
    :class: code

    
    → `Unit Test Mock Chunk class (4)`_    
    → `Unit Test of Emitter Superclass (3)`_    
    → `Unit Test of Weaver subclass of Emitter (5)`_    
    → `Unit Test of LaTeX macros in Weaver (7)`_    
    → `Unit Test of HTML macros in Weaver (10)`_    
    → `Unit Test of Tangler subclass of Emitter (12)`_    
    → `Unit Test of TanglerMake subclass of Emitter (13)`_    

..

..  container:: small

    ∎ *Unit Test of Emitter class hierarchy (2)*.
    Used by     → `tests/test_unit.py (1)`_.



The Emitter superclass is designed to be extended.
The test creates a subclass to exercise a few key features.
The default emitter is Tangler-like.


..  _`Unit Test of Emitter Superclass (3)`:
..  rubric:: Unit Test of Emitter Superclass (3) =
..  code-block::
    :class: code

     
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

..

..  container:: small

    ∎ *Unit Test of Emitter Superclass (3)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.



A mock ``Chunk`` object can be used to test ``Weaver`` subclasses.

Some tests will create multiple chunks.
To keep their state separate, we define a function to return each mocked ``Chunk`` instance as a new Mock object.

The ``write_closure()`` is a function that calls the ``Tangler.write()``  method.
This is *not* consistent with best unit testing practices.
It is merely a hold-over from an older testing strategy.
The mock call history to the ``tangle()`` method of each ``Chunk`` instance is a better test strategy.


..  _`Unit Test Mock Chunk class (4)`:
..  rubric:: Unit Test Mock Chunk class (4) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test Mock Chunk class (4)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.



The default ``Weaver`` is an ``Emitter`` that uses templates to produce RST markup.


..  _`Unit Test of Weaver subclass of Emitter (5)`:
..  rubric:: Unit Test of Weaver subclass of Emitter (5) =
..  code-block::
    :class: code

    
    def test_rst_quote_rules():
        assert pyweb.rst_quote_rules("|char| `code` *em* _em_") == "|char| `code` *em* _em_"
    
    def test_html_quote_rules():
        assert pyweb.html_quote_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"
    
    → `expected RST output (6)`_    
    
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

..

..  container:: small

    ∎ *Unit Test of Weaver subclass of Emitter (5)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.




..  _`expected RST output (6)`:
..  rubric:: expected RST output (6) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *expected RST output (6)*.
    Used by     → `Unit Test of Weaver subclass of Emitter (5)`_.



A significant fraction of the various subclasses of weaver are expansion of various template macros.
Testing the template macros looks deeply at the intermediate product (RST or LaTeX), something that may be more easily tested by the final **docutils**, **Sphinx**, or a LaTeX processor.

Because of the complexity of LaTeX, we will examine a few features of these template macros.


..  _`Unit Test of LaTeX macros in Weaver (7)`:
..  rubric:: Unit Test of LaTeX macros in Weaver (7) =
..  code-block::
    :class: code

    
    
    → `expected tex output (8)`_    
    → `expected tex minted output (9)`_    
    
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

..

..  container:: small

    ∎ *Unit Test of LaTeX macros in Weaver (7)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.




..  _`expected tex output (8)`:
..  rubric:: expected tex output (8) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *expected tex output (8)*.
    Used by     → `Unit Test of LaTeX macros in Weaver (7)`_.




..  _`expected tex minted output (9)`:
..  rubric:: expected tex minted output (9) =
..  code-block::
    :class: code

    
    expected_tex_minted_output = [
        '\n'
        '\\label{pyweb-314}\n'
        '\\textit{Code example Chunk (314)}\n'
        '\\begin{minted}{python}',
        '\n'
        '\\end{minted}\n'
    ]

..

..  container:: small

    ∎ *expected tex minted output (9)*.
    Used by     → `Unit Test of LaTeX macros in Weaver (7)`_.



We'll examine a few features of the HTML templates.


..  _`Unit Test of HTML macros in Weaver (10)`:
..  rubric:: Unit Test of HTML macros in Weaver (10) =
..  code-block::
    :class: code

    
    → `expected html output (11)`_    
    
    def test_weaver_functions_html(weaver_instance, mock_tiny_web):
        weaver_instance.set_markup("html")
    
        quote_result = pyweb.html_quote_rules("a < b && c > d")
        assert "a &lt; b &amp;&amp; c &gt; d" == quote_result
    
        weave_result = list(weaver_instance.generate_text(mock_tiny_web))
        assert expected_html_output == weave_result

..

..  container:: small

    ∎ *Unit Test of HTML macros in Weaver (10)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.




..  _`expected html output (11)`:
..  rubric:: expected html output (11) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *expected html output (11)*.
    Used by     → `Unit Test of HTML macros in Weaver (10)`_.



A Tangler emits the various named source files in proper format for the desired
compiler and language.


..  _`Unit Test of Tangler subclass of Emitter (12)`:
..  rubric:: Unit Test of Tangler subclass of Emitter (12) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test of Tangler subclass of Emitter (12)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.



A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference check.
If the file is different, the old version is replaced with  the new version.
If the file content is the same, the old version is left intact with all of the operating system creation timestamps untouched.


..  _`Unit Test of TanglerMake subclass of Emitter (13)`:
..  rubric:: Unit Test of TanglerMake subclass of Emitter (13) =
..  code-block::
    :class: code

    
    
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

..

..  container:: small

    ∎ *Unit Test of TanglerMake subclass of Emitter (13)*.
    Used by     → `Unit Test of Emitter class hierarchy (2)`_.



Chunk Tests
------------

The ``Chunk`` and ``Command`` class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.



..  _`Unit Test of Chunk class hierarchy (14)`:
..  rubric:: Unit Test of Chunk class hierarchy (14) =
..  code-block::
    :class: code

    
    → `Unit Test of Chunk superclass (15)`_    
    → `Unit Test of NamedChunk subclass (22)`_    
    → `Unit Test of NamedChunk with no indent (25)`_    
    → `Unit Test of OutputChunk subclass (28)`_    
    → `Unit Test of NamedDocumentChunk subclass (31)`_    

..

..  container:: small

    ∎ *Unit Test of Chunk class hierarchy (14)*.
    Used by     → `tests/test_unit.py (1)`_.



In order to test the ``Chunk`` superclass, we need several mock objects.
A ``Chunk`` contains one or more ``Command`` instances.
A ``Chunk`` is a part of a ``Web``.
Also, a ``Chunk`` is processed by a ``Tangler`` or a ``Weaver``.
We'll need  mock objects for all of these relationships in which a ``Chunk`` participates.

We'll replace Commands (and Web) with ``Mock`` objects.


..  _`Unit Test of Chunk superclass (15)`:
..  rubric:: Unit Test of Chunk superclass (15) =
..  code-block::
    :class: code

    
    MockCommand = Mock(
        name="Command class",
        side_effect=lambda: Mock(
            name="Command instance",
            # text="",  # Only used for TextCommand.
            lineNumber=314,
            startswith=Mock(return_value=False)
        )
    )

..

..  container:: small

    ∎ *Unit Test of Chunk superclass (15)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.



A ``MockWeb`` contains a ``Chunk``.


..  _`Unit Test of Chunk superclass (16)`:
..  rubric:: Unit Test of Chunk superclass (16) +=
..  code-block::
    :class: code

    
    
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

..

..  container:: small

    ∎ *Unit Test of Chunk superclass (16)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.



A MockWeaver or MockTangler appear to process a ``Chunk``.
We can interrogate the ``mock_calls`` to be sure the right things were done.

We need to permit ``__enter__()`` and ``__exit__()``,
which leads to a multi-step instance.
The initial instance with ``__enter__()`` that
returns the context manager instance.



..  _`Unit Test of Chunk superclass (17)`:
..  rubric:: Unit Test of Chunk superclass (17) +=
..  code-block::
    :class: code

    
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
    

..

..  container:: small

    ∎ *Unit Test of Chunk superclass (17)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.



A ``Chunk`` must be built, interrogated and then emitted.


..  _`Unit Test of Chunk superclass (18)`:
..  rubric:: Unit Test of Chunk superclass (18) +=
..  code-block::
    :class: code

    
    @pytest.fixture
    def chunk_instance():
        return pyweb.Chunk()
    
    → `Unit Test of Chunk construction (19)`_    
    → `Unit Test of Chunk interrogation (20)`_    
    → `Unit Test of Chunk properties (21)`_    

..

..  container:: small

    ∎ *Unit Test of Chunk superclass (18)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.



Can we build a Chunk?


..  _`Unit Test of Chunk construction (19)`:
..  rubric:: Unit Test of Chunk construction (19) =
..  code-block::
    :class: code

    
    def test_append_command_should_work(chunk_instance) -> None:
        cmd1 = MockCommand()
        chunk_instance.commands.append(cmd1)
        assert 1 == len(chunk_instance.commands)
        assert [cmd1] == chunk_instance.commands
        
        cmd2 = MockCommand()
        chunk_instance.commands.append(cmd2)
        assert 2 == len(chunk_instance.commands)
        assert [cmd1, cmd2] == chunk_instance.commands

..

..  container:: small

    ∎ *Unit Test of Chunk construction (19)*.
    Used by     → `Unit Test of Chunk superclass (18)`_.



Can we interrogate a Chunk?


..  _`Unit Test of Chunk interrogation (20)`:
..  rubric:: Unit Test of Chunk interrogation (20) =
..  code-block::
    :class: code

    
    def test_lineNumber_should_work(chunk_instance) -> None:
        cmd1 = MockCommand()
        chunk_instance.commands.append(cmd1)
        assert 314 == chunk_instance.commands[0].lineNumber

..

..  container:: small

    ∎ *Unit Test of Chunk interrogation (20)*.
    Used by     → `Unit Test of Chunk superclass (18)`_.



Can we emit a Chunk with a weaver or tangler?


..  _`Unit Test of Chunk properties (21)`:
..  rubric:: Unit Test of Chunk properties (21) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test of Chunk properties (21)*.
    Used by     → `Unit Test of Chunk superclass (18)`_.



The ``NamedChunk`` is created by a ``@d`` command.
Since it's named, it appears in the Web's index.
Also, it is woven and tangled differently than anonymous chunks.


..  _`Unit Test of NamedChunk subclass (22)`:
..  rubric:: Unit Test of NamedChunk subclass (22) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def namedchunk_instance():
        chunk = pyweb.NamedChunk(options=["Some Name..."])
        cmd = MockCommand()
        chunk.commands.append(cmd)
        chunk.def_names = ["index", "terms"]
        return chunk
    
    → `Unit test of named chunk xref (23)`_    
    → `Unit test of named chunk properties (24)`_    

..

..  container:: small

    ∎ *Unit Test of NamedChunk subclass (22)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.




..  _`Unit test of named chunk xref (23)`:
..  rubric:: Unit test of named chunk xref (23) =
..  code-block::
    :class: code

    
    def test_should_find_xref_words(namedchunk_instance) -> None:
        assert 2 == len(namedchunk_instance.def_names)
        assert {"index", "terms"} == set(namedchunk_instance.def_names)

..

..  container:: small

    ∎ *Unit test of named chunk xref (23)*.
    Used by     → `Unit Test of NamedChunk subclass (22)`_.




..  _`Unit test of named chunk properties (24)`:
..  rubric:: Unit test of named chunk properties (24) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit test of named chunk properties (24)*.
    Used by     → `Unit Test of NamedChunk subclass (22)`_.




..  _`Unit Test of NamedChunk with no indent (25)`:
..  rubric:: Unit Test of NamedChunk with no indent (25) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def namedchunk_noindent_instance():
        chunk = pyweb.NamedChunk(options=["-noindent", "NoIndent Name..."])
        cmd = MockCommand()
        chunk.commands.append(cmd)
        chunk.def_names = ["index", "terms"]
        return chunk
    
    → `Unit test of named chunk no-indent xref (26)`_    
    → `Unit test of named chunk no-indent properties (27)`_    

..

..  container:: small

    ∎ *Unit Test of NamedChunk with no indent (25)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.




..  _`Unit test of named chunk no-indent xref (26)`:
..  rubric:: Unit test of named chunk no-indent xref (26) =
..  code-block::
    :class: code

    
    def test_should_find_xref_words(namedchunk_noindent_instance) -> None:
        assert 2 == len(namedchunk_noindent_instance.def_names)
        assert {"index", "terms"} == set(namedchunk_noindent_instance.def_names)

..

..  container:: small

    ∎ *Unit test of named chunk no-indent xref (26)*.
    Used by     → `Unit Test of NamedChunk with no indent (25)`_.




..  _`Unit test of named chunk no-indent properties (27)`:
..  rubric:: Unit test of named chunk no-indent properties (27) =
..  code-block::
    :class: code

    
    def test_namedchunk_ni_properties(namedchunk_noindent_instance) -> None:
        web = mock_web()
        namedchunk_noindent_instance.web = Mock(return_value=web)
        namedchunk_noindent_instance.full_name
        web.resolve_name.assert_called_once_with(namedchunk_noindent_instance.name)
        assert namedchunk_noindent_instance.path is None
        assert namedchunk_noindent_instance.type_is("NamedChunk")
        assert not namedchunk_noindent_instance.type_is("Chunk")
        assert namedchunk_noindent_instance.referencedBy is None

..

..  container:: small

    ∎ *Unit test of named chunk no-indent properties (27)*.
    Used by     → `Unit Test of NamedChunk with no indent (25)`_.




An ``OutputChunk`` is created by a ``@o`` command.
Since it's named, it appears in the Web's index.
Also, it is woven and tangled differently than anonymous chunks of text.
This defines the files of tangled code. 


..  _`Unit Test of OutputChunk subclass (28)`:
..  rubric:: Unit Test of OutputChunk subclass (28) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def outputchunk_instance():
        chunk = pyweb.OutputChunk(options=["filename.out"])
        chunk.comment_start = "# "
        chunk.comment_end = ""
        cmd = MockCommand()
        chunk.commands.append(cmd)
        chunk.def_names = ["index", "terms"]
        return chunk
    
    → `Unit Test output chunk xref (29)`_    
    → `Unit Test output chunk properties (30)`_    

..

..  container:: small

    ∎ *Unit Test of OutputChunk subclass (28)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.





..  _`Unit Test output chunk xref (29)`:
..  rubric:: Unit Test output chunk xref (29) =
..  code-block::
    :class: code

    
    def test_should_find_xref_words(outputchunk_instance) -> None:
        assert 2 == len(outputchunk_instance.def_names)
        assert {"index", "terms"} == set(outputchunk_instance.def_names)

..

..  container:: small

    ∎ *Unit Test output chunk xref (29)*.
    Used by     → `Unit Test of OutputChunk subclass (28)`_.




..  _`Unit Test output chunk properties (30)`:
..  rubric:: Unit Test output chunk properties (30) =
..  code-block::
    :class: code

    
    def test_outputchunk_properties(outputchunk_instance) -> None:
        web = mock_web()
        outputchunk_instance.web = Mock(return_value=web)
        assert outputchunk_instance.full_name is None
        web.resolve_name.assert_not_called()
        assert outputchunk_instance.path == Path("filename.out")
        assert outputchunk_instance.type_is("OutputChunk")
        assert not outputchunk_instance.type_is("Chunk")
        assert outputchunk_instance.referencedBy is None

..

..  container:: small

    ∎ *Unit Test output chunk properties (30)*.
    Used by     → `Unit Test of OutputChunk subclass (28)`_.



The ``NamedDocumentChunk`` is a way to define substitutable text, similar to code, but it applies to document chunks.
It's not clear how useful this really is.


..  _`Unit Test of NamedDocumentChunk subclass (31)`:
..  rubric:: Unit Test of NamedDocumentChunk subclass (31) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def named_documentchunk_instance():
        chunk = pyweb.NamedDocumentChunk("Document Chunk Name...")
        cmd = MockCommand()
        chunk.commands.append(cmd)
        chunk.def_names = ["index", "terms"]
        return chunk
    
    → `Unit test named document chunk xref (32)`_    
    → `Unit test named document chunk properties (33)`_    

..

..  container:: small

    ∎ *Unit Test of NamedDocumentChunk subclass (31)*.
    Used by     → `Unit Test of Chunk class hierarchy (14)`_.




..  _`Unit test named document chunk xref (32)`:
..  rubric:: Unit test named document chunk xref (32) =
..  code-block::
    :class: code

    
    def test_should_find_xref_words(named_documentchunk_instance) -> None:
        assert 2 == len(named_documentchunk_instance.def_names)
        assert {"index", "terms"} == set(named_documentchunk_instance.def_names)

..

..  container:: small

    ∎ *Unit test named document chunk xref (32)*.
    Used by     → `Unit Test of NamedDocumentChunk subclass (31)`_.




..  _`Unit test named document chunk properties (33)`:
..  rubric:: Unit test named document chunk properties (33) =
..  code-block::
    :class: code

    
    def test_nameddocument_chunk_properties(named_documentchunk_instance) -> None:
        web = mock_web()
        named_documentchunk_instance.web = Mock(return_value=web)
        named_documentchunk_instance.full_name
        web.resolve_name.assert_called_once_with(named_documentchunk_instance.name)
        assert named_documentchunk_instance.path is None
        assert named_documentchunk_instance.type_is("NamedDocumentChunk")
        assert not named_documentchunk_instance.type_is("OutputChunk")
        assert named_documentchunk_instance.referencedBy is None

..

..  container:: small

    ∎ *Unit test named document chunk properties (33)*.
    Used by     → `Unit Test of NamedDocumentChunk subclass (31)`_.



Chunk References Tests
----------------------

A ``Chunk``\ 's "referencedBy" attribute is set by the ``Web`` during the initialization processing.

The test fixture is this

..  parsed-literal::

    @d main @{ @< parent @> @}
    
    @d parent @{ @< sub @> @}
    
    @d sub @{ something @}
    
The ``sub`` item is referenced by ``parent`` which is referenced by ``main``.

There are two broad styles of references:

- The simple reference is ``sub`` referenced by ``parent``.

- The transitive references are ``sub`` referenced by ``parent`` which is referenced by ``main``.


..  _`Unit Test of Chunk References (34)`:
..  rubric:: Unit Test of Chunk References (34) =
..  code-block::
    :class: code

     
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
    
    → `Unit test of simple references (35)`_    
    → `Unit test of two-level transitive reference (36)`_    
    → `Unit test of one-level transitive reference (37)`_    
    → `Unit test of top-level transitive reference (38)`_    

..

..  container:: small

    ∎ *Unit Test of Chunk References (34)*.
    Used by     → `tests/test_unit.py (1)`_.




..  _`Unit test of simple references (35)`:
..  rubric:: Unit test of simple references (35) =
..  code-block::
    :class: code

    
    def test_simple(main_parent_sub_chunks) -> None:
        main, parent, chunk = main_parent_sub_chunks
        assert chunk.referencedBy == parent

..

..  container:: small

    ∎ *Unit test of simple references (35)*.
    Used by     → `Unit Test of Chunk References (34)`_.




..  _`Unit test of two-level transitive reference (36)`:
..  rubric:: Unit test of two-level transitive reference (36) =
..  code-block::
    :class: code

    
    def test_transitive_sub_sub(main_parent_sub_chunks) -> None:
        main, parent, chunk = main_parent_sub_chunks
        theList = chunk.transitive_referencedBy
        assert 2 == len(theList)
        assert parent == theList[0]
        assert main == theList[1]

..

..  container:: small

    ∎ *Unit test of two-level transitive reference (36)*.
    Used by     → `Unit Test of Chunk References (34)`_.




..  _`Unit test of one-level transitive reference (37)`:
..  rubric:: Unit test of one-level transitive reference (37) =
..  code-block::
    :class: code

    
    def test_transitive_sub(main_parent_sub_chunks) -> None:
        main, parent, chunk = main_parent_sub_chunks
        theList = parent.transitive_referencedBy
        assert 1 == len(theList)
        assert main == theList[0]

..

..  container:: small

    ∎ *Unit test of one-level transitive reference (37)*.
    Used by     → `Unit Test of Chunk References (34)`_.




..  _`Unit test of top-level transitive reference (38)`:
..  rubric:: Unit test of top-level transitive reference (38) =
..  code-block::
    :class: code

    
    def test_transitive_top(main_parent_sub_chunks) -> None:
        main, parent, chunk = main_parent_sub_chunks
        theList = main.transitive_referencedBy
        assert 0 == len(theList)

..

..  container:: small

    ∎ *Unit test of top-level transitive reference (38)*.
    Used by     → `Unit Test of Chunk References (34)`_.



Command Tests
---------------

A ``Chunk`` is a sequence of individual ``Command`` instances.
The invidual commands include all of the ``@x`` commands,
plus the remaining blocks of text (or code.)


..  _`Unit Test of Command class hierarchy (39)`:
..  rubric:: Unit Test of Command class hierarchy (39) =
..  code-block::
    :class: code

     
    → `Unit Test of Command superclass (40)`_    
    → `Unit Test of TextCommand class to contain a document text block (41)`_    
    → `Unit Test of CodeCommand class to contain a program source code block (44)`_    
    → `Unit Test of XrefCommand superclass for all cross-reference commands (47)`_    
    → `Unit Test of FileXrefCommand class for an output file cross-reference (48)`_    
    → `Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)`_    
    → `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)`_    
    → `Unit Test of ReferenceCommand class for chunk references (57)`_    

..

..  container:: small

    ∎ *Unit Test of Command class hierarchy (39)*.
    Used by     → `tests/test_unit.py (1)`_.



This Command superclass is essentially an inteface definition; it has no real testable features.


..  _`Unit Test of Command superclass (40)`:
..  rubric:: Unit Test of Command superclass (40) =
..  code-block::
    :class: code

    # No Tests

..

..  container:: small

    ∎ *Unit Test of Command superclass (40)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.



A ``TextCommand`` object must be built from source text, interrogated, and emitted.
A ``TextCommand`` should not (generally) be created in a ``Chunk``, it should
only be part of a ``NamedChunk`` or ``OutputChunk``.


..  _`Unit Test of TextCommand class to contain a document text block (41)`:
..  rubric:: Unit Test of TextCommand class to contain a document text block (41) =
..  code-block::
    :class: code

     
    @pytest.fixture
    def text_command_instances():
        cmd = pyweb.TextCommand("Some text & words in the document\n    ", ("sample.w", 314))
        cmd2 = pyweb.TextCommand("No Indent\n", ("sample.w", 271))
        return cmd, cmd2
    
    → `Unit test text command methods should work (42)`_    
    → `Unit test text command tangle should error (43)`_    

..

..  container:: small

    ∎ *Unit Test of TextCommand class to contain a document text block (41)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit test text command methods should work (42)`:
..  rubric:: Unit test text command methods should work (42) =
..  code-block::
    :class: code

    
    def test_textcommand_methods(text_command_instances) -> None:
        cmd, cmd2 = text_command_instances
        assert cmd.typeid.TextCommand
        assert ("sample.w", 314) == cmd.location

..

..  container:: small

    ∎ *Unit test text command methods should work (42)*.
    Used by     → `Unit Test of TextCommand class to contain a document text block (41)`_.




..  _`Unit test text command tangle should error (43)`:
..  rubric:: Unit test text command tangle should error (43) =
..  code-block::
    :class: code

    
    def test_textcommamnd_tangle_should_error(text_command_instances) -> None:
        cmd, cmd2 = text_command_instances
        tangler = MockTangler()
        with pytest.raises(pyweb.Error) as exc_info:
            cmd.tangle(tangler, sentinel.TARGET)
        assert exc_info.value.args == (
            "attempt to tangle a text block ('sample.w', 314) 'Some text & words in the [...]'",
        )

..

..  container:: small

    ∎ *Unit test text command tangle should error (43)*.
    Used by     → `Unit Test of TextCommand class to contain a document text block (41)`_.



A ``CodeCommand`` object is a ``TextCommand`` with different processing when it is emitted.
It represents a block of code in a ``NamedChunk`` or ``OutputChunk``. 


..  _`Unit Test of CodeCommand class to contain a program source code block (44)`:
..  rubric:: Unit Test of CodeCommand class to contain a program source code block (44) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def code_command_instance():
        cmd = pyweb.CodeCommand("Some code in the document\n    ", ("sample.w", 314))
        return cmd
    
    → `Unit test code command methods should work (45)`_    
    → `Unit test code command tangle should error (46)`_    

..

..  container:: small

    ∎ *Unit Test of CodeCommand class to contain a program source code block (44)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit test code command methods should work (45)`:
..  rubric:: Unit test code command methods should work (45) =
..  code-block::
    :class: code

    
    def test_codecommand_methods(code_command_instance) -> None:
        assert code_command_instance.typeid.CodeCommand
        assert ("sample.w", 314)== code_command_instance.location

..

..  container:: small

    ∎ *Unit test code command methods should work (45)*.
    Used by     → `Unit Test of CodeCommand class to contain a program source code block (44)`_.




..  _`Unit test code command tangle should error (46)`:
..  rubric:: Unit test code command tangle should error (46) =
..  code-block::
    :class: code

    
    def test_codecommand_tangle_should_work(code_command_instance) -> None:
        tangler = MockTangler()
        code_command_instance.tangle(tangler, sentinel.TARGET)
        tangler.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some code in the document\n    ')

..

..  container:: small

    ∎ *Unit test code command tangle should error (46)*.
    Used by     → `Unit Test of CodeCommand class to contain a program source code block (44)`_.



An ``XrefCommand`` class (if defined) would be abstract.
We could formalize this, but it seems easier to have a collection of ``@dataclass`` definitions with a  ``Union[...]`` type hint.



..  _`Unit Test of XrefCommand superclass for all cross-reference commands (47)`:
..  rubric:: Unit Test of XrefCommand superclass for all cross-reference commands (47) =
..  code-block::
    :class: code

    # No Tests 

..

..  container:: small

    ∎ *Unit Test of XrefCommand superclass for all cross-reference commands (47)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.



The ``FileXrefCommand`` command is expanded by a weaver to a list of ``@o`` locations.


..  _`Unit Test of FileXrefCommand class for an output file cross-reference (48)`:
..  rubric:: Unit Test of FileXrefCommand class for an output file cross-reference (48) =
..  code-block::
    :class: code

     
    @pytest.fixture
    def filexref_command_instance():
        web = Mock(files=sentinel.FILES)
        cmd = pyweb.FileXrefCommand(("sample.w", 314))
        cmd.web = Mock(return_value=web)
        return cmd
    
    → `Unit test file xref command methods should work (49)`_    
    → `Unit test file xref command tangle should error (50)`_    

..

..  container:: small

    ∎ *Unit Test of FileXrefCommand class for an output file cross-reference (48)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit test file xref command methods should work (49)`:
..  rubric:: Unit test file xref command methods should work (49) =
..  code-block::
    :class: code

    
    def test_filexrefcommand_methods(filexref_command_instance) -> None:
        assert filexref_command_instance.typeid.FileXrefCommand
        assert ("sample.w", 314) == filexref_command_instance.location
        assert sentinel.FILES == filexref_command_instance.files

..

..  container:: small

    ∎ *Unit test file xref command methods should work (49)*.
    Used by     → `Unit Test of FileXrefCommand class for an output file cross-reference (48)`_.




..  _`Unit test file xref command tangle should error (50)`:
..  rubric:: Unit test file xref command tangle should error (50) =
..  code-block::
    :class: code

    
    def test_filexrefcommand_tangle_should_fail(filexref_command_instance) -> None:
        tangler = MockTangler()
        with pytest.raises(pyweb.Error):
            filexref_command_instance.tangle(tangler, sentinel.TARGET)

..

..  container:: small

    ∎ *Unit test file xref command tangle should error (50)*.
    Used by     → `Unit Test of FileXrefCommand class for an output file cross-reference (48)`_.



The ``MacroXrefCommand`` command is expanded by a weaver to a list of all ``@d`` locations.


..  _`Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)`:
..  rubric:: Unit Test of MacroXrefCommand class for a named chunk cross-reference (51) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def macroxref_command_instance():
        web = Mock(macros=sentinel.MACROS)
        cmd = pyweb.MacroXrefCommand(("sample.w", 314))
        cmd.web = Mock(return_value=web)
        return cmd
    
    → `Unit test macro xref command methods should work (52)`_    
    → `Unit test macro xref command tangle shuould fail (53)`_    

..

..  container:: small

    ∎ *Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit test macro xref command methods should work (52)`:
..  rubric:: Unit test macro xref command methods should work (52) =
..  code-block::
    :class: code

    
    def test_macroxrefcommand_methods(macroxref_command_instance) -> None:
        assert macroxref_command_instance.typeid.MacroXrefCommand
        assert ("sample.w", 314) == macroxref_command_instance.location
        assert sentinel.MACROS == macroxref_command_instance.macros

..

..  container:: small

    ∎ *Unit test macro xref command methods should work (52)*.
    Used by     → `Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)`_.




..  _`Unit test macro xref command tangle shuould fail (53)`:
..  rubric:: Unit test macro xref command tangle shuould fail (53) =
..  code-block::
    :class: code

    
    def test_macroxrefcommand_tangle_should_fail(macroxref_command_instance) -> None:
        tangler = MockTangler()
        with pytest.raises(pyweb.Error):
            macroxref_command_instance.tangle(tangler, sentinel.TARGET)

..

..  container:: small

    ∎ *Unit test macro xref command tangle shuould fail (53)*.
    Used by     → `Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)`_.



The ``UserIdXrefCommand`` command is expanded by a weaver to a list of all ``@|`` names.


..  _`Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)`:
..  rubric:: Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def useridxref_command_instance():
        web = Mock(userids=sentinel.USERIDS)
        cmd = pyweb.UserIdXrefCommand(("sample.w", 314))
        cmd.web = Mock(return_value=web)
        return cmd
    
    → `Unit test userid xref command methods should work (55)`_    
    → `Unit test userid xref command tangle should fail (56)`_    

..

..  container:: small

    ∎ *Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit test userid xref command methods should work (55)`:
..  rubric:: Unit test userid xref command methods should work (55) =
..  code-block::
    :class: code

    
    def test_useridxref_command_methods(useridxref_command_instance) -> None:
        assert useridxref_command_instance.typeid.UserIdXrefCommand
        assert ("sample.w", 314) == useridxref_command_instance.location
        assert sentinel.USERIDS == useridxref_command_instance.userids

..

..  container:: small

    ∎ *Unit test userid xref command methods should work (55)*.
    Used by     → `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)`_.




..  _`Unit test userid xref command tangle should fail (56)`:
..  rubric:: Unit test userid xref command tangle should fail (56) =
..  code-block::
    :class: code

    
    def test_useridxref_command_tangle_should_fail(useridxref_command_instance) -> None:
        tangler = MockTangler()
        with pytest.raises(pyweb.Error):
            useridxref_command_instance.tangle(tangler, sentinel.TARGET)

..

..  container:: small

    ∎ *Unit test userid xref command tangle should fail (56)*.
    Used by     → `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)`_.



Instances of the ``Reference`` command reflect ``@< name @>`` locations in code.
These require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled, since the expand to code that may (transitively) have more references to more code.

The document here is a mock-up of the following

..  parsed-literal::

    @d name @{ @<Some Name@> @}
    
    @d Some Name @{ code @}
    
This is a single ``Chunk`` with a reference to another ``Chunk``.

The ``Web`` class ``__post_init__`` sets the ``references`` and ``referencedBy`` attributes of each ``Chunk``.


..  _`Unit Test of ReferenceCommand class for chunk references (57)`:
..  rubric:: Unit Test of ReferenceCommand class for chunk references (57) =
..  code-block::
    :class: code

    
    → `Unit Test reference command methods should work (58)`_    
    → `Unit Test reference command tangle should work (59)`_    
    
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

..

..  container:: small

    ∎ *Unit Test of ReferenceCommand class for chunk references (57)*.
    Used by     → `Unit Test of Command class hierarchy (39)`_.




..  _`Unit Test reference command methods should work (58)`:
..  rubric:: Unit Test reference command methods should work (58) =
..  code-block::
    :class: code

    
    def test_reference_command_methods(reference_command_instance) -> None:
        assert reference_command_instance.typeid.ReferenceCommand
        assert ("sample.w", 314) == reference_command_instance.location
        assert sentinel.FULL_NAME == reference_command_instance.full_name
        assert sentinel.SEQUENCE == reference_command_instance.seq

..

..  container:: small

    ∎ *Unit Test reference command methods should work (58)*.
    Used by     → `Unit Test of ReferenceCommand class for chunk references (57)`_.




..  _`Unit Test reference command tangle should work (59)`:
..  rubric:: Unit Test reference command tangle should work (59) =
..  code-block::
    :class: code

    
    def test_reference_command_tangle_should_work(reference_command_instance) -> None:
        tangler = MockTangler()
        reference_command_instance.tangle(tangler, sentinel.TARGET)
        web = reference_command_instance.web()
        web.resolve_chunk.assert_called_once_with("Some Name")
        tangler.reference_names.add.assert_called_once_with('Some Name')
        referenced_chunk = web.resolve_chunk("Some Name")[0]
        referenced_chunk.commands[0].tangle.assert_called_once_with(tangler, sentinel.TARGET)

..

..  container:: small

    ∎ *Unit Test reference command tangle should work (59)*.
    Used by     → `Unit Test of ReferenceCommand class for chunk references (57)`_.




Web Tests
-----------

We create a ``Web`` instance with mocked ``Chunks`` and mocked ``Commands``.
The point is to test the ``Web`` features in isolation.
This is tricky because some state is recorded in the ``Chunk`` instances.


..  _`Unit Test of Web class (60)`:
..  rubric:: Unit Test of Web class (60) =
..  code-block::
    :class: code

    
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
    
    → `Unit test web name resolution (61)`_    
    → `Unit test web iteration over chunks (62)`_    
    → `Unit test web tangle when valid (63)`_    
    → `Unit test web weave when valid (64)`_    

..

..  container:: small

    ∎ *Unit Test of Web class (60)*.
    Used by     → `tests/test_unit.py (1)`_.




..  _`Unit test web name resolution (61)`:
..  rubric:: Unit test web name resolution (61) =
..  code-block::
    :class: code

    
    def test_web_name_resolution(web_instance) -> None:
        assert web_instance.resolve_name("c1") == "c1"
        assert web_instance.resolve_chunk("c2") == [web_instance.chunks[1]]
        assert web_instance.resolve_name("c1...") == "c1"
        assert web_instance.resolve_name("c3...") == "c3 has a long name"

..

..  container:: small

    ∎ *Unit test web name resolution (61)*.
    Used by     → `Unit Test of Web class (60)`_.




..  _`Unit test web iteration over chunks (62)`:
..  rubric:: Unit test web iteration over chunks (62) =
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit test web iteration over chunks (62)*.
    Used by     → `Unit Test of Web class (60)`_.



This exercises the entire interface used by tangling.
All details are pushed down to ```command.tangle()`` methods for each command in each chunk.


..  _`Unit test web tangle when valid (63)`:
..  rubric:: Unit test web tangle when valid (63) =
..  code-block::
    :class: code

    
    def test_valid_web_should_tangle(web_instance) -> None:
        web = web_instance
        c1, c2, c3 = web_instance.chunks
        assert [c2], web.files

..

..  container:: small

    ∎ *Unit test web tangle when valid (63)*.
    Used by     → `Unit Test of Web class (60)`_.



This the entire interface used by weaving is the ``web.chunks`` attribute, which is implicitly tested in several places.
All chunk-specific details are pushed down to unique processing based on ``chunk.type_is``.


..  _`Unit test web weave when valid (64)`:
..  rubric:: Unit test web weave when valid (64) =
..  code-block::
    :class: code

    # No tests

..

..  container:: small

    ∎ *Unit test web weave when valid (64)*.
    Used by     → `Unit Test of Web class (60)`_.




WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

The ``WebReader`` is poorly designed for unit testing. 
The various chunk and command classes are part of the ``WebReader``, and 
new classes cannot be injected gracefully.

Exacerbating this are two special cases: the ``@@`` and ``@(expr@)`` constructs
are evaluated immediately, and don't create commands.


..  _`Unit Test of WebReader class (65)`:
..  rubric:: Unit Test of WebReader class (65) =
..  code-block::
    :class: code

    
    # Tested via functional tests

..

..  container:: small

    ∎ *Unit Test of WebReader class (65)*.
    Used by     → `tests/test_unit.py (1)`_.



Some lower-level units: specifically the tokenizer and the option parser.


..  _`Unit Test of WebReader class (66)`:
..  rubric:: Unit Test of WebReader class (66) +=
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test of WebReader class (66)*.
    Used by     → `tests/test_unit.py (1)`_.




..  _`Unit Test of WebReader class (67)`:
..  rubric:: Unit Test of WebReader class (67) +=
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test of WebReader class (67)*.
    Used by     → `tests/test_unit.py (1)`_.



Testing the ``@@`` case and one of the ``@(expr@)`` cases.
Need to test all the available variables: ``os.path``, ``os.getcwd``, ``os.name``, ``time``, ``datetime``, ``platform``, 
``theWebReader``, ``theFile``, ``thisApplication``, ``version``, ``theLocation``.

Note the escape processing has a lot of ``@`` characters in it.


..  _`Unit Test of WebReader class (68)`:
..  rubric:: Unit Test of WebReader class (68) +=
..  code-block::
    :class: code

    
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

..

..  container:: small

    ∎ *Unit Test of WebReader class (68)*.
    Used by     → `tests/test_unit.py (1)`_.



Action Tests
-------------

Each ``Action`` class is tested separately.
This requires a aequence of some mocks.
The behaviors include loading, tangling, weaving.


..  _`Unit Test of Action class hierarchy (69)`:
..  rubric:: Unit Test of Action class hierarchy (69) =
..  code-block::
    :class: code

     
    → `Unit test of Action Sequence class (70)`_    
    → `Unit test of LoadAction class (76)`_    
    → `Unit test of TangleAction class (74)`_    
    → `Unit test of WeaverAction class (72)`_    

..

..  container:: small

    ∎ *Unit Test of Action class hierarchy (69)*.
    Used by     → `tests/test_unit.py (1)`_.



**TODO:** Replace with Mock


..  _`Unit test of Action Sequence class (70)`:
..  rubric:: Unit test of Action Sequence class (70) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def action_sequence_instance():
        a1 = MagicMock(name="Action1")
        a2 = MagicMock(name="Action2")
        action = pyweb.ActionSequence("TwoSteps", [a1, a2])
        action.web = mock_web()
        return action
    
    → `Unit test of action sequence (71)`_    

..

..  container:: small

    ∎ *Unit test of Action Sequence class (70)*.
    Used by     → `Unit Test of Action class hierarchy (69)`_.




..  _`Unit test of action sequence (71)`:
..  rubric:: Unit test of action sequence (71) =
..  code-block::
    :class: code

    
    def test_action_sequence_execute_both(action_sequence_instance) -> None:
        action_sequence_instance(sentinel.OPTIONS)
        action_sequence_instance.opSequence[0].assert_called_once_with(sentinel.OPTIONS)
        action_sequence_instance.opSequence[1].assert_called_once_with(sentinel.OPTIONS)

..

..  container:: small

    ∎ *Unit test of action sequence (71)*.
    Used by     → `Unit test of Action Sequence class (70)`_.




..  _`Unit test of WeaverAction class (72)`:
..  rubric:: Unit test of WeaverAction class (72) =
..  code-block::
    :class: code

     
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
    
    → `Unit test WeaveAction should call Weaver (73)`_    

..

..  container:: small

    ∎ *Unit test of WeaverAction class (72)*.
    Used by     → `Unit Test of Action class hierarchy (69)`_.




..  _`Unit test WeaveAction should call Weaver (73)`:
..  rubric:: Unit test WeaveAction should call Weaver (73) =
..  code-block::
    :class: code

    
    def test_weave_action(action_weave_instance) -> None:
        action, options = action_weave_instance
        action(options)
        options.theWeaver.emit.assert_called_once_with(options.web)

..

..  container:: small

    ∎ *Unit test WeaveAction should call Weaver (73)*.
    Used by     → `Unit test of WeaverAction class (72)`_.




..  _`Unit test of TangleAction class (74)`:
..  rubric:: Unit test of TangleAction class (74) =
..  code-block::
    :class: code

    
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
    
    → `Unit test TangleAction should call Tangler (75)`_    

..

..  container:: small

    ∎ *Unit test of TangleAction class (74)*.
    Used by     → `Unit Test of Action class hierarchy (69)`_.




..  _`Unit test TangleAction should call Tangler (75)`:
..  rubric:: Unit test TangleAction should call Tangler (75) =
..  code-block::
    :class: code

    
    def test_tangle_action(action_tangle_instance) -> None:
        action, options = action_tangle_instance
        action(options)
        options.theTangler.emit.assert_called_once_with(options.web)

..

..  container:: small

    ∎ *Unit test TangleAction should call Tangler (75)*.
    Used by     → `Unit test of TangleAction class (74)`_.



The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.


..  _`Unit test of LoadAction class (76)`:
..  rubric:: Unit test of LoadAction class (76) =
..  code-block::
    :class: code

     
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
    
    → `Unit test LoadAction should call WebReader (77)`_    

..

..  container:: small

    ∎ *Unit test of LoadAction class (76)*.
    Used by     → `Unit Test of Action class hierarchy (69)`_.




..  _`Unit test LoadAction should call WebReader (77)`:
..  rubric:: Unit test LoadAction should call WebReader (77) =
..  code-block::
    :class: code

    
    def test_loader_action(action_loader_instance) -> None:
        action, options = action_loader_instance
        action(options)
        options.webReader.load.assert_called_once_with(options.source_path)

..

..  container:: small

    ∎ *Unit test LoadAction should call WebReader (77)*.
    Used by     → `Unit test of LoadAction class (76)`_.



Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.

**TODO:** Test Application class


..  _`Unit Test of Application class (78)`:
..  rubric:: Unit Test of Application class (78) =
..  code-block::
    :class: code

    # TODO Test Application class 

..

..  container:: small

    ∎ *Unit Test of Application class (78)*.
    Used by     → `tests/test_unit.py (1)`_.



Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.


..  _`Unit Test overheads: imports, etc. (79)`:
..  rubric:: Unit Test overheads: imports, etc. (79) =
..  code-block::
    :class: code

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

..

..  container:: small

    ∎ *Unit Test overheads: imports, etc. (79)*.
    Used by     → `tests/test_unit.py (1)`_.



One more overhead is a function to cleanup output files.


..  _`Unit Test overheads: imports, etc. (80)`:
..  rubric:: Unit Test overheads: imports, etc. (80) +=
..  code-block::
    :class: code

    
    def rstrip_lines(source: str) -> list[str]:
        return list(l.rstrip() for l in source.splitlines())    

..

..  container:: small

    ∎ *Unit Test overheads: imports, etc. (80)*.
    Used by     → `tests/test_unit.py (1)`_.





Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-   `Tests for Loading`_

-   `Tests for Tangling`_

-   `Tests for Weaving`_

Because of some overlaps in fixture definition, there is also a ``conftest.py`` file that contains the shared test fixtures.

Shared Fixtures
---------------


..  _`tests/conftest.py (81)`:
..  rubric:: tests/conftest.py (81) =
..  code-block::
    :class: code

    
    import io
    from pathlib import Path
    from typing import TextIO
    import pytest
    import pyweb
    
    → `Fixture for Source, WebReader, and Path (82)`_    
    
    → `Fixture for Source, WebReader, Path, with an Include (83)`_    

..

..  container:: small

    ∎ *tests/conftest.py (81)*.
    



These fixtures require a "marker" set in each test that uses them.
The marker provides needed parameter values.

Many of the parsing test cases have a common setup shown in this fixture.


..  _`Fixture for Source, WebReader, and Path (82)`:
..  rubric:: Fixture for Source, WebReader, and Path (82) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def source_path(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
        marker = request.node.get_closest_marker("text_name")
        text, name = marker.args
        source = io.StringIO(text)
        path = tmp_path / name
        return source, path

..

..  container:: small

    ∎ *Fixture for Source, WebReader, and Path (82)*.
    Used by     → `tests/conftest.py (81)`_.



Some of the more complex cases inject an Include file.
This requires a somewhat more complicated fixture.


..  _`Fixture for Source, WebReader, Path, with an Include (83)`:
..  rubric:: Fixture for Source, WebReader, Path, with an Include (83) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def source_path_incl(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
        marker = request.node.get_closest_marker("text_name_incl")
        text, name, incl_text, incl_name = marker.args
        include_path = tmp_path / incl_name
        include_path.write_text(incl_text)
        source = io.StringIO(text)
        path = tmp_path / name
        return source, path

..

..  container:: small

    ∎ *Fixture for Source, WebReader, Path, with an Include (83)*.
    Used by     → `tests/conftest.py (81)`_.



Additionally, a ``pytest.ini`` is also required to register the marks used to provide test parameters to a fixture.
This also sets a logging format to assure the log messages have the expected format.


..  _`pytest.ini (84)`:
..  rubric:: pytest.ini (84) =
..  code-block::
    :class: code

    
    [pytest]
    markers =
        text_name: a blob of text, the path name
        text_name_incl: a blob of text, a path, a blob of include text, the include path
    log_format = %(levelname)s:%(name)s:%(message)s

..

..  container:: small

    ∎ *pytest.ini (84)*.
    



Tests for Loading
------------------

We need to be able to load a web from one or more source files.


..  _`tests/test_loader.py (85)`:
..  rubric:: tests/test_loader.py (85) =
..  code-block::
    :class: code

    → `Load Test overheads: imports, etc. (90)`_    
    
    → `Load Test error handling with a few common syntax errors (86)`_    
    
    → `Load Test include processing with syntax errors (88)`_    

..

..  container:: small

    ∎ *tests/test_loader.py (85)*.
    



There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to  find an expected next token.


..  _`Load Test error handling with a few common syntax errors (86)`:
..  rubric:: Load Test error handling with a few common syntax errors (86) =
..  code-block::
    :class: code

    
    
    → `Sample Document 1 with correct and incorrect syntax (87)`_    
    
    @pytest.mark.text_name(test1_w, "test1.w")
    def test_error_should_count_1(source_path, caplog):
        source, file_path = source_path
        rdr = pyweb.WebReader()
    
        with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
            chunks = rdr.load(file_path, source)
        assert 3 == rdr.errors
        assert caplog.text.splitlines() == [
            "ERROR:WebReader:At ('test1.w', 8): expected {'@{'}, found '@o'",
            "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)",
            "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)"
        ]

..

..  container:: small

    ∎ *Load Test error handling with a few common syntax errors (86)*.
    Used by     → `tests/test_loader.py (85)`_.




..  _`Sample Document 1 with correct and incorrect syntax (87)`:
..  rubric:: Sample Document 1 with correct and incorrect syntax (87) =
..  code-block::
    :class: code

    
    test1_w = """Some anonymous chunk
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

..  container:: small

    ∎ *Sample Document 1 with correct and incorrect syntax (87)*.
    Used by     → `Load Test error handling with a few common syntax errors (86)`_.



All of the parsing exceptions should be correctly identified with any included file.
We'll cover most of the cases with a quick check for a failure to find an expected next token.

In order to test the include file processing, we have to actually create a temporary file.
It's hard to mock the include processing, since it's a nested instance of the tokenizer.


..  _`Load Test include processing with syntax errors (88)`:
..  rubric:: Load Test include processing with syntax errors (88) =
..  code-block::
    :class: code

    
    → `Sample Document 8 and the file it includes (89)`_    
    
    @pytest.mark.text_name_incl(test8_w, "test8.w", test8_inc_w, 'test8_inc.w')
    def test_error_should_count_2(caplog, tmp_path, source_path_incl) -> None:
        source, file_path = source_path_incl
        rdr = pyweb.WebReader()
        with caplog.at_level(level='WARN', logger='WebReader') as log_capture:
            chunks = rdr.load(file_path, source)
        assert 1 == rdr.errors
        assert caplog.text.splitlines() == [
            "ERROR:WebReader:At ('test8_inc.w', 4): end of input, {'@{', '@['} not found",
            "ERROR:WebReader:Errors in included file 'test8_inc.w', output is incomplete."
        ]

..

..  container:: small

    ∎ *Load Test include processing with syntax errors (88)*.
    Used by     → `tests/test_loader.py (85)`_.



The sample document must reference the correct name that will be given to the included document by ``setUp``.


..  _`Sample Document 8 and the file it includes (89)`:
..  rubric:: Sample Document 8 and the file it includes (89) =
..  code-block::
    :class: code

    
    test8_w = """Some anonymous chunk.
    @d title @[the title of this document, defined with @@[ and @@]@]
    A reference to @<title@>.
    @i test8_inc.w
    A final anonymous chunk from test8.w
    """
    
    test8_inc_w="""A chunk from test8a.w
    And now for an error - incorrect syntax in an included file!
    @d yap
    """

..

..  container:: small

    ∎ *Sample Document 8 and the file it includes (89)*.
    Used by     → `Load Test include processing with syntax errors (88)`_.



The overheads for a Python test.


..  _`Load Test overheads: imports, etc. (90)`:
..  rubric:: Load Test overheads: imports, etc. (90) =
..  code-block::
    :class: code

    
    """Loader and parsing tests."""
    import io
    import logging
    import logging.handlers
    import os
    from pathlib import Path
    import string
    import sys
    from textwrap import dedent
    import types
    from typing import TextIO
    
    import pytest
    
    import pyweb

..

..  container:: small

    ∎ *Load Test overheads: imports, etc. (90)*.
    Used by     → `tests/test_loader.py (85)`_.



Tests for Tangling
------------------

We need to be able to tangle a web.


..  _`tests/test_tangler.py (91)`:
..  rubric:: tests/test_tangler.py (91) =
..  code-block::
    :class: code

    → `Tangle Test overheads: imports, etc. (99)`_    
    
    → `Tangle Test semantic errors 2-5 (94)`_    
    
    → `Tangle Test fixture to refactor common setup (92)`_    
    → `Tangle Test function to execute cases (93)`_    
    
    → `Tangle Test semantic error 6 (95)`_    
    → `Tangle Test include example 7 (97)`_    

..

..  container:: small

    ∎ *tests/test_tangler.py (91)*.
    



Tangling test cases have a common setup and teardown shown in this fixture.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the exceptions raised.

Since these test cases are all very similar, we can use a parameterized fixture to execute a single test function repeatedly.


..  _`Tangle Test fixture to refactor common setup (92)`:
..  rubric:: Tangle Test fixture to refactor common setup (92) =
..  code-block::
    :class: code

    
    tangle_cases = [
        (test2_w, "test2.w", "Attempt to tangle an undefined Chunk, 'part2'"),
        (test3_w, "test3.w", "Illegal tangling of a cross reference command."),
        (test4_w, "test4.w", "No full name for 'part1...'"),
        (test5_w, "test5.w", "Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']"),
    ]
    
    @pytest.fixture(params=tangle_cases)
    def source_reader_path_tangler_error(request, tmp_path) -> [TextIO, pyweb.WebReader, Path, pyweb.Tangler, str]:
        text, name, error = request.param
        source = io.StringIO(text)
        rdr = pyweb.WebReader()
        path = tmp_path / name
        tangler = pyweb.Tangler(tmp_path)
        yield source, rdr, path, tangler, error
        for output in tmp_path.glob("*.tmp"):
            output.unlink()

..

..  container:: small

    ∎ *Tangle Test fixture to refactor common setup (92)*.
    Used by     → `tests/test_tangler.py (91)`_.




..  _`Tangle Test function to execute cases (93)`:
..  rubric:: Tangle Test function to execute cases (93) =
..  code-block::
    :class: code

    
    def test_tangle_and_check_exception(source_reader_path_tangler_error) -> None:
        source, rdr, file_path, tangler, exception_text = source_reader_path_tangler_error
    
        with pytest.raises(pyweb.Error) as exc_info:
            chunks = rdr.load(file_path, source)
            web = pyweb.Web(chunks)
            tangler.emit(web)
            assert False, "Should not tangle"
        assert exception_text == exc_info.value.args[0]

..

..  container:: small

    ∎ *Tangle Test function to execute cases (93)*.
    Used by     → `tests/test_tangler.py (91)`_.




..  _`Tangle Test semantic errors 2-5 (94)`:
..  rubric:: Tangle Test semantic errors 2-5 (94) =
..  code-block::
    :class: code

    
    test2_w = """Some anonymous chunk
    @o test2.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    Okay, now for some errors: no part2!
    """
    
    test3_w = """Some anonymous chunk
    @o test3.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    @d part2 @{This is part 2, with an illegal: @f.@}
    Okay, now for some errors: attempt to tangle a cross-reference!
    """
    
    test4_w = """Some anonymous chunk
    @o test4.tmp
    @{@<part1...@>
    @<part2@>
    @}@@
    @d part1... @{This is part 1.@}
    @d part2 @{This is part 2.@}
    Okay, now for some errors: attempt to weave but no full name for part1....
    """
    
    test5_w = """
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

..  container:: small

    ∎ *Tangle Test semantic errors 2-5 (94)*.
    Used by     → `tests/test_tangler.py (91)`_.



The remaining errors have unique features, and can't use the generic test function.
The first of these looks for a number of warnings, instead of an exception.


..  _`Tangle Test semantic error 6 (95)`:
..  rubric:: Tangle Test semantic error 6 (95) =
..  code-block::
    :class: code

     
    → `Sample Document 6 (96)`_    
    
    @pytest.mark.text_name(test6_w, "test6.w")
    def test_tangle_warnings(tmp_path, source_path) -> None:
        source, file_path = source_path
        rdr = pyweb.WebReader()
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        tangler = pyweb.Tangler(tmp_path)
        tangler.emit(web)
        print(web.no_reference())
        assert 1 == len(web.no_reference())
        assert 1 == len(web.multi_reference())
        assert {'part1a', 'part1...'} == tangler.reference_names

..

..  container:: small

    ∎ *Tangle Test semantic error 6 (95)*.
    Used by     → `tests/test_tangler.py (91)`_.




..  _`Sample Document 6 (96)`:
..  rubric:: Sample Document 6 (96) =
..  code-block::
    :class: code

    
    test6_w = """Some anonymous chunk
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

..  container:: small

    ∎ *Sample Document 6 (96)*.
    Used by     → `Tangle Test semantic error 6 (95)`_.




..  _`Tangle Test include example 7 (97)`:
..  rubric:: Tangle Test include example 7 (97) =
..  code-block::
    :class: code

    
    → `Sample Document 7 and it's included file (98)`_    
    
    @pytest.mark.text_name_incl(test7_w, "test7.w", test7_inc_w, 'test7_inc.tmp')
    def test_tangle_should_include(tmp_path, source_path_incl) -> None:
        source, file_path = source_path_incl
        rdr = pyweb.WebReader()
    
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        tangler = pyweb.Tangler(tmp_path)
        tangler.emit(web)
        assert 5 == len(web.chunks)
        assert test7_inc_w == web.chunks[3].commands[0].text

..

..  container:: small

    ∎ *Tangle Test include example 7 (97)*.
    Used by     → `tests/test_tangler.py (91)`_.




..  _`Sample Document 7 and it's included file (98)`:
..  rubric:: Sample Document 7 and it's included file (98) =
..  code-block::
    :class: code

    
    test7_w = """
    Some anonymous chunk.
    @d title @[the title of this document, defined with @@[ and @@]@]
    A reference to @<title@>.
    @i test7_inc.tmp
    A final anonymous chunk from test7.w
    """
    
    test7_inc_w = """The test7a.tmp chunk for test7.w"""

..

..  container:: small

    ∎ *Sample Document 7 and it's included file (98)*.
    Used by     → `Tangle Test include example 7 (97)`_.




..  _`Tangle Test overheads: imports, etc. (99)`:
..  rubric:: Tangle Test overheads: imports, etc. (99) =
..  code-block::
    :class: code

    
    """Tangler tests exercise various semantic features."""
    import io
    import logging
    import os
    from pathlib import Path
    from typing import ClassVar, TextIO
    
    import pytest
    
    import pyweb

..

..  container:: small

    ∎ *Tangle Test overheads: imports, etc. (99)*.
    Used by     → `tests/test_tangler.py (91)`_.




Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.


..  _`tests/test_weaver.py (100)`:
..  rubric:: tests/test_weaver.py (100) =
..  code-block::
    :class: code

    → `Weave Test overheads: imports, etc. (107)`_    
    
    → `Weave Test references and definitions (101)`_    
    → `Weave Test evaluation of expressions (105)`_    

..

..  container:: small

    ∎ *tests/test_weaver.py (100)*.
    



Weaving test cases have a common setup shown in this fixture.


..  _`Weave Test references and definitions (101)`:
..  rubric:: Weave Test references and definitions (101) =
..  code-block::
    :class: code

    
    → `Sample Document 0 (102)`_    
    → `Expected Output 0 (103)`_    
    
    
    @pytest.mark.text_name(test0_w, "test0.w")
    def test_load_should_createChunks(source_path) -> None:
        source, file_path = source_path
        rdr = pyweb.WebReader()
        chunks = rdr.load(file_path, source)
        assert 3 == len(chunks)
            
    @pytest.mark.text_name(test0_w, "test0.w")
    def test_weave_should_create_html(tmp_path, source_path) -> None:
        source, file_path = source_path
        rdr = pyweb.WebReader()
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        web.web_path = file_path
        doc = pyweb.Weaver( )
        doc.set_markup("html")
        doc.output = tmp_path
        doc.emit(web)
        assert doc.target_path == file_path.with_suffix(".html")
        actual = doc.target_path.read_text()
        assert test0_expected_html == actual
            
    @pytest.mark.text_name(test0_w, "test0.w")
    def test_weave_should_create_debug(tmp_path, source_path) -> None:
        source, file_path = source_path
        rdr = pyweb.WebReader()
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        web.web_path = file_path
        doc = pyweb.Weaver( )
        doc.set_markup("debug")
        doc.output = tmp_path
        doc.emit(web)
        assert doc.target_path == file_path.with_suffix(".debug")
        actual = doc.target_path.read_text()
        assert test0_expected_debug == actual

..

..  container:: small

    ∎ *Weave Test references and definitions (101)*.
    Used by     → `tests/test_weaver.py (100)`_.




..  _`Sample Document 0 (102)`:
..  rubric:: Sample Document 0 (102) =
..  code-block::
    :class: code

     
    test0_w = """<html>
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
            if p%2 == 1: return n*fastExp(n,p-1)
        return n*n*fastExp(n,p/2)
    
    for i in range(24):
        fastExp(2,i)
    @}
    </body>
    </html>
    """

..

..  container:: small

    ∎ *Sample Document 0 (102)*.
    Used by     → `Weave Test references and definitions (101)`_.




..  _`Expected Output 0 (103)`:
..  rubric:: Expected Output 0 (103) =
..  code-block::
    :class: code

    
    test0_expected_html = """<html>
    <head>
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />
    </head>
    <body>
    &rarr;<a href="#pyweb_1"><em>some code (1)</em></a>
    
    
    <a name="pyweb_1"></a>
    <!--line number ('test0.w', 10)-->
    <p><em>some code (1)</em> =</p>
    <pre><code>
    def fastExp(n, p):
        r = 1
        while p &gt; 0:
            if p%2 == 1: return n*fastExp(n,p-1)
        return n*n*fastExp(n,p/2)
    
    for i in range(24):
        fastExp(2,i)
    
    </code></pre>
    <p>&#8718; <em>some code (1)</em>.
    
    </p> 
    
    </body>
    </html>
    """

..

..  container:: small

    ∎ *Expected Output 0 (103)*.
    Used by     → `Weave Test references and definitions (101)`_.




..  _`Expected Output 0 (104)`:
..  rubric:: Expected Output 0 (104) +=
..  code-block::
    :class: code

    
    test0_expected_debug = (
        'text: TextCommand(text=\'<html>\\n<head>\\n    <link rel="StyleSheet" href="pyweb.css" type="text/css" />\\n</head>\\n<body>\\n\', location=(\'test0.w\', 1))\n'
        "ref: ReferenceCommand(name='some code', location=('test0.w', 6))"
        "text: TextCommand(text='\\n\\n', location=('test0.w', 7))\n"
        "begin_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
        "code: CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))\n"
        "end_code: NamedChunk(options=['some', 'code'], name='some code', seq=1, commands=[CodeCommand(text='\\ndef fastExp(n, p):\\n    r = 1\\n    while p > 0:\\n        if p%2 == 1: return n*fastExp(n,p-1)\\n    return n*n*fastExp(n,p/2)\\n\\nfor i in range(24):\\n    fastExp(2,i)\\n', location=('test0.w', 10))], def_names=[], initial=True, comment_start=None, comment_end=None, weave=True, style=None, references=0, referencedBy=None, logger=<Logger Chunk (INFO)>, indent=None)\n"
        "text: TextCommand(text='\\n</body>\\n</html>\\n', location=('test0.w', 19))"
        )

..

..  container:: small

    ∎ *Expected Output 0 (104)*.
    Used by     → `Weave Test references and definitions (101)`_.



Note that this requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.


..  _`Weave Test evaluation of expressions (105)`:
..  rubric:: Weave Test evaluation of expressions (105) =
..  code-block::
    :class: code

    
    → `Sample Document 9 (106)`_    
    
    from unittest.mock import Mock
    
    @pytest.fixture()
    def mock_time(monkeypatch):
        mock_time = Mock(asctime=Mock(return_value="mocked time"))
        monkeypatch.setattr(pyweb, "time", mock_time)
        return mock_time
    
    @pytest.mark.text_name(test9_w, "test9.w")
    def test_should_evaluate(tmp_path, source_path, mock_time) -> None:
        source, file_path = source_path
        rdr = pyweb.WebReader()
        chunks = rdr.load(file_path, source)
        web = pyweb.Web(chunks)
        web.web_path = file_path
        doc = pyweb.Weaver( )
        doc.set_markup("html")
        doc.output = tmp_path
        doc.emit(web)
        assert doc.target_path == file_path.with_suffix(".html")
        actual = doc.target_path.read_text().splitlines()
        #print(actual)
        assert "An anonymous chunk." == actual[0]
        assert "Time = mocked time" == actual[1]
        assert "File = ('test9.w', 3)" == actual[2]
        assert 'Version = 3.3' == actual[3]
        assert f'CWD = {os.getcwd()}' == actual[4]

..

..  container:: small

    ∎ *Weave Test evaluation of expressions (105)*.
    Used by     → `tests/test_weaver.py (100)`_.




..  _`Sample Document 9 (106)`:
..  rubric:: Sample Document 9 (106) =
..  code-block::
    :class: code

    
    test9_w= """An anonymous chunk.
    Time = @(time.asctime()@)
    File = @(theLocation@)
    Version = @(__version__@)
    CWD = @(os.path.realpath('.')@)
    """

..

..  container:: small

    ∎ *Sample Document 9 (106)*.
    Used by     → `Weave Test evaluation of expressions (105)`_.




..  _`Weave Test overheads: imports, etc. (107)`:
..  rubric:: Weave Test overheads: imports, etc. (107) =
..  code-block::
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
    
    import pytest
    
    import pyweb

..

..  container:: small

    ∎ *Weave Test overheads: imports, etc. (107)*.
    Used by     → `tests/test_weaver.py (100)`_.




Additional Scripts Testing
==========================

.. test/scripts.w

We provide these two additional scripts; effectively command-line short-cuts:

-   ``tangle.py``

-   ``weave.py``

These isolate specific actions, making it slightly easier to provide a new subclass or macro configuration.
These need their own test cases.


This gives us the following outline for the script testing.


..  _`tests/test_scripts.py (108)`:
..  rubric:: tests/test_scripts.py (108) =
..  code-block::
    :class: code

    → `Script Test overheads: imports, etc. (113)`_    
    
    → `Sample web file to test with (109)`_    
    
    → `Fixture for test cases (110)`_    
    
    → `Test of weave.py (111)`_    
    
    → `Test of tangle.py (112)`_    

..

..  container:: small

    ∎ *tests/test_scripts.py (108)*.
    



Sample Web File
---------------

This is a web ``.w`` file to create a document and tangle a small file.


..  _`Sample web file to test with (109)`:
..  rubric:: Sample web file to test with (109) =
..  code-block::
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
            
        @o sample_tangle.code
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

..  container:: small

    ∎ *Sample web file to test with (109)*.
    Used by     → `tests/test_scripts.py (108)`_.



Fixture for test cases
-------------------------

The ``sample_path`` is a consistent test fixture for both test cases.
The sample ``test_sample.w`` file is created and removed after the test.


..  _`Fixture for test cases (110)`:
..  rubric:: Fixture for test cases (110) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def sample_path(tmp_path) -> Path:
        sample_path = tmp_path / "test_sample.w"
        sample_path.write_text(sample)
        yield sample_path
        sample_path.unlink()
    
    def clean_lines(first: str) -> list[str]:
        """Strips blank lines and trailing whitespace that (generally) aren't problems when weaving."""
        def non_blank(line: str) -> bool:
            return len(line) > 0
        return list(filter(non_blank, (line.rstrip() for line in first.splitlines())))

..

..  container:: small

    ∎ *Fixture for test cases (110)*.
    Used by     → `tests/test_scripts.py (108)`_.



Weave Script Test
-----------------

We check the weave output to be sure it's what we expected. 
This could be altered to check a few features of the weave file rather than compare the entire file.


..  _`Test of weave.py (111)`:
..  rubric:: Test of weave.py (111) =
..  code-block::
    :class: code

    
    @pytest.fixture
    def expected_weave(sample_path) -> str:
        expected_weave = ('<!doctype html>\n'
            '<html lang="en">\n'
            '  <head>\n'
            '    <meta charset="utf-8">\n'
            '    <meta name="viewport" content="width=device-width, initial-scale=1">\n'
            '    <title>Sample HTML web file</title>\n'
            '  </head>\n'
            '  <body>\n'
            '    <h1>Sample HTML web file</h1>\n'
            "    <p>We're avoiding using Python specifically.\n"
            '    This hints at other languages being tangled by this tool.</p>\n'
            '<div class="card">\n'
            '  <div class="card-header">\n'
            '    <a type="button" class="btn btn-primary" name="pyweb_1"></a>\n'
            "    <!--line number ('test_sample.w', 16)-->\n"
            '    <p class="small"><em>sample_tangle.code (1)</em> =</p>\n'
            '   </div>\n'
            '  <div class="card-body">\n'
            '    <pre><code>\n'
            '&rarr;<a href="#pyweb_2"><em>preamble (2)</em></a>\n'
            '&rarr;<a href="#pyweb_3"><em>body (3)</em></a>\n'
            '    </code></pre>\n'
            '  </div>\n'
            '<div class="card-footer">\n'
            '  <p>&#8718; <em>sample_tangle.code (1)</em>.\n'
            '  </p>\n'
            '</div>\n'
            '</div>\n'
            '<div class="card">\n'
            '  <div class="card-header">\n'
            '    <a type="button" class="btn btn-primary" name="pyweb_2"></a>\n'
            "    <!--line number ('test_sample.w', 22)-->\n"
            '    <p class="small"><em>preamble (2)</em> =</p>\n'
            '   </div>\n'
            '  <div class="card-body">\n'
            '    <pre><code>\n'
            '#include &lt;stdio.h&gt;\n'
            '    </code></pre>\n'
            '  </div>\n'
            '<div class="card-footer">\n'
            '  <p>&#8718; <em>preamble (2)</em>.\n'
            '  </p>\n'
            '</div>\n'
            '</div>\n'
            '<div class="card">\n'
            '  <div class="card-header">\n'
            '    <a type="button" class="btn btn-primary" name="pyweb_3"></a>\n'
            "    <!--line number ('test_sample.w', 27)-->\n"
            '    <p class="small"><em>body (3)</em> =</p>\n'
            '   </div>\n'
            '  <div class="card-body">\n'
            '    <pre><code>\n'
            'int main() {\n'
            '    println(&quot;Hello, World!&quot;)\n'
            '}\n'
            '    </code></pre>\n'
            '  </div>\n'
            '<div class="card-footer">\n'
            '  <p>&#8718; <em>body (3)</em>.\n'
            '  </p>\n'
            '</div>\n'
            '</div>\n'
            '  </body>\n'
            '</html>')
        return expected_weave
    
    def test_weave(sample_path: Path, expected_weave) -> None:
        output = sample_path.with_suffix(".html")
    
        weave.main(sample_path)
        result = output.read_text()
        output.unlink()
    
        assert clean_lines(expected_weave) == clean_lines(result)

..

..  container:: small

    ∎ *Test of weave.py (111)*.
    Used by     → `tests/test_scripts.py (108)`_.



Tangle Script Test
------------------

We check the tangle output to be sure it's what we expected. 


..  _`Test of tangle.py (112)`:
..  rubric:: Test of tangle.py (112) =
..  code-block::
    :class: code

    
    
    expected_tangle = textwrap.dedent("""
    
        #include <stdio.h>
        
        
        int main() {
            println("Hello, World!")
        }
        
        """)
    
    def test_tangle(sample_path):
        # Name comes from ``@o`` command
        output = sample_path.parent / "sample_tangle.code"
    
        tangle.main(sample_path)
        result = output.read_text()
        output.unlink()
        assert clean_lines(expected_tangle) == clean_lines(result)

..

..  container:: small

    ∎ *Test of tangle.py (112)*.
    Used by     → `tests/test_scripts.py (108)`_.



Overheads
--------------------------

These are the common Python overheads required for testing.
Import some modules used in general.
Import ``pytest`` to provide helpful definitions.
Import the modules under test.


..  _`Script Test overheads: imports, etc. (113)`:
..  rubric:: Script Test overheads: imports, etc. (113) =
..  code-block::
    :class: code

    
    """Script tests."""
    import logging
    from pathlib import Path
    import sys
    import textwrap
    
    import pytest
    
    import tangle
    import weave

..

..  container:: small

    ∎ *Script Test overheads: imports, etc. (113)*.
    Used by     → `tests/test_scripts.py (108)`_.



Run this test with the following command:

.. code-block:: bash

    PYTHONPATH=src pytest tests/test_scripts.py

This will put the local ``src`` directory on the ``PYTHONPATH``, so the modules under test can be imported.


Indices
=======

Files
-----

:tests/test_unit.py:
    → `tests/test_unit.py (1)`_:tests/conftest.py:
    → `tests/conftest.py (81)`_:pytest.ini:
    → `pytest.ini (84)`_:tests/test_loader.py:
    → `tests/test_loader.py (85)`_:tests/test_tangler.py:
    → `tests/test_tangler.py (91)`_:tests/test_weaver.py:
    → `tests/test_weaver.py (100)`_:tests/test_scripts.py:
    → `tests/test_scripts.py (108)`_

Macros
------

:Expected Output 0:
    → `Expected Output 0 (103)`_, → `Expected Output 0 (104)`_

:Fixture for Source, WebReader, Path, with an Include:
    → `Fixture for Source, WebReader, Path, with an Include (83)`_

:Fixture for Source, WebReader, and Path:
    → `Fixture for Source, WebReader, and Path (82)`_

:Fixture for test cases:
    → `Fixture for test cases (110)`_

:Load Test error handling with a few common syntax errors:
    → `Load Test error handling with a few common syntax errors (86)`_

:Load Test include processing with syntax errors:
    → `Load Test include processing with syntax errors (88)`_

:Load Test overheads: imports, etc.:
    → `Load Test overheads: imports, etc. (90)`_

:Sample Document 0:
    → `Sample Document 0 (102)`_

:Sample Document 1 with correct and incorrect syntax:
    → `Sample Document 1 with correct and incorrect syntax (87)`_

:Sample Document 6:
    → `Sample Document 6 (96)`_

:Sample Document 7 and it's included file:
    → `Sample Document 7 and it's included file (98)`_

:Sample Document 8 and the file it includes:
    → `Sample Document 8 and the file it includes (89)`_

:Sample Document 9:
    → `Sample Document 9 (106)`_

:Sample web file to test with:
    → `Sample web file to test with (109)`_

:Script Test overheads: imports, etc.:
    → `Script Test overheads: imports, etc. (113)`_

:Tangle Test fixture to refactor common setup:
    → `Tangle Test fixture to refactor common setup (92)`_

:Tangle Test function to execute cases:
    → `Tangle Test function to execute cases (93)`_

:Tangle Test include example 7:
    → `Tangle Test include example 7 (97)`_

:Tangle Test overheads: imports, etc.:
    → `Tangle Test overheads: imports, etc. (99)`_

:Tangle Test semantic error 6:
    → `Tangle Test semantic error 6 (95)`_

:Tangle Test semantic errors 2-5:
    → `Tangle Test semantic errors 2-5 (94)`_

:Test of tangle.py:
    → `Test of tangle.py (112)`_

:Test of weave.py:
    → `Test of weave.py (111)`_

:Unit Test Mock Chunk class:
    → `Unit Test Mock Chunk class (4)`_

:Unit Test of Action class hierarchy:
    → `Unit Test of Action class hierarchy (69)`_

:Unit Test of Application class:
    → `Unit Test of Application class (78)`_

:Unit Test of Chunk References:
    → `Unit Test of Chunk References (34)`_

:Unit Test of Chunk class hierarchy:
    → `Unit Test of Chunk class hierarchy (14)`_

:Unit Test of Chunk construction:
    → `Unit Test of Chunk construction (19)`_

:Unit Test of Chunk interrogation:
    → `Unit Test of Chunk interrogation (20)`_

:Unit Test of Chunk properties:
    → `Unit Test of Chunk properties (21)`_

:Unit Test of Chunk superclass:
    → `Unit Test of Chunk superclass (15)`_, → `Unit Test of Chunk superclass (16)`_, → `Unit Test of Chunk superclass (17)`_, → `Unit Test of Chunk superclass (18)`_

:Unit Test of CodeCommand class to contain a program source code block:
    → `Unit Test of CodeCommand class to contain a program source code block (44)`_

:Unit Test of Command class hierarchy:
    → `Unit Test of Command class hierarchy (39)`_

:Unit Test of Command superclass:
    → `Unit Test of Command superclass (40)`_

:Unit Test of Emitter Superclass:
    → `Unit Test of Emitter Superclass (3)`_

:Unit Test of Emitter class hierarchy:
    → `Unit Test of Emitter class hierarchy (2)`_

:Unit Test of FileXrefCommand class for an output file cross-reference:
    → `Unit Test of FileXrefCommand class for an output file cross-reference (48)`_

:Unit Test of HTML macros in Weaver:
    → `Unit Test of HTML macros in Weaver (10)`_

:Unit Test of LaTeX macros in Weaver:
    → `Unit Test of LaTeX macros in Weaver (7)`_

:Unit Test of MacroXrefCommand class for a named chunk cross-reference:
    → `Unit Test of MacroXrefCommand class for a named chunk cross-reference (51)`_

:Unit Test of NamedChunk subclass:
    → `Unit Test of NamedChunk subclass (22)`_

:Unit Test of NamedChunk with no indent:
    → `Unit Test of NamedChunk with no indent (25)`_

:Unit Test of NamedDocumentChunk subclass:
    → `Unit Test of NamedDocumentChunk subclass (31)`_

:Unit Test of OutputChunk subclass:
    → `Unit Test of OutputChunk subclass (28)`_

:Unit Test of ReferenceCommand class for chunk references:
    → `Unit Test of ReferenceCommand class for chunk references (57)`_

:Unit Test of Tangler subclass of Emitter:
    → `Unit Test of Tangler subclass of Emitter (12)`_

:Unit Test of TanglerMake subclass of Emitter:
    → `Unit Test of TanglerMake subclass of Emitter (13)`_

:Unit Test of TextCommand class to contain a document text block:
    → `Unit Test of TextCommand class to contain a document text block (41)`_

:Unit Test of UserIdXrefCommand class for a user identifier cross-reference:
    → `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (54)`_

:Unit Test of Weaver subclass of Emitter:
    → `Unit Test of Weaver subclass of Emitter (5)`_

:Unit Test of Web class:
    → `Unit Test of Web class (60)`_

:Unit Test of WebReader class:
    → `Unit Test of WebReader class (65)`_, → `Unit Test of WebReader class (66)`_, → `Unit Test of WebReader class (67)`_, → `Unit Test of WebReader class (68)`_

:Unit Test of XrefCommand superclass for all cross-reference commands:
    → `Unit Test of XrefCommand superclass for all cross-reference commands (47)`_

:Unit Test output chunk properties:
    → `Unit Test output chunk properties (30)`_

:Unit Test output chunk xref:
    → `Unit Test output chunk xref (29)`_

:Unit Test overheads: imports, etc.:
    → `Unit Test overheads: imports, etc. (79)`_, → `Unit Test overheads: imports, etc. (80)`_

:Unit Test reference command methods should work:
    → `Unit Test reference command methods should work (58)`_

:Unit Test reference command tangle should work:
    → `Unit Test reference command tangle should work (59)`_

:Unit test LoadAction should call WebReader:
    → `Unit test LoadAction should call WebReader (77)`_

:Unit test TangleAction should call Tangler:
    → `Unit test TangleAction should call Tangler (75)`_

:Unit test WeaveAction should call Weaver:
    → `Unit test WeaveAction should call Weaver (73)`_

:Unit test code command methods should work:
    → `Unit test code command methods should work (45)`_

:Unit test code command tangle should error:
    → `Unit test code command tangle should error (46)`_

:Unit test file xref command methods should work:
    → `Unit test file xref command methods should work (49)`_

:Unit test file xref command tangle should error:
    → `Unit test file xref command tangle should error (50)`_

:Unit test macro xref command methods should work:
    → `Unit test macro xref command methods should work (52)`_

:Unit test macro xref command tangle shuould fail:
    → `Unit test macro xref command tangle shuould fail (53)`_

:Unit test named document chunk properties:
    → `Unit test named document chunk properties (33)`_

:Unit test named document chunk xref:
    → `Unit test named document chunk xref (32)`_

:Unit test of Action Sequence class:
    → `Unit test of Action Sequence class (70)`_

:Unit test of LoadAction class:
    → `Unit test of LoadAction class (76)`_

:Unit test of TangleAction class:
    → `Unit test of TangleAction class (74)`_

:Unit test of WeaverAction class:
    → `Unit test of WeaverAction class (72)`_

:Unit test of action sequence:
    → `Unit test of action sequence (71)`_

:Unit test of named chunk no-indent properties:
    → `Unit test of named chunk no-indent properties (27)`_

:Unit test of named chunk no-indent xref:
    → `Unit test of named chunk no-indent xref (26)`_

:Unit test of named chunk properties:
    → `Unit test of named chunk properties (24)`_

:Unit test of named chunk xref:
    → `Unit test of named chunk xref (23)`_

:Unit test of one-level transitive reference:
    → `Unit test of one-level transitive reference (37)`_

:Unit test of simple references:
    → `Unit test of simple references (35)`_

:Unit test of top-level transitive reference:
    → `Unit test of top-level transitive reference (38)`_

:Unit test of two-level transitive reference:
    → `Unit test of two-level transitive reference (36)`_

:Unit test text command methods should work:
    → `Unit test text command methods should work (42)`_

:Unit test text command tangle should error:
    → `Unit test text command tangle should error (43)`_

:Unit test userid xref command methods should work:
    → `Unit test userid xref command methods should work (55)`_

:Unit test userid xref command tangle should fail:
    → `Unit test userid xref command tangle should fail (56)`_

:Unit test web iteration over chunks:
    → `Unit test web iteration over chunks (62)`_

:Unit test web name resolution:
    → `Unit test web name resolution (61)`_

:Unit test web tangle when valid:
    → `Unit test web tangle when valid (63)`_

:Unit test web weave when valid:
    → `Unit test web weave when valid (64)`_

:Weave Test evaluation of expressions:
    → `Weave Test evaluation of expressions (105)`_

:Weave Test overheads: imports, etc.:
    → `Weave Test overheads: imports, etc. (107)`_

:Weave Test references and definitions:
    → `Weave Test references and definitions (101)`_

:expected RST output:
    → `expected RST output (6)`_

:expected html output:
    → `expected html output (11)`_

:expected tex minted output:
    → `expected tex minted output (9)`_

:expected tex output:
    → `expected tex output (8)`_




----------

..	container:: small

	Created by src/pyweb.py at Sat Oct 26 19:20:29 2024.

    Source pyweb_test.w modified Sun Oct 20 13:50:38 2024.

	pyweb.__version__ '3.3'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool'.
