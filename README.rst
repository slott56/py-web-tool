pyWeb 3.0: In Python, Yet Another Literate Programming Tool

Literate programming is an attempt to reconcile the opposing needs
of clear presentation to people with the technical issues of 
creating code that will work with our current set of tools.

Presentation to people requires extensive and sophisticated typesetting
techniques.  Further, the "narrative arc" of a presentation may not 
follow the source code as layed out for the compiler.

pyWeb is a literate programming tool based on Knuth's Web_ to combine the actions
of weaving a document with tangling source files.
It is independent of any particular document markup or source language.
Is uses a simple set of markup tags to define chunks of code and 
documentation.

The ``pyweb.w`` file is the source for the various pyweb module and script files.
The various source code files are created by applying a
tangle operation to the ``.w`` file.  The final documentation is created by
applying a weave operation to the ``.w`` file.

Installation
-------------

::

    python3 setup.py install

This will install the pyweb module.

Document production
--------------------

The supplied documentation uses RST markup and requires docutils.

::

	python3 -m pyweb pyweb.w
	rst2html.py pyweb.rst pyweb.html

Authoring
---------

The pyweb document describes the simple markup used to define code chunks
and assemble those code chunks into a coherent document as well as working code.

If you're a JEdit user, the ``jedit`` directory can be used
to configure syntax highlighting that includes PyWeb and RST.

Operation
---------

You can then run pyweb with

::

    python3 -m pyweb pyweb.w 

This will create the various output files from the source .w file.

-   ``pyweb.html`` is the final woven document.

-   ``pyweb.py``, ``tangle.py``, ``weave.py``, ``README``, ``setup.py`` and ``MANIFEST.in`` 
	``.nojekyll`` and ``index.html`` are tangled output files.

Testing
-------

The test directory includes ``pyweb_test.w``, which will create a 
complete test suite.

This weaves a ``pyweb_test.html`` file.

This tangles several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py`` and ``test_unit.py``.  Running the ``test.py`` module will include and
execute all tests.

::

	cd test
	python3 -m pyweb pyweb_test.w
	PYTHONPATH=.. python3 test.py
	rst2html.py pyweb_test.rst pyweb_test.html


.. _Web: https://doi.org/10.1093/comjnl/27.2.97
