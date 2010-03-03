from __future__ import print_function
"""Combined tests."""
import unittest
import test_loader
import test_tangler
import test_weaver
import test_unit
import logging


def suite():
    s= unittest.TestSuite()
    for m in ( test_loader, test_tangler, test_weaver, test_unit ):
        s.addTests( unittest.defaultTestLoader.loadTestsFromModule( m ) )
    return s


if __name__ == "__main__":
    import sys
    logging.basicConfig( stream=sys.stdout, level=logging.CRITICAL )
    tr= unittest.TextTestRunner()
    result= tr.run( suite() )
    logging.shutdown()
    sys.exit( len(result.failures) + len(result.errors) )

