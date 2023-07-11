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

This depends on Jinja2 templates. The Jinja components should be installed
when ``setup.py`` uses ``requirements.txt`` to install the required components.

Using
=====

**py-web-lp** supports two use cases, `Tangle Source Files`_ and `Weave Documentation`_.
These are often combined to both tangle and weave an application and it's documentation.
The work starts with creating a WEB file with documentation and code.

Create WEB File
----------------

See `The py-web-lp Markup Language`_ for more details on the language.
For a simple example, we'll use the following WEB file: ``examples/hw.w``.

..  parsed-literal::

    ###########
    Hello World
    ###########
    
    This file has a *small* example.
    
    @@d The Body Of The Script @@{
    print("Hello, World!")
    @@}
    
    The Python module includes a small script.
    
    @@o hw.py @@{
    @@<The Body...@@>
    @@}

This example has RST markup document, that includes some ``@@d`` and ``@@o`` chunks
to define code blocks. The ``@@d`` is the definition of a named chunk, ``The Body Of The Script``.
The ``@@o`` defines an output file to be tangled. This file has a reference to
the ``The Body Of The Script`` chunk.

When tangling, the code will be used to build the file(s) in the ``@@o`` chunk(s).
In this example, it will write the ``hw.py`` file by tangling the referenced chunk.

When weaving, the ``@@d`` and ``@@o`` chunks will have some additional RST markup inserted
into the document. The output file will have a name based on the source WEB document.
In this case it will be ``hw.rst``.


Tangle Source Files
-------------------

A user initiates this process when they have a complete ``.w`` file that contains 
a description of source files.  These source files are described with ``@@o`` commands
in the WEB file.

The use case is successful when the source files are produced.

The use case is a failure when the source files cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

A typical command to tangle (without weaving) is:

..  parsed-literal::

    python -m pyweb -xw examples/hw.w -o examples

The outputs will be defined by the ``@@o`` commands in the source.
The ``-o`` option writes the resulting tangled files to the named directory.

Weave Documentation
-------------------

A user initiates this process when they have a ``.w`` file that contains 
a description of a document to produce.  The document is described by the entire
WEB file. The default is to use ReSTructured Text (RST) markup.
The output file will have the ``.rst`` suffix. 

The use case is successful when the documentation file is produced.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

A typical command to weave (without tangling) is:

..  parsed-literal::

    python -m pyweb -xt examples/hw.w -o examples
    
The output will be named ``examples/hw.rst``. The ``-o`` option made sure the file
was written to the ``examples`` directory.

Running **py-web-lp** to Tangle and Weave
-------------------------------------------

Assuming that you have marked ``pyweb.py`` as executable,
you do the following:

..  code:: bash

    python -m pyweb examples/hw.w -o examples

This will tangle the ``@@o`` commands in ``examples/hw.w``
It will also weave the output, and create ``examples/hw.rst``.
This can be processed by docutils to create an HTML file.

Command Line Options
~~~~~~~~~~~~~~~~~~~~~

Currently, the following command line options are accepted.


:-v:
    Verbose logging. 
    
:-s:
    Silent operation.

:-c *x*:
    Change the command character from ``@@`` to ``*x*``.

:-w *weaver*:
    Choose a particular documentation weaver template. Currently the choices
    are ``rst``, ``tex``, and ``html``.

:-xw:
    Exclude weaving.  This does tangling of source program files only.

:-xt:
    Exclude tangling.  This does weaving of the document file only.

:-p *command*:
    Permit errors in the given list of commands.  The most common
    version is ``-pi`` to permit errors in locating an include file.
    This is done in the following scenario: pass 1 uses ``-xw -pi`` to exclude
    weaving and permit include-file errors; 
    the tangled program is run to create test results; pass 2 uses
    ``-xt`` to exclude tangling and include the test results.
    
:-o *directory*:
    The directory to which to write output files.

Bootstrapping
--------------

**py-web-lp** is written using **py-web-lp**. The distribution includes the original ``.w``
files as well as a ``.py`` module.

The bootstrap procedure is to run a "known good" ``pyweb`` to transform
a working copy into a new version of ``pyweb``. We provide the previous release in the ``bootstrap``
directory.

..  parsed-literal::

    python bootstrap/pyweb.py pyweb.w
    rst2html.py pyweb.rst pyweb.html
    
The resulting ``pyweb.html`` file is the updated documentation.
The ``pyweb.py`` is the updated candidate release of **py-web-lp**.

Similarly, the tests built from a ``.w`` files.

..  code:: bash

    python pyweb.py tests/pyweb_test.w -o tests
    PYTHONPATH=.. pytest
    rst2html.py tests/pyweb_test.rst tests/pyweb_test.html    

Dependencies
-------------

**py-web-lp** requires Python 3.10 or newer.

The following components are listed in the ``requirements.txt``
file. These can be loaded via

..  code:: bash
    
    python -m pip install -r requirements.txt
    
This lp uses `Jinja <https://palletsprojects.com/p/jinja/>`_ for template processing.

The `tomli <https://pypi.org/project/tomli/>`_ library is used to parse configuration files
for older Python that lack a ``tomllib`` in the standard library.

If you create RST output, you'll want to use either `docutils <https://docutils.sourceforge.io>`_ or `Sphinx <https://www.sphinx-doc.org/en/master/>`_ to translate
the RST to HTML or LaTeX or any of the other formats supported by docutils or Sphinx.
This is not a proper requirement to run the tool. It's a common
part of an overall document production tool chain.

The overview contains PlantUML diagrams.
See https://plantuml.com/ for more information.
The `PlantUML for Sphinx <https://github.com/sphinx-contrib/plantuml>`_ plug-in
can be used to render the diagrams automatically.

For development, additional components
like ``pytest``, ``tox``, and ``mypy`` are also used for development.

More Advanced Usage
===================

Here are two more advanced use cases.

Tangle, Test, and Weave with Test Results
-----------------------------------------

A user initiates this process when the final document should include test output 
from the source files created by the tangle operation. This is an extension to 
the example shown earlier.

..  parsed-literal::

    ###########
    Hello World
    ###########
    
    This file has a *small* example.
    
    @@d The Body Of The Script @@{
    print("Hello, World!")
    @@}
    
    The Python module includes a small script.
    
    @@o hw.py @@{
    @@<The Body...@@>
    @@}
       
    Example Output
    ==============
    
    @@i examples/hw_output.log 


The use case is successful when the documentation file is produced, including
current test output.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

The use case is a failure when the documentation file does not include current
test output.

The sequence is as follows:

..  parsed-literal::

    python -m pyweb -xw -pi examples/hw.w -o examples
    python examples/hw.py >examples/hw_output.log
    python -m pyweb -xt examples/hw.w -o examples
     
The first step uses ``-xw`` to excludes document weaving.
The ``-pi`` option will permits errors on the ``@@i`` command. 
This is necessary in the event that the log file does not yet exist. 

The second step runs the test, creating a log file.  

The third step weaves the final document, including the test output file.
The ``-xt`` option excludes tangling, since output file had already been produced.


Template Changes
----------------

The woven document is based -- primarily -- on the text in the source WEB file.
This is processed using a small set of Jinja2 macros to modify behavior.
To fine-tune the results, we can adjust the templates used by this application.

The easiest way to do this is to work with the ``weave.py`` script which shows
how to create a customized subclass of ``Weaver``. 
The `Handy Scripts and Other Files`_ section shows this script and how it's build
from a few ``pyweb`` components.
