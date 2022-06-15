
"""Tangler tests exercise various semantic features."""
import io
import logging
import os
from pathlib import Path
from typing import ClassVar
import unittest

import pyweb


class TangleTestcase(unittest.TestCase):
    text: ClassVar[str]
    error: ClassVar[str]
    file_path: ClassVar[Path]
    
    def setUp(self) -> None:
        self.source = io.StringIO(self.text)
        self.web = pyweb.Web()
        self.rdr = pyweb.WebReader()
        self.tangler = pyweb.Tangler()
        
    def tangle_and_check_exception(self, exception_text: str) -> None:
        try:
            self.rdr.load(self.web, self.file_path, self.source)
            self.web.tangle(self.tangler)
            self.web.createUsedBy()
            self.fail("Should not tangle")
        except pyweb.Error as e:
            self.assertEqual(exception_text, e.args[0])
            
    def tearDown(self) -> None:
        try:
            self.file_path.with_suffix(".tmp").unlink()
        except FileNotFoundError:
            pass  # If the test fails, nothing to remove...



test2_w = """Some anonymous chunk
@o test2.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
Okay, now for some errors: no part2!
"""


class Test_SemanticError_2(TangleTestcase):
    text = test2_w
    file_path = Path("test2.w")
    def test_should_raise_undefined(self) -> None:
        self.tangle_and_check_exception("Attempt to tangle an undefined Chunk, part2.")



test3_w = """Some anonymous chunk
@o test3.tmp
@{@<part1@>
@<part2@>
@}@@
@d part1 @{This is part 1.@}
@d part2 @{This is part 2, with an illegal: @f.@}
Okay, now for some errors: attempt to tangle a cross-reference!
"""


class Test_SemanticError_3(TangleTestcase):
    text = test3_w
    file_path = Path("test3.w")
    def test_should_raise_bad_xref(self) -> None:
        self.tangle_and_check_exception("Illegal tangling of a cross reference command.")



test4_w = """Some anonymous chunk
@o test4.tmp
@{@<part1...@>
@<part2@>
@}@@
@d part1... @{This is part 1.@}
@d part2 @{This is part 2.@}
Okay, now for some errors: attempt to weave but no full name for part1....
"""


class Test_SemanticError_4(TangleTestcase):
    text = test4_w
    file_path = Path("test4.w")
    def test_should_raise_noFullName(self) -> None:
        self.tangle_and_check_exception("No full name for 'part1...'")



test5_w = """
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


class Test_SemanticError_5(TangleTestcase):
    text = test5_w
    file_path = Path("test5.w")
    def test_should_raise_ambiguous(self) -> None:
        self.tangle_and_check_exception("Ambiguous abbreviation 'part1...', matches ['part1a', 'part1b']")

 

test6_w = """Some anonymous chunk
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


class Test_SemanticError_6(TangleTestcase):
    text = test6_w
    file_path = Path("test6.w")
    def test_should_warn(self) -> None:
        self.rdr.load(self.web, self.file_path, self.source)
        self.web.tangle(self.tangler)
        self.web.createUsedBy()
        self.assertEqual(1, len(self.web.no_reference()))
        self.assertEqual(1, len(self.web.multi_reference()))
        self.assertEqual(0, len(self.web.no_definition()))



test7_w = """
Some anonymous chunk.
@d title @[the title of this document, defined with @@[ and @@]@]
A reference to @<title@>.
@i test7_inc.tmp
A final anonymous chunk from test7.w
"""

test7_inc_w = """The test7a.tmp chunk for test7.w
"""


class Test_IncludeError_7(TangleTestcase):
    text = test7_w
    file_path = Path("test7.w")
    def setUp(self) -> None:
        Path('test7_inc.tmp').write_text(test7_inc_w)
        super().setUp()
    def test_should_include(self) -> None:
        self.rdr.load(self.web, self.file_path, self.source)
        self.web.tangle(self.tangler)
        self.web.createUsedBy()
        self.assertEqual(5, len(self.web.chunkSeq))
        self.assertEqual(test7_inc_w, self.web.chunkSeq[3].commands[0].text)
    def tearDown(self) -> None:
        Path('test7_inc.tmp').unlink()
        super().tearDown()


if __name__ == "__main__":
    import sys
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    unittest.main()

