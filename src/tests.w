..  py-web-tool/src/test.w

Unit Tests
===========

The ``tests`` directory includes ``pyweb_test.w``, which will create a 
complete test suite.

This source will weaves a ``pyweb_test.html`` file. See `tests/pyweb_test.html <tests/pyweb_test.html>`_.

This source will tangle several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py``, ``test_unit.py``, and ``test_scripts.py``.  

Use **pytest** to discover and run all 80+ test cases.

Here's a script that works out well for running this without disturbing the development
environment. The ``PYTHONPATH`` setting is essential to support importing ``pyweb``.

..	parsed-literal::

	python pyweb.py -o tests tests/pyweb_test.w
	PYTHONPATH=$(PWD) pytest

Note that the last line sets an environment variable and runs
the ``pytest`` tool on a single line.
