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

@o tests/test_unit.py
@{@<Unit Test overheads: imports, etc.@>

@<Unit Test of Emitter class hierarchy@>
@<Unit Test of Chunk class hierarchy@>
@<Unit Test of Chunk References@>
@<Unit Test of Command class hierarchy@>
@<Unit Test of Web class@>
@<Unit Test of WebReader class@>
@<Unit Test of Action class hierarchy@>
@<Unit Test of Application class@>
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
@<Unit Test of LaTeX macros in Weaver@>
@<Unit Test of HTML macros in Weaver@>
@<Unit Test of Tangler subclass of Emitter@>
@<Unit Test of TanglerMake subclass of Emitter@>
@}

The Emitter superclass is designed to be extended.
The test creates a subclass to exercise a few key features.
The default emitter is Tangler-like.

@d Unit Test of Emitter Superclass... @{ 
@@pytest.fixture
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
@}

A mock ``Chunk`` object can be used to test ``Weaver`` subclasses.

Some tests will create multiple chunks.
To keep their state separate, we define a function to return each mocked ``Chunk`` instance as a new Mock object.

The ``write_closure()`` is a function that calls the ``Tangler.write()``  method.
This is *not* consistent with best unit testing practices.
It is merely a hold-over from an older testing strategy.
The mock call history to the ``tangle()`` method of each ``Chunk`` instance is a better test strategy.

@d Unit Test Mock Chunk...
@{
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
@}

The default ``Weaver`` is an ``Emitter`` that uses templates to produce RST markup.

@d Unit Test of Weaver... @{
def test_rst_quote_rules():
    assert pyweb.rst_quote_rules("|char| `code` *em* _em_") == "|char| `code` *em* _em_"

def test_html_quote_rules():
    assert pyweb.html_quote_rules("a & b < c > d") == r"a &amp; b &lt; c &gt; d"

@<expected RST output@>

@@pytest.fixture
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
@}

@d expected RST output @{
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
@}

A significant fraction of the various subclasses of weaver are expansion of various template macros.
Testing the template macros looks deeply at the intermediate product (RST or LaTeX), something that may be more easily tested by the final **docutils**, **Sphinx**, or a LaTeX processor.

Because of the complexity of LaTeX, we will examine a few features of these template macros.

@d Unit Test of LaTeX... @{

@<expected tex output@>
@<expected tex minted output@>

@@pytest.fixture
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

@@pytest.fixture
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
@}

@d expected tex output @{
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
@}

@d expected tex minted output @{
expected_tex_minted_output = [
    '\n'
    '\\label{pyweb-314}\n'
    '\\textit{Code example Chunk (314)}\n'
    '\\begin{minted}{python}',
    '\n'
    '\\end{minted}\n'
]
@}

We'll examine a few features of the HTML templates.

@d Unit Test of HTML... @{
@<expected html output @>

def test_weaver_functions_html(weaver_instance, mock_tiny_web):
    weaver_instance.set_markup("html")

    quote_result = pyweb.html_quote_rules("a < b && c > d")
    assert "a &lt; b &amp;&amp; c &gt; d" == quote_result

    weave_result = list(weaver_instance.generate_text(mock_tiny_web))
    assert expected_html_output == weave_result
@}

@d expected html output
@{
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
@}

A Tangler emits the various named source files in proper format for the desired
compiler and language.

@d Unit Test of Tangler subclass... 
@{
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
@}

A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference check.
If the file is different, the old version is replaced with  the new version.
If the file content is the same, the old version is left intact with all of the operating system creation timestamps untouched.

@d Unit Test of TanglerMake subclass... @{

@@pytest.fixture
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
@}

Chunk Tests
------------

The ``Chunk`` and ``Command`` class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.


@d Unit Test of Chunk class hierarchy... 
@{
@<Unit Test of Chunk superclass@>
@<Unit Test of NamedChunk subclass@>
@<Unit Test of NamedChunk with no indent@>
@<Unit Test of OutputChunk subclass@>
@<Unit Test of NamedDocumentChunk subclass@>
@}

In order to test the ``Chunk`` superclass, we need several mock objects.
A ``Chunk`` contains one or more ``Command`` instances.
A ``Chunk`` is a part of a ``Web``.
Also, a ``Chunk`` is processed by a ``Tangler`` or a ``Weaver``.
We'll need  mock objects for all of these relationships in which a ``Chunk`` participates.

We'll replace Commands (and Web) with ``Mock`` objects.

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

A ``MockWeb`` contains a ``Chunk``.

@d Unit Test of Chunk superclass...
@{

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
@}

A MockWeaver or MockTangler appear to process a ``Chunk``.
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

@}

A ``Chunk`` must be built, interrogated and then emitted.

@d Unit Test of Chunk superclass...
@{
@@pytest.fixture
def chunk_instance():
    return pyweb.Chunk()

@<Unit Test of Chunk construction@>
@<Unit Test of Chunk interrogation@>
@<Unit Test of Chunk properties@>
@}

Can we build a Chunk?

@d Unit Test of Chunk construction...
@{
def test_append_command_should_work(chunk_instance) -> None:
    cmd1 = MockCommand()
    chunk_instance.commands.append(cmd1)
    assert 1 == len(chunk_instance.commands)
    assert [cmd1] == chunk_instance.commands
    
    cmd2 = MockCommand()
    chunk_instance.commands.append(cmd2)
    assert 2 == len(chunk_instance.commands)
    assert [cmd1, cmd2] == chunk_instance.commands
@}

Can we interrogate a Chunk?

@d Unit Test of Chunk interrogation...
@{
def test_lineNumber_should_work(chunk_instance) -> None:
    cmd1 = MockCommand()
    chunk_instance.commands.append(cmd1)
    assert 314 == chunk_instance.commands[0].lineNumber
@}

Can we emit a Chunk with a weaver or tangler?

@d Unit Test of Chunk properties...
@{
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
@}

The ``NamedChunk`` is created by a ``@@d`` command.
Since it's named, it appears in the Web's index.
Also, it is woven and tangled differently than anonymous chunks.

@d Unit Test of NamedChunk subclass... @{
@@pytest.fixture
def namedchunk_instance():
    chunk = pyweb.NamedChunk(options=["Some Name..."])
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk

@<Unit test of named chunk xref@>
@<Unit test of named chunk properties@>
@}

@d Unit test of named chunk xref...
@{
def test_should_find_xref_words(namedchunk_instance) -> None:
    assert 2 == len(namedchunk_instance.def_names)
    assert {"index", "terms"} == set(namedchunk_instance.def_names)
@}

@d Unit test of named chunk properties...
@{
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
@}

@d Unit Test of NamedChunk with no indent...
@{
@@pytest.fixture
def namedchunk_noindent_instance():
    chunk = pyweb.NamedChunk(options=["-noindent", "NoIndent Name..."])
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk

@<Unit test of named chunk no-indent xref@>
@<Unit test of named chunk no-indent properties@>
@}

@d Unit test of named chunk no-indent xref @{
def test_should_find_xref_words(namedchunk_noindent_instance) -> None:
    assert 2 == len(namedchunk_noindent_instance.def_names)
    assert {"index", "terms"} == set(namedchunk_noindent_instance.def_names)
@}

@d Unit test of named chunk no-indent properties @{
def test_namedchunk_ni_properties(namedchunk_noindent_instance) -> None:
    web = mock_web()
    namedchunk_noindent_instance.web = Mock(return_value=web)
    namedchunk_noindent_instance.full_name
    web.resolve_name.assert_called_once_with(namedchunk_noindent_instance.name)
    assert namedchunk_noindent_instance.path is None
    assert namedchunk_noindent_instance.type_is("NamedChunk")
    assert not namedchunk_noindent_instance.type_is("Chunk")
    assert namedchunk_noindent_instance.referencedBy is None
@}


An ``OutputChunk`` is created by a ``@@o`` command.
Since it's named, it appears in the Web's index.
Also, it is woven and tangled differently than anonymous chunks of text.
This defines the files of tangled code. 

@d Unit Test of OutputChunk subclass... @{
@@pytest.fixture
def outputchunk_instance():
    chunk = pyweb.OutputChunk(options=["filename.out"])
    chunk.comment_start = "# "
    chunk.comment_end = ""
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk

@<Unit Test output chunk xref@>
@<Unit Test output chunk properties@>
@}


@d Unit Test output chunk xref...
@{
def test_should_find_xref_words(outputchunk_instance) -> None:
    assert 2 == len(outputchunk_instance.def_names)
    assert {"index", "terms"} == set(outputchunk_instance.def_names)
@}

@d Unit Test output chunk properties...
@{
def test_outputchunk_properties(outputchunk_instance) -> None:
    web = mock_web()
    outputchunk_instance.web = Mock(return_value=web)
    assert outputchunk_instance.full_name is None
    web.resolve_name.assert_not_called()
    assert outputchunk_instance.path == Path("filename.out")
    assert outputchunk_instance.type_is("OutputChunk")
    assert not outputchunk_instance.type_is("Chunk")
    assert outputchunk_instance.referencedBy is None
@}

The ``NamedDocumentChunk`` is a way to define substitutable text, similar to code, but it applies to document chunks.
It's not clear how useful this really is.

@d Unit Test of NamedDocumentChunk subclass... @{
@@pytest.fixture
def named_documentchunk_instance():
    chunk = pyweb.NamedDocumentChunk("Document Chunk Name...")
    cmd = MockCommand()
    chunk.commands.append(cmd)
    chunk.def_names = ["index", "terms"]
    return chunk

@<Unit test named document chunk xref@>
@<Unit test named document chunk properties@>
@}

@d Unit test named document chunk xref...
@{
def test_should_find_xref_words(named_documentchunk_instance) -> None:
    assert 2 == len(named_documentchunk_instance.def_names)
    assert {"index", "terms"} == set(named_documentchunk_instance.def_names)
@}

@d Unit test named document chunk properties...
@{
def test_nameddocument_chunk_properties(named_documentchunk_instance) -> None:
    web = mock_web()
    named_documentchunk_instance.web = Mock(return_value=web)
    named_documentchunk_instance.full_name
    web.resolve_name.assert_called_once_with(named_documentchunk_instance.name)
    assert named_documentchunk_instance.path is None
    assert named_documentchunk_instance.type_is("NamedDocumentChunk")
    assert not named_documentchunk_instance.type_is("OutputChunk")
    assert named_documentchunk_instance.referencedBy is None
@}

Chunk References Tests
----------------------

A ``Chunk``\ 's "referencedBy" attribute is set by the ``Web`` during the initialization processing.

The test fixture is this

..  parsed-literal::

    @@d main @@{ @@< parent @@> @@}
    
    @@d parent @@{ @@< sub @@> @@}
    
    @@d sub @@{ something @@}
    
The ``sub`` item is referenced by ``parent`` which is referenced by ``main``.

There are two broad styles of references:

- The simple reference is ``sub`` referenced by ``parent``.

- The transitive references are ``sub`` referenced by ``parent`` which is referenced by ``main``.

@d Unit Test of Chunk References... @{ 
@@pytest.fixture
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

@<Unit test of simple references@>
@<Unit test of two-level transitive reference@>
@<Unit test of one-level transitive reference@>
@<Unit test of top-level transitive reference@>
@}

@d Unit test of simple references...
@{
def test_simple(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    assert chunk.referencedBy == parent
@}

@d Unit test of two-level transitive reference...
@{
def test_transitive_sub_sub(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = chunk.transitive_referencedBy
    assert 2 == len(theList)
    assert parent == theList[0]
    assert main == theList[1]
@}

@d Unit test of one-level transitive reference...
@{
def test_transitive_sub(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = parent.transitive_referencedBy
    assert 1 == len(theList)
    assert main == theList[0]
@}

@d Unit test of top-level transitive reference...
@{
def test_transitive_top(main_parent_sub_chunks) -> None:
    main, parent, chunk = main_parent_sub_chunks
    theList = main.transitive_referencedBy
    assert 0 == len(theList)
@}

Command Tests
---------------

A ``Chunk`` is a sequence of individual ``Command`` instances.
The invidual commands include all of the ``@@x`` commands,
plus the remaining blocks of text (or code.)

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

This Command superclass is essentially an inteface definition; it has no real testable features.

@d Unit Test of Command superclass... @{# No Tests@}

A ``TextCommand`` object must be built from source text, interrogated, and emitted.
A ``TextCommand`` should not (generally) be created in a ``Chunk``, it should
only be part of a ``NamedChunk`` or ``OutputChunk``.

@d Unit Test of TextCommand class... @{ 
@@pytest.fixture
def text_command_instances():
    cmd = pyweb.TextCommand("Some text & words in the document\n    ", ("sample.w", 314))
    cmd2 = pyweb.TextCommand("No Indent\n", ("sample.w", 271))
    return cmd, cmd2

@<Unit test text command methods should work@>
@<Unit test text command tangle should error@>
@}

@d Unit test text command methods...
@{
def test_textcommand_methods(text_command_instances) -> None:
    cmd, cmd2 = text_command_instances
    assert cmd.typeid.TextCommand
    assert ("sample.w", 314) == cmd.location
@}

@d Unit test text command tangle...
@{
def test_textcommamnd_tangle_should_error(text_command_instances) -> None:
    cmd, cmd2 = text_command_instances
    tangler = MockTangler()
    with pytest.raises(pyweb.Error) as exc_info:
        cmd.tangle(tangler, sentinel.TARGET)
    assert exc_info.value.args == (
        "attempt to tangle a text block ('sample.w', 314) 'Some text & words in the [...]'",
    )
@}

A ``CodeCommand`` object is a ``TextCommand`` with different processing when it is emitted.
It represents a block of code in a ``NamedChunk`` or ``OutputChunk``. 

@d Unit Test of CodeCommand class... @{
@@pytest.fixture
def code_command_instance():
    cmd = pyweb.CodeCommand("Some code in the document\n    ", ("sample.w", 314))
    return cmd

@<Unit test code command methods should work@>
@<Unit test code command tangle should error@>
@}

@d Unit test code command methods...
@{
def test_codecommand_methods(code_command_instance) -> None:
    assert code_command_instance.typeid.CodeCommand
    assert ("sample.w", 314)== code_command_instance.location
@}

@d Unit test code command tangle...
@{
def test_codecommand_tangle_should_work(code_command_instance) -> None:
    tangler = MockTangler()
    code_command_instance.tangle(tangler, sentinel.TARGET)
    tangler.codeBlock.assert_called_once_with(sentinel.TARGET, 'Some code in the document\n    ')
@}

An ``XrefCommand`` class (if defined) would be abstract.
We could formalize this, but it seems easier to have a collection of ``@@dataclass`` definitions with a  ``Union[...]`` type hint.


@d Unit Test of XrefCommand superclass... @{# No Tests @}

The ``FileXrefCommand`` command is expanded by a weaver to a list of ``@@o`` locations.

@d Unit Test of FileXrefCommand class... @{ 
@@pytest.fixture
def filexref_command_instance():
    web = Mock(files=sentinel.FILES)
    cmd = pyweb.FileXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd

@<Unit test file xref command methods should work@>
@<Unit test file xref command tangle should error@>
@}

@d Unit test file xref command methods...
@{
def test_filexrefcommand_methods(filexref_command_instance) -> None:
    assert filexref_command_instance.typeid.FileXrefCommand
    assert ("sample.w", 314) == filexref_command_instance.location
    assert sentinel.FILES == filexref_command_instance.files
@}

@d Unit test file xref command tangle...
@{
def test_filexrefcommand_tangle_should_fail(filexref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        filexref_command_instance.tangle(tangler, sentinel.TARGET)
@}

The ``MacroXrefCommand`` command is expanded by a weaver to a list of all ``@@d`` locations.

@d Unit Test of MacroXrefCommand class... @{
@@pytest.fixture
def macroxref_command_instance():
    web = Mock(macros=sentinel.MACROS)
    cmd = pyweb.MacroXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd

@<Unit test macro xref command methods should work@>
@<Unit test macro xref command tangle shuould fail@>
@}

@d Unit test macro xref command methods...
@{
def test_macroxrefcommand_methods(macroxref_command_instance) -> None:
    assert macroxref_command_instance.typeid.MacroXrefCommand
    assert ("sample.w", 314) == macroxref_command_instance.location
    assert sentinel.MACROS == macroxref_command_instance.macros
@}

@d Unit test macro xref command tangle...
@{
def test_macroxrefcommand_tangle_should_fail(macroxref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        macroxref_command_instance.tangle(tangler, sentinel.TARGET)
@}

The ``UserIdXrefCommand`` command is expanded by a weaver to a list of all ``@@|`` names.

@d Unit Test of UserIdXrefCommand class... @{
@@pytest.fixture
def useridxref_command_instance():
    web = Mock(userids=sentinel.USERIDS)
    cmd = pyweb.UserIdXrefCommand(("sample.w", 314))
    cmd.web = Mock(return_value=web)
    return cmd

@<Unit test userid xref command methods should work@>
@<Unit test userid xref command tangle should fail@>
@}

@d Unit test userid xref command methods...
@{
def test_useridxref_command_methods(useridxref_command_instance) -> None:
    assert useridxref_command_instance.typeid.UserIdXrefCommand
    assert ("sample.w", 314) == useridxref_command_instance.location
    assert sentinel.USERIDS == useridxref_command_instance.userids
@}

@d Unit test userid xref command tangle...
@{
def test_useridxref_command_tangle_should_fail(useridxref_command_instance) -> None:
    tangler = MockTangler()
    with pytest.raises(pyweb.Error):
        useridxref_command_instance.tangle(tangler, sentinel.TARGET)
@}

Instances of the ``Reference`` command reflect ``@@< name @@>`` locations in code.
These require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled, since the expand to code that may (transitively) have more references to more code.

The document here is a mock-up of the following

..  parsed-literal::

    @@d name @@{ @@<Some Name@@> @@}
    
    @@d Some Name @@{ code @@}
    
This is a single ``Chunk`` with a reference to another ``Chunk``.

The ``Web`` class ``__post_init__`` sets the ``references`` and ``referencedBy`` attributes of each ``Chunk``.

@d Unit Test of ReferenceCommand class... @{
@<Unit Test reference command methods should work@>
@<Unit Test reference command tangle should work@>

@@pytest.fixture
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
@}

@d Unit Test reference command methods...
@{
def test_reference_command_methods(reference_command_instance) -> None:
    assert reference_command_instance.typeid.ReferenceCommand
    assert ("sample.w", 314) == reference_command_instance.location
    assert sentinel.FULL_NAME == reference_command_instance.full_name
    assert sentinel.SEQUENCE == reference_command_instance.seq
@}

@d Unit Test reference command tangle...
@{
def test_reference_command_tangle_should_work(reference_command_instance) -> None:
    tangler = MockTangler()
    reference_command_instance.tangle(tangler, sentinel.TARGET)
    web = reference_command_instance.web()
    web.resolve_chunk.assert_called_once_with("Some Name")
    tangler.reference_names.add.assert_called_once_with('Some Name')
    referenced_chunk = web.resolve_chunk("Some Name")[0]
    referenced_chunk.commands[0].tangle.assert_called_once_with(tangler, sentinel.TARGET)
@}


Web Tests
-----------

We create a ``Web`` instance with mocked ``Chunks`` and mocked ``Commands``.
The point is to test the ``Web`` features in isolation.
This is tricky because some state is recorded in the ``Chunk`` instances.

@d Unit Test of Web class... 
@{
@@pytest.fixture
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

@<Unit test web name resolution@>
@<Unit test web iteration over chunks@>
@<Unit test web tangle when valid@>
@<Unit test web weave when valid@>
@}

@d Unit test web name resolution...
@{
def test_web_name_resolution(web_instance) -> None:
    assert web_instance.resolve_name("c1") == "c1"
    assert web_instance.resolve_chunk("c2") == [web_instance.chunks[1]]
    assert web_instance.resolve_name("c1...") == "c1"
    assert web_instance.resolve_name("c3...") == "c3 has a long name"
@}

@d Unit test web iteration over chunks...
@{
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
@}

This exercises the entire interface used by tangling.
All details are pushed down to ```command.tangle()`` methods for each command in each chunk.

@d Unit test web tangle...
@{
def test_valid_web_should_tangle(web_instance) -> None:
    web = web_instance
    c1, c2, c3 = web_instance.chunks
    assert [c2], web.files
@}

This the entire interface used by weaving is the ``web.chunks`` attribute, which is implicitly tested in several places.
All chunk-specific details are pushed down to unique processing based on ``chunk.type_is``.

@d Unit test web weave... @{# No tests@}


WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

The ``WebReader`` is poorly designed for unit testing. 
The various chunk and command classes are part of the ``WebReader``, and 
new classes cannot be injected gracefully.

Exacerbating this are two special cases: the ``@@@@`` and ``@@(expr@@)`` constructs
are evaluated immediately, and don't create commands.

@d Unit Test of WebReader... @{
# Tested via functional tests
@}

Some lower-level units: specifically the tokenizer and the option parser.

@d Unit Test of WebReader... @{
@@pytest.fixture
def tokenizer():
    input = io.StringIO("@@@@ word @@{ @@[ @@< @@>\n@@] @@} @@i @@| @@m @@f @@u @@( @@)\n")
    tokenizer = pyweb.Tokenizer(input)
    return tokenizer

def test_should_split_tokens(tokenizer) -> None:
    tokens = list(tokenizer)
    assert len(tokens) == 28
    assert tokens == ['@@@@', ' word ', '@@{', ' ', '@@[', ' ', '@@<', ' ',
    '@@>', '\n', '@@]', ' ', '@@}', ' ', '@@i', ' ', '@@|', ' ', '@@m', ' ',
    '@@f', ' ', '@@u', ' ', '@@(', ' ', '@@)', '\n']
    assert tokenizer.lineNumber == 2
@}

@d Unit Test of WebReader... @{
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
@}

Testing the ``@@@@`` case and one of the ``@@(expr@@)`` cases.
Need to test all the available variables: ``os.path``, ``os.getcwd``, ``os.name``, ``time``, ``datetime``, ``platform``, 
``theWebReader``, ``theFile``, ``thisApplication``, ``version``, ``theLocation``.

Note the escape processing has a lot of ``@@`` characters in it.

@d Unit Test of WebReader... @{
ex1 = ("Escape: @@@@ Example", "Escape: @@ Example")
ex2 = ("Filename: @@(theFile@@)", "Filename: sample.w")

@@pytest.fixture(params=(ex1, ex2))
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
@}

Action Tests
-------------

Each ``Action`` class is tested separately.
This requires a aequence of some mocks.
The behaviors include loading, tangling, weaving.

@d Unit Test of Action class hierarchy... @{ 
@<Unit test of Action Sequence class@>
@<Unit test of LoadAction class@>
@<Unit test of TangleAction class@>
@<Unit test of WeaverAction class@>
@}

**TODO:** Replace with Mock

@d Unit test of Action Sequence class... @{
@@pytest.fixture
def action_sequence_instance():
    a1 = MagicMock(name="Action1")
    a2 = MagicMock(name="Action2")
    action = pyweb.ActionSequence("TwoSteps", [a1, a2])
    action.web = mock_web()
    return action

@<Unit test of action sequence...@>
@}

@d Unit test of action sequence
@{
def test_action_sequence_execute_both(action_sequence_instance) -> None:
    action_sequence_instance(sentinel.OPTIONS)
    action_sequence_instance.opSequence[0].assert_called_once_with(sentinel.OPTIONS)
    action_sequence_instance.opSequence[1].assert_called_once_with(sentinel.OPTIONS)
@}

@d Unit test of WeaverAction class... @{ 
@@pytest.fixture
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

@<Unit test WeaveAction should call Weaver@>
@}

@d Unit test WeaveAction should call...
@{
def test_weave_action(action_weave_instance) -> None:
    action, options = action_weave_instance
    action(options)
    options.theWeaver.emit.assert_called_once_with(options.web)
@}

@d Unit test of TangleAction class... @{
@@pytest.fixture
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

@<Unit test TangleAction should call Tangler@>
@}

@d Unit test TangleAction...
@{
def test_tangle_action(action_tangle_instance) -> None:
    action, options = action_tangle_instance
    action(options)
    options.theTangler.emit.assert_called_once_with(options.web)
@}

The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.

@d Unit test of LoadAction class... @{ 
@@pytest.fixture
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
        command="@@",
        permitList=[],
        output=tmp_path,
    )
    return action, options

@<Unit test LoadAction should call WebReader@>
@}

@d Unit test LoadAction should...
@{
def test_loader_action(action_loader_instance) -> None:
    action, options = action_loader_instance
    action(options)
    options.webReader.load.assert_called_once_with(options.source_path)
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
@}

One more overhead is a function to cleanup output files.

@d Unit Test overheads...
@{
def rstrip_lines(source: str) -> list[str]:
    return list(l.rstrip() for l in source.splitlines())    
@}

