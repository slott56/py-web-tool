.. py-web-tool/src/usage.w

Installing
==========

This requires Python 3.10.

This is not (currently) hosted in PyPI. Instead of installing it with PIP,
clone the GitHub repository or download the distribution kit.

After downloading, install pyweb "manually" using the provided ``setup.py``.

::

    python setup.py install
    
This will install the ``pyweb`` module.

This depends on 

Using
=====

**py-web-tool** supports two use cases, `Tangle Source Files`_ and `Weave Documentation`_.
These are often combined to both tangle and weave an application and it's documentation.

Tangle Source Files
-------------------

A user initiates this process when they have a complete ``.w`` file that contains 
a description of source files.  These source files are described with ``@@o`` commands
in the ``.w`` file.

The use case is successful when the source files are produced.

Outside this use case, the user will debug those source files, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the source files cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

A typical command to tangle (without weaving) is:

..  parsed-literal::

    python -m pyweb -xw *theFile*.w

The outputs will be defined by the ``@@o`` commands in the source.

Weave Documentation
-------------------

A user initiates this process when they have a ``.w`` file that contains 
a description of a document to produce.  The document is described by the entire
``.w`` file. The default is to use ReSTructured Text (RST) markup.
The output file will have the ``.rst`` suffix. 

The use case is successful when the documentation file is produced.

Outside this use case, the user will edit the documentation file, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

A typical command to weave (without tangling) is:

..  parsed-literal::

    python -m pyweb -xt *theFile*\ .w
    
The output will be the *theFile*\ ``.rst``.

Tangle, Test, and Weave with Test Results
-----------------------------------------

A user initiates this process when they have a ``.w`` file that contains 
a description of a document to produce.  The document is described by the entire
``.w`` file.  Further, their final document should include test output 
from the source files created by the tangle operation.

The use case is successful when the documentation file is produced, including
current test output.

Outside this use case, the user will edit the documentation file, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

The use case is a failure when the documentation file does not include current
test output.

The sequence is as follows:

..  parsed-literal::

    python -m pyweb -xw -pi *theFile*\ .w
    pytest >\ *aLog*
    python -m pyweb -xt *theFile*\ .w
     
The first step excludes weaving and permits errors on the ``@@i`` command.  The ``-pi`` option
is necessary in the event that the log file does not yet exist.  The second step 
runs the test, creating a log file.  The third step weaves the final document,
including the test output.

Running **py-web-tool** to Tangle and Weave
-------------------------------------------

Assuming that you have marked ``pyweb.py`` as executable,
you do the following:

..  parsed-literal::

    python -m pyweb *theFile*\ .w

This will tangle the ``@@o`` commands in each *theFile*.
It will also weave the output, and create *theFile*.rst.

Command Line Options
~~~~~~~~~~~~~~~~~~~~~

Currently, the following command line options are accepted.


:-v:
    Verbose logging. 
    
:-s:
    Silent operation.

:-c\ *x*:
    Change the command character from ``@@`` to ``*x*``.

:-w\ *weaver*:
    Choose a particular documentation weaver template. Currently the choices
    are RST and HTML.

:-xw:
    Exclude weaving.  This does tangling of source program files only.

:-xt:
    Exclude tangling.  This does weaving of the document file only.

:-p\ *command*:
    Permit errors in the given list of commands.  The most common
    version is ``-pi`` to permit errors in locating an include file.
    This is done in the following scenario: pass 1 uses ``-xw -pi`` to exclude
    weaving and permit include-file errors; 
    the tangled program is run to create test results; pass 2 uses
    ``-xt`` to exclude tangling and include the test results.
    
:-o\ *directory*:
    The directory to which to write output files.

Bootstrapping
--------------

**py-web-tool** is written using **py-web-tool**. The distribution includes the original ``.w``
files as well as a ``.py`` module.

The bootstrap procedure is to run a "known good" ``pyweb`` to transform
a working copy into a new version of ``pyweb``. We provide the previous release in the ``bootstrap``
directory.

..  parsed-literal::

    python bootstrap/pyweb.py pyweb.w
    rst2html.py pyweb.rst pyweb.html
    
The resulting ``pyweb.html`` file is the updated documentation.
The ``pyweb.py`` is the updated candidate release of **py-web-tool**.

Similarly, the tests built from a ``.w`` files.

..  parsed-literal::

    python pyweb.py tests/pyweb_test.w -o tests
    PYTHONPATH=.. pytest
    rst2html.py tests/pyweb_test.rst tests/pyweb_test.html    

Dependencies
-------------

**py-web-tool** requires Python 3.10 or newer.

If you create RST output, you'll want to use ``docutils`` to translate
the RST to HTML or LaTeX or any of the other formats supported by docutils.

Tools like ``pytest`` and ``tox`` are also used for development.
