##############################
pyWeb Literate Programming 3.2
##############################

=================================================
Yet Another Literate Programming Tool
=================================================

..	include:: <isoamsa.txt>
..	include:: <isopub.txt>

..	contents::


..  py-web-tool/src/intro.w

Introduction
============

Literate programming was pioneered by Knuth as a method for
developing readable, understandable presentations of programs.
These would present a program in a literate fashion for people
to read and understand; this would be in parallel with presentation as source text
for a compiler to process and both would be generated from a common source file.

One intent is to synchronize the program source with the
documentation about that source.  If the program and the documentation
have a common origin, then the traditional gaps between intent 
(expressed in the documentation) and action (expressed in the
working program) are significantly reduced.

**py-web-tool** is a literate programming tool that combines the actions
of *weaving* a document with *tangling* source files.
It is independent of any source language.
While is designed to work with RST document markup, it should be amenable to any other
flavor of markup.
It uses a small set of markup tags to define chunks of code and 
documentation.

Background
-----------

The following is an almost verbatim quote from Briggs' *nuweb* documentation, 
and provides an apt summary of Literate Programming.

    In 1984, Knuth introduced the idea of *literate programming* and
    described a pair of tools to support the practise (Donald E. Knuth, 
    "Literate Programming", *The Computer Journal* 27 (1984), no. 2, 97-111.)
    His approach was to combine Pascal code with T\ :sub:`e`\ X documentation to
    produce a new language, ``WEB``, that offered programmers a superior
    approach to programming. He wrote several programs in ``WEB``,
    including ``weave`` and ``tangle``, the programs used to support
    literate programming.
    The idea was that a programmer wrote one document, the web file, that
    combined documentation written in T\ :sub:`e`\ X (Donald E. Knuth, 
    T\ :sub:`e`\ X book, Computers and Typesetting, 1986) with code (written in Pascal).

    Running ``tangle`` on the web file would produce a complete
    Pascal program, ready for compilation by an ordinary Pascal compiler.
    The primary function of ``tangle`` is to allow the programmer to
    present elements of the program in any desired order, regardless of
    the restrictions imposed by the programming language. Thus, the
    programmer is free to present his program in a top-down fashion,
    bottom-up fashion, or whatever seems best in terms of promoting
    understanding and maintenance.

    Running ``weave`` on the web file would produce a  T\ :sub:`e`\ X file, ready
    to be processed by  T\ :sub:`e`\ X. The resulting document included a variety of
    automatically generated indices and cross-references that made it much
    easier to navigate the code. Additionally, all of the code sections
    were automatically prettyprinted, resulting in a quite impressive
    document. 

    Knuth also wrote the programs for T\ :sub:`e`\ X and ``METAFONT``
    entirely in ``WEB``, eventually publishing them in book
    form. These are probably the
    largest programs ever published in a readable form.


Other Tools
------------

Numerous tools have been developed based on Knuth's initial
work.  A relatively complete survey is available at sites
like `Literate Programming <http://www.literateprogramming.com>`_,
and the OASIS
`XML Cover Pages: Literate Programming with SGML and XML <http://www.oasis-open.org/cover/xmlLitProg.html>`_.

The immediate predecessors to this **py-web-tool** tool are 
`FunnelWeb <http://www.ross.net/funnelweb>`_,
`noweb <http://www.eecs.harvard.edu/~nr/noweb/>`_ and 
`nuweb <http://sourceforge.net/projects/nuweb/>`_.  The ideas lifted from these other
tools created the foundation for **py-web-tool**.

There are several Python-oriented literate programming tools.  
These include 
`LEO <http://personalpages.tds.net/~edream/front.html">`_,
`interscript <http://interscript.sourceforge.net/>`_,
`lpy <http://www.danbala.com/python/lpy/>`_,
`py2html <http://www.egenix.com/files/python/SoftwareDescriptions.html#py2html.py>`_,
`PyLit-3 <https://github.com/slott56/PyLit-3>`_

The *FunnelWeb* tool is independent of any programming language
and only mildly dependent on T\ :sub:`e`\ X.
It has 19 commands, many of which duplicate features of HTML or 
L\ :sub:`a`\ T\ :sub:`e`\ X.

The *noweb* tool was written by Norman Ramsey.
This tool uses a sophisticated multi-processing framework, via Unix
pipes, to permit flexible manipulation of the source file to tangle
and weave the programming language and documentation markup files.

The *nuweb* Simple Literate Programming Tool was developed by
Preston Briggs (preston@tera.com).  His work was supported by ARPA,
through ONR grant N00014-91-J-1989.  It is written
in C, and very focused on producing L\ :sub:`a`\ T\ :sub:`e`\ X documents.  It can 
produce HTML, but this is clearly added after the fact.  It cannot be 
easily extended, and is not object-oriented.

The *LEO* tool is a structured GUI editor for creating
source.  It uses XML and *noweb*\ -style chunk management.  It is more
than a simple weave and tangle tool.

The *interscript* tool is very large and sophisticated, but doesn't gracefully
tolerate HTML markup in the document.  It can create a variety of 
markup languages from the interscript source, making it suitable for
creating HTML as well as L\ :sub:`a`\ T\ :sub:`e`\ X.

The *lpy* tool can produce very complex HTML representations of
a Python program.  It works by locating documentation markup embedded
in Python comments and docstrings.  This is called "inverted literate
programming".

The *py2html* tool does very sophisticated syntax coloring.

The *PyLit-3* tool is perhaps the very best approach to Literate
programming, since it leverages an existing lightweight markup language
and it's output formatting. However, it's limited in the presentation order,
making it difficult to present a complex Python module out of the proper
Python required presentation.

**py-web-tool**
---------------

**py-web-tool** works with any 
programming language. It can work with any markup language, but is currently
configured to work with RST.  This philosophy
comes from *FunnelWeb*
*noweb*, *nuweb* and *interscript*.  The primary differences
between **py-web-tool** and other tools are the following.

-   **py-web-tool** is object-oriented, permitting easy extension.  
    *noweb* extensions
    are separate processes that communicate through a sophisticated protocol.
    *nuweb* is not easily extended without rewriting and recompiling
    the C programs.

-   **py-web-tool** is built in the very portable Python programming 
    language.  This allows it to run anywhere that Python 3.3 runs, with
    only the addition of docutils.  This makes it a useful
    tool for programmers in any language.

-   **py-web-tool** is much simpler than *FunnelWeb*, *LEO* or *Interscript*.  It has 
    a very limited selection of commands, but can still produce 
    complex programs and HTML documents.

-   **py-web-tool** does not invent a complex markup language like *Interscript*.
    Because *Iterscript* has its own markup, it can generate L\ :sub:`a`\ T\ :sub:`e`\ X or HTML or other
    output formats from a unique input format.  While powerful, it seems simpler to
    avoid inventing yet another sophisticated markup language.  The language **py-web-tool**
    uses is very simple, and the author's use their preferred markup language almost
    exclusively.

-   **py-web-tool** supports the forward literate programming philosophy, 
    where a source document creates programming language and markup language.
    The alternative, deriving the document from markup embedded in 
    program comments ("inverted literate programming"), seems less appealing.
    The disadvantage of inverted literate programming is that the final document
    can't reflect the original author's preferred order of exposition,
    since that informtion generally isn't part of the source code.

-   **py-web-tool** also specifically rejects some features of *nuweb*
    and *FunnelWeb*.  These include the macro capability with parameter
    substitution, and multiple references to a chunk.  These two capabilities
    can be used to grow object-like applications from non-object programming
    languages (*e.g.* C or Pascal).  Since most modern languages (Python,
    Java, C++) are object-oriented, this macro capability is more of a problem
    than a help.

-   Since **py-web-tool** is built in the Python interpreter, a source document
    can include Python expressions that are evaluated during weave operation to
    produce time stamps, source file descriptions or other information in the woven 
    or tangled output.


**py-web-tool** works with any programming language; it can work with any markup language.
The initial release supports RST via simple templates.

The following is extensively quoted from Briggs' *nuweb* documentation, 
and provides an excellent background in the advantages of the very
simple approach started by *nuweb* and adopted by **py-web-tool**.

    The need to support arbitrary
    programming languages has many consequences:

    :No prettyprinting:
        Both ``WEB`` and ``CWEB`` are able to
        prettyprint the code sections of their documents because they
        understand the language well enough to parse it. Since we want to use
        *any* language, we've got to abandon this feature.
        However, we do allow particular individual formulas or fragments
        of L\ :sub:`a`\ T\ :sub:`e`\ X
        or HTML code to be formatted and still be part of the output files.

    :Limited index of identifiers:
        Because ``WEB`` knows about Pascal,
        it is able to construct an index of all the identifiers occurring in
        the code sections (filtering out keywords and the standard type
        identifiers). Unfortunately, this isn't as easy in our case. We don't
        know what an identifier looks like in each language and we certainly
        don't know all the keywords.  We provide a mechanism to mark 
        identifiers, and we use a pretty standard pattern for recognizing
        identifiers almost most programming languages.


    Of course, we've got to have some compensation for our losses or the
    whole idea would be a waste. Here are the advantages I [Briggs] can see:

    :Simplicity:
        The majority of the commands in ``WEB`` are concerned with control of the 
        automatic prettyprinting. Since we don't prettyprint, many commands are 
        eliminated. A further set of commands is subsumed by L\ :sub:`a`\ T\ :sub:`e`\ X  
        and may also be eliminated. As a result, our set of commands is reduced to 
        only about seven members (explained in the next section). 
        This simplicity is also reflected in the size of this tool, 
        which is quite a bit smaller than the tools used with other approaches.

    :No prettyprinting:
        Everyone disagrees about how their code should look, so automatic 
        formatting annoys many people. One approach is to provide ways to 
        control the formatting. Our approach is simpler -- we perform no 
        automatic formatting and therefore allow the programmer complete 
        control of code layout.

    :Control:
        We also offer the programmer reasonably complete control of the 
        layout of his output files (the files generated during tangling). 
        Of course, this is essential for languages that are sensitive to layout; 
        but it is also important in many practical situations, *e.g.*, debugging.

    :Speed:
        Since [**py-web-tool**] doesn't do too much, it runs very quickly. 
        It combines the functions of ``tangle`` and ``weave`` into a single 
        program that performs both functions at once.

    :Chunk numbers:
        Inspired by the example of **noweb**, [**py-web-tool**] refers to all program code 
        chunks by a simple, ascending sequence number through the file.  
        This becomes the HTML anchor name, also.

    :Multiple file output:
        The programmer may specify more than one output file in a single [**py-web-tool**] 
        source file. This is required when constructing programs in a combination of 
        languages (say, Fortran and C). It's also an advantage when constructing 
        very large programs.

Acknowledgements
----------------

This application is very directly based on (derived from?) work that
 preceded this, particularly the following:

-   Ross N. Williams' *FunnelWeb* http://www.ross.net/funnelweb/

-   Norman Ramsey's *noweb* http://www.eecs.harvard.edu/~nr/noweb/

-   Preston Briggs' *nuweb* http://sourceforge.net/projects/nuweb/
    Currently supported by Charles Martin and Marc W. Mengel

Also, after using John Skaller's *interscript* http://interscript.sourceforge.net/
for two large development efforts, I finally understood the feature set I really wanted.

Jason Fruit and others contributed to the previous version.


.. py-web-tool/src/usage.w

Installing
==========

This requires Python 3.10.

This is not (currently) hosted in PyPI. Instead of installing it with PIP,
clone the GitHub repository or download the distribution kit.

Install pyweb "manually" using the provided ``setup.py``.

::

    python setup.py install
    
This will install the ``pyweb`` module.

Using
=====

**py-web-tool** supports two use cases, `Tangle Source Files`_ and `Weave Documentation`_.
These are often combined to both tangle and weave an application and it's documentation.

Tangle Source Files
-------------------

A user initiates this process when they have a complete ``.w`` file that contains 
a description of source files.  These source files are described with ``@o`` commands
in the ``.w`` file.

The use case is successful when the source files are produced.

Outside this use case, the user will debug those source files, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the source files cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

A typical command to tangle (without weaving) is:

..  parsed-literal::

    python -m pyweb -xw *theFile*.w

The outputs will be defined by the ``@o`` commands in the source.

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
     
The first step excludes weaving and permits errors on the ``@i`` command.  The ``-pi`` option
is necessary in the event that the log file does not yet exist.  The second step 
runs the test, creating a log file.  The third step weaves the final document,
including the test output.

Running **py-web-tool** to Tangle and Weave
-------------------------------------------

Assuming that you have marked ``pyweb.py`` as executable,
you do the following:

..  parsed-literal::

    python -m pyweb *theFile*\ .w

This will tangle the ``@o`` commands in each *theFile*.
It will also weave the output, and create *theFile*.rst.

Command Line Options
~~~~~~~~~~~~~~~~~~~~~

Currently, the following command line options are accepted.


:-v:
    Verbose logging. 
    
:-s:
    Silent operation.

:-c\ *x*:
    Change the command character from ``@`` to ``*x*``.

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


.. py-web-tool/src/language.w

The **py-web-tool** ``.w`` Markup Language
==========================================

The essence of literate programming is a markup language that includes both code
from documentation. For tangling, the code is relevant. For weaving, both code
and documentation are relevant.

The source document is a "Web" documentation that includes the code.
It's important to see the ``.w`` file as the final documentation.  The code is tangled out 
of the source web.  

The **py-web-tool** tool parses the ``.w`` file, and performs the
tangle and weave operations.  It *tangles* each individual output file
from the program source chunks.  It *weaves* the final documentation file
file from the entire sequence of chunks provided, mixing the author's 
original documentation with some markup around the embedded program source.

Concepts
---------

The ``.w`` file has two tiers of markup in it.

-   At the top, it has **py-web-tool** markup to distinguish
    documentation chunks from code chunks. 
    
-   Within the documentation chunks, there can be 
    markup for the target publication tool chain. This might
    be RST, LaTeX, HTML, or some other markup language.
    
The **py-web-tool** markup decomposes the source document a sequence of *Chunks*. 
Each Chunk is one of the two kinds:
 
-   program source code to be *tangled* and *woven*.

-   documentation to be *woven*.  

The bulk of the file is typically documentation chunks that describe the program in
some publication-oriented markup language like RST, HTML, or LaTeX.

**py-web-tool** markup surrounds the code with "commands." Everything else is documentation.

The code chunks have two transformations applied.

- When Tangling, the indentation is adjusted to match the context in which they were originally defined. 
  This assures that Python (which relies on indentation)
  parses correctly. For other languages, proper indentation is expected but not required.

- When Weaving, selected characters can be quoted so they don't break the publication tool.
  For HTML, ``&``, ``<``, ``>`` are quoted properly. For LaTeX, a few escapes are used
  to avoid problems with the ``fancyvrb`` environment.

The non-code, documentation chunks are not transformed up in any way.  Everything that's not
explicitly a code chunk is output without modification.

All of the **py-web-tool** tags begin with ``@``. This is sometimes called the command prefix.
(This can be changed.) The tags were historically referred to as "commands."

The *Structural* tags (historically called "major commands") partition the input and define the
various chunks.  The *Inline* tags are (called "minor commands") are used to control the
woven and tangled output from the defined chunks. There are *Content* tags which generate 
summary cross-reference content in woven files.

Boilerplate
-----------

There is some mandatory "boilerplate" required to make a working document.
Requirements vary by markup language.

RST
~~~

The RST template uses two substitutions, ``|srarr|`` and ``|loz|``.

These can be provided by 

::
    
    ..	include:: <isoamsa.txt>
    ..	include:: <isopub.txt>
    
Or

::

    .. |srarr|  unicode:: U+02192 .. RIGHTWARDS ARROW
    .. |loz|    unicode:: U+025CA .. LOZENGE
    
Often the boilerplate document looks like this

..  parsed-literal::
    
    ####################
    *Title*
    ####################
    
    ===============
    *Author*
    ===============
    
    ..  include:: <isoamsa.txt>
    ..	include:: <isopub.txt>
    
    ..  contents::
    
    *Your Document Starts Here*


LaTeX
~~~~~

The LaTeX templates use ``\\fancyvrb``.
The following is required.

::

    \\usepackage{fancyvrb}

Some minimal boilerplate document looks like this:

..  parsed-literal::
    
    \documentclass{article}
    \usepackage{fancyvrb}
    \title{ *Title* }
    \author{ *Author* }
    
    \begin{document}
    
    \maketitle
    \tableofcontents

    *Your Document Starts Here*

    \end{document}

HTML
~~~~

No additional setup is required for HTML. However, there's often
a fairly large amount of HTML boilerplate, depending on the CSS
requirements.

Structural Tags
---------------

There are two definitional tags; these define the various chunks
in an input file. 

``@o`` *file* ``@{`` *text* ``@}``

    The ``@o`` (output) command defines a named output file chunk.  
    The text is tangled to the named
    file with no alteration.  It is woven into the document
    in an appropriate fixed-width font.
    
    There are options available to specify comment conventions
    for the tangled output; this allows inclusion of source
    line numbers.

``@d`` *name* ``@{`` *text* ``@}``

    The ``@d`` (define) command defines a named chunk of program source. 
    This text is tangled
    or woven when it is referenced by the *reference* inline tag.
    
    There are options available to specify the indentation for this
    particular chunk. In rare cases, it can be helpful to override
    the indentation context.

Each ``@o`` and ``@d`` tag is followed by a chunk which is
delimited by ``@{`` and ``@}`` tags.  
At the end of that chunk, there is an optional "major" tag.  

``@|``

    A chunk may define user identifiers.  The list of defined identifiers is placed
    in the chunk, separated by the ``@|`` separator.


Additionally, these tags provide for the inclusion of additional input files.
This is necessary for decomposing a long document into easy-to-edit sections.

``@i`` *file*

    The ``@i`` (include) command includes another file.  The previous chunk
    is ended.  The file is processed completely, then a new chunk
    is started for the text after the ``@i`` command.

All material that is not explicitly in a ``@o`` or ``@d`` named chunk is
implicitly collected into a sequence of anonymous document source chunks.
These anonymous chunks form the backbone of the document that is woven.
The anonymous chunks are never tangled into output program source files.
They are woven into the document without any alteration.

Note that white space (line breaks (``'\n'``), tabs and spaces) have no effect on the input parsing.
They are completely preserved on output.

The following example has three chunks:

..  parsed-literal::

    Some RST-format documentation that describes the following piece of the
    program.

    @o myFile.py 
    @{
    import math
    print( math.pi )
    @| math math.pi
    @}

    Some more RST documentation.

This starts with an anonymous chunk of
documentation. It includes a named output chunk which will write to ``myFile.py``.
It ends with an anonymous chunk of documentation.

Inline Tags
---------------

There are several tags that are replaced by content in the woven output.

``@@``

    The ``@@`` command creates a single ``@`` in the output file.
    This is replaced in tangled as well as woven output.

``@<``\ *name*\ ``@>``

    The *name* references a named chunk.
    When tangling, the referenced chunk replaces the reference command.
    When weaving, a reference marker is used.  For example, in RST, this can be 
    replaced with RST ```reference`_`` markup.
    Note that the indentation prior to the ``@<`` tag is preserved
    for the tangled chunk that replaces the tag.


``@(``\ *Python expression*\ ``@)``

    The *Python expression* is evaluated and the result is tangled or
    woven in place.  A few global variables and modules are available.
    These are described in `Expression Context`_.

Content Tags
---------------

There are three index creation tags that are replaced by content in the woven output.


``@f``

    The ``@f`` command inserts a file cross reference.  This
    lists the name of each file created by an ``@o`` command, and all of the various
    chunks that are concatenated to create this file.

``@m``

    The ``@m`` command inserts a named chunk ("macro") cross reference.  This
    lists the name of each chunk created by a ``@d`` command, and all of the various
    chunks that are concatenated to create the complete chunk.

``@u``

    The ``@u`` command inserts a user identifier cross reference. 
    This index lists the name of each chunk created by an ``@d`` command or ``@|``, 
    and all of the various chunks that are concatenated to create the complete chunk.


Additional Features
-------------------

**Sequence Numbers**. The named chunks (from both ``@o`` and ``@d`` commands) are assigned 
unique sequence numbers to simplify cross references.  

**Case Sensitive**. Chunk names and file names are case sensitive.

**Abbreviations**. Chunk names can be abbreviated.  A partial name can have a trailing ellipsis (...), 
this will be resolved to the full name.  The most typical use for this
is shown in the following example:

..  parsed-literal::

    Some RST-format documentation.

    @o myFile.py 
    @{
    @<imports of the various packages used@>
    print(math.pi,time.time())
    @}

    Some notes on the packages used.

    @d imports...
    @{
    import math,time
    @| math time
    @}

    Some more RST-format documentation.

This example shows five chunks.

1.  An anonymous chunk of documentation.

2.  A named chunk that tangles the ``myFile.py`` output.  It has
    a reference to the ``imports of the various packages used`` chunk.
    Note that the full name of the chunk is essentially a line of 
    documentation, traditionally done as a comment line in a non-literate
    programming environment.

3.  An anonymous chunk of documentation.

4.  A named chunk with an abbreviated name.  The ``imports...``
    matches the name ``imports of the various packages used``.  
    Set off after the ``@|`` separator is
    the list of user-specified identifiers defined in this chunk.

5.  An anonymous chunk of documentation.

Note that the first time a name appears (in a reference or definition),
it **must** be the full name.  All subsequent uses can be elisions.
Also not that ambiguous elision is an annoying problem when you 
first start creating a document.

**Concatenation**. Named chunks are concatenated from their various pieces.
This allows a named chunk to be broken into several pieces, simplifying
the description.  This is most often used when producing 
fairly complex output files.

..  parsed-literal::

    An anonymous chunk with some RST documentation.

    @o myFile.py 
    @{
    import math, time
    @}

    Some notes on the packages used.

    @o myFile.py
    @{
    print(math.pi, time.time())
    @}

    Some more HTML documentation.

This example shows five chunks.

1.  An anonymous chunk of documentation.

2.  A named chunk that tangles the ``myFile.py`` output.  It has
    the first part of the file.  In the woven document
    this is marked with ``"="``.

3.  An anonymous chunk of documentation.

4.  A named chunk that also tangles the ``myFile.py`` output. This
    chunk's content is appended to the first chunk.  In the woven document
    this is marked with ``"+="``.
    
5.  An anonymous chunk of documentation.

**Newline Preservation**. Newline characters are preserved on input.  
Because of this the output may appear to have excessive newlines.  
In all of the above examples, each
named chunk was defined with the following.

..  parsed-literal::

    @{
    import math, time
    @}

This puts a newline character before and after the import line.

Controlling Indentation
-----------------------

We have two choices in indentation:

-   Context-Sensitive.

-   Consistent.

If we have context-sensitive indentation, then the indentation of a chunk reference 
is applied to the entire chunk when expanded in place of the reference.  This makes it
simpler to prepare source for languages (like Python) where indentation
is important.

There are cases, however, when this is not desirable. There are some places in Python
where we want to create long, triple-quoted strings with indentation that does
not follow the prevailing indentations of the surrounding code. 

Here's how the context-sensitive indentation works.

..  parsed-literal::

    @o myFile.py 
    @{
    def aFunction(a, b):
        @<body of aFunction@>
    @| aFunction @}

    @d body...
    @{
    """doc string"""
    return a + b
    @}

The tangled output from this will look like the following.
All of the newline characters are preserved, and the reference to
*body of the aFunction* is indented to match the prevailing
indent where it was referenced.  In the following example, 
explicit line markers of ``~`` are provided to make the blank lines 
more obvious.

..  parsed-literal::

    ~
    ~def aFunction(a, b):
    ~        
    ~    """doc string"""
    ~    return a + b
    ~

[The ``@|`` command shows that this chunk defines the identifier ``aFunction``.]

This leads to a difficult design choice.

-   Do we use context-sensitive indentation without any exceptions?
    This is the current implementation. 
    
-   Do we use consistent indentation and require the author to get it right?
    This seems to make Python awkward, since we might indent our outdent a 
    ``@<`` *name* ``@>`` command, expecting the chunk to indent properly.

-   Do we use context-sensitive indentation with an exception indicator?
    This seems to go against the utter simplicity we're cribbing from **noweb**.
    However, it makes a great deal of sense to add an option for ``@d`` chunks to
    supersede context-sensitive indentation. The author must then get it right.
    
    The syntax to define a section looks like this: 
    
..  parsed-literal::

    @d -noindent some chunk name
    @{*First partial line*
    *More that uses """*
    @}
    
We might reference such a section like this.

..  parsed-literal::

    @d some bigger chunk...
    @{*code*
        @<some chunk name@>
    @}
    
This will include the ``-noindent`` section by resetting the contextual indentation
to zero. The *First partial line* line will be output after the four spaces 
provided by the ``some bigger chunk`` context. 

After the first newline (*More that uses """*) will be at the left margin.

Tracking Source Line Numbers
----------------------------

Since the tangled output files are -- well -- tangled, it can be difficult to
trace back from a Python error stack to the original line in the ``.w`` file that
needs to be fixed.

To facilitate this, there is a two-step operation to get more detailed information
on how tangling worked.

1.  Use the -n command-line option to get line numbers.

2.  Include comment indicators on the ``@o`` commands that define output files.

The expanded syntax for ``@o`` looks like this.

..  parsed-literal::

    @o -start /* -end */ page-layout.css
    @{
    *Some CSS code*
    @}
    
We've added two options: ``-start /*`` and ``-end */`` which define comment
start and end syntax. This will lead to comments embedded in the tangled output
which contain source line numbers for every (every!) chunk.

Expression Context
-------------------

There are two possible implementations for evaluation of a Python
expression in the input.

1.  Create an ``ExpressionCommand``, and append this to the current ``Chunk``.
    This will allow evaluation during weave processing and during tangle processing.  This
    makes the entire weave (or tangle) context available to the expression, including
    completed cross reference information.

2.  Evaluate the expression during input parsing, and append the resulting text
    as a ``TextCommand`` to the current ``Chunk``.  This provides a common result
    available to both weave and parse, but the only context available is the ``WebReader`` and
    the incomplete ``Web``, built up to that point.


In this implementation, we adopt the latter approach, and evaluate expressions immediately.
A global context is created with the following variables defined.

:os.path:
    This is the standard ``os.path`` module. 
    
:os.getcwd:
    The complete ``os`` module is not available. Just this function.
    
:datetime:
    This is the standard ``datetime`` module.
    
:time:
    The standard ``time`` module.

:platform:
    This is the standard ``platform`` module.

:__builtins__:
    Most of the built-ins are available, too. Not all. 
    ``exec()``, ``eval()``, ``open()`` and ``__import__()`` aren't available.

:theLocation:
    A tuple with the file name, first line number and last line number
    for the original expression's location.

:theWebReader:
    The ``WebReader`` instance doing the parsing.

:theFile:
    The ``.w`` file being processed.
    
:thisApplication:
    The name of the running **py-web-tool** application. It may not be pyweb.py, 
    if some other script is being used.

:__version__:
    The version string in the **py-web-tool** application.


.. py-web-tool/src/overview.w 

Architecture and Design Overview
================================

This application breaks the overall problem into the following sub-problems.

1.	Representation of the Web as Chunks and Commands

2.	Reading and parsing the input.

3.	Weaving a document file.

4. 	Tangling the desired program source files.


Representation
---------------

The basic parse tree has three layers. The source document is transformed into a web, 
which is the overall container. The source is
decomposed into a simple sequence of Chunks.  Each Chunk is a simple sequence
of Commands.

Chunks and Commands cannot be nested, leading to delightful simplification.

The overall Web
includes the sequence of Chunks as well as an index for the named chunks.

Note that a named chunk may be created through a number of ``@d`` commands.
This means that
each named chunk may be a sequence of Chunks with a common name.
They are concatenated in order to permit decomposing a single concept into sequentially described pieces.
 
Because a Chunk is composed of a sequence Commands, the weave and tangle actions can be 
delegated to each Chunk, and in turn, delegated to each Command that
composes a Chunk.

There is a small interaction between Tanglers and Chunks to work out the indentation.
Otherwise, the output and input work is largely independent of the Web itself.


Reading and Parsing
--------------------

A solution to the reading and parsing problem depends on a convenient 
tool for breaking up the input stream and a representation for the chunks of input.
Input decomposition is done with the Python Splitter pattern. 

The **Splitter** pattern is widely used in text processing, and has a long legacy
in a variety of languages and libraries.  A Splitter decomposes a string into
a sequence of strings using the split pattern.  There are many variant implementations.
One variant locates only a single occurence (usually the left-most); this is
commonly implemented as a Find or Search string function.  Another variant locates all
occurrences of a specific string or character, and discards the matching string or
character.

The variation on **Splitter** that we use in this application
creates each element in the resulting sequence as either (1) an instance of the 
split regular expression or (2) the text between split patterns.  

We define our splitting pattern with the regular
expression ``'@.|\n'``.  This will split on either of these patterns:

-	 ``@`` followed by a single character,

-	or, a newline.

For the most part, ``\n`` is just text. The exception is the 
``@i`` *filename* command, which ends at the end of the line, making the ``\n``
significant syntax.

We could be a tad more specific and use the following as a split pattern:
``'@[doOifmu\|<>(){}\[\]]|\n'``.  This would silently ignore unknown commands, 
merging them in with the surrounding text.  This would leave the ``'@@'`` sequences 
completely alone, allowing us to replace ``'@@'`` with ``'@'`` in
every text chunk.

Within the ``@d`` and ``@o`` commands, we also parse options. These follow
the syntax rules for Tcl or the shell. Optional fields are prefaced with ``-``.
All options come before all positional arguments. 

Weaving
---------

The weaving operation depends on the target document markup language.
There are several approaches to this problem.  

-	We can use a markup language unique to **py-web-tool**, 
	and weave using markup in the desired target language.
	
-	We can use a standard markup language and use converters to transform
	the standard markup to the desired target markup. We could adopt
	XML or RST or some other generic markup that can be converted.
	
The problem with the second method is the mixture of background document
in some standard markup and the code elements, which need to be bracketed 
with common templates. We hate to repeat these templates; that's the
job of a literate programming tool. Also, certain code characters must
be properly escaped.

Since **py-web-tool** must transform the code into a specific markup language,
we opt using a **Strategy** pattern to encapsulate markup language details.
Each alternative markup strategy is then a subclass of **Weaver**.  This 
simplifies adding additional markup languages without inventing a 
markup language unique to **py-web-tool**.
The author uses their preferred markup, and their preferred
toolset to convert to other output languages.

The templates used to wrap code sections can be tweaked relatively easily.


Tangling
----------

The tangling operation produces output files.  In other tools,
some care was taken to understand the source code context for tangling, and
provide a correct indentation.  This required a command-line parameter
to turn off indentation for languages like Fortran, where identation
is not used.  

In **py-web-tool**, there are two options. The default behavior is that the
indent of a ``@<`` command is used to set the indent of the 
material is expanded in place of this reference.  If all ``@<`` commands are presented at the
left margin, no indentation will be done.  This is helpful simplification,
particularly for users of Python, where indentation is significant.

In rare cases, we might need both, and a ``@d`` chunk can override the indentation
rule to force the material to be placed at the left margin.

Application
------------

The overall application has two layers to it. There are actions (Load, Tangle, Weave)
as well as a top-level main function that parses the command line, creates
and configures the actions, and then closes up shop when all done.

The idea is that the Weaver Action should be visible to tools like `PyInvoke <https://docs.pyinvoke.org/en/stable/index.html>`_.
We want ``Weave("someFile.w")`` to be a sensible task.  


.. py-web-tool/src/impl.w

Implementation
==============

The implementation is contained in a single Python with
the base classes and an overall ``main()`` function.  The ``main()``
function uses these base classes to weave and tangle the output files.

The broad outline of the presentation is as follows:

-   `Web`_ contains the overall Web of Chunks. A Web is a sequence
    of `Chunk` objects. It's also a mapping from chunk name to definition.

-   `Chunks`_ are pieces of the source document, built into a Web.
    A ``Chunk`` is a collection of ``Command`` instances.  This can be
    either an anonymous chunk that will be sent directly to the output, 
    or a named chunks delimited by the structural ``@d`` or ``@o`` commands.

-   `Commands`_ are the items within a ``Chunk``. The text and
    the inline ``@<name@>`` references are the principle command classes.  
    Additionally, there are some cross reference commands (``@f``, ``@m``, or ``@u``).

-   `Emitters`_ write various kinds of files. These decompose into two subclasses:
        
     -  A ``Tangler`` creates source code. 
     
     -  A ``Weaver`` creates documentation.

-   `WebReader`_ is the parser which produces a `Web` from source text.
    This has several closely-related components:

    -   `The WebReader class`_ which parses the Web structure.
    
    -   `The Tokenizer class`_ which tokenizes the raw input.
    
    -   `The Option Parser Class`_ which tokenizes just the arguments to ``@d`` and ``@o``
        commands.
    
-   `Error class`_ defines an application-specific Error.

-   `Reference Strategy`_ defines ways to manage cross-references among chunks.
    These support the ``Weaver`` subclasses of the ``Emitters``.
    We can have references resolved transitively or simply. A transitive
    reference becomes a list of parent ``NamedChunk`` instances.

-   `Action class hierarchy`_ defines things this program does.

-   `pyWeb Module File`_ defines the final module file that's created.

-   `The Application class`_. This is an overall class definition that includes
    command line parsing, picking an Action, configuring and executing the Action.
    It could be a set of related functions, but we've bound them into a class.

-   `Logging setup`_. This includes a simple context manager for logging.

-   `The Main Function`_.

We'll start with a place-holder that collects the definitions 
into the order most convenient for the final implementation.


..  _`1`:
..  rubric:: Base Class Definitions (1) =
..  parsed-literal::
    :class: code

    
    
    |srarr|\ Error class - defines the errors raised (`21`_)
    
    |srarr|\ Command class hierarchy - used to describe individual commands (`6`_)
    
    |srarr|\ Chunk class hierarchy - used to describe input chunks (`4`_)
    
    |srarr|\ Web class - describes the overall "web" of chunks (`3`_)
    
    |srarr|\ Tokenizer class - breaks input into tokens (`39`_)
    
    |srarr|\ Option Parser class - locates optional values on commands (`41`_), |srarr|\ (`42`_), |srarr|\ (`43`_)
    
    |srarr|\ WebReader class - parses the input file, building the Web structure (`22`_)
    
    |srarr|\ Reference class hierarchy - strategies for weaving references to a chunk (`18`_), |srarr|\ (`19`_), |srarr|\ (`20`_) 
    
    |srarr|\ Emitter class hierarchy - used to control output files (`7`_)
    
    |srarr|\ Action class hierarchy - used to describe actions of the application (`44`_)

..

    ..  class:: small

        |loz| *Base Class Definitions (1)*. Used by: pyweb.py (`60`_)


The above order is reasonably helpful for Python and minimizes forward
references. The ``Chunk``, ``Command``, and ``Web`` instances do have a circular relationship.

We'll start at the central collection of information, the ``Web`` class of objects.



Web Class
----------

The overall web of chunks is contained in a 
single instance of the ``Web`` class that is the principle parameter for the weaving and tangling actions.  
Broadly, the functionality of a Web can be separated into the folloowing areas:

- It supports  construction methods used by ``Chunks`` and ``WebReader``.

- It also supports "enrichment" of the web, once all the Chunks are known. 
  This is a stateful update to the web.  Each Chunk is updated with Chunk 
  references it makes as well as Chunks which reference it.

- It supports ``Chunk`` cross-reference methods that traverse this enriched data.
  This includes a kind of validity check to be sure that everything is used once
  and once only. 
  

Fundamentally, a ``Web`` is a hybrid list-mapping. It as the following features:

-   It's a mapping of names to chunks that also offers a 
    moderately sophisticated
    lookup, including exact match for a chunk name and an approximate match for a
    an abbreviated chunk name. 
    There are several methods to  resolve references among chunks.

-   It's a sequence that retains all chunks in order.

The ``Web`` is built, incrementally, by the parser.

Note that the source language has a "mixed content model". This means the code chunks
have specific tags with names. The text, on the other hand, is interspersed
among the code chunks. The text can be collected into implicit, unnamed text chunks.

A web instance has a number of attributes.

:chunks:
    the sequence of ``Chunk`` instances as seen in the input file.
    To support anonymous chunks, and to assure that the original input document order
    is preserved, we keep all chunks in a master sequential list.

:files:
    the ``@o`` named ``OutputChunk`` chunks.  
    Each element of this  dictionary is a sequence of chunks that have the same name. 
    The first is the initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:macros:
    the ``@d`` named ``NamedChunk`` chunks.  Each element of this 
    dictionary is a sequence of chunks that have the same name.  The first is the
    initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:userids:
    the cross reference of chunks referenced by commands in other
    chunks.

This relies on the way a ``@dataclass`` does post-init processing.
One the raw sequence of ``Chunks`` has been presented, some additional
processing is done to link each ``Chunk`` to the web. This permits
the ``full_name`` property to expand abbreviated names to full names,
and, consequently, chunk references.


..  _`2`:
..  rubric:: Imports (2) =
..  parsed-literal::
    :class: code

    from collections import defaultdict
    from collections.abc import Iterator
    from dataclasses import dataclass, field
    import logging
    from pathlib import Path
    from types import SimpleNamespace
    from typing import Any, Optional, Literal, ClassVar
    from weakref import ref, ReferenceType

..

    ..  class:: small

        |loz| *Imports (2)*. Used by: pyweb.py (`60`_)



..  _`3`:
..  rubric:: Web class - describes the overall "web" of chunks (3) =
..  parsed-literal::
    :class: code

    
    @dataclass
    class Web:
        chunks: list["Chunk"]  #: The source sequence of chunks.
    
        # The \`\`@d\`\` chunk names and locations where they're defined.
        chunk\_map: dict[str, list["Chunk"]] = field(init=False)
        
        # The \`\`@\|\`\` defined names and chunks with which they're associated.
        userid\_map: defaultdict[str, list["Chunk"]] = field(init=False)
        
        logger: logging.Logger = field(init=False, default=logging.getLogger("Web"))
    
        strict\_match: ClassVar[bool] = True  #: Don't permit ... names without a definition.
        
        def \_\_post\_init\_\_(self) -> None:
            """
            Populate weak references throughout the web to make full\_name properties work.
            Then. Locate all macro definitions and userid references. 
            """
            # Pass 1 -- set all Chunk and Command back references.
            for c in self.chunks:
                c.web = ref(self)
                for cmd in c.commands:
                    cmd.web = ref(self)
                    
            # Named Chunks = Union of macro\_iter and file\_iter
            named\_chunks = list(filter(lambda c: c.name is not None, self.chunks))
    
            # Pass 2 -- locate the unabbreviated names
            self.chunk\_map = {}
            for seq, c in enumerate(named\_chunks, start=1):
                c.seq = seq
                if not c.path:
                    # Use \`\`@d name\`\` chunks (reject \`\`@o\`\` and text)
                    if not c.name.endswith('...'):
                        self.logger.debug(f"\_\_post\_init\_\_ 2a {c.name=!r}")
                        self.chunk\_map.setdefault(c.name, [])
                for cmd in c.commands:
                    # Find \`\`@< name @>\`\` in \`\`@d name\`\` chunks or \`\`@o\`\` chunks 
                    if cmd.typeid.ReferenceCommand and not cmd.name.endswith('...'):
                        self.logger.debug(f"\_\_post\_init\_\_ 2b {cmd.name=!r}")
                        self.chunk\_map.setdefault(cmd.name, [])
                        
            # Pass 3 -- accumulate chunk lists, output lists, and name definition lists
            self.userid\_map = defaultdict(list)
            for c in named\_chunks:
                for name in c.def\_names:
                    self.userid\_map[name].append(c)
                if not c.path:
                    # Use \`\`@d name\`\` chunks (reject \`\`@o\`\` and text)
                    self.chunk\_map[c.full\_name].append(c)
                    self.logger.debug(f"\_\_post\_init\_\_ 3 {c.name=!r} -> {c.full\_name=!r}")
                    
                # TODO: Accumulate all chunks that contribute to a named file...
    
            # Pass 4 -- set referencedBy a command in a chunk.
            # NOTE: Assuming single references \*only\*
            # We should raise an exception when updating a non-None referencedBy value.
            # Or incrementing ref\_chunk.references > 1.
            for c in named\_chunks:
                for cmd in c.commands:
                    if cmd.typeid.ReferenceCommand:
                        ref\_to\_list = self.resolve\_chunk(cmd.name)
                        for ref\_chunk in ref\_to\_list:
                            ref\_chunk.referencedBy = c
                            ref\_chunk.references += 1
                
        def \_\_repr\_\_(self) -> str:
            NL = ",\\n"
            return (
                f"{self.\_\_class\_\_.\_\_name\_\_}("
                f"{NL.join(repr(c) for c in self.chunks)}"
                f")"
            )
            
        def resolve\_name(self, target: str) -> str:
            """Map short names to full names, if possible."""
            if target in self.chunk\_map:
                # self.logger.debug(f"resolve\_name {target=} in self.chunk\_map")
                return target
            elif target.endswith('...'):
                # The ... is equivalent to regular expression .\*
                matches = list(
                    c\_name
                    for c\_name in self.chunk\_map
                    if c\_name.startswith(target[:-3])
                )
                # self.logger.debug(f"resolve\_name {target=} {matches=} in self.chunk\_map")
                match matches:
                    case []:
                        if self.strict\_match:
                            raise Error(f"No full name for {target!r}")
                        else:
                            self.logger.warning(f"resolve\_name {target=} unknown")
                            self.chunk\_map[target] = []
                            return target
                    case [head]:
                        return head
                    case [head, \*tail]:
                        message = f"Ambiguous abbreviation {target!r}, matches {[head] + tail!r}"
                        raise Error(message)
            else:
                self.logger.warning(f"resolve\_name {target=} unknown")
                self.chunk\_map[target] = []
                return target
    
        def resolve\_chunk(self, target: str) -> list["Chunk"]:
            """Map name (short or full) to the defining sequence of chunks."""
            full\_name = self.resolve\_name(target)
            chunk\_list = self.chunk\_map[full\_name]
            self.logger.debug(f"resolve\_chunk {target=!r} -> {full\_name=!r} -> {chunk\_list=}")
            return chunk\_list
    
        def file\_iter(self) -> Iterator[SimpleNamespace]:
            return filter(lambda c: c.typeid.OutputChunk, self.chunks)
    
        def macro\_iter(self) -> Iterator[SimpleNamespace]:
            return filter(lambda c: c.typeid.NamedChunk, self.chunks)
    
        def userid\_iter(self) -> Iterator[SimpleNamespace]:
            yield from (SimpleNamespace(def\_name=n, chunk=c) for c in self.file\_iter() for n in c.def\_names)
            yield from (SimpleNamespace(def\_name=n, chunk=c) for c in self.macro\_iter() for n in c.def\_names)
    
        @property
        def files(self) -> list["OutputChunk"]:
            return list(self.file\_iter())
    
        @property
        def macros(self) -> list[SimpleNamespace]:
            """
            The chunk\_map has the list of Chunks that comprise a macro definition.
            We separate those to make it slightly easier to format the first definition.
            """
            first\_list = (
                (self.chunk\_map[name][0], self.chunk\_map[name])
                for name in sorted(self.chunk\_map)
                if self.chunk\_map[name]
            )
            macro\_list = list(
                SimpleNamespace(name=first\_def.name, full\_name=first\_def.full\_name, seq=first\_def.seq, def\_list=def\_list)
                for first\_def, def\_list in first\_list
            )
            # print(f"macros: {defs}")
            return macro\_list
    
        @property
        def userids(self) -> list[SimpleNamespace]:
            userid\_list = list(
                SimpleNamespace(userid=userid, ref\_list=self.userid\_map[userid])
                for userid in sorted(self.userid\_map)
            )
            # print(f"userids: {userid\_list}")
            return userid\_list
                
        def no\_reference(self) -> list[Chunk]:
            return list(filter(lambda c: c.name and not c.path and c.references == 0, self.chunks))
            
        def multi\_reference(self) -> list[Chunk]:
            return list(filter(lambda c: c.name and not c.path and c.references > 1, self.chunks))
            
        def no\_definition(self) -> list[str]:
            commands = (
                cmd for c in self.chunks for cmd in c.commands
            )
            return list(filter(lambda cmd: not cmd.definition, commands))
    

..

    ..  class:: small

        |loz| *Web class - describes the overall "web" of chunks (3)*. Used by: Base Class Definitions (`1`_)


A web is built by a WebReader. It's used by Emitters, including Weaver and Tangler.
It's composed of individual Chunk instances.

Chunks
--------

A ``Chunk`` is a piece of the input file.  It is a collection of ``Command`` instances.
A chunk can be woven or tangled to create output.


..  _`4`:
..  rubric:: Chunk class hierarchy - used to describe input chunks (4) =
..  parsed-literal::
    :class: code

    
    |srarr|\ The TypeId Helper (`5`_)
    
    @dataclass
    class Chunk:
        """Superclass for OutputChunk, NamedChunk, NamedDocumentChunk.
    
        Chunk is the anonymous text context. 
            The Text, Ref, and the various XREF commands can \*only\* appear here.
            A REF must be do a \`\`@d name @[...@]\`\` NamedDocumentChunk, which is expanded, not linked.
    
        OutputChunk is the \`\`@o\`\` context. 
            The Code and Ref commands appear here.
            This is tangled to a file.
    
        NamedChunk is the \`\`@d\`\` context. 
            The Code and Ref commands appear here.
            This is tangled where referenced.
        """
        name: str \| None = None  #: Short name of the chunk
        seq: int \| None = None  #: Unique sequence number of chunk in the WEB
        commands: list["Command"] = field(default\_factory=list)  #: Sequence of commands inside this chunk
        options: list[str] = field(default\_factory=list)  #: Parsed options for @d and @o chunks.
        def\_names: list[str] = field(default\_factory=list)  #: Names defined after \`\`@\|\`\` in this chunk
        comment\_start: str \| None = None  #: If injecting location details, this is the prefix
        comment\_end: str \| None = None  #: If injecting location details, this is the suffix
    
        references: int = field(init=False, default=0)
        referencedBy: Optional["Chunk"] = field(init=False, default=None)
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("Chunk"))
    
        @property
        def full\_name(self) -> str \| None:
            return self.web().resolve\_name(self.name)
    
        @property
        def path(self) -> Path \| None:
            return None
    
        @classmethod
        @property
        def typeid(cls) -> TypeId:
            return TypeId(cls)
    
    
    class OutputChunk(Chunk):
        @property
        def path(self) -> Path \| None:
            return Path(self.name)
    
        @property
        def full\_name(self) -> str \| None:
            return None
    
    class NamedChunk(Chunk): 
        pass
    
    
    class NamedDocumentChunk(Chunk): 
        pass
    
    

..

    ..  class:: small

        |loz| *Chunk class hierarchy - used to describe input chunks (4)*. Used by: Base Class Definitions (`1`_)


The ``TypeId`` class is used to provide some run-time type
identification. This helps sort out the various nodes of the AST
built from the source WEB document. The idea is ``object.typeid.AClass`` is 
equivalent to ``isinstance(object, AClass)``. It has simpler syntax
and works well with Jinja templates.


..  _`5`:
..  rubric:: The TypeId Helper (5) =
..  parsed-literal::
    :class: code

    
    class TypeId:
        """
        This makes the given class name into an attribute with a 
        True value. Any other attribute reference will return False.
        """
        def \_\_init\_\_(self, member\_of: type[Any]) -> None:
            self.my\_class = member\_of.\_\_name\_\_
    
        def \_\_getattr\_\_(self, item: str) -> bool:
            return item == self.my\_class
    

..

    ..  class:: small

        |loz| *The TypeId Helper (5)*. Used by: Chunk class hierarchy... (`4`_)


Commands
--------

The input stream is broken into individual commands, based on the
various ``@*x*`` strings in the file.  There are several subclasses of ``Command``,
each used to describe a different command or block of text in the input.


All instances of the ``Command`` class are created by a ``WebReader`` instance.  
In this case, a ``WebReader`` can be thought of as a factory for ``Command`` instances.
Each ``Command`` instance is appended to the sequence of commands that
belong to a ``Chunk``.  A chunk may be as small as a single command, or a long sequence
of commands.


..  _`6`:
..  rubric:: Command class hierarchy - used to describe individual commands (6) =
..  parsed-literal::
    :class: code

    
    
    @dataclass
    class TextCommand:
        text: str  #: The text
        location: tuple[str, int]  #: The (filename, line number)
        
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("TextCommand"))
        definition: bool = field(init=False, default=True)  # Only used for ReferenceCommand
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
    
        def indent(self) -> int:
            if self.text.endswith('\\n'):
                self.logger.debug(f"indent = 0")
                return 0
            try:
                last\_line = self.text.splitlines()[-1]
                self.logger.debug(f"indent = {len(last\_line)}")
                return len(last\_line)
            except IndexError:
                self.logger.debug(f"indent (with no text) = 0")
                return 0
            
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            self.logger.debug(f"tangle {self.text=!r}")
            aTangler.codeBlock(target, self.text)
    
    @dataclass
    class CodeCommand:
        text: str  #: The code
        location: tuple[str, int]
        
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("CodeCommand"))
        definition: bool = field(init=False, default=True)  # Only used for ReferenceCommand
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
            
        def indent(self) -> int:
            if self.text.endswith('\\n'):
                return 0
            try:
                last\_line = self.text.splitlines()[-1]
                return len(last\_line)
            except IndexError:
                return 0
    
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            self.logger.debug(f"tangle {self.text=!r}")
            aTangler.codeBlock(target, self.text)
    
    
    @dataclass
    class ReferenceCommand:
        """
        Reference to a \`\`NamedChunk\`\` in code.
        On text, however, it expands to the text of a \`\`NamedDocumentChunk\`\`.
        """
        name: str  #: The name provided
        location: tuple[str, int]
        
        web: ReferenceType["Web"] = field(init=False)
        definition: bool = field(init=False, default=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("ReferenceCommand"))
    
        @property
        def text(self) -> str:
            return self.web().get\_text(self.full\_name)
        
        @property
        def full\_name(self) -> str:
            return self.web().resolve\_name(self.name)
    
        @property
        def seq(self) -> str:
            return self.web().resolve\_chunk(self.name)[0].seq
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
    
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            """Expand this reference.
            The starting position is the indentation for all \*\*subsequent\*\* lines.
            Provide tangler.lastIndent back to the tangler. 
            """
            self.logger.debug(f"tangle reference to {self.name=}, {aTangler.lastIndent=}")
            chunk\_list = self.web().resolve\_chunk(self.name)
            if len(chunk\_list) == 0:
                message = f"Attempt to tangle an undefined Chunk, {self.name!r}"
                self.logger.error(message)
                raise Error(message) 
            self.definition = True
            aTangler.addIndent(aTangler.lastIndent)
    
            for chunk in chunk\_list:
                # TODO: if chunk.options includes '-indent': do an addIndent before tangling.
                for command in chunk.commands:
                    command.tangle(aTangler, target)
                    
            aTangler.clrIndent()
            
        def indent(self) -> int \| None:
            return None
    
    @dataclass
    class FileXrefCommand:
        location: tuple[str, int]
    
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("FileXrefCommand"))
        definition: bool = field(init=False, default=True)  # Only used for ReferenceCommand
    
        @property
        def files(self):
            return self.web().files
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
    
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            raise Error('Illegal tangling of a cross reference command.')
    
        def indent(self) -> int:
            return 0
    
    @dataclass
    class MacroXrefCommand:
        location: tuple[str, int]
    
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("MacroXrefCommand"))
        definition: bool = field(init=False, default=True)  # Only used for ReferenceCommand
    
        @property
        def macros(self):
            return self.web().macros
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
    
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            raise Error('Illegal tangling of a cross reference command.')
    
        def indent(self) -> int:
            return 0
    
    @dataclass
    class UserIdXrefCommand:
        location: tuple[str, int]
    
        web: ReferenceType["Web"] = field(init=False)
        logger: logging.Logger = field(init=False, default=logging.getLogger("UserIdXrefCommand"))
        definition: bool = field(init=False, default=True)  # Only used for ReferenceCommand
    
        @property
        def userids(self) -> list[str]:
            return self.web().userids
    
        @classmethod
        @property
        def typeid(cls) -> "TypeId":
            return TypeId(cls)
            
        def tangle(self, aTangler: "Tangler", target: TextIO) -> None:
            raise Error('Illegal tangling of a cross reference command.')
    
        def indent(self) -> int:
            return 0

..

    ..  class:: small

        |loz| *Command class hierarchy - used to describe individual commands (6)*. Used by: Base Class Definitions (`1`_)


Emitters
---------

An ``Emitter`` instance is responsible for control of an output file format.
This includes the necessary file naming, opening, writing and closing operations.
It also includes providing the correct markup for the file type.


..  _`7`:
..  rubric:: Emitter class hierarchy - used to control output files (7) =
..  parsed-literal::
    :class: code

    
    
    |srarr|\ Emitter Superclass (`9`_)
    
    |srarr|\ Quoting rule definitions -- functions used by templates (`11`_) 
    
    |srarr|\ Weaver Subclass -- Uses Jinja templates to weave documentation (`10`_)
    
    |srarr|\ Tangler Subclass -- emits the output files (`13`_) 
    
    |srarr|\ TanglerMake Subclass -- extends Tangler to avoid touching files that didn't change (`17`_)

..

    ..  class:: small

        |loz| *Emitter class hierarchy - used to control output files (7)*. Used by: Base Class Definitions (`1`_)



..  _`8`:
..  rubric:: Imports (8) +=
..  parsed-literal::
    :class: code

    import abc
    from textwrap import dedent
    from jinja2 import Environment, DictLoader, select\_autoescape

..

    ..  class:: small

        |loz| *Imports (8)*. Used by: pyweb.py (`60`_)



..  _`9`:
..  rubric:: Emitter Superclass (9) =
..  parsed-literal::
    :class: code

    
    class Emitter(abc.ABC):
        def \_\_init\_\_(self, output: Path): 
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            self.log\_indent = logging.getLogger("indent." + self.\_\_class\_\_.\_\_qualname\_\_)
            self.output = output
        
        @abc.abstractmethod
        def emit(self, web: Web) -> None:
            pass

..

    ..  class:: small

        |loz| *Emitter Superclass (9)*. Used by: Emitter class hierarchy... (`7`_)



..  _`10`:
..  rubric:: Weaver Subclass -- Uses Jinja templates to weave documentation (10) =
..  parsed-literal::
    :class: code

    
    |srarr|\ RST Templates -- these are the default templates (`12`_)
    
    class Weaver(Emitter):
        def \_\_init\_\_(self, output: Path = Path.cwd()) -> None:
            super().\_\_init\_\_(output)
            # TODO: Track down all markup-specific templates
            # HTML weaver, LaTeX weaver 
            self.env = Environment(
                loader=DictLoader(
                    {
                        'rst\_weaver': rst\_weaver\_template,
                        'rst\_overrides': rst\_overrides\_template,
                        'base\_weaver': base\_weaver\_template\_2,
                    }
                ),
                autoescape=select\_autoescape()
            )
            # Summary
            self.linesWritten = 0
            
        def set\_markup(self, markup: str = "rst") -> "Weaver":
            self.env.filters \|= {"quote\_rules": quote\_rules[markup]}
            self.markup = markup
            return self
            
        def emit(self, web: Web) -> None:
            self.target\_path = (self.output / web.web\_path.name).with\_suffix(f".{self.markup}")
            self.logger.info("Weaving %s using %s markup", self.target\_path, self.markup)
            template = self.env.get\_template("base\_weaver")
            with self.target\_path.open('w') as target\_file:
                for text in template.generate(markup="rst\_weaver", overrides="rst\_overrides", web=web):
                    self.linesWritten += text.count("\\n")
                    target\_file.write(text)

..

    ..  class:: small

        |loz| *Weaver Subclass -- Uses Jinja templates to weave documentation (10)*. Used by: Emitter class hierarchy... (`7`_)



..  _`11`:
..  rubric:: Quoting rule definitions -- functions used by templates (11) =
..  parsed-literal::
    :class: code

    
    def rst\_quote\_rules(text: str) -> str:
        quoted\_chars = [
            ('\\\\', r'\\\\'), # Must be first.
            ('\`', r'\\\`'),
            ('\_', r'\\\_'), 
            ('\*', r'\\\*'),
            ('\|', r'\\\|'),
        ]
        clean = text
        for from\_, to\_ in quoted\_chars:
            clean = clean.replace(from\_, to\_)
        return clean
    
    def html\_quote\_rules(text: str) -> str:
        quoted\_chars = [
            ("&", "&amp;"),  # Must be first
            ("<", "&lt;"),
            (">", "&gt;"),
            ('"', "&quot;"),
        ]
        clean = text
        for from\_, to\_ in quoted\_chars:
            clean = clean.replace(from\_, to\_)
        return clean
    
    quote\_rules = {
        "rst": rst\_quote\_rules,
        "html": html\_quote\_rules,
    }

..

    ..  class:: small

        |loz| *Quoting rule definitions -- functions used by templates (11)*. Used by: Emitter class hierarchy... (`7`_)



..  _`12`:
..  rubric:: RST Templates -- these are the default templates (12) =
..  parsed-literal::
    :class: code

    
    rst\_weaver\_template = dedent("""\\
        {%- macro text(command) -%}
        {{command.text}}
        {%- endmacro -%}
        
        {%- macro begin\_code(chunk) %}
        ..  \_\`{{chunk.full\_name}} ({{chunk.seq}})\`:
        ..  rubric:: {{chunk.name}} ({{chunk.seq}}) =
        ..  parsed-literal::
            :class: code
        {% endmacro -%}
        
        {% macro code(command) %}
            {% for line in command.lines -%}
            {{line \| quote\_rules}}
            {% endfor -%}
        {% endmacro -%}
        
        {% macro ref(id) -%}
        \\N{RIGHTWARDS ARROW}\\ \`{{id.full\_name}} ({{id.seq}})\`\_
        {%- endmacro -%}
        
        {%- macro end\_code(chunk) %}
        ..
        
        ..  class:: small
        
            \\N{END OF PROOF} \*{{chunk.full\_name}} ({{chunk.seq}})\*
            
        {% endmacro -%}
        
        {% macro file\_xref(command) -%}
        {% for file in command.files -%}
        :{{file.name}}:
            {{ref(file)}}
        {%- endfor %}
        {%- endmacro -%}
        
        {% macro macro\_xref(command) -%}
        {% for macro in command.macros -%}
        :{{macro.full\_name}}:
            {% for d in macro.def\_list -%}{{ref(d)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
            
        {% endfor %}
        {%- endmacro -%}
    
        {% macro userid\_xref(command) -%}
        {% for userid in command.userids -%}
        :{{userid.userid}}:
            {% for r in userid.ref\_list -%}{{ref(r)}}{% if loop.last %}{% else %}, {% endif %}{%- endfor %}
            
        {% endfor %}
        {%- endmacro -%}
        """
    )
    
    rst\_overrides\_template = dedent("""
    """)
    
    base\_weaver\_template\_2 = dedent("""\\
        {%- from 'rst\_weaver' import text, begin\_code, code, end\_code, file\_xref, macro\_xref, userid\_xref, ref, ref\_list -%}{#- default macros from rst\_weaver -#}
        {#- from 'rst\_overrides' import \*the names\* -#}{#- customized macros from WEB document -#}
        {% for chunk in web.chunks -%}
            {%- if chunk.typeid.OutputChunk or chunk.typeid.NamedChunk -%}
                {{begin\_code(chunk)}}
                {% for command in chunk.commands -%}
                    {%- if command.typeid.CodeCommand %}{{code(command)}}
                    {%- elif command.typeid.ReferenceCommand %}{{ref(command)}}
                    {%- endif -%}
                {% endfor %}
                {{end\_code(chunk)}}
            {%- elif chunk.typeid.Chunk -%}
                {% for command in chunk.commands -%}
                    {%- if command.typeid.TextCommand %}{{text(command)}}
                    {%- elif command.typeid.ReferenceCommand %}{{text(command)}}
                    {%- elif command.typeid.FileXrefCommand %}{{file\_xref(command)}}
                    {%- elif command.typeid.MacroXrefCommand %}{{macro\_xref(command)}}
                    {%- elif command.typeid.UserIdXrefCommand %}{{userid\_xref(command)}}
                    {% endif -%}
                {%- endfor %}
            {%- endif -%}
        {%- endfor %}
    """)

..

    ..  class:: small

        |loz| *RST Templates -- these are the default templates (12)*. Used by: Weaver Subclass... (`10`_)


**TODO:** Need to handle the case where an output chunk
has multiple definitions. 

..  parsed-literal::

    @o x.y
    @{
    ... part 1 ...
    @}
    
    @o x.y
    @{
    ... part 2 ...
    @}
    
The above should have the same output as the follow (more complex) alternative: 

..  parsed-literal::

    @o x.y
    @{
    @<part 1@>
    @<part 2@>
    @}
    
    @d part 1
    @{
    ... part 1 ...
    @}

    @d part 2
    @{
    ... part 2 ...
    @}

The following definition may not support the first alternative.
The ``Web`` needs to create a mapping from file name to all chunks that
create the file. 


..  _`13`:
..  rubric:: Tangler Subclass -- emits the output files (13) =
..  parsed-literal::
    :class: code

    
    class Tangler(Emitter):
        code\_indent = 0  #: Initial indent
    
        def \_\_init\_\_(self, output: Path = Path.cwd()) -> None:
            super().\_\_init\_\_(output)
            self.context: list[int] = []
            self.resetIndent(self.code\_indent)  # Create context and initial lastIndent values
            # Summary
            self.linesWritten = 0
            self.totalFiles = 0
            self.totalLines = 0
    
        def emit(self, web: Web) -> None:
            for file\_chunk in web.files:
                self.logger.info("Tangling %s", file\_chunk.name)
                self.emit\_file(web, file\_chunk)
                
        def emit\_file(self, web: Web, file\_chunk: Chunk) -> None:
            target\_path = self.output / file\_chunk.name
            self.logger.debug("Writing %s", target\_path)
            self.logger.debug("Chunk %r", file\_chunk)
            with target\_path.open("w") as target:
                # An initial command to provide indentations.
                for command in file\_chunk.commands:
                    command.tangle(self, target)
                    
        |srarr|\ Emitter write a block of code with proper indents (`14`_)
    
        |srarr|\ Emitter indent control: set, clear and reset (`15`_)

..

    ..  class:: small

        |loz| *Tangler Subclass -- emits the output files (13)*. Used by: Emitter class hierarchy... (`7`_)




..  _`14`:
..  rubric:: Emitter write a block of code with proper indents (14) =
..  parsed-literal::
    :class: code

    
    def codeBlock(self, target: TextIO, text: str) -> None:
        """Indented write of text in a \`\`CodeCommand\`\`. 
        Counts lines and saves position to indent to when expanding \`\`@<...@>\`\` references.
        
        The \`\`lastIndent\`\` is the prevailing indent used in reference expansion.
        """
        indent = self.context[-1]
        if len(text) == 0:
            # Degenerate case of empty CodeText command
            pass
        elif text == '\\n':
            self.linesWritten += 1
            target.write(text)
            self.lastIndent = 0
            self.fragment = False  # Generally, also means lastIndent == 0
        else:
            if not self.fragment:
                # First thing after '\\n'
                target.write(indent\*' ')
                wrote = target.write(text)
                self.lastIndent = wrote
                self.fragment = True
            else:
                target.write(text)
    

..

    ..  class:: small

        |loz| *Emitter write a block of code with proper indents (14)*. Used by: Tangler Subclass... (`13`_)


The ``setIndent()`` pushes a fixed indent instead adding an increment.
    
The ``clrIndent()`` method discards the most recent indent from the context stack.  
This is used when finished
tangling a source chunk.  This restores the indent to the prevailing indent.

The ``resetIndent()`` method removes all indent context information and resets the indent
to a default.


..  _`15`:
..  rubric:: Emitter indent control: set, clear and reset (15) =
..  parsed-literal::
    :class: code

    
    def addIndent(self, increment: int) -> None:
        self.lastIndent = self.context[-1]+increment
        self.context.append(self.lastIndent)
        self.log\_indent.debug("addIndent %d: %r", increment, self.context)
        
    def setIndent(self, indent: int) -> None:
        self.context.append(indent)
        self.lastIndent = self.context[-1]
        self.log\_indent.debug("setIndent %d: %r", indent, self.context)
        
    def clrIndent(self) -> None:
        if len(self.context) > 1:
            self.context.pop()
        self.lastIndent = self.context[-1]
        self.log\_indent.debug("clrIndent %r", self.context)
        
    def resetIndent(self, indent: int = 0) -> None:
        """Resets the indentation context."""
        self.lastIndent = indent
        self.context = [self.lastIndent]
        self.fragment = False  # Nothing written yet
        self.log\_indent.debug("resetIndent %d: %r", indent, self.context)
    

..

    ..  class:: small

        |loz| *Emitter indent control: set, clear and reset (15)*. Used by: Tangler Subclass... (`13`_)


An extension that only updates a file if the content has changed.


..  _`16`:
..  rubric:: Imports (16) +=
..  parsed-literal::
    :class: code

    import filecmp
    import tempfile
    import os

..

    ..  class:: small

        |loz| *Imports (16)*. Used by: pyweb.py (`60`_)



..  _`17`:
..  rubric:: TanglerMake Subclass -- extends Tangler to avoid touching files that didn't change (17) =
..  parsed-literal::
    :class: code

    
    class TanglerMake(Tangler):
        def emit\_file(self, web: Web, file\_chunk: Chunk) -> None:
            target\_path = self.output / file\_chunk.name
            self.logger.debug("Writing %s via a temp file", target\_path)
            self.logger.debug("Chunk %r", file\_chunk)
    
            fd, tempname = tempfile.mkstemp(dir=os.curdir)
            with os.fdopen(fd, "w") as target:
                for command in file\_chunk.commands:
                    command.tangle(self, target)
                    
            try:
                same = filecmp.cmp(tempname, target\_path)
            except OSError as e:
                same = False  # Doesn't exist. (Could check for errno.ENOENT)
                
            if same:
                self.logger.info("Unchanged '%s'", target\_path)
                os.remove(tempname)
            else:
                # Windows requires the original file name be removed first.
                try: 
                    target\_path.unlink()
                except OSError as e:
                    pass  # Doesn't exist. (Could check for errno.ENOENT)
                target\_path.parent.mkdir(parents=True, exist\_ok=True)
                target\_path.hardlink\_to(tempname)
                os.remove(tempname)
                self.logger.info("Wrote %d lines to %s", self.linesWritten, target\_path)

..

    ..  class:: small

        |loz| *TanglerMake Subclass -- extends Tangler to avoid touching files that didn't change (17)*. Used by: Emitter class hierarchy... (`7`_)



Reference Strategy
---------------------------------

The Reference Strategy has two implementations.  An instance
of this is injected into each Chunk by the Web.  By injecting this
algorithm, we assure that:

(1) each Chunk can produce all relevant reference information and 

(2) a simple configuration change can be applied to the document.


Reference Superclass
~~~~~~~~~~~~~~~~~~~~~

The superclass is an abstract class that defines the interface for
this object.



..  _`18`:
..  rubric:: Reference class hierarchy - strategies for weaving references to a chunk (18) =
..  parsed-literal::
    :class: code

    
    class Reference(abc.ABC):
        def \_\_init\_\_(self) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            
        @abc.abstractmethod
        def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
            """Return a list of Chunks."""
            ...

..

    ..  class:: small

        |loz| *Reference class hierarchy - strategies for weaving references to a chunk (18)*. Used by: Base Class Definitions (`1`_)


SimpleReference Class
~~~~~~~~~~~~~~~~~~~~~

The SimpleReference subclass does the simplest version of resolution. It returns
the ``Chunks`` referenced.
    

..  _`19`:
..  rubric:: Reference class hierarchy - strategies for weaving references to a chunk (19) +=
..  parsed-literal::
    :class: code

    
    class SimpleReference(Reference):
        def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
            refBy = [aChunk.referencedBy]
            return refBy

..

    ..  class:: small

        |loz| *Reference class hierarchy - strategies for weaving references to a chunk (19)*. Used by: Base Class Definitions (`1`_)


TransitiveReference Class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The TransitiveReference subclass does a transitive closure of all
references to this Chunk.

This requires walking through the ``Web`` to locate "parents" of each referenced
``Chunk``.


..  _`20`:
..  rubric:: Reference class hierarchy - strategies for weaving references to a chunk (20) +=
..  parsed-literal::
    :class: code

    
    class TransitiveReference(Reference):
        def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
            refBy = aChunk.referencedBy
            all\_refs = list(self.allParentsOf(refBy))
            self.logger.debug("References: %r(%d) %r", aChunk.name, aChunk.seq, all\_refs)
            return all\_refs
            
        @staticmethod
        def allParentsOf(chunk: Chunk \| None, depth: int = 0) -> Iterator[Chunk]:
            """Transitive closure of parents via recursive ascent.
            """
            if chunk:
                yield chunk
                yield from TransitiveReference.allParentsOf(chunk.referencedBy, depth+1)

..

    ..  class:: small

        |loz| *Reference class hierarchy - strategies for weaving references to a chunk (20)*. Used by: Base Class Definitions (`1`_)



Error class
------------

An ``Error`` is raised whenever processing cannot continue.  Since it
is a subclass of Exception, it takes an arbitrary number of arguments.  The
first should be the basic message text.  Subsequent arguments provide 
additional details.  We will try to be sure that
all of our internal exceptions reference a specific chunk, if possible.
This means either including the chunk as an argument, or catching the 
exception and appending the current chunk to the exception's arguments.

The Python ``raise`` statement takes an instance of ``Error`` and passes it
to the enclosing ``try/except`` statement for processing.

The typical creation is as follows:

..  parsed-literal::

    raise Error(f"No full name for {chunk.name!r}", chunk)

A typical exception-handling suite might look like this:

..  parsed-literal::

    try:
        *...something that may raise an Error or Exception...*
    except Error as e:
        print(e.args) # this is a pyWeb internal Error
    except Exception as w:
        print(w.args) # this is some other Python Exception

The ``Error`` class is a subclass of ``Exception`` used to differentiate 
application-specific
exceptions from other Python exceptions.  It does no additional processing,
but merely creates a distinct class to facilitate writing ``except`` statements.



..  _`21`:
..  rubric:: Error class - defines the errors raised (21) =
..  parsed-literal::
    :class: code

    
    class Error(Exception): pass

..

    ..  class:: small

        |loz| *Error class - defines the errors raised (21)*. Used by: Base Class Definitions (`1`_)


The WebReader Class
-----------------------------

There are two forms of the constructor for a ``WebReader``.  The 
initial ``WebReader`` instance is created with code like the following:


..  parsed-literal::

    p = WebReader()
    p.command = options.commandCharacter 

This will define the command character; usually provided as a command-line parameter to the application.

When processing an include file (with the ``@i`` command), a child ``WebReader``
instance is created with code like the following:

..  parsed-literal::

    c = WebReader(parent=parentWebReader)


This will inherit the configuration from the parent ``WebReader``.  
This will also include a  reference from child to parent so that embedded Python expressions
can view the entire input context.

The ``WebReader`` class parses the input file into command blocks.
These are assembled into ``Chunks``, and the ``Chunks`` are assembled into the document
``Web``.  Once this input pass is complete, the resulting ``Web`` can be tangled or
woven.

The commands have three general types:

-   "Structural" commands define the structure of the ``Chunks``.  The  structural commands 
    are ``@d`` and ``@o``, as well as the ``@{``, ``@}``, ``@[``, ``@]`` brackets, 
    and the ``@i`` command to include another file.

-   "Inline" commands are inline within a ``Chunk``: they define internal ``Commands``.  
    Blocks of text are minor commands, as well as the ``@<``\ *name*\ ``@>`` references.
    The ``@@`` escape is also
    handled here so that all further processing is independent of any parsing.

-   "Content" commands generate woven content. These include 
    the various cross-reference commands (``@f``, ``@m`` and ``@u``).  

There are two class-level ``OptionParser`` instances used by this class.

:output_option_parser:
    An ``OptionParser`` used to parse the ``@o`` command's options.
    
:definition_option_parser:
    An ``OptionParser`` used to parse the ``@d`` command's options.

The class has the following attributes:

:parent:
    is the outer ``WebReader`` when processing a ``@i`` command.

:command:
    is the command character; a WebReader will use the parent command 
    character if the parent is not ``None``.

:permitList:
    is the list of commands that are permitted to fail.  This is generally 
    an empty list or ``('@i',)``.

:_source:
    The open source being used by ``load()``.
    
:filePath:
    is used to pass the file name to the Web instance.

:theWeb:
    is the current open Web.

:tokenizer:
    An instance of ``Tokenizer`` used to parse the input. This is built
    when ``load()`` is called.
    
:aChunk:
    is the current open Chunk being built.
    
:totalLines:
:totalFiles:
    Summaries


..  _`22`:
..  rubric:: WebReader class - parses the input file, building the Web structure (22) =
..  parsed-literal::
    :class: code

    
    class WebReader:
        """Parse an input file, creating Chunks and Commands."""
    
        output\_option\_parser = OptionParser(
            OptionDef("-start", nargs=1, default=None),
            OptionDef("-end", nargs=1, default=""),
            OptionDef("argument", nargs='\*'),
        )
    
        # TODO: Allow a numeric argument value in \`\`-indent\`\`
        definition\_option\_parser = OptionParser(
            OptionDef("-indent", nargs=0),
            OptionDef("-noindent", nargs=0),
            OptionDef("argument", nargs='\*'),
        )
        
        # Configuration
        command: str
        permitList: list[str]
        base\_path: Path
        
        # State of the reader
        filePath: Path  #: Input Path 
        \_source: TextIO  #: Input file
        tokenizer: Tokenizer  #: The tokenizer used to find commands
        content: list[Chunk]  #: the processing context -- a sequence of Chunk instances.
    
        def \_\_init\_\_(self, parent: Optional["WebReader"] = None) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
    
            # Configuration comes from the parent or defaults if there is no parent.
            self.parent = parent
            if self.parent: 
                self.command = self.parent.command
                self.permitList = self.parent.permitList
            else: # Defaults until overridden
                self.command = '@'
                self.permitList = []
                        
            # Summary
            self.totalLines = 0
            self.totalFiles = 0
            self.errors = 0 
            
            |srarr|\ WebReader command literals (`37`_)
            
        def \_\_str\_\_(self) -> str:
            return self.\_\_class\_\_.\_\_name\_\_
            
        |srarr|\ WebReader location in the input stream (`34`_)
        
        |srarr|\ WebReader load the web (`36`_)
        
        |srarr|\ WebReader handle a command string (`23`_), |srarr|\ (`33`_)

..

    ..  class:: small

        |loz| *WebReader class - parses the input file, building the Web structure (22)*. Used by: Base Class Definitions (`1`_)


The reader maintains a context into which constructs are added.
The ``Web`` contains ``Chunk`` instances in ``self.web.chunks``.
The current chunk is ``self.web.chunks[-1]``.
Each ``Chunk``, similarly, has a command context in ``chunk.commands[-1]``.

This works because the language is "flat": there are no nested ``@d`` or ``@o``
chunks.

Command recognition is done via a **Chain of Command**-like design.
There are two conditions: the command string is recognized or it is not recognized.
If the command is recognized, ``handleCommand()`` will do one of the following:

-   For "structural" commands, it will attach the current ``Chunk`` (*self.aChunk*) to the 
    current ``Web`` (*self.aWeb*), and start a new ``Chunk``. This becomes the context
    for processing commands. By default an anonymous ``Chunk`` used to accumulate text
    is available for all of the content outside named chunks.

-   For "inline" and "content" commands, create a ``Command``, attach it to the current 
    ``Chunk`` (*self.aChunk*).

If the command is not recognized, ``handleCommand()`` returns false, and this is a syntax error.

A subclass can override ``handleCommand()`` to 

(1) call this superclass version;

(2) if the command is unknown to the superclass, 
    then the subclass can process it;

(3) if the command is unknown to both classes, 
    then return ``False``.  Either a subclass will handle it, or the default activity taken
    by ``load()`` is to treat the command as a syntax error.


..  _`23`:
..  rubric:: WebReader handle a command string (23) =
..  parsed-literal::
    :class: code

    
    def handleCommand(self, token: str) -> bool:
        self.logger.debug("Reading %r", token)
        
        match token[:2]:
            case self.cmdo:
                |srarr|\ start an OutputChunk, adding it to the web (`24`_)
            case self.cmdd:
                |srarr|\ start a NamedChunk or NamedDocumentChunk, adding it to the web (`25`_)
            case self.cmdi:
                |srarr|\ include another file (`26`_)
            case self.cmdrcurl \| self.cmdrbrak:
                |srarr|\ finish a chunk, start a new Chunk adding it to the web (`27`_)
            case self.cmdpipe:
                |srarr|\ assign user identifiers to the current chunk (`28`_)
            case self.cmdf:
                self.content[-1].commands.append(FileXrefCommand(self.tokenizer.lineNumber))
            case self.cmdm:
                self.content[-1].commands.append(MacroXrefCommand(self.tokenizer.lineNumber))
            case self.cmdu:
                self.content[-1].commands.append(UserIdXrefCommand(self.tokenizer.lineNumber))
            case self.cmdlangl:
                |srarr|\ add a reference command to the current chunk (`29`_)
            case self.cmdlexpr:
                |srarr|\ add an expression command to the current chunk (`31`_)
            case self.cmdcmd:
                |srarr|\ double at-sign replacement, append this character to previous TextCommand (`32`_)
            case self.cmdlcurl \| self.cmdlbrak:
                # These should have been consumed as part of @o and @d parsing
                self.logger.error("Extra %r (possibly missing chunk name) near %r", token, self.location())
                self.errors += 1
            case \_:
                return False  # did not recogize the command
        return True  # did recognize the command
    

..

    ..  class:: small

        |loz| *WebReader handle a command string (23)*. Used by: WebReader class... (`22`_)



An output chunk has the form ``@o`` *name* ``@{`` *content* ``@}``.
We use the first two tokens to name the ``OutputChunk``.  We expect
the ``@{`` separator.  We then attach all subsequent commands
to this chunk while waiting for the final ``@}`` token to end the chunk.

We'll use an ``OptionParser`` to locate the optional parameters.  This will then let
us build an appropriate instance of ``OutputChunk``.

With some small additional changes, we could use ``OutputChunk(**options)``.
    

..  _`24`:
..  rubric:: start an OutputChunk, adding it to the web (24) =
..  parsed-literal::
    :class: code

    
    args = next(self.tokenizer)
    self.expect({self.cmdlcurl})
    options = self.output\_option\_parser.parse(args)
    newChunk = OutputChunk(
        name=' '.join(options['argument']),
        comment\_start=''.join(options.get('start', "# ")),
        comment\_end=''.join(options.get('end', "")),
    )
    newChunk.filePath = self.filePath
    self.content.append(newChunk)
    self.content[-1].commands.append(CodeCommand("", self.location()))
    # capture an OutputChunk up to @}

..

    ..  class:: small

        |loz| *start an OutputChunk, adding it to the web (24)*. Used by: WebReader handle a command... (`23`_)


A named chunk has the form ``@d`` *name* ``@{`` *content* ``@}`` for
code and ``@d`` *name* ``@[`` *content* ``@]`` for document source.
We use the first two tokens to name the ``NamedChunk`` or ``NamedDocumentChunk``.  
We expect either the ``@{`` or ``@[`` separator, and use the actual
token found to choose which subclass of ``Chunk`` to create.
We then attach all subsequent commands
to this chunk while waiting for the final ``@}`` or ``@]`` token to 
end the chunk.

We'll use an ``OptionParser`` to locate the optional parameter of ``-noindent``.

**TODO:** Extend this to support ``-indent`` *number*

Then we can use the ``options`` value to create an appropriate subclass of ``NamedChunk``.
        
If ```"-indent"`` is in options, this is the default. 
If both are in the options, we should provide a warning.

**TODO:** Add a warning for conflicting options.


..  _`25`:
..  rubric:: start a NamedChunk or NamedDocumentChunk, adding it to the web (25) =
..  parsed-literal::
    :class: code

    
    args = next(self.tokenizer)
    brack = self.expect({self.cmdlcurl, self.cmdlbrak})
    options = self.output\_option\_parser.parse(args)
    name = ' '.join(options['argument'])
    
    if brack == self.cmdlbrak:
        newChunk = NamedDocumentChunk(name)
    elif brack == self.cmdlcurl:
        if '-noindent' in options:
            newChunk = NamedChunk\_Noindent(name)
        else:
            newChunk = NamedChunk(name)
    elif brack == None:
        newChunk = None
        pass # Error noted by expect()
    else:
        raise Error("Design Error")
    
    if newChunk:
        self.content.append(newChunk)
    self.content[-1].commands.append(CodeCommand("", self.location()))
    # capture a NamedChunk up to @} or @]

..

    ..  class:: small

        |loz| *start a NamedChunk or NamedDocumentChunk, adding it to the web (25)*. Used by: WebReader handle a command... (`23`_)


An import command has the unusual form of ``@i`` *name*, with no trailing
separator.  When we encounter the ``@i`` token, the next token will start with the
file name, but may continue with an anonymous chunk.  To avoid confusion,
we require that all ``@i`` commands occur at the end of a line, 
The break on the ``'\n'`` which ends the file name.
This permits file names with embedded spaces. It also permits arguments and options,
if really necessary.

Once we have split the file name away from the rest of the following anonymous chunk,
we push the following token (a ``\n``) back into the token stream, so that it will be the 
first token examined at the top of the ``load()`` loop.

We create a child ``WebReader`` instance to process the included file.  The entire file 
is loaded into the current ``Web`` instance.  A new, empty ``Chunk`` is created at the end
of the file so that processing can resume with an anonymous ``Chunk``.

The reader has a ``permitList`` attribute.
This lists any commands where failure is permitted.  Currently, only the ``@i`` command
can be set to permit failure; this allows a ``.w`` to include
a file that does not yet exist.  
 
The primary use case for this permitted error feature is when weaving test output.
A first use of the **py-web-tool** can be used to tangle the program source files,
ignoring a missing test output file, named in an ``@i`` command.
The application can then be run to create the missing test output file. 
After this, a second use of the **py-web-tool** 
can weave the test output file into a final, complete document.


..  _`26`:
..  rubric:: include another file (26) =
..  parsed-literal::
    :class: code

    
    incPath = Path(next(self.tokenizer).strip())
    try:
        include = WebReader(parent=self)
        if not incPath.is\_absolute():
            incPath = self.base\_path / incPath
        self.logger.info("Including '%s'", incPath)
        self.content.extend(include.load(incPath))
        self.totalLines += include.tokenizer.lineNumber
        self.totalFiles += include.totalFiles
        if include.errors:
            self.errors += include.errors
            self.logger.error("Errors in included file '%s', output is incomplete.", incPath)
    except Error as e:
        self.logger.error("Problems with included file '%s', output is incomplete.", incPath)
        self.errors += 1
    except IOError as e:
        self.logger.error("Problems finding included file '%s', output is incomplete.", incPath)
        # Discretionary -- sometimes we want to continue
        if self.cmdi in self.permitList: pass
        else: raise  # Seems heavy-handed, but, the file wasn't found!
    # Start a new context for text or commands \*after\* the \`\`@i\`\`.
    self.content.append(Chunk())

..

    ..  class:: small

        |loz| *include another file (26)*. Used by: WebReader handle a command... (`23`_)


When a ``@}`` or ``@]`` are found, this finishes a named chunk.  The next
text is therefore part of an anonymous chunk.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@{`` or ``@[``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if a trailing bracket was necessary.
For the base ``Chunk`` class, this would be false, but for all other subclasses of
``Chunk``, this would be true.



..  _`27`:
..  rubric:: finish a chunk, start a new Chunk adding it to the web (27) =
..  parsed-literal::
    :class: code

    
    # Start a new context for text or commands \*after\* this command.
    self.content.append(Chunk())

..

    ..  class:: small

        |loz| *finish a chunk, start a new Chunk adding it to the web (27)*. Used by: WebReader handle a command... (`23`_)


User identifiers occur after a ``@|`` command inside a ``NamedChunk``.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@{``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if user identifiers are permitted.
For the base ``Chunk`` class, this would be false, but for the ``NamedChunk`` class and
``OutputChunk`` class, this would be true.

User identifiers are name references at the end of a NamedChunk
These are accumulated and expanded by ``@u`` reference


..  _`28`:
..  rubric:: assign user identifiers to the current chunk (28) =
..  parsed-literal::
    :class: code

    
    try:
        names = next(self.tokenizer).strip().split()
        self.content[-1].def\_names.extend(names)
    except AttributeError:
        # Out of place @\| user identifier command
        self.logger.error("Unexpected references near %r: %r", self.location(), token)
        self.errors += 1

..

    ..  class:: small

        |loz| *assign user identifiers to the current chunk (28)*. Used by: WebReader handle a command... (`23`_)


A reference command has the form ``@<``\ *name*\ ``@>``.  We accept three
tokens from the input, the middle token is the referenced name.


..  _`29`:
..  rubric:: add a reference command to the current chunk (29) =
..  parsed-literal::
    :class: code

    
    # get the name, introduce into the named Chunk dictionary
    name = next(self.tokenizer).strip()
    closing = self.expect({self.cmdrangl})
    self.content[-1].commands.append(ReferenceCommand(name, self.tokenizer.lineNumber))
    self.logger.debug("Reading %r %r", name, closing)

..

    ..  class:: small

        |loz| *add a reference command to the current chunk (29)*. Used by: WebReader handle a command... (`23`_)


An expression command has the form ``@(``\ *Python Expression*\ ``@)``.  
We accept three
tokens from the input, the middle token is the expression.

There are two alternative semantics for an embedded expression.

-   **Deferred Execution**.  This requires definition of a new subclass of ``Command``, 
    ``ExpressionCommand``, and appends it into the current ``Chunk``.  At weave and
    tangle time, this expression is evaluated.  The insert might look something like this:
    ``aChunk.append(ExpressionCommand(expression, self.tokenizer.lineNumber))``.

-   **Immediate Execution**.  This simply creates a context and evaluates
    the Python expression.  The output from the expression becomes a ``TextCommand``, and
    is append to the current ``Chunk``.

We use the **Immediate Execution** semantics -- the expression is immediately appended
to the current chunk's text.

We provide elements of the ``os`` module.  We provide ``os.path`` library.
An ``os.getcwd()`` could be changed to ``os.path.realpath('.')``.


..  _`30`:
..  rubric:: Imports (30) +=
..  parsed-literal::
    :class: code

    
    import builtins
    import sys
    import platform
    

..

    ..  class:: small

        |loz| *Imports (30)*. Used by: pyweb.py (`60`_)



..  _`31`:
..  rubric:: add an expression command to the current chunk (31) =
..  parsed-literal::
    :class: code

    
    # get the Python expression, create the expression result
    expression = next(self.tokenizer)
    self.expect({self.cmdrexpr})
    try:
        # Build Context
        # \*\*TODO:\*\* Parts of this are static.
        dangerous = {
            'breakpoint', 'compile', 'eval', 'exec', 'execfile', 'globals', 'help', 'input', 
            'memoryview', 'open', 'print', 'super', '\_\_import\_\_'
        }
        safe = types.SimpleNamespace(\*\*dict(
            (name, obj) 
            for name,obj in builtins.\_\_dict\_\_.items() 
            if name not in dangerous
        ))
        globals = dict(
            \_\_builtins\_\_=safe, 
            os=types.SimpleNamespace(path=os.path, getcwd=os.getcwd, name=os.name),
            time=time,
            datetime=datetime,
            platform=platform,
            theLocation=str(self.location()),
            theWebReader=self,
            theFile=self.filePath,
            thisApplication=sys.argv[0],
            \_\_version\_\_=\_\_version\_\_,  # Legacy compatibility. Deprecated.
            version=\_\_version\_\_,
            )
        # Evaluate
        result = str(eval(expression, globals))
    except Exception as exc:
        self.logger.error('Failure to process %r: result is %r', expression, exc)
        self.errors += 1
        result = f"@({expression!r}: Error {exc!r}@)"
    self.content[-1].commands.append(TextCommand(result, self.tokenizer.lineNumber))

..

    ..  class:: small

        |loz| *add an expression command to the current chunk (31)*. Used by: WebReader handle a command... (`23`_)


A double command sequence (``'@@'``, when the command is an ``'@'``) has the
usual meaning of ``'@'`` in the input stream.  We do this via 
the ``appendText()`` method of the current ``Chunk``.  This will append the 
character on the end of the most recent ``TextCommand``; if this fails, it will
create a new, empty ``TextCommand``.

We replace with '@' here and now! This is put this at the end of the previous chunk.
And we make sure the next chunk will be appended to this so that it's 
largely seamless.


..  _`32`:
..  rubric:: double at-sign replacement, append this character to previous TextCommand (32) =
..  parsed-literal::
    :class: code

    
    self.content[-1].commands.append(TextCommand(self.command, self.tokenizer.lineNumber))

..

    ..  class:: small

        |loz| *double at-sign replacement, append this character to previous TextCommand (32)*. Used by: WebReader handle a command... (`23`_)


The ``expect()`` method examines the 
next token to see if it is the expected item. ``'\n'`` are absorbed.  
If this is not found, a standard type of error message is raised. 
This is used by ``handleCommand()``.


..  _`33`:
..  rubric:: WebReader handle a command string (33) +=
..  parsed-literal::
    :class: code

    
    def expect(self, tokens: set[str]) -> str \| None:
        """Compare next token with expectation, quietly skipping whitespace (i.e., \`\`\\n\`\`)."""
        try:
            t = next(self.tokenizer)
            while t == '\\n':
                t = next(self.tokenizer)
        except StopIteration:
            self.logger.error("At %r: end of input, %r not found", self.location(), tokens)
            self.errors += 1
            return None
        if t in tokens:
            return t
        else:
            self.logger.error("At %r: expected %r, found %r", self.location(), tokens, t)
            self.errors += 1
            return None
    

..

    ..  class:: small

        |loz| *WebReader handle a command string (33)*. Used by: WebReader class... (`22`_)


The ``location()`` provides the file name and line number.
This allows error messages as well as tangled or woven output 
to correctly reference the original input files.


..  _`34`:
..  rubric:: WebReader location in the input stream (34) =
..  parsed-literal::
    :class: code

    
    def location(self) -> tuple[str, int]:
        return (str(self.filePath), self.tokenizer.lineNumber+1)
    

..

    ..  class:: small

        |loz| *WebReader location in the input stream (34)*. Used by: WebReader class... (`22`_)


The ``load()`` method reads the entire input file as a sequence
of tokens, split up by the ``Tokenizer``.  Each token that appears
to be a command is passed to the ``handleCommand()`` method.  If
the ``handleCommand()`` method returns a True result, the command was recognized
and placed in the ``Web``.  If ``handleCommand()`` returns a False result, the command
was unknown, and we write a warning but treat it as text.

The ``load()`` method is used recursively to handle the ``@i`` command. The issue
is that it's always loading a single top-level web. 


..  _`35`:
..  rubric:: Imports (35) +=
..  parsed-literal::
    :class: code

    from typing import TextIO

..

    ..  class:: small

        |loz| *Imports (35)*. Used by: pyweb.py (`60`_)



..  _`36`:
..  rubric:: WebReader load the web (36) =
..  parsed-literal::
    :class: code

    
    def load(self, filepath: Path, source: TextIO \| None = None) -> list[Chunk]:
        """A flat list of chunks can be made into a Web. 
        Or. It can be used to extend a web because of a \`\`@i\`\` command.
        """
        self.filePath = filepath
        self.base\_path = self.filePath.parent
    
        if source:
            self.\_source = source
            self.parse\_source()
        else:
            with self.filePath.open() as self.\_source:
                self.parse\_source()
        return self.content
    
    def parse\_source(self) -> None:
        self.tokenizer = Tokenizer(self.\_source, self.command)
        self.totalFiles += 1
    
        # Initial anonymous chunk.
        self.content = [Chunk()]
    
        for token in self.tokenizer:
            if len(token) >= 2 and token.startswith(self.command):
                if self.handleCommand(token):
                    continue
                else:
                    self.logger.error('Unknown @-command in input: %r near %r', token, self.location())
                    self.content[-1].commands.append(TextCommand(token, self.tokenizer.lineNumber))
            elif token:
                # Accumulate a non-empty block of text in the current chunk.
                self.content[-1].commands.append(TextCommand(token, self.tokenizer.lineNumber))
            else:
                # Whitespace
                pass
    

..

    ..  class:: small

        |loz| *WebReader load the web (36)*. Used by: WebReader class... (`22`_)


The command character can be changed to permit
some flexibility when working with languages that make extensive
use of the ``@`` symbol, i.e., PERL.
The initialization of the ``WebReader`` is based on the selected 
command character.



..  _`37`:
..  rubric:: WebReader command literals (37) =
..  parsed-literal::
    :class: code

    
    # Structural ("major") commands
    self.cmdo = self.command+'o'
    self.cmdd = self.command+'d'
    self.cmdlcurl = self.command+'{'
    self.cmdrcurl = self.command+'}'
    self.cmdlbrak = self.command+'['
    self.cmdrbrak = self.command+']'
    self.cmdi = self.command+'i'
    
    # Inline ("minor") commands
    self.cmdlangl = self.command+'<'
    self.cmdrangl = self.command+'>'
    self.cmdpipe = self.command+'\|'
    self.cmdlexpr = self.command+'('
    self.cmdrexpr = self.command+')'
    self.cmdcmd = self.command+self.command
    
    # Content "minor" commands
    self.cmdf = self.command+'f'
    self.cmdm = self.command+'m'
    self.cmdu = self.command+'u'

..

    ..  class:: small

        |loz| *WebReader command literals (37)*. Used by: WebReader class... (`22`_)



The Tokenizer Class
~~~~~~~~~~~~~~~~~~~~

The ``WebReader`` requires a tokenizer. The tokenizer breaks the input text
into a stream of tokens. There are two broad classes of tokens:

-   ``r'@.'`` command tokens, including the structural, inline, and content
    commands.

-   ``r'\n'``. Inside text, these matter. Within structural command tokens, these don't matter.
    Except after the filename after an ``@i`` command, where it ends the command. 

-   The remaining text; neither newlines nor commands.

The tokenizer works by reading the entire file and splitting on ``r'@.'`` patterns.
The ``re.split()`` function will separate the input
and preserve the actual character sequence on which the input was split.
This breaks the input into blocks of text separated by the ``r'@.'`` characters.

For example:

..  parsed-literal::

    >>> pat.split( "@{hi mom@}")
    ['', '@{', 'hi mom', '@}', '']
    
This tokenizer splits the input using ``r'@.|\n'``. The idea is that 
we locate commands, newlines and the interstitial text as three classes of tokens.  
We can then assemble each ``Command`` instance from a short sequence of tokens.
The core ``TextCommand`` and ``CodeCommand`` will be a line of text ending with
the ``\n``. 

The tokenizer counts newline characters for us, so that error messages can include
a line number. Also, we can tangle extract comments into a file to reveal source line numbers.

Since the tokenizer is a proper iterator, we can use ``tokens = iter(Tokenizer(source))``
and ``next(tokens)`` to step through the sequence of tokens until we raise a ``StopIteration``
exception.


..  _`38`:
..  rubric:: Imports (38) +=
..  parsed-literal::
    :class: code

    
    import re
    from collections.abc import Iterator, Iterable
    

..

    ..  class:: small

        |loz| *Imports (38)*. Used by: pyweb.py (`60`_)



..  _`39`:
..  rubric:: Tokenizer class - breaks input into tokens (39) =
..  parsed-literal::
    :class: code

    
    class Tokenizer(Iterator[str]):
        def \_\_init\_\_(self, stream: TextIO, command\_char: str='@') -> None:
            self.command = command\_char
            self.parsePat = re.compile(f'({self.command}.\|\\\\n)')
            self.token\_iter = (t for t in self.parsePat.split(stream.read()) if len(t) != 0)
            self.lineNumber = 0
            
        def \_\_next\_\_(self) -> str:
            token = next(self.token\_iter)
            self.lineNumber += token.count('\\n')
            return token
            
        def \_\_iter\_\_(self) -> Iterator[str]:
            return self
    

..

    ..  class:: small

        |loz| *Tokenizer class - breaks input into tokens (39)*. Used by: Base Class Definitions (`1`_)


The Option Parser Class
~~~~~~~~~~~~~~~~~~~~~~~~~

For some commands (``@d`` and ``@o``) we have options as well as the chunk name
or file name. This roughly parallels the way Tcl or the shell works.

The two examples are 

-   ``@o`` which has an optional ``-start`` and ``-end`` that are used to 
    provide comment bracketing information. For example:
    
    ``@0 -start /* -end */ something.css``
    
    Provides two options in addition to the required filename.
    
-   ``@d`` which has an optional ``-noident`` or ``-indent`` that is used to
    provide the indentation rules for this chunk. Some chunks are not indented 
    automatically. It's up to the author to get the indentation right. This is
    used in the case of a Python """ string that would be ruined by indentation.
    
To handle this, we have a separate lexical scanner and parser for these
two commands.


..  _`40`:
..  rubric:: Imports (40) +=
..  parsed-literal::
    :class: code

    
    import shlex
    

..

    ..  class:: small

        |loz| *Imports (40)*. Used by: pyweb.py (`60`_)


Here's how we can define an option.

..  parsed-literal::

    OptionParser(
        OptionDef("-start", nargs=1, default=None),
        OptionDef("-end", nargs=1, default=""),
        OptionDef("-indent", nargs=0), # A default
        OptionDef("-noindent", nargs=0),
        OptionDef("argument", nargs='*'),
        )
        
The idea is to parallel ``argparse.add_argument()`` syntax.


..  _`41`:
..  rubric:: Option Parser class - locates optional values on commands (41) =
..  parsed-literal::
    :class: code

    
    class ParseError(Exception): pass

..

    ..  class:: small

        |loz| *Option Parser class - locates optional values on commands (41)*. Used by: Base Class Definitions (`1`_)



..  _`42`:
..  rubric:: Option Parser class - locates optional values on commands (42) +=
..  parsed-literal::
    :class: code

    
    class OptionDef:
        def \_\_init\_\_(self, name: str, \*\*kw: Any) -> None:
            self.name = name
            self.\_\_dict\_\_.update(kw)

..

    ..  class:: small

        |loz| *Option Parser class - locates optional values on commands (42)*. Used by: Base Class Definitions (`1`_)


The parser breaks the text into words using ``shelex`` rules. 
It then steps through the words, accumulating the options and the
final argument value.


..  _`43`:
..  rubric:: Option Parser class - locates optional values on commands (43) +=
..  parsed-literal::
    :class: code

    
    class OptionParser:
        def \_\_init\_\_(self, \*arg\_defs: Any) -> None:
            self.args = dict((arg.name, arg) for arg in arg\_defs)
            self.trailers = [k for k in self.args.keys() if not k.startswith('-')]
            
        def parse(self, text: str) -> dict[str, list[str]]:
            try:
                word\_iter = iter(shlex.split(text))
            except ValueError as e:
                raise Error(f"Error parsing options in {text!r}")
            options = dict(self.\_group(word\_iter))
            return options
            
        def \_group(self, word\_iter: Iterator[str]) -> Iterator[tuple[str, list[str]]]:
            option: str \| None
            value: list[str]
            final: list[str]
            option, value, final = None, [], []
            for word in word\_iter:
                if word == '--':
                    if option:
                        yield option, value
                    try:
                        final = [next(word\_iter)] 
                    except StopIteration:
                        final = []  # Special case of '--' at the end.
                    break
                elif word.startswith('-'):
                    if word in self.args:
                        if option: 
                            yield option, value
                        option, value = word, []
                    else:
                        raise ParseError(f"Unknown option {word!r}")
                else:
                    if option:
                        if self.args[option].nargs == len(value):
                            yield option, value
                            final = [word]
                            break
                        else:                
                            value.append(word)
                    else:
                        final = [word]
                        break
            # In principle, we step through the trailers based on nargs counts.
            for word in word\_iter:
                final.append(word)
            yield self.trailers[0], final

..

    ..  class:: small

        |loz| *Option Parser class - locates optional values on commands (43)*. Used by: Base Class Definitions (`1`_)


In principle, we step through the trailers based on ``nargs`` counts.
Since we only ever have the one trailer, we can skate by without checking the number of args.

The loop becomes a bit more complex to capture the positional arguments, in order.
Then we'd have something like this. (Untested, incomplete, just hand-waving.)

..  parsed-literal::

    trailers = self.trailers[:] # Stateful shallow copy
    for word in word_iter:
        if len(final) == trailers[-1].nargs:  # nargs=='*' vs. nargs=int??
            yield trailers[0], " ".join(final)
            final = 0
            trailers.pop(0)
    yield trailers[0], " ".join(final)
    
Action Class Hierarchy
-----------------------

This application performs three major actions: loading the document web, 
weaving and tangling.  Generally,
the use case is to perform a load, weave and tangle.  However, a less common use case
is to first load and tangle output files, run a regression test and then 
load and weave a result that includes the test output file.

The ``-x`` option excludes one of the two output actions.  The ``-xw`` 
excludes the weave pass, doing only the tangle action.  The ``-xt`` excludes
the tangle pass, doing the weave action.

This two pass action might be embedded in the following type of Python program.

..  parsed-literal::

    import pyweb, os, runpy, sys, pathlib, contextlib
    log = pathlib.Path("source.log")
    Tangler().emit(web)
    with log.open("w") as target:
        with contextlib.redirect_stdout(target):
            # run the app, capturing the output
            runpy.run_path('source.py')
            # Alternatives include using pytest or doctest
    Weaver().emit(web, "something.rst")


The first step runs **py-web-tool** , excluding the final weaving pass.  The second
step runs the tangled program, ``source.py``, and produces test results in
some log file, ``source.log``.  The third step runs **py-web-tool**  excluding the
tangle pass.  This produces a final document that includes the ``source.log`` 
test results.

To accomplish this, we provide a class hierarchy that defines the various
actions of the **py-web-tool**  application.  This class hierarchy defines an extensible set of 
fundamental actions.  This gives us the flexibility to create a simple sequence
of actions and execute any combination of these.  It eliminates the need for a 
forest of ``if``-statements to determine precisely what will be done.

Each action has the potential to update the state of the overall
application.   A partner with this command hierarchy is the Application class
that defines the application options, inputs and results. 


..  _`44`:
..  rubric:: Action class hierarchy - used to describe actions of the application (44) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Action superclass has common features of all actions (`45`_)
    |srarr|\ ActionSequence subclass that holds a sequence of other actions (`48`_)
    |srarr|\ WeaveAction subclass initiates the weave action (`51`_)
    |srarr|\ TangleAction subclass initiates the tangle action (`54`_)
    |srarr|\ LoadAction subclass loads the document web (`57`_)

..

    ..  class:: small

        |loz| *Action class hierarchy - used to describe actions of the application (44)*. Used by: Base Class Definitions (`1`_)


Action Class
~~~~~~~~~~~~~

The ``Action`` class embodies the basic operations of **py-web-tool** .
The intent of this hierarchy is to both provide an easily expanded method of
adding new actions, but an easily specified list of actions for a particular
run of **py-web-tool** .

The overall process of the application is defined by an instance of ``Action``.
This instance may be the ``WeaveAction`` instance, the ``TangleAction`` instance
or a ``ActionSequence`` instance.

The instance is constructed during parsing of the input parameters.  Then the 
``Action`` class ``perform()`` method is called to actually perform the
action.  There are three standard ``Action`` instances available: an instance
that is a macro and does both tangling and weaving, an instance that excludes tangling,
and an instance that excludes weaving.  These correspond to the command-line options.

..  parsed-literal::

    anOp = SomeAction("name")
    anOp(*argparse.Namespace*)


The ``Action`` is the superclass for all actions.
An ``Action`` has a number of common attributes.

:name:
    A name for this action.
    
:options:
    The ``argparse.Namespace`` object.
    A LoadAction will update this with the ``Web`` object that was loaded.
    
!start:
    The time at which the action started.




..  _`45`:
..  rubric:: Action superclass has common features of all actions (45) =
..  parsed-literal::
    :class: code

    
    class Action:
        """An action performed by pyWeb."""
        start: float
        options: argparse.Namespace
        
        def \_\_init\_\_(self, name: str) -> None:
            self.name = name
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            
        def \_\_str\_\_(self) -> str:
            return f"{self.name!s} [{self.web!s}]"
            
        |srarr|\ Action call method actually does the real work (`46`_)
        
        |srarr|\ Action final summary of what was done (`47`_)
    

..

    ..  class:: small

        |loz| *Action superclass has common features of all actions (45)*. Used by: Action class hierarchy... (`44`_)


The ``__call__()`` method does the real work of the action.
For the superclass, it merely logs a message.  This is overridden 
by a subclass.


..  _`46`:
..  rubric:: Action call method actually does the real work (46) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self, options: argparse.Namespace) -> None:
        self.logger.info("Starting %s", self.name)
        self.options = options
        self.start = time.process\_time()
    

..

    ..  class:: small

        |loz| *Action call method actually does the real work (46)*. Used by: Action superclass... (`45`_)


The ``summary()`` method returns some basic processing
statistics for this action.


..  _`47`:
..  rubric:: Action final summary of what was done (47) =
..  parsed-literal::
    :class: code

    
    def duration(self) -> float:
        """Return duration of the action."""
        return (self.start and time.process\_time()-self.start) or 0
        
    def summary(self) -> str:
        return f"{self.name!s} in {self.duration():0.3f} sec."
    

..

    ..  class:: small

        |loz| *Action final summary of what was done (47)*. Used by: Action superclass... (`45`_)


ActionSequence Class
~~~~~~~~~~~~~~~~~~~~

A ``ActionSequence`` defines a composite action; it is a sequence of
other actions.  When the macro is performed, it delegates to the 
sub-actions.

The instance is created during parsing of input parameters.  An instance of
this class is one of
the three standard actions available; it generally is the default, "do everything" 
action.

This class overrides the ``perform()`` method of the superclass.  It also adds
an ``append()`` method that is used to construct the sequence of actions.



..  _`48`:
..  rubric:: ActionSequence subclass that holds a sequence of other actions (48) =
..  parsed-literal::
    :class: code

    
    class ActionSequence(Action):
        """An action composed of a sequence of other actions."""
        def \_\_init\_\_(self, name: str, opSequence: list[Action] \| None = None) -> None:
            super().\_\_init\_\_(name)
            if opSequence: self.opSequence = opSequence
            else: self.opSequence = []
            
        def \_\_str\_\_(self) -> str:
            return "; ".join([str(x) for x in self.opSequence])
            
        |srarr|\ ActionSequence call method delegates the sequence of ations (`49`_)
            
        |srarr|\ ActionSequence summary summarizes each step (`50`_)
    

..

    ..  class:: small

        |loz| *ActionSequence subclass that holds a sequence of other actions (48)*. Used by: Action class hierarchy... (`44`_)


Since the macro ``__call__()`` method delegates to other Actions,
it is possible to short-cut argument processing by using the Python
``*args`` construct to accept all arguments and pass them to each
sub-action.


..  _`49`:
..  rubric:: ActionSequence call method delegates the sequence of ations (49) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self, options: argparse.Namespace) -> None:
        super().\_\_call\_\_(options)
        for o in self.opSequence:
            o(self.options)
    

..

    ..  class:: small

        |loz| *ActionSequence call method delegates the sequence of ations (49)*. Used by: ActionSequence subclass... (`48`_)


The ``summary()`` method returns some basic processing
statistics for each step of this action.


..  _`50`:
..  rubric:: ActionSequence summary summarizes each step (50) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        return ", ".join([o.summary() for o in self.opSequence])
    

..

    ..  class:: small

        |loz| *ActionSequence summary summarizes each step (50)*. Used by: ActionSequence subclass... (`48`_)


WeaveAction Class
~~~~~~~~~~~~~~~~~~

The ``WeaveAction`` defines the action of weaving.  This action
logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.  If a ``Weaver`` was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

If the options include ``theWeaver``, that ``Weaver`` instance will be used.
Otherwise, the ``web.language()`` method function is used to guess what weaver to use.


..  _`51`:
..  rubric:: WeaveAction subclass initiates the weave action (51) =
..  parsed-literal::
    :class: code

    
    class WeaveAction(Action):
        """Weave the final document."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Weave")
            
        def \_\_str\_\_(self) -> str:
            return f"{self.name!s} [{self.web!s}, {self.options.theWeaver!s}]"
    
        |srarr|\ WeaveAction call method to pick the language (`52`_)
        
        |srarr|\ WeaveAction summary of language choice (`53`_)
    

..

    ..  class:: small

        |loz| *WeaveAction subclass initiates the weave action (51)*. Used by: Action class hierarchy... (`44`_)


The language is picked just prior to weaving.  It is either (1) the language
specified on the command line, or, (2) if no language was specified, a language
is selected based on the first few characters of the input.

Weaving can only raise an exception when there is a reference to a chunk that
is never defined.


..  _`52`:
..  rubric:: WeaveAction call method to pick the language (52) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self, options: argparse.Namespace) -> None:
        super().\_\_call\_\_(options)
        if not self.options.weaver: 
            # Examine first few chars of first chunk of web to determine language
            self.options.weaver = self.web.language() 
            self.logger.info("Using %s", self.options.theWeaver)
        self.options.theWeaver.reference\_style = self.options.reference\_style
        self.options.theWeaver.output = self.options.output
        try:
            self.options.theWeaver.set\_markup(self.options.weaver)
            self.options.theWeaver.emit(self.options.web)
            self.logger.info("Finished Normally")
        except Error as e:
            self.logger.error("Problems weaving document from %r (weave file is faulty).", self.options.web.web\_path)
            #raise
    

..

    ..  class:: small

        |loz| *WeaveAction call method to pick the language (52)*. Used by: WeaveAction subclass... (`51`_)


The ``summary()`` method returns some basic processing
statistics for the weave action.



..  _`53`:
..  rubric:: WeaveAction summary of language choice (53) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        if self.options.theWeaver and self.options.theWeaver.linesWritten > 0:
            return (
                f"{self.name!s} {self.options.theWeaver.linesWritten:d} lines in {self.duration():0.3f} sec."
            )
        return f"did not {self.name!s}"
    

..

    ..  class:: small

        |loz| *WeaveAction summary of language choice (53)*. Used by: WeaveAction subclass... (`51`_)


TangleAction Class
~~~~~~~~~~~~~~~~~~~

The ``TangleAction`` defines the action of tangling.  This operation
logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.  If a ``Weaver`` was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``theTangler``, with the ``Tangler`` instance to be used.


..  _`54`:
..  rubric:: TangleAction subclass initiates the tangle action (54) =
..  parsed-literal::
    :class: code

    
    class TangleAction(Action):
        """Tangle source files."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Tangle")
            
        |srarr|\ TangleAction call method does tangling of the output files (`55`_)
        
        |srarr|\ TangleAction summary method provides total lines tangled (`56`_)
    

..

    ..  class:: small

        |loz| *TangleAction subclass initiates the tangle action (54)*. Used by: Action class hierarchy... (`44`_)


Tangling can only raise an exception when a cross reference request (``@f``, ``@m`` or ``@u``)
occurs in a program code chunk.  Program code chunks are defined 
with any of ``@d`` or ``@o``  and use ``@{`` ``@}`` brackets.



..  _`55`:
..  rubric:: TangleAction call method does tangling of the output files (55) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self, options: argparse.Namespace) -> None:
        super().\_\_call\_\_(options)
        self.options.theTangler.include\_line\_numbers = self.options.tangler\_line\_numbers
        self.options.theTangler.output = self.options.output
        try:
            self.options.theTangler.emit(self.options.web)
        except Error as e:
            self.logger.error("Problems tangling outputs from %r (tangle files are faulty).", self.options.web.web\_path)
            #raise
    

..

    ..  class:: small

        |loz| *TangleAction call method does tangling of the output files (55)*. Used by: TangleAction subclass... (`54`_)


The ``summary()`` method returns some basic processing
statistics for the tangle action.


..  _`56`:
..  rubric:: TangleAction summary method provides total lines tangled (56) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        if self.options.theTangler and self.options.theTangler.linesWritten > 0:
            return (
                f"{self.name!s} {self.options.theTangler.totalLines:d} lines in {self.duration():0.3f} sec."
            )
        return f"did not {self.name!r}"
    

..

    ..  class:: small

        |loz| *TangleAction summary method provides total lines tangled (56)*. Used by: TangleAction subclass... (`54`_)



LoadAction Class
~~~~~~~~~~~~~~~~~~

The ``LoadAction`` defines the action of loading the web structure.  This action
uses the application's ``webReader`` to actually do the load.

An instance is created during parsing of the input parameters.  An instance of
this class is part of any of the weave, tangle and "do everything" action.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``webReader``, with the ``WebReader`` instance to be used.



..  _`57`:
..  rubric:: LoadAction subclass loads the document web (57) =
..  parsed-literal::
    :class: code

    
    class LoadAction(Action):
        """Load the source web."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Load")
            
        def \_\_str\_\_(self) -> str:
            return f"Load [{self.webReader!s}, {self.options.web!s}]"
            
        |srarr|\ LoadAction call method loads the input files (`58`_)
        
        |srarr|\ LoadAction summary provides lines read (`59`_)
    

..

    ..  class:: small

        |loz| *LoadAction subclass loads the document web (57)*. Used by: Action class hierarchy... (`44`_)


Trying to load the web involves two steps, either of which can raise 
exceptions due to incorrect inputs.

1.  The ``WebReader`` class ``load()`` method can raise exceptions for a number of 
    syntax errors as well as OS errors.

    -     Missing closing brackets (``@}``, ``@]`` or ``@>``).

    -     Missing opening bracket (``@{`` or ``@[``) after a chunk name (``@d`` or ``@o``).

    -     Extra brackets (``@{``, ``@[``, ``@}``, ``@]``).

    -     Extra ``@|``.

    -     The input file does not exist or is not readable.

2.  The ``Web`` class ``createUsedBy()`` method can raise an exception when a 
    chunk reference cannot be resolved to a named chunk.


..  _`58`:
..  rubric:: LoadAction call method loads the input files (58) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self, options: argparse.Namespace) -> None:
        super().\_\_call\_\_(options)
        self.webReader = self.options.webReader
        self.webReader.command = self.options.command
        self.webReader.permitList = self.options.permitList
        self.logger.debug("Reader Class %s", self.webReader.\_\_class\_\_.\_\_name\_\_)
    
        error = f"Problems with source file {self.options.source\_path!r}, no output produced."
        try:
            chunks = self.webReader.load(self.options.source\_path)
            if self.webReader.errors != 0:
                raise Error("Syntax Errors in the Web")
            self.logger.debug("Read %d Chunks", len(chunks))
            self.options.web = Web(chunks)
            self.options.web.web\_path = self.options.source\_path
            self.logger.debug("Web contains %3d chunks", len(self.options.web.chunks))
            self.logger.debug("Web defines  %3d files", len(self.options.web.files))
            self.logger.debug("Web defines  %3d macros", len(self.options.web.macros))
            self.logger.debug("Web defines  %3d names", len(self.options.web.userids))
        except Error as e:
            self.logger.error(error)
            raise  # Could not be parsed or built.
        except IOError as e:
            self.logger.error(error)
            raise
    

..

    ..  class:: small

        |loz| *LoadAction call method loads the input files (58)*. Used by: LoadAction subclass... (`57`_)


The ``summary()`` method returns some basic processing
statistics for the load action.


..  _`59`:
..  rubric:: LoadAction summary provides lines read (59) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        return (
            f"{self.name!s} {self.webReader.totalLines:d} lines from {self.webReader.totalFiles:d} files in {self.duration():0.3f} sec."
        )
    

..

    ..  class:: small

        |loz| *LoadAction summary provides lines read (59)*. Used by: LoadAction subclass... (`57`_)



**pyWeb** Module File
------------------------

The **pyWeb** application file is shown below:


..  _`60`:
..  rubric:: pyweb.py (60) =
..  parsed-literal::
    :class: code

    |srarr|\ Overheads (`62`_), |srarr|\ (`63`_), |srarr|\ (`64`_)
    |srarr|\ Imports (`2`_), |srarr|\ (`8`_), |srarr|\ (`16`_), |srarr|\ (`30`_), |srarr|\ (`35`_), |srarr|\ (`38`_), |srarr|\ (`40`_), |srarr|\ (`61`_), |srarr|\ (`65`_), |srarr|\ (`70`_)
    |srarr|\ Base Class Definitions (`1`_)
    |srarr|\ Application Class (`66`_)
    |srarr|\ Logging Setup (`71`_), |srarr|\ (`72`_)
    |srarr|\ Interface Functions (`74`_)

..

    ..  class:: small

        |loz| *pyweb.py (60)*.


The `Overheads`_ are described below, they include things like:

-     shell escape

-     doc string

-     ``__version__`` setting


`Python Library Imports`_ are actually scattered in various places in this description.


The more important elements are described in separate sections:

-     Base Class Definitions

-     Application Class and Main Functions

-     Interface Functions

Python Library Imports
~~~~~~~~~~~~~~~~~~~~~~~

Numerous Python library modules are used by this application. 

A few are listed here because they're used widely. Others are listed
closer to where they're referenced.

-   The ``os`` module provide os-specific file and path manipulations; it is used
    to transform the input file name into the output file name as well as track down file modification
    times.

-   The ``time`` module provides a handy current-time string; this is used
    to by the HTML Weaver to write a closing timestamp on generated HTML files, 
    as well as log messages.
    
-   The ``datetime`` module is used to format times, phasing out use of ``time``.

-   The ``types`` module is used to get at ``SimpleNamespace`` for configuration.




..  _`61`:
..  rubric:: Imports (61) +=
..  parsed-literal::
    :class: code

    
    import os
    import time
    import datetime
    import types
    

..

    ..  class:: small

        |loz| *Imports (61)*. Used by: pyweb.py (`60`_)


Note that ``os.path``, ``time``, ``datetime`` and ``platform```
are provided in the expression context.

Overheads
~~~~~~~~~~~~

The shell escape is provided so that the user can define this
file as executable, and launch it directly from their shell.
The shell reads the first line of a file; when it finds the ``'#!'`` shell
escape, the remainder of the line is taken as the path to the binary program
that should be run.  The shell runs this binary, providing the 
file as standard input.



..  _`62`:
..  rubric:: Overheads (62) =
..  parsed-literal::
    :class: code

    #!/usr/bin/env python

..

    ..  class:: small

        |loz| *Overheads (62)*. Used by: pyweb.py (`60`_)


A Python ``__doc__`` string provides a standard vehicle for documenting
the module or the application program.  The usual style is to provide
a one-sentence summary on the first line.  This is followed by more 
detailed usage information.



..  _`63`:
..  rubric:: Overheads (63) +=
..  parsed-literal::
    :class: code

    """py-web-tool Literate Programming.
    
    Yet another simple literate programming tool derived from \*\*nuweb\*\*, 
    implemented entirely in Python.
    With a suitable configuration, this weaves documents with any markup language,
    and tangles source files for any programming language.
    """

..

    ..  class:: small

        |loz| *Overheads (63)*. Used by: pyweb.py (`60`_)


The keyword cruft is a standard way of placing version control information into
a Python module so it is preserved.  See PEP (Python Enhancement Proposal) #8 for information
on recommended styles.


We also sneak in a "DO NOT EDIT" warning that belongs in all generated application 
source files.


..  _`64`:
..  rubric:: Overheads (64) +=
..  parsed-literal::
    :class: code

    \_\_version\_\_ = """3.2"""
    
    ### DO NOT EDIT THIS FILE!
    ### It was created by /Users/slott/Documents/Projects/py-web-tool/bootstrap/pyweb.py, \_\_version\_\_='3.1'.
    ### From source pyweb.w modified Sat Jun 18 11:04:10 2022.
    ### In working directory '/Users/slott/Documents/Projects/py-web-tool/src'.

..

    ..  class:: small

        |loz| *Overheads (64)*. Used by: pyweb.py (`60`_)



The Application Class
-----------------------

The ``Application`` class is provided so that the ``Action`` instances
have an overall application to update.  This allows the ``WeaveAction`` to 
provide the selected ``Weaver`` instance to the application.  It also provides a
central location for the various options and alternatives that might be accepted from
the command line.


The constructor creates a default ``argparse.Namespace`` with values
suitable for weaving and tangling.

The ``parseArgs()`` method uses the ``sys.argv`` sequence to 
parse the command line arguments and update the options.  This allows a
program to pre-process the arguments, passing other arguments to this module.


The ``process()`` method processes a list of files.  This is either
the list of files passed as an argument, or it is the list of files
parsed by the ``parseArgs()`` method.


The ``parseArgs()`` and process() functions are separated so that
another application can ``import pyweb``, bypass command-line parsing, yet still perform
the basic actionss simply and consistently.
For example:

..  parsed-literal::

    import pyweb, argparse
    
    p = argparse.ArgumentParser()
    *argument definition*
    config = p.parse_args()
    
    a = pyweb.Application()
    *Configure the Application based on options*
    a.process(config)


The ``main()`` function creates an ``Application`` instance and
calls the ``parseArgs()`` and ``process()`` methods to provide the
expected default behavior for this module when it is used as the main program.

The configuration can be either a ``types.SimpleNamespace`` or an
``argparse.Namespace`` instance.



..  _`65`:
..  rubric:: Imports (65) +=
..  parsed-literal::
    :class: code

    import argparse
    

..

    ..  class:: small

        |loz| *Imports (65)*. Used by: pyweb.py (`60`_)



..  _`66`:
..  rubric:: Application Class (66) =
..  parsed-literal::
    :class: code

    
    class Application:
        def \_\_init\_\_(self) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            |srarr|\ Application default options (`67`_)
            
        |srarr|\ Application parse command line (`68`_)
        |srarr|\ Application class process all files (`69`_)
    

..

    ..  class:: small

        |loz| *Application Class (66)*. Used by: pyweb.py (`60`_)


The first part of parsing the command line is 
setting default values that apply when parameters are omitted.
The default values are set as follows:

:defaults:
    A default configuration.

:webReader:
    is the ``WebReader`` instance created for the current
    input file.
 
:doWeave:
    instance of ``Action``
    that does weaving only.

:doTangle:
    instance of ``Action``
    that does tangling only.
    
:theAction:
    is an instance of ``Action`` that describes
    the default overall action: load, tangle and weave.  This is the default unless
    overridden by an option.
    
Here are the configuration values. These are attributes
of the ``argparse.namespace`` default as well as the updated
namespace returned by ``parseArgs()``.

:verbosity:
    Either ``logging.INFO``, ``logging.WARN`` or ``logging.DEBUG``
    
:command:
    is set to ``@`` as the  default command introducer.

:permit:
    The raw list of permitted command characters, perhaps ``'i'``.
    
:permitList:
    provides a list of commands that are permitted
    to fail.  Typically this is empty, or contains ``@i`` to allow the include
    command to fail.

:files:
    is the final list of argument files from the command line; 
    these will be processed unless overridden in the call to ``process()``.

!skip:
    a list of steps to skip: perhaps ``'w'`` or ``'t'`` to skip weaving or tangling.
    
:weaver:
    the short name of the weaver.
    
:theTangler:
    is set to a ``TanglerMake`` instance 
    to create the output files.

:theWeaver:
    is set to an instance of a subclass of ``Weaver`` based on ``weaver``


..  _`67`:
..  rubric:: Application default options (67) =
..  parsed-literal::
    :class: code

    
    self.defaults = argparse.Namespace(
        verbosity=logging.INFO,
        command='@',
        weaver='rst', 
        skip='',  # Don't skip any steps
        permit='',  # Don't tolerate missing includes
        reference='s',  # Simple references
        tangler\_line\_numbers=False,
        output=Path.cwd(),
        )
    
    # Primitive Actions
    self.loadOp = LoadAction()
    self.weaveOp = WeaveAction()
    self.tangleOp = TangleAction()
    
    # Composite Actions
    self.doWeave = ActionSequence("load and weave", [self.loadOp, self.weaveOp])
    self.doTangle = ActionSequence("load and tangle", [self.loadOp, self.tangleOp])
    self.theAction = ActionSequence("load, tangle and weave", [self.loadOp, self.tangleOp, self.weaveOp])

..

    ..  class:: small

        |loz| *Application default options (67)*. Used by: Application Class... (`66`_)


The algorithm for parsing the command line parameters uses the built in
``argparse`` module.  We have to build a parser, define the options,
and the parse the command-line arguments, updating the default namespace.

We further expand on the arguments. This transforms simple strings into object
instances.



..  _`68`:
..  rubric:: Application parse command line (68) =
..  parsed-literal::
    :class: code

    
    def parseArgs(self, argv: list[str]) -> argparse.Namespace:
        p = argparse.ArgumentParser()
        p.add\_argument("-v", "--verbose", dest="verbosity", action="store\_const", const=logging.INFO)
        p.add\_argument("-s", "--silent", dest="verbosity", action="store\_const", const=logging.WARN)
        p.add\_argument("-d", "--debug", dest="verbosity", action="store\_const", const=logging.DEBUG)
        p.add\_argument("-c", "--command", dest="command", action="store")
        p.add\_argument("-w", "--weaver", dest="weaver", action="store")
        p.add\_argument("-x", "--except", dest="skip", action="store", choices=('w', 't'))
        p.add\_argument("-p", "--permit", dest="permit", action="store")
        p.add\_argument("-r", "--reference", dest="reference", action="store", choices=('t', 's'))
        p.add\_argument("-n", "--linenumbers", dest="tangler\_line\_numbers", action="store\_true")
        p.add\_argument("-o", "--output", dest="output", action="store", type=Path)
        p.add\_argument("-V", "--Version", action='version', version=f"py-web-tool pyweb.py {\_\_version\_\_}")
        p.add\_argument("files", nargs='+', type=Path)
        config = p.parse\_args(argv, namespace=self.defaults)
        self.expand(config)
        return config
        
    def expand(self, config: argparse.Namespace) -> argparse.Namespace:
        """Translate the argument values from simple text to useful objects.
        Weaver. Tangler. WebReader.
        """
        match config.reference:
            case 't':
                config.reference\_style = TransitiveReference() 
            case 's':
                config.reference\_style = SimpleReference()
            case \_:
                raise Error("Improper configuration")
    
        # Weaver & Tangler
        config.theWeaver = Weaver(config.output)
        config.theTangler = TanglerMake(config.output)
        
        if config.permit:
            # save permitted errors, usual case is \`\`-pi\`\` to permit \`\`@i\`\` include errors
            config.permitList = [f'{config.command!s}{c!s}' for c in config.permit]
        else:
            config.permitList = []
    
        config.webReader = WebReader()
    
        return config
    

..

    ..  class:: small

        |loz| *Application parse command line (68)*. Used by: Application Class... (`66`_)


The ``process()`` function uses the current ``Application`` settings
to process each file as follows:

1.  Create a new ``WebReader`` for the ``Application``, providing
    the parameters required to process the input file.

2.  Create a ``Web`` instance, *w* 
    and set the Web's *sourceFileName* from the WebReader's *filePath*.

3.  Perform the given command, typically a ``ActionSequence``, 
    which does some combination of load, tangle the output files and
    weave the final document in the target language; if
    necessary, examine the ``Web`` to determine the documentation language.

4.  Print a performance summary line that shows lines processed per second.

In the event of failure in any of the major processing steps, 
a summary message is produced, to clarify the state of 
the output files, and the exception is reraised.
The re-raising is done so that all exceptions are handled by the 
outermost main program.


..  _`69`:
..  rubric:: Application class process all files (69) =
..  parsed-literal::
    :class: code

    
    def process(self, config: argparse.Namespace) -> None:
        root = logging.getLogger()
        root.setLevel(config.verbosity)
        self.logger.debug("Setting root log level to %r", logging.getLevelName(root.getEffectiveLevel()))
        
        if config.command:
            self.logger.debug("Command character %r", config.command)
            
        if config.skip:
            if config.skip.lower().startswith('w'):  # not weaving == tangling
                self.theAction = self.doTangle
            elif config.skip.lower().startswith('t'):  # not tangling == weaving
                self.theAction = self.doWeave
            else:
                raise Exception(f"Unknown -x option {config.skip!r}")
    
        for f in config.files:
            self.logger.info("%s %r", self.theAction.name, f)
            config.source\_path = f
            self.theAction(config)
            self.logger.info(self.theAction.summary())
    

..

    ..  class:: small

        |loz| *Application class process all files (69)*. Used by: Application Class... (`66`_)


Logging Setup
--------------

We'll create a logging context manager. This allows us to wrap the ``main()`` 
function in an explicit ``with`` statement that assures that logging is
configured and cleaned up politely.


..  _`70`:
..  rubric:: Imports (70) +=
..  parsed-literal::
    :class: code

    
    import logging
    import logging.config
    

..

    ..  class:: small

        |loz| *Imports (70)*. Used by: pyweb.py (`60`_)


This has two configuration approaches. If a positional argument is given,
that dictionary is used for ``logging.config.dictConfig``. Otherwise,
keyword arguments are provided to ``logging.basicConfig``.

A subclass might properly load a dictionary 
encoded in YAML and use that with ``logging.config.dictConfig``.


..  _`71`:
..  rubric:: Logging Setup (71) =
..  parsed-literal::
    :class: code

    
    class Logger:
        def \_\_init\_\_(self, dict\_config: dict[str, Any] \| None = None, \*\*kw\_config: Any) -> None:
            self.dict\_config = dict\_config
            self.kw\_config = kw\_config
            
        def \_\_enter\_\_(self) -> "Logger":
            if self.dict\_config:
                logging.config.dictConfig(self.dict\_config)
            else:
                logging.basicConfig(\*\*self.kw\_config)
            return self
            
        def \_\_exit\_\_(self, \*args: Any) -> Literal[False]:
            logging.shutdown()
            return False

..

    ..  class:: small

        |loz| *Logging Setup (71)*. Used by: pyweb.py (`60`_)


Here's a sample logging setup. This creates a simple console handler and 
a formatter that matches the ``basicConfig`` formatter.

It defines the root logger plus two overrides for class loggers that might be
used to gather additional information.


..  _`72`:
..  rubric:: Logging Setup (72) +=
..  parsed-literal::
    :class: code

    
    log\_config = {
        'version': 1,
        'disable\_existing\_loggers': False, # Allow pre-existing loggers to work.
        'style': '{',
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'stream': 'ext://sys.stderr',
                'formatter': 'basic',
            },
        },
        'formatters': {
            'basic': {
                'format': "{levelname}:{name}:{message}",
                'style': "{",
            }
        },
        
        'root': {'handlers': ['console'], 'level': logging.INFO,},
        
        # For specific debugging support...
        'loggers': {
            'Weaver': {'level': logging.DEBUG},
            'WebReader': {'level': logging.INFO},
            'TanglerMake': {'level': logging.DEBUG},
            'Web': {'level': logging.DEBUG},
        },
    }

..

    ..  class:: small

        |loz| *Logging Setup (72)*. Used by: pyweb.py (`60`_)


This seems a bit verbose. The following configuration file might be better.


..  _`73`:
..  rubric:: logging.toml (73) =
..  parsed-literal::
    :class: code

    
    version = 1
    disable\_existing\_loggers = false
    
    [root]
    handlers = [ "console",]
    level = "INFO"
    
    [handlers.console]
    class = "logging.StreamHandler"
    stream = "ext://sys.stderr"
    formatter = "basic"
    
    [formatters.basic]
    format = "{levelname}:{name}:{message}"
    style = "{"
    
    [loggers.Weaver]
    level = "DEBUG"
    
    [loggers.WebReader]
    level = "INFO"
    
    [loggers.TanglerMake]
    level = "DEBUG"
    }
    
    We can load this with 
    
    ..  parsed-literal::
    
        log\_config = toml.load(Path("logging.toml"))
    
    This makes it slightly easier to add and change debuging alternatives.
    Rather then use the \`\`-v\`\` and \`\`-d\`\` options, a \`\`-l logging.toml\`\` 
    options can be used to provide non-default config values. 
    
    Also, we might want a decorator to define loggers more consistently for each class definition.
    
    
    The Main Function
    ------------------
    
    The top-level interface is the \`\`main()\`\` function.
    This function creates an \`\`Application\`\` instance.
    
    The \`\`Application\`\` object parses the command-line arguments.
    Then the \`\`Application\`\` object does the requested processing.
    This two-step process allows for some dependency injection to customize argument processing.
    
    We might also want to parse a logging configuration file, as well
    as a weaver template configuration file.
    

..

    ..  class:: small

        |loz| *logging.toml (73)*.

..  _`74`:
..  rubric:: Interface Functions (74) =
..  parsed-literal::
    :class: code

    
    def main(argv: list[str] = sys.argv[1:]) -> None:
        a = Application()
        config = a.parseArgs(argv)
        a.process(config)
    
    if \_\_name\_\_ == "\_\_main\_\_":
        with Logger(log\_config):
            main()

..

    ..  class:: small

        |loz| *Interface Functions (74)*. Used by: pyweb.py (`60`_)


This can be extended by doing something like the following.

1.  Subclass ``Weaver`` create a subclass with different templates.

2.  Update the ``pyweb.weavers`` dictionary.

3.  Call ``pyweb.main()`` to run the existing
    main program with extra classes available to it.


..  parsed-literal::

    import pyweb
    class MyWeaver(HTML):
       *Any template changes*
     
    pyweb.weavers['myweaver']= MyWeaver()
    pyweb.main()


This will create a variant on **py-web-tool** that will handle a different
weaver via the command-line option ``-w myweaver``.


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

Note that the last line really does set an environment variable and run 
the ``pytest`` tool on a single line.


..  py-web-tool/src/scripts.w

Handy Scripts and Other Files
=================================================

Two aditional scripts, ``tangle.py`` and ``weave.py``, are provided as examples 
which can be customized and extended.

``tangle.py`` Script
---------------------

This script shows a simple version of Tangling.  This has a permitted 
error for '@i' commands to allow an include file (for example test results)
to be omitted from the tangle operation.

Note the general flow of this top-level script.

1.	Create the logging context.

2.	Create the options. This hard-coded object is a stand-in for 
	parsing command-line options. 
	
3.	Create the web object.

4.	For each action (``LoadAction`` and ``TangleAction`` in this example)
	Set the web, set the options, execute the callable action, and write
	a summary.


..  _`75`:
..  rubric:: tangle.py (75) =
..  parsed-literal::
    :class: code

    #!/usr/bin/env python3
    """Sample tangle.py script."""
    import argparse
    import logging
    from pathlib import Path
    import pyweb
    
    def main(source: Path) -> None:
        with pyweb.Logger(pyweb.log\_config):
            logger = logging.getLogger(\_\_file\_\_)
        
            options = argparse.Namespace(
                source\_path=source,
                output=source.parent,
                verbosity=logging.INFO,
                command='@',
                permitList=['@i'],
                tangler\_line\_numbers=False,
                reference\_style=pyweb.SimpleReference(),
                theTangler=pyweb.TanglerMake(),
                webReader=pyweb.WebReader(),
            )
                
            for action in pyweb.LoadAction(), pyweb.TangleAction():
                action(options)
                logger.info(action.summary())
    
    if \_\_name\_\_ == "\_\_main\_\_":
        main(Path("examples/test\_rst.w"))

..

    ..  class:: small

        |loz| *tangle.py (75)*.


``weave.py`` Script
---------------------

This script shows a simple version of Weaving.  This shows how
to define a customized set of templates for a different markup language.


A customized weaver generally has three parts.


..  _`76`:
..  rubric:: weave.py (76) =
..  parsed-literal::
    :class: code

    |srarr|\ weave.py overheads for correct operation of a script (`77`_)
    
    |srarr|\ weave.py custom weaver definition to customize the Weaver being used (`78`_)
    
    |srarr|\ weaver.py processing: load and weave the document (`79`_)

..

    ..  class:: small

        |loz| *weave.py (76)*.



..  _`77`:
..  rubric:: weave.py overheads for correct operation of a script (77) =
..  parsed-literal::
    :class: code

    #!/usr/bin/env python3
    """Sample weave.py script."""
    import argparse
    import logging
    import string
    from pathlib import Path
    import pyweb

..

    ..  class:: small

        |loz| *weave.py overheads for correct operation of a script (77)*. Used by: weave.py (`76`_)



..  _`78`:
..  rubric:: weave.py custom weaver definition to customize the Weaver being used (78) =
..  parsed-literal::
    :class: code

    
    class MyHTML(pyweb.Weaver):
        """HTML formatting templates."""
        extension = ".html"
        
        cb\_template = string.Template("""<a name="pyweb${seq}"></a>
        <!--line number ${lineNumber}-->
        <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
        <pre><code>\\n""")
    
        ce\_template = string.Template("""
        </code></pre>
        <p>&loz; <em>${fullName}</em> (${seq}).
        ${references}
        </p>\\n""")
            
        fb\_template = string.Template("""<a name="pyweb${seq}"></a>
        <!--line number ${lineNumber}-->
        <p>\`\`${fullName}\`\` (${seq})&nbsp;${concat}</p>
        <pre><code>\\n""") # Prevent indent
            
        fe\_template = string.Template( """</code></pre>
        <p>&loz; \`\`${fullName}\`\` (${seq}).
        ${references}
        </p>\\n""")
            
        ref\_item\_template = string.Template(
        '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
        )
        
        ref\_template = string.Template('  Used by ${refList}.' )
                
        refto\_name\_template = string.Template(
        '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em>&nbsp;(${seq})</a>'
        )
        refto\_seq\_template = string.Template('<a href="#pyweb${seq}">(${seq})</a>')
     
        xref\_head\_template = string.Template("<dl>\\n")
        xref\_foot\_template = string.Template("</dl>\\n")
        xref\_item\_template = string.Template("<dt>${fullName}</dt><dd>${refList}</dd>\\n")
        
        name\_def\_template = string.Template('<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>')
        name\_ref\_template = string.Template('<a href="#pyweb${seq}">${seq}</a>')

..

    ..  class:: small

        |loz| *weave.py custom weaver definition to customize the Weaver being used (78)*. Used by: weave.py (`76`_)



..  _`79`:
..  rubric:: weaver.py processing: load and weave the document (79) =
..  parsed-literal::
    :class: code

    
    def main(source: Path) -> None:
        with pyweb.Logger(pyweb.log\_config):
            logger = logging.getLogger(\_\_file\_\_)
        
            options = argparse.Namespace(
                source\_path=source,
                output=source.parent,
                verbosity=logging.INFO,
                weaver="html",
                command='@',
                permitList=[],
                tangler\_line\_numbers=False,
                reference\_style=pyweb.SimpleReference(),
                theWeaver=MyHTML(),
                webReader=pyweb.WebReader(),
            )
            
            for action in pyweb.LoadAction(), pyweb.WeaveAction():
                action(options)
                logger.info(action.summary())
    
    if \_\_name\_\_ == "\_\_main\_\_":
        main(Path("examples/test\_rst.w"))

..

    ..  class:: small

        |loz| *weaver.py processing: load and weave the document (79)*. Used by: weave.py (`76`_)



..    py-web-tool/src/todo.w 

 
To Do
=======

1.  Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
    Rename the project from ``py-web-tool`` to ``py-lpweb``.
    
2.  Switch to jinja templates.

    -   See the ``weave.py`` example. 
        Defining templates in the source removes any need for a command-line option. A silly optimization.
        Setting the "command character" to something other than ``@`` can be done in the configuration, too.

    -   With Jinjda templates can be provided via
        a Jinja configuration (there are many choices.) By stepping away from the ``string.Template``,
        we can incorporate list-processing ``{%for%}...{%endfor%}`` construct that 
        pushes some processing into the template.

#.  Separate TOML-based logging configuration file would be helpful. 
    Must be separate from template configuration.

#.  Rethink the presentation. Are |loz| and |srarr| REALLY necessary? 
    Can we use ◊ and → now that Unicode is more universal?
    And why ``'\N{LOZENGE}'``? There's a nice ``'\N{END OF PROOF}'`` symbol we could use.
    Remove the unused ``header``, ``docBegin()``, and ``docEnd()``. 
    
#.  Tangling can include non-woven content. More usefully, Weaving can exclude some chunks.
    The use case is a book chapter with test cases that are **not** woven into the text.
    Add an option to define tangle-only chunks that are NOT woven into the final document. 
    
#.  Update the ``-indent`` option on @d chunks to accept a numeric argument with the 
    specific indentation value. This becomes a kind of "noindent" with a given
    value. The ``-noindent`` would then be the same as ``-indent 0``.  
    Currently, `-indent` and `-noindent` are true/false flags. 
    
#.  We might want to decompose the ``impl.w`` file: it's huge.
    
#.  We might want to interleave code and test into a document that presents both
    side-by-side. We can route to multiple files.
    It's a little awkward to create tangled files in multiple directories;
    We'd have to use ``../tests/whatever.py``, **assuming** we were always using ``-o src``.

#.  Fix name definition order. There's no **good** reason why a full name must
    be first and elided names defined later.

#.  Offer a basic XHTML template that uses ``CDATA`` sections instead of quoting.
    Does require the standard quoting for the ``CDATA`` end tag.

#.  The ``createUsedBy()`` method can be done incrementally by 
    accumulating a list of forward references to chunks; as each
    new chunk is added, any references to the chunk are removed from
    the forward references list, and a call is made to the Web's
    setUsage method.  References backward to already existing chunks
    are easily resolved with a simple lookup.
    
#.  Note that the overall ``Web`` is a bit like a ``NamedChunk`` that contains ``Chunks``.
    This similarity could be factored out. 
    While this will create a more proper **Composition** pattern implementation, it
    leads to the question of why nest ``@d`` or ``@o`` chunks in the first place?


..    py-web-tool/src/done.w 

Change Log
===========

Changes for 3.2

-   Replaced weaving process with Jinja templates.

-   Dramatic redesign to Class, Chunk, and Command class hierarchies.

-   Dramatic redesign to Emitters.

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
    ``@d Web weave...`` ``weaveChunk()``.  This was moved into a template.

-   Add an ``__enter__()`` and ``__exit__()`` to make an ``Emitter``
    into a proper Context Manager that can be used with a ``with`` statement.
    
-   Add the ``-n`` option to include tangler line numbers if the ``@o`` includes
    the comment characters.

-   Cleanup the ``TanglerMake`` unit tests to remove the ``sleep()`` 
    used to assure that the timestamps really are different.
    
-   Cleanup the syntax for adding a comment template to ``@o``. Use ``-start`` and ``-end``
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

-   Removed the ``@O`` command; it was essentially a variant template for LaTeX.

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



Indices
=======

Files
------


:logging.toml:
    |srarr|\ (`73`_)
:pyweb.py:
    |srarr|\ (`60`_)
:tangle.py:
    |srarr|\ (`75`_)
:weave.py:
    |srarr|\ (`76`_)



Macros
------


:Action call method actually does the real work:
    |srarr|\ (`46`_)
:Action class hierarchy - used to describe actions of the application:
    |srarr|\ (`44`_)
:Action final summary of what was done:
    |srarr|\ (`47`_)
:Action superclass has common features of all actions:
    |srarr|\ (`45`_)
:ActionSequence call method delegates the sequence of ations:
    |srarr|\ (`49`_)
:ActionSequence subclass that holds a sequence of other actions:
    |srarr|\ (`48`_)
:ActionSequence summary summarizes each step:
    |srarr|\ (`50`_)
:Application Class:
    |srarr|\ (`66`_)
:Application class process all files:
    |srarr|\ (`69`_)
:Application default options:
    |srarr|\ (`67`_)
:Application parse command line:
    |srarr|\ (`68`_)
:Base Class Definitions:
    |srarr|\ (`1`_)
:Chunk class hierarchy - used to describe input chunks:
    |srarr|\ (`4`_)
:Command class hierarchy - used to describe individual commands:
    |srarr|\ (`6`_)
:Emitter Superclass:
    |srarr|\ (`9`_)
:Emitter class hierarchy - used to control output files:
    |srarr|\ (`7`_)
:Emitter indent control: set, clear and reset:
    |srarr|\ (`15`_)
:Emitter write a block of code with proper indents:
    |srarr|\ (`14`_)
:Error class - defines the errors raised:
    |srarr|\ (`21`_)
:Imports:
    |srarr|\ (`2`_) |srarr|\ (`8`_) |srarr|\ (`16`_) |srarr|\ (`30`_) |srarr|\ (`35`_) |srarr|\ (`38`_) |srarr|\ (`40`_) |srarr|\ (`61`_) |srarr|\ (`65`_) |srarr|\ (`70`_)
:Interface Functions:
    |srarr|\ (`74`_)
:LoadAction call method loads the input files:
    |srarr|\ (`58`_)
:LoadAction subclass loads the document web:
    |srarr|\ (`57`_)
:LoadAction summary provides lines read:
    |srarr|\ (`59`_)
:Logging Setup:
    |srarr|\ (`71`_) |srarr|\ (`72`_)
:Option Parser class - locates optional values on commands:
    |srarr|\ (`41`_) |srarr|\ (`42`_) |srarr|\ (`43`_)
:Overheads:
    |srarr|\ (`62`_) |srarr|\ (`63`_) |srarr|\ (`64`_)
:Quoting rule definitions -- functions used by templates:
    |srarr|\ (`11`_)
:RST Templates -- these are the default templates:
    |srarr|\ (`12`_)
:Reference class hierarchy - strategies for weaving references to a chunk:
    |srarr|\ (`18`_) |srarr|\ (`19`_) |srarr|\ (`20`_)
:TangleAction call method does tangling of the output files:
    |srarr|\ (`55`_)
:TangleAction subclass initiates the tangle action:
    |srarr|\ (`54`_)
:TangleAction summary method provides total lines tangled:
    |srarr|\ (`56`_)
:Tangler Subclass -- emits the output files:
    |srarr|\ (`13`_)
:TanglerMake Subclass -- extends Tangler to avoid touching files that didn't change:
    |srarr|\ (`17`_)
:The TypeId Helper:
    |srarr|\ (`5`_)
:Tokenizer class - breaks input into tokens:
    |srarr|\ (`39`_)
:WeaveAction call method to pick the language:
    |srarr|\ (`52`_)
:WeaveAction subclass initiates the weave action:
    |srarr|\ (`51`_)
:WeaveAction summary of language choice:
    |srarr|\ (`53`_)
:Weaver Subclass -- Uses Jinja templates to weave documentation:
    |srarr|\ (`10`_)
:Web class - describes the overall "web" of chunks:
    |srarr|\ (`3`_)
:WebReader class - parses the input file, building the Web structure:
    |srarr|\ (`22`_)
:WebReader command literals:
    |srarr|\ (`37`_)
:WebReader handle a command string:
    |srarr|\ (`23`_) |srarr|\ (`33`_)
:WebReader load the web:
    |srarr|\ (`36`_)
:WebReader location in the input stream:
    |srarr|\ (`34`_)
:add a reference command to the current chunk:
    |srarr|\ (`29`_)
:add an expression command to the current chunk:
    |srarr|\ (`31`_)
:assign user identifiers to the current chunk:
    |srarr|\ (`28`_)
:double at-sign replacement, append this character to previous TextCommand:
    |srarr|\ (`32`_)
:finish a chunk, start a new Chunk adding it to the web:
    |srarr|\ (`27`_)
:include another file:
    |srarr|\ (`26`_)
:start a NamedChunk or NamedDocumentChunk, adding it to the web:
    |srarr|\ (`25`_)
:start an OutputChunk, adding it to the web:
    |srarr|\ (`24`_)
:weave.py custom weaver definition to customize the Weaver being used:
    |srarr|\ (`78`_)
:weave.py overheads for correct operation of a script:
    |srarr|\ (`77`_)
:weaver.py processing: load and weave the document:
    |srarr|\ (`79`_)



User Identifiers
----------------


:Action:
    [`45`_] `48`_ `51`_ `54`_ `57`_
:ActionSequence:
    [`48`_] `67`_
:Application:
    [`66`_] `73`_ `74`_
:Chunk:
    `3`_ [`4`_] `6`_ `12`_ `13`_ `17`_ `18`_ `19`_ `20`_ `22`_ `26`_ `27`_ `29`_ `36`_
:Error:
    `3`_ `6`_ [`21`_] `25`_ `26`_ `31`_ `43`_ `52`_ `55`_ `58`_ `68`_
:LoadAction:
    [`57`_] `67`_ `75`_ `79`_
:NamedChunk:
    `3`_ [`4`_] `6`_ `12`_ `25`_
:NamedDocumentChunk:
    [`4`_] `6`_ `25`_
:OutputChunk:
    `3`_ [`4`_] `12`_ `24`_
:TangleAction:
    [`54`_] `67`_ `75`_
:Tokenizer:
    `22`_ `36`_ [`39`_]
:TypeId:
    `4`_ [`5`_] `6`_
:WeaveAction:
    [`51`_] `67`_ `79`_
:Web:
    [`3`_] `4`_ `6`_ `9`_ `10`_ `13`_ `17`_ `36`_ `58`_ `72`_
:WebReader:
    [`22`_] `26`_ `68`_ `72`_ `73`_ `75`_ `79`_
:__version__:
    `31`_ [`64`_] `68`_
:addIndent:
    `6`_ [`15`_]
:argparse:
    `45`_ `46`_ `49`_ `52`_ `55`_ `58`_ [`65`_] `67`_ `68`_ `69`_ `75`_ `77`_ `79`_
:builtins:
    [`30`_] `31`_
:clrIndent:
    `6`_ [`15`_]
:codeBlock:
    `6`_ [`14`_]
:datetime:
    `31`_ [`61`_]
:duration:
    [`47`_] `53`_ `56`_ `59`_
:expand:
    [`68`_]
:expect:
    `24`_ `25`_ `29`_ `31`_ [`33`_]
:handleCommand:
    [`23`_] `36`_
:load:
    `26`_ [`36`_] `58`_ `67`_ `73`_
:location:
    `4`_ `6`_ `23`_ `24`_ `25`_ `28`_ `31`_ `33`_ [`34`_] `36`_
:logging:
    `2`_ `3`_ `4`_ `6`_ `9`_ `18`_ `22`_ `45`_ `66`_ `67`_ `68`_ `69`_ [`70`_] `71`_ `72`_ `73`_ `75`_ `77`_ `79`_
:logging.config:
    [`70`_] `71`_
:main:
    `73`_ [`74`_] `75`_ `79`_
:os:
    `16`_ `17`_ `31`_ [`61`_]
:parse:
    `24`_ `25`_ [`36`_] `43`_ `73`_
:parseArgs:
    [`68`_] `74`_
:perform:
    [`58`_]
:platform:
    [`30`_] `31`_
:process:
    `31`_ [`69`_] `73`_ `74`_
:re:
    `3`_ [`38`_] `39`_
:resetIndent:
    `13`_ [`15`_]
:setIndent:
    [`15`_]
:shlex:
    [`40`_] `43`_
:summary:
    `47`_ `50`_ `53`_ `56`_ [`59`_] `69`_ `75`_ `79`_
:sys:
    [`30`_] `31`_ `72`_ `73`_ `74`_
:time:
    `31`_ `46`_ `47`_ [`61`_]
:types:
    `2`_ `31`_ [`61`_]




---------

..	class:: small

	Created by /Users/slott/Documents/Projects/py-web-tool/bootstrap/pyweb.py at Thu Jun 23 15:30:45 2022.

    Source pyweb.w modified Sat Jun 18 11:04:10 2022.

	pyweb.__version__ '3.1'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool/src'.
