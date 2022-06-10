Combined Test Runner
=====================

.. test/runner.w

This is a small runner that executes all tests in all test modules.
Instead of test discovery as done by **pytest** and others,
this defines a test suite "the hard way" with an explicit list of modules.

@o runner.py 
@{@<Combined Test overheads, imports, etc.@>
@<Combined Test suite which imports all other test modules@>
@<Combined Test command line options@>
@<Combined Test main script@>
@}

The overheads import unittest and logging, because those are essential
infrastructure.  Additionally, each of the test modules is also imported.

@d Combined Test overheads...
@{"""Combined tests."""
import argparse
import unittest
import test_loader
import test_tangler
import test_weaver
import test_unit
import logging
import sys

@}

The test suite is built from each of the individual test modules.

@d Combined Test suite...
@{
def suite():
    s = unittest.TestSuite()
    for m in (test_loader, test_tangler, test_weaver, test_unit):
        s.addTests(unittest.defaultTestLoader.loadTestsFromModule(m))
    return s
@}

In order to debug failing tests, we accept some command-line
parameters to the combined testing script.

@d Combined Test command line options...
@{
def get_options(argv: list[str] = sys.argv[1:]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", dest="verbosity", action="store_const", const=logging.INFO)
    parser.add_argument("-d", "--debug", dest="verbosity", action="store_const", const=logging.DEBUG)
    parser.add_argument("-l", "--logger", dest="logger", action="store", help="comma-separated list")
    defaults = argparse.Namespace(
        verbosity=logging.CRITICAL,
        logger=""
    )
    config = parser.parse_args(argv, namespace=defaults)
    return config
@}

This means we can use ``-dlWebReader`` to debug the Web Reader.
We can use ``-d -lWebReader,TanglerMake`` to debug both
the WebReader class and the TanglerMake class. Not all classes have named loggers.
Logger names include ``Emitter``, 
``indent.Emitter``, 
``Chunk``, 
``Command``, 
``Reference``, 
``Web``, 
``WebReader``, 
``Action``, and
``Application``.
As well as subclasses of Emitter, Chunk, Command, and Action.

The main script initializes logging. Note that the typical setup
uses ``logging.CRITICAL`` to silence some expected warning messages.
For debugging, ``logging.WARN`` provides more information.

Once logging is running, it executes the ``unittest.TextTestRunner`` on the test suite.


@d Combined Test main...
@{
if __name__ == "__main__":
    options = get_options()
    logging.basicConfig(stream=sys.stderr, level=options.verbosity)
    logger = logging.getLogger("test")
    for logger_name in (n.strip() for n in options.logger.split(',')):
        l = logging.getLogger(logger_name)
        l.setLevel(options.verbosity)
        logger.info(f"Setting {l}")
        
    tr = unittest.TextTestRunner()
    result = tr.run(suite())
    logging.shutdown()
    sys.exit(len(result.failures) + len(result.errors))
@}
