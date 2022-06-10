############################################
pyWeb Literate Programming 2.1 - Test Suite
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

	MacBookPro-SLott:pyweb slott$ cd test
	MacBookPro-SLott:test slott$ python ../pyweb.py pyweb_test.w
	INFO:pyweb:Reading 'pyweb_test.w'
	INFO:pyweb:Starting Load [WebReader, Web 'pyweb_test.w']
	INFO:pyweb:Including 'intro.w'
	INFO:pyweb:Including 'unit.w'
	INFO:pyweb:Including 'func.w'
	INFO:pyweb:Including 'combined.w'
	INFO:pyweb:Starting Tangle [Web 'pyweb_test.w']
	INFO:pyweb:Tangling 'test_unit.py'
	INFO:pyweb:No change to 'test_unit.py'
	INFO:pyweb:Tangling 'test_weaver.py'
	INFO:pyweb:No change to 'test_weaver.py'
	INFO:pyweb:Tangling 'test_tangler.py'
	INFO:pyweb:No change to 'test_tangler.py'
	INFO:pyweb:Tangling 'test.py'
	INFO:pyweb:No change to 'test.py'
	INFO:pyweb:Tangling 'test_loader.py'
	INFO:pyweb:No change to 'test_loader.py'
	INFO:pyweb:Starting Weave [Web 'pyweb_test.w', None]
	INFO:pyweb:Weaving 'pyweb_test.html'
	INFO:pyweb:Wrote 2519 lines to 'pyweb_test.html'
	INFO:pyweb:pyWeb: Load 1695 lines from 5 files in 0 sec., Tangle 80 lines in 0.1 sec., Weave 2519 lines in 0.0 sec.
	MacBookPro-SLott:test slott$ PYTHONPATH=.. python3.3 test.py
	ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, ('@@{', '@@[') not found
	ERROR:WebReader:Errors in included file test8_inc.tmp, output is incomplete.
	.ERROR:WebReader:At ('test1.w', 8): expected ('@@{',), found '@@o'
	ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)
	ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)
	.............................................................................
	----------------------------------------------------------------------
	Ran 78 tests in 0.025s

	OK
	MacBookPro-SLott:test slott$ 


Unit Testing
============

..	test/func.w 

There are several broad areas of unit testing.  There are the 34 classes in this application.
However, it isn't really necessary to test everyone single one of these classes.
We'll decompose these into several hierarchies.


-	Emitters
    
	    class Emitter( object ):  
	    
        class Weaver( Emitter ):  
        
        class LaTeX( Weaver ):  
        
        class HTML( Weaver ):  
        
        class HTMLShort( HTML ):  
        
        class Tangler( Emitter ):  
        
        class TanglerMake( Tangler ):  
    
    
-	Structure: Chunk, Command
    
        class Chunk( object ):  
        
        class NamedChunk( Chunk ):  
        
        class OutputChunk( NamedChunk ):  
        
        class NamedDocumentChunk( NamedChunk ):  
        
        class MyNewCommand( Command ):  
        
        class Command( object ):  
        
        class TextCommand( Command ):  
        
        class CodeCommand( TextCommand ):  
        
        class XrefCommand( Command ):  
        
        class FileXrefCommand( XrefCommand ):  
        
        class MacroXrefCommand( XrefCommand ):  
        
        class UserIdXrefCommand( XrefCommand ):  
        
        class ReferenceCommand( Command ):  
	
	
-	class Error( Exception ):   
	
-	Reference Handling
	
        class Reference( object ):  
        
        class SimpleReference( Reference ):  
        
        class TransitiveReference( Reference ):  
    
	
-	class Web( object ):  

-	class WebReader( object ):  
	
-	Action
	
        class Action( object ):  
        
        class ActionSequence( Action ):  
        
        class WeaveAction( Action ):  
        
        class TangleAction( Action ):  
        
        class LoadAction( Action ):  
    
    
-	class Application( object ):  
	
-	class MyWeaver( HTML ):  
	
-	class MyHTML( pyweb.HTML ):


This gives us the following outline for unit testing.


..  _`1`:
..  rubric:: test_unit.py (1) =
..  parsed-literal::
    :class: code

    |srarr|\ Unit Test overheads: imports, etc. (`45`_)
    |srarr|\ Unit Test of Emitter class hierarchy (`2`_)
    |srarr|\ Unit Test of Chunk class hierarchy (`11`_)
    |srarr|\ Unit Test of Command class hierarchy (`22`_)
    |srarr|\ Unit Test of Reference class hierarchy (`31`_)
    |srarr|\ Unit Test of Web class (`32`_)
    |srarr|\ Unit Test of WebReader class (`38`_)
    |srarr|\ Unit Test of Action class hierarchy (`39`_)
    |srarr|\ Unit Test of Application class (`44`_)
    |srarr|\ Unit Test main (`46`_)

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

     
    class EmitterExtension( pyweb.Emitter ):
        def doOpen( self, fileName ):
            self.theFile= io.StringIO()
        def doClose( self ):
            self.theFile.flush()
            
    class TestEmitter( unittest.TestCase ):
        def setUp( self ):
            self.emitter= EmitterExtension()
        def test\_emitter\_should\_open\_close\_write( self ):
            self.emitter.open( "test.tmp" )
            self.emitter.write( "Something" )
            self.emitter.close()
            self.assertEquals( "Something", self.emitter.theFile.getvalue() )
        def test\_emitter\_should\_codeBlock( self ):
            self.emitter.open( "test.tmp" )
            self.emitter.codeBlock( "Some" )
            self.emitter.codeBlock( " Code" )
            self.emitter.close()
            self.assertEquals( "Some Code\\n", self.emitter.theFile.getvalue() )
        def test\_emitter\_should\_indent( self ):
            self.emitter.open( "test.tmp" )
            self.emitter.codeBlock( "Begin\\n" )
            self.emitter.setIndent( 4 )
            self.emitter.codeBlock( "More Code\\n" )
            self.emitter.clrIndent()
            self.emitter.codeBlock( "End" )
            self.emitter.close()
            self.assertEquals( "Begin\\n    More Code\\nEnd\\n", self.emitter.theFile.getvalue() )

..

    ..  class:: small

        |loz| *Unit Test of Emitter Superclass (3)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


A Mock Chunk is a Chunk-like object that we can use to test Weavers.


..  _`4`:
..  rubric:: Unit Test Mock Chunk class (4) =
..  parsed-literal::
    :class: code

    
    class MockChunk( object ):
        def \_\_init\_\_( self, name, seq, lineNumber ):
            self.name= name
            self.fullName= name
            self.seq= seq
            self.lineNumber= lineNumber
            self.initial= True
            self.commands= []
            self.referencedBy= []

..

    ..  class:: small

        |loz| *Unit Test Mock Chunk class (4)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


The default Weaver is an Emitter that uses templates to produce RST markup.


..  _`5`:
..  rubric:: Unit Test of Weaver subclass of Emitter (5) =
..  parsed-literal::
    :class: code

    
    class TestWeaver( unittest.TestCase ):
        def setUp( self ):
            self.weaver= pyweb.Weaver()
            self.filename= "testweaver.w" 
            self.aFileChunk= MockChunk( "File", 123, 456 )
            self.aFileChunk.references\_list= [ ]
            self.aChunk= MockChunk( "Chunk", 314, 278 )
            self.aChunk.references\_list= [ ("Container", 123) ]
        def tearDown( self ):
            import os
            try:
                pass #os.remove( "testweaver.rst" )
            except OSError:
                pass
            
        def test\_weaver\_functions( self ):
            result= self.weaver.quote( "\|char\| \`code\` \*em\* \_em\_" )
            self.assertEquals( "\\\|char\\\| \\\`code\\\` \\\*em\\\* \\\_em\\\_", result )
            result= self.weaver.references( self.aChunk )
            self.assertEquals( "Container (\`123\`\_)", result )
            result= self.weaver.referenceTo( "Chunk", 314 )
            self.assertEquals( r"\|srarr\|\\ Chunk (\`314\`\_)", result )
      
        def test\_weaver\_should\_codeBegin( self ):
            self.weaver.open( self.filename )
            self.weaver.setIndent()
            self.weaver.codeBegin( self.aChunk )
            self.weaver.codeBlock( self.weaver.quote( "\*The\* \`Code\`\\n" ) )
            self.weaver.clrIndent()
            self.weaver.codeEnd( self.aChunk )
            self.weaver.close()
            with open( "testweaver.rst", "r" ) as result:
                txt= result.read()
            self.assertEquals( "\\n..  \_\`314\`:\\n..  rubric:: Chunk (314) =\\n..  parsed-literal::\\n    :class: code\\n\\n    \\\\\*The\\\\\* \\\\\`Code\\\\\`\\n\\n..\\n\\n    ..  class:: small\\n\\n        \|loz\| \*Chunk (314)\*. Used by: Container (\`123\`\_)\\n", txt )
      
        def test\_weaver\_should\_fileBegin( self ):
            self.weaver.open( self.filename )
            self.weaver.fileBegin( self.aFileChunk )
            self.weaver.codeBlock( self.weaver.quote( "\*The\* \`Code\`\\n" ) )
            self.weaver.fileEnd( self.aFileChunk )
            self.weaver.close()
            with open( "testweaver.rst", "r" ) as result:
                txt= result.read()
            self.assertEquals( "\\n..  \_\`123\`:\\n..  rubric:: File (123) =\\n..  parsed-literal::\\n    :class: code\\n\\n    \\\\\*The\\\\\* \\\\\`Code\\\\\`\\n\\n..\\n\\n    ..  class:: small\\n\\n        \|loz\| \*File (123)\*.\\n", txt )
    
        def test\_weaver\_should\_xref( self ):
            self.weaver.open( self.filename )
            self.weaver.xrefHead( )
            self.weaver.xrefLine( "Chunk", [ ("Container", 123) ] )
            self.weaver.xrefFoot( )
            #self.weaver.fileEnd( self.aFileChunk ) # Why?
            self.weaver.close()
            with open( "testweaver.rst", "r" ) as result:
                txt= result.read()
            self.assertEquals( "\\n:Chunk:\\n    \|srarr\|\\\\ (\`('Container', 123)\`\_)\\n\\n", txt )
    
        def test\_weaver\_should\_xref\_def( self ):
            self.weaver.open( self.filename )
            self.weaver.xrefHead( )
            # Seems to have changed to a simple list of lines??
            self.weaver.xrefDefLine( "Chunk", 314, [ 123, 567 ] )
            self.weaver.xrefFoot( )
            #self.weaver.fileEnd( self.aFileChunk ) # Why?
            self.weaver.close()
            with open( "testweaver.rst", "r" ) as result:
                txt= result.read()
            self.assertEquals( "\\n:Chunk:\\n    \`123\`\_ [\`314\`\_] \`567\`\_\\n\\n", txt )

..

    ..  class:: small

        |loz| *Unit Test of Weaver subclass of Emitter (5)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


Note that the XREF data structure seems to have changed without appropriate
unit test support. During version 2.3 (6 Mar 2014) development, this
unit test seemed to have failed.

A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.

We'll examine a few features of the LaTeX templates.


..  _`6`:
..  rubric:: Unit Test of LaTeX subclass of Emitter (6) =
..  parsed-literal::
    :class: code

     
    class TestLaTeX( unittest.TestCase ):
        def setUp( self ):
            self.weaver= pyweb.LaTeX()
            self.filename= "testweaver.w" 
            self.aFileChunk= MockChunk( "File", 123, 456 )
            self.aFileChunk.references\_list= [ ]
            self.aChunk= MockChunk( "Chunk", 314, 278 )
            self.aChunk.references\_list= [ ("Container", 123) ]
        def tearDown( self ):
            import os
            try:
                os.remove( "testweaver.tex" )
            except OSError:
                pass
                
        def test\_weaver\_functions( self ):
            result= self.weaver.quote( "\\\\end{Verbatim}" )
            self.assertEquals( "\\\\end\\\\,{Verbatim}", result )
            result= self.weaver.references( self.aChunk )
            self.assertEquals( "\\n    \\\\footnotesize\\n    Used by:\\n    \\\\begin{list}{}{}\\n    \\n    \\\\item Code example Container (123) (Sect. \\\\ref{pyweb123}, p. \\\\pageref{pyweb123})\\n\\n    \\\\end{list}\\n    \\\\normalsize\\n", result )
            result= self.weaver.referenceTo( "Chunk", 314 )
            self.assertEquals( "$\\\\triangleright$ Code Example Chunk (314)", result )

..

    ..  class:: small

        |loz| *Unit Test of LaTeX subclass of Emitter (6)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


We'll examine a few features of the HTML templates.


..  _`7`:
..  rubric:: Unit Test of HTML subclass of Emitter (7) =
..  parsed-literal::
    :class: code

     
    class TestHTML( unittest.TestCase ):
        def setUp( self ):
            self.weaver= pyweb.HTML()
            self.filename= "testweaver.w" 
            self.aFileChunk= MockChunk( "File", 123, 456 )
            self.aFileChunk.references\_list= [ ]
            self.aChunk= MockChunk( "Chunk", 314, 278 )
            self.aChunk.references\_list= [ ("Container", 123) ]
        def tearDown( self ):
            import os
            try:
                os.remove( "testweaver.html" )
            except OSError:
                pass
                
        def test\_weaver\_functions( self ):
            result= self.weaver.quote( "a < b && c > d" )
            self.assertEquals( "a &lt; b &amp;&amp; c &gt; d", result )
            result= self.weaver.references( self.aChunk )
            self.assertEquals( '  Used by <a href="#pyweb123"><em>Container</em>&nbsp;(123)</a>.', result )
            result= self.weaver.referenceTo( "Chunk", 314 )
            self.assertEquals( '<a href="#pyweb314">&rarr;<em>Chunk</em> (314)</a>', result )
    

..

    ..  class:: small

        |loz| *Unit Test of HTML subclass of Emitter (7)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


The unique feature of the ``HTMLShort`` class is just a template change.

	**To Do** Test ``HTMLShort``.


..  _`8`:
..  rubric:: Unit Test of HTMLShort subclass of Emitter (8) =
..  parsed-literal::
    :class: code

    # TODO: Finish this
..

    ..  class:: small

        |loz| *Unit Test of HTMLShort subclass of Emitter (8)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


A Tangler emits the various named source files in proper format for the desired
compiler and language.


..  _`9`:
..  rubric:: Unit Test of Tangler subclass of Emitter (9) =
..  parsed-literal::
    :class: code

     
    class TestTangler( unittest.TestCase ):
        def setUp( self ):
            self.tangler= pyweb.Tangler()
            self.filename= "testtangler.w" 
            self.aFileChunk= MockChunk( "File", 123, 456 )
            self.aFileChunk.references\_list= [ ]
            self.aChunk= MockChunk( "Chunk", 314, 278 )
            self.aChunk.references\_list= [ ("Container", 123) ]
        def tearDown( self ):
            import os
            try:
                os.remove( "testtangler.w" )
            except OSError:
                pass
            
        def test\_tangler\_functions( self ):
            result= self.tangler.quote( string.printable )
            self.assertEquals( string.printable, result )
        def test\_tangler\_should\_codeBegin( self ):
            self.tangler.open( self.filename )
            self.tangler.codeBegin( self.aChunk )
            self.tangler.codeBlock( self.tangler.quote( "\*The\* \`Code\`\\n" ) )
            self.tangler.codeEnd( self.aChunk )
            self.tangler.close()
            with open( "testtangler.w", "r" ) as result:
                txt= result.read()
            self.assertEquals( "\*The\* \`Code\`\\n", txt )

..

    ..  class:: small

        |loz| *Unit Test of Tangler subclass of Emitter (9)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.


In order to be sure that the timestamps really have changed, we 
need to wait for a full second to elapse.




..  _`10`:
..  rubric:: Unit Test of TanglerMake subclass of Emitter (10) =
..  parsed-literal::
    :class: code

    
    class TestTanglerMake( unittest.TestCase ):
        def setUp( self ):
            self.tangler= pyweb.TanglerMake()
            self.filename= "testtangler.w" 
            self.aChunk= MockChunk( "Chunk", 314, 278 )
            self.aChunk.references\_list= [ ("Container", 123) ]
            self.tangler.open( self.filename )
            self.tangler.codeBegin( self.aChunk )
            self.tangler.codeBlock( self.tangler.quote( "\*The\* \`Code\`\\n" ) )
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
            
        def test\_same\_should\_leave( self ):
            self.tangler.open( self.filename )
            self.tangler.codeBegin( self.aChunk )
            self.tangler.codeBlock( self.tangler.quote( "\*The\* \`Code\`\\n" ) )
            self.tangler.codeEnd( self.aChunk )
            self.tangler.close()
            self.assertEquals( self.original, os.path.getmtime( self.filename ) )
            
        def test\_different\_should\_update( self ):
            self.tangler.open( self.filename )
            self.tangler.codeBegin( self.aChunk )
            self.tangler.codeBlock( self.tangler.quote( "\*Completely Different\* \`Code\`\\n" ) )
            self.tangler.codeEnd( self.aChunk )
            self.tangler.close()
            self.assertNotEquals( self.original, os.path.getmtime( self.filename ) )

..

    ..  class:: small

        |loz| *Unit Test of TanglerMake subclass of Emitter (10)*. Used by: Unit Test of Emitter class hierarchy (`2`_); test_unit.py (`1`_)


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
    |srarr|\ Unit Test of OutputChunk subclass (`20`_)
    |srarr|\ Unit Test of NamedDocumentChunk subclass (`21`_)

..

    ..  class:: small

        |loz| *Unit Test of Chunk class hierarchy (11)*. Used by: test_unit.py (`1`_)


In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
Mock objects for all of these relationships in which a Chunk participates.

A MockCommand can be attached to a Chunk.


..  _`12`:
..  rubric:: Unit Test of Chunk superclass (12) =
..  parsed-literal::
    :class: code

    
    class MockCommand( object ):
        def \_\_init\_\_( self ):
            self.lineNumber= 314
        def startswith( self, text ):
            return False

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (12)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


A MockWeb can contain a Chunk.


..  _`13`:
..  rubric:: Unit Test of Chunk superclass (13) +=
..  parsed-literal::
    :class: code

    
    class MockWeb( object ):
        def \_\_init\_\_( self ):
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

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (13)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


A MockWeaver or MockTangle can process a Chunk.


..  _`14`:
..  rubric:: Unit Test of Chunk superclass (14) +=
..  parsed-literal::
    :class: code

    
    class MockWeaver( object ):
        def \_\_init\_\_( self ):
            self.begin\_chunk= []
            self.end\_chunk= []
            self.written= []
            self.code\_indent= None
        def quote( self, text ):
            return text.replace( "&", "&amp;" ) # token quoting
        def docBegin( self, aChunk ):
            self.begin\_chunk.append( aChunk )
        def write( self, text ):
            self.written.append( text )
        def docEnd( self, aChunk ):
            self.end\_chunk.append( aChunk )
        def codeBegin( self, aChunk ):
            self.begin\_chunk.append( aChunk )
        def codeBlock( self, text ):
            self.written.append( text )
        def codeEnd( self, aChunk ):
            self.end\_chunk.append( aChunk )
        def fileBegin( self, aChunk ):
            self.begin\_chunk.append( aChunk )
        def fileEnd( self, aChunk ):
            self.end\_chunk.append( aChunk )
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
        def \_\_init\_\_( self ):
            super( MockTangler, self ).\_\_init\_\_()
            self.context= [0]

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (14)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


A Chunk is built, interrogated and then emitted.


..  _`15`:
..  rubric:: Unit Test of Chunk superclass (15) +=
..  parsed-literal::
    :class: code

    
    class TestChunk( unittest.TestCase ):
        def setUp( self ):
            self.theChunk= pyweb.Chunk()
        |srarr|\ Unit Test of Chunk construction (`16`_)
        |srarr|\ Unit Test of Chunk interrogation (`17`_)
        |srarr|\ Unit Test of Chunk emission (`18`_)

..

    ..  class:: small

        |loz| *Unit Test of Chunk superclass (15)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


Can we build a Chunk?


..  _`16`:
..  rubric:: Unit Test of Chunk construction (16) =
..  parsed-literal::
    :class: code

    
    def test\_append\_command\_should\_work( self ):
        cmd1= MockCommand()
        self.theChunk.append( cmd1 )
        self.assertEquals( 1, len(self.theChunk.commands ) )
        cmd2= MockCommand()
        self.theChunk.append( cmd2 )
        self.assertEquals( 2, len(self.theChunk.commands ) )
        
    def test\_append\_initial\_and\_more\_text\_should\_work( self ):
        self.theChunk.appendText( "hi mom" )
        self.assertEquals( 1, len(self.theChunk.commands ) )
        self.theChunk.appendText( "&more text" )
        self.assertEquals( 1, len(self.theChunk.commands ) )
        self.assertEquals( "hi mom&more text", self.theChunk.commands[0].text )
        
    def test\_append\_following\_text\_should\_work( self ):
        cmd1= MockCommand()
        self.theChunk.append( cmd1 )
        self.theChunk.appendText( "hi mom" )
        self.assertEquals( 2, len(self.theChunk.commands ) )
        
    def test\_append\_to\_web\_should\_work( self ):
        web= MockWeb()
        self.theChunk.webAdd( web )
        self.assertEquals( 1, len(web.chunks) )

..

    ..  class:: small

        |loz| *Unit Test of Chunk construction (16)*. Used by: Unit Test of Chunk superclass (`15`_); Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


Can we interrogate a Chunk?


..  _`17`:
..  rubric:: Unit Test of Chunk interrogation (17) =
..  parsed-literal::
    :class: code

    
    def test\_leading\_command\_should\_not\_find( self ):
        self.assertFalse( self.theChunk.startswith( "hi mom" ) )
        cmd1= MockCommand()
        self.theChunk.append( cmd1 )
        self.assertFalse( self.theChunk.startswith( "hi mom" ) )
        self.theChunk.appendText( "hi mom" )
        self.assertEquals( 2, len(self.theChunk.commands ) )
        self.assertFalse( self.theChunk.startswith( "hi mom" ) )
        
    def test\_leading\_text\_should\_not\_find( self ):
        self.assertFalse( self.theChunk.startswith( "hi mom" ) )
        self.theChunk.appendText( "hi mom" )
        self.assertTrue( self.theChunk.startswith( "hi mom" ) )
        cmd1= MockCommand()
        self.theChunk.append( cmd1 )
        self.assertTrue( self.theChunk.startswith( "hi mom" ) )
        self.assertEquals( 2, len(self.theChunk.commands ) )
    
    def test\_regexp\_exists\_should\_find( self ):
        self.theChunk.appendText( "this chunk has many words" )
        pat= re.compile( r"\\Wchunk\\W" )
        found= self.theChunk.searchForRE(pat)
        self.assertTrue( found is self.theChunk )
    def test\_regexp\_missing\_should\_not\_find( self ):
        self.theChunk.appendText( "this chunk has many words" )
        pat= re.compile( "\\Warpigs\\W" )
        found= self.theChunk.searchForRE(pat)
        self.assertTrue( found is None )
        
    def test\_lineNumber\_should\_work( self ):
        self.assertTrue( self.theChunk.lineNumber is None )
        cmd1= MockCommand()
        self.theChunk.append( cmd1 )
        self.assertEqual( 314, self.theChunk.lineNumber )

..

    ..  class:: small

        |loz| *Unit Test of Chunk interrogation (17)*. Used by: Unit Test of Chunk superclass (`15`_); Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


Can we emit a Chunk with a weaver or tangler?


..  _`18`:
..  rubric:: Unit Test of Chunk emission (18) =
..  parsed-literal::
    :class: code

    
    def test\_weave\_should\_work( self ):
        wvr = MockWeaver()
        web = MockWeb()
        self.theChunk.appendText( "this chunk has very & many words" )
        self.theChunk.weave( web, wvr )
        self.assertEquals( 1, len(wvr.begin\_chunk) )
        self.assertTrue( wvr.begin\_chunk[0] is self.theChunk )
        self.assertEquals( 1, len(wvr.end\_chunk) )
        self.assertTrue( wvr.end\_chunk[0] is self.theChunk )
        self.assertEquals(  "this chunk has very & many words", "".join( wvr.written ) )
        
    def test\_tangle\_should\_fail( self ):
        tnglr = MockTangler()
        web = MockWeb()
        self.theChunk.appendText( "this chunk has very & many words" )
        try:
            self.theChunk.tangle( web, tnglr )
            self.fail()
        except pyweb.Error as e:
            self.assertEquals( "Cannot tangle an anonymous chunk", e.args[0] )

..

    ..  class:: small

        |loz| *Unit Test of Chunk emission (18)*. Used by: Unit Test of Chunk superclass (`15`_); Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


The NamedChunk is created by a ``@d`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`19`:
..  rubric:: Unit Test of NamedChunk subclass (19) =
..  parsed-literal::
    :class: code

     
    class TestNamedChunk( unittest.TestCase ):
        def setUp( self ):
            self.theChunk= pyweb.NamedChunk( "Some Name..." )
            cmd= self.theChunk.makeContent( "the words & text of this Chunk" )
            self.theChunk.append( cmd )
            self.theChunk.setUserIDRefs( "index terms" )
            
        def test\_should\_find\_xref\_words( self ):
            self.assertEquals( 2, len(self.theChunk.getUserIDRefs()) )
            self.assertEquals( "index", self.theChunk.getUserIDRefs()[0] )
            self.assertEquals( "terms", self.theChunk.getUserIDRefs()[1] )
            
        def test\_append\_to\_web\_should\_work( self ):
            web= MockWeb()
            self.theChunk.webAdd( web )
            self.assertEquals( 1, len(web.chunks) )
            
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.theChunk.weave( web, wvr )
            self.assertEquals( 1, len(wvr.begin\_chunk) )
            self.assertTrue( wvr.begin\_chunk[0] is self.theChunk )
            self.assertEquals( 1, len(wvr.end\_chunk) )
            self.assertTrue( wvr.end\_chunk[0] is self.theChunk )
            self.assertEquals(  "the words &amp; text of this Chunk", "".join( wvr.written ) )
    
        def test\_tangle\_should\_work( self ):
            tnglr = MockTangler()
            web = MockWeb()
            self.theChunk.tangle( web, tnglr )
            self.assertEquals( 1, len(tnglr.begin\_chunk) )
            self.assertTrue( tnglr.begin\_chunk[0] is self.theChunk )
            self.assertEquals( 1, len(tnglr.end\_chunk) )
            self.assertTrue( tnglr.end\_chunk[0] is self.theChunk )
            self.assertEquals(  "the words & text of this Chunk", "".join( tnglr.written ) )

..

    ..  class:: small

        |loz| *Unit Test of NamedChunk subclass (19)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


The OutputChunk is created by a ``@o`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`20`:
..  rubric:: Unit Test of OutputChunk subclass (20) =
..  parsed-literal::
    :class: code

    
    class TestOutputChunk( unittest.TestCase ):
        def setUp( self ):
            self.theChunk= pyweb.OutputChunk( "filename", "#", "" )
            cmd= self.theChunk.makeContent( "the words & text of this Chunk" )
            self.theChunk.append( cmd )
            self.theChunk.setUserIDRefs( "index terms" )
            
        def test\_append\_to\_web\_should\_work( self ):
            web= MockWeb()
            self.theChunk.webAdd( web )
            self.assertEquals( 1, len(web.chunks) )
            
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.theChunk.weave( web, wvr )
            self.assertEquals( 1, len(wvr.begin\_chunk) )
            self.assertTrue( wvr.begin\_chunk[0] is self.theChunk )
            self.assertEquals( 1, len(wvr.end\_chunk) )
            self.assertTrue( wvr.end\_chunk[0] is self.theChunk )
            self.assertEquals(  "the words &amp; text of this Chunk", "".join( wvr.written ) )
    
        def test\_tangle\_should\_work( self ):
            tnglr = MockTangler()
            web = MockWeb()
            self.theChunk.tangle( web, tnglr )
            self.assertEquals( 1, len(tnglr.begin\_chunk) )
            self.assertTrue( tnglr.begin\_chunk[0] is self.theChunk )
            self.assertEquals( 1, len(tnglr.end\_chunk) )
            self.assertTrue( tnglr.end\_chunk[0] is self.theChunk )
            self.assertEquals(  "the words & text of this Chunk", "".join( tnglr.written ) )

..

    ..  class:: small

        |loz| *Unit Test of OutputChunk subclass (20)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


The NamedDocumentChunk is a little-used feature.

	**TODO** Test ``NamedDocumentChunk``.


..  _`21`:
..  rubric:: Unit Test of NamedDocumentChunk subclass (21) =
..  parsed-literal::
    :class: code

    # TODO Test This 
..

    ..  class:: small

        |loz| *Unit Test of NamedDocumentChunk subclass (21)*. Used by: Unit Test of Chunk class hierarchy (`11`_); test_unit.py (`1`_)


Command Tests
---------------


..  _`22`:
..  rubric:: Unit Test of Command class hierarchy (22) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Unit Test of Command superclass (`23`_)
    |srarr|\ Unit Test of TextCommand class to contain a document text block (`24`_)
    |srarr|\ Unit Test of CodeCommand class to contain a program source code block (`25`_)
    |srarr|\ Unit Test of XrefCommand superclass for all cross-reference commands (`26`_)
    |srarr|\ Unit Test of FileXrefCommand class for an output file cross-reference (`27`_)
    |srarr|\ Unit Test of MacroXrefCommand class for a named chunk cross-reference (`28`_)
    |srarr|\ Unit Test of UserIdXrefCommand class for a user identifier cross-reference (`29`_)
    |srarr|\ Unit Test of ReferenceCommand class for chunk references (`30`_)

..

    ..  class:: small

        |loz| *Unit Test of Command class hierarchy (22)*. Used by: test_unit.py (`1`_)


This Command superclass is essentially an inteface definition, it
has no real testable features.


..  _`23`:
..  rubric:: Unit Test of Command superclass (23) =
..  parsed-literal::
    :class: code

    # No Tests
..

    ..  class:: small

        |loz| *Unit Test of Command superclass (23)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


A TextCommand object must be constructed, interrogated and emitted.


..  _`24`:
..  rubric:: Unit Test of TextCommand class to contain a document text block (24) =
..  parsed-literal::
    :class: code

     
    class TestTextCommand( unittest.TestCase ):
        def setUp( self ):
            self.cmd= pyweb.TextCommand( "Some text & words in the document\\n    ", 314 )
            self.cmd2= pyweb.TextCommand( "No Indent\\n", 314 )
        def test\_methods\_should\_work( self ):
            self.assertTrue( self.cmd.startswith("Some") )
            self.assertFalse( self.cmd.startswith("text") )
            pat1= re.compile( r"\\Wthe\\W" )
            self.assertTrue( self.cmd.searchForRE(pat1) is not None )
            pat2= re.compile( r"\\Wnothing\\W" )
            self.assertTrue( self.cmd.searchForRE(pat2) is None )
            self.assertEquals( 4, self.cmd.indent() )
            self.assertEquals( 0, self.cmd2.indent() )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "Some text & words in the document\\n    ", "".join( wvr.written ) )
        def test\_tangle\_should\_work( self ):
            tnglr = MockTangler()
            web = MockWeb()
            self.cmd.tangle( web, tnglr )
            self.assertEquals(  "Some text & words in the document\\n    ", "".join( tnglr.written ) )

..

    ..  class:: small

        |loz| *Unit Test of TextCommand class to contain a document text block (24)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


A CodeCommand object is a TextCommand with different processing for being emitted.


..  _`25`:
..  rubric:: Unit Test of CodeCommand class to contain a program source code block (25) =
..  parsed-literal::
    :class: code

    
    class TestCodeCommand( unittest.TestCase ):
        def setUp( self ):
            self.cmd= pyweb.CodeCommand( "Some text & words in the document\\n    ", 314 )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "Some text &amp; words in the document\\n    ", "".join( wvr.written ) )
        def test\_tangle\_should\_work( self ):
            tnglr = MockTangler()
            web = MockWeb()
            self.cmd.tangle( web, tnglr )
            self.assertEquals(  "Some text & words in the document\\n    ", "".join( tnglr.written ) )

..

    ..  class:: small

        |loz| *Unit Test of CodeCommand class to contain a program source code block (25)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


The XrefCommand class is largely abstract.


..  _`26`:
..  rubric:: Unit Test of XrefCommand superclass for all cross-reference commands (26) =
..  parsed-literal::
    :class: code

    # No Tests 
..

    ..  class:: small

        |loz| *Unit Test of XrefCommand superclass for all cross-reference commands (26)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


The FileXrefCommand command is expanded by a weaver to a list of ``@o``
locations.


..  _`27`:
..  rubric:: Unit Test of FileXrefCommand class for an output file cross-reference (27) =
..  parsed-literal::
    :class: code

     
    class TestFileXRefCommand( unittest.TestCase ):
        def setUp( self ):
            self.cmd= pyweb.FileXrefCommand( 314 )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "file [1, 2, 3]", "".join( wvr.written ) )
        def test\_tangle\_should\_fail( self ):
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle( web, tnglr )
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of FileXrefCommand class for an output file cross-reference (27)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


The MacroXrefCommand command is expanded by a weaver to a list of all ``@d``
locations.


..  _`28`:
..  rubric:: Unit Test of MacroXrefCommand class for a named chunk cross-reference (28) =
..  parsed-literal::
    :class: code

    
    class TestMacroXRefCommand( unittest.TestCase ):
        def setUp( self ):
            self.cmd= pyweb.MacroXrefCommand( 314 )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "chunk [4, 5, 6]", "".join( wvr.written ) )
        def test\_tangle\_should\_fail( self ):
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle( web, tnglr )
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of MacroXrefCommand class for a named chunk cross-reference (28)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


The UserIdXrefCommand command is expanded by a weaver to a list of all ``@|``
names.


..  _`29`:
..  rubric:: Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29) =
..  parsed-literal::
    :class: code

    
    class TestUserIdXrefCommand( unittest.TestCase ):
        def setUp( self ):
            self.cmd= pyweb.UserIdXrefCommand( 314 )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "name 7 [8, 9, 10]", "".join( wvr.written ) )
        def test\_tangle\_should\_fail( self ):
            tnglr = MockTangler()
            web = MockWeb()
            try:
                self.cmd.tangle( web, tnglr )
                self.fail()
            except pyweb.Error:
                pass

..

    ..  class:: small

        |loz| *Unit Test of UserIdXrefCommand class for a user identifier cross-reference (29)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


Reference commands require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled.


..  _`30`:
..  rubric:: Unit Test of ReferenceCommand class for chunk references (30) =
..  parsed-literal::
    :class: code

     
    class TestReferenceCommand( unittest.TestCase ):
        def setUp( self ):
            self.chunk= MockChunk( "Owning Chunk", 123, 456 )
            self.cmd= pyweb.ReferenceCommand( "Some Name", 314 )
            self.cmd.chunk= self.chunk
            self.chunk.commands.append( self.cmd )
            self.chunk.previous\_command= pyweb.TextCommand( "", self.chunk.commands[0].lineNumber )
        def test\_weave\_should\_work( self ):
            wvr = MockWeaver()
            web = MockWeb()
            self.cmd.weave( web, wvr )
            self.assertEquals(  "Some Name", "".join( wvr.written ) )
        def test\_tangle\_should\_work( self ):
            tnglr = MockTangler()
            web = MockWeb()
            self.cmd.tangle( web, tnglr )
            self.assertEquals(  "Some Name", "".join( tnglr.written ) )

..

    ..  class:: small

        |loz| *Unit Test of ReferenceCommand class for chunk references (30)*. Used by: Unit Test of Command class hierarchy (`22`_); test_unit.py (`1`_)


Reference Tests
----------------

The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.

The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.



..  _`31`:
..  rubric:: Unit Test of Reference class hierarchy (31) =
..  parsed-literal::
    :class: code

     
    class TestReference( unittest.TestCase ):
        def setUp( self ):
            self.web= MockWeb()
            self.main= MockChunk( "Main", 1, 11 )
            self.parent= MockChunk( "Parent", 2, 22 )
            self.parent.referencedBy= [ self.main ]
            self.chunk= MockChunk( "Sub", 3, 33 )
            self.chunk.referencedBy= [ self.parent ]
        def test\_simple\_should\_find\_one( self ):
            self.reference= pyweb.SimpleReference( self.web )
            theList= self.reference.chunkReferencedBy( self.chunk )
            self.assertEquals( 1, len(theList) )
            self.assertEquals( ('Parent',2), theList[0] )
        def test\_transitive\_should\_find\_all( self ):
            self.reference= pyweb.TransitiveReference( self.web )
            theList= self.reference.chunkReferencedBy( self.chunk )
            self.assertEquals( 2, len(theList) )
            self.assertEquals( ('Parent',2), theList[0] )
            self.assertEquals( ('Main',1), theList[1] )

..

    ..  class:: small

        |loz| *Unit Test of Reference class hierarchy (31)*. Used by: test_unit.py (`1`_)


Web Tests
-----------

This is more difficult to create mocks for.


..  _`32`:
..  rubric:: Unit Test of Web class (32) =
..  parsed-literal::
    :class: code

     
    class TestWebConstruction( unittest.TestCase ):
        def setUp( self ):
            self.web= pyweb.Web()
        |srarr|\ Unit Test Web class construction methods (`33`_)
        
    class TestWebProcessing( unittest.TestCase ):
        def setUp( self ):
            self.web= pyweb.Web()
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
        |srarr|\ Unit Test Web class name resolution methods (`34`_)
        |srarr|\ Unit Test Web class chunk cross-reference (`35`_)
        |srarr|\ Unit Test Web class tangle (`36`_)
        |srarr|\ Unit Test Web class weave (`37`_)

..

    ..  class:: small

        |loz| *Unit Test of Web class (32)*. Used by: test_unit.py (`1`_)



..  _`33`:
..  rubric:: Unit Test Web class construction methods (33) =
..  parsed-literal::
    :class: code

    
    def test\_names\_definition\_should\_resolve( self ):
        name1= self.web.addDefName( "A Chunk..." )
        self.assertTrue( name1 is None )
        self.assertEquals( 0, len(self.web.named) )
        name2= self.web.addDefName( "A Chunk Of Code" )
        self.assertEquals( "A Chunk Of Code", name2 )
        self.assertEquals( 1, len(self.web.named) )
        name3= self.web.addDefName( "A Chunk..." )
        self.assertEquals( "A Chunk Of Code", name3 )
        self.assertEquals( 1, len(self.web.named) )
        
    def test\_chunks\_should\_add\_and\_index( self ):
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

..

    ..  class:: small

        |loz| *Unit Test Web class construction methods (33)*. Used by: Unit Test of Web class (`32`_); test_unit.py (`1`_)



..  _`34`:
..  rubric:: Unit Test Web class name resolution methods (34) =
..  parsed-literal::
    :class: code

     
    def test\_name\_queries\_should\_resolve( self ):
        self.assertEquals( "A Chunk", self.web.fullNameFor( "A C..." ) )    
        self.assertEquals( "A Chunk", self.web.fullNameFor( "A Chunk" ) )    
        self.assertNotEquals( "A Chunk", self.web.fullNameFor( "A File" ) )
        self.assertTrue( self.named is self.web.getchunk( "A C..." )[0] )
        self.assertTrue( self.named is self.web.getchunk( "A Chunk" )[0] )
        try:
            self.assertTrue( None is not self.web.getchunk( "A File" ) )
            self.fail()
        except pyweb.Error as e:
            self.assertTrue( e.args[0].startswith("Cannot resolve 'A File'") )  

..

    ..  class:: small

        |loz| *Unit Test Web class name resolution methods (34)*. Used by: Unit Test of Web class (`32`_); test_unit.py (`1`_)



..  _`35`:
..  rubric:: Unit Test Web class chunk cross-reference (35) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_createUsedBy( self ):
        self.web.createUsedBy()
        # If it raises an exception, the web structure is damaged
    def test\_valid\_web\_should\_createFileXref( self ):
        file\_xref= self.web.fileXref()
        self.assertEquals( 1, len(file\_xref) )
        self.assertTrue( "A File" in file\_xref ) 
        self.assertTrue( 1, len(file\_xref["A File"]) )
    def test\_valid\_web\_should\_createChunkXref( self ):
        chunk\_xref= self.web.chunkXref()
        self.assertEquals( 2, len(chunk\_xref) )
        self.assertTrue( "A Chunk" in chunk\_xref )
        self.assertEquals( 1, len(chunk\_xref["A Chunk"]) )
        self.assertTrue( "Another Chunk" in chunk\_xref )
        self.assertEquals( 1, len(chunk\_xref["Another Chunk"]) )
        self.assertFalse( "Not A Real Chunk" in chunk\_xref )
    def test\_valid\_web\_should\_create\_userNamesXref( self ):
        user\_xref= self.web.userNamesXref() 
        self.assertEquals( 3, len(user\_xref) )
        self.assertTrue( "user1" in user\_xref )
        defn, reflist= user\_xref["user1"]
        self.assertEquals( 1, len(reflist), "did not find user1" )
        self.assertTrue( "user2a" in user\_xref )
        defn, reflist= user\_xref["user2a"]
        self.assertEquals( 1, len(reflist), "did not find user2a" )
        self.assertTrue( "user2b" in user\_xref )
        defn, reflist= user\_xref["user2b"]
        self.assertEquals( 0, len(reflist) )
        self.assertFalse( "Not A User Symbol" in user\_xref )

..

    ..  class:: small

        |loz| *Unit Test Web class chunk cross-reference (35)*. Used by: Unit Test of Web class (`32`_); test_unit.py (`1`_)



..  _`36`:
..  rubric:: Unit Test Web class tangle (36) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_tangle( self ):
        tangler= MockTangler()
        self.web.tangle( tangler )
        self.assertEquals( 3, len(tangler.written) )
        self.assertEquals( ['some code', 'some user2a code', 'some user1 code'], tangler.written )

..

    ..  class:: small

        |loz| *Unit Test Web class tangle (36)*. Used by: Unit Test of Web class (`32`_); test_unit.py (`1`_)



..  _`37`:
..  rubric:: Unit Test Web class weave (37) =
..  parsed-literal::
    :class: code

     
    def test\_valid\_web\_should\_weave( self ):
        weaver= MockWeaver()
        self.web.weave( weaver )
        self.assertEquals( 6, len(weaver.written) )
        expected= ['some text', 'some code', None, 'some user2a code', None, 'some user1 code']
        self.assertEquals( expected, weaver.written )

..

    ..  class:: small

        |loz| *Unit Test Web class weave (37)*. Used by: Unit Test of Web class (`32`_); test_unit.py (`1`_)



WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.


..  _`38`:
..  rubric:: Unit Test of WebReader class (38) =
..  parsed-literal::
    :class: code

    # Tested via functional tests
..

    ..  class:: small

        |loz| *Unit Test of WebReader class (38)*. Used by: test_unit.py (`1`_)


Action Tests
-------------

Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  


..  _`39`:
..  rubric:: Unit Test of Action class hierarchy (39) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Unit test of Action Sequence class (`40`_)
    |srarr|\ Unit test of LoadAction class (`43`_)
    |srarr|\ Unit test of TangleAction class (`42`_)
    |srarr|\ Unit test of WeaverAction class (`41`_)

..

    ..  class:: small

        |loz| *Unit Test of Action class hierarchy (39)*. Used by: test_unit.py (`1`_)



..  _`40`:
..  rubric:: Unit test of Action Sequence class (40) =
..  parsed-literal::
    :class: code

    
    class MockAction( object ):
        def \_\_init\_\_( self ):
            self.count= 0
        def \_\_call\_\_( self ):
            self.count += 1
            
    class MockWebReader( object ):
        def \_\_init\_\_( self ):
            self.count= 0
            self.theWeb= None
        def web( self, aWeb ):
            self.theWeb= aWeb
            return self
        def source( self, filename, file ):
         	self.webFileName= filename
        def load( self ):
            self.count += 1
        
    class TestActionSequence( unittest.TestCase ):
        def setUp( self ):
            self.web= MockWeb()
            self.a1= MockAction()
            self.a2= MockAction()
            self.action= pyweb.ActionSequence( "TwoSteps", [self.a1, self.a2] )
            self.action.web= self.web
            self.action.options= argparse.Namespace()
        def test\_should\_execute\_both( self ):
            self.action()
            for c in self.action.opSequence:
                self.assertEquals( 1, c.count )
                self.assertTrue( self.web is c.web )

..

    ..  class:: small

        |loz| *Unit test of Action Sequence class (40)*. Used by: Unit Test of Action class hierarchy (`39`_); test_unit.py (`1`_)



..  _`41`:
..  rubric:: Unit test of WeaverAction class (41) =
..  parsed-literal::
    :class: code

     
    class TestWeaveAction( unittest.TestCase ):
        def setUp( self ):
            self.web= MockWeb()
            self.action= pyweb.WeaveAction(  )
            self.weaver= MockWeaver()
            self.action.web= self.web
            self.action.options= argparse.Namespace( theWeaver=self.weaver )
        def test\_should\_execute\_weaving( self ):
            self.action()
            self.assertTrue( self.web.wove is self.weaver )

..

    ..  class:: small

        |loz| *Unit test of WeaverAction class (41)*. Used by: Unit Test of Action class hierarchy (`39`_); test_unit.py (`1`_)



..  _`42`:
..  rubric:: Unit test of TangleAction class (42) =
..  parsed-literal::
    :class: code

     
    class TestTangleAction( unittest.TestCase ):
        def setUp( self ):
            self.web= MockWeb()
            self.action= pyweb.TangleAction(  )
            self.tangler= MockTangler()
            self.action.web= self.web
            self.action.options= argparse.Namespace( 
            	theTangler= self.tangler )
        def test\_should\_execute\_tangling( self ):
            self.action()
            self.assertTrue( self.web.tangled is self.tangler )

..

    ..  class:: small

        |loz| *Unit test of TangleAction class (42)*. Used by: Unit Test of Action class hierarchy (`39`_); test_unit.py (`1`_)



..  _`43`:
..  rubric:: Unit test of LoadAction class (43) =
..  parsed-literal::
    :class: code

     
    class TestLoadAction( unittest.TestCase ):
        def setUp( self ):
            self.web= MockWeb()
            self.action= pyweb.LoadAction(  )
            self.webReader= MockWebReader()
            self.action.webReader= self.webReader
            self.action.web= self.web
            self.action.options= argparse.Namespace( webReader= self.webReader, webFileName="TestLoadAction.w" )
            with open("TestLoadAction.w","w") as web:
            	pass
        def tearDown( self ):
        	try:
        		os.remove("TestLoadAction.w")
        	except IOError:
        		pass
        def test\_should\_execute\_loading( self ):
            self.action()
            self.assertEquals( 1, self.webReader.count )

..

    ..  class:: small

        |loz| *Unit test of LoadAction class (43)*. Used by: Unit Test of Action class hierarchy (`39`_); test_unit.py (`1`_)


Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.


..  _`44`:
..  rubric:: Unit Test of Application class (44) =
..  parsed-literal::
    :class: code

    # TODO Test Application class 
..

    ..  class:: small

        |loz| *Unit Test of Application class (44)*. Used by: test_unit.py (`1`_)


Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.


..  _`45`:
..  rubric:: Unit Test overheads: imports, etc. (45) =
..  parsed-literal::
    :class: code

    from \_\_future\_\_ import print\_function
    """Unit tests."""
    import pyweb
    import unittest
    import logging
    import io
    import string
    import os
    import time
    import re
    import argparse

..

    ..  class:: small

        |loz| *Unit Test overheads: imports, etc. (45)*. Used by: test_unit.py (`1`_)



..  _`46`:
..  rubric:: Unit Test main (46) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig( stream=sys.stdout, level= logging.WARN )
        unittest.main()

..

    ..  class:: small

        |loz| *Unit Test main (46)*. Used by: test_unit.py (`1`_)


We run the default ``unittest.main()`` to execute the entire suite of tests.

Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-	`Tests for Loading`_

-	`Tests for Tangling`_

-	`Tests for Weaving`_

There are a total of 11 test cases.

Tests for Loading
------------------

We need to be able to load a web from one or more source files.


..  _`47`:
..  rubric:: test_loader.py (47) =
..  parsed-literal::
    :class: code

    |srarr|\ Load Test overheads: imports, etc. (`53`_)
    |srarr|\ Load Test superclass to refactor common setup (`48`_)
    |srarr|\ Load Test error handling with a few common syntax errors (`49`_)
    |srarr|\ Load Test include processing with syntax errors (`51`_)
    |srarr|\ Load Test main program (`54`_)

..

    ..  class:: small

        |loz| *test_loader.py (47)*.


Parsing test cases have a common setup shown in this superclass.

By using some class-level variables ``text``,
``file_name``, we can simply provide a file-like
input object to the ``WebReader`` instance.


..  _`48`:
..  rubric:: Load Test superclass to refactor common setup (48) =
..  parsed-literal::
    :class: code

    
    class ParseTestcase( unittest.TestCase ):
        text= ""
        file\_name= ""
        def setUp( self ):
            source= io.StringIO( self.text )
            self.web= pyweb.Web()
            self.rdr= pyweb.WebReader()
            self.rdr.source( self.file\_name, source ).web( self.web )

..

    ..  class:: small

        |loz| *Load Test superclass to refactor common setup (48)*. Used by: test_loader.py (`47`_)


There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.


..  _`49`:
..  rubric:: Load Test error handling with a few common syntax errors (49) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 1 with correct and incorrect syntax (`50`_)
    
    class Test\_ParseErrors( ParseTestcase ):
        text= test1\_w
        file\_name= "test1.w"
        def test\_should\_raise\_syntax( self ):
            try:
                self.rdr.load()
                self.fail( "Should not parse" )
            except pyweb.Error as e:
                self.assertEquals( "At ('test1.w', 8): expected ('@{',), found '@o'", e.args[0] )

..

    ..  class:: small

        |loz| *Load Test error handling with a few common syntax errors (49)*. Used by: test_loader.py (`47`_)



..  _`50`:
..  rubric:: Sample Document 1 with correct and incorrect syntax (50) =
..  parsed-literal::
    :class: code

    
    test1\_w= """Some anonymous chunk
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

        |loz| *Sample Document 1 with correct and incorrect syntax (50)*. Used by: Load Test error handling with a few common syntax errors (`49`_); test_loader.py (`47`_)


All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

In order to handle the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing.


..  _`51`:
..  rubric:: Load Test include processing with syntax errors (51) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 8 and the file it includes (`52`_)
    
    class Test\_IncludeParseErrors( ParseTestcase ):
        text= test8\_w
        file\_name= "test8.w"
        def setUp( self ):
            with open('test8\_inc.tmp','w') as temp:
                temp.write( test8\_inc\_w )
            super( Test\_IncludeParseErrors, self ).setUp()
        def test\_should\_raise\_include\_syntax( self ):
            try:
                self.rdr.load()
                self.fail( "Should not parse" )
            except pyweb.Error as e:
                self.assertEquals( "At ('test8\_inc.tmp', 4): end of input, ('@{', '@[') not found", e.args[0] )
        def tearDown( self ):
            os.remove( 'test8\_inc.tmp' )
            super( Test\_IncludeParseErrors, self ).tearDown()

..

    ..  class:: small

        |loz| *Load Test include processing with syntax errors (51)*. Used by: test_loader.py (`47`_)


The sample document must reference the correct name that will
be given to the included document by ``setUp``.


..  _`52`:
..  rubric:: Sample Document 8 and the file it includes (52) =
..  parsed-literal::
    :class: code

    
    test8\_w= """Some anonymous chunk.
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

        |loz| *Sample Document 8 and the file it includes (52)*. Used by: Load Test include processing with syntax errors (`51`_); test_loader.py (`47`_)


<p>The overheads for a Python unittest.</p>


..  _`53`:
..  rubric:: Load Test overheads: imports, etc. (53) =
..  parsed-literal::
    :class: code

    from \_\_future\_\_ import print\_function
    """Loader and parsing tests."""
    import pyweb
    import unittest
    import logging
    import os
    import io

..

    ..  class:: small

        |loz| *Load Test overheads: imports, etc. (53)*. Used by: test_loader.py (`47`_)


A main program that configures logging and then runs the test.


..  _`54`:
..  rubric:: Load Test main program (54) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig( stream=sys.stdout, level= logging.WARN )
        unittest.main()

..

    ..  class:: small

        |loz| *Load Test main program (54)*. Used by: test_loader.py (`47`_)


Tests for Tangling
------------------

We need to be able to tangle a web.


..  _`55`:
..  rubric:: test_tangler.py (55) =
..  parsed-literal::
    :class: code

    |srarr|\ Tangle Test overheads: imports, etc. (`69`_)
    |srarr|\ Tangle Test superclass to refactor common setup (`56`_)
    |srarr|\ Tangle Test semantic error 2 (`57`_)
    |srarr|\ Tangle Test semantic error 3 (`59`_)
    |srarr|\ Tangle Test semantic error 4 (`61`_)
    |srarr|\ Tangle Test semantic error 5 (`63`_)
    |srarr|\ Tangle Test semantic error 6 (`65`_)
    |srarr|\ Tangle Test include error 7 (`67`_)
    |srarr|\ Tangle Test main program (`70`_)

..

    ..  class:: small

        |loz| *test_tangler.py (55)*.


Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.



..  _`56`:
..  rubric:: Tangle Test superclass to refactor common setup (56) =
..  parsed-literal::
    :class: code

    
    class TangleTestcase( unittest.TestCase ):
        text= ""
        file\_name= ""
        error= ""
        def setUp( self ):
            source= io.StringIO( self.text )
            self.web= pyweb.Web()
            self.rdr= pyweb.WebReader()
            self.rdr.source( self.file\_name, source ).web( self.web )
            self.tangler= pyweb.Tangler()
        def tangle\_and\_check\_exception( self, exception\_text ):
            try:
                self.rdr.load()
                self.web.tangle( self.tangler )
                self.web.createUsedBy()
                self.fail( "Should not tangle" )
            except pyweb.Error as e:
                self.assertEquals( exception\_text, e.args[0] )
        def tearDown( self ):
            name, \_ = os.path.splitext( self.file\_name )
            try:
                os.remove( name + ".tmp" )
            except OSError:
                pass

..

    ..  class:: small

        |loz| *Tangle Test superclass to refactor common setup (56)*. Used by: test_tangler.py (`55`_)



..  _`57`:
..  rubric:: Tangle Test semantic error 2 (57) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 2 (`58`_)
    
    class Test\_SemanticError\_2( TangleTestcase ):
        text= test2\_w
        file\_name= "test2.w"
        def test\_should\_raise\_undefined( self ):
            self.tangle\_and\_check\_exception( "Attempt to tangle an undefined Chunk, part2." )

..

    ..  class:: small

        |loz| *Tangle Test semantic error 2 (57)*. Used by: test_tangler.py (`55`_)



..  _`58`:
..  rubric:: Sample Document 2 (58) =
..  parsed-literal::
    :class: code

    
    test2\_w= """Some anonymous chunk
    @o test2.tmp
    @{@<part1@>
    @<part2@>
    @}@@
    @d part1 @{This is part 1.@}
    Okay, now for some errors: no part2!
    """

..

    ..  class:: small

        |loz| *Sample Document 2 (58)*. Used by: Tangle Test semantic error 2 (`57`_); test_tangler.py (`55`_)



..  _`59`:
..  rubric:: Tangle Test semantic error 3 (59) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 3 (`60`_)
    
    class Test\_SemanticError\_3( TangleTestcase ):
        text= test3\_w
        file\_name= "test3.w"
        def test\_should\_raise\_bad\_xref( self ):
            self.tangle\_and\_check\_exception( "Illegal tangling of a cross reference command." )

..

    ..  class:: small

        |loz| *Tangle Test semantic error 3 (59)*. Used by: test_tangler.py (`55`_)



..  _`60`:
..  rubric:: Sample Document 3 (60) =
..  parsed-literal::
    :class: code

    
    test3\_w= """Some anonymous chunk
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

        |loz| *Sample Document 3 (60)*. Used by: Tangle Test semantic error 3 (`59`_); test_tangler.py (`55`_)




..  _`61`:
..  rubric:: Tangle Test semantic error 4 (61) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 4 (`62`_)
    
    class Test\_SemanticError\_4( TangleTestcase ):
        text= test4\_w
        file\_name= "test4.w"
        def test\_should\_raise\_noFullName( self ):
            self.tangle\_and\_check\_exception( "No full name for 'part1...'" )

..

    ..  class:: small

        |loz| *Tangle Test semantic error 4 (61)*. Used by: test_tangler.py (`55`_)



..  _`62`:
..  rubric:: Sample Document 4 (62) =
..  parsed-literal::
    :class: code

    
    test4\_w= """Some anonymous chunk
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

        |loz| *Sample Document 4 (62)*. Used by: Tangle Test semantic error 4 (`61`_); test_tangler.py (`55`_)



..  _`63`:
..  rubric:: Tangle Test semantic error 5 (63) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 5 (`64`_)
    
    class Test\_SemanticError\_5( TangleTestcase ):
        text= test5\_w
        file\_name= "test5.w"
        def test\_should\_raise\_ambiguous( self ):
            self.tangle\_and\_check\_exception( "Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']" )

..

    ..  class:: small

        |loz| *Tangle Test semantic error 5 (63)*. Used by: test_tangler.py (`55`_)



..  _`64`:
..  rubric:: Sample Document 5 (64) =
..  parsed-literal::
    :class: code

    
    test5\_w= """
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

        |loz| *Sample Document 5 (64)*. Used by: Tangle Test semantic error 5 (`63`_); test_tangler.py (`55`_)



..  _`65`:
..  rubric:: Tangle Test semantic error 6 (65) =
..  parsed-literal::
    :class: code

     
    |srarr|\ Sample Document 6 (`66`_)
    
    class Test\_SemanticError\_6( TangleTestcase ):
        text= test6\_w
        file\_name= "test6.w"
        def test\_should\_warn( self ):
            self.rdr.load()
            self.web.tangle( self.tangler )
            self.web.createUsedBy()
            self.assertEquals( 1, len( self.web.no\_reference() ) )
            self.assertEquals( 1, len( self.web.multi\_reference() ) )
            self.assertEquals( 0, len( self.web.no\_definition() ) )

..

    ..  class:: small

        |loz| *Tangle Test semantic error 6 (65)*. Used by: test_tangler.py (`55`_)



..  _`66`:
..  rubric:: Sample Document 6 (66) =
..  parsed-literal::
    :class: code

    
    test6\_w= """Some anonymous chunk
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

        |loz| *Sample Document 6 (66)*. Used by: Tangle Test semantic error 6 (`65`_); test_tangler.py (`55`_)



..  _`67`:
..  rubric:: Tangle Test include error 7 (67) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 7 and it's included file (`68`_)
    
    class Test\_IncludeError\_7( TangleTestcase ):
        text= test7\_w
        file\_name= "test7.w"
        def setUp( self ):
            with open('test7\_inc.tmp','w') as temp:
                temp.write( test7\_inc\_w )
            super( Test\_IncludeError\_7, self ).setUp()
        def test\_should\_include( self ):
            self.rdr.load()
            self.web.tangle( self.tangler )
            self.web.createUsedBy()
            self.assertEquals( 5, len(self.web.chunkSeq) )
            self.assertEquals( test7\_inc\_w, self.web.chunkSeq[3].commands[0].text )
        def tearDown( self ):
            os.remove( 'test7\_inc.tmp' )
            super( Test\_IncludeError\_7, self ).tearDown()

..

    ..  class:: small

        |loz| *Tangle Test include error 7 (67)*. Used by: test_tangler.py (`55`_)



..  _`68`:
..  rubric:: Sample Document 7 and it's included file (68) =
..  parsed-literal::
    :class: code

    
    test7\_w= """
    Some anonymous chunk.
    @d title @[the title of this document, defined with @@[ and @@]@]
    A reference to @<title@>.
    @i test7\_inc.tmp
    A final anonymous chunk from test7.w
    """
    
    test7\_inc\_w= """The test7a.tmp chunk for test7.w
    """

..

    ..  class:: small

        |loz| *Sample Document 7 and it's included file (68)*. Used by: Tangle Test include error 7 (`67`_); test_tangler.py (`55`_)



..  _`69`:
..  rubric:: Tangle Test overheads: imports, etc. (69) =
..  parsed-literal::
    :class: code

    from \_\_future\_\_ import print\_function
    """Tangler tests exercise various semantic features."""
    import pyweb
    import unittest
    import logging
    import os
    import io

..

    ..  class:: small

        |loz| *Tangle Test overheads: imports, etc. (69)*. Used by: test_tangler.py (`55`_)



..  _`70`:
..  rubric:: Tangle Test main program (70) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig( stream=sys.stdout, level= logging.WARN )
        unittest.main()

..

    ..  class:: small

        |loz| *Tangle Test main program (70)*. Used by: test_tangler.py (`55`_)



Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.


..  _`71`:
..  rubric:: test_weaver.py (71) =
..  parsed-literal::
    :class: code

    |srarr|\ Weave Test overheads: imports, etc. (`78`_)
    |srarr|\ Weave Test superclass to refactor common setup (`72`_)
    |srarr|\ Weave Test references and definitions (`73`_)
    |srarr|\ Weave Test evaluation of expressions (`76`_)
    |srarr|\ Weave Test main program (`79`_)

..

    ..  class:: small

        |loz| *test_weaver.py (71)*.


Weaving test cases have a common setup shown in this superclass.


..  _`72`:
..  rubric:: Weave Test superclass to refactor common setup (72) =
..  parsed-literal::
    :class: code

    
    class WeaveTestcase( unittest.TestCase ):
        text= ""
        file\_name= ""
        error= ""
        def setUp( self ):
            source= io.StringIO( self.text )
            self.web= pyweb.Web()
            self.rdr= pyweb.WebReader()
            self.rdr.source( self.file\_name, source ).web( self.web )
            self.rdr.load()
        def tangle\_and\_check\_exception( self, exception\_text ):
            try:
                self.rdr.load()
                self.web.tangle( self.tangler )
                self.web.createUsedBy()
                self.fail( "Should not tangle" )
            except pyweb.Error as e:
                self.assertEquals( exception\_text, e.args[0] )
        def tearDown( self ):
            name, \_ = os.path.splitext( self.file\_name )
            try:
                os.remove( name + ".html" )
            except OSError:
                pass

..

    ..  class:: small

        |loz| *Weave Test superclass to refactor common setup (72)*. Used by: test_weaver.py (`71`_)



..  _`73`:
..  rubric:: Weave Test references and definitions (73) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 0 (`74`_)
    |srarr|\ Expected Output 0 (`75`_)
    
    class Test\_RefDefWeave( WeaveTestcase ):
        text= test0\_w
        file\_name = "test0.w"
        def test\_load\_should\_createChunks( self ):
            self.assertEquals( 3, len( self.web.chunkSeq ) )
        def test\_weave\_should\_createFile( self ):
            doc= pyweb.HTML()
            self.web.weave( doc )
            with open("test0.html","r") as source:
                actual= source.read()
            self.maxDiff= None
            self.assertEqual( test0\_expected, actual )
    

..

    ..  class:: small

        |loz| *Weave Test references and definitions (73)*. Used by: test_weaver.py (`71`_)



..  _`74`:
..  rubric:: Sample Document 0 (74) =
..  parsed-literal::
    :class: code

     
    test0\_w= """<html>
    <head>
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />
    </head>
    <body>
    @<some code@>
    
    @d some code 
    @{
    def fastExp( n, p ):
        r= 1
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

        |loz| *Sample Document 0 (74)*. Used by: Weave Test references and definitions (`73`_); test_weaver.py (`71`_)



..  _`75`:
..  rubric:: Expected Output 0 (75) =
..  parsed-literal::
    :class: code

    
    test0\_expected= """<html>
    <head>
        <link rel="StyleSheet" href="pyweb.css" type="text/css" />
    </head>
    <body>
    <a href="#pyweb1">&rarr;<em>some code</em> (1)</a>
    
    
        <a name="pyweb1"></a>
        <!--line number 10-->
        <p><em>some code</em> (1)&nbsp;=</p>
        <code><pre>
    
    def fastExp( n, p ):
        r= 1
        while p &gt; 0:
            if p%2 == 1: return n\*fastExp(n,p-1)
    	return n\*n\*fastExp(n,p/2)
    
    for i in range(24):
        fastExp(2,i)
    
        </pre></code>
        <p>&loz; <em>some code</em> (1).
        
        </p>
    
    </body>
    </html>
    """

..

    ..  class:: small

        |loz| *Expected Output 0 (75)*. Used by: Weave Test references and definitions (`73`_); test_weaver.py (`71`_)


Note that this really requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.


..  _`76`:
..  rubric:: Weave Test evaluation of expressions (76) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Sample Document 9 (`77`_)
    
    class TestEvaluations( WeaveTestcase ):
        text= test9\_w
        file\_name = "test9.w"
        def test\_should\_evaluate( self ):
            doc= pyweb.HTML()
            self.web.weave( doc )
            with open("test9.html","r") as source:
                actual= source.readlines()
            #print( actual )
            self.assertEquals( "An anonymous chunk.\\n", actual[0] )
            self.assertTrue( actual[1].startswith( "Time =" ) )
            self.assertEquals( "File = ('test9.w', 3)\\n", actual[2] )
            self.assertEquals( 'Version = 2.3\\n', actual[3] )
            self.assertEquals( 'CWD = %s\\n' % os.getcwd(), actual[4] )

..

    ..  class:: small

        |loz| *Weave Test evaluation of expressions (76)*. Used by: test_weaver.py (`71`_)



..  _`77`:
..  rubric:: Sample Document 9 (77) =
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

        |loz| *Sample Document 9 (77)*. Used by: Weave Test evaluation of expressions (`76`_); test_weaver.py (`71`_)



..  _`78`:
..  rubric:: Weave Test overheads: imports, etc. (78) =
..  parsed-literal::
    :class: code

    from \_\_future\_\_ import print\_function
    """Weaver tests exercise various weaving features."""
    import pyweb
    import unittest
    import logging
    import os
    import string
    import io

..

    ..  class:: small

        |loz| *Weave Test overheads: imports, etc. (78)*. Used by: test_weaver.py (`71`_)



..  _`79`:
..  rubric:: Weave Test main program (79) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig( stream=sys.stdout, level= logging.WARN )
        unittest.main()

..

    ..  class:: small

        |loz| *Weave Test main program (79)*. Used by: test_weaver.py (`71`_)



Combined Test Script
=====================

.. test/combined.w

The combined test script runs all tests in all test modules.


..  _`80`:
..  rubric:: test.py (80) =
..  parsed-literal::
    :class: code

    |srarr|\ Combined Test overheads, imports, etc. (`81`_)
    |srarr|\ Combined Test suite which imports all other test modules (`82`_)
    |srarr|\ Combined Test main script (`83`_)

..

    ..  class:: small

        |loz| *test.py (80)*.


The overheads import unittest and logging, because those are essential
infrastructure.  Additionally, each of the test modules is also imported.


..  _`81`:
..  rubric:: Combined Test overheads, imports, etc. (81) =
..  parsed-literal::
    :class: code

    """Combined tests."""
    import unittest
    import test\_loader
    import test\_tangler
    import test\_weaver
    import test\_unit
    import logging

..

    ..  class:: small

        |loz| *Combined Test overheads, imports, etc. (81)*. Used by: test.py (`80`_)


The test suite is built from each of the individual test modules.


..  _`82`:
..  rubric:: Combined Test suite which imports all other test modules (82) =
..  parsed-literal::
    :class: code

    
    def suite():
        s= unittest.TestSuite()
        for m in ( test\_loader, test\_tangler, test\_weaver, test\_unit ):
            s.addTests( unittest.defaultTestLoader.loadTestsFromModule( m ) )
        return s

..

    ..  class:: small

        |loz| *Combined Test suite which imports all other test modules (82)*. Used by: test.py (`80`_)


The main script initializes logging. Note that the typical setup
uses ``logging.CRITICAL`` to silence some expected warning messages.
For debugging, ``logging.WARN`` provides more information.

Once logging is running, it executes the ``unittest.TextTestRunner`` on the test suite.



..  _`83`:
..  rubric:: Combined Test main script (83) =
..  parsed-literal::
    :class: code

    
    if \_\_name\_\_ == "\_\_main\_\_":
        import sys
        logging.basicConfig( stream=sys.stdout, level=logging.CRITICAL )
        tr= unittest.TextTestRunner()
        result= tr.run( suite() )
        logging.shutdown()
        sys.exit( len(result.failures) + len(result.errors) )

..

    ..  class:: small

        |loz| *Combined Test main script (83)*. Used by: test.py (`80`_)


Additional Files
=================

To get the RST to look good, there are two additional files.

``docutils.conf`` defines two CSS files to use.
	The default CSS file may need to be customized.


..  _`84`:
..  rubric:: docutils.conf (84) =
..  parsed-literal::
    :class: code

    # docutils.conf
    
    [html4css1 writer]
    stylesheet-path: /Library/Frameworks/Python.framework/Versions/3.3/lib/python3.3/site-packages/docutils-0.11-py3.3.egg/docutils/writers/html4css1/html4css1.css,
        page-layout.css
    syntax-highlight: long

..

    ..  class:: small

        |loz| *docutils.conf (84)*.


``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. These are minor
tweaks to the default CSS.


..  _`85`:
..  rubric:: page-layout.css (85) =
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

        |loz| *page-layout.css (85)*.


Indices
=======

Files
-----


:docutils.conf:
    |srarr|\ (`84`_)
:page-layout.css:
    |srarr|\ (`85`_)
:test.py:
    |srarr|\ (`80`_)
:test_loader.py:
    |srarr|\ (`47`_)
:test_tangler.py:
    |srarr|\ (`55`_)
:test_unit.py:
    |srarr|\ (`1`_)
:test_weaver.py:
    |srarr|\ (`71`_)



Macros
------


:Combined Test main script:
    |srarr|\ (`83`_)
:Combined Test overheads, imports, etc.:
    |srarr|\ (`81`_)
:Combined Test suite which imports all other test modules:
    |srarr|\ (`82`_)
:Expected Output 0:
    |srarr|\ (`75`_)
:Load Test error handling with a few common syntax errors:
    |srarr|\ (`49`_)
:Load Test include processing with syntax errors:
    |srarr|\ (`51`_)
:Load Test main program:
    |srarr|\ (`54`_)
:Load Test overheads: imports, etc.:
    |srarr|\ (`53`_)
:Load Test superclass to refactor common setup:
    |srarr|\ (`48`_)
:Sample Document 0:
    |srarr|\ (`74`_)
:Sample Document 1 with correct and incorrect syntax:
    |srarr|\ (`50`_)
:Sample Document 2:
    |srarr|\ (`58`_)
:Sample Document 3:
    |srarr|\ (`60`_)
:Sample Document 4:
    |srarr|\ (`62`_)
:Sample Document 5:
    |srarr|\ (`64`_)
:Sample Document 6:
    |srarr|\ (`66`_)
:Sample Document 7 and it's included file:
    |srarr|\ (`68`_)
:Sample Document 8 and the file it includes:
    |srarr|\ (`52`_)
:Sample Document 9:
    |srarr|\ (`77`_)
:Tangle Test include error 7:
    |srarr|\ (`67`_)
:Tangle Test main program:
    |srarr|\ (`70`_)
:Tangle Test overheads: imports, etc.:
    |srarr|\ (`69`_)
:Tangle Test semantic error 2:
    |srarr|\ (`57`_)
:Tangle Test semantic error 3:
    |srarr|\ (`59`_)
:Tangle Test semantic error 4:
    |srarr|\ (`61`_)
:Tangle Test semantic error 5:
    |srarr|\ (`63`_)
:Tangle Test semantic error 6:
    |srarr|\ (`65`_)
:Tangle Test superclass to refactor common setup:
    |srarr|\ (`56`_)
:Unit Test Mock Chunk class:
    |srarr|\ (`4`_)
:Unit Test Web class chunk cross-reference:
    |srarr|\ (`35`_)
:Unit Test Web class construction methods:
    |srarr|\ (`33`_)
:Unit Test Web class name resolution methods:
    |srarr|\ (`34`_)
:Unit Test Web class tangle:
    |srarr|\ (`36`_)
:Unit Test Web class weave:
    |srarr|\ (`37`_)
:Unit Test main:
    |srarr|\ (`46`_)
:Unit Test of Action class hierarchy:
    |srarr|\ (`39`_)
:Unit Test of Application class:
    |srarr|\ (`44`_)
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
    |srarr|\ (`25`_)
:Unit Test of Command class hierarchy:
    |srarr|\ (`22`_)
:Unit Test of Command superclass:
    |srarr|\ (`23`_)
:Unit Test of Emitter Superclass:
    |srarr|\ (`3`_)
:Unit Test of Emitter class hierarchy:
    |srarr|\ (`2`_)
:Unit Test of FileXrefCommand class for an output file cross-reference:
    |srarr|\ (`27`_)
:Unit Test of HTML subclass of Emitter:
    |srarr|\ (`7`_)
:Unit Test of HTMLShort subclass of Emitter:
    |srarr|\ (`8`_)
:Unit Test of LaTeX subclass of Emitter:
    |srarr|\ (`6`_)
:Unit Test of MacroXrefCommand class for a named chunk cross-reference:
    |srarr|\ (`28`_)
:Unit Test of NamedChunk subclass:
    |srarr|\ (`19`_)
:Unit Test of NamedDocumentChunk subclass:
    |srarr|\ (`21`_)
:Unit Test of OutputChunk subclass:
    |srarr|\ (`20`_)
:Unit Test of Reference class hierarchy:
    |srarr|\ (`31`_)
:Unit Test of ReferenceCommand class for chunk references:
    |srarr|\ (`30`_)
:Unit Test of Tangler subclass of Emitter:
    |srarr|\ (`9`_)
:Unit Test of TanglerMake subclass of Emitter:
    |srarr|\ (`10`_)
:Unit Test of TextCommand class to contain a document text block:
    |srarr|\ (`24`_)
:Unit Test of UserIdXrefCommand class for a user identifier cross-reference:
    |srarr|\ (`29`_)
:Unit Test of Weaver subclass of Emitter:
    |srarr|\ (`5`_)
:Unit Test of Web class:
    |srarr|\ (`32`_)
:Unit Test of WebReader class:
    |srarr|\ (`38`_)
:Unit Test of XrefCommand superclass for all cross-reference commands:
    |srarr|\ (`26`_)
:Unit Test overheads: imports, etc.:
    |srarr|\ (`45`_)
:Unit test of Action Sequence class:
    |srarr|\ (`40`_)
:Unit test of LoadAction class:
    |srarr|\ (`43`_)
:Unit test of TangleAction class:
    |srarr|\ (`42`_)
:Unit test of WeaverAction class:
    |srarr|\ (`41`_)
:Weave Test evaluation of expressions:
    |srarr|\ (`76`_)
:Weave Test main program:
    |srarr|\ (`79`_)
:Weave Test overheads: imports, etc.:
    |srarr|\ (`78`_)
:Weave Test references and definitions:
    |srarr|\ (`73`_)
:Weave Test superclass to refactor common setup:
    |srarr|\ (`72`_)



User Identifiers
----------------

(None)


----------

..	class:: small


	Created by ../pyweb.py at Tue Mar 11 10:12:14 2014.

	pyweb.__version__ '2.3'.

	Source combined.w modified Fri Mar  7 09:51:12 2014.

	Working directory '/Users/slott/Documents/Projects/pyWeb-2.3/pyweb/test'.

