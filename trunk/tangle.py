#!/usr/bin/env python
"""Sample tangle.py script."""
import pyweb
import logging, sys

logging.basicConfig( stream=sys.stderr, level=logging.INFO )
logger= logging.getLogger(__file__)

w= pyweb.Web( "pyweb.w" ) # The web we'll work on.

permitList= ['@i']
commandChar= '@'
load= pyweb.LoadAction()
load.webReader= pyweb.WebReader( command=commandChar, permit=permitList )
load.webReader.web( w ).source( "pyweb.w" )
load.web= w
load()
logger.info( load.summary() )

tangle= pyweb.TangleAction()
tangle.theTangler= pyweb.TanglerMake()
tangle.web= w
tangle()
logger.info( tangle.summary() )
