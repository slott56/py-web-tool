<!-- test/func.w -->

<p>There are several broad areas of unit testing.  There are the 34 classes in this application.
However, it isn't really necessary to test everyone single one of these classes.
We'll decompose these into several hierarchies.
</p>

<ul type="circle">
    <li>Emitters
    <ul>
	    <li>class Emitter( object ):  </li>
        <li>class Weaver( Emitter ):  </li>
        <li>class LaTeX( Weaver ):  </li>
        <li>class HTML( Weaver ):  </li>
        <li>class HTMLShort( HTML ):  </li>
        <li>class Tangler( Emitter ):  </li>
        <li>class TanglerMake( Tangler ):  </li>
    </ul>
    </li>
    <li>Structure: Chunk, Command
    <ul>
        <li>class Chunk( object ):  </li>
        <li>class NamedChunk( Chunk ):  </li>
        <li>class OutputChunk( NamedChunk ):  </li>
        <li>class NamedDocumentChunk( NamedChunk ):  </li>
        <li>class MyNewCommand( Command ):  </li>
        <li>class Command( object ):  </li>
        <li>class TextCommand( Command ):  </li>
        <li>class CodeCommand( TextCommand ):  </li>
        <li>class XrefCommand( Command ):  </li>
        <li>class FileXrefCommand( XrefCommand ):  </li>
        <li>class MacroXrefCommand( XrefCommand ):  </li>
        <li>class UserIdXrefCommand( XrefCommand ):  </li>
        <li>class ReferenceCommand( Command ):  </li>
	</ul>
	</li>
	<li>class Error( Exception ): pass  </li>
	<li>Reference Handling
	<ul>
        <li>class Reference( object ):  </li>
        <li>class SimpleReference( Reference ):  </li>
        <li>class TransitiveReference( Reference ):  </li>
    </ul>
	</li>
	<li>class Web( object ):  </li>
	<li>class WebReader( object ):  </li>
	<li>Action
	<ul>
        <li>class Action( object ):  </li>
        <li>class ActionSequence( Action ):  </li>
        <li>class WeaveAction( Action ):  </li>
        <li>class TangleAction( Action ):  </li>
        <li>class LoadAction( Action ):  </li>
    </ul>
    </li>
	<li>class Application( object ):  </li>
	<li>class MyWeaver( HTML ):  </li>
	<li>class MyHTML( pyweb.HTML ):</li>
</ul>

<p>This gives us the following outline for unit testing.</p>

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

<h3>Emitter Tests</h3>

<p>The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.
</p>

@d Unit Test of Emitter class hierarchy... @{
@<Unit Test Mock Chunk class@>
@<Unit Test of Emitter Superclass@>
@<Unit Test of Weaver subclass of Emitter@>
@<Unit Test of LaTeX subclass of Emitter@>
@<Unit Test of HTML subclass of Emitter@>
@<Unit Test of HTMLShort subclass of Emitter@>
@<Unit Test of Tangler subclass of Emitter@>
@<Unit Test of TanglerMake subclass of Emitter@>
@}

<p>The Emitter superclass is designed to be extended.  The test 
creates a subclass to exercise a few key features.</p>

@d Unit Test of Emitter Superclass... @{ 
class EmitterExtension( pyweb.Emitter ):
    def doOpen( self, fileName ):
        self.file= StringIO.StringIO()
    def doClose( self ):
        self.file.flush()
    def doWrite( self, text ):
        self.file.write( text )
        
class TestEmitter( unittest.TestCase ):
    def setUp( self ):
        self.emitter= EmitterExtension()
    def test_emitter_should_open_close_write( self ):
        self.emitter.open( "test.tmp" )
        self.emitter.write( "Something" )
        self.emitter.close()
        self.assertEquals( "Something", self.emitter.file.getvalue() )
    def test_emitter_should_codeBlock( self ):
        self.emitter.open( "test.tmp" )
        self.emitter.codeBlock( "Some Code" )
        self.emitter.close()
        self.assertEquals( "Some Code\n", self.emitter.file.getvalue() )
    def test_emitter_should_indent( self ):
        self.emitter.open( "test.tmp" )
        self.emitter.codeBlock( "Begin\n" )
        self.emitter.setIndent( 4 )
        self.emitter.codeBlock( "More Code\n" )
        self.emitter.clrIndent()
        self.emitter.codeBlock( "End" )
        self.emitter.close()
        self.assertEquals( "Begin\n    More Code\nEnd\n", self.emitter.file.getvalue() )
@}

<p>A Mock Chunk is a Chunk-like object that we can use to test Weavers.</p>

@d Unit Test Mock Chunk...
@{
class MockChunk( object ):
    def __init__( self, name, seq, lineNumber ):
        self.name= name
        self.fullName= name
        self.seq= seq
        self.lineNumber= lineNumber
        self.initial= True
        self.commands= []
        self.referencedBy= []
@}

<p>The default Weaver is an Emitter that uses templates to produce RST markup.</p>

@d Unit Test of Weaver... @{
class TestWeaver( unittest.TestCase ):
    def setUp( self ):
        self.weaver= pyweb.Weaver()
        self.filename= "testweaver.w" 
        self.aFileChunk= MockChunk( "File", 123, 456 )
        self.aFileChunk.references_list= [ ]
        self.aChunk= MockChunk( "Chunk", 314, 278 )
        self.aChunk.references_list= [ ("Container", 123) ]
    def tearDown( self ):
        import os
        try:
            os.remove( "testweaver.rst" )
        except OSError:
            pass
        
    def test_weaver_functions( self ):
        result= self.weaver.quote( "|char| `code` *em* _em_" )
        self.assertEquals( "\|char\| \`code\` \*em\* \_em\_", result )
        result= self.weaver.references( self.aChunk )
        self.assertEquals( "\nUsed by: Container (`123`_)\n", result )
        result= self.weaver.referenceTo( "Chunk", 314 )
        self.assertEquals( "|srarr| Chunk (`314`_)", result )
  
    def test_weaver_should_codeBegin( self ):
        self.weaver.open( self.filename )
        self.weaver.codeBegin( self.aChunk )
        self.weaver.codeBlock( self.weaver.quote( "*The* `Code`\n" ) )
        self.weaver.codeEnd( self.aChunk )
        self.weaver.close()
        with open( "testweaver.rst", "r" ) as result:
            txt= result.read()
        self.assertEquals( "\n..  _`314`:\n..  rubric:: Chunk (314)\n..  parsed-literal::\n    \\*The\\* \\`Code\\`\n\n\nUsed by: Container (`123`_)\n\n", txt )
  
    def test_weaver_should_fileBegin( self ):
        self.weaver.open( self.filename )
        self.weaver.fileBegin( self.aFileChunk )
        self.weaver.codeBlock( self.weaver.quote( "*The* `Code`\n" ) )
        self.weaver.fileEnd( self.aFileChunk )
        self.weaver.close()
        with open( "testweaver.rst", "r" ) as result:
            txt= result.read()
        self.assertEquals( "\n..  _`123`:\n..  rubric:: File (123)\n..  parsed-literal::\n    \\*The\\* \\`Code\\`\n\n\n", txt )

    def test_weaver_should_xref( self ):
        self.weaver.open( self.filename )
        self.weaver.xrefHead( )
        self.weaver.xrefLine( "Chunk", [ ("Container", 123) ] )
        self.weaver.xrefFoot( )
        self.weaver.fileEnd( self.aFileChunk )
        self.weaver.close()
        with open( "testweaver.rst", "r" ) as result:
            txt= result.read()
        self.assertEquals( "\n:Chunk:\n    |srarr| (`('Container', 123)`_)\n\n\n\n", txt )

    def test_weaver_should_xref_def( self ):
        self.weaver.open( self.filename )
        self.weaver.xrefHead( )
        self.weaver.xrefDefLine( "Chunk", 314, [ ("Container", 123), ("Chunk", 314) ] )
        self.weaver.xrefFoot( )
        self.weaver.fileEnd( self.aFileChunk )
        self.weaver.close()
        with open( "testweaver.rst", "r" ) as result:
            txt= result.read()
        self.assertEquals( "\n:Chunk:\n    [`314`_] `('Chunk', 314)`_ `('Container', 123)`_\n\n\n\n", txt )
@}

<p>A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.
</p>

<p>We'll examine a few features of the LaTeX templates.</p>

@d Unit Test of LaTeX... @{ 
class TestLaTeX( unittest.TestCase ):
    def setUp( self ):
        self.weaver= pyweb.LaTeX()
        self.filename= "testweaver.w" 
        self.aFileChunk= MockChunk( "File", 123, 456 )
        self.aFileChunk.references_list= [ ]
        self.aChunk= MockChunk( "Chunk", 314, 278 )
        self.aChunk.references_list= [ ("Container", 123) ]
    def tearDown( self ):
        import os
        try:
            os.remove( "testweaver.tex" )
        except OSError:
            pass
            
    def test_weaver_functions( self ):
        result= self.weaver.quote( "\\end{Verbatim}" )
        self.assertEquals( "\\end\\,{Verbatim}", result )
        result= self.weaver.references( self.aChunk )
        self.assertEquals( "\n    \\footnotesize\n    Used by:\n    \\begin{list}{}{}\n    \n    \\item Code example Container (123) (Sect. \\ref{pyweb123}, p. \\pageref{pyweb123})\n\n    \\end{list}\n    \\normalsize\n", result )
        result= self.weaver.referenceTo( "Chunk", 314 )
        self.assertEquals( "$\\triangleright$ Code Example Chunk (314)", result )
@}

<p>We'll examine a few features of the HTML templates.</p>

@d Unit Test of HTML subclass... @{ 
class TestHTML( unittest.TestCase ):
    def setUp( self ):
        self.weaver= pyweb.HTML()
        self.filename= "testweaver.w" 
        self.aFileChunk= MockChunk( "File", 123, 456 )
        self.aFileChunk.references_list= [ ]
        self.aChunk= MockChunk( "Chunk", 314, 278 )
        self.aChunk.references_list= [ ("Container", 123) ]
    def tearDown( self ):
        import os
        try:
            os.remove( "testweaver.html" )
        except OSError:
            pass
            
    def test_weaver_functions( self ):
        result= self.weaver.quote( "a < b && c > d" )
        self.assertEquals( "a &lt; b &amp;&amp; c &gt; d", result )
        result= self.weaver.references( self.aChunk )
        self.assertEquals( '  Used by <a href="#pyweb123"><em>Container</em>&nbsp;(123)</a>.', result )
        result= self.weaver.referenceTo( "Chunk", 314 )
        self.assertEquals( '<a href="#pyweb314">&rarr;<em>Chunk</em> (314)</a>', result )

@}

<p>The unique feature of the <span class="code">HTMLShort</span> class is just a template change.
</p>

<p><b>To Do:</b> Test this.</p>

@d Unit Test of HTMLShort subclass... @{ @}

<p>A Tangler emits the various named source files in proper format for the desired
compiler and language.</p>

@d Unit Test of Tangler subclass... 
@{ 
class TestTangler( unittest.TestCase ):
    def setUp( self ):
        self.tangler= pyweb.Tangler()
        self.filename= "testtangler.w" 
        self.aFileChunk= MockChunk( "File", 123, 456 )
        self.aFileChunk.references_list= [ ]
        self.aChunk= MockChunk( "Chunk", 314, 278 )
        self.aChunk.references_list= [ ("Container", 123) ]
    def tearDown( self ):
        import os
        try:
            os.remove( "testtangler.w" )
        except OSError:
            pass
        
    def test_tangler_functions( self ):
        result= self.tangler.quote( string.printable )
        self.assertEquals( string.printable, result )
    def test_tangler_should_codeBegin( self ):
        self.tangler.open( self.filename )
        self.tangler.codeBegin( self.aChunk )
        self.tangler.codeBlock( self.tangler.quote( "*The* `Code`\n" ) )
        self.tangler.codeEnd( self.aChunk )
        self.tangler.close()
        with open( "testtangler.w", "r" ) as result:
            txt= result.read()
        self.assertEquals( "*The* `Code`\n", txt )
@}

<p>A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.
</p>

<p>In order to be sure that the timestamps really have changed, we 
need to wait for a full second to elapse.
</p>


@d Unit Test of TanglerMake subclass... @{
class TestTanglerMake( unittest.TestCase ):
    def setUp( self ):
        self.tangler= pyweb.TanglerMake()
        self.filename= "testtangler.w" 
        self.aChunk= MockChunk( "Chunk", 314, 278 )
        self.aChunk.references_list= [ ("Container", 123) ]
        self.tangler.open( self.filename )
        self.tangler.codeBegin( self.aChunk )
        self.tangler.codeBlock( self.tangler.quote( "*The* `Code`\n" ) )
        self.tangler.codeEnd( self.aChunk )
        self.tangler.close()
        self.original= os.path.getmtime( self.filename )
        time.sleep( 1.0 ) # Attempt to assure timestamps are different
    def tearDown( self ):
        import os
        try:
            os.remove( "testtangler.w" )
        except OSError:
            pass
        
    def test_same_should_leave( self ):
        self.tangler.open( self.filename )
        self.tangler.codeBegin( self.aChunk )
        self.tangler.codeBlock( self.tangler.quote( "*The* `Code`\n" ) )
        self.tangler.codeEnd( self.aChunk )
        self.tangler.close()
        self.assertEquals( self.original, os.path.getmtime( self.filename ) )
        
    def test_different_should_update( self ):
        self.tangler.open( self.filename )
        self.tangler.codeBegin( self.aChunk )
        self.tangler.codeBlock( self.tangler.quote( "*Completely Different* `Code`\n" ) )
        self.tangler.codeEnd( self.aChunk )
        self.tangler.close()
        self.assertNotEquals( self.original, os.path.getmtime( self.filename ) )
@}

<h3>Chunk Tests</h3>

<p>The Chunk and Command class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.
</p>

@d Unit Test of Chunk class hierarchy... 
@{
@<Unit Test of Chunk superclass@>
@<Unit Test of NamedChunk subclass@>
@<Unit Test of OutputChunk subclass@>
@<Unit Test of NamedDocumentChunk subclass@>
@}

<p>In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
Mock objects for all of these relationships in which a Chunk participates.
</p>

<p>A MockCommand can be attached to a Chunk.<p>

@d Unit Test of Chunk superclass...
@{
class MockCommand( object ):
    def __init__( self ):
        self.lineNumber= 314
    def startswith( self, text ):
        return False
@}

<p>A MockWeb can contain a Chunk.<p>

@d Unit Test of Chunk superclass...
@{
class MockWeb( object ):
    def __init__( self ):
        self.chunks= []
        self.wove= None
        self.tangled= None
    def add( self, aChunk ):
        self.chunks.append( aChunk )
    def addNamed( self, aChunk ):
        self.chunks.append( aChunk )
    def addOutput( self, aChunk ):
        self.chunks.append( aChunk )
    def fullNameFor( self, name ):
        return name
    def fileXref( self ):
        return { 'file':[1,2,3] }
    def chunkXref( self ):
        return { 'chunk':[4,5,6] }
    def userNamesXref( self ):
        return { 'name':(7,[8,9,10]) }
    def getchunk( self, name ):
        return [ MockChunk( name, 1, 314 ) ]
    def createUsedBy( self ):
        pass
    def weaveChunk( self, name, weaver ):
        weaver.write( name )
    def tangleChunk( self, name, tangler ):
        tangler.write( name )
    def weave( self, weaver ):
        self.wove= weaver
    def tangle( self, tangler ):
        self.tangled= tangler
@}

<p>A MockWeaver or MockTangle can process a Chunk.<p>

@d Unit Test of Chunk superclass...
@{
class MockWeaver( object ):
    def __init__( self ):
        self.begin_chunk= []
        self.end_chunk= []
        self.written= []
        self.code_indent= None
    def quote( self, text ):
        return text.replace( "&", "&amp;" ) # token quoting
    def docBegin( self, aChunk ):
        self.begin_chunk.append( aChunk )
    def write( self, text ):
        self.written.append( text )
    def docEnd( self, aChunk ):
        self.end_chunk.append( aChunk )
    def codeBegin( self, aChunk ):
        self.begin_chunk.append( aChunk )
    def codeBlock( self, text ):
        self.written.append( text )
    def codeEnd( self, aChunk ):
        self.end_chunk.append( aChunk )
    def fileBegin( self, aChunk ):
        self.begin_chunk.append( aChunk )
    def fileEnd( self, aChunk ):
        self.end_chunk.append( aChunk )
    def setIndent( self, fixed=None, command=None ):
        pass
    def clrIndent( self ):
        pass
    def xrefHead( self ):
        pass
    def xrefLine( self, name, refList ):
        self.written.append( "%s %s" % ( name, refList ) )
    def xrefDefLine( self, name, defn, refList ):
        self.written.append( "%s %s %s" % ( name, defn, refList ) )
    def xrefFoot( self ):
        pass
    def open( self, aFile ):
        pass
    def close( self ):
        pass
    def referenceTo( self, name, seq ):
        pass

class MockTangler( MockWeaver ):
    def __init__( self ):
        super( MockTangler, self ).__init__()
        self.context= [0]
@}

<p>A Chunk is built, interrogated and then emitted.</p>

@d Unit Test of Chunk superclass...
@{
class TestChunk( unittest.TestCase ):
    def setUp( self ):
        self.theChunk= pyweb.Chunk()
    @<Unit Test of Chunk construction@>
    @<Unit Test of Chunk interrogation@>
    @<Unit Test of Chunk emission@>
@}

<p>Can we build a Chunk?</p>

@d Unit Test of Chunk construction...
@{
def test_append_command_should_work( self ):
    cmd1= MockCommand()
    self.theChunk.append( cmd1 )
    self.assertEquals( 1, len(self.theChunk.commands ) )
    cmd2= MockCommand()
    self.theChunk.append( cmd2 )
    self.assertEquals( 2, len(self.theChunk.commands ) )
    
def test_append_initial_and_more_text_should_work( self ):
    self.theChunk.appendText( "hi mom" )
    self.assertEquals( 1, len(self.theChunk.commands ) )
    self.theChunk.appendText( "&more text" )
    self.assertEquals( 1, len(self.theChunk.commands ) )
    self.assertEquals( "hi mom&more text", self.theChunk.commands[0].text )
    
def test_append_following_text_should_work( self ):
    cmd1= MockCommand()
    self.theChunk.append( cmd1 )
    self.theChunk.appendText( "hi mom" )
    self.assertEquals( 2, len(self.theChunk.commands ) )
    
def test_append_to_web_should_work( self ):
    web= MockWeb()
    self.theChunk.webAdd( web )
    self.assertEquals( 1, len(web.chunks) )
@}

<p>Can we interrogate a Chunk?</p>

@d Unit Test of Chunk interrogation...
@{
def test_leading_command_should_not_find( self ):
    self.assertFalse( self.theChunk.startswith( "hi mom" ) )
    cmd1= MockCommand()
    self.theChunk.append( cmd1 )
    self.assertFalse( self.theChunk.startswith( "hi mom" ) )
    self.theChunk.appendText( "hi mom" )
    self.assertEquals( 2, len(self.theChunk.commands ) )
    self.assertFalse( self.theChunk.startswith( "hi mom" ) )
    
def test_leading_text_should_not_find( self ):
    self.assertFalse( self.theChunk.startswith( "hi mom" ) )
    self.theChunk.appendText( "hi mom" )
    self.assertTrue( self.theChunk.startswith( "hi mom" ) )
    cmd1= MockCommand()
    self.theChunk.append( cmd1 )
    self.assertTrue( self.theChunk.startswith( "hi mom" ) )
    self.assertEquals( 2, len(self.theChunk.commands ) )

def test_regexp_exists_should_find( self ):
    self.theChunk.appendText( "this chunk has many words" )
    pat= re.compile( r"\Wchunk\W" )
    found= self.theChunk.searchForRE(pat)
    self.assertTrue( found is self.theChunk )
def test_regexp_missing_should_not_find( self ):
    self.theChunk.appendText( "this chunk has many words" )
    pat= re.compile( "\Warpigs\W" )
    found= self.theChunk.searchForRE(pat)
    self.assertTrue( found is None )
    
def test_lineNumber_should_work( self ):
    self.assertTrue( self.theChunk.lineNumber is None )
    cmd1= MockCommand()
    self.theChunk.append( cmd1 )
    self.assertEqual( 314, self.theChunk.lineNumber )
@}

<p>Can we emit a Chunk with a weaver or tangler?</p>

@d Unit Test of Chunk emission...
@{
def test_weave_should_work( self ):
    wvr = MockWeaver()
    web = MockWeb()
    self.theChunk.appendText( "this chunk has very & many words" )
    self.theChunk.weave( web, wvr )
    self.assertEquals( 1, len(wvr.begin_chunk) )
    self.assertTrue( wvr.begin_chunk[0] is self.theChunk )
    self.assertEquals( 1, len(wvr.end_chunk) )
    self.assertTrue( wvr.end_chunk[0] is self.theChunk )
    self.assertEquals(  "this chunk has very & many words", "".join( wvr.written ) )
    
def test_tangle_should_fail( self ):
    tnglr = MockTangler()
    web = MockWeb()
    self.theChunk.appendText( "this chunk has very & many words" )
    try:
        self.theChunk.tangle( web, tnglr )
        self.fail()
    except pyweb.Error, e:
        self.assertEquals( "Cannot tangle an anonymous chunk", e.args[0] )
@}

<p>The NamedChunk is created by a <tt>@@d</tt> command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.
</p>

@d Unit Test of NamedChunk subclass... @{ 
class TestNamedChunk( unittest.TestCase ):
    def setUp( self ):
        self.theChunk= pyweb.NamedChunk( "Some Name..." )
        cmd= self.theChunk.makeContent( "the words & text of this Chunk" )
        self.theChunk.append( cmd )
        self.theChunk.setUserIDRefs( "index terms" )
        
    def test_should_find_xref_words( self ):
        self.assertEquals( 2, len(self.theChunk.getUserIDRefs()) )
        self.assertEquals( "index", self.theChunk.getUserIDRefs()[0] )
        self.assertEquals( "terms", self.theChunk.getUserIDRefs()[1] )
        
    def test_append_to_web_should_work( self ):
        web= MockWeb()
        self.theChunk.webAdd( web )
        self.assertEquals( 1, len(web.chunks) )
        
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.theChunk.weave( web, wvr )
        self.assertEquals( 1, len(wvr.begin_chunk) )
        self.assertTrue( wvr.begin_chunk[0] is self.theChunk )
        self.assertEquals( 1, len(wvr.end_chunk) )
        self.assertTrue( wvr.end_chunk[0] is self.theChunk )
        self.assertEquals(  "the words &amp; text of this Chunk", "".join( wvr.written ) )

    def test_tangle_should_work( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.theChunk.tangle( web, tnglr )
        self.assertEquals( 1, len(tnglr.begin_chunk) )
        self.assertTrue( tnglr.begin_chunk[0] is self.theChunk )
        self.assertEquals( 1, len(tnglr.end_chunk) )
        self.assertTrue( tnglr.end_chunk[0] is self.theChunk )
        self.assertEquals(  "the words & text of this Chunk", "".join( tnglr.written ) )
@}

<p>The OutputChunk is created by a <tt>@@o</tt> command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.
</p>

@d Unit Test of OutputChunk subclass... @{
class TestOutputChunk( unittest.TestCase ):
    def setUp( self ):
        self.theChunk= pyweb.OutputChunk( "filename", "#", "" )
        cmd= self.theChunk.makeContent( "the words & text of this Chunk" )
        self.theChunk.append( cmd )
        self.theChunk.setUserIDRefs( "index terms" )
        
    def test_append_to_web_should_work( self ):
        web= MockWeb()
        self.theChunk.webAdd( web )
        self.assertEquals( 1, len(web.chunks) )
        
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.theChunk.weave( web, wvr )
        self.assertEquals( 1, len(wvr.begin_chunk) )
        self.assertTrue( wvr.begin_chunk[0] is self.theChunk )
        self.assertEquals( 1, len(wvr.end_chunk) )
        self.assertTrue( wvr.end_chunk[0] is self.theChunk )
        self.assertEquals(  "the words &amp; text of this Chunk", "".join( wvr.written ) )

    def test_tangle_should_work( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.theChunk.tangle( web, tnglr )
        self.assertEquals( 1, len(tnglr.begin_chunk) )
        self.assertTrue( tnglr.begin_chunk[0] is self.theChunk )
        self.assertEquals( 1, len(tnglr.end_chunk) )
        self.assertTrue( tnglr.end_chunk[0] is self.theChunk )
        self.assertEquals(  "the words & text of this Chunk", "".join( tnglr.written ) )
@}

<p>The NamedDocumentChunk is a little-used feature.</p>

@d Unit Test of NamedDocumentChunk subclass... @{ @}

<h3>Command Tests</h3>

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

<p>This Command superclass is essentially an inteface definition, it
has no real testable features.</p>
@d Unit Test of Command superclass... @{ @}

<p>A TextCommand object must be constructed, interrogated and emitted.</p>

@d Unit Test of TextCommand class... @{ 
class TestTextCommand( unittest.TestCase ):
    def setUp( self ):
        self.cmd= pyweb.TextCommand( "Some text & words in the document\n    ", 314 )
        self.cmd2= pyweb.TextCommand( "No Indent\n", 314 )
    def test_methods_should_work( self ):
        self.assertTrue( self.cmd.startswith("Some") )
        self.assertFalse( self.cmd.startswith("text") )
        pat1= re.compile( r"\Wthe\W" )
        self.assertTrue( self.cmd.searchForRE(pat1) is not None )
        pat2= re.compile( r"\Wnothing\W" )
        self.assertTrue( self.cmd.searchForRE(pat2) is None )
        self.assertEquals( 4, self.cmd.indent() )
        self.assertEquals( 0, self.cmd2.indent() )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "Some text & words in the document\n    ", "".join( wvr.written ) )
    def test_tangle_should_work( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.cmd.tangle( web, tnglr )
        self.assertEquals(  "Some text & words in the document\n    ", "".join( tnglr.written ) )
@}

<p>A CodeCommand object is a TextCommand with different processing for being emitted.</p>

@d Unit Test of CodeCommand class... @{
class TestCodeCommand( unittest.TestCase ):
    def setUp( self ):
        self.cmd= pyweb.CodeCommand( "Some text & words in the document\n    ", 314 )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "Some text &amp; words in the document\n    ", "".join( wvr.written ) )
    def test_tangle_should_work( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.cmd.tangle( web, tnglr )
        self.assertEquals(  "Some text & words in the document\n    ", "".join( tnglr.written ) )
@}

<p>The XrefCommand class is largely abstract.</p>

@d Unit Test of XrefCommand superclass... @{ @}

<p>The FileXrefCommand command is expanded by a weaver to a list of all <tt>@@o</tt>
locations.</p>

@d Unit Test of FileXrefCommand class... @{ 
class TestFileXRefCommand( unittest.TestCase ):
    def setUp( self ):
        self.cmd= pyweb.FileXrefCommand( 314 )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "file [1, 2, 3]", "".join( wvr.written ) )
    def test_tangle_should_fail( self ):
        tnglr = MockTangler()
        web = MockWeb()
        try:
            self.cmd.tangle( web, tnglr )
            self.fail()
        except pyweb.Error:
            pass
@}

<p>The MacroXrefCommand command is expanded by a weaver to a list of all <tt>@@d</tt>
locations.</p>

@d Unit Test of MacroXrefCommand class... @{
class TestMacroXRefCommand( unittest.TestCase ):
    def setUp( self ):
        self.cmd= pyweb.MacroXrefCommand( 314 )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "chunk [4, 5, 6]", "".join( wvr.written ) )
    def test_tangle_should_fail( self ):
        tnglr = MockTangler()
        web = MockWeb()
        try:
            self.cmd.tangle( web, tnglr )
            self.fail()
        except pyweb.Error:
            pass
@}

<p>The UserIdXrefCommand command is expanded by a weaver to a list of all <tt>@@|</tt>
names.</p>

@d Unit Test of UserIdXrefCommand class... @{
class TestUserIdXrefCommand( unittest.TestCase ):
    def setUp( self ):
        self.cmd= pyweb.UserIdXrefCommand( 314 )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "name 7 [8, 9, 10]", "".join( wvr.written ) )
    def test_tangle_should_fail( self ):
        tnglr = MockTangler()
        web = MockWeb()
        try:
            self.cmd.tangle( web, tnglr )
            self.fail()
        except pyweb.Error:
            pass
@}

<p>Reference commands require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled.
</p>

@d Unit Test of ReferenceCommand class... @{ 
class TestReferenceCommand( unittest.TestCase ):
    def setUp( self ):
        self.chunk= MockChunk( "Owning Chunk", 123, 456 )
        self.cmd= pyweb.ReferenceCommand( "Some Name", 314 )
        self.cmd.chunk= self.chunk
        self.chunk.commands.append( self.cmd )
        self.chunk.previous_command= pyweb.TextCommand( "", self.chunk.commands[0].lineNumber )
    def test_weave_should_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.cmd.weave( web, wvr )
        self.assertEquals(  "Some Name", "".join( wvr.written ) )
    def test_tangle_should_work( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.cmd.tangle( web, tnglr )
        self.assertEquals(  "Some Name", "".join( tnglr.written ) )
@}

<h3>Reference Tests</h3>

<p>The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.
</p>

<p>The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.
</p>

@d Unit Test of Reference class hierarchy... @{ 
class TestReference( unittest.TestCase ):
    def setUp( self ):
        self.web= MockWeb()
        self.main= MockChunk( "Main", 1, 11 )
        self.parent= MockChunk( "Parent", 2, 22 )
        self.parent.referencedBy= [ self.main ]
        self.chunk= MockChunk( "Sub", 3, 33 )
        self.chunk.referencedBy= [ self.parent ]
    def test_simple_should_find_one( self ):
        self.reference= pyweb.SimpleReference( self.web )
        theList= self.reference.chunkReferencedBy( self.chunk )
        self.assertEquals( 1, len(theList) )
        self.assertEquals( ('Parent',2), theList[0] )
    def test_transitive_should_find_all( self ):
        self.reference= pyweb.TransitiveReference( self.web )
        theList= self.reference.chunkReferencedBy( self.chunk )
        self.assertEquals( 2, len(theList) )
        self.assertEquals( ('Parent',2), theList[0] )
        self.assertEquals( ('Main',1), theList[1] )
@}

<h3>Web Tests</h3>

<p>This is more difficult to create mocks for.</p>

@d Unit Test of Web class... 
@{ 
class TestWebConstruction( unittest.TestCase ):
    def setUp( self ):
        self.web= pyweb.Web( "Test" )
    @<Unit Test Web class construction methods@>
    
class TestWebProcessing( unittest.TestCase ):
    def setUp( self ):
        self.web= pyweb.Web( "Test" )
        self.chunk= pyweb.Chunk()
        self.chunk.appendText( "some text" )
        self.chunk.webAdd( self.web )
        self.out= pyweb.OutputChunk( "A File" )
        self.out.appendText( "some code" )
        nm= self.web.addDefName( "A Chunk" )
        self.out.append( pyweb.ReferenceCommand( nm ) )
        self.out.webAdd( self.web )
        self.named= pyweb.NamedChunk( "A Chunk..." )
        self.named.appendText( "some user2a code" )
        self.named.setUserIDRefs( "user1" )
        nm= self.web.addDefName( "Another Chunk" )
        self.named.append( pyweb.ReferenceCommand( nm ) )
        self.named.webAdd( self.web )
        self.named2= pyweb.NamedChunk( "Another Chunk..." )
        self.named2.appendText(  "some user1 code"  )
        self.named2.setUserIDRefs( "user2a user2b" )
        self.named2.webAdd( self.web )
    @<Unit Test Web class name resolution methods@>
    @<Unit Test Web class chunk cross-reference@>
    @<Unit Test Web class tangle@>
    @<Unit Test Web class weave@>
@}

@d Unit Test Web class construction... 
@{
def test_names_definition_should_resolve( self ):
    name1= self.web.addDefName( "A Chunk..." )
    self.assertTrue( name1 is None )
    self.assertEquals( 0, len(self.web.named) )
    name2= self.web.addDefName( "A Chunk Of Code" )
    self.assertEquals( "A Chunk Of Code", name2 )
    self.assertEquals( 1, len(self.web.named) )
    name3= self.web.addDefName( "A Chunk..." )
    self.assertEquals( "A Chunk Of Code", name3 )
    self.assertEquals( 1, len(self.web.named) )
    
def test_chunks_should_add_and_index( self ):
    chunk= pyweb.Chunk()
    chunk.appendText( "some text" )
    chunk.webAdd( self.web )
    self.assertEquals( 1, len(self.web.chunkSeq) )
    self.assertEquals( 0, len(self.web.named) )
    self.assertEquals( 0, len(self.web.output) )
    named= pyweb.NamedChunk( "A Chunk" )
    named.appendText( "some code" )
    named.webAdd( self.web )
    self.assertEquals( 2, len(self.web.chunkSeq) )
    self.assertEquals( 1, len(self.web.named) )
    self.assertEquals( 0, len(self.web.output) )
    out= pyweb.OutputChunk( "A File" )
    out.appendText( "some code" )
    out.webAdd( self.web )
    self.assertEquals( 3, len(self.web.chunkSeq) )
    self.assertEquals( 1, len(self.web.named) )
    self.assertEquals( 1, len(self.web.output) )
@}

@d Unit Test Web class name resolution... 
@{ 
def test_name_queries_should_resolve( self ):
    self.assertEquals( "A Chunk", self.web.fullNameFor( "A C..." ) )    
    self.assertEquals( "A Chunk", self.web.fullNameFor( "A Chunk" ) )    
    self.assertNotEquals( "A Chunk", self.web.fullNameFor( "A File" ) )
    self.assertTrue( self.named is self.web.getchunk( "A C..." )[0] )
    self.assertTrue( self.named is self.web.getchunk( "A Chunk" )[0] )
    try:
        self.assertTrue( None is not self.web.getchunk( "A File" ) )
        self.fail()
    except pyweb.Error, e:
        self.assertTrue( e.args[0].startswith("Cannot resolve 'A File'") )  
@}

@d Unit Test Web class chunk cross-reference @{ 
def test_valid_web_should_createUsedBy( self ):
    self.web.createUsedBy()
    # If it raises an exception, the web structure is damaged
def test_valid_web_should_createFileXref( self ):
    file_xref= self.web.fileXref()
    self.assertEquals( 1, len(file_xref) )
    self.assertTrue( "A File" in file_xref ) 
    self.assertTrue( 1, len(file_xref["A File"]) )
def test_valid_web_should_createChunkXref( self ):
    chunk_xref= self.web.chunkXref()
    self.assertEquals( 2, len(chunk_xref) )
    self.assertTrue( "A Chunk" in chunk_xref )
    self.assertEquals( 1, len(chunk_xref["A Chunk"]) )
    self.assertTrue( "Another Chunk" in chunk_xref )
    self.assertEquals( 1, len(chunk_xref["Another Chunk"]) )
    self.assertFalse( "Not A Real Chunk" in chunk_xref )
def test_valid_web_should_create_userNamesXref( self ):
    user_xref= self.web.userNamesXref() 
    self.assertEquals( 3, len(user_xref) )
    self.assertTrue( "user1" in user_xref )
    defn, reflist= user_xref["user1"]
    self.assertEquals( 1, len(reflist), "did not find user1" )
    self.assertTrue( "user2a" in user_xref )
    defn, reflist= user_xref["user2a"]
    self.assertEquals( 1, len(reflist), "did not find user2a" )
    self.assertTrue( "user2b" in user_xref )
    defn, reflist= user_xref["user2b"]
    self.assertEquals( 0, len(reflist) )
    self.assertFalse( "Not A User Symbol" in user_xref )
@}

@d Unit Test Web class tangle @{ 
def test_valid_web_should_tangle( self ):
    tangler= MockTangler()
    self.web.tangle( tangler )
    self.assertEquals( 3, len(tangler.written) )
    self.assertEquals( ['some code', 'some user2a code', 'some user1 code'], tangler.written )
@}

@d Unit Test Web class weave @{ 
def test_valid_web_should_weave( self ):
    weaver= MockWeaver()
    self.web.weave( weaver )
    self.assertEquals( 6, len(weaver.written) )
    expected= ['some text', 'some code', None, 'some user2a code', None, 'some user1 code']
    self.assertEquals( expected, weaver.written )
@}


<h3>WebReader Tests</h3>

<p>Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.
</p>

@d Unit Test of WebReader... @{ @}

<h3>Action Tests</h3>

<p>Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  
</p>

@d Unit Test of Action class hierarchy... @{ 
@<Unit test of Action Sequence class@>
@<Unit test of LoadAction class@>
@<Unit test of TangleAction class@>
@<Unit test of WeaverAction class@>
@}

@d Unit test of Action Sequence class... @{
class MockAction( object ):
    def __init__( self ):
        self.count= 0
    def __call__( self ):
        self.count += 1
        
class MockWebReader( object ):
    def __init__( self ):
        self.count= 0
        self.theWeb= None
    def web( self, aWeb ):
        self.theWeb= aWeb
        return self
    def load( self ):
        self.count += 1
    
class TestActionSequence( unittest.TestCase ):
    def setUp( self ):
        self.web= MockWeb()
        self.a1= MockAction()
        self.a2= MockAction()
        self.action= pyweb.ActionSequence( "TwoSteps", [self.a1, self.a2] )
        self.action.web= self.web
    def test_should_execute_both( self ):
        self.action()
        for c in self.action.opSequence:
            self.assertEquals( 1, c.count )
            self.assertTrue( self.web is c.web )
@}

@d Unit test of WeaverAction class... @{ 
class TestWeaveAction( unittest.TestCase ):
    def setUp( self ):
        self.web= MockWeb()
        self.action= pyweb.WeaveAction(  )
        self.weaver= MockWeaver()
        self.action.theWeaver= self.weaver
        self.action.web= self.web
    def test_should_execute_weaving( self ):
        self.action()
        self.assertTrue( self.web.wove is self.weaver )
@}

@d Unit test of TangleAction class... @{ 
class TestTangleAction( unittest.TestCase ):
    def setUp( self ):
        self.web= MockWeb()
        self.action= pyweb.TangleAction(  )
        self.tangler= MockTangler()
        self.action.theTangler= self.tangler
        self.action.web= self.web
    def test_should_execute_tangling( self ):
        self.action()
        self.assertTrue( self.web.tangled is self.tangler )
@}

@d Unit test of LoadAction class... @{ 
class TestLoadAction( unittest.TestCase ):
    def setUp( self ):
        self.web= MockWeb()
        self.action= pyweb.LoadAction(  )
        self.webReader= MockWebReader()
        self.webReader.theWeb= self.web
        self.action.webReader= self.webReader
        self.action.web= self.web
    def test_should_execute_tangling( self ):
        self.action()
        self.assertEquals( 1, self.webReader.count )
@}

<h3>Application Tests</h3>

<p>As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.
</p>

@d Unit Test of Application... @{ @}

<h3>Overheads and Main Script</h3>

<p>The boilerplate code for unit testing is the following.</p>

@d Unit Test overheads...
@{from __future__ import print_function
"""Unit tests."""
import pyweb
import unittest
import logging
import StringIO
import string
import os
import time
import re
@}

@d Unit Test main...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()
@}