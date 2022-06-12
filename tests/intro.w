Introduction
============

..	test/intro.w 

There are two levels of testing in this document.

-	`Unit Testing`_

-	`Functional Testing`_

Other testing, like performance or security, is possible.
But for this application, not very interesting.

This doument builds a complete test suite, ``test.py``.

..	parsed-literal::

	MacBookPro-SLott:test slott$ python3.3 ../pyweb.py pyweb_test.w
	INFO:Application:Setting root log level to 'INFO'
	INFO:Application:Setting command character to '@@'
	INFO:Application:Weaver RST
	INFO:Application:load, tangle and weave 'pyweb_test.w'
	INFO:LoadAction:Starting Load
	INFO:WebReader:Including 'intro.w'
	WARNING:WebReader:Unknown @@-command in input: "@@'"
	INFO:WebReader:Including 'unit.w'
	INFO:WebReader:Including 'func.w'
	INFO:WebReader:Including 'combined.w'
	INFO:TangleAction:Starting Tangle
	INFO:TanglerMake:Tangling 'test_unit.py'
	INFO:TanglerMake:No change to 'test_unit.py'
	INFO:TanglerMake:Tangling 'test_loader.py'
	INFO:TanglerMake:No change to 'test_loader.py'
	INFO:TanglerMake:Tangling 'test.py'
	INFO:TanglerMake:No change to 'test.py'
	INFO:TanglerMake:Tangling 'page-layout.css'
	INFO:TanglerMake:No change to 'page-layout.css'
	INFO:TanglerMake:Tangling 'docutils.conf'
	INFO:TanglerMake:No change to 'docutils.conf'
	INFO:TanglerMake:Tangling 'test_tangler.py'
	INFO:TanglerMake:No change to 'test_tangler.py'
	INFO:TanglerMake:Tangling 'test_weaver.py'
	INFO:TanglerMake:No change to 'test_weaver.py'
	INFO:WeaveAction:Starting Weave
	INFO:RST:Weaving 'pyweb_test.rst'
	INFO:RST:Wrote 3173 lines to 'pyweb_test.rst'
	INFO:WeaveAction:Finished Normally
	INFO:Application:Load 1911 lines from 5 files in 0.05 sec., Tangle 138 lines in 0.03 sec., Weave 3173 lines in 0.02 sec.
	MacBookPro-SLott:test slott$ PYTHONPATH=.. python3.3 test.py
	ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, ('@@{', '@@[') not found
	ERROR:WebReader:Errors in included file test8_inc.tmp, output is incomplete.
	.ERROR:WebReader:At ('test1.w', 8): expected ('@@{',), found '@@o'
	ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)
	ERROR:WebReader:Extra '@@{' (possibly missing chunk name) near ('test1.w', 9)
	.............................................................................
	----------------------------------------------------------------------
	Ran 78 tests in 0.025s

	OK
	MacBookPro-SLott:test slott$ rst2html.py pyweb_test.rst pyweb_test.html
