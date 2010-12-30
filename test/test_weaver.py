from __future__ import print_function
"""Weaver tests exercise various weaving features."""
import pyweb
import unittest
import logging
import StringIO
import os
import difflib
import string


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


 
test0_w= """<html>
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
        if p%2 == 1: return n*fastExp(n,p-1)
	return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)
@}
</body>
</html>
"""


expected= """<html>
<head>
    <link rel="StyleSheet" href="pyweb.css" type="text/css" />
</head>
<body>
    <a href="#pyweb1">&rarr;<em>some code</em> (1)</a>


    <a name="pyweb1"></a>
    <!--line number 9-->
    <p><em>some code</em> (1)&nbsp;=</p>
    <code><pre>

def fastExp( n, p ):
    r= 1
    while p &gt; 0:
        if p%2 == 1: return n*fastExp(n,p-1)
	return n*n*fastExp(n,p/2)

for i in range(24):
    fastExp(2,i)

    </pre></code>
    <p>&loz; <em>some code</em> (1).
    
    </p>

</body>
</html>
"""


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




test9_w= """An anonymous chunk.
Time = @(time.asctime()@)
File = @(theLocation@)
Version = @(__version__@)
OS = @(os.name@)
CWD = @(os.getcwd()@)
"""


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


if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()

