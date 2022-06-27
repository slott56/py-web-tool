
import logging.handlers
from pathlib import Path
from textwrap import dedent
from typing import ClassVar

"""Loader and parsing tests."""
import io
import logging
import os
from pathlib import Path
import string
import sys
import types
import unittest

import pyweb



class ParseTestcase(unittest.TestCase):
    text: ClassVar[str]
    file_path: ClassVar[Path]
    
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
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
    file_path = Path("test1.w")
    def test_error_should_count_1(self) -> None:
        with self.assertLogs('WebReader', level='WARN') as log_capture:
            chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(3, self.rdr.errors)
        self.assertEqual(log_capture.output, 
            [
                "ERROR:WebReader:At ('test1.w', 8): expected {'@{'}, found '@o'",
                "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)",
                "ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)"
            ]
        )




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
    file_path = Path("test8.w")
    def setUp(self) -> None:
        super().setUp()
        Path('test8_inc.tmp').write_text(test8_inc_w)
    def test_error_should_count_2(self) -> None:
        with self.assertLogs('WebReader', level='WARN') as log_capture:
            chunks = self.rdr.load(self.file_path, self.source)
        self.assertEqual(1, self.rdr.errors)
        self.assertEqual(log_capture.output,
            [
                "ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, {'@{', '@['} not found", 
                "ERROR:WebReader:Errors in included file 'test8_inc.tmp', output is incomplete."
            ]
        ) 
    def tearDown(self) -> None:
        super().tearDown()
        Path('test8_inc.tmp').unlink()



if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

