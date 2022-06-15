#!/usr/bin/env python3
"""Sample tangle.py script."""
import argparse
import logging
from pathlib import Path
import pyweb

def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            command='@',
            permitList=['@i'],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theTangler=pyweb.TanglerMake(),
            webReader=pyweb.WebReader(),
        )
    
        w = pyweb.Web() 
        
        for action in pyweb.LoadAction(), pyweb.TangleAction():
            action.web = w
            action.options = options
            action()
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))
