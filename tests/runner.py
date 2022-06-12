"""Combined tests."""
import argparse
import unittest
import test_loader
import test_tangler
import test_weaver
import test_unit
import logging
import sys



def suite():
    s = unittest.TestSuite()
    for m in (test_loader, test_tangler, test_weaver, test_unit):
        s.addTests(unittest.defaultTestLoader.loadTestsFromModule(m))
    return s


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

