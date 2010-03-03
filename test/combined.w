<!-- combined.w -->

<p>The combined test script runs all tests in all test modules.</p>

@o test.py 
@{@<Combined Test overheads, imports, etc.@>
@<Combined Test suite which imports all other test modules@>
@<Combined Test main script@>
@}

<p>The overheads import unittest and logging, because those are essential
infrastructure.  Additionally, each of the test modules is also imported.
</p>

@d Combined Test overheads...
@{from __future__ import print_function
"""Combined tests."""
import unittest
import test_loader
import test_tangler
import test_weaver
import test_unit
import logging
@}

<p>The test suite is built from each of the individual test modules.</p>

@d Combined Test suite...
@{
def suite():
    s= unittest.TestSuite()
    for m in ( test_loader, test_tangler, test_weaver, test_unit ):
        s.addTests( unittest.defaultTestLoader.loadTestsFromModule( m ) )
    return s
@}

<p>The main script initializes logging and then executes the 
<span class="code">unittest.TextTestRunner</span> on the test suite.
</p>

@d Combined Test main...
@{
if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level=logging.CRITICAL )
    tr= unittest.TextTestRunner()
    result= tr.run( suite() )
    logging.shutdown()
    sys.exit( len(result.failures) + len(result.errors) )
@}