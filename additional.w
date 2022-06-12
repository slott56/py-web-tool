..  py-web-tool/additional.w

Additional Files
================

Two aditional scripts, ``tangle.py`` and ``weave.py``, are provided as examples 
which an be customized.

The ``README`` and ``setup.py`` files are also an important part of the
distribution as are a ``.nojekyll`` and ``index.html`` that are part of
publishing from GitHub.

The ``.CSS`` file and ``.conf`` file for RST production are also provided here.

``tangle.py`` Script
---------------------

This script shows a simple version of Tangling.  This has a permitted 
error for '@@i' commands to allow an include file (for example test results)
to be omitted from the tangle operation.

Note the general flow of this top-level script.

1.	Create the logging context.

2.	Create the options. This hard-coded object is a stand-in for 
	parsing command-line options. 
	
3.	Create the web object.

4.	For each action (``LoadAction`` and ``TangleAction`` in this example)
	Set the web, set the options, execute the callable action, and write
	a summary.

@o tangle.py 
@{#!/usr/bin/env python3
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
            command='@@',
            permitList=['@@i'],
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
@}

``weave.py`` Script
---------------------

This script shows a simple version of Weaving.  This shows how
to define a customized set of templates for a different markup language.


A customized weaver generally has three parts.

@o weave.py
@{@<weave.py overheads for correct operation of a script@>

@<weave.py custom weaver definition to customize the Weaver being used@>

@<weaver.py processing: load and weave the document@>
@}

@d weave.py overheads...
@{#!/usr/bin/env python3
"""Sample weave.py script."""
import argparse
import logging
import string
from pathlib import Path
import pyweb
@}

@d weave.py custom weaver definition...
@{
class MyHTML(pyweb.HTML):
    """HTML formatting templates."""
    extension = ".html"
    
    cb_template = string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
    <pre><code>\n""")

    ce_template = string.Template("""
    </code></pre>
    <p>&loz; <em>${fullName}</em> (${seq}).
    ${references}
    </p>\n""")
        
    fb_template = string.Template("""<a name="pyweb${seq}"></a>
    <!--line number ${lineNumber}-->
    <p>``${fullName}`` (${seq})&nbsp;${concat}</p>
    <pre><code>\n""") # Prevent indent
        
    fe_template = string.Template( """</code></pre>
    <p>&loz; ``${fullName}`` (${seq}).
    ${references}
    </p>\n""")
        
    ref_item_template = string.Template(
    '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    
    ref_template = string.Template('  Used by ${refList}.' )
            
    refto_name_template = string.Template(
    '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    refto_seq_template = string.Template('<a href="#pyweb${seq}">(${seq})</a>')
 
    xref_head_template = string.Template("<dl>\n")
    xref_foot_template = string.Template("</dl>\n")
    xref_item_template = string.Template("<dt>${fullName}</dt><dd>${refList}</dd>\n")
    
    name_def_template = string.Template('<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>')
    name_ref_template = string.Template('<a href="#pyweb${seq}">${seq}</a>')
@}

@d weaver.py processing...
@{
def main(source: Path) -> None:
    with pyweb.Logger(pyweb.log_config):
        logger = logging.getLogger(__file__)
    
        options = argparse.Namespace(
            source_path=source,
            output=source.parent,
            verbosity=logging.INFO,
            command='@@',
            permitList=[],
            tangler_line_numbers=False,
            reference_style=pyweb.SimpleReference(),
            theWeaver=MyHTML(),
            webReader=pyweb.WebReader(),
        )
    
        w = pyweb.Web() 
    
        for action in pyweb.LoadAction(), pyweb.WeaveAction():
            action.web = w
            action.options = options
            action()
            logger.info(action.summary())

if __name__ == "__main__":
    main(Path("examples/test_rst.w"))
@}

The ``setup.py``, ``requirements-dev.txt`` and ``MANIFEST.in`` files
---------------------------------------------------------------------

In order to support a pleasant installation, the ``setup.py`` file is helpful.

@o setup.py 
@{#!/usr/bin/env python3
"""Setup for pyWeb."""

from distutils.core import setup

setup(name='py-web-tool',
      version='3.1',
      description='py-web-tool 3.1: Yet Another Literate Programming Tool',
      author='S. Lott',
      author_email='slott56@@gmail.com',
      url='http://slott-softwarearchitect.blogspot.com/',
      py_modules=['pyweb'],
      classifiers=[
          'Intended Audience :: Developers',
          'Topic :: Documentation',
          'Topic :: Software Development :: Documentation', 
          'Topic :: Text Processing :: Markup',
      ]
   )
@}

In order build a source distribution kit the ``python3 setup.py sdist`` requires a
``MANIFEST``.  We can either list all files or provide a   ``MANIFEST.in``
that specifies additional rules.
We use a simple inclusion to augment the default manifest rules.

@o MANIFEST.in
@{include *.w *.css *.html *.conf *.rst
include tests/*.w tests/*.css tests/*.html tests/*.conf tests/*.py
include jedit/*.xml
@}

In order to install dependencies, the following file is also used.

@o requirements-dev.txt
@{
docutils==0.18.1
tox==3.25.0
mypy==0.910
pytest==7.1.2
@}

The ``README`` file
---------------------

Here's the README file.

@o README
@{pyWeb 3.1: In Python, Yet Another Literate Programming Tool

Literate programming is an attempt to reconcile the opposing needs
of clear presentation to people with the technical issues of 
creating code that will work with our current set of tools.

Presentation to people requires extensive and sophisticated typesetting
techniques.  Further, the "narrative arc" of a presentation may not 
follow the source code as layed out for the compiler.

pyWeb is a literate programming tool based on Knuth's Web to combine the actions
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

First, downnload the distribution kit from PyPI.

::

    python3 setup.py install

This will install the ``pyweb`` module, and the ``weave`` and ``tangle`` applications.

Produce Documentation
---------------------

The supplied documentation uses RST markup; it requires docutils.

::

    python3 -m pip install docutils

::

	python3 -m pyweb pyweb.w
	rst2html.py pyweb.rst pyweb.html

Authoring
---------

The ``pyweb.html`` document describes the markup used to define code chunks
and assemble those code chunks into a coherent document as well as working code.

If you're a JEdit user, the ``jedit`` directory can be used
to configure syntax highlighting that includes **py-web-tool** and RST.

Operation
---------

After installation and authoring, you can then run **py-web-tool** with

::

    python3 -m pyweb pyweb.w 

This will create the various output files from the source .w file.

-   ``pyweb.html`` is the final woven document.

-   ``pyweb.py``, ``tangle.py``, ``weave.py``, ``README``, ``setup.py`` and ``MANIFEST.in`` 
	``.nojekyll`` and ``index.html`` are tangled output files.

Testing
-------

The ``tests`` directory includes ``pyweb_test.w``, which will create a 
complete test suite.

This weaves a ``pyweb_test.html`` file.

This tangles several test modules:  ``test.py``, ``test_tangler.py``, ``test_weaver.py``,
``test_loader.py``, ``test_unit.py``, and ``test_scripts.py``.  
Use **pytest** to run all the tests

::

	python3 bootstrap/pyweb.py -xw pyweb.w 
	python3 pyweb.py tests/pyweb_test.w -o tests
	PYTHONPATH=${PWD} pytest
	rst2html.py tests/pyweb_test.rst tests/pyweb_test.html
    mypy --strict pyweb.py weave.py tangle.py


@}

The HTML Support Files
----------------------

To get the RST to look good, there are some additional files.

``docutils.conf`` defines the CSS files to use.
The default CSS file (stylesheet-path) may need to be customized for your
installation of docutils.

@o docutils.conf
@{# docutils.conf

[html4css1 writer]
stylesheet-path: /Users/slott/miniconda3/envs/pywebtool/lib/python3.10/site-packages/docutils/writers/html4css1/html4css1.css,
    page-layout.css
syntax-highlight: long
@}

``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. 

@o page-layout.css
@{/* Page layout tweaks */
div.document { width: 7in; }
.small { font-size: smaller; }
.code
{
	color: #101080;
	display: block;
	border-color: black;
	border-width: thin;
	border-style: solid;
	background-color: #E0FFFF;
	/*#99FFFF*/
	padding: 0 0 0 1%;
	margin: 0 6% 0 6%;
	text-align: left;
	font-size: smaller;
}
@}

Yes, this creates a (nearly) empty file for use by GitHub. There's a small
bug in ``NamedChunk.tangle()`` that prevents handling zero-length text.

@o .nojekyll
@{

@}

Here's an ``index.html`` to redirect GitHub to the ``pyweb.html`` file.

@o index.html
@{<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="0;url=pyweb.html" />
    <title>Redirect</title>
  </head>
  <body>
    <p>Sorry, you should have been redirected <a href="pyweb.html">pyweb.html</a>.</p>
  </body>
</html>
@}


Tox and Makefile
----------------

It's simpler to have a ``Makefile`` to automate testing, particularly when making changes
to **py-web-tool**. 

Note that there are tabs in this file. We bootstrap the next version from the 3.0 version.

@o Makefile
@{# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE_PYLPWEB = pyweb.w intro.w overview.w impl.w tests.w additional.w todo.w done.w
TEST_PYLPWEB = tests/pyweb_test.w tests/intro.w tests/unit.w tests/func.w tests/scripts.w	

.PHONY : test doc build

# Note the bootstrapping new version from version 3.0 as baseline.
# Handy to keep this *outside* the project's Git repository.
PYLPWEB_BOOTSTRAP=bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) -xw pyweb.w 
	python3 pyweb.py tests/pyweb_test.w -o tests
	PYTHONPATH=${PWD} pytest
	python3 pyweb.py tests/pyweb_test.w -xt -o tests
	rst2html.py tests/pyweb_test.rst tests/pyweb_test.html
	mypy --strict --show-error-codes pyweb.py tangle.py weave.py

doc : pyweb.html

build : pyweb.py tangle.py weave.py pyweb.html

pyweb.py pyweb.rst : $(SOURCE_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) pyweb.w 
         
tests/pyweb_test.rst : pyweb.py $(TEST_PYLPWEB)
	python3 pyweb.py tests/pyweb_test.w -o tests

pyweb.html : pyweb.rst
	rst2html.py $< $@

tests/pyweb_test.html : tests/pyweb_test.rst
	rst2html.py $< $@

@}

**TODO:** Finish ``tox.ini`` or ``pyproject.toml``.

@o pyproject.toml
@{
[build-system]
requires = ["setuptools >= 61.2.0", "wheel >= 0.37.1", "pytest == 7.1.2", "mypy == 0.910"]
build-backend = "setuptools.build_meta"

[tool.tox]
legacy_tox_ini = """
[tox]
envlist = py310

[testenv]
deps = 
    pytest == 7.1.2
    mypy == 0.910
setenv = 
    PYLPWEB_BOOTSTRAP = bootstrap/pyweb.py
    PYTHONPATH = {toxinidir}
commands_pre = 
    python3 {env:PYLPWEB_BOOTSTRAP} pyweb.w
    python3 pyweb.py -o tests tests/pyweb_test.w 
commands = 
    pytest
	mypy --strict --show-error-codes pyweb.py tangle.py weave.py
"""
@}
