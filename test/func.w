<!-- test/func.w -->

<p>There are three broad areas of functional testing.</p>

<ul>
<li>Loading</li>
<li>Tanging</li>
<li>Weaving</li>
</ul>

<p>There are a total of 11 test cases.</p>

<h3>Tests for Loading</h3>

<p>We need to be able to load a web from one or more source files.</p>

@o test_loader.py 
@{@<Load Test overheads: imports, etc.@>
@<Load Test superclass to refactor common setup@>
@<Load Test error handling with a few common syntax errors@>
@<Load Test include processing with syntax errors@>
@<Load Test main program@>
@}

<p>Parsing test cases have a common setup shown in this superclass.</p>

<p>By using some class-level variables <span class="code">text</span>,
<span class="code">file_name</span>, we can simply provide a file-like
input object to the <span class="code">WebReader</span> instance.
</p>

@d Load Test superclass...
@{
class ParseTestcase( unittest.TestCase ):
    text= ""
    file_name= ""
    def setUp( self ):
        source= StringIO.StringIO( self.text )
        self.web= pyweb.Web( self.file_name )
        self.rdr= pyweb.WebReader()
        self.rdr.source( self.file_name, source ).web( self.web )
@}

<p>There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.
</p>

@d Load Test error handling...
@{
@<Sample Document 1 with correct and incorrect syntax@>

class Test_ParseErrors( ParseTestcase ):
    text= test1_w
    file_name= "test1.w"
    def test_should_raise_syntax( self ):
        try:
            self.rdr.load()
            self.fail( "Should not parse" )
        except pyweb.Error, e:
            self.assertEquals( "At ('test1.w', 8, 8): expected ('@@{',), found '@@o'", e.args[0] )
@}

@d Sample Document 1...
@{
test1_w= """Some anonymous chunk
@@o test1.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
Okay, now for an error.
@@o show how @@o commands work
@@{ @@{ @@] @@]
"""
@}

<p>All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.
</p>

<p>In order to handle the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing.
</p>

@d Load Test include...
@{
@<Sample Document 8 and the file it includes@>

class Test_IncludeParseErrors( ParseTestcase ):
    text= test8_w
    file_name= "test8.w"
    def setUp( self ):
        with open('test8_inc.tmp','w') as temp:
            temp.write( test8_inc_w )
        super( Test_IncludeParseErrors, self ).setUp()
    def test_should_raise_include_syntax( self ):
        try:
            self.rdr.load()
            self.fail( "Should not parse" )
        except pyweb.Error, e:
            self.assertEquals( "At ('test8_inc.tmp', 3, 4): end of input, ('@@{', '@@[') not found", e.args[0] )
    def tearDown( self ):
        os.remove( 'test8_inc.tmp' )
        super( Test_IncludeParseErrors, self ).tearDown()
@}

<p>The sample document must reference the correct name that will
be given to the included document by <span class="code">setUp</span>.
</p>

@d Sample Document 8...
@{
test8_w= """Some anonymous chunk.
@@d title @@[the title of this document, defined with @@@@[ and @@@@]@@]
A reference to @@<title@@>.
@@i test8_inc.tmp
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@@d yap
"""
@}

<p>The overheads for a Python unittest.</p>

@d Load Test overheads...
@{from __future__ import print_function
"""Loader and parsing tests."""
import pyweb
import unittest
import logging
import StringIO
import os
@}

<p>A main program that configures logging and then runs the test.</p>

@d Load Test main program...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()
@}

<h3>Tests for Tangling</h3>

<p>We need to be able to tangle a web.</p>

@o test_tangler.py 
@{@<Tangle Test overheads: imports, etc.@>
@<Tangle Test superclass to refactor common setup@>
@<Tangle Test semantic error 2@>
@<Tangle Test semantic error 3@>
@<Tangle Test semantic error 4@>
@<Tangle Test semantic error 5@>
@<Tangle Test semantic error 6@>
@<Tangle Test include error 7@>
@<Tangle Test main program@>
@}

<p>Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.
</p>

@d Tangle Test superclass...
@{
class TangleTestcase( unittest.TestCase ):
    text= ""
    file_name= ""
    error= ""
    def setUp( self ):
        source= StringIO.StringIO( self.text )
        self.web= pyweb.Web( self.file_name )
        self.rdr= pyweb.WebReader()
        self.rdr.source( self.file_name, source ).web( self.web )
        self.tangler= pyweb.Tangler()
    def tangle_and_check_exception( self, exception_text ):
        try:
            self.rdr.load()
            self.web.tangle( self.tangler )
            self.web.createUsedBy()
            self.fail( "Should not tangle" )
        except pyweb.Error, e:
            self.assertEquals( exception_text, e.args[0] )
    def tearDown( self ):
        name, _ = os.path.splitext( self.file_name )
        try:
            os.remove( name + ".tmp" )
        except OSError:
            pass
@}

@d Tangle Test semantic error 2... 
@{
@<Sample Document 2@>

class Test_SemanticError_2( TangleTestcase ):
    text= test2_w
    file_name= "test2.w"
    def test_should_raise_undefined( self ):
        self.tangle_and_check_exception( "Attempt to tangle an undefined Chunk, part2." )
@}

@d Sample Document 2... @{
test2_w= """Some anonymous chunk
@@o test2.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
Okay, now for some errors: no part2!
"""
@}

@d Tangle Test semantic error 3... 
@{
@<Sample Document 3@>

class Test_SemanticError_3( TangleTestcase ):
    text= test3_w
    file_name= "test3.w"
    def test_should_raise_bad_xref( self ):
        self.tangle_and_check_exception( "Illegal tangling of a cross reference command." )
@}

@d Sample Document 3... @{
test3_w= """Some anonymous chunk
@@o test3.tmp
@@{@@<part1@@>
@@<part2@@>
@@}@@@@
@@d part1 @@{This is part 1.@@}
@@d part2 @@{This is part 2, with an illegal: @@f.@@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""
@}


@d Tangle Test semantic error 4... 
@{
@<Sample Document 4@>

class Test_SemanticError_4( TangleTestcase ):
    text= test4_w
    file_name= "test4.w"
    def test_should_raise_noFullName( self ):
        self.tangle_and_check_exception( "No full name for 'part1...'" )
@}

@d Sample Document 4... @{
test4_w= """Some anonymous chunk
@@o test4.tmp
@@{@@<part1...@@>
@@<part2@@>
@@}@@@@
@@d part1... @@{This is part 1.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""
@}

@d Tangle Test semantic error 5... 
@{
@<Sample Document 5@>

class Test_SemanticError_5( TangleTestcase ):
    text= test5_w
    file_name= "test5.w"
    def test_should_raise_ambiguous( self ):
        self.tangle_and_check_exception( "Ambiguous abbreviation 'part1...', matches ['part1b', 'part1a']" )
@}

@d Sample Document 5... @{
test5_w= """
Some anonymous chunk
@@o test5.tmp
@@{@@<part1...@@>
@@<part2@@>
@@}@@@@
@@d part1a @@{This is part 1 a.@@}
@@d part1b @@{This is part 1 b.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some errors: part1... is ambiguous
"""
@}

@d Tangle Test semantic error 6... 
@{ 
@<Sample Document 6@>

class Test_SemanticError_6( TangleTestcase ):
    text= test6_w
    file_name= "test6.w"
    def test_should_warn( self ):
        self.rdr.load()
        self.web.tangle( self.tangler )
        self.web.createUsedBy()
        self.assertEquals( 1, len( self.web.no_reference() ) )
        self.assertEquals( 1, len( self.web.multi_reference() ) )
        self.assertEquals( 0, len( self.web.no_definition() ) )
@}

@d Sample Document 6... @{
test6_w= """Some anonymous chunk
@@o test6.tmp
@@{@@<part1...@@>
@@<part1a@@>
@@}@@@@
@@d part1a @@{This is part 1 a.@@}
@@d part2 @@{This is part 2.@@}
Okay, now for some warnings: 
- part1 has multiple references.
- part2 is unreferenced.
"""
@}

@d Tangle Test include error 7... 
@{
@<Sample Document 7 and it's included file@>

class Test_IncludeError_7( TangleTestcase ):
    text= test7_w
    file_name= "test7.w"
    def setUp( self ):
        with open('test7_inc.tmp','w') as temp:
            temp.write( test7_inc_w )
        super( Test_IncludeError_7, self ).setUp()
    def test_should_include( self ):
        self.rdr.load()
        self.web.tangle( self.tangler )
        self.web.createUsedBy()
        self.assertEquals( 5, len(self.web.chunkSeq) )
        self.assertEquals( test7_inc_w, self.web.chunkSeq[3].commands[0].text )
    def tearDown( self ):
        os.remove( 'test7_inc.tmp' )
        super( Test_IncludeError_7, self ).tearDown()
@}

@d Sample Document 7... @{
test7_w= """
Some anonymous chunk.
@@d title @@[the title of this document, defined with @@@@[ and @@@@]@@]
A reference to @@<title@@>.
@@i test7_inc.tmp
A final anonymous chunk from test7.w
"""

test7_inc_w= """The test7a.tmp chunk for test7.w
"""
@}

@d Tangle Test overheads...
@{from __future__ import print_function
"""Tangler tests exercise various semantic features."""
import pyweb
import unittest
import logging
import StringIO
import os
@}

@d Tangle Test main program...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()
@}


<h3>Tests for Weaving</h3>

<p>We need to be able to weave a document from one or more source files.</p>

@o test_weaver.py 
@{@<Weave Test overheads: imports, etc.@>
@<Weave Test superclass to refactor common setup@>
@<Weave Test references and definitions@>
@<Weave Test evaluation of expressions@>
@<Weave Test main program@>
@}

<p>Weaving test cases have a common setup shown in this superclass.</p>

@d Weave Test superclass... @{
class WeaveTestcase( unittest.TestCase ):
    text= ""
    file_name= ""
    error= ""
    def setUp( self ):
        source= StringIO.StringIO( self.text )
        self.web= pyweb.Web( self.file_name )
        self.rdr= pyweb.WebReader()
        self.rdr.source( self.file_name, source ).web( self.web )
        self.rdr.load()
    def tangle_and_check_exception( self, exception_text ):
        try:
            self.rdr.load()
            self.web.tangle( self.tangler )
            self.web.createUsedBy()
            self.fail( "Should not tangle" )
        except pyweb.Error, e:
            self.assertEquals( exception_text, e.args[0] )
    def tearDown( self ):
        name, _ = os.path.splitext( self.file_name )
        try:
            os.remove( name + ".html" )
        except OSError:
            pass
@}

@d Weave Test references... @{
@<Sample Document 0@>
@<Expected Output 0@>

class Test_RefDefWeave( WeaveTestcase ):
    text= test0_w
    file_name = "test0.w"
    def test_load_should_createChunks( self ):
        self.assertEquals( 3, len( self.web.chunkSeq ) )
    def test_weave_should_createFile( self ):
        doc= pyweb.HTML()
        self.web.weave( doc )
        with open("test0.html","r") as source:
            actual= source.read()
        m= difflib.SequenceMatcher( lambda x: x in string.whitespace, expected, actual )
        for tag, i1, i2, j1, j2 in m.get_opcodes():
            if tag == "equal": continue
            self.fail( "At %d %s: expected %r, actual %r" % ( j1, tag, repr(expected[i1:i2]), repr(actual[j1:j2]) ) )

@}

@d Sample Document 0... 
@{ 
test0_w= """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
@@<some code@@>

@@d some code 
@@{
def fastExp( n, p ):
    r= 1
    while p > 0:
        if p%2 == 1: return n*fastExp(n,p-1)
	return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)
@@}
</body>
</html>
"""
@}

@d Expected Output 0... @{
expected= """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
    <a href="#pyweb1">&rarr;<em>some code</em> (1)</a>


    <a name="pyweb1"></a>
    <!--line number 9-->
    <p><em>some code</em> (1)&nbsp;=</p>
    <pre><code>

def fastExp( n, p ):
    r= 1
    while p &gt; 0:
        if p%2 == 1: return n*fastExp(n,p-1)
	return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)

    </code></pre>
    <p>&loz; <em>some code</em> (1).
    
    </p>

</body>
</html>
"""
@}

@d Weave Test evaluation... @{
@<Sample Document 9@>

class TestEvaluations( WeaveTestcase ):
    text= test9_w
    file_name = "test9.w"
    def test_should_evaluate( self ):
        doc= pyweb.HTML()
        self.web.weave( doc )
        with open("test9.html","r") as source:
            actual= source.readlines()
        #print( actual )
        self.assertEquals( "An anonymous chunk.\n", actual[0] )
        self.assertTrue( actual[1].startswith( "Time =" ) )
        self.assertEquals( "File = ('test9.w', 3, 3)\n", actual[2] )
        self.assertEquals( 'Version = $Revision$\n', actual[3] )
        self.assertEquals( 'OS = %s\n' % os.name, actual[4] )
        self.assertEquals( 'CWD = %s\n' % os.getcwd(), actual[5] )
@}

@d Sample Document 9...
@{
test9_w= """An anonymous chunk.
Time = @@(time.asctime()@@)
File = @@(theLocation@@)
Version = @@(__version__@@)
OS = @@(os.name@@)
CWD = @@(os.getcwd()@@)
"""
@}

@d Weave Test overheads...
@{from __future__ import print_function
"""Weaver tests exercise various weaving features."""
import pyweb
import unittest
import logging
import StringIO
import os
import difflib
import string
@}

@d Weave Test main program...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()
@}
