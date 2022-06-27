#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
import pyweb



class MyHTML(pyweb.Weaver):
    pass



def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            weaver="html",
            command='@',
            permitList=[],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theWeaver=MyHTML(),
            webReader=pyweb.WebReader(),
        )
        
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action(options)
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))

