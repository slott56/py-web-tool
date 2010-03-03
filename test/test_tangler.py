from __future__ import print_function
"""Tangler tests exercise various semantic features."""
import pyweb
import unittest
import logging
import StringIO
import os


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



test2_w= """Some anonymous chunk
@o test2.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
Okay, now for some errors: no part2!
"""


class Test_SemanticError_2( TangleTestcase ):
    text= test2_w
    file_name= "test2.w"
    def test_should_raise_undefined( self ):
        self.tangle_and_check_exception( "Attempt to tangle an undefined Chunk, part2." )



test3_w= """Some anonymous chunk
@o test3.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
@d part2 @{This is part 2, with an illegal: @f.@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""


class Test_SemanticError_3( TangleTestcase ):
    text= test3_w
    file_name= "test3.w"
    def test_should_raise_bad_xref( self ):
        self.tangle_and_check_exception( "Illegal tangling of a cross reference command." )



test4_w= """Some anonymous chunk
@o test4.tmp
@{@<part1...@>
@<part2@>
@}@@
@d part1... @{This is part 1.@}
@d part2 @{This is part 2.@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""


class Test_SemanticError_4( TangleTestcase ):
    text= test4_w
    file_name= "test4.w"
    def test_should_raise_noFullName( self ):
        self.tangle_and_check_exception( "No full name for 'part1...'" )



test5_w= """
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


class Test_SemanticError_5( TangleTestcase ):
    text= test5_w
    file_name= "test5.w"
    def test_should_raise_ambiguous( self ):
        self.tangle_and_check_exception( "Ambiguous abbreviation 'part1...', matches ['part1b', 'part1a']" )

 

test6_w= """Some anonymous chunk
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



test7_w= """
Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test7_inc.tmp
A final anonymous chunk from test7.w
"""

test7_inc_w= """The test7a.tmp chunk for test7.w
"""


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


if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()

