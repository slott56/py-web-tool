from __future__ import print_function
"""Loader and parsing tests."""
import pyweb
import unittest
import logging
import StringIO
import os


class ParseTestcase( unittest.TestCase ):
    text= ""
    file_name= ""
    def setUp( self ):
        source= StringIO.StringIO( self.text )
        self.web= pyweb.Web( self.file_name )
        self.rdr= pyweb.WebReader()
        self.rdr.source( self.file_name, source ).web( self.web )



test1_w= """Some anonymous chunk
@o test1.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
Okay, now for an error.
@o show how @o commands work
@{ @{ @] @]
"""


class Test_ParseErrors( ParseTestcase ):
    text= test1_w
    file_name= "test1.w"
    def test_should_raise_syntax( self ):
        try:
            self.rdr.load()
            self.fail( "Should not parse" )
        except pyweb.Error, e:
            self.assertEquals( "At ('test1.w', 8, 8): expected ('@{',), found '@o'", e.args[0] )



test8_w= """Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test8_inc.tmp
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@d yap
"""


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
            self.assertEquals( "At ('test8_inc.tmp', 3, 4): end of input, ('@{', '@[') not found", e.args[0] )
    def tearDown( self ):
        os.remove( 'test8_inc.tmp' )
        super( Test_IncludeParseErrors, self ).tearDown()


if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level= logging.WARN )
    unittest.main()

