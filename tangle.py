#!/usr/bin/env python3
"""Sample tangle.py script."""
import pyweb
import logging
import argparse
		
with pyweb.Logger( pyweb.log_config ):
	logger= logging.getLogger(__file__)

	options = argparse.Namespace(
		webFileName= "pyweb.w",
		verbosity= logging.INFO,
		command= '@',
		permitList= ['@i'],
		tangler_line_numbers= False,
		reference_style = pyweb.SimpleReference(),
		theTangler= pyweb.TanglerMake(),
		webReader= pyweb.WebReader(),
		)

	w= pyweb.Web() 
	
	for action in LoadAction(), TangleAction():
		action.web= w
		action.options= options
		action()
		logger.info( action.summary() )

