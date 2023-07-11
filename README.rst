pyWebLP: In Python, Yet Another Literate Programming Tool

Literate programming is an attempt to reconcile the opposing needs
of clear presentation to people with the technical issues of 
creating code that will work with our current set of tools.

Presentation to people requires extensive and sophisticated typesetting
techniques.  Further, the "narrative arc" of a presentation may not 
follow the source code as layed out for the compiler.

**py-web-tool** is a literate programming tool based on Knuth's Web to combine the actions
of weaving a document with tangling source files.
It is independent of any particular document markup or source language.
Is uses a simple set of markup tags to define chunks of code and 
documentation.

The ``pyweb.w`` file is the source for the various ``pyweb`` module and script files.
The various source code files are created by applying a
tangle operation to the ``.w`` file.  The final documentation is created by
applying a weave operation to the ``.w`` file.

Installation
-------------

This requires Python 3.10. 

::

    python -m pip install py-web-lp
    
This will install the ``pyweb`` module and all of its dependencies.

Produce Documentation
---------------------

The supplied documentation uses RST markup; it requires docutils.

::

    python3 -m pip install docutils

::

	python3 -m pyweb src/pyweb.w -o src
	rst2html.py src/pyweb.rst src/pyweb.html

Authoring
---------

The ``pyweb.html`` document describes the markup used to define code chunks
and assemble those code chunks into a coherent document as well as working code.
You'll create a ``.w`` file with documentation and code.

If you're a JEdit user, the ``jedit`` directory can be used
to configure syntax highlighting that includes **py-web-lp** and RST.

Operation
---------

After installation and authoring, you can then run **py-web-lp** with the following
command

::

    python3 -m pyweb src/pyweb.w -o src 

This will create the various output files from the source ``.w`` file.

-   ``pyweb.rst`` is the final woven document. This can be run through docutils for publication.

-   ``pyweb.py``, ``tangle.py``, ``weave.py`` are the tangled code files.

All of the files are produced from a single source.

Testing
-------

The ``tests`` directory includes ``pyweb_test.w``, which will create a 
complete test suite.
You can create this with the following command

::

    python3 -m pyweb tests/pyweb_test.w -o tests 

This weaves a ``tests/pyweb_test.rst`` file. This can be run through docutils for publication.

This tangles several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py``, ``test_unit.py``, and ``test_scripts.py``.  

Use **pytest** to run all the tests.

Here's a typical sequence, used during development:

::

    python3 bootstrap/pyweb.py -xw src/pyweb.w -o src
    python3 src/pyweb.py tests/pyweb_test.w -o tests
    PYTHONPATH=${PWD}/src pytest
    rst2html.py tests/pyweb_test.rst tests/pyweb_test.html
    mypy --strict src

Note that a previous release, untouched, is saved in the project's ``bootstrap`` directory.
This is **not** changed during development, since **py-web-lp** is written with **py-web-lp**.
