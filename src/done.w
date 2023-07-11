..    py-web-tool/src/done.w

Change Log
===========


Changes for 3.2

-   Rename to ``py-web-lp`` to limit collisions in PyPI.

-   Replaced ``toml`` with ``tomli`` or built-in ``tomllib``.

-   Fiddle with ``pyproject.toml`` and ``tox.ini`` to eliminate ``setup.py``.

-   Replaced home-brewed ``OptionParser`` with ``argparse.ArgumentParser``.
    Now the options for ``@@d`` and ``@@o`` can be *much* more flexible.

-   Added the transitive path of references as a Chunk property.
    Removes ``SimpleReference`` and ``TransitiveReference`` classes,
    and the associated "reference_style" attribute of a ``Weaver``.
    To show transitive references, a revised ``code_end`` template is required.

-   Added a TOML-based configuration file with a ``[logging]`` section. 

-   Incorporated Sphinx and PlantUML into the documentation.
    Support continues for ```rst2html.py``. It's used for test documentaion. 
    See https://github.com/slott56/py-web-tool/wiki/PlantUML-support-for-RST-%5BCompleted%5D

-   Replaced weaving process with Jinja templates. 
    See https://github.com/slott56/py-web-tool/wiki/Jinja-Template-for-Weaving-%5BCompleted%5D

-   Dramatic redesign to Class, Chunk, and Command class hierarchies.

-   Dramatic redesign to Emitters to switch to using Jinja templates.
    By stepping away from the ``string.Template``,
    we can incorporate list-processing ``{% for %}...{% endfor %}`` construct that 
    pushes some processing into the template.

-   Removed ``'\N{LOZENGE}'`` (borrowed from Interscript) and use the ``'\N{END OF PROOF}'`` symbol instead.

-   Created a better ``weave.py`` example that shows how to incorporate bootstrap CSS into HTML overrides.
    This also requires designing a more easily extended ``Weaver`` class.
    
Changes for 3.1

-   Change to Python 3.10 as the supported version.

-   Add type hints, f-strings, ``pathlib``, ``abc.ABC``.

-   Replace some complex ``elif`` blocks with ``match`` statements.

-   Use **pytest** as a test runner.

-   Add a ``Makefile``, ``pyproject.toml``, ``requirements.txt`` and ``requirements-dev.txt``.

-   Implement ``-o dir`` option to write output to a directory of choice, simplifying **tox** setup.

-   Add ``bootstrap`` directory with a snapshot of a previous working release to simplify development.

-   Add Test cases for ``weave.py`` and ``tangle.py``

-   Replace hand-build mock classes with ``unittest.mock.Mock`` objects

-   Separate the projec into ``src``, ``tests``, ``examples``. Cleanup ``Makefile``, ``pyproject.toml``, etc.

-   Silence the ERROR-level logging during testing.

-   Clean up the examples

Changes for 3.0

-   Move to GitHub

Changes for 2.3.2.

-   Fix all ``{:s}`` format strings to be ``{!s}``.

Changes for 2.3.1.

-   Cleanup some stray comment errors.

-   Revise the documentation structure and organization.

-   Tweak the error messages.

Changes for 2.3.

-   Changed to Python 3.3 -- Fixed ``except``, ``raise`` and ``%``.

-   Removed ``doWrite()`` and simplified ``doOpen()`` and ``doClose()``.

-   Cleaned up RST output to be much nicer.

-   Change the baseline ``pyweb.w`` file to be RST instead of HTML.
    docutils required to produce HTML from the woven output.

-   Removed the unconstrained ``eval()`` function. Provided a slim set of globals.
    ``os`` is really just ``os.path``.
    Any ``os.getcwd()`` can be changed to ``os.path.realpath('.')``.
    ``time`` was removed and replaced with ``datetime``.
    Any ``time.asctime()`` must be ``datetime.datetime.now().ctime()``.

-   Resolved a small dispute between ``weaveReferenceTo()`` (wrong) and ``tangle()`` (right).
    for NamedChunks. The issue was one of failure to understand the differences
    between weaving -- where indentation is localized -- and tangling -- where indentation
    must be tracked globally. Root cause was a huge problem in ``codeBlock()`` which didn't
    really weave properly at all. 

-   Fix the tokenizer and parsing. Stop using a complex tokenizer and use a simpler
    iterator over the tokens with ``StopIteration`` exception handling.
    
-   Replace ``optparse`` with ``argparse``. 

-   Get rid of the global ``logger`` variable.

-   Remove the filename as part of ``Web()`` initial creation. 
    A basename comes from the initial ``.w`` file loaded by the ``WebReader``. 

-   Fix the Action class hierarchy so that composite actions are simpler. 

-   Change references to return ``Chunk`` objects, not ``(name,sequence)`` pairs.

-   Make the ref list separator in ``Weaver reference summary...`` a proper template
    feature, not a hidden punctuation mark in the code.
    
-   Configure ``Web.reference_style`` properly so that simple or transitive references
    can be included as a command-line option. The default is Simple.
    Add the ``-r`` option so that ``-rt`` includes transitive references.
    
-   Reduce the "hard-coded" punctuation. For example, the ``", "`` in 
    ``@@d Web weave...`` ``weaveChunk()``.  This was moved into a template.

-   Add an ``__enter__()`` and ``__exit__()`` to make an ``Emitter``
    into a proper Context Manager that can be used with a ``with`` statement.
    
-   Add the ``-n`` option to include tangler line numbers if the ``@@o`` includes
    the comment characters.

-   Cleanup the ``TanglerMake`` unit tests to remove the ``sleep()`` 
    used to assure that the timestamps really are different.
    
-   Cleanup the syntax for adding a comment template to ``@@o``. Use ``-start`` and ``-end``
    before the filename.
    
-   Cleanup the syntax for noindent named chunks. Use ``-noindent`` before the chunk name.
    This creates a distinct ``NamedChunk_Noindent`` instance that handles indentation
    differently from other ``Chunk`` subclasses.
    
-   Cleanup the ``TangleAction`` summary.

-   Clean up the error messages. Raising an exception seems
    heavy-handed and confusing.  Count errors instead. 


Changes since version 1.4

-   Removed home-brewed logger.

-   Replaced ``getopt`` with ``optparse``.

-   Replaced LaTeX markup.

-   Corrected significant problems in cross-reference resolution.

-   Replaced all HTML and LaTeX-specific features with a much simpler template
    engine which applies a template to a Chunk.  The Templates are separate
    configuration items.  The big issue with templates are conditional processing
    and the use of loops to handle multiple references in a transitive closure.
    While it's nice to depend on Jinja2, it's also nice to be totally stand-alone.
    Sigh.  Choices include the no-logic ``string.Template`` in the standard library
    or the ``Templite+`` Recipe 576663.

-   Looked at SCons API.  Renamed "Operation" to "Action"; renamed "perform" to "__call__".  
    Consider having "__call__" which does logging, then call "execute".  

-   Eliminated the EmitterFactory; replace this with simple injection of
    the proper template configuration.  

-   Removed the ``@@O`` command; it was essentially a variant template for LaTeX.

-   Disentangled indentation and quoting in the codeBlock.
    Indentation rules vary between Tangling and Weaving.
    Quoting is unique to a woven codeBlock.  Fix ``referenceTo()``  to write
    indented without code quoting.

-   Offer a basic RST template.
    Note that colorizing may be easier to handle with an RST template.
    The weaving markup template degenerates 
    to ``..   parsed-literal::`` and indent.  By doing this,
    the RST output from *pyWeb* can be run through DocUtils ``rst2html.py``
    or perhaps *Sphix* to create final HTML. The hard part is the indent.

-   Tweaked (but didn't fix) ReferenceCommand tangle and all setIndent/clrIndent operations. 
    Only a ReferenceCommand actually cares about indentation.  And that indentation
    is totally based on the "context" plus the text in the Command immediate in front
    of the ReferenceCommand.
