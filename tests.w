..  pyweb/test.w

Unit Tests
===========

The ``test`` directory includes ``pyweb_test.w``, which will create a 
complete test suite.

This source will weaves a ``pyweb_test.html`` file. See file:test/pyweb_test.html

This source will tangle several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py`` and ``test_unit.py``.  Running the ``test.py`` module will include and
execute all 78 tests.

Here's a script that works out well for running this without disturbing the development
environment. The ``PYTHONPATH`` setting is essential to support importing ``pyweb``.

..	parsed-literal::

	cd test
	python ../pyweb.py pyweb_test.w
	PYTHONPATH=.. python test.py

Note that the last line really does set an environment variable and run 
a program on a single line.
