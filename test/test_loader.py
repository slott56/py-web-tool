
import logging.handlers

"""Loader and parsing tests."""
import pyweb
import unittest
import logging
import os
import io
import types


class ParseTestcase(unittest.TestCase):
    text = ""
    file_name = ""
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.web = pyweb.Web()
        self.rdr = pyweb.WebReader()



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


class Test_ParseErrors(ParseTestcase):
    text = test1_w
    file_name = "test1.w"
    def setUp(self) -> None:
        super().setUp()
        self.logger = logging.getLogger("WebReader")
        self.buffer = logging.handlers.BufferingHandler(12)
        self.buffer.setLevel(logging.WARN)
        self.logger.addHandler(self.buffer)
        self.logger.setLevel(logging.WARN)
    def test_error_should_count_1(self) -> None:
        self.rdr.load(self.web, self.file_name, self.source)
        self.assertEqual(3, self.rdr.errors)
        messages = [r.message for r in self.buffer.buffer]
        self.assertEqual( 
            ["At ('test1.w', 8): expected ('@{',), found '@o'", 
            "Extra '@{' (possibly missing chunk name) near ('test1.w', 9)", 
            "Extra '@{' (possibly missing chunk name) near ('test1.w', 9)"],
            messages
        )
    def tearDown(self) -> None:
        self.logger.setLevel(logging.CRITICAL)
        self.logger.removeHandler(self.buffer)
        super().tearDown()
        



test8_w = """Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test8_inc.tmp
A final anonymous chunk from test8.w
"""

test8_inc_w="""A chunk from test8a.w
And now for an error - incorrect syntax in an included file!
@d yap
"""


class Test_IncludeParseErrors(ParseTestcase):
    text = test8_w
    file_name = "test8.w"
    def setUp(self) -> None:
        with open('test8_inc.tmp','w') as temp:
            temp.write(test8_inc_w)
        super().setUp()
        self.logger = logging.getLogger("WebReader")
        self.buffer = logging.handlers.BufferingHandler(12)
        self.buffer.setLevel(logging.WARN)
        self.logger.addHandler(self.buffer)
        self.logger.setLevel(logging.WARN)
    def test_error_should_count_2(self) -> None:
        self.rdr.load(self.web, self.file_name, self.source)
        self.assertEqual(1, self.rdr.errors)
        messages = [r.message for r in self.buffer.buffer]
        self.assertEqual( 
            ["At ('test8_inc.tmp', 4): end of input, ('@{', '@[') not found", 
            "Errors in included file 'test8_inc.tmp', output is incomplete."],
            messages
        )
    def tearDown(self) -> None:
        self.logger.setLevel(logging.CRITICAL)
        self.logger.removeHandler(self.buffer)
        os.remove('test8_inc.tmp')
        super().tearDown()


if __name__ == "__main__":
    import sys
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

