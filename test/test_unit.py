from __future__ import print_function
"""Unit tests."""
import pyweb
import unittest
import logging
import StringIO
import string
import os
import time
import re



class MockChunk( object ):
    def __init__( self, name, seq, lineNumber ):
        self.name= name
        self.fullName= name
        self.seq= seq
        self.lineNumber= lineNumber
        self.initial= True
        self.commands= []
        self.referencedBy= []

 
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




class MockCommand( object ):
    def __init__( self ):
        self.lineNumber= 314
    def startswith( self, text ):
        return False

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

class TestChunk( unittest.TestCase ):
    def setUp( self ):
        self.theChunk= pyweb.Chunk()
        
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

 
class TestWebConstruction( unittest.TestCase ):
    def setUp( self ):
        self.web= pyweb.Web( "Test" )
        
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

         
    def test_valid_web_should_tangle( self ):
        tangler= MockTangler()
        self.web.tangle( tangler )
        self.assertEquals( 3, len(tangler.written) )
        self.assertEquals( ['some code', 'some user2a code', 'some user1 code'], tangler.written )

         
    def test_valid_web_should_weave( self ):
        weaver= MockWeaver()
        self.web.weave( weaver )
        self.assertEquals( 6, len(weaver.written) )
        expected= ['some text', 'some code', None, 'some user2a code', None, 'some user1 code']
        self.assertEquals( expected, weaver.written )


 
 

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


 

if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()

