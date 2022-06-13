##############################
pyWeb Literate Programming 3.1
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

The essence of literate programming is a markup language that distinguishes code
from documentation. For tangling, the code is relevant. For weaving, both code
and documentation are relevant.

The **py-web-tool** markup defines a sequence of *Chunks*. 
Each Chunk is either program source code to 
be *tangled* or it is documentation to be *woven*.  The bulk of
the file is typically documentation chunks that describe the program in
some human-oriented markup language like RST, HTML, or LaTeX.


The **py-web-tool** tool parses the input, and performs the
tangle and weave operations.  It *tangles* each individual output file
from the program source chunks.  It *weaves* a final documentation file
file from the entire sequence of chunks provided, mixing the author's 
original documentation with some markup around the embedded program source.

**py-web-tool** markup surrounds the code with tags. Everything else is documentation.
When tangling, the tagged code is assembled into the final file.
When weaving, the tags are replaced with output markup. This means that **py-web-tool**
is not **totally** independent of the output markup.

The code chunks will have their indentation adjusted to match the context in which
they were originally defined. This assures that Python (which relies on indentation)
parses correctly. For other languages, proper indentation is expected but not required.

The non-code chunks are not transformed up in any way.  Everything that's not
explicitly a code chunk is output without modification.

All of the **py-web-tool** tags begin with ``@``.  This can be changed.

The *Structural* tags (historically called "major commands") partition the input and define the
various chunks.  The *Inline* tags are (called "minor commands") are used to control the
woven and tangled output from those chunks. There are *Content* tags which generate 
summary cross-reference content in woven files.

Concepts
--------

The ``.w`` file **is** the final documentation.  The code is tangled out 
of this.  

There are some mandatory "boilerplate" required to make a working document.
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

The implementation is contained in a file that both defines
the base classes and provides an overall ``main()`` function.  The ``main()``
function uses these base classes to weave and tangle the output files.

The broad outline of the presentation is as follows:

-   `Base Class Definitions`_ is largely an overview of the important features.

-   `Emitters`_ write various kinds of files. We'll present this first because
    the output shapes other parts of what the program does.

-   `Chunks`_ are pieces of the source document, built into a Web.

-   `Commands`_ are the items within a ``Chunk``.

-   `The Web and WebReader Classes`_ includes the web and the parser which produces a web.

    -   `The WebReader class`_ which parses the Web structure.
    
    -   `The Tokenizer class`_ which tokenizes the raw input.
    
    -   `The Option Parser Class`_ which tokenizes just the arguments to ``@d`` and ``@o``
        commands.
    
-   `Error class`_ defines an application-specific Error.

-   `Reference Strategy`_ defines ways to manage cross-references among chunks.
    These support the ``Weaver`` subclasses of the ``Emitters``.

-   `Action class hierarchy`_ defines things this program does.

-   `pyWeb Module File`_ defines the final module file that's created.

-   `The Application class`_. This is an overall class definition that includes
    command line parsing, picking an Action, configuring and executing the Action.
    It could be a set of related functions, but we've bound them into a class.

-   `Logging setup`_. This includes a simple context manager for logging.

-   `The Main Function`_.


Base Class Definitions
----------------------

There are the core classes that define the enduring application objects. These form
fairly complex hierarchies.

-   **Commands**. A ``Command`` contains user input and creates output.  
    This can be a block of text from the input file, 
    one of the various kinds of cross reference commands (``@f``, ``@m``, or ``@u``) 
    or a reference to a chunk (via the ``@<``\ *name*\ ``@>`` sequence.)

-   **Chunks**. A ``Chunk`` is a collection of ``Command`` instances.  This can be
    either an anonymous chunk that will be sent directly to the output, 
    or one the classes of named chunks delimited by the
    structural ``@d`` or ``@o`` commands.

There are classes for reading the input. These don't form a complex hierarchy.

The ``Web`` as a whole is a collection of ``Chunk`` instances. It's built by 
a ``WebReader`` which uses a ``Tokenizer``.

There is a hierarchy for the various kinds of output.

-   **Emitters**. An ``Emitter`` creates an output file, either tangled code or some kind of markup from
    the chunks that make up the source file.  Two major subclasses are the ``Weaver``, which 
    has a focus on markup output, and ``Tangler`` which has a focus on pure source output.

    We have further specialization of the weavers for RST,  HTML or LaTeX. The issue is
    generating proper markup to surround the code and include cross-references among code
    blocks. A number of simple templates are used for this.

-   **Reference Strategy**. We can have references resolved transitively or simply. A transitive
    reference becomes a list of parent ``@d`` ``NamedChunk`` instances.

Hovering at the edge of the base class definitions is the Action Class Hierarchy.
It's not an essential part of the base class definitions. But it doesn't seem to
fit elsewhere


..  _`1`:
..  rubric:: Base Class Definitions (1) =
..  parsed-literal::
    :class: code

    
    
    |srarr|\ Error class - defines the errors raised (`96`_)
    
    |srarr|\ Command class hierarchy - used to describe individual commands (`78`_)
    
    |srarr|\ Chunk class hierarchy - used to describe input chunks (`52`_)
    
    |srarr|\ Web class - describes the overall "web" of chunks (`97`_)
    
    |srarr|\ Tokenizer class - breaks input into tokens (`133`_)
    
    |srarr|\ Option Parser class - locates optional values on commands (`135`_), |srarr|\ (`136`_), |srarr|\ (`137`_)
    
    |srarr|\ WebReader class - parses the input file, building the Web structure (`116`_)
    
    |srarr|\ Emitter class hierarchy - used to control output files (`2`_)
    
    |srarr|\ Reference class hierarchy - strategies for references to a chunk (`93`_), |srarr|\ (`94`_), |srarr|\ (`95`_) 
    
    |srarr|\ Action class hierarchy - used to describe actions of the application (`138`_)

..

    ..  class:: small

        |loz| *Base Class Definitions (1)*. Used by: pyweb.py (`155`_)


The above order is reasonably helpful for Python and minimizes forward
references. A ``Chunk`` and a ``Web`` do have a circular relationship.
We'll present the designs from the most important first, the `Emitters`_. 

Emitters
---------

An ``Emitter`` instance is responsible for control of an output file format.
This includes the necessary file naming, opening, writing and closing operations.
It also includes providing the correct markup for the file type.

There are several subclasses of the ``Emitter`` superclass, specialized for various file
formats.


..  _`2`:
..  rubric:: Emitter class hierarchy - used to control output files (2) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Emitter superclass (`4`_)
    
    |srarr|\ Weaver subclass of Emitter to create documentation (`13`_)
    |srarr|\ RST subclass of Weaver (`23`_)
    |srarr|\ LaTeX subclass of Weaver (`24`_)
    |srarr|\ HTML subclass of Weaver (`32`_), |srarr|\ (`33`_)
    
    |srarr|\ Tangler subclass of Emitter to create source files with no markup (`44`_)
    |srarr|\ TanglerMake subclass which is make-sensitive (`49`_)

..

    ..  class:: small

        |loz| *Emitter class hierarchy - used to control output files (2)*. Used by: Base Class Definitions (`1`_)


An ``Emitter`` instance is created to contain the various details of
writing an output file.  Emitters are created as follows:

-   A ``Web`` object will create a ``Weaver`` to **weave** a final document file.

-   A ``Web`` object will create a ``Tangler`` to **tangle** each source code file.

Since each ``Emitter`` instance is responsible for the details of one file
type, different subclasses of ``Emitter`` are used when tangling source code files 
(``Tangler``) and  weaving files that include source code plus markup (``Weaver``).

Further specialization is required when weaving HTML or LaTeX or some other markup language.  
Generally, this is a matter of providing three things:

-   Templates with markup to replace various **py-web-tool** constructs,

-   Escape rules to make source code amenable to the markup language,

-   A header to provide overall includes or other setup.

An additional part of the escape rules could be expanded to include using a syntax coloring 
toolset instead of simply applying escapes.

In the case of **tangle**, the following algorithm is used:

    Visit each each output ``Chunk`` (``@o`` command), doing the following:
    
    1.  Open the ``Tangler`` instance using the target file name.

    2.  Visit each ``Chunk`` directed to the file, calling the chunk's ``tangle()`` method.
        
        1.  Call the Tangler's ``docBegin()`` method.  This sets the Tangler's indents.

        2.  Visit each ``Command``, call the command's ``tangle()`` method.  
            For the text of the chunk, the
            text is written to the tangler using the ``codeBlock()`` method.  For
            references to other chunks, the referenced chunk is tangled using the 
            referenced chunk's ``tangler()`` method.

        3.  Call the Tangler's ``docEnd()`` method.  This clears the Tangler's indents.


In the case of **weave**, the following algorithm is used:

    1.  Open the ``Weaver`` instance using the target file name.  This name is transformed
        by the weaver to an output file name appropriate to the target markup language.

    2.  Visit each each sequential ``Chunk`` (anonymous, ``@d`` or ``@o``), doing the following:

        1.  When visiting each ``Chunk``, call the Chunk's ``weave()`` method.
        
            1.  Call the Weaver's ``docBegin()``, ``fileBegin()`` or ``codeBegin()`` method, 
                depending on the subclass of Chunk.  For 
                ``fileBegin()`` and ``codeBegin()``, this writes the header for
                a code chunk in the weaver's markup language.  

            2.  Visit each ``Command``, calling the Command's ``weave()`` method.  
                For ordinary text, the
                text is written to the Weaver using the ``codeBlock()`` method.  For
                references to other chunks, the referenced chunk is woven using 
                the Weaver's ``referenceTo()`` method.

            3.  Call the Weaver's ``docEnd()``, ``fileEnd()`` or ``codeEnd()`` method.  
                For ``fileEnd()`` or ``codeEnd()``, this writes a trailer for
                a code chunk in the Weaver's markup language.


Emitter Superclass
~~~~~~~~~~~~~~~~~~

The ``Emitter`` class is an abstract base class.  It
contains common features factored out of the ``Weaver`` and ``Tangler`` subclasses.

Inheriting from the ``Emitter`` class generally requires overriding one or more
of the core methods: ``doOpen()``, and ``doClose()``.
A subclass of Tangler, might override the code writing methods: 
``quote()``, ``codeBlock()`` or ``codeFinish()``.

The ``Emitter`` class defines the basic
framework used to create and write to an output file.
This class follows the **Template** design pattern.  This design pattern
directs us to factor the basic ``open()``, ``close()`` and ``write()`` methods into two step algorithms.

..  parsed-literal::

    def open(self) -> "Emitter":
        *common preparation*
        self.doOpen()  *# overridden by subclasses*
        return self

The *common preparation* section is generally internal 
housekeeping.  The ``doOpen()`` method is overridden by subclasses to change the
basic behavior.

The class has the following attributes:

:filePath:
    the ``Path`` object for the target file created by the
    ``open()`` method.

:theFile:
    the current open file object created by the
    open method.

:linesWritten:
    the total number of ``'\n'`` characters written to the file.

:totalFiles:
    count of total number of files processed.

:totalLines:
    count of total number of lines.

Additionally, an ``Emitter`` object tracks an indentation context used by
The ``codeBlock()`` method to indent each line written.

:context:
    the indentation context stack, updated by ``addIndent()``, 
    ``clrIndent()`` and ``readdIndent()`` methods.
        
:lastIndent:
    the last indent used after writing a line of source code;
    this is used to track places where a partial line of code has a substitution into it.

:fragment:
    the last line written was a fragment and needs a ``'\n'``.

:code_indent:
    Any initial code indent. RST weavers needs additional code indentation.
    Other weavers don't care. Tanglers must have this set to zero.


..  _`3`:
..  rubric:: Imports (3) =
..  parsed-literal::
    :class: code

    from pathlib import Path
    import abc
    

..

    ..  class:: small

        |loz| *Imports (3)*. Used by: pyweb.py (`155`_)



..  _`4`:
..  rubric:: Emitter superclass (4) =
..  parsed-literal::
    :class: code

    
    class Emitter:
        """Emit an output file; handling indentation context."""
        
        code\_indent = 0 #: Used by a Tangler
        filePath : Path  #: Path within the base directory (on the name is used)
        output : Path  #: Base directory to write
        theFile: TextIO  #: Open file being written
        
        def \_\_init\_\_(self) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            self.log\_indent = logging.getLogger("indent." + self.\_\_class\_\_.\_\_qualname\_\_)
            # Working State
            self.lastIndent = 0
            self.fragment = False
            self.context: list[int] = []
            self.readdIndent(self.code\_indent)  # Create context and initial lastIndent values
            # Summary
            self.linesWritten = 0
            self.totalFiles = 0
            self.totalLines = 0
    
        def \_\_str\_\_(self) -> str:
            return self.\_\_class\_\_.\_\_name\_\_
            
        |srarr|\ Emitter core open, close and write (`5`_)
        |srarr|\ Emitter write a block of code (`8`_), |srarr|\ (`9`_), |srarr|\ (`10`_)
        |srarr|\ Emitter indent control: set, clear and reset (`11`_)
    

..

    ..  class:: small

        |loz| *Emitter superclass (4)*. Used by: Emitter class hierarchy... (`2`_)


The core ``open()`` method tracks the open files.
A subclass overrides a ``doOpen()`` method to name the output file, and
then actually open the file.  The Weaver will create an output file with
a name that's based on the overall project.  The Tangler will open the given file
name.

The ``close()`` method closes the file.  As with  ``open()``, a
``doClose()`` method actually closes the file.  This allows subclasses
to do overrides on the actual file processing.

The ``write()`` method is the lowest-level, unadorned write.
This does some additional counting as well as writing the
characters to the file.


..  _`5`:
..  rubric:: Emitter core open, close and write (5) =
..  parsed-literal::
    :class: code

    
    def open(self, aPath: Path) -> "Emitter":
        """Open a file."""
        if not hasattr(self, 'output'):
            self.output = Path.cwd()
        self.filePath = self.output / aPath.name
        self.logger.debug(f"Writing to {self.output} / {aPath.name} == {self.filePath}")
        self.linesWritten = 0
        self.doOpen()
        return self
        
    |srarr|\ Emitter doOpen, to be overridden by subclasses (`6`_)
    
    def close(self) -> None:
        self.codeFinish() # Trailing newline for tangler only.
        self.doClose()
        self.totalFiles += 1
        self.totalLines += self.linesWritten
        
    |srarr|\ Emitter doClose, to be overridden by subclasses (`7`_)
    
    def write(self, text: str) -> None:
        if text is None: return
        self.theFile.write(text)
        self.linesWritten += text.count('\\n')
    
    # Context Manager Interface -- used by \`\`open()\`\` method
    def \_\_enter\_\_(self) -> "Emitter":
        return self
        
    def \_\_exit\_\_(self, \*exc: Any) -> Literal[False]:
        self.close()
        return False
    

..

    ..  class:: small

        |loz| *Emitter core open, close and write (5)*. Used by: Emitter superclass (`4`_)


The ``doOpen()``, and ``doClose()``
methods are overridden by the various subclasses to
perform the unique operation for the subclass.


..  _`6`:
..  rubric:: Emitter doOpen, to be overridden by subclasses (6) =
..  parsed-literal::
    :class: code

    
    def doOpen(self) -> None:
        self.logger.debug("Creating %r", self.filePath)
    

..

    ..  class:: small

        |loz| *Emitter doOpen, to be overridden by subclasses (6)*. Used by: Emitter core... (`5`_)



..  _`7`:
..  rubric:: Emitter doClose, to be overridden by subclasses (7) =
..  parsed-literal::
    :class: code

    
    def doClose(self) -> None:
        self.logger.debug("Wrote %d lines to %r", self.linesWritten, self.filePath)
    

..

    ..  class:: small

        |loz| *Emitter doClose, to be overridden by subclasses (7)*. Used by: Emitter core... (`5`_)


The ``codeBlock()`` method writes several lines of code.  It calls
the ``quote()`` method to quote each line of code after doing the correct indentation.
Often, the last line of code is incomplete, so it is left unterminated.
This last line of code also sets the indentation for any 
additional code to be tangled into this section.

..  important::

    Tab characters confuse the indent algorithm.  Tabs are 
    not expanded to spaces in this application.  They should be expanded 
    prior to creating a ``.w`` file.

The algorithm is as follows:

1.  Save the topmost value of the context stack as the current indent.

2.  Split the block of text on ``'\n'`` boundaries. 
    There are two cases.
    
    -   One line only, no newline. 
    
        Write this with the saved lastIndent. 
        The lastIndent is reset to zero since we've only written a fragmentary line.
    
    -   Multiple lines.

        1.  Write the first line with saved lastIndent.
        
        2.  For each remaining line (except the last), write with the indented text, 
            ending with a newline.
    
        #.  The string ``split()`` method will put a trailing 
            zero-length element in the list if the original block ended with a
            newline.  We drop this zero length piece to prevent writing a useless fragment 
            of indent-only after the final ``'\n'``.
      
        #.  If the last line has content: Write with the indented text, 
            but do not write a trailing ``'\n'``. Set lastIndent to zero because
            the next ``codeBlock()`` will continue this fragmentary line.
    
            If the last line has no content: Write nothing.
            Save the length of the last line as the most recent indent for any ``@<``\ *name*\ ``@>``
            reference to.

This feels a bit too complex. Indentation is a feature of a tangling a reference to 
a NamedChunk. It's not really a general feature of emitters or even tanglers.


..  _`8`:
..  rubric:: Emitter write a block of code (8) =
..  parsed-literal::
    :class: code

    
    def codeBlock(self, text: str) -> None:
        """Indented write of a block of code. 
        Buffers the spaces from the last line provided to act as the indent for the next line.
        """
        indent = self.context[-1]
        lines = text.split('\\n')
        if len(lines) == 1: 
            # Fragment with no newline.
            self.logger.debug("Fragment: %d, %r", self.lastIndent, lines[0])
            self.write(f"{self.lastIndent\*' '!s}{lines[0]!s}")
            self.lastIndent = 0
            self.fragment = True
        else:
            # Multiple lines with one or more newlines.
            first, rest = lines[:1], lines[1:]
            self.logger.debug("First Line: %d, %r", self.lastIndent, first[0])
            self.write(f"{self.lastIndent\*' '!s}{first[0]!s}\\n")
            for l in rest[:-1]:
                self.logger.debug("Next Line: %d, %r", indent, l)
                self.write(f"{indent\*' '!s}{l!s}\\n")
            if rest[-1]:
                # Last line is non-empty.
                self.logger.debug("Last (Partial) Line: %d, %r", indent, rest[-1])
                self.write(f"{indent\*' '!s}{rest[-1]!s}")
                self.lastIndent = 0
                self.fragment = True
            else:
                # Last line was empty, a trailing newline.
                self.logger.debug("Last (Empty) Line: indent is %d", len(rest[-1]) + indent)
                # Buffer the next indent
                self.lastIndent = len(rest[-1]) + indent
                self.fragment = False
    

..

    ..  class:: small

        |loz| *Emitter write a block of code (8)*. Used by: Emitter superclass (`4`_)


The ``quote()`` method quotes a single line of source code.
This is used by Weaver subclasses to transform source into
a form acceptable by the final weave file format.

In the case of an HTML weaver, the HTML reserved characters -- 
``<``, ``>``, ``&``, and ``"`` -- must be replaced in the output
of code with ``&lt;``, ``&gt;``, ``&amp;``, and ``&quot;``.  
However, since the author's original document sections contain
HTML these will not be altered.


..  _`9`:
..  rubric:: Emitter write a block of code (9) +=
..  parsed-literal::
    :class: code

    
    quoted\_chars: list[tuple[str, str]] = [
        # Must be empty for tangling.
    ]
    
    def quote(self, aLine: str) -> str:
        """Each individual line of code; often overridden by weavers to quote the code."""
        clean = aLine
        for from\_, to\_ in self.quoted\_chars:
            clean = clean.replace(from\_, to\_)
        return clean
    

..

    ..  class:: small

        |loz| *Emitter write a block of code (9)*. Used by: Emitter superclass (`4`_)


The ``codeFinish()`` method handles a trailing fragmentary line when tangling.


..  _`10`:
..  rubric:: Emitter write a block of code (10) +=
..  parsed-literal::
    :class: code

    
    def codeFinish(self) -> None:
        if self.fragment:
            self.write('\\n')
    

..

    ..  class:: small

        |loz| *Emitter write a block of code (10)*. Used by: Emitter superclass (`4`_)


These three methods are used when to be sure that the included text is indented correctly with respect to the
surrounding text.

The ``addIndent()`` method pushes the next indent on the context stack
using an increment to the previous indent.

When tangling, a "previous" value is set from the indent left over from the
previous command. This allows ``@<``\ *name*\ ``@>`` references to be indented 
properly. A tangle must track all nested ``@d`` contexts to create a proper
global indent.

Weaving, however, is entirely localized to the block of code. There's no 
real context tracking. Just "lastIndent" from the previous command's ``codeBlock()``.

The ``setIndent()`` pushes a fixed indent instead adding an increment.
    
The ``clrIndent()`` method discards the most recent indent from the context stack.  
This is used when finished
tangling a source chunk.  This restores the indent to the prevailing indent.

The ``readdIndent()`` method removes all indent context information and resets the indent
to a default.

Weaving may use an initial offset. 
It's an additional indent for woven code; not used for tangled code. In particular, RST
requires this. ``readdIndent()`` uses this initial offset for weaving.


..  _`11`:
..  rubric:: Emitter indent control: set, clear and reset (11) =
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
        
    def readdIndent(self, indent: int = 0) -> None:
        """Resets the indentation context."""
        self.lastIndent = indent
        self.context = [self.lastIndent]
        self.log\_indent.debug("readdIndent %d: %r", indent, self.context)
    

..

    ..  class:: small

        |loz| *Emitter indent control: set, clear and reset (11)*. Used by: Emitter superclass (`4`_)


Weaver subclass of Emitter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Weaver is an Emitter that produces the final user-focused document.
This will include the source document with the code blocks surrounded by
markup to present that code properly.  In effect, the **py-web-tool**  ``@`` commands
are replaced by markup.

The Weaver class uses a simple set of templates to product RST markup as the default
Subclasses can introduce other templates to produce HTML or LaTeX output.

Most Weaver languages don't rely on special indentation rules.
The woven code samples usually start right on the left margin of 
the source document.  However, the RST markup language does rely
on extra indentation of code blocks.  For that reason, the weavers
have an additional indent for code blocks.  This is generally 
set to zero, except when generating RST where 4 spaces is good.

The ``Weaver`` subclass extends an ``Emitter`` to **weave** the final
documentation.  This involves decorating source code to make it
displayable.  It also involves creating references and cross
references among the various chunks.

The ``Weaver`` class adds several methods to the basic ``Emitter`` methods.  These
additional methods are also included that are used exclusively when weaving, never when tangling.

This class hierarch depends heavily on the ``string`` module.

Class-level variables include the following

:extension:
    The Path's suffix used by this weaver.
    
:code_indent:
    The number of spaces to indent code to separate code blocks from
    surrounding text. Mostly this is used by RST where a non-zero value
    is required.
    
:header:
    Any additional header material this weaver requires.

Instance-level configuration values:

:reference_style:
    Either an instance of ``TransitiveReference()`` or ``SimpleReference()``
        

..  _`12`:
..  rubric:: Imports (12) +=
..  parsed-literal::
    :class: code

    import string
    from textwrap import dedent, indent, shorten
    

..

    ..  class:: small

        |loz| *Imports (12)*. Used by: pyweb.py (`155`_)



..  _`13`:
..  rubric:: Weaver subclass of Emitter to create documentation (13) =
..  parsed-literal::
    :class: code

    
    class Weaver(Emitter):
        """Format various types of XRef's and code blocks when weaving.
        
        For RST format we splice in the following two lines
        ::
         
            ..  include:: <isoamsa.txt>
            ..  include:: <isopub.txt>
        """
        extension = ".rst" 
        code\_indent = 4
        # Not actually used.
        header = dedent("""
            ..  include:: <isoamsa.txt>
            ..  include:: <isopub.txt>
        """)
        
        reference\_style : "Reference"
        
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_()
        
        |srarr|\ Weaver doOpen, doClose and addIndent overrides (`14`_)
        
        # Template Expansions.
        
        |srarr|\ Weaver quoted characters (`15`_)
        |srarr|\ Weaver document chunk begin-end (`16`_)
        |srarr|\ Weaver reference summary, used by code chunk and file chunk (`17`_)
        |srarr|\ Weaver code chunk begin-end (`18`_)
        |srarr|\ Weaver file chunk begin-end (`19`_)
        |srarr|\ Weaver reference command output (`20`_)
        |srarr|\ Weaver cross reference output methods (`21`_), |srarr|\ (`22`_)
    

..

    ..  class:: small

        |loz| *Weaver subclass of Emitter to create documentation (13)*. Used by: Emitter class hierarchy... (`2`_)


The ``doOpen()`` method opens the file for writing.  For weavers, the file extension
is specified part of the target markup language being created.

The ``doClose()`` method extends the ``Emitter`` class ``close()`` method by closing the
actual file created by the open() method.

The ``addIndent()`` reflects the fact that we're not tracking global indents, merely
the local indentation required to weave a code chunk. The "indent" can vary because
we're not always starting a fresh line with ``weaveReferenceTo()``.


..  _`14`:
..  rubric:: Weaver doOpen, doClose and addIndent overrides (14) =
..  parsed-literal::
    :class: code

    
    def doOpen(self) -> None:
        """Create the final woven document."""
        self.filePath = self.filePath.with\_suffix(self.extension)
        self.logger.info("Weaving '%s'", self.filePath)
        self.theFile = self.filePath.open("w")
        self.readdIndent(self.code\_indent)
        
    def doClose(self) -> None:
        self.theFile.close()
        self.logger.info("Wrote %d lines to %r", self.linesWritten, self.filePath)
        
    def addIndent(self, increment: int = 0) -> None:
        """increment not used when weaving"""
        self.context.append(self.context[-1])
        self.log\_indent.debug("addIndent %d: %r", self.lastIndent, self.context)
        
    def codeFinish(self) -> None:
        pass # Not needed when weaving
    

..

    ..  class:: small

        |loz| *Weaver doOpen, doClose and addIndent overrides (14)*. Used by: Weaver subclass of Emitter... (`13`_)


The following list of markup escapes for RST may not be **all** that are requiresd. 
The general template for cude uses ``parsed-literal``
directive because it can include links comingled with the code.
We have to quote certain inline markup -- but only when the
characters are paired in a way that might confuse RST.

We could use patterns like ```.*?```, ``_.*?_``, ``\*.*?\*``, and ``\|.*?\|``
to look for paired RST inline markup and quote just these special character occurrences. 


..  _`15`:
..  rubric:: Weaver quoted characters (15) =
..  parsed-literal::
    :class: code

    
    # Prevent some RST markup from being recognized (and processed) in code.
    quoted\_chars: list[tuple[str, str]] = [
        ('\\\\', r'\\\\'), # Must be first.
        ('\`', r'\\\`'),
        ('\_', r'\\\_'), 
        ('\*', r'\\\*'),
        ('\|', r'\\\|'),
    ]

..

    ..  class:: small

        |loz| *Weaver quoted characters (15)*. Used by: Weaver subclass of Emitter... (`13`_)


The remaining methods apply a chunk to a template.

The ``docBegin()`` and ``docEnd()`` 
methods are used when weaving a document text chunk.
Typically, nothing is done before emitting these kinds of chunks.
However, putting a ``.. line line number`` RST comment is an example
of possible additional processing.



..  _`16`:
..  rubric:: Weaver document chunk begin-end (16) =
..  parsed-literal::
    :class: code

    
    def docBegin(self, aChunk: Chunk) -> None:
        pass
        
    def docEnd(self, aChunk: Chunk) -> None:
        pass
    

..

    ..  class:: small

        |loz| *Weaver document chunk begin-end (16)*. Used by: Weaver subclass of Emitter... (`13`_)


Each code chunk includes the places where the chunk is referenced.

..  note::

    This may be one of the rare places where ``for... else:`` could be the correct statement.
    
    Currently, something more complex is used.


..  _`17`:
..  rubric:: Weaver reference summary, used by code chunk and file chunk (17) =
..  parsed-literal::
    :class: code

    
    ref\_template = string.Template(
        "${refList}"
    )
    ref\_separator = "; "
    ref\_item\_template = string.Template(
        "$fullName (\`${seq}\`\_)"
    )
    
    def references(self, aChunk: Chunk) -> str:
        references = aChunk.references(self)
        if len(references) != 0:
            refList = [ 
                self.ref\_item\_template.substitute(seq=s, fullName=n)
                for n, s in references 
            ]
            return self.ref\_template.substitute(refList=self.ref\_separator.join(refList))
        else:
            return ""
    

..

    ..  class:: small

        |loz| *Weaver reference summary, used by code chunk and file chunk (17)*. Used by: Weaver subclass of Emitter... (`13`_)



The ``codeBegin()`` method emits the necessary material prior to 
a chunk of source code, defined with the ``@d`` command.

The ``codeEnd()`` method emits the necessary material subsequent to 
a chunk of source code, defined with the ``@d`` command.  
Links or cross references to chunks that 
refer to this chunk can be emitted.



..  _`18`:
..  rubric:: Weaver code chunk begin-end (18) =
..  parsed-literal::
    :class: code

    
    cb\_template = string.Template(
        dedent("""
            ..  \_\`${seq}\`:
            ..  rubric:: ${fullName} (${seq}) ${concat}
            ..  parsed-literal::
                :class: code
                
        """)
    )
    
    ce\_template = string.Template(
        dedent("""
            ..
                
                ..  class:: small
                    
                    \|loz\| \*${fullName} (${seq})\*. Used by: ${references}
        """)
    )
    
    def codeBegin(self, aChunk: Chunk) -> None:
        txt = self.cb\_template.substitute( 
            seq=aChunk.seq,
            lineNumber=aChunk.lineNumber, 
            fullName=aChunk.fullName,
            concat="=" if aChunk.initial else "+=",
        )
        self.write(txt)
        
    def codeEnd(self, aChunk: Chunk) -> None:
        txt = self.ce\_template.substitute( 
            seq = aChunk.seq,
            lineNumber = aChunk.lineNumber, 
            fullName = aChunk.fullName,
            references = self.references(aChunk),
        )
        self.write(txt)
    

..

    ..  class:: small

        |loz| *Weaver code chunk begin-end (18)*. Used by: Weaver subclass of Emitter... (`13`_)


**TODO:** Is this really necessary? Should we inject additional material
into the woven output? It seems like a potentially bad idea because
of the complications of various markup tool chains.

The ``fileBegin()`` method emits the necessary material prior to 
a chunk of source code, defined with the ``@o`` command.
A subclass would override this to provide specific text
for the intended file type.

The ``fileEnd()`` method emits the necessary material subsequent to 
a chunk of source code, defined with the ``@o`` command.  

There shouldn't be a list of references to a file. We assert that this
list is always empty.


..  _`19`:
..  rubric:: Weaver file chunk begin-end (19) =
..  parsed-literal::
    :class: code

    
    fb\_template = string.Template(
        dedent("""
            ..  \_\`${seq}\`:
            ..  rubric:: ${fullName} (${seq}) ${concat}
            ..  parsed-literal::
                :class: code
        
        """)
    )
    
    fe\_template = string.Template(
        dedent("""
            ..
                
                ..  class:: small
                        
                    \|loz\| \*${fullName} (${seq})\*.
        """)
    )
    
    def fileBegin(self, aChunk: Chunk) -> None:
        txt = self.fb\_template.substitute(
            seq=aChunk.seq, 
            lineNumber=aChunk.lineNumber, 
            fullName=aChunk.fullName,
            concat="=" if aChunk.initial else "+=",
        )
        self.write(txt)
    
    def fileEnd(self, aChunk: Chunk) -> None:
        assert len(self.references(aChunk)) == 0
        txt = self.fe\_template.substitute(
            seq=aChunk.seq, 
            lineNumber=aChunk.lineNumber, 
            fullName=aChunk.fullName,
            references=[])
        self.write(txt)
    

..

    ..  class:: small

        |loz| *Weaver file chunk begin-end (19)*. Used by: Weaver subclass of Emitter... (`13`_)


The ``referenceTo()`` method emits a reference to 
a chunk of source code.  There reference is made with a
``@<``\ *name*\ ``@>`` reference  within a ``@d`` or ``@o`` chunk.
The references are defined with the ``@d`` or ``@o`` commands.  
A subclass would override this to provide specific text
for the intended file type.


The ``referenceSep()`` method emits a separator to be used
in a sequence of references. It's usually a ``", "``, but that might be changed to
a simple ``" "`` because it looks better.


..  _`20`:
..  rubric:: Weaver reference command output (20) =
..  parsed-literal::
    :class: code

    
    refto\_name\_template = string.Template(
        r"\|srarr\|\\ ${fullName} (\`${seq}\`\_)"
    )
    refto\_seq\_template = string.Template(
        r"\|srarr\|\\ (\`${seq}\`\_)"
    )
    refto\_seq\_separator = ", "
    
    def referenceTo(self, aName: str \| None, seq: int) -> str:
        """Weave a reference to a chunk.
        Provide name to get a full reference.
        name=None to get a short reference.
        """
        if aName:
            return self.refto\_name\_template.substitute(fullName=aName, seq=seq)
        else:
            return self.refto\_seq\_template.substitute(seq=seq)
            
    def referenceSep(self) -> str:
        """Separator between references."""
        return self.refto\_seq\_separator
    

..

    ..  class:: small

        |loz| *Weaver reference command output (20)*. Used by: Weaver subclass of Emitter... (`13`_)


The ``xrefHead()`` method puts decoration in front of cross-reference
output.  A subclass may override this to change the look of the final
woven document.

The ``xrefFoot()`` method puts decoration after cross-reference
output.  A subclass may override this to change the look of the final
woven document.

The ``xrefLine()`` method is used for both 
file and chunk ("macro") cross-references to show a name (either file name
or chunk name) and a list of chunks that reference the file or chunk.

The ``xrefDefLine()`` method is used for the user identifier cross-reference.
This shows a name and a list of chunks that 
reference or define the name.  One of the chunks is identified as the
defining chunk, all others are referencing chunks.

An ``xrefEmpty()`` is used in the rare case of no user identifiers present.

The default behavior simply writes the Python data structure used
to represent cross reference information.  A subclass may override this 
to change the look of the final woven document.

Note that the ``xref_item_template`` and ``xref_empty_template`` have no leading ``\n`` character. They have
an indentation on the first line, however, to make ``dedent()`` work. The spaces to create proper
RST indentation are a bit fiddly here.


..  _`21`:
..  rubric:: Weaver cross reference output methods (21) =
..  parsed-literal::
    :class: code

    
    xref\_head\_template = string.Template(
        dedent("""
        """)
    )
    xref\_foot\_template = string.Template(
        dedent("""
        """)
    )
    xref\_item\_template = string.Template(
        dedent("""    :${fullName}:
        ${refList}
        """)
    )
    xref\_empty\_template = string.Template(
        dedent("""    (None)
        """)
    )
    
    def xrefHead(self) -> None:
        txt = self.xref\_head\_template.substitute()
        self.write(txt)
    
    def xrefFoot(self) -> None:
        txt = self.xref\_foot\_template.substitute()
        self.write(txt)
    
    def xrefLine(self, name: str, refList: list[int]) -> None:
        refList\_txt = [self.referenceTo(None, r) for r in refList]
        txt = self.xref\_item\_template.substitute(fullName=name, refList = " ".join(refList\_txt)) # RST Separator
        self.write(txt)
    
    def xrefEmpty(self) -> None:
        self.write(self.xref\_empty\_template.substitute())

..

    ..  class:: small

        |loz| *Weaver cross reference output methods (21)*. Used by: Weaver subclass of Emitter... (`13`_)


Cross-reference definition line 


..  _`22`:
..  rubric:: Weaver cross reference output methods (22) +=
..  parsed-literal::
    :class: code

    
    name\_def\_template = string.Template(
        '[\`${seq}\`\_]'
    )
    name\_ref\_template = string.Template(
        '\`${seq}\`\_'
    )
    
    def xrefDefLine(self, name: str, defn: int, refList: list[int]) -> None:
        """Special template for the definition, default reference for all others."""
        templates = {defn: self.name\_def\_template}
        refTxt = [
            templates.get(r, self.name\_ref\_template).substitute(seq=r)
            for r in sorted(refList + [defn]) 
        ]
        # Generic space separator
        txt = self.xref\_item\_template.substitute(fullName=name, refList=" ".join(refTxt)) 
        self.write(txt)
    

..

    ..  class:: small

        |loz| *Weaver cross reference output methods (22)*. Used by: Weaver subclass of Emitter... (`13`_)


RST subclass of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

A degenerate case: the base ``Weaver`` class does ``RST``.
Using this class name slightly simplifies the configuration and makes the output
look a little nicer.


..  _`23`:
..  rubric:: RST subclass of Weaver (23) =
..  parsed-literal::
    :class: code

    
    class RST(Weaver):
        pass

..

    ..  class:: small

        |loz| *RST subclass of Weaver (23)*. Used by: Emitter class hierarchy... (`2`_)



LaTeX subclass of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

Experimental, at best. 

An instance of ``LaTeX`` can be used by the ``Web`` object to 
weave an output document.  The instance is created outside the Web, and
given to the ``weave()`` method of the Web.

..  parsed-literal::

    w = Web()
    WebReader().load(w, "somefile.w") 
    weave_latex = LaTeX()
    w.weave(weave_latex)

Note that the template language and LaTeX both use ``$``.
This means that all  ``$`` that are intended to be output to LaTeX
must appear as ``$$`` in the template.


The ``LaTeX`` subclass defines a Weaver that is customized to
produce LaTeX output of code sections and cross reference information.
Its markup is pretty rudimentary, but it's also distinctive enough to
function pretty well in most L\ !sub:`A`\ T\ !sub:`E`\ X documents.



..  _`24`:
..  rubric:: LaTeX subclass of Weaver (24) =
..  parsed-literal::
    :class: code

    
    class LaTeX(Weaver):
        """LaTeX formatting for XRef's and code blocks when weaving.
        Requires \`\`\\\\usepackage{fancyvrb}\`\`
        """
        extension = ".tex"
        code\_indent = 0
        # Not actually used
        header = dedent("""
            \\\\usepackage{fancyvrb}
        """)
    
        |srarr|\ LaTeX code chunk begin (`25`_)
        |srarr|\ LaTeX code chunk end (`26`_)
        |srarr|\ LaTeX file output begin (`27`_)
        |srarr|\ LaTeX file output end (`28`_)
        |srarr|\ LaTeX references summary at the end of a chunk (`29`_)
        |srarr|\ LaTeX write a line of code (`30`_)
        |srarr|\ LaTeX reference to a chunk (`31`_)
    

..

    ..  class:: small

        |loz| *LaTeX subclass of Weaver (24)*. Used by: Emitter class hierarchy... (`2`_)


The LaTeX ``open()`` method opens the woven file by replacing the
source file's suffix with ``".tex"`` and creating the resulting file.


The LaTeX ``codeBegin()`` template writes the header prior to a
chunk of source code.  It aligns the block to the left, prints an
italicised header, and opens a preformatted block.

There's no leading ``\n`` in the template -- we're trying to avoid an indent when weaving.
To make ``dedent()`` work, we have to provide the same leading whitespace on the first line
to match the subsequent lines.


..  _`25`:
..  rubric:: LaTeX code chunk begin (25) =
..  parsed-literal::
    :class: code

    
    cb\_template = string.Template(
        dedent("""        \\\\label{pyweb${seq}}
            \\\\begin{flushleft}
            \\\\textit{Code example ${fullName} (${seq})}
            \\\\begin{Verbatim}[commandchars=\\\\\\\\\\\\{\\\\},codes={\\\\catcode\`$$=3\\\\catcode\`^=7},frame=single]
        """)
    )
    

..

    ..  class:: small

        |loz| *LaTeX code chunk begin (25)*. Used by: LaTeX subclass... (`24`_)


The LaTeX ``codeEnd()`` template writes the trailer subsequent to
a chunk of source code.  This first closes the preformatted block and
then calls the ``references()`` method to write a reference
to the chunk that invokes this chunk; finally, it restores paragraph
indentation.
  

..  _`26`:
..  rubric:: LaTeX code chunk end (26) =
..  parsed-literal::
    :class: code

    
    ce\_template = string.Template(
        dedent("""
            \\\\end{Verbatim}
            ${references}
            \\\\end{flushleft}
        """)
    )
    

..

    ..  class:: small

        |loz| *LaTeX code chunk end (26)*. Used by: LaTeX subclass... (`24`_)



The LaTeX ``fileBegin()`` template writes the header prior to a
the creation of a tangled file.  Its formatting is identical to the
start of a code chunk.



..  _`27`:
..  rubric:: LaTeX file output begin (27) =
..  parsed-literal::
    :class: code

    
    fb\_template = cb\_template
    

..

    ..  class:: small

        |loz| *LaTeX file output begin (27)*. Used by: LaTeX subclass... (`24`_)


The LaTeX ``fileEnd()`` template writes the trailer subsequent to
a tangled file.  This closes the preformatted block, calls the LaTeX
``references()`` method to write a reference to the chunk that
invokes this chunk, and restores normal indentation.


..  _`28`:
..  rubric:: LaTeX file output end (28) =
..  parsed-literal::
    :class: code

    
    fe\_template = ce\_template
    

..

    ..  class:: small

        |loz| *LaTeX file output end (28)*. Used by: LaTeX subclass... (`24`_)


The ``references()`` template writes a list of references after a
chunk of code.  Each reference includes the example number, the title,
and a reference to the LaTeX section and page numbers on which the
referring block appears.

The spacing around ``ref_item_template`` and ``ref_template`` are particularly fiddly.
This isn't easy to prepare with ``dedent()``. The ``indent()`` provides the indent
that makes the resulting LaTeX readable, distinct from the indent that makes the code readable.
  

..  _`29`:
..  rubric:: LaTeX references summary at the end of a chunk (29) =
..  parsed-literal::
    :class: code

    
    ref\_item\_template = string.Template(
        indent(
            dedent("""
                \\\\item Code example ${fullName} (${seq}) (Sect. \\\\ref{pyweb${seq}}, p. \\\\pageref{pyweb${seq}})
                """),
            '    '
        )
    )
    
    ref\_template = string.Template(
        indent(
            dedent("""
                \\\\footnotesize
                Used by:
                \\\\begin{list}{}{}
                ${refList}
                \\\\end{list}
                \\\\normalsize"""),
            '    '
        )
    )
    

..

    ..  class:: small

        |loz| *LaTeX references summary at the end of a chunk (29)*. Used by: LaTeX subclass... (`24`_)


The ``quote()`` method quotes a single line of code to the
weaver; since these lines are always in preformatted blocks, no
special formatting is needed, except to avoid ending the preformatted
block.  Our one compromise is a thin space if the phrase
``\\end{Verbatim}`` is used in a code block.

  

..  _`30`:
..  rubric:: LaTeX write a line of code (30) =
..  parsed-literal::
    :class: code

    
    quoted\_chars: list[tuple[str, str]] = [
        ("\\\\end{Verbatim}", "\\\\end\\\\,{Verbatim}"),  # Allow \\end{Verbatim} in a Verbatim context
        ("\\\\{", "\\\\\\\\,{"), # Prevent unexpected commands in Verbatim
        ("$", "\\\\$"), # Prevent unexpected math in Verbatim
    ]
    

..

    ..  class:: small

        |loz| *LaTeX write a line of code (30)*. Used by: LaTeX subclass... (`24`_)


The ``referenceTo()`` template writes a reference to another chunk of
code.  It uses write directly as to follow the current indentation on
the current line of code.



..  _`31`:
..  rubric:: LaTeX reference to a chunk (31) =
..  parsed-literal::
    :class: code

    
    refto\_name\_template = string.Template(
        """$$\\\\triangleright$$ Code Example ${fullName} (${seq})"""
    )
    
    refto\_seq\_template = string.Template(
        """(${seq})"""
    )
    

..

    ..  class:: small

        |loz| *LaTeX reference to a chunk (31)*. Used by: LaTeX subclass... (`24`_)


HTML subclasses of Weaver
~~~~~~~~~~~~~~~~~~~~~~~~~~

An instance of ``HTML`` can be used by the ``Web`` object to 
weave an output document.  The instance is created outside the Web, and
given to the ``weave()`` method of the Web.

..  parsed-literal::


    w = Web()
    WebReader().load(w,"somefile.w") 
    weave_html = HTML()
    w.weave(weave_html)


Variations in the output formatting are accomplished by having
variant subclasses of HTML.  In this implementation, we have two
variations: full path references, and short references.  The base class
produces complete reference paths; a subclass produces abbreviated references.

The ``HTML`` subclass defines a Weaver that is customized to
produce HTML output of code sections and cross reference information.

All HTML chunks are identified by anchor names of the form ``pyweb*n*``.  Each
*n* is the unique chunk number, in sequential order.

An ``HTMLShort`` subclass defines a Weaver that produces HTML output
with abbreviated (no name) cross references at the end of the chunk.


..  _`32`:
..  rubric:: HTML subclass of Weaver (32) =
..  parsed-literal::
    :class: code

    
    class HTML(Weaver):
        """HTML formatting for XRef's and code blocks when weaving."""
        extension = ".html"
        code\_indent = 0
        header = ""
        
        |srarr|\ HTML code chunk begin (`34`_)
        |srarr|\ HTML code chunk end (`35`_)
        |srarr|\ HTML output file begin (`36`_)
        |srarr|\ HTML output file end (`37`_)
        |srarr|\ HTML references summary at the end of a chunk (`38`_)
        |srarr|\ HTML write a line of code (`39`_)
        |srarr|\ HTML reference to a chunk (`40`_)
        |srarr|\ HTML simple cross reference markup (`41`_)
    

..

    ..  class:: small

        |loz| *HTML subclass of Weaver (32)*. Used by: Emitter class hierarchy... (`2`_)



..  _`33`:
..  rubric:: HTML subclass of Weaver (33) +=
..  parsed-literal::
    :class: code

    
    class HTMLShort(HTML):
        """HTML formatting for XRef's and code blocks when weaving with short references."""
        |srarr|\ HTML short references summary at the end of a chunk (`43`_)
    

..

    ..  class:: small

        |loz| *HTML subclass of Weaver (33)*. Used by: Emitter class hierarchy... (`2`_)


The ``codeBegin()`` template starts a chunk of code, defined with ``@d``, providing a label
and HTML tags necessary to set the code off visually.



..  _`34`:
..  rubric:: HTML code chunk begin (34) =
..  parsed-literal::
    :class: code

    
    cb\_template = string.Template(
        indent(
            dedent("""
                <a name="pyweb${seq}"></a>
                <!--line number ${lineNumber}-->
                <p><em>${fullName}</em> (${seq})&nbsp;${concat}</p>
                <pre><code>
                """),
            '    '
        )
    )
    

..

    ..  class:: small

        |loz| *HTML code chunk begin (34)*. Used by: HTML subclass... (`32`_)


The ``codeEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.


..  _`35`:
..  rubric:: HTML code chunk end (35) =
..  parsed-literal::
    :class: code

    
    ce\_template = string.Template(
        indent(
            dedent("""
                </code></pre>
                <p>&loz; <em>${fullName}</em> (${seq}).
                ${references}
                </p>
                """),
            '    '
        )
    )
    

..

    ..  class:: small

        |loz| *HTML code chunk end (35)*. Used by: HTML subclass... (`32`_)


The ``fileBegin()`` template starts a chunk of code, defined with ``@o``, providing a label
and HTML tags necessary to set the code off visually.


..  _`36`:
..  rubric:: HTML output file begin (36) =
..  parsed-literal::
    :class: code

    
    fb\_template = string.Template(
        indent(
            dedent("""            <a name="pyweb${seq}"></a>
                <!--line number ${lineNumber}-->
                <p>\`\`${fullName}\`\` (${seq})&nbsp;${concat}</p>
                <pre><code>
            """), # No leading \\\\n.
            '    '
        )
    )
    

..

    ..  class:: small

        |loz| *HTML output file begin (36)*. Used by: HTML subclass... (`32`_)


The ``fileEnd()`` template ends a chunk of code, providing a HTML tags necessary 
to finish the code block visually.  This calls the references method to
write the list of chunks that reference this chunk.


..  _`37`:
..  rubric:: HTML output file end (37) =
..  parsed-literal::
    :class: code

    
    fe\_template = string.Template(
        indent(
            dedent("""            </code></pre>
                <p>&loz; \`\`${fullName}\`\` (${seq}).
                ${references}
                </p>
                """),
            '    '
        )
    )
    

..

    ..  class:: small

        |loz| *HTML output file end (37)*. Used by: HTML subclass... (`32`_)


The ``references()`` template writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.


..  _`38`:
..  rubric:: HTML references summary at the end of a chunk (38) =
..  parsed-literal::
    :class: code

    
    ref\_item\_template = string.Template(
        '<a href="#pyweb${seq}"><em>${fullName}</em>&nbsp;(${seq})</a>'
    )
    
    ref\_template = string.Template(
        '  Used by ${refList}.'
    )
    

..

    ..  class:: small

        |loz| *HTML references summary at the end of a chunk (38)*. Used by: HTML subclass... (`32`_)


The ``quote()`` method quotes an individual line of code for HTML purposes.
This encodes the four basic HTML entities (``<``, ``>``, ``&``, ``"``) to prevent code from being interpreted
as HTML.


..  _`39`:
..  rubric:: HTML write a line of code (39) =
..  parsed-literal::
    :class: code

    
    quoted\_chars: list[tuple[str, str]] = [
        ("&", "&amp;"),  # Must be first
        ("<", "&lt;"),
        (">", "&gt;"),
        ('"', "&quot;"),
    ]
    

..

    ..  class:: small

        |loz| *HTML write a line of code (39)*. Used by: HTML subclass... (`32`_)


The ``referenceTo()`` template writes a reference to another chunk.  It uses the 
direct ``write()`` method so that the reference is indented properly with the
surrounding source code.


..  _`40`:
..  rubric:: HTML reference to a chunk (40) =
..  parsed-literal::
    :class: code

    
    refto\_name\_template = string.Template(
        '<a href="#pyweb${seq}">&rarr;<em>${fullName}</em> (${seq})</a>'
    )
    
    refto\_seq\_template = string.Template(
        '<a href="#pyweb${seq}">(${seq})</a>'
    )
    

..

    ..  class:: small

        |loz| *HTML reference to a chunk (40)*. Used by: HTML subclass... (`32`_)


The ``xrefHead()`` method writes the heading for any of the cross reference blocks created by
``@f``, ``@m``, or ``@u``.  In this implementation, the cross references are simply unordered lists. 

The ``xrefFoot()`` method writes the footing for any of the cross reference blocks created by
``@f``, ``@m``, or ``@u``.  In this implementation, the cross references are simply unordered lists. 

The ``xrefLine()`` method writes a line for the file or macro cross reference blocks created by
``@f`` or ``@m``.  In this implementation, the cross references are simply unordered lists. 


..  _`41`:
..  rubric:: HTML simple cross reference markup (41) =
..  parsed-literal::
    :class: code

    
    xref\_head\_template = string.Template(
        dedent("""    <dl>
        """)
    )
    xref\_foot\_template = string.Template(
        dedent("""    </dl>
        """)
    )
    xref\_item\_template = string.Template(
        dedent("""    <dt>${fullName}</dt><dd>${refList}</dd>
        """)
    )
    
    |srarr|\ HTML write user id cross reference line (`42`_)
    

..

    ..  class:: small

        |loz| *HTML simple cross reference markup (41)*. Used by: HTML subclass... (`32`_)


The ``xrefDefLine()`` method writes a line for the user identifier cross reference blocks created by
@u.  In this implementation, the cross references are simply unordered lists.  The defining instance 
is included in the correct order with the other instances, but is bold and marked with a bullet (&bull;).



..  _`42`:
..  rubric:: HTML write user id cross reference line (42) =
..  parsed-literal::
    :class: code

    
    name\_def\_template = string.Template(
        '<a href="#pyweb${seq}"><b>&bull;${seq}</b></a>'
    )
    
    name\_ref\_template = string.Template(
        '<a href="#pyweb${seq}">${seq}</a>'
    )
    

..

    ..  class:: small

        |loz| *HTML write user id cross reference line (42)*. Used by: HTML simple cross reference markup (`41`_)


The HTMLShort subclass enhances the HTML class to provide short 
cross references.
The ``references()`` method writes the list of chunks that refer to this chunk.
Note that this list could be rather long because of the possibility of 
transitive references.


..  _`43`:
..  rubric:: HTML short references summary at the end of a chunk (43) =
..  parsed-literal::
    :class: code

    
    ref\_item\_template = string.Template(
        '<a href="#pyweb${seq}">(${seq})</a>'
    )
    

..

    ..  class:: small

        |loz| *HTML short references summary at the end of a chunk (43)*. Used by: HTML subclass... (`33`_)


Tangler subclass of Emitter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``Tangler`` class is concrete, and can tangle source files.  An
instance of ``Tangler`` is given to the ``Web`` class ``tangle()`` method.

..  parsed-literal::

    w = Web()
    WebReader().load(w,"somefile.w") 
    t = Tangler()
    w.tangle(t)


The ``Tangler`` subclass extends an Emitter to **tangle** the various
program source files.  The superclass is used to simply emit correctly indented 
source code and do very little else that could corrupt or alter the output.

Language-specific subclasses could be used to provide additional decoration.
For example, inserting ``#line`` directives showing the line number
in the original source file.

For Python, where indentation matters, the indent rules are relatively
simple.  The whitespace berfore a ``@<`` command is preserved as
the prevailing indent for the block tangled as a replacement for the  ``@<``\ *name*\ ``@>``.

There are three configurable values:

:comment_start:
    If not None, this is the leading character for a line-number comment
    
:comment_end:
    This is the trailing character for a line-number comment
    
:include_line_numbers:
    Show the source line numbers in the output via additional comments.


..  _`44`:
..  rubric:: Tangler subclass of Emitter to create source files with no markup (44) =
..  parsed-literal::
    :class: code

    
    class Tangler(Emitter):
        """Tangle output files."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_()
            self.comment\_start: str = "#"
            self.comment\_end: str = ""
            self.include\_line\_numbers = False
            
        |srarr|\ Tangler doOpen, and doClose overrides (`45`_)
        |srarr|\ Tangler code chunk begin (`46`_)
        |srarr|\ Tangler code chunk end (`47`_)
    

..

    ..  class:: small

        |loz| *Tangler subclass of Emitter to create source files with no markup (44)*. Used by: Emitter class hierarchy... (`2`_)


The default for all tanglers is to create the named file.
In order to handle paths, we will examine the file name for any ``"/"``
characters and perform the required ``os.makedirs`` functions to
allow creation of files with a path.  We don't use Windows ``"\"``
characters, but rely on Python to handle this automatically.

This ``doClose()`` method overrides the ``Emitter`` class ``doClose()`` method by closing the
actual file created by open.


..  _`45`:
..  rubric:: Tangler doOpen, and doClose overrides (45) =
..  parsed-literal::
    :class: code

    
    def checkPath(self) -> None:
        self.filePath.parent.mkdir(parents=True, exist\_ok=True)
    
    def doOpen(self) -> None:
        """Tangle out of the output files."""
        self.checkPath()
        self.theFile = self.filePath.open("w")
        self.logger.info("Tangling '%s'", self.filePath)
        
    def doClose(self) -> None:
        self.theFile.close()
        self.logger.info("Wrote %d lines to %r", self.linesWritten, self.filePath)
    

..

    ..  class:: small

        |loz| *Tangler doOpen, and doClose overrides (45)*. Used by: Tangler subclass of Emitter... (`44`_)


The ``codeBegin()`` method starts emitting a new chunk of code.
It does this by setting the Tangler's indent to the
prevailing indent at the start of the ``@<`` reference command.


..  _`46`:
..  rubric:: Tangler code chunk begin (46) =
..  parsed-literal::
    :class: code

    
    def codeBegin(self, aChunk: Chunk) -> None:
        self.log\_indent.debug("<tangle %r:", aChunk.fullName)
        if self.include\_line\_numbers:
            self.write(
                f"\\n{self.comment\_start!s} Web: " 
                f"{aChunk.filePath.name!s}:{aChunk.lineNumber!r} " 
                f"{aChunk.fullName!s}({aChunk.seq:d}) {self.comment\_end!s}\\n"
            )
    

..

    ..  class:: small

        |loz| *Tangler code chunk begin (46)*. Used by: Tangler subclass of Emitter... (`44`_)


The ``codeEnd()`` method ends emitting a new chunk of code.
It does this by resetting the Tangler's indent to the previous
setting.



..  _`47`:
..  rubric:: Tangler code chunk end (47) =
..  parsed-literal::
    :class: code

    
    def codeEnd(self, aChunk: Chunk) -> None:
        self.log\_indent.debug(">%r", aChunk.fullName)
    

..

    ..  class:: small

        |loz| *Tangler code chunk end (47)*. Used by: Tangler subclass of Emitter... (`44`_)


TanglerMake subclass of Tangler
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``TanglerMake`` class is can tangle source files.  An
instance of ``TanglerMake`` is given to the ``Web`` class ``tangle()`` method.

..  parsed-literal::

    w = Web()
    WebReader().load(w,"somefile.w") 
    t = TanglerMake()
    w.tangle(t)

The ``TanglerMake`` subclass extends ``Tangler`` to make the source files
more make-friendly.  This subclass of ``Tangler`` 
does not **touch** an output file
where there is no change.  This is helpful when **py-web-tool**\ 's output is
sent to **make**.  Using ``TanglerMake`` assures that only files with real changes
are rewritten, minimizing recompilation of an application for changes to
the associated documentation.

This subclass of ``Tangler`` changes how files
are opened and closed.


..  _`48`:
..  rubric:: Imports (48) +=
..  parsed-literal::
    :class: code

    import tempfile
    import filecmp
    

..

    ..  class:: small

        |loz| *Imports (48)*. Used by: pyweb.py (`155`_)



..  _`49`:
..  rubric:: TanglerMake subclass which is make-sensitive (49) =
..  parsed-literal::
    :class: code

    
    class TanglerMake(Tangler):
        """Tangle output files, leaving files untouched if there are no changes."""
        tempname : str
        def \_\_init\_\_(self, \*args: Any) -> None:
            super().\_\_init\_\_(\*args)
    
        |srarr|\ TanglerMake doOpen override, using a temporary file (`50`_)
    
        |srarr|\ TanglerMake doClose override, comparing temporary to original (`51`_)
    

..

    ..  class:: small

        |loz| *TanglerMake subclass which is make-sensitive (49)*. Used by: Emitter class hierarchy... (`2`_)


A ``TanglerMake`` creates a temporary file to collect the
tangled output.  When this file is completed, we can compare
it with the original file in this directory, avoiding
a "touch" if the new file is the same as the original.



..  _`50`:
..  rubric:: TanglerMake doOpen override, using a temporary file (50) =
..  parsed-literal::
    :class: code

    
    def doOpen(self) -> None:
        fd, self.tempname = tempfile.mkstemp(dir=os.curdir)
        self.theFile = os.fdopen(fd, "w")
        self.logger.info("Tangling  '%s'", self.filePath)
    

..

    ..  class:: small

        |loz| *TanglerMake doOpen override, using a temporary file (50)*. Used by: TanglerMake subclass... (`49`_)


If there is a previous file: compare the temporary file and the previous file.  

If there was no previous file or the files are different: rename temporary to replace previous;
else there was a previous file and the files were the same: unlink temporary and discard it.  

This preserves the original (with the original date
and time) if nothing has changed.



..  _`51`:
..  rubric:: TanglerMake doClose override, comparing temporary to original (51) =
..  parsed-literal::
    :class: code

    
    def doClose(self) -> None:
        self.theFile.close()
        try:
            same = filecmp.cmp(self.tempname, self.filePath)
        except OSError as e:
            same = False  # Doesn't exist. (Could check for errno.ENOENT)
        if same:
            self.logger.info("Unchanged '%s'", self.filePath)
            os.remove(self.tempname)
        else:
            # Windows requires the original file name be removed first.
            try: 
                self.filePath.unlink()
            except OSError as e:
                pass  # Doesn't exist. (Could check for errno.ENOENT)
            self.checkPath()
            self.filePath.hardlink\_to(self.tempname)
            os.remove(self.tempname)
            self.logger.info("Wrote %d lines to %s", self.linesWritten, self.filePath)
    

..

    ..  class:: small

        |loz| *TanglerMake doClose override, comparing temporary to original (51)*. Used by: TanglerMake subclass... (`49`_)


Chunks
--------

A ``Chunk`` is a piece of the input file.  It is a collection of ``Command`` instances.
A chunk can be woven or tangled to create output.

The two most important methods are the ``weave()`` and ``tangle()`` methods.  These
visit the commands of this chunk, producing the required output file.

Additional methods (``startswith()``, ``searchForRE()`` and ``usedBy()``)
are used to examine the text of the ``Command`` instances within
the chunk.

A ``Chunk`` instance is created by the ``WebReader`` as the input file is parsed.
Each ``Chunk`` instance has one or more pieces of the original input text.  
This text can be program source, a reference command, or the documentation source.


..  _`52`:
..  rubric:: Chunk class hierarchy - used to describe input chunks (52) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Chunk base class for anonymous chunks of the file (`53`_)
    
    |srarr|\ NamedChunk class for defined names (`65`_), |srarr|\ (`70`_)
    
    |srarr|\ OutputChunk class (`71`_)
    
    |srarr|\ NamedDocumentChunk class (`75`_)

..

    ..  class:: small

        |loz| *Chunk class hierarchy - used to describe input chunks (52)*. Used by: Base Class Definitions (`1`_)


The ``Chunk`` class is both the superclass for this hierarchy and the implementation 
for anonymous chunks.  An anonymous chunk is always documentation in the 
target markup language.  No transformation is ever done on anonymous chunks.

A ``NamedChunk`` is a chunk created with a ``@d`` command.  
This is a chunk of source programming language, bracketed with ``@{`` and ``@}``.

An ``OutputChunk`` is a named chunk created with a ``@o`` command.  
This must be a chunk of source programming language, bracketed with ``@{`` and ``@}``.

A ``NamedDocumentChunk`` is a named chunk created with a ``@d`` command.  
This is a chunk of documentation in the target markup language,
bracketed with ``@[`` and ``@]``.

Chunk Superclass
~~~~~~~~~~~~~~~~~

An instance of the ``Chunk`` class has a life that includes four important events:

-   creation, 

-   cross-reference, 

-   weave,

-   and tangle.

A ``Chunk`` is created by a ``WebReader``, and associated with a ``Web``.
There are several web append methods, depending on the exact subclass of ``Chunk``.
The ``WebReader`` calls the chunk's ``webAdd()`` method select the correct method
for appending and indexing the chunk.
Individual instances of ``Command`` are appended to the chunk.
The basic outline for creating a ``Chunk`` instance is as follows:

..  parsed-literal::

    w = Web()
    c = Chunk()
    c.webAdd(w)
    c.append(*...some Command...*)
    c.append(*...some Command...*)

Before weaving or tangling, a cross reference is created for all
user identifiers in all of the ``Chunk`` instances.
This is done by: (1) visit each ``Chunk`` and call the 
``getUserIDRefs()`` method to gather all identifiers; (2) for each identifier, 
visit each ``Chunk`` and call the ``searchForRE()`` method to find uses of
the identifier.

..  parsed-literal::

    ident = []
    for c in *the Web's named chunk list*:
        ident.extend(c.getUserIDRefs())
    for i in ident:
        pattern = re.compile(f'\\W{i!s}\\W' )
        for c in *the Web's named chunk list*:
            c.searchForRE(pattern)

A ``Chunk`` is woven or tangled by the ``Web``.  The basic outline for weaving is
as follows.  The tangling action is essentially the same.

..  parsed-literal::

    for c in *the Web's chunk list*:
        c.weave(aWeaver)

The ``Chunk`` class contains the overall definitions for all of the
various specialized subclasses.  In particular, it contains the ``append()``,
and ``appendText()`` methods used by all of the various ``Chunk`` subclasses.


When a ``@@`` construct is located in the input stream, the stream contains
three text tokens: material before the ``@@``, the ``@@``, 
and the material after the ``@@``.
These three tokens are reassembled into a single block of text.  This reassembly
is accomplished by changing the chunk's state so that the next ``TextCommand`` is
appended onto the previous ``TextCommand``.

The ``appendText()`` method either:

-   appends to a previous ``TextCommand``  instance,

-   or finds that there are no commands at all, and creates an initial
    ``TextCommand`` instance,

-   or finds that the last ``Command`` isn't a subclass of ``TextCommand``
    and creates a ``TextCommand`` instance.

Each subclass of ``Chunk`` has a particular type of text that it will process.  Anonymous chunks
only handle document text.  The ``NamedChunk`` subclass that handles program source
will override this method to create a different command type.  The ``makeContent()`` method
creates the appropriate ``Command`` instance for this ``Chunk`` subclass.

The ``weave()`` method of an anonymous ``Chunk`` uses the weaver's 
``docBegin()`` and ``docEnd()``
methods to insert text that is source markup.  Other subclasses will override this to 
use different ``Weaver`` methods for different kinds of text.

A ``Chunk`` has a **Strategy** object which is a subclass of ``Reference``.  This is
either an instance of ``SimpleReference`` or ``TransitiveReference``.  
A ``SimpleRerence`` does no additional processing, and locates the proximate reference to 
this chunk.  The ``TransitiveReference`` walks "up" the web toward top-level file
definitions that reference this ``Chunk``.


The ``Chunk`` constructor initializes the following instance variables:

:commands:
    is a sequence of the various ``Command`` instances the comprise this
    chunk.

:user_id_list:
    is used the list of user identifiers associated with
    this chunk.  This attribute is always ``None`` for this class.
    The ``NamedChunk`` subclass, however, can have user identifiers.
    
:initial:
    is True if this is the first
    definition (display with ``'='``) or a subsequent definition (display with ``'+='``).

:web:
    A weakref to the web which contains this Chunk. We want to inherit information
    from the ``Web`` overall.
    
:filePath:
    The file which contained this chunk's initial ``@o`` or ``@d``.
    
:name:
    has the name of the chunk.  This is '' for anonymous chunks.

!seq:
    has the sequence number associated with this chunk.  This is None
    for anonymous chunks.

:referencedBy:
    is the list of Chunks which reference this chunk.

:references:
    is the list of Chunks this chunk references.


..  _`53`:
..  rubric:: Chunk base class for anonymous chunks of the file (53) =
..  parsed-literal::
    :class: code

    
    class Chunk:
        """Anonymous piece of input file: will be output through the weaver only."""
        web: weakref.ReferenceType["Web"]
        previous\_command: "Command"
        initial: bool
        filePath: Path
        
        def \_\_init\_\_(self) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            self.commands: list["Command"] = []  # The list of children of this chunk
            self.user\_id\_list: list[str] = []
            self.name: str = ""
            self.fullName: str = ""
            self.seq: int = 0
            self.referencedBy: list[Chunk] = []  # Chunks which reference this chunk.  Ideally just one.
            self.references\_list: list[str] = []  # Names that this chunk references
            self.refCount = 0
            
        def \_\_str\_\_(self) -> str:
            return "\\n".join(map(str, self.commands))
        def \_\_repr\_\_(self) -> str:
            return f"{self.\_\_class\_\_.\_\_name\_\_!s}({self.name!r})"
        def \_\_eq\_\_(self, other: Any) -> bool:
            match other:
                case Chunk():
                    return self.name == other.name and self.commands == other.commands
                case \_:
                    return NotImplemented
            
        |srarr|\ Chunk append a command (`54`_)
        |srarr|\ Chunk append text (`55`_)
        |srarr|\ Chunk add to the web (`56`_)
        
        |srarr|\ Chunk generate references from this Chunk (`60`_)
        |srarr|\ Chunk superclass make Content definition (`57`_)
        |srarr|\ Chunk examination: starts with, matches pattern (`59`_)
        |srarr|\ Chunk references to this Chunk (`61`_)
        
        |srarr|\ Chunk weave this Chunk into the documentation (`62`_)
        |srarr|\ Chunk tangle this Chunk into a code file (`63`_)
        |srarr|\ Chunk indent adjustments (`64`_)
    

..

    ..  class:: small

        |loz| *Chunk base class for anonymous chunks of the file (53)*. Used by: Chunk class hierarchy... (`52`_)


The ``append()`` method simply appends a ``Command`` instance to this chunk.


..  _`54`:
..  rubric:: Chunk append a command (54) =
..  parsed-literal::
    :class: code

    
    def append(self, command: Command) -> None:
        """Add another Command to this chunk."""
        self.commands.append(command)
        command.chunk = self
    

..

    ..  class:: small

        |loz| *Chunk append a command (54)*. Used by: Chunk base class... (`53`_)


The ``appendText()`` method appends a ``TextCommand`` to this chunk,
or it concatenates it to the most recent ``TextCommand``.  

When an ``@@`` construct is located, the ``appendText()`` method is
used to accumulate this character.  This means that it will be appended to 
any previous TextCommand, or  new TextCommand will be built.

The reason for appending is that a ``TextCommand`` has an implicit indentation.  The "@" cannot
be a separate ``TextCommand`` because it will wind up indented.


..  _`55`:
..  rubric:: Chunk append text (55) =
..  parsed-literal::
    :class: code

    
    def appendText(self, text: str, lineNumber: int = 0) -> None:
        """Append a string to the most recent TextCommand."""
        match self.commands:
            case [\*Command, TextCommand()]:
                self.commands[-1].text += text
            case \_:
                self.commands.append(self.makeContent(text, lineNumber))
    

..

    ..  class:: small

        |loz| *Chunk append text (55)*. Used by: Chunk base class... (`53`_)


The ``webAdd()`` method adds this chunk to the given document web.
Each subclass of the ``Chunk`` class must override this to be sure that the various
``Chunk`` subclasses are indexed properly.  The
``Chunk`` class uses the ``add()`` method
of the ``Web`` class to append an anonymous, unindexed chunk.


..  _`56`:
..  rubric:: Chunk add to the web (56) =
..  parsed-literal::
    :class: code

    
    def webAdd(self, web: "Web") -> None:
        """Add self to a Web as anonymous chunk."""
        web.add(self)
    

..

    ..  class:: small

        |loz| *Chunk add to the web (56)*. Used by: Chunk base class... (`53`_)


This superclass creates a specific Command for a given piece of content.
A subclass can override this to change the underlying assumptions of that Chunk.
The generic chunk doesn't contain code, it contains text and can only be woven,
never tangled.  A Named Chunk using ``@{`` and ``@}`` creates code.
A Named Chunk using ``@[`` and ``@]`` creates text.



..  _`57`:
..  rubric:: Chunk superclass make Content definition (57) =
..  parsed-literal::
    :class: code

    
    def makeContent(self, text: str, lineNumber: int = 0) -> Command:
        return TextCommand(text, lineNumber)
    

..

    ..  class:: small

        |loz| *Chunk superclass make Content definition (57)*. Used by: Chunk base class... (`53`_)


The ``startsWith()`` method examines a the first ``Command`` instance this
``Chunk`` instance to see if it starts
with the given prefix string.

The ``lineNumber()`` method returns the line number of the first
``Command`` in this chunk.  This provides some context for where the chunk
occurs in the original input file.

A ``NamedChunk`` instance may define one or more identifiers.  This parent class
provides a dummy version of the ``getUserIDRefs`` method.  The ``NamedChunk``
subclass overrides this to provide actual results.  By providing this
at the superclass-level, the ``Web`` can easily gather identifiers without
knowing the actual subclass of ``Chunk``.

The ``searchForRE()`` method examines each ``Command`` instance to see if it matches
with the given regular expression.  If so, this can be reported to the Web instance
and accumulated as part of a cross reference for this ``Chunk``.


..  _`58`:
..  rubric:: Imports (58) +=
..  parsed-literal::
    :class: code

    from typing import Pattern, Match, Optional, Any, Literal

..

    ..  class:: small

        |loz| *Imports (58)*. Used by: pyweb.py (`155`_)



..  _`59`:
..  rubric:: Chunk examination: starts with, matches pattern (59) =
..  parsed-literal::
    :class: code

    
    def startswith(self, prefix: str) -> bool:
        """Examine the first command's starting text."""
        return len(self.commands) >= 1 and self.commands[0].startswith(prefix)
    
    def searchForRE(self, rePat: Pattern[str]) -> Optional["Chunk"]:
        """Visit each command, applying the pattern."""
        for c in self.commands:
            if c.searchForRE(rePat):
                return self
        return None
    
    @property
    def lineNumber(self) -> int \| None:
        """Return the first command's line number or None."""
        return self.commands[0].lineNumber if len(self.commands) >= 1 else None
    
    def setUserIDRefs(self, text: str) -> None:
        """Used by NamedChunk subclass."""
        pass
        
    def getUserIDRefs(self) -> list[str]:
        """Used by NamedChunk subclass."""
        return []
    

..

    ..  class:: small

        |loz| *Chunk examination: starts with, matches pattern (59)*. Used by: Chunk base class... (`53`_)


The chunk search in the ``searchForRE()`` method parallels weaving and tangling a ``Chunk``.
The operation is delegated to each ``Command`` instance within the ``Chunk`` instance.

The ``genReferences()`` method visits each ``Command`` instance inside this chunk;
a ``Command`` will yield the references.  

Note that an exception may be raised by this operation if a referenced
``Chunk`` does not actually exist.  If a reference ``Command`` does raise an error, 
we append this ``Chunk`` information and reraise the error with the additional 
context information.



..  _`60`:
..  rubric:: Chunk generate references from this Chunk (60) =
..  parsed-literal::
    :class: code

    
    def genReferences(self, aWeb: "Web") -> Iterator[str]:
        """Generate references from this Chunk."""
        try:
            for t in self.commands:
                ref = t.ref(aWeb)
                if ref is not None:
                    yield ref
        except Error as e:
            raise
    

..

    ..  class:: small

        |loz| *Chunk generate references from this Chunk (60)*. Used by: Chunk base class... (`53`_)


The list of references to a Chunk uses a **Strategy** plug-in
to either generate a simple parent or a transitive closure of all parents.

Note that we need to get the ``Weaver.reference_style`` which is a
configuration item. This is a **Strategy** showing how to compute the list of references.
The Weaver pushed it into the Web so that it is available for each ``Chunk``.


..  _`61`:
..  rubric:: Chunk references to this Chunk (61) =
..  parsed-literal::
    :class: code

    
    def references(self, theWeaver: "Weaver") -> list[tuple[str, int]]:
        """Extract name, sequence from Chunks into a list."""
        return [ 
            (c.name, c.seq) 
            for c in theWeaver.reference\_style.chunkReferencedBy(self) 
        ]

..

    ..  class:: small

        |loz| *Chunk references to this Chunk (61)*. Used by: Chunk base class... (`53`_)


The ``weave()`` method weaves this chunk into the final document as follows:

1.  Call the ``Weaver`` class ``docBegin()`` method.  This method does nothing for document content.

2.  Visit each ``Command`` instance: call the ``Command`` instance ``weave()`` method to 
    emit the content of the ``Command`` instance

3.  Call the ``Weaver`` class ``docEnd()`` method.  This method does nothing for document content.

Note that an exception may be raised by this action if a referenced
``Chunk`` does not actually exist.  If a reference ``Command`` does raise an error, 
we append this ``Chunk`` information and reraise the error with the additional 
context information.



..  _`62`:
..  rubric:: Chunk weave this Chunk into the documentation (62) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create the nicely formatted document from an anonymous chunk."""
        aWeaver.docBegin(self)
        for cmd in self.commands:
            cmd.weave(aWeb, aWeaver)
        aWeaver.docEnd(self)
    def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create a reference to this chunk -- except for anonymous chunks."""
        raise Exception( "Cannot reference an anonymous chunk.""")
    def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create a short reference to this chunk -- except for anonymous chunks."""
        raise Exception( "Cannot reference an anonymous chunk.""")
    

..

    ..  class:: small

        |loz| *Chunk weave this Chunk into the documentation (62)*. Used by: Chunk base class... (`53`_)


Anonymous chunks cannot be tangled.  Any attempt indicates a serious
problem with this program or the input file.


..  _`63`:
..  rubric:: Chunk tangle this Chunk into a code file (63) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        """Create source code -- except anonymous chunks should not be tangled"""
        raise Error('Cannot tangle an anonymous chunk', self)
    

..

    ..  class:: small

        |loz| *Chunk tangle this Chunk into a code file (63)*. Used by: Chunk base class... (`53`_)


Generally, a Chunk with a reference will adjust the indentation for
that referenced material. However, this is not universally true,
a subclass may not indent when tangling and may -- instead -- put stuff flush at the
left margin by forcing the local indent to zero.


..  _`64`:
..  rubric:: Chunk indent adjustments (64) =
..  parsed-literal::
    :class: code

    
    def reference\_indent(self, aWeb: "Web", aTangler: "Tangler", amount: int) -> None:
        aTangler.addIndent(amount)  # Or possibly set indent to local zero.
        
    def reference\_dedent(self, aWeb: "Web", aTangler: "Tangler") -> None:
        aTangler.clrIndent()

..

    ..  class:: small

        |loz| *Chunk indent adjustments (64)*. Used by: Chunk base class... (`53`_)


NamedChunk class
~~~~~~~~~~~~~~~~

A ``NamedChunk`` is created and used almost identically to an anonymous ``Chunk``.
The most significant difference is that a name is provided when the ``NamedChunk`` is created.
This name is used by the ``Web`` to organize the chunks.

A ``NamedChunk`` is created with a ``@d`` or ``@o`` command.  
A ``NamedChunk`` contains programming language source
when the brackets are ``@{`` and ``@}``.  A
separate subclass of ``NamedDocumentChunk`` is used when
the brackets are ``@[`` and ``@]``.

A ``NamedChunk`` can be both tangled into the output program files, and
woven into the output document file. 

The ``weave()`` method of a ``NamedChunk`` uses the Weaver's 
``codeBegin()`` and ``codeEnd()``
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses can override this to 
use different ``Weaver`` methods for different kinds of text.

By inheritance from the superclass, this class indents. A separate subclass provides a no-indent
implementation of a ``NamedChunk``.

This class introduces some additional attributes.

:fullName:
    is the full name of the chunk.  It's possible for a 
    chunk to be an abbreviated forward reference; full names cannot be resolved
    until all chunks have been seen.

:user_id_list:
    is the list of user identifiers associated with this chunk.

:refCount:
    is the count of references to this chunk.  If this is
    zero, the chunk is unused; if this is more than one, this chunk is 
    multiply used.  Either of these conditions is a possible error in the input. 
    This is set by the ``usedBy()`` method.

:name: 
    has the name of the chunk.  Names can be abbreviated.

!seq:
    has the sequence number associated with this chunk.  This
    is set by the Web by the ``webAdd()`` method.



..  _`65`:
..  rubric:: NamedChunk class for defined names (65) =
..  parsed-literal::
    :class: code

    
    class NamedChunk(Chunk):
        """Named piece of input file: will be output as both tangler and weaver."""
        def \_\_init\_\_(self, name: str) -> None:
            super().\_\_init\_\_()
            self.name = name
            self.user\_id\_list = []
            self.refCount = 0
            
        def \_\_str\_\_(self) -> str:
            return f"{self.name!r}: {self!s}"
            
        def makeContent(self, text: str, lineNumber: int = 0) -> Command:
            return CodeCommand(text, lineNumber)
            
        |srarr|\ NamedChunk user identifiers set and get (`66`_)
        |srarr|\ NamedChunk add to the web (`67`_)
        |srarr|\ NamedChunk weave into the documentation (`68`_)
        |srarr|\ NamedChunk tangle into the source file (`69`_)
    

..

    ..  class:: small

        |loz| *NamedChunk class for defined names (65)*. Used by: Chunk class hierarchy... (`52`_)


The ``setUserIDRefs()`` method accepts a list of user identifiers that are
associated with this chunk.  These are provided after the ``@|`` separator
in a ``@d`` named chunk.  These are used by the ``@u`` cross reference generator.


..  _`66`:
..  rubric:: NamedChunk user identifiers set and get (66) =
..  parsed-literal::
    :class: code

    
    def setUserIDRefs(self, text: str) -> None:
        """Save user ID's associated with this chunk."""
        self.user\_id\_list = text.split()
    def getUserIDRefs(self) -> list[str]:
        return self.user\_id\_list
    

..

    ..  class:: small

        |loz| *NamedChunk user identifiers set and get (66)*. Used by: NamedChunk class... (`65`_)


The ``webAdd()`` method adds this chunk to the given document ``Web`` instance.
Each class of ``Chunk`` must override this to be sure that the various
``Chunk`` classes are indexed properly.  This class uses the ``Web.addNamed()`` method
of the ``Web`` class to append a named chunk.


..  _`67`:
..  rubric:: NamedChunk add to the web (67) =
..  parsed-literal::
    :class: code

    
    def webAdd(self, web: "Web") -> None:
        """Add self to a Web as named chunk, update xrefs."""
        web.addNamed(self)
    

..

    ..  class:: small

        |loz| *NamedChunk add to the web (67)*. Used by: NamedChunk class... (`65`_)


The ``weave()`` method weaves this chunk into the final document as follows:

1.  call the ``Weaver`` class ``codeBegin()`` method.  This method emits the necessary markup
    for code appearing in the woven output.

2.  visit each ``Command``, calling the command's ``weave()`` method to emit the command's content.

3.  call the ``Weaver`` class ``CodeEnd()`` method.  This method emits the necessary markup
    for code appearing in the woven output.


For an RST weaver this becomes a ``parsed-literal``, which requires a extra indent.
For an HTML weaver this becomes a ``<pre>`` in a different-colored box.

References generate links in a woven document. In a tangled document, they create the actual
code. The ``weaveRefenceTo()`` method weaves a reference to a chunk using both name and sequence number.
The ``weaveShortReferenceTo()`` method weaves a reference to a chunk using only the sequence number.
These references are created by ``ReferenceCommand`` instances within a chunk being woven.

The woven references simply follow whatever preceded them on the line; the indent
(if any) doesn't change from the default.



..  _`68`:
..  rubric:: NamedChunk weave into the documentation (68) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create the nicely formatted document from a chunk of code."""
        self.fullName = aWeb.fullNameFor(self.name)
        aWeaver.addIndent()
        aWeaver.codeBegin(self)
        for cmd in self.commands:
            cmd.weave(aWeb, aWeaver)
        aWeaver.clrIndent( )
        aWeaver.codeEnd(self)
    def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create a reference to this chunk."""
        self.fullName = aWeb.fullNameFor(self.name)
        txt = aWeaver.referenceTo(self.fullName, self.seq)
        aWeaver.codeBlock(txt)
    def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create a shortened reference to this chunk."""
        txt = aWeaver.referenceTo(None, self.seq)
        aWeaver.codeBlock(txt)
    

..

    ..  class:: small

        |loz| *NamedChunk weave into the documentation (68)*. Used by: NamedChunk class... (`65`_)


The ``tangle()`` method tangles this chunk into the final document as follows:

1.  call the ``Tangler`` class ``codeBegin()`` method to set indents properly.

2.  visit each Command, calling the Command's ``tangle()`` method to emit the Command's content.

3.  call the ``Tangler`` class ``codeEnd()`` method to restore indents.

If a ``ReferenceCommand`` does raise an error during tangling,
we append this Chunk information and reraise the error with the additional 
context information.



..  _`69`:
..  rubric:: NamedChunk tangle into the source file (69) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        """Create source code.
        Use aWeb to resolve @<namedChunk@>.
        Format as correctly indented source text
        """
        self.previous\_command = TextCommand("", self.commands[0].lineNumber)
        aTangler.codeBegin(self)
        for t in self.commands:
            try:
                t.tangle(aWeb, aTangler)
            except Error as e:
                raise
            self.previous\_command = t
        aTangler.codeEnd(self)
    

..

    ..  class:: small

        |loz| *NamedChunk tangle into the source file (69)*. Used by: NamedChunk class... (`65`_)


There's a second variation on NamedChunk, one that doesn't indent based on 
context. It simply sets an indent at the left margin.


..  _`70`:
..  rubric:: NamedChunk class for defined names (70) +=
..  parsed-literal::
    :class: code

    
    class NamedChunk\_Noindent(NamedChunk):
        """Named piece of input file: will be output as both tangler and weaver."""
        def reference\_indent(self, aWeb: "Web", aTangler: "Tangler", amount: int) -> None:
            aTangler.setIndent(0)
        
        def reference\_dedent(self, aWeb: "Web", aTangler: "Tangler") -> None:
            aTangler.clrIndent()

..

    ..  class:: small

        |loz| *NamedChunk class for defined names (70)*. Used by: Chunk class hierarchy... (`52`_)

    
OutputChunk class
~~~~~~~~~~~~~~~~~~~

A ``OutputChunk`` is created and used identically to a ``NamedChunk``.
The difference between this class and the parent class is the decoration of 
the markup when weaving.

The ``OutputChunk`` class is a subclass of ``NamedChunk`` that handles 
file output chunks defined with ``@o``. 

The ``weave()`` method of a ``OutputChunk`` uses the Weaver's 
``fileBegin()`` and ``fileEnd()``
methods to insert text that is program source and requires additional
markup to make it stand out from documentation.  Other subclasses could override this to 
use different ``Weaver`` methods for different kinds of text.

All other methods, including the tangle method are identical to ``NamedChunk``.


..  _`71`:
..  rubric:: OutputChunk class (71) =
..  parsed-literal::
    :class: code

    
    class OutputChunk(NamedChunk):
        """Named piece of input file, defines an output tangle."""
        def \_\_init\_\_(self, name: str, comment\_start: str = "", comment\_end: str = "") -> None:
            super().\_\_init\_\_(name)
            self.comment\_start = comment\_start
            self.comment\_end = comment\_end
        |srarr|\ OutputChunk add to the web (`72`_)
        |srarr|\ OutputChunk weave (`73`_)
        |srarr|\ OutputChunk tangle (`74`_)
    

..

    ..  class:: small

        |loz| *OutputChunk class (71)*. Used by: Chunk class hierarchy... (`52`_)


The ``webAdd()`` method adds this chunk to the given document ``Web``.
Each class of ``Chunk`` must override this to be sure that the various
``Chunk`` classes are indexed properly.  This class uses the ``addOutput()`` method
of the ``Web`` class to append a file output chunk.


..  _`72`:
..  rubric:: OutputChunk add to the web (72) =
..  parsed-literal::
    :class: code

    
    def webAdd(self, web: "Web") -> None:
        """Add self to a Web as output chunk, update xrefs."""
        web.addOutput(self)
    

..

    ..  class:: small

        |loz| *OutputChunk add to the web (72)*. Used by: OutputChunk class... (`71`_)


The ``weave()`` method weaves this chunk into the final document as follows:

1.  call the ``Weaver`` class ``codeBegin()`` method to emit proper markup for an output file chunk.

2.  visit each ``Command``, call the Command's ``weave()`` method to emit the Command's content.

3.  call the ``Weaver`` class ``codeEnd()`` method to emit proper markup for an output file chunk.

These chunks of documentation are never tangled.  Any attempt is an
error.

If a ``ReferenceCommand`` does raise an error during weaving,
we append this ``Chunk`` information and reraise the error with the additional 
context information.



..  _`73`:
..  rubric:: OutputChunk weave (73) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create the nicely formatted document from a chunk of code."""
        self.fullName = aWeb.fullNameFor(self.name)
        aWeaver.fileBegin(self)
        for cmd in self.commands:
            cmd.weave(aWeb, aWeaver)
        aWeaver.fileEnd(self)
    

..

    ..  class:: small

        |loz| *OutputChunk weave (73)*. Used by: OutputChunk class... (`71`_)


When we tangle, we provide the output Chunk's comment information to the Tangler
to be sure that -- if line numbers were requested -- they can be included properly.


..  _`74`:
..  rubric:: OutputChunk tangle (74) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        aTangler.comment\_start = self.comment\_start
        aTangler.comment\_end = self.comment\_end
        super().tangle(aWeb, aTangler)

..

    ..  class:: small

        |loz| *OutputChunk tangle (74)*. Used by: OutputChunk class... (`71`_)


NamedDocumentChunk class
~~~~~~~~~~~~~~~~~~~~~~~~~

A ``NamedDocumentChunk`` is created and used identically to a ``NamedChunk``.
The difference between this class and the parent class is that this chunk
is only woven when referenced.  The original definition is silently skipped.

The ``NamedDocumentChunk`` class is a subclass of ``NamedChunk`` that handles 
named chunks defined with ``@d`` and the ``@[``\ ...\ ``@]`` delimiters.  
These are woven slightly
differently, since they are document source, not programming language source.

We're not as interested in the cross reference of named document chunks.
They can be used multiple times or never.  They are expected to be referenced
by anonymous chunks.  While this chunk subclass participates in this data 
gathering, it is ignored for reporting purposes.

All other methods, including the tangle method are identical to ``NamedChunk``.



..  _`75`:
..  rubric:: NamedDocumentChunk class (75) =
..  parsed-literal::
    :class: code

    
    class NamedDocumentChunk(NamedChunk):
        """Named piece of input file with document source, defines an output tangle."""
        
        def makeContent(self, text: str, lineNumber: int = 0) -> Command:
            return TextCommand(text, lineNumber)
            
        |srarr|\ NamedDocumentChunk weave (`76`_)
        |srarr|\ NamedDocumentChunk tangle (`77`_)
    

..

    ..  class:: small

        |loz| *NamedDocumentChunk class (75)*. Used by: Chunk class hierarchy... (`52`_)


The ``weave()`` method quietly ignores this chunk in the document.
A named document chunk is only included when it is referenced 
during weaving of another chunk (usually an anonymous document
chunk).

The ``weaveReferenceTo()`` method inserts the content of this
chunk into the output document.  This is done in response to a
``ReferenceCommand`` in another chunk.  
The ``weaveShortReferenceTo()`` method calls the ``weaveReferenceTo()``
to insert the entire chunk.



..  _`76`:
..  rubric:: NamedDocumentChunk weave (76) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Ignore this when producing the document."""
        pass
    def weaveReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """On a reference to this chunk, expand the body in place."""
        for cmd in self.commands:
            cmd.weave(aWeb, aWeaver)
    def weaveShortReferenceTo(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """On a reference to this chunk, expand the body in place."""
        self.weaveReferenceTo(aWeb, aWeaver)
    

..

    ..  class:: small

        |loz| *NamedDocumentChunk weave (76)*. Used by: NamedDocumentChunk class... (`75`_)



..  _`77`:
..  rubric:: NamedDocumentChunk tangle (77) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        """Raise an exception on an attempt to tangle."""
        raise Error("Cannot tangle a chunk defined with @[.""")
    

..

    ..  class:: small

        |loz| *NamedDocumentChunk tangle (77)*. Used by: NamedDocumentChunk class... (`75`_)


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

Each ``Command`` instance responds to methods to examine the content, gather 
cross reference information and tangle a file or weave the final document.



..  _`78`:
..  rubric:: Command class hierarchy - used to describe individual commands (78) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Command superclass (`79`_)
    
    |srarr|\ TextCommand class to contain a document text block (`82`_)
    
    |srarr|\ CodeCommand class to contain a program source code block (`83`_)
    
    |srarr|\ XrefCommand superclass for all cross-reference commands (`84`_)
    
    |srarr|\ FileXrefCommand class for an output file cross-reference (`85`_)
    
    |srarr|\ MacroXrefCommand class for a named chunk cross-reference (`86`_)
    
    |srarr|\ UserIdXrefCommand class for a user identifier cross-reference (`87`_)
    
    |srarr|\ ReferenceCommand class for chunk references (`88`_)

..

    ..  class:: small

        |loz| *Command class hierarchy - used to describe individual commands (78)*. Used by: Base Class Definitions (`1`_)


Command Superclass
~~~~~~~~~~~~~~~~~~~~

A ``Command`` is created by the ``WebReader``, and attached to a ``Chunk``.
The Command participates in cross reference creation, weaving and tangling.

The ``Command`` superclass is abstract, and has default methods factored out
of the various subclasses.  When a subclass is created, it will override some
of the methods provided in this superclass.

..  parsed-literal::

    class MyNewCommand(Command):
        *... overrides for various methods ...*

Additionally, a subclass of ``WebReader`` must be defined to parse the new command
syntax.  The main ``process()`` function must also be updated to use this new subclass
of ``WebReader``.


The ``Command`` superclass provides the parent class definition
for all of the various command types.  The most common command
is a block of text.
For tangling it is presented with no changes. For weaving, 
quoting is used to make it work nicely with the given markup language.

The next most
common command is a reference to a chunk. This is woven as a 
mark-up reference: a link. It is tangled as an expansion of the source 
code.

Additional methods include the following:

-   The ``startswith()`` method examines any source text to see if
    it begins with the given prefix text. 

-   The ``searchForRE()`` method examines any source text to see if
    it matches the given regular expression, usually a match for a user identifier.

-   The ``ref()`` method is ignored by all but the ``Reference`` subclass,
    which returns reference made by the command to the parent chunk.

-   The ``weave()`` method weaves this into the output.  If a document text
    command, it is emitted directly; if a program source code command, 
    markup is applied.  In the case of cross-reference commands,
    the actual cross-reference content is emitted.  In the case of 
    reference commands, they are woven as a reference to a named
    chunk.

-   The ``tangle()`` method tangles this into the output.  If a
    this is a document text command, it is ignored; if a this is a
    program source code
    command, it is indented and emitted.  In the case of cross-reference
    commands, no output is produced.  In the case of reference
    commands, the named chunk is indented and emitted.


The attributes of a ``Command`` instance includes the line number on which
the command began, in ``lineNumber``.


..  _`79`:
..  rubric:: Command superclass (79) =
..  parsed-literal::
    :class: code

    
    class Command(abc.ABC):
        """A Command is the lowest level of granularity in the input stream."""
        chunk : "Chunk"
        text : str
        def \_\_init\_\_(self, fromLine: int = 0) -> None:
            self.lineNumber = fromLine+1 # tokenizer is zero-based
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            
        def \_\_str\_\_(self) -> str:
            return f"at {self.lineNumber!r}"
            
        def \_\_eq\_\_(self, other: Any) -> bool:
            match other:
                case Command():
                    return self.lineNumber == other.lineNumber and self.text == other.text
                case \_:
                    return NotImplemented
                    
        |srarr|\ Command analysis features: starts-with and Regular Expression search (`80`_)
        |srarr|\ Command tangle and weave functions (`81`_)
    

..

    ..  class:: small

        |loz| *Command superclass (79)*. Used by: Command class hierarchy... (`78`_)



..  _`80`:
..  rubric:: Command analysis features: starts-with and Regular Expression search (80) =
..  parsed-literal::
    :class: code

    
    def startswith(self, prefix: str) -> bool:
        return False
    def searchForRE(self, rePat: Pattern[str]) -> Match[str] \| None:
        return None
    def indent(self) -> int:
        return 0
    

..

    ..  class:: small

        |loz| *Command analysis features: starts-with and Regular Expression search (80)*. Used by: Command superclass (`79`_)



..  _`81`:
..  rubric:: Command tangle and weave functions (81) =
..  parsed-literal::
    :class: code

    
    def ref(self, aWeb: "Web") -> str \| None:
        return None
        
    @abc.abstractmethod
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        ...
        
    @abc.abstractmethod
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        ...
    

..

    ..  class:: small

        |loz| *Command tangle and weave functions (81)*. Used by: Command superclass (`79`_)


TextCommand class
~~~~~~~~~~~~~~~~~~

A ``TextCommand`` is created by a ``Chunk`` or a ``NamedDocumentChunk`` when a 
``WebReader`` calls the chunk's ``appendText()`` method.

This Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 

An instance of the ``TextCommand`` class is a block of document text.  It can originate
in an anonymous block or a named chunk delimited with ``@[`` and ``@]``.

This subclass provides a concrete implementation for all of the methods.  Since
text is the author's original markup language, it is emitted directly to the weaver
or tangler.

**TODO:** Use textwrap.shorten to snip off first 32 chars of the text.


..  _`82`:
..  rubric:: TextCommand class to contain a document text block (82) =
..  parsed-literal::
    :class: code

    
    class TextCommand(Command):
        """A piece of document source text."""
        def \_\_init\_\_(self, text: str, fromLine: int = 0) -> None:
            super().\_\_init\_\_(fromLine)
            self.text = text
        def \_\_str\_\_(self) -> str:
            return f"at {self.lineNumber!r}: {self.text[:32]!r}..."
        def startswith(self, prefix: str) -> bool:
            return self.text.startswith(prefix)
        def searchForRE(self, rePat: Pattern[str]) -> Match[str] \| None:
            return rePat.search(self.text)
        def indent(self) -> int:
            if self.text.endswith('\\n'):
                return 0
            try:
                last\_line = self.text.splitlines()[-1]
                return len(last\_line)
            except IndexError:
                return 0
        def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
            aWeaver.write(self.text)
        def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
            aTangler.write(self.text)
    

..

    ..  class:: small

        |loz| *TextCommand class to contain a document text block (82)*. Used by: Command class hierarchy... (`78`_)


CodeCommand class
~~~~~~~~~~~~~~~~~~

A ``CodeCommand`` is created by a ``NamedChunk`` when a 
``WebReader`` calls the ``appendText()`` method.
The Command participates in cross reference creation, weaving and tangling.  When it is
created, the source line number is provided so that this text can be tied back
to the source document. 


An instance of the ``CodeCommand`` class is a block of program source code text.
It can originate in a named chunk (``@d``) with a ``@{`` and ``@}`` delimiter.
Or it can be a file output chunk (``@o``).


It uses the ``codeBlock()`` methods of a ``Weaver`` or ``Tangler``.  The weaver will 
insert appropriate markup for this code.  The tangler will assure that the prevailing
indentation is maintained.



..  _`83`:
..  rubric:: CodeCommand class to contain a program source code block (83) =
..  parsed-literal::
    :class: code

    
    class CodeCommand(TextCommand):
        """A piece of program source code."""
        def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
            aWeaver.codeBlock(aWeaver.quote(self.text))
        def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
            aTangler.codeBlock(self.text)
    

..

    ..  class:: small

        |loz| *CodeCommand class to contain a program source code block (83)*. Used by: Command class hierarchy... (`78`_)


XrefCommand superclass
~~~~~~~~~~~~~~~~~~~~~~~

An ``XrefCommand`` is created by the ``WebReader`` when any of the 
``@f``, ``@m``, ``@u`` commands are found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``XrefCommand`` superclass defines any common features of the
various cross-reference commands (``@f``, ``@m``, ``@u``).

The ``formatXref()`` method creates the body of a cross-reference
by the following algorithm:

1. Use the ``Weaver`` class ``xrefHead()`` method to emit the cross-reference header.

2. Sort the keys in the cross-reference mapping.

3. Use the ``Weaver`` class ``xrefLine()`` method to emit each line of the cross-reference mapping.

4. Use the ``Weaver`` class ``xrefFoot()`` method to emit the cross-reference footer.

If this command winds up in a tangle action, that use
is illegal.  An exception is raised and processing stops.

 

..  _`84`:
..  rubric:: XrefCommand superclass for all cross-reference commands (84) =
..  parsed-literal::
    :class: code

    
    class XrefCommand(Command):
        """Any of the Xref-goes-here commands in the input."""
        def \_\_str\_\_(self) -> str:
            return f"at {self.lineNumber!r}: cross reference"
            
        def formatXref(self, xref: dict[str, list[int]], aWeaver: "Weaver") -> None:
            aWeaver.xrefHead()
            for n in sorted(xref):
                aWeaver.xrefLine(n, xref[n])
            aWeaver.xrefFoot()
            
        def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
            raise Error('Illegal tangling of a cross reference command.')
    

..

    ..  class:: small

        |loz| *XrefCommand superclass for all cross-reference commands (84)*. Used by: Command class hierarchy... (`78`_)


FileXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``FileXrefCommand`` is created by the ``WebReader`` when the 
``@f`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``FileXrefCommand`` class weave method gets the
file cross reference from the overall web instance, and uses
the  ``formatXref()`` method of the ``XrefCommand`` superclass for format this result.



..  _`85`:
..  rubric:: FileXrefCommand class for an output file cross-reference (85) =
..  parsed-literal::
    :class: code

    
    class FileXrefCommand(XrefCommand):
        """A FileXref command."""
        def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
            """Weave a File Xref from @o commands."""
            self.formatXref(aWeb.fileXref(), aWeaver)
    

..

    ..  class:: small

        |loz| *FileXrefCommand class for an output file cross-reference (85)*. Used by: Command class hierarchy... (`78`_)


MacroXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~

A ``MacroXrefCommand`` is created by the ``WebReader`` when the 
``@m`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``MacroXrefCommand`` class weave method gets the
named chunk (macro) cross reference from the overall web instance, and uses
the ``formatXref()`` method of the ``XrefCommand`` superclass method for format this result.



..  _`86`:
..  rubric:: MacroXrefCommand class for a named chunk cross-reference (86) =
..  parsed-literal::
    :class: code

    
    class MacroXrefCommand(XrefCommand):
        """A MacroXref command."""
        def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
            """Weave the Macro Xref from @d commands."""
            self.formatXref(aWeb.chunkXref(), aWeaver)
    

..

    ..  class:: small

        |loz| *MacroXrefCommand class for a named chunk cross-reference (86)*. Used by: Command class hierarchy... (`78`_)


UserIdXrefCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``MacroXrefCommand`` is created by the ``WebReader`` when the 
``@u`` command is found in the input stream.
The Command is then appended to the current Chunk being built by the WebReader.

The ``UserIdXrefCommand`` class weave method gets the
user identifier cross reference information from the 
overall web instance.  It then formats this line using the following 
algorithm, which is similar to the algorithm in the ``XrefCommand`` superclass.

1.  Use the ``Weaver`` class ``xrefHead()`` method to emit the cross-reference header.

2.  Sort the keys in the cross-reference mapping.

3.  Use the ``Weaver`` class ``xrefDefLine()`` method to emit each line of the cross-reference definition mapping.

4.  Use the ``Weaver`` class ``xrefFoor()`` method to emit the cross-reference footer.



..  _`87`:
..  rubric:: UserIdXrefCommand class for a user identifier cross-reference (87) =
..  parsed-literal::
    :class: code

    
    class UserIdXrefCommand(XrefCommand):
        """A UserIdXref command."""
        def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
            """Weave a user identifier Xref from @d commands."""
            ux = aWeb.userNamesXref()
            if len(ux) != 0:
                aWeaver.xrefHead()
                for u in sorted(ux):
                    defn, refList = ux[u]
                    aWeaver.xrefDefLine(u, defn, refList)
                aWeaver.xrefFoot()
            else:
                aWeaver.xrefEmpty()
    

..

    ..  class:: small

        |loz| *UserIdXrefCommand class for a user identifier cross-reference (87)*. Used by: Command class hierarchy... (`78`_)


ReferenceCommand class
~~~~~~~~~~~~~~~~~~~~~~~

A ``ReferenceCommand`` instance is created by a ``WebReader`` when
a ``@<``\ *name*\ ``@>`` construct in is found in the input stream.  This is attached
to the current ``Chunk`` being built by the WebReader.  
 

During a weave, this creates a markup reference to
another ``NamedChunk``.  During tangle, this actually includes the ``NamedChunk`` 
at this point in the tangled output file.


The constructor creates several attributes of an instance
of a ``ReferenceCommand``.


:refTo:
    the name of the chunk to which this refers, possibly 
    elided with a trailing ``'...'``.

:fullName:
    the full name of the chunk to which this refers.

:chunkList:
    the list of the chunks to which the name refers.



..  _`88`:
..  rubric:: ReferenceCommand class for chunk references (88) =
..  parsed-literal::
    :class: code

    
    class ReferenceCommand(Command):
        """A reference to a named chunk, via @<name@>."""
        def \_\_init\_\_(self, refTo: str, fromLine: int = 0) -> None:
            super().\_\_init\_\_(fromLine)
            self.refTo = refTo
            self.fullname = None
            self.sequenceList = None
            self.chunkList: list[Chunk] = []
            
        def \_\_str\_\_(self) -> str:
            return "at {self.lineNumber!r}: reference to chunk {self.refTo!r}"
            
        |srarr|\ ReferenceCommand resolve a referenced chunk name (`89`_)
        |srarr|\ ReferenceCommand refers to a chunk (`90`_)
        |srarr|\ ReferenceCommand weave a reference to a chunk (`91`_)
        |srarr|\ ReferenceCommand tangle a referenced chunk (`92`_)
    

..

    ..  class:: small

        |loz| *ReferenceCommand class for chunk references (88)*. Used by: Command class hierarchy... (`78`_)


The ``resolve()`` method queries the overall ``Web`` instance for the full
name and sequence number for this chunk reference.  This is used
by the ``Weaver`` class ``referenceTo()`` method to write the markup reference
to the chunk.



..  _`89`:
..  rubric:: ReferenceCommand resolve a referenced chunk name (89) =
..  parsed-literal::
    :class: code

    
    def resolve(self, aWeb: "Web") -> None:
        """Expand our chunk name and list of parts"""
        self.fullName = aWeb.fullNameFor(self.refTo)
        self.chunkList = aWeb.getchunk(self.refTo)
    

..

    ..  class:: small

        |loz| *ReferenceCommand resolve a referenced chunk name (89)*. Used by: ReferenceCommand class... (`88`_)


The ``ref()`` method is a request that is delegated by a ``Chunk``;
it resolves the reference this Command makes within the containing Chunk.
When the Chunk iterates through the Commands, it can accumulate a list of 
Chinks to which it refers.



..  _`90`:
..  rubric:: ReferenceCommand refers to a chunk (90) =
..  parsed-literal::
    :class: code

    
    def ref(self, aWeb: "Web") -> str:
        """Find and return the full name for this reference."""
        self.resolve(aWeb)
        return self.fullName
    

..

    ..  class:: small

        |loz| *ReferenceCommand refers to a chunk (90)*. Used by: ReferenceCommand class... (`88`_)


The ``weave()`` method inserts a markup reference to a named
chunk.  It uses the ``Weaver`` class ``referenceTo()`` method to format
this appropriately for the document type being woven.



..  _`91`:
..  rubric:: ReferenceCommand weave a reference to a chunk (91) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeb: "Web", aWeaver: "Weaver") -> None:
        """Create the nicely formatted reference to a chunk of code."""
        self.resolve(aWeb)
        aWeb.weaveChunk(self.fullName, aWeaver)
    

..

    ..  class:: small

        |loz| *ReferenceCommand weave a reference to a chunk (91)*. Used by: ReferenceCommand class... (`88`_)


The ``tangle()`` method inserts the resolved chunk in this
place.  When a chunk is tangled, it sets the indent,
inserts the chunk and resets the indent.

This is where the Tangler indentation is updated by a reference.
Or where indentation is set to a local zero because the included
Chunk is a no-indent Chunk.


..  _`92`:
..  rubric:: ReferenceCommand tangle a referenced chunk (92) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aWeb: "Web", aTangler: "Tangler") -> None:
        """Create source code."""
        self.resolve(aWeb)
        
        self.logger.debug("Indent %r + %r", aTangler.context, self.chunk.previous\_command.indent())    
        self.chunk.reference\_indent(aWeb, aTangler, self.chunk.previous\_command.indent())
        
        self.logger.debug("Tangling %r with chunks %r", self.fullName, self.chunkList)
        if len(self.chunkList) != 0:
            for p in self.chunkList:
                p.tangle(aWeb, aTangler)
        else:
            raise Error(f"Attempt to tangle an undefined Chunk, {self.fullName!s}.")
    
        self.chunk.reference\_dedent(aWeb, aTangler)
    

..

    ..  class:: small

        |loz| *ReferenceCommand tangle a referenced chunk (92)*. Used by: ReferenceCommand class... (`88`_)


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



..  _`93`:
..  rubric:: Reference class hierarchy - strategies for references to a chunk (93) =
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

        |loz| *Reference class hierarchy - strategies for references to a chunk (93)*. Used by: Base Class Definitions (`1`_)


SimpleReference Class
~~~~~~~~~~~~~~~~~~~~~

The SimpleReference subclass does the simplest version of resolution. It returns
the ``Chunks`` referenced.
    

..  _`94`:
..  rubric:: Reference class hierarchy - strategies for references to a chunk (94) +=
..  parsed-literal::
    :class: code

    
    class SimpleReference(Reference):
        def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
            refBy = aChunk.referencedBy
            return refBy

..

    ..  class:: small

        |loz| *Reference class hierarchy - strategies for references to a chunk (94)*. Used by: Base Class Definitions (`1`_)


TransitiveReference Class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The TransitiveReference subclass does a transitive closure of all
references to this Chunk.

This requires walking through the ``Web`` to locate "parents" of each referenced
``Chunk``.


..  _`95`:
..  rubric:: Reference class hierarchy - strategies for references to a chunk (95) +=
..  parsed-literal::
    :class: code

    
    class TransitiveReference(Reference):
        def chunkReferencedBy(self, aChunk: Chunk) -> list[Chunk]:
            refBy = aChunk.referencedBy
            self.logger.debug("References: %r(%d) %r", aChunk.name, aChunk.seq, refBy)
            return self.allParentsOf(refBy)
        def allParentsOf(self, chunkList: list[Chunk], depth: int = 0) -> list[Chunk]:
            """Transitive closure of parents via recursive ascent.
            """
            final = []
            for c in chunkList:
                final.append(c)
                final.extend(self.allParentsOf(c.referencedBy, depth+1))
            self.logger.debug(f"References: {'--':>{2\*depth}s} {final!s}")
            return final

..

    ..  class:: small

        |loz| *Reference class hierarchy - strategies for references to a chunk (95)*. Used by: Base Class Definitions (`1`_)



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



..  _`96`:
..  rubric:: Error class - defines the errors raised (96) =
..  parsed-literal::
    :class: code

    
    class Error(Exception): pass

..

    ..  class:: small

        |loz| *Error class - defines the errors raised (96)*. Used by: Base Class Definitions (`1`_)


The Web and WebReader Classes
-----------------------------

The overall web of chunks is carried in a 
single instance of the ``Web`` class that is the principle parameter for the weaving and tangling actions.  
Broadly, the functionality of a Web can be separated into several areas.

It supports  construction methods used by ``Chunks`` and ``WebReader``.

It also supports "enrichment" of the web, once all the Chunks are known. 
This is a stateful update to the web.  Each Chunk is updated with Chunk 
references it makes as well as Chunks which reference it.

It supports ``Chunk`` cross-reference methods that traverse this enriched data.
This includes a kind of validity check to be sure that everything is used once
and once only. 

More importantly, it supports tangle and weave operations.

Fundamentally, a ``Web`` is a hybrid list-dictionary.  

-   It's a mapping of chunks that also offers a 
    moderately sophisticated
    lookup, including exact match for a chunk name and an approximate match for a chunk name. 
    There are several methods to  resolve references among chunks.

-   It's a sequence that retains all chunks in order, also. 
    It may be a good candidate to be an ``OrderedDict``, but there are multiple keys. Both Chunk
    names and chunk numbers are used. 

A web instance has a number of attributes.

:web_path:
    the Path of the source ``.w`` file.

:chunkSeq:
    the sequence of ``Chunk`` instances as seen in the input file.
    To support anonymous chunks, and to assure that the original input document order
    is preserved, we keep all chunks in a master sequential list.

:output:
    the ``@o`` named ``OutputChunk`` chunks.  
    Each element of this  dictionary is a sequence of chunks that have the same name. 
    The first is the initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:named:
    the ``@d`` named ``NamedChunk`` chunks.  Each element of this 
    dictionary is a sequence of chunks that have the same name.  The first is the
    initial definition (marked with "="), all others a second definitions
    (marked with "+=").

:usedBy:
    the cross reference of chunks referenced by commands in other
    chunks.

!sequence:
    is used to assign a unique sequence number to each
    named chunk.
    

..  _`97`:
..  rubric:: Web class - describes the overall "web" of chunks (97) =
..  parsed-literal::
    :class: code

    
    class Web:
        """The overall Web of chunks."""
        def \_\_init\_\_(self, file\_path: Path \| None = None) -> None:
            self.web\_path = file\_path
            self.chunkSeq: list[Chunk] = [] 
            self.output: dict[str, list[Chunk]] = {} # Map filename to Chunk
            self.named: dict[str, list[Chunk]] = {} # Map chunkname to Chunk
            self.sequence = 0
            self.errors = 0
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            
        def \_\_str\_\_(self) -> str:
            return f"Web {self.web\_path!r}"
    
        |srarr|\ Web construction methods used by Chunks and WebReader (`99`_)
        |srarr|\ Web Chunk name resolution methods (`104`_), |srarr|\ (`105`_)
        |srarr|\ Web Chunk cross reference methods (`106`_), |srarr|\ (`108`_), |srarr|\ (`109`_), |srarr|\ (`110`_)
        |srarr|\ Web determination of the language from the first chunk (`113`_)
        |srarr|\ Web tangle the output files (`114`_)
        |srarr|\ Web weave the output document (`115`_)
    

..

    ..  class:: small

        |loz| *Web class - describes the overall "web" of chunks (97)*. Used by: Base Class Definitions (`1`_)


Web Construction
~~~~~~~~~~~~~~~~~

During web construction, it is convenient to capture
information about the individual ``Chunk`` instances being appended to
the web.  This done using a **Callback** design pattern.
Each subclass of ``Chunk`` provides an override for the ``Chunk`` class
``webAdd()`` method.  This override calls one of the appropriate
web construction methods.

Also note that the full name for a chunk can be given
either as part of the definition, or as part a reference.
Typically, the first reference has the full name and the definition
has the elided name.  This allows a reference to a chunk
to contain a more complete description of the chunk.

We include a weakref to the ``Web`` to each ``Chunk``.


..  _`98`:
..  rubric:: Imports (98) +=
..  parsed-literal::
    :class: code

    import weakref
    

..

    ..  class:: small

        |loz| *Imports (98)*. Used by: pyweb.py (`155`_)



..  _`99`:
..  rubric:: Web construction methods used by Chunks and WebReader (99) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Web add full chunk names, ignoring abbreviated names (`100`_)
    |srarr|\ Web add an anonymous chunk (`101`_)
    |srarr|\ Web add a named macro chunk (`102`_)
    |srarr|\ Web add an output file definition chunk (`103`_)

..

    ..  class:: small

        |loz| *Web construction methods used by Chunks and WebReader (99)*. Used by: Web class... (`97`_)


A name is only added to the known names when it is
a full name, not an abbreviation ending with ``"..."``.
Abbreviated names are quietly skipped until the full name
is seen.


The algorithm for the ``addDefName()`` method, then is as follows:

1.  Use the ``fullNameFor()`` method to locate the full name.

2.  If no full name was found (the result of ``fullNameFor()`` ends with ``'...'``), 
    ignore this name as an abbreviation with no definition.

3.  If this is a full name and the name was not in the ``named`` mapping, add this full name to the mapping.



This name resolution approach presents a problem when a chunk's first definition
uses an abbreviated name.  

..  note:: Improved use case needed.

    We can be more flexible about assembling the web if we 
    tolerate "..." elipsis as the initial use of a name.
        
    We have to fold the abbreviated name(s) 
    into the Web. Prior to tangling, we have to
    resolve the various abbreviated names to their proper
    full names. This would then merge the chunks into a single
    sequence. 

    We preserve source document ordering between the variations
    on the name using the chunk sequence numbers.
    
    Here "prior to tangling" means either eagerly -- as each full name arrives -- 
    or lazily -- after the entire Web is built.
    
    We would no longer need to return a value from this function, either.


..  _`100`:
..  rubric:: Web add full chunk names, ignoring abbreviated names (100) =
..  parsed-literal::
    :class: code

    
    def addDefName(self, name: str) -> str \| None:
        """Reference to or definition of a chunk name."""
        nm = self.fullNameFor(name)
        if nm is None: return None
        if nm[-3:] == '...':
            self.logger.debug("Abbreviated reference %r", name)
            return None # first occurance is a forward reference using an abbreviation
        if nm not in self.named:
            self.named[nm] = []
            self.logger.debug("Adding empty chunk %r", name)
        return nm
    

..

    ..  class:: small

        |loz| *Web add full chunk names, ignoring abbreviated names (100)*. Used by: Web construction... (`99`_)


An anonymous ``Chunk`` is kept in a sequence of Chunks, used for
tangling.



..  _`101`:
..  rubric:: Web add an anonymous chunk (101) =
..  parsed-literal::
    :class: code

    
    def add(self, chunk: Chunk) -> None:
        """Add an anonymous chunk."""
        self.chunkSeq.append(chunk)
        chunk.web = weakref.ref(self)
    

..

    ..  class:: small

        |loz| *Web add an anonymous chunk (101)*. Used by: Web construction... (`99`_)


A named ``Chunk`` is defined with a ``@d`` command.
It is collected into a mapping of ``NamedChunk`` instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.


All chunks are also placed in the overall sequence of chunks.
This overall sequence is used for weaving the document.


The ``addDefName()`` method is used to resolve this name if
it is an abbreviation, or add it to the mapping if this
is the first occurance of the name.  If the name cannot be
added, an instance of our ``Error`` class is raised.  If the name exists or 
was added, the chunk is appended to the chunk list associated
with this name.


The Web's sequence counter is incremented, and this 
unique sequence number sets the ``seq`` attribute of the ``Chunk``.
If the chunk list was empty, this is the first chunk, the
``initial`` flag is set to True when there's only one element
in the list.  Otherwise, it's False.

..  note:: Improved use case.

    If we improve name resolution, then the if and exception can go away.
    The ``addDefName()`` no longer needs to return a value. 


..  _`102`:
..  rubric:: Web add a named macro chunk (102) =
..  parsed-literal::
    :class: code

    
    def addNamed(self, chunk: Chunk) -> None:
        """Add a named chunk to a sequence with a given name."""
        self.chunkSeq.append(chunk)
        chunk.web = weakref.ref(self)
        nm = self.addDefName(chunk.name)
        if nm:
            # We found the full name for this chunk
            self.sequence += 1
            chunk.seq = self.sequence
            chunk.fullName = nm
            self.named[nm].append(chunk)
            chunk.initial = len(self.named[nm]) == 1
            self.logger.debug("Extending chunk %r from %r", nm, chunk.name)
        else:
            raise Error(f"No full name for {chunk.name!r}", chunk)
    

..

    ..  class:: small

        |loz| *Web add a named macro chunk (102)*. Used by: Web construction... (`99`_)


An output file definition ``Chunk`` is defined with an ``@o``
command.  It is collected into a mapping of ``OutputChunk`` instances.
An entry in the mapping is a sequence of chunks that have the
same name.  This sequence of chunks is used to produce the
weave or tangle output.


Note that file names cannot be abbreviated.

All chunks are also placed in overall sequence of chunks.
This overall sequence is used for weaving the document.


If the name does not exist in the ``output`` mapping,
the name is added with an empty sequence of chunks.
In all cases, the chunk is 
appended to the chunk list associated
with this name.


The web's sequence counter is incremented, and this 
unique sequence number sets the Chunk's ``seq`` attribute.
If the chunk list was empty, this is the first chunk, the
``initial`` flag is True if this is the first chunk.




..  _`103`:
..  rubric:: Web add an output file definition chunk (103) =
..  parsed-literal::
    :class: code

    
    def addOutput(self, chunk: Chunk) -> None:
        """Add an output chunk to a sequence with a given name."""
        self.chunkSeq.append(chunk)
        chunk.web = weakref.ref(self)
        if chunk.name not in self.output:
            self.output[chunk.name] = []
            self.logger.debug("Adding chunk %r", chunk.name)
        self.sequence += 1
        chunk.seq = self.sequence
        chunk.fullName = chunk.name
        self.output[chunk.name].append(chunk)
        chunk.initial = len(self.output[chunk.name]) == 1
    

..

    ..  class:: small

        |loz| *Web add an output file definition chunk (103)*. Used by: Web construction... (`99`_)


Web Chunk Name Resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~

Web Chunk name resolution has three aspects.  The first
is resolving elided names (those ending with ``...``) to their
full names.  The second is finding the named chunk
in the web structure.  The third is returning a reference
to a specific chunk including the name and sequence number.

Note that a Chunk name actually refers to a sequence
of Chunk instances.  Multiple definitions for a Chunk are allowed, and
all of the definitions are concatenated to create the complete
Chunk.  This complexity makes it unwise to return the sequence
of same-named Chunk; therefore, we put the burden on the Web to 
process all Chunk with a given name, in sequence.

The ``fullNameFor()`` method resolves full name for a chunk as follows:

1.  If the string is already in the ``named`` mapping, this is the full name

2.  If the string ends in ``'...'``, visit each key in the dictionary 
    to see if the key starts with the string up to the trailing ``'...'``.  
    If a match is found, the dictionary key is the full name.

3.  Otherwise, treat this as a full name.



..  _`104`:
..  rubric:: Web Chunk name resolution methods (104) =
..  parsed-literal::
    :class: code

    
    def fullNameFor(self, name: str) -> str:
        """Resolve "..." names into the full name."""
        if name in self.named: 
            return name
        elif name.endswith('...'):
            best = [n 
                for n in self.named
                if n.startswith(name[:-3])
            ]
            match best:
                case []:
                    return name
                case [singleton]:
                    return singleton
                case \_:
                    raise Error(f"Ambiguous abbreviation {name!r}, matches {sorted(best)!r}")
        else:
            return name
    

..

    ..  class:: small

        |loz| *Web Chunk name resolution methods (104)*. Used by: Web class... (`97`_)


The ``getchunk()`` method locates a named sequence of chunks by first determining the full name
for the identifying string.  If full name is in the ``named`` mapping, the sequence
of chunks is returned.  Otherwise, an instance of our ``Error`` class is raised because the name
is unresolvable.


It might be more helpful for debugging to emit this as an error in the
weave and tangle results and keep processing.  This would allow an author to
catch multiple errors in a single run of **py-web-tool** .
 

..  _`105`:
..  rubric:: Web Chunk name resolution methods (105) +=
..  parsed-literal::
    :class: code

    
    def getchunk(self, name: str) -> list[Chunk]:
        """Locate a named sequence of chunks."""
        nm = self.fullNameFor(name)
        if nm in self.named:
            return self.named[nm]
        raise Error(f"Cannot resolve {name!r} in {self.named.keys()!r}")
    

..

    ..  class:: small

        |loz| *Web Chunk name resolution methods (105)*. Used by: Web class... (`97`_)


Web Cross-Reference Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cross-reference support includes creating and reporting
on the various cross-references available in a web.  This includes
creating the list of chunks that reference a given chunk;
and returning the file, macro and user identifier cross references.

Each ``Chunk`` has a list ``Reference`` commands that shows the chunks
to which a chunk refers.  These relationships must be reversed to show
the chunks that refer to a given chunk.  This is done by traversing
the entire web of named chunks and recording each chunk-to-chunk reference.
This mapping has the referred-to chunk as 
the key, and a sequence of referring chunks as the value.

The accumulation is initiated by the web's ``createUsedBy()`` method.  This
method visits a ``Chunk``, calling the ``genReferences()`` method, 
passing in the ``Web`` instance
as an argument.  Each ``Chunk`` class ``genReferences()`` method, in turn, 
invokes the ``usedBy()`` method
of each ``Command`` instance in the chunk.  Most commands do nothing, 
but a ``ReferenceCommand``
will resolve the name to which it refers.

When the ``createUsedBy()`` method has accumulated the entire cross 
reference, it also assures that all chunks are used exactly once.


..  _`106`:
..  rubric:: Web Chunk cross reference methods (106) =
..  parsed-literal::
    :class: code

    
    def createUsedBy(self) -> None:
        """Update every piece of a Chunk to show how the chunk is referenced.
        Each piece can then report where it's used in the web.
        """
        for aChunk in self.chunkSeq:
            #usage = (self.fullNameFor(aChunk.name), aChunk.seq)
            for aRefName in aChunk.genReferences(self):
                for c in self.getchunk(aRefName):
                    c.referencedBy.append(aChunk)
                    c.refCount += 1
                    
        |srarr|\ Web Chunk check reference counts are all one (`107`_)
    

..

    ..  class:: small

        |loz| *Web Chunk cross reference methods (106)*. Used by: Web class... (`97`_)


We verify that the reference count for a
Chunk is exactly one.  We don't gracefully tolerate multiple references to
a Chunk or unreferenced chunks.


..  _`107`:
..  rubric:: Web Chunk check reference counts are all one (107) =
..  parsed-literal::
    :class: code

    
    for nm in self.no\_reference():
        self.logger.warning("No reference to %r", nm)
    for nm in self.multi\_reference():
        self.logger.warning("Multiple references to %r", nm)
    for nm in self.no\_definition():
        self.logger.error("No definition for %r", nm)
        self.errors += 1

..

    ..  class:: small

        |loz| *Web Chunk check reference counts are all one (107)*. Used by: Web Chunk cross reference methods... (`106`_)


An alternative one-pass version of the above algorithm:

..  parsed-literal::

    for nm, cl in self.named.items():
        if len(cl) > 0:
            if cl[0].refCount == 0:
               self.logger.warning("No reference to %r", nm)
            elif cl[0].refCount > 1:
               self.logger.warning("Multiple references to %r", nm)
        else:
            self.logger.error("No definition for %r", nm)


We use three methods to filter chunk names into 
the various warning categories.  The ``no_reference`` list
is a list of chunks defined by never referenced.
The ``multi_reference`` list
is a list of chunks defined by never referenced.
The ``no_definition`` list
is a list of chunks referenced but not defined.



..  _`108`:
..  rubric:: Web Chunk cross reference methods (108) +=
..  parsed-literal::
    :class: code

    
    def no\_reference(self) -> list[str]:
        return [nm for nm, cl in self.named.items() if len(cl)>0 and cl[0].refCount == 0]
    def multi\_reference(self) -> list[str]:
        return [nm for nm, cl in self.named.items() if len(cl)>0 and cl[0].refCount > 1]
    def no\_definition(self) -> list[str]:
        return [nm for nm, cl in self.named.items() if len(cl) == 0] 
    

..

    ..  class:: small

        |loz| *Web Chunk cross reference methods (108)*. Used by: Web class... (`97`_)


The ``fileXref()`` method visits all named file output chunks in ``output`` and
collects the sequence numbers of each section in the sequence of chunks.

The ``chunkXref()`` method uses the same algorithm as a the ``fileXref()`` method,
but applies it to the ``named`` mapping.


..  _`109`:
..  rubric:: Web Chunk cross reference methods (109) +=
..  parsed-literal::
    :class: code

    
    def fileXref(self) -> dict[str, list[int]]:
        fx = {}
        for f, cList in self.output.items():
            fx[f] = [c.seq for c in cList]
        return fx
    def chunkXref(self) -> dict[str, list[int]]:
        mx = {}
        for n, cList in self.named.items():
            mx[n] = [c.seq for c in cList]
        return mx
    

..

    ..  class:: small

        |loz| *Web Chunk cross reference methods (109)*. Used by: Web class... (`97`_)


The ``userNamesXref()`` method creates a mapping for each
user identifier.  The value for this mapping is a tuple
with the chunk that defined the identifer (via a ``@|`` command), 
and a sequence of chunks that reference the identifier. 

For example:
``{'Web': (87, (88,93,96,101,102,104)), 'Chunk': (53, (54,55,56,60,57,58,59))}``, 
shows that the identifier
``'Web'`` is defined in chunk with a sequence number of 87, and referenced
in the sequence of chunks that follow.


This works in two passes:

1.  ``_gatherUserId()`` gathers all user identifiers

2.  ``_updateUserId()`` searches all text commands for the identifiers 
    and updates the ``Web`` class cross reference information.




..  _`110`:
..  rubric:: Web Chunk cross reference methods (110) +=
..  parsed-literal::
    :class: code

    
    def userNamesXref(self) -> dict[str, tuple[int, list[int]]]:
        ux: dict[str, tuple[int, list[int]]] = {}
        self.\_gatherUserId(self.named, ux)
        self.\_gatherUserId(self.output, ux)
        self.\_updateUserId(self.named, ux)
        self.\_updateUserId(self.output, ux)
        return ux
        
    def \_gatherUserId(self, chunkMap: dict[str, list[Chunk]], ux: dict[str, tuple[int, list[int]]]) -> None:
        |srarr|\ collect all user identifiers from a given map into ux (`111`_)
        
    def \_updateUserId(self, chunkMap: dict[str, list[Chunk]], ux: dict[str, tuple[int, list[int]]]) -> None:
        |srarr|\ find user identifier usage and update ux from the given map (`112`_)
    

..

    ..  class:: small

        |loz| *Web Chunk cross reference methods (110)*. Used by: Web class... (`97`_)


User identifiers are collected by visiting each of the sequence of 
``Chunks`` that share the
same name; within each component chunk, if chunk has identifiers assigned
by the ``@|`` command, these are seeded into the dictionary.
If the chunk does not permit identifiers, it simply returns an empty
list as a default action.

 

..  _`111`:
..  rubric:: collect all user identifiers from a given map into ux (111) =
..  parsed-literal::
    :class: code

    
    for n,cList in chunkMap.items():
        for c in cList:
            for id in c.getUserIDRefs():
                ux[id] = (c.seq, [])

..

    ..  class:: small

        |loz| *collect all user identifiers from a given map into ux (111)*. Used by: Web Chunk cross reference methods... (`110`_)


User identifiers are cross-referenced by visiting 
each of the sequence of ``Chunks`` that share the
same name; within each component chunk, visit each user identifier;
if the ``Chunk`` class ``searchForRE()`` method matches an identifier, 
this is appended to the sequence of chunks that reference the original user identifier.



..  _`112`:
..  rubric:: find user identifier usage and update ux from the given map (112) =
..  parsed-literal::
    :class: code

    
    # examine source for occurrences of all names in ux.keys()
    for id in ux.keys():
        self.logger.debug("References to %r", id)
        idpat = re.compile(f'\\\\W{id}\\\\W')
        for n,cList in chunkMap.items():
            for c in cList:
                if c.seq != ux[id][0] and c.searchForRE(idpat):
                    ux[id][1].append(c.seq)

..

    ..  class:: small

        |loz| *find user identifier usage and update ux from the given map (112)*. Used by: Web Chunk cross reference methods... (`110`_)


Loop Detection
~~~~~~~~~~~~~~~~~~~~~~~~~~

How do we assure that the web is a proper tree and doesn't contain any loops?

Consider this example web 

..  parsed-literal::

    @o example1 @{
        @<part 1A@>
    @}
    
    @d part 1A @{
        @<part 1B@>
    @}
    
    @d part 1B @{
        @<part 1A@>
    @}
    
All valid chunks are must be referenced from a ``@o`` chunk, either directly,
or indirectly via one or more ``@<``\ *name*\ ``@>`` references. This defines a 
proper tree with ``@o`` at the root and children at each ``@d``.

Each chunk can have multiple references to further ``@d`` definitions.
No chunk can reference the ``@o`` definition at the root.

To be circular, two ``@d`` chunks must reference each other.  

To be valid, either (or both) must be named by the ``@o``. There will, therefore,
be two references: from the ``@o`` and a ``@d``. Our check for duplicate references will spot this.

We do not need to do a proper BFS or DFS through the graph to check for loops.
The simple reference count will do.

Tangle and Weave Support
~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``language()`` method makes a stab at determining the output language.
The determination of the language can be done a variety of ways.
One is to use command line parameters, another is to use the filename
extension on the input file.

We examine the first few characters of input.  A proper HTML, XHTML or
XML file begins with '<!', '<?' or '<H'.  
LaTeX files typically begin with '%' or '\'.
Everything else is probably RST.


..  _`113`:
..  rubric:: Web determination of the language from the first chunk (113) =
..  parsed-literal::
    :class: code

    
    def language(self, preferredWeaverClass: type["Weaver"] \| None = None) -> "Weaver":
        """Construct a weaver appropriate to the document's language"""
        if preferredWeaverClass:
            return preferredWeaverClass()
        self.logger.debug("Picking a weaver based on first chunk %r", str(self.chunkSeq[0])[:4])
        if self.chunkSeq[0].startswith('<'): 
            return HTML()
        if self.chunkSeq[0].startswith('%') or self.chunkSeq[0].startswith('\\\\'):  
            return LaTeX()
        return RST()
    

..

    ..  class:: small

        |loz| *Web determination of the language from the first chunk (113)*. Used by: Web class... (`97`_)


The ``tangle()`` method of the ``Web`` class performs 
the ``tangle()`` method for each ``Chunk`` of each
named output file.  Note that several ``Chunks`` may share the file name, requiring
the file be composed of material from each ``Chunk``, in order.


..  _`114`:
..  rubric:: Web tangle the output files (114) =
..  parsed-literal::
    :class: code

    
    def tangle(self, aTangler: "Tangler") -> None:
        for f, c in self.output.items():
            with aTangler.open(Path(f)):
                for p in c:
                    p.tangle(self, aTangler)
    

..

    ..  class:: small

        |loz| *Web tangle the output files (114)*. Used by: Web class... (`97`_)


The ``weave()`` method of the ``Web`` class creates the final documentation.
This is done by stepping through each ``Chunk`` in sequence
and weaving the chunk into the resulting file via the ``Chunk`` class ``weave()`` method.

During weaving of a chunk, the chunk may reference another
chunk.  When weaving a reference to a named chunk (output or ordinary programming
source defined with ``@{``), this does not lead to transitive weaving: only a
reference is put in from one chunk to another.  However, when weaving
a chunk defined with ``@[``, the chunk *is* expanded when weaving.
The decision is delegated to the referenced chunk.

**TODO** Can we refactor weaveChunk out of here entirely?
    Should it go in ``ReferenceCommand weave...``?


..  _`115`:
..  rubric:: Web weave the output document (115) =
..  parsed-literal::
    :class: code

    
    def weave(self, aWeaver: "Weaver") -> None:
        self.logger.debug("Weaving file from '%s'", self.web\_path)
        if not self.web\_path:
            raise Error("No filename supplied for weaving.")
        with aWeaver.open(self.web\_path):
            for c in self.chunkSeq:
                c.weave(self, aWeaver)
                
    def weaveChunk(self, name: str, aWeaver: "Weaver") -> None:
        self.logger.debug("Weaving chunk %r", name)
        chunkList = self.getchunk(name)
        if not chunkList:
            raise Error(f"No Definition for {name!r}")
        chunkList[0].weaveReferenceTo(self, aWeaver)
        for p in chunkList[1:]:
            aWeaver.write(aWeaver.referenceSep())
            p.weaveShortReferenceTo(self, aWeaver)
    

..

    ..  class:: small

        |loz| *Web weave the output document (115)*. Used by: Web class... (`97`_)


The WebReader Class
~~~~~~~~~~~~~~~~~~~~~~

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


"Structural" commands define the structure of the ``Chunks``.  The  structural commands 
are ``@d`` and ``@o``, as well as the ``@{``, ``@}``, ``@[``, ``@]`` brackets, 
and the ``@i`` command to include another file.


"Inline" commands are inline within a ``Chunk``: they define internal ``Commands``.  
Blocks of text are minor commands, as well as the ``@<``\ *name*\ ``@>`` references.
The ``@@`` escape is also
handled here so that all further processing is independent of any parsing.

"Content" commands generate woven content. These include 
the various cross-reference commands (``@f``, ``@m`` and ``@u``).  


There are two class-level ``OptionParser`` instances used by this class.

:output_option_parser:
    An ``OptionParser`` used to parse the ``@o`` command.
    
:definition_option_parser:
    An ``OptionParser`` used to parse the ``@d`` command.

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


..  _`116`:
..  rubric:: WebReader class - parses the input file, building the Web structure (116) =
..  parsed-literal::
    :class: code

    
    class WebReader:
        """Parse an input file, creating Chunks and Commands."""
    
        output\_option\_parser = OptionParser(
            OptionDef("-start", nargs=1, default=None),
            OptionDef("-end", nargs=1, default=""),
            OptionDef("argument", nargs='\*'),
        )
    
        definition\_option\_parser = OptionParser(
            OptionDef("-indent", nargs=0),
            OptionDef("-noindent", nargs=0),
            OptionDef("argument", nargs='\*'),
        )
        
        # Configuration
        command: str
        permitList: list[str]
        base\_path : Path
        
        # State of the reader
        \_source: TextIO
        filePath: Path
        theWeb: "Web"
        tokenizer: Tokenizer
        aChunk: Chunk
    
        def \_\_init\_\_(self, parent: Optional["WebReader"] = None) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
    
            # Configuration of this reader.
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
            
            |srarr|\ WebReader command literals (`131`_)
            
        def \_\_str\_\_(self) -> str:
            return self.\_\_class\_\_.\_\_name\_\_
            
        |srarr|\ WebReader location in the input stream (`128`_)
        
        |srarr|\ WebReader load the web (`130`_)
        
        |srarr|\ WebReader handle a command string (`117`_), |srarr|\ (`127`_)

..

    ..  class:: small

        |loz| *WebReader class - parses the input file, building the Web structure (116)*. Used by: Base Class Definitions (`1`_)


Command recognition is done via a **Chain of Command**-like design.
There are two conditions: the command string is recognized or it is not recognized.
If the command is recognized, ``handleCommand()`` either:

    -   (for "structural" commands) attaches the current ``Chunk`` (*self.aChunk*) to the 
        current ``Web`` (*self.aWeb*), **or**

    -   (for "inline" and "content" commands) create a ``Command``, attach it to the current 
        ``Chunk`` (*self.aChunk*)

and returns a true result.

If the command is not recognized, ``handleCommand()`` returns false.

A subclass can override ``handleCommand()`` to 

(1) call this superclass version;

(2) if the command is unknown to the superclass, 
    then the subclass can attempt to process it;

(3) if the command is unknown to both classes, 
    then return false.  Either a subclass will handle it, or the default activity taken
    by ``load()`` is to treat the command a text, but also issue a warning.


..  _`117`:
..  rubric:: WebReader handle a command string (117) =
..  parsed-literal::
    :class: code

    
    def handleCommand(self, token: str) -> bool:
        self.logger.debug("Reading %r", token)
        
        match token[:2]:
            case self.cmdo:
                |srarr|\ start an OutputChunk, adding it to the web (`118`_)
            case self.cmdd:
                |srarr|\ start a NamedChunk or NamedDocumentChunk, adding it to the web (`119`_)
            case self.cmdi:
                |srarr|\ include another file (`120`_)
            case self.cmdrcurl \| self.cmdrbrak:
                |srarr|\ finish a chunk, start a new Chunk adding it to the web (`121`_)
            case self.cmdpipe:
                |srarr|\ assign user identifiers to the current chunk (`122`_)
            case self.cmdf:
                self.aChunk.append(FileXrefCommand(self.tokenizer.lineNumber))
            case self.cmdm:
                self.aChunk.append(MacroXrefCommand(self.tokenizer.lineNumber))
            case self.cmdu:
                self.aChunk.append(UserIdXrefCommand(self.tokenizer.lineNumber))
            case self.cmdlangl:
                |srarr|\ add a reference command to the current chunk (`123`_)
            case self.cmdlexpr:
                |srarr|\ add an expression command to the current chunk (`125`_)
            case self.cmdcmd:
                |srarr|\ double at-sign replacement, append this character to previous TextCommand (`126`_)
            case self.cmdlcurl \| self.cmdlbrak:
                # These should have been consumed as part of @o and @d parsing
                self.logger.error("Extra %r (possibly missing chunk name) near %r", token, self.location())
                self.errors += 1
            case \_:
                return False  # did not recogize the command
        return True  # did recognize the command
    

..

    ..  class:: small

        |loz| *WebReader handle a command string (117)*. Used by: WebReader class... (`116`_)



An output chunk has the form ``@o`` *name* ``@{`` *content* ``@}``.
We use the first two tokens to name the ``OutputChunk``.  We simply expect
the ``@{`` separator.  We then attach all subsequent commands
to this chunk while waiting for the final ``@}`` token to end the chunk.

We'll use an ``OptionParser`` to locate the optional parameters.  This will then let
us build an appropriate instance of ``OutputChunk``.

With some small additional changes, we could use ``OutputChunk(**options)``.
    

..  _`118`:
..  rubric:: start an OutputChunk, adding it to the web (118) =
..  parsed-literal::
    :class: code

    
    args = next(self.tokenizer)
    self.expect((self.cmdlcurl,))
    options = self.output\_option\_parser.parse(args)
    self.aChunk = OutputChunk(
        name=' '.join(options['argument']),
        comment\_start=''.join(options.get('start', "# ")),
        comment\_end=''.join(options.get('end', "")),
    )
    self.aChunk.filePath = self.filePath 
    self.aChunk.webAdd(self.theWeb)
    # capture an OutputChunk up to @}

..

    ..  class:: small

        |loz| *start an OutputChunk, adding it to the web (118)*. Used by: WebReader handle a command... (`117`_)


A named chunk has the form ``@d`` *name* ``@{`` *content* ``@}`` for
code and ``@d`` *name* ``@[`` *content* ``@]`` for document source.
We use the first two tokens to name the ``NamedChunk`` or ``NamedDocumentChunk``.  
We expect either the ``@{`` or ``@[`` separator, and use the actual
token found to choose which subclass of ``Chunk`` to create.
We then attach all subsequent commands
to this chunk while waiting for the final ``@}`` or ``@]`` token to 
end the chunk.

We'll use an ``OptionParser`` to locate the optional parameter of ``-noindent``.

[Or possibly ``-indent`` *number*?]

Then we can use options to create an appropriate subclass of ``NamedChunk``.
        
If "-indent" is in options, this is the default. 
If both are in the options, we can provide a warning, I guess.

**TODO:** Add a warning for conflicting options.


..  _`119`:
..  rubric:: start a NamedChunk or NamedDocumentChunk, adding it to the web (119) =
..  parsed-literal::
    :class: code

    
    args = next(self.tokenizer)
    brack = self.expect((self.cmdlcurl,self.cmdlbrak))
    options = self.output\_option\_parser.parse(args)
    name = ' '.join(options['argument'])
    
    if brack == self.cmdlbrak:
        self.aChunk = NamedDocumentChunk(name)
    elif brack == self.cmdlcurl:
        if '-noindent' in options:
            self.aChunk = NamedChunk\_Noindent(name)
        else:
            self.aChunk = NamedChunk(name)
    elif brack == None:
        pass # Error noted by expect()
    else:
        raise Error("Design Error")
    
    self.aChunk.filePath = self.filePath 
    self.aChunk.webAdd(self.theWeb)
    # capture a NamedChunk up to @} or @]

..

    ..  class:: small

        |loz| *start a NamedChunk or NamedDocumentChunk, adding it to the web (119)*. Used by: WebReader handle a command... (`117`_)


An import command has the unusual form of ``@i`` *name*, with no trailing
separator.  When we encounter the ``@i`` token, the next token will start with the
file name, but may continue with an anonymous chunk.  We require that all ``@i`` commands
occur at the end of a line, and break on the ``'\n'`` which must occur after the file name.
This permits file names with embedded spaces. It also permits arguments and options,
if really necessary.

Once we have split the file name away from the rest of the following anonymous chunk,
we push the following token back into the token stream, so that it will be the 
first token examined at the top of the ``load()`` loop.

We create a child ``WebReader`` instance to process the included file.  The entire file 
is loaded into the current ``Web`` instance.  A new, empty ``Chunk`` is created at the end
of the file so that processing can resume with an anonymous ``Chunk``.

The reader has a ``permitList`` attribute.
This lists any commands where failure is permitted.  Currently, only the ``@i`` command
can be set to permit failure; this allows a ``.w`` to include
a file that does not yet exist.  
 
The primary use case for this feature is when weaving test output.
The first pass of **py-web-tool**  tangles the program source files; they are
then run to create test output; the second pass of **py-web-tool**  weaves this
test output into the final document via the ``@i`` command.


..  _`120`:
..  rubric:: include another file (120) =
..  parsed-literal::
    :class: code

    
    incPath = Path(next(self.tokenizer).strip())
    try:
        include = WebReader(parent=self)
        if not incPath.is\_absolute():
            incPath = self.base\_path / incPath
        self.logger.info("Including '%s'", incPath)
        include.load(self.theWeb, incPath)
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
    self.aChunk = Chunk()
    self.aChunk.webAdd(self.theWeb)

..

    ..  class:: small

        |loz| *include another file (120)*. Used by: WebReader handle a command... (`117`_)


When a ``@}`` or ``@]`` are found, this finishes a named chunk.  The next
text is therefore part of an anonymous chunk.


Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@{`` or ``@[``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if a trailing bracket was necessary.
For the base ``Chunk`` class, this would be false, but for all other subclasses of
``Chunk``, this would be true.



..  _`121`:
..  rubric:: finish a chunk, start a new Chunk adding it to the web (121) =
..  parsed-literal::
    :class: code

    
    self.aChunk = Chunk()
    self.aChunk.webAdd(self.theWeb)

..

    ..  class:: small

        |loz| *finish a chunk, start a new Chunk adding it to the web (121)*. Used by: WebReader handle a command... (`117`_)


The following sequence of ``elif`` statements identifies
the minor commands that add ``Command`` instances to the current open ``Chunk``. 

User identifiers occur after a ``@|`` in a ``NamedChunk``.

Note that no check is made to assure that the previous ``Chunk`` was indeed a named
chunk or output chunk started with ``@{``.  
To do this, an attribute would be
needed for each ``Chunk`` subclass that indicated if user identifiers are permitted.
For the base ``Chunk`` class, this would be false, but for the ``NamedChunk`` class and
``OutputChunk`` class, this would be true.

User identifiers are name references at the end of a NamedChunk
These are accumulated and expanded by ``@u`` reference


..  _`122`:
..  rubric:: assign user identifiers to the current chunk (122) =
..  parsed-literal::
    :class: code

    
    try:
        self.aChunk.setUserIDRefs(next(self.tokenizer).strip())
    except AttributeError:
        # Out of place @\| user identifier command
        self.logger.error("Unexpected references near %r: %r", self.location(), token)
        self.errors += 1

..

    ..  class:: small

        |loz| *assign user identifiers to the current chunk (122)*. Used by: WebReader handle a command... (`117`_)


A reference command has the form ``@<``\ *name*\ ``@>``.  We accept three
tokens from the input, the middle token is the referenced name.



..  _`123`:
..  rubric:: add a reference command to the current chunk (123) =
..  parsed-literal::
    :class: code

    
    # get the name, introduce into the named Chunk dictionary
    expand = next(self.tokenizer).strip()
    closing = self.expect((self.cmdrangl,))
    self.theWeb.addDefName(expand)
    self.aChunk.append(ReferenceCommand(expand, self.tokenizer.lineNumber))
    self.aChunk.appendText("", self.tokenizer.lineNumber) # to collect following text
    self.logger.debug("Reading %r %r", expand, closing)

..

    ..  class:: small

        |loz| *add a reference command to the current chunk (123)*. Used by: WebReader handle a command... (`117`_)


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

We use the **Immediate Execution** semantics.

Note that we've removed the blanket ``os``.  We provide ``os.path`` library.
An ``os.getcwd()`` could be changed to ``os.path.realpath('.')``.


..  _`124`:
..  rubric:: Imports (124) +=
..  parsed-literal::
    :class: code

    
    import builtins
    import sys
    import platform
    

..

    ..  class:: small

        |loz| *Imports (124)*. Used by: pyweb.py (`155`_)



..  _`125`:
..  rubric:: add an expression command to the current chunk (125) =
..  parsed-literal::
    :class: code

    
    # get the Python expression, create the expression result
    expression = next(self.tokenizer)
    self.expect((self.cmdrexpr,))
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
            theFile=self.theWeb.web\_path,
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
    self.aChunk.appendText(result, self.tokenizer.lineNumber)

..

    ..  class:: small

        |loz| *add an expression command to the current chunk (125)*. Used by: WebReader handle a command... (`117`_)


A double command sequence (``'@@'``, when the command is an ``'@'``) has the
usual meaning of ``'@'`` in the input stream.  We do this via 
the ``appendText()`` method of the current ``Chunk``.  This will append the 
character on the end of the most recent ``TextCommand``; if this fails, it will
create a new, empty ``TextCommand``.

We replace with '@' here and now! This is put this at the end of the previous chunk.
And we make sure the next chunk will be appended to this so that it's 
largely seamless.


..  _`126`:
..  rubric:: double at-sign replacement, append this character to previous TextCommand (126) =
..  parsed-literal::
    :class: code

    
    self.aChunk.appendText(self.command, self.tokenizer.lineNumber)

..

    ..  class:: small

        |loz| *double at-sign replacement, append this character to previous TextCommand (126)*. Used by: WebReader handle a command... (`117`_)


The ``expect()`` method examines the 
next token to see if it is the expected item. ``'\n'`` are absorbed.  
If this is not found, a standard type of error message is raised. 
This is used by ``handleCommand()``.


..  _`127`:
..  rubric:: WebReader handle a command string (127) +=
..  parsed-literal::
    :class: code

    
    def expect(self, tokens: Iterable[str]) -> str \| None:
        try:
            t = next(self.tokenizer)
            while t == '\\n':
                t = next(self.tokenizer)
        except StopIteration:
            self.logger.error("At %r: end of input, %r not found", self.location(), tokens)
            self.errors += 1
            return None
        if t not in tokens:
            self.logger.error("At %r: expected %r, found %r", self.location(), tokens, t)
            self.errors += 1
            return None
        return t
    

..

    ..  class:: small

        |loz| *WebReader handle a command string (127)*. Used by: WebReader class... (`116`_)


The ``location()`` provides the file name and line number.
This allows error messages as well as tangled or woven output 
to correctly reference the original input files.


..  _`128`:
..  rubric:: WebReader location in the input stream (128) =
..  parsed-literal::
    :class: code

    
    def location(self) -> tuple[str, int]:
        return (str(self.filePath), self.tokenizer.lineNumber+1)
    

..

    ..  class:: small

        |loz| *WebReader location in the input stream (128)*. Used by: WebReader class... (`116`_)


The ``load()`` method reads the entire input file as a sequence
of tokens, split up by the ``Tokenizer``.  Each token that appears
to be a command is passed to the ``handleCommand()`` method.  If
the ``handleCommand()`` method returns a True result, the command was recognized
and placed in the ``Web``.  If ``handleCommand()`` returns a False result, the command
was unknown, and we write a warning but treat it as text.

The ``load()`` method is used recursively to handle the ``@i`` command. The issue
is that it's always loading a single top-level web. 


..  _`129`:
..  rubric:: Imports (129) +=
..  parsed-literal::
    :class: code

    from typing import TextIO

..

    ..  class:: small

        |loz| *Imports (129)*. Used by: pyweb.py (`155`_)



..  _`130`:
..  rubric:: WebReader load the web (130) =
..  parsed-literal::
    :class: code

    
    def load(self, web: "Web", filepath: Path, source: TextIO \| None = None) -> "WebReader":
        self.theWeb = web
        self.filePath = filepath
        self.base\_path = self.filePath.parent
    
        # Only set the a web's filename once using the first file.
        # \*\*TODO:\*\* this should be a setter property of the web.
        if self.theWeb.web\_path is None:
            self.theWeb.web\_path = self.filePath
        
        if source:
            self.\_source = source
            self.parse\_source()
        else:
            with self.filePath.open() as self.\_source:
                self.parse\_source()
        return self
    
    def parse\_source(self) -> None:
        self.tokenizer = Tokenizer(self.\_source, self.command)
        self.totalFiles += 1
    
        self.aChunk = Chunk() # Initial anonymous chunk of text.
        self.aChunk.webAdd(self.theWeb)
    
        for token in self.tokenizer:
            if len(token) >= 2 and token.startswith(self.command):
                if self.handleCommand(token):
                    continue
                else:
                    self.logger.error('Unknown @-command in input: %r', token)
                    self.aChunk.appendText(token, self.tokenizer.lineNumber)
            elif token:
                # Accumulate a non-empty block of text in the current chunk.
                self.aChunk.appendText(token, self.tokenizer.lineNumber)
            else:
                # Whitespace
                pass
    

..

    ..  class:: small

        |loz| *WebReader load the web (130)*. Used by: WebReader class... (`116`_)


The command character can be changed to permit
some flexibility when working with languages that make extensive
use of the ``@`` symbol, i.e., PERL.
The initialization of the ``WebReader`` is based on the selected 
command character.



..  _`131`:
..  rubric:: WebReader command literals (131) =
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

        |loz| *WebReader command literals (131)*. Used by: WebReader class... (`116`_)



The Tokenizer Class
~~~~~~~~~~~~~~~~~~~~

The ``WebReader`` requires a tokenizer. The tokenizer breaks the input text
into a stream of tokens. There are two broad classes of tokens:

-   ``@.`` command tokens, including the structural, inline, and content
    commands.

-   ``\n``. Inside text, these matter. Within structure command tokens, these don't matter.
    Except after the filename after an ``@i`` command, where it ends the command. 

-   The remaining text.

The tokenizer works by reading the entire file and splitting on ``@.`` patterns.
The ``split()`` method of the Python ``re`` module will separate the input
and preserve the actual character sequence on which the input was split.
This breaks the input into blocks of text separated by the ``@.`` characters.

This tokenizer splits the input using ``(r'@.|\n')``. The idea is that 
we locate commands, newlines and the interstitial text as three classes of tokens.  
We can then assemble each ``Command`` instance from a short sequence of tokens.
The core ``TextCommand`` and ``CodeCommand`` will be a line of text ending with
the ``\n``. 

The re.split() method will include an empty string when the split pattern occurs
at the very beginning or very end of the input. For example:

..  parsed-literal::

    >>> pat.split( "@{hi mom@}")
    ['', '@{', 'hi mom', '@}', '']
    
We can safely filter these via a generator expression.

The tokenizer counts newline characters for us, so that error messages can include
a line number. Also, we can tangle comments into the file that include line numbers.

Since the tokenizer is a proper iterator, we can use ``tokens = iter(Tokenizer(source))``
and ``next(tokens)`` to step through the sequence of tokens until we raise a ``StopIteration``
exception.


..  _`132`:
..  rubric:: Imports (132) +=
..  parsed-literal::
    :class: code

    
    import re
    from collections.abc import Iterator, Iterable
    

..

    ..  class:: small

        |loz| *Imports (132)*. Used by: pyweb.py (`155`_)



..  _`133`:
..  rubric:: Tokenizer class - breaks input into tokens (133) =
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

        |loz| *Tokenizer class - breaks input into tokens (133)*. Used by: Base Class Definitions (`1`_)


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


..  _`134`:
..  rubric:: Imports (134) +=
..  parsed-literal::
    :class: code

    
    import shlex
    

..

    ..  class:: small

        |loz| *Imports (134)*. Used by: pyweb.py (`155`_)


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


..  _`135`:
..  rubric:: Option Parser class - locates optional values on commands (135) =
..  parsed-literal::
    :class: code

    
    class ParseError(Exception): pass

..

    ..  class:: small

        |loz| *Option Parser class - locates optional values on commands (135)*. Used by: Base Class Definitions (`1`_)



..  _`136`:
..  rubric:: Option Parser class - locates optional values on commands (136) +=
..  parsed-literal::
    :class: code

    
    class OptionDef:
        def \_\_init\_\_(self, name: str, \*\*kw: Any) -> None:
            self.name = name
            self.\_\_dict\_\_.update(kw)

..

    ..  class:: small

        |loz| *Option Parser class - locates optional values on commands (136)*. Used by: Base Class Definitions (`1`_)


The parser breaks the text into words using ``shelex`` rules. 
It then steps through the words, accumulating the options and the
final argument value.


..  _`137`:
..  rubric:: Option Parser class - locates optional values on commands (137) +=
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

        |loz| *Option Parser class - locates optional values on commands (137)*. Used by: Base Class Definitions (`1`_)


In principle, we step through the trailers based on nargs counts.
Since we only ever have the one trailer, we skate by.

The loop becomes a bit more complex to capture the positional arguments, in order.
First, we have to use an ``OrderedDict`` instead of a ``dict``.

Then we'd have a loop something like this. (Untested, incomplete, just hand-waving.)

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
    pyweb.tangle("source.w")
    with log.open("w") as target:
        with contextlib.redirect_stdout(target):
            runpy.run_path('source.py')
    pyweb.weave("source.w")


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


..  _`138`:
..  rubric:: Action class hierarchy - used to describe actions of the application (138) =
..  parsed-literal::
    :class: code

    
    |srarr|\ Action superclass has common features of all actions (`139`_)
    |srarr|\ ActionSequence subclass that holds a sequence of other actions (`142`_)
    |srarr|\ WeaveAction subclass initiates the weave action (`146`_)
    |srarr|\ TangleAction subclass initiates the tangle action (`149`_)
    |srarr|\ LoadAction subclass loads the document web (`152`_)

..

    ..  class:: small

        |loz| *Action class hierarchy - used to describe actions of the application (138)*. Used by: Base Class Definitions (`1`_)


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

    anOp = SomeAction(*parameters*)
    anOp.options = *argparse.Namespace*
    anOp.web = *Current web*
    anOp()


The ``Action`` is the superclass for all actions.
An ``Action`` has a number of common attributes.

:name:
    A name for this action.
    
:options:
    The ``argparse.Namespace`` object.
    
:web:
    The current web that's being processed.
    
!start:
    The time at which the action started.




..  _`139`:
..  rubric:: Action superclass has common features of all actions (139) =
..  parsed-literal::
    :class: code

    
    class Action:
        """An action performed by pyWeb."""
        options : argparse.Namespace
        web : "Web"
        def \_\_init\_\_(self, name: str) -> None:
            self.name = name
            self.start: float \| None = None
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            
        def \_\_str\_\_(self) -> str:
            return f"{self.name!s} [{self.web!s}]"
            
        |srarr|\ Action call method actually does the real work (`140`_)
        
        |srarr|\ Action final summary of what was done (`141`_)
    

..

    ..  class:: small

        |loz| *Action superclass has common features of all actions (139)*. Used by: Action class hierarchy... (`138`_)


The ``__call__()`` method does the real work of the action.
For the superclass, it merely logs a message.  This is overridden 
by a subclass.


..  _`140`:
..  rubric:: Action call method actually does the real work (140) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self) -> None:
        self.logger.info("Starting %s", self.name)
        self.start = time.process\_time()
    

..

    ..  class:: small

        |loz| *Action call method actually does the real work (140)*. Used by: Action superclass... (`139`_)


The ``summary()`` method returns some basic processing
statistics for this action.


..  _`141`:
..  rubric:: Action final summary of what was done (141) =
..  parsed-literal::
    :class: code

    
    def duration(self) -> float:
        """Return duration of the action."""
        return (self.start and time.process\_time()-self.start) or 0
        
    def summary(self) -> str:
        return f"{self.name!s} in {self.duration():0.3f} sec."
    

..

    ..  class:: small

        |loz| *Action final summary of what was done (141)*. Used by: Action superclass... (`139`_)


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



..  _`142`:
..  rubric:: ActionSequence subclass that holds a sequence of other actions (142) =
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
            
        |srarr|\ ActionSequence call method delegates the sequence of ations (`143`_)
        
        |srarr|\ ActionSequence append adds a new action to the sequence (`144`_)
        
        |srarr|\ ActionSequence summary summarizes each step (`145`_)
    

..

    ..  class:: small

        |loz| *ActionSequence subclass that holds a sequence of other actions (142)*. Used by: Action class hierarchy... (`138`_)


Since the macro ``__call__()`` method delegates to other Actions,
it is possible to short-cut argument processing by using the Python
``*args`` construct to accept all arguments and pass them to each
sub-action.


..  _`143`:
..  rubric:: ActionSequence call method delegates the sequence of ations (143) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self) -> None:
        super().\_\_call\_\_()
        for o in self.opSequence:
            o.web = self.web
            o.options = self.options
            o()
    

..

    ..  class:: small

        |loz| *ActionSequence call method delegates the sequence of ations (143)*. Used by: ActionSequence subclass... (`142`_)


Since this class is essentially a wrapper around the built-in sequence type, 
we delegate sequence related actions directly to the underlying sequence.


..  _`144`:
..  rubric:: ActionSequence append adds a new action to the sequence (144) =
..  parsed-literal::
    :class: code

    
    def append(self, anAction: Action) -> None:
        self.opSequence.append(anAction)
    

..

    ..  class:: small

        |loz| *ActionSequence append adds a new action to the sequence (144)*. Used by: ActionSequence subclass... (`142`_)


The ``summary()`` method returns some basic processing
statistics for each step of this action.


..  _`145`:
..  rubric:: ActionSequence summary summarizes each step (145) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        return ", ".join([o.summary() for o in self.opSequence])
    

..

    ..  class:: small

        |loz| *ActionSequence summary summarizes each step (145)*. Used by: ActionSequence subclass... (`142`_)


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


..  _`146`:
..  rubric:: WeaveAction subclass initiates the weave action (146) =
..  parsed-literal::
    :class: code

    
    class WeaveAction(Action):
        """Weave the final document."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Weave")
            
        def \_\_str\_\_(self) -> str:
            return f"{self.name!s} [{self.web!s}, {self.options.theWeaver!s}]"
    
        |srarr|\ WeaveAction call method to pick the language (`147`_)
        
        |srarr|\ WeaveAction summary of language choice (`148`_)
    

..

    ..  class:: small

        |loz| *WeaveAction subclass initiates the weave action (146)*. Used by: Action class hierarchy... (`138`_)


The language is picked just prior to weaving.  It is either (1) the language
specified on the command line, or, (2) if no language was specified, a language
is selected based on the first few characters of the input.

Weaving can only raise an exception when there is a reference to a chunk that
is never defined.


..  _`147`:
..  rubric:: WeaveAction call method to pick the language (147) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self) -> None:
        super().\_\_call\_\_()
        if not self.options.theWeaver: 
            # Examine first few chars of first chunk of web to determine language
            self.options.theWeaver = self.web.language() 
            self.logger.info("Using %s", self.options.theWeaver.\_\_class\_\_.\_\_name\_\_)
        self.options.theWeaver.reference\_style = self.options.reference\_style
        self.options.theWeaver.output = self.options.output
        try:
            self.web.weave(self.options.theWeaver)
            self.logger.info("Finished Normally")
        except Error as e:
            self.logger.error("Problems weaving document from %r (weave file is faulty).", self.web.web\_path)
            #raise
    

..

    ..  class:: small

        |loz| *WeaveAction call method to pick the language (147)*. Used by: WeaveAction subclass... (`146`_)


The ``summary()`` method returns some basic processing
statistics for the weave action.



..  _`148`:
..  rubric:: WeaveAction summary of language choice (148) =
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

        |loz| *WeaveAction summary of language choice (148)*. Used by: WeaveAction subclass... (`146`_)


TangleAction Class
~~~~~~~~~~~~~~~~~~~

The ``TangleAction`` defines the action of tangling.  This operation
logs a message, and invokes the ``weave()`` method of the ``Web`` instance.
This method also includes the basic decision on which weaver to use.  If a ``Weaver`` was
specified on the command line, this instance is used.  Otherwise, the first few characters
are examined and a weaver is selected.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``theTangler``, with the ``Tangler`` instance to be used.


..  _`149`:
..  rubric:: TangleAction subclass initiates the tangle action (149) =
..  parsed-literal::
    :class: code

    
    class TangleAction(Action):
        """Tangle source files."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Tangle")
            
        |srarr|\ TangleAction call method does tangling of the output files (`150`_)
        
        |srarr|\ TangleAction summary method provides total lines tangled (`151`_)
    

..

    ..  class:: small

        |loz| *TangleAction subclass initiates the tangle action (149)*. Used by: Action class hierarchy... (`138`_)


Tangling can only raise an exception when a cross reference request (``@f``, ``@m`` or ``@u``)
occurs in a program code chunk.  Program code chunks are defined 
with any of ``@d`` or ``@o``  and use ``@{`` ``@}`` brackets.



..  _`150`:
..  rubric:: TangleAction call method does tangling of the output files (150) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self) -> None:
        super().\_\_call\_\_()
        self.options.theTangler.include\_line\_numbers = self.options.tangler\_line\_numbers
        self.options.theTangler.output = self.options.output
        try:
            self.web.tangle(self.options.theTangler)
        except Error as e:
            self.logger.error("Problems tangling outputs from %r (tangle files are faulty).", self.web.web\_path)
            #raise
    

..

    ..  class:: small

        |loz| *TangleAction call method does tangling of the output files (150)*. Used by: TangleAction subclass... (`149`_)


The ``summary()`` method returns some basic processing
statistics for the tangle action.


..  _`151`:
..  rubric:: TangleAction summary method provides total lines tangled (151) =
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

        |loz| *TangleAction summary method provides total lines tangled (151)*. Used by: TangleAction subclass... (`149`_)



LoadAction Class
~~~~~~~~~~~~~~~~~~

The ``LoadAction`` defines the action of loading the web structure.  This action
uses the application's ``webReader`` to actually do the load.

An instance is created during parsing of the input parameters.  An instance of
this class is part of any of the weave, tangle and "do everything" action.

This class overrides the ``__call__()`` method of the superclass.

The options **must** include ``webReader``, with the ``WebReader`` instance to be used.



..  _`152`:
..  rubric:: LoadAction subclass loads the document web (152) =
..  parsed-literal::
    :class: code

    
    class LoadAction(Action):
        """Load the source web."""
        def \_\_init\_\_(self) -> None:
            super().\_\_init\_\_("Load")
        def \_\_str\_\_(self) -> str:
            return f"Load [{self.webReader!s}, {self.web!s}]"
            
        |srarr|\ LoadAction call method loads the input files (`153`_)
        
        |srarr|\ LoadAction summary provides lines read (`154`_)
    

..

    ..  class:: small

        |loz| *LoadAction subclass loads the document web (152)*. Used by: Action class hierarchy... (`138`_)


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


..  _`153`:
..  rubric:: LoadAction call method loads the input files (153) =
..  parsed-literal::
    :class: code

    
    def \_\_call\_\_(self) -> None:
        super().\_\_call\_\_()
        self.webReader = self.options.webReader
        self.webReader.command = self.options.command
        self.webReader.permitList = self.options.permitList 
        self.web.web\_path = self.options.source\_path
        error = f"Problems with source file {self.options.source\_path!r}, no output produced."
        try:
            self.webReader.load(self.web, self.options.source\_path)
            if self.webReader.errors != 0:
                self.logger.error(error)
                raise Error("Syntax Errors in the Web")
            self.web.createUsedBy()
            if self.webReader.errors != 0:
                self.logger.error(error)
                raise Error("Internal Reference Errors in the Web")        
        except Error as e:
            self.logger.error(error)
            raise # Older design.
        except IOError as e:
            self.logger.error(error)
            raise
    

..

    ..  class:: small

        |loz| *LoadAction call method loads the input files (153)*. Used by: LoadAction subclass... (`152`_)


The ``summary()`` method returns some basic processing
statistics for the load action.


..  _`154`:
..  rubric:: LoadAction summary provides lines read (154) =
..  parsed-literal::
    :class: code

    
    def summary(self) -> str:
        return (
            f"{self.name!s} {self.webReader.totalLines:d} lines from {self.webReader.totalFiles:d} files in {self.duration():0.3f} sec."
        )
    

..

    ..  class:: small

        |loz| *LoadAction summary provides lines read (154)*. Used by: LoadAction subclass... (`152`_)



**pyWeb** Module File
------------------------

The **pyWeb** application file is shown below:


..  _`155`:
..  rubric:: pyweb.py (155) =
..  parsed-literal::
    :class: code

    |srarr|\ Overheads (`157`_), |srarr|\ (`158`_), |srarr|\ (`159`_)
    |srarr|\ Imports (`3`_), |srarr|\ (`12`_), |srarr|\ (`48`_), |srarr|\ (`58`_), |srarr|\ (`98`_), |srarr|\ (`124`_), |srarr|\ (`129`_), |srarr|\ (`132`_), |srarr|\ (`134`_), |srarr|\ (`156`_), |srarr|\ (`160`_), |srarr|\ (`166`_)
    |srarr|\ Base Class Definitions (`1`_)
    |srarr|\ Application Class (`161`_), |srarr|\ (`162`_)
    |srarr|\ Logging Setup (`167`_), |srarr|\ (`168`_)
    |srarr|\ Interface Functions (`169`_)

..

    ..  class:: small

        |loz| *pyweb.py (155)*.


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




..  _`156`:
..  rubric:: Imports (156) +=
..  parsed-literal::
    :class: code

    
    import os
    import time
    import datetime
    import types
    

..

    ..  class:: small

        |loz| *Imports (156)*. Used by: pyweb.py (`155`_)


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



..  _`157`:
..  rubric:: Overheads (157) =
..  parsed-literal::
    :class: code

    #!/usr/bin/env python

..

    ..  class:: small

        |loz| *Overheads (157)*. Used by: pyweb.py (`155`_)


A Python ``__doc__`` string provides a standard vehicle for documenting
the module or the application program.  The usual style is to provide
a one-sentence summary on the first line.  This is followed by more 
detailed usage information.



..  _`158`:
..  rubric:: Overheads (158) +=
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

        |loz| *Overheads (158)*. Used by: pyweb.py (`155`_)


The keyword cruft is a standard way of placing version control information into
a Python module so it is preserved.  See PEP (Python Enhancement Proposal) #8 for information
on recommended styles.


We also sneak in a "DO NOT EDIT" warning that belongs in all generated application 
source files.


..  _`159`:
..  rubric:: Overheads (159) +=
..  parsed-literal::
    :class: code

    \_\_version\_\_ = """3.1"""
    
    ### DO NOT EDIT THIS FILE!
    ### It was created by /Users/slott/Documents/Projects/py-web-tool/bootstrap/pyweb.py, \_\_version\_\_='3.0'.
    ### From source pyweb.w modified Mon Jun 13 08:52:05 2022.
    ### In working directory '/Users/slott/Documents/Projects/py-web-tool/src'.

..

    ..  class:: small

        |loz| *Overheads (159)*. Used by: pyweb.py (`155`_)



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



..  _`160`:
..  rubric:: Imports (160) +=
..  parsed-literal::
    :class: code

    import argparse
    

..

    ..  class:: small

        |loz| *Imports (160)*. Used by: pyweb.py (`155`_)



..  _`161`:
..  rubric:: Application Class (161) =
..  parsed-literal::
    :class: code

    
    class Application:
        def \_\_init\_\_(self) -> None:
            self.logger = logging.getLogger(self.\_\_class\_\_.\_\_qualname\_\_)
            |srarr|\ Application default options (`163`_)
            
        |srarr|\ Application parse command line (`164`_)
        |srarr|\ Application class process all files (`165`_)
    

..

    ..  class:: small

        |loz| *Application Class (161)*. Used by: pyweb.py (`155`_)


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

Other instance variables.
   
Here's the global list of available weavers. Essentially this is the subclass
list of ``Weaver``.  Essentially, the list is this:

..  parsed-literal::

    weavers = dict( 
        (x.__class__.__name__.lower(), x) 
        for x in Weaver.__subclasses__()
    )

Rather than automate this, and potentially expose elements of the class hierarchy
that aren't really meant to be used, we provide a manually-developed list. 


..  _`162`:
..  rubric:: Application Class (162) +=
..  parsed-literal::
    :class: code

    
    # Global list of available weaver classes.
    weavers = {
        'html':  HTML,
        'htmlshort': HTMLShort,
        'latex': LaTeX,
        'rst': RST, 
    }

..

    ..  class:: small

        |loz| *Application Class (162)*. Used by: pyweb.py (`155`_)


The defaults used for application configuration. The ``expand()`` method expands
on these simple text values to create more useful objects.


..  _`163`:
..  rubric:: Application default options (163) =
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
    # self.expand(self.defaults)
    
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

        |loz| *Application default options (163)*. Used by: Application Class... (`161`_)


The algorithm for parsing the command line parameters uses the built in
``argparse`` module.  We have to build a parser, define the options,
and the parse the command-line arguments, updating the default namespace.

We further expand on the arguments. This transforms simple strings into object
instances.



..  _`164`:
..  rubric:: Application parse command line (164) =
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
    
        # Weaver
        try:
            weaver\_class = weavers[config.weaver.lower()]
        except KeyError:
            module\_name, \_, class\_name = config.weaver.partition('.')
            weaver\_module = \_\_import\_\_(module\_name)
            weaver\_class = weaver\_module.\_\_dict\_\_[class\_name]
            if not issubclass(weaver\_class, Weaver):
                raise TypeError(f"{weaver\_class!r} not a subclass of Weaver")
        config.theWeaver = weaver\_class()
        
        # Tangler
        config.theTangler = TanglerMake()
        
        if config.permit:
            # save permitted errors, usual case is \`\`-pi\`\` to permit \`\`@i\`\` include errors
            config.permitList = [f'{config.command!s}{c!s}' for c in config.permit]
        else:
            config.permitList = []
    
        config.webReader = WebReader()
    
        return config
    

..

    ..  class:: small

        |loz| *Application parse command line (164)*. Used by: Application Class... (`161`_)


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


..  _`165`:
..  rubric:: Application class process all files (165) =
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
    
        self.logger.info("Weaver %s", config.theWeaver)
    
        for f in config.files:
            w = Web() # New, empty web to load and process.
            self.logger.info("%s %r", self.theAction.name, f)
            config.source\_path = f
            self.theAction.web = w
            self.theAction.options = config
            self.theAction()
            self.logger.info(self.theAction.summary())
    

..

    ..  class:: small

        |loz| *Application class process all files (165)*. Used by: Application Class... (`161`_)


Logging Setup
--------------

We'll create a logging context manager. This allows us to wrap the ``main()`` 
function in an explicit ``with`` statement that assures that logging is
configured and cleaned up politely.


..  _`166`:
..  rubric:: Imports (166) +=
..  parsed-literal::
    :class: code

    
    import logging
    import logging.config
    

..

    ..  class:: small

        |loz| *Imports (166)*. Used by: pyweb.py (`155`_)


This has two configuration approaches. If a positional argument is given,
that dictionary is used for ``logging.config.dictConfig``. Otherwise,
keyword arguments are provided to ``logging.basicConfig``.

A subclass might properly load a dictionary 
encoded in YAML and use that with ``logging.config.dictConfig``.


..  _`167`:
..  rubric:: Logging Setup (167) =
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

        |loz| *Logging Setup (167)*. Used by: pyweb.py (`155`_)


Here's a sample logging setup. This creates a simple console handler and 
a formatter that matches the ``basicConfig`` formatter.

It defines the root logger plus two overrides for class loggers that might be
used to gather additional information.


..  _`168`:
..  rubric:: Logging Setup (168) +=
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
        
        #For specific debugging support...
        'loggers': {
        #    'RST': {'level': logging.DEBUG},
        #    'TanglerMake': {'level': logging.DEBUG},
        #    'WebReader': {'level': logging.DEBUG},
        },
    }

..

    ..  class:: small

        |loz| *Logging Setup (168)*. Used by: pyweb.py (`155`_)


This seems a bit verbose; a separate configuration file might be better.

Also, we might want a decorator to define loggers consistently for each class.


The Main Function
------------------

The top-level interface is the ``main()`` function.
This function creates an ``Application`` instance.

The ``Application`` object parses the command-line arguments.
Then the ``Application`` object does the requested processing.
This two-step process allows for some dependency injection to customize argument processing.

We might also want to parse a logging configuration file, as well
as a weaver template configuration file.


..  _`169`:
..  rubric:: Interface Functions (169) =
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

        |loz| *Interface Functions (169)*. Used by: pyweb.py (`155`_)


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


..  _`170`:
..  rubric:: tangle.py (170) =
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
        
            w = pyweb.Web() 
            
            for action in pyweb.LoadAction(), pyweb.TangleAction():
                action.web = w
                action.options = options
                action()
                logger.info(action.summary())
    
    if \_\_name\_\_ == "\_\_main\_\_":
        main(Path("examples/test\_rst.w"))

..

    ..  class:: small

        |loz| *tangle.py (170)*.


``weave.py`` Script
---------------------

This script shows a simple version of Weaving.  This shows how
to define a customized set of templates for a different markup language.


A customized weaver generally has three parts.


..  _`171`:
..  rubric:: weave.py (171) =
..  parsed-literal::
    :class: code

    |srarr|\ weave.py overheads for correct operation of a script (`172`_)
    
    |srarr|\ weave.py custom weaver definition to customize the Weaver being used (`173`_)
    
    |srarr|\ weaver.py processing: load and weave the document (`174`_)

..

    ..  class:: small

        |loz| *weave.py (171)*.



..  _`172`:
..  rubric:: weave.py overheads for correct operation of a script (172) =
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

        |loz| *weave.py overheads for correct operation of a script (172)*. Used by: weave.py (`171`_)



..  _`173`:
..  rubric:: weave.py custom weaver definition to customize the Weaver being used (173) =
..  parsed-literal::
    :class: code

    
    class MyHTML(pyweb.HTML):
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

        |loz| *weave.py custom weaver definition to customize the Weaver being used (173)*. Used by: weave.py (`171`_)



..  _`174`:
..  rubric:: weaver.py processing: load and weave the document (174) =
..  parsed-literal::
    :class: code

    
    def main(source: Path) -> None:
        with pyweb.Logger(pyweb.log\_config):
            logger = logging.getLogger(\_\_file\_\_)
        
            options = argparse.Namespace(
                source\_path=source,
                output=source.parent,
                verbosity=logging.INFO,
                command='@',
                permitList=[],
                tangler\_line\_numbers=False,
                reference\_style=pyweb.SimpleReference(),
                theWeaver=MyHTML(),
                webReader=pyweb.WebReader(),
            )
        
            w = pyweb.Web() 
        
            for action in pyweb.LoadAction(), pyweb.WeaveAction():
                action.web = w
                action.options = options
                action()
                logger.info(action.summary())
    
    if \_\_name\_\_ == "\_\_main\_\_":
        main(Path("examples/test\_rst.w"))

..

    ..  class:: small

        |loz| *weaver.py processing: load and weave the document (174)*. Used by: weave.py (`171`_)



..    py-web-tool/src/todo.w 

Python 3.10 Migration
=====================

1. [x] Add type hints.

#. [x] Replace all ``.format()`` with f-strings.

#. [x] Replace filename strings (and ``os.path``) with ``pathlib.Path``.

#. [x] Add ``abc`` to formalize Abstract Base Classes.

#. [x] Use ``match`` statements for some of the ``elif`` blocks.

#. [x] Introduce pytest instead of building a test runner from ``runner.w``.

#. [x] Add ``-o dir`` option to write output to a directory of choice. Requires ``pathlib``.

#. [x] Finish ``pyproject.toml``. Requires ``-o dir`` option.

#. [x] Add ``bootstrap`` directory.

#. [x] Test cases for ``weave.py`` and ``tangle.py``
 
#. [x] Replace various mock classes with ``unittest.mock.Mock`` objects and appropriate testing.

#. [x] Separate ``tests``, ``examples``, and ``src`` from each other. 

#. [ ] Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
       Rename the project from ``py-web-tool`` to ``py-lpweb``.

 
To Do
=======
    
1.  Add a JSON-based (or TOML) configuration file for templates.

    -   See the ``weave.py`` example. 
        Defining templates in the source removes any need for a command-line option. A silly optimization.
        Setting the "command character" to something other than ``@`` can be done in the configuration, too.

    -   An alternative is to get markup templates from some kind of "header" section in the ``.w`` file.  
        To support reuse over multiple projects, a header could be included with ``@i``.
        The downside is that we have a lot of *variable = value* syntax that makes it
        more like a properties file than a ``.w`` syntax file. It seems needless to invent 
        a lot of new syntax just for configuration.
        
    -   See below on switching to Jinja2. In this case, the templates can be provided via
        a Jinja configuration (there are many choices.) By stepping away from the ``string.Template``,
        we can incorporate list-processing ``{%for%}...{%endfor%}`` construct that 
        pushes some processing into the template.

#.  Separate TOML-based logging configuration file would be helpful. 
    Should be separate from template configuration.

#.  Rethink the weaver header. Are |loz| and |srarr| REALLY necessary? 
    Can we use ◊ and → now that Unicode is more universal?
    And why ``'\N{LOZENGE}'``? There's a nice ``'\N{END OF PROOF}'`` symbol we could use.

    -   Currently, we rely on a list of things which **must** be present
        in the document to be woven correctly. Consider a standard RST starter template with the definitions
        provided. 

    -   Add a ``@h`` "header goes here" command to allow weaving any **pyWeb** required addons to 
        a LaTeX header, HTML header or RST header.
        These are extra ``..  include::``, ``\\usepackage{fancyvrb}`` or maybe an HTML CSS reference
        that come from **pyWeb** and need to be folded into otherwise boilerplate documents.
        
    
    -   In the long run, even tangling should permit templates with "assumed" or "implied" code in it.
        The use case is the book chapters with test cases that are **not** woven into the text.
    
    -   Or. Tangle-only chunks that are NOT woven into the final document. 
    
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

Other Thoughts
----------------

There are two possible projects that might prove useful.

-   Jinja2 for better templates.

-   ``pyYAML`` or ``toml`` for slightly cleaner encoding of logging configuration
    or other configuration.

There are advantages and disadvantages to depending on other projects. 
The disadvantage is a (very low, but still present) barrier to adoption. 
The advantage of adding these two projects might be some simplification.


..    py-web-tool/src/done.w 

Change Log
===========

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


:pyweb.py:
    |srarr|\ (`155`_)
:tangle.py:
    |srarr|\ (`170`_)
:weave.py:
    |srarr|\ (`171`_)



Macros
------


:Action call method actually does the real work:
    |srarr|\ (`140`_)
:Action class hierarchy - used to describe actions of the application:
    |srarr|\ (`138`_)
:Action final summary of what was done:
    |srarr|\ (`141`_)
:Action superclass has common features of all actions:
    |srarr|\ (`139`_)
:ActionSequence append adds a new action to the sequence:
    |srarr|\ (`144`_)
:ActionSequence call method delegates the sequence of ations:
    |srarr|\ (`143`_)
:ActionSequence subclass that holds a sequence of other actions:
    |srarr|\ (`142`_)
:ActionSequence summary summarizes each step:
    |srarr|\ (`145`_)
:Application Class:
    |srarr|\ (`161`_) |srarr|\ (`162`_)
:Application class process all files:
    |srarr|\ (`165`_)
:Application default options:
    |srarr|\ (`163`_)
:Application parse command line:
    |srarr|\ (`164`_)
:Base Class Definitions:
    |srarr|\ (`1`_)
:Chunk add to the web:
    |srarr|\ (`56`_)
:Chunk append a command:
    |srarr|\ (`54`_)
:Chunk append text:
    |srarr|\ (`55`_)
:Chunk base class for anonymous chunks of the file:
    |srarr|\ (`53`_)
:Chunk class hierarchy - used to describe input chunks:
    |srarr|\ (`52`_)
:Chunk examination: starts with, matches pattern:
    |srarr|\ (`59`_)
:Chunk generate references from this Chunk:
    |srarr|\ (`60`_)
:Chunk indent adjustments:
    |srarr|\ (`64`_)
:Chunk references to this Chunk:
    |srarr|\ (`61`_)
:Chunk superclass make Content definition:
    |srarr|\ (`57`_)
:Chunk tangle this Chunk into a code file:
    |srarr|\ (`63`_)
:Chunk weave this Chunk into the documentation:
    |srarr|\ (`62`_)
:CodeCommand class to contain a program source code block:
    |srarr|\ (`83`_)
:Command analysis features: starts-with and Regular Expression search:
    |srarr|\ (`80`_)
:Command class hierarchy - used to describe individual commands:
    |srarr|\ (`78`_)
:Command superclass:
    |srarr|\ (`79`_)
:Command tangle and weave functions:
    |srarr|\ (`81`_)
:Emitter class hierarchy - used to control output files:
    |srarr|\ (`2`_)
:Emitter core open, close and write:
    |srarr|\ (`5`_)
:Emitter doClose, to be overridden by subclasses:
    |srarr|\ (`7`_)
:Emitter doOpen, to be overridden by subclasses:
    |srarr|\ (`6`_)
:Emitter indent control: set, clear and reset:
    |srarr|\ (`11`_)
:Emitter superclass:
    |srarr|\ (`4`_)
:Emitter write a block of code:
    |srarr|\ (`8`_) |srarr|\ (`9`_) |srarr|\ (`10`_)
:Error class - defines the errors raised:
    |srarr|\ (`96`_)
:FileXrefCommand class for an output file cross-reference:
    |srarr|\ (`85`_)
:HTML code chunk begin:
    |srarr|\ (`34`_)
:HTML code chunk end:
    |srarr|\ (`35`_)
:HTML output file begin:
    |srarr|\ (`36`_)
:HTML output file end:
    |srarr|\ (`37`_)
:HTML reference to a chunk:
    |srarr|\ (`40`_)
:HTML references summary at the end of a chunk:
    |srarr|\ (`38`_)
:HTML short references summary at the end of a chunk:
    |srarr|\ (`43`_)
:HTML simple cross reference markup:
    |srarr|\ (`41`_)
:HTML subclass of Weaver:
    |srarr|\ (`32`_) |srarr|\ (`33`_)
:HTML write a line of code:
    |srarr|\ (`39`_)
:HTML write user id cross reference line:
    |srarr|\ (`42`_)
:Imports:
    |srarr|\ (`3`_) |srarr|\ (`12`_) |srarr|\ (`48`_) |srarr|\ (`58`_) |srarr|\ (`98`_) |srarr|\ (`124`_) |srarr|\ (`129`_) |srarr|\ (`132`_) |srarr|\ (`134`_) |srarr|\ (`156`_) |srarr|\ (`160`_) |srarr|\ (`166`_)
:Interface Functions:
    |srarr|\ (`169`_)
:LaTeX code chunk begin:
    |srarr|\ (`25`_)
:LaTeX code chunk end:
    |srarr|\ (`26`_)
:LaTeX file output begin:
    |srarr|\ (`27`_)
:LaTeX file output end:
    |srarr|\ (`28`_)
:LaTeX reference to a chunk:
    |srarr|\ (`31`_)
:LaTeX references summary at the end of a chunk:
    |srarr|\ (`29`_)
:LaTeX subclass of Weaver:
    |srarr|\ (`24`_)
:LaTeX write a line of code:
    |srarr|\ (`30`_)
:LoadAction call method loads the input files:
    |srarr|\ (`153`_)
:LoadAction subclass loads the document web:
    |srarr|\ (`152`_)
:LoadAction summary provides lines read:
    |srarr|\ (`154`_)
:Logging Setup:
    |srarr|\ (`167`_) |srarr|\ (`168`_)
:MacroXrefCommand class for a named chunk cross-reference:
    |srarr|\ (`86`_)
:NamedChunk add to the web:
    |srarr|\ (`67`_)
:NamedChunk class for defined names:
    |srarr|\ (`65`_) |srarr|\ (`70`_)
:NamedChunk tangle into the source file:
    |srarr|\ (`69`_)
:NamedChunk user identifiers set and get:
    |srarr|\ (`66`_)
:NamedChunk weave into the documentation:
    |srarr|\ (`68`_)
:NamedDocumentChunk class:
    |srarr|\ (`75`_)
:NamedDocumentChunk tangle:
    |srarr|\ (`77`_)
:NamedDocumentChunk weave:
    |srarr|\ (`76`_)
:Option Parser class - locates optional values on commands:
    |srarr|\ (`135`_) |srarr|\ (`136`_) |srarr|\ (`137`_)
:OutputChunk add to the web:
    |srarr|\ (`72`_)
:OutputChunk class:
    |srarr|\ (`71`_)
:OutputChunk tangle:
    |srarr|\ (`74`_)
:OutputChunk weave:
    |srarr|\ (`73`_)
:Overheads:
    |srarr|\ (`157`_) |srarr|\ (`158`_) |srarr|\ (`159`_)
:RST subclass of Weaver:
    |srarr|\ (`23`_)
:Reference class hierarchy - strategies for references to a chunk:
    |srarr|\ (`93`_) |srarr|\ (`94`_) |srarr|\ (`95`_)
:ReferenceCommand class for chunk references:
    |srarr|\ (`88`_)
:ReferenceCommand refers to a chunk:
    |srarr|\ (`90`_)
:ReferenceCommand resolve a referenced chunk name:
    |srarr|\ (`89`_)
:ReferenceCommand tangle a referenced chunk:
    |srarr|\ (`92`_)
:ReferenceCommand weave a reference to a chunk:
    |srarr|\ (`91`_)
:TangleAction call method does tangling of the output files:
    |srarr|\ (`150`_)
:TangleAction subclass initiates the tangle action:
    |srarr|\ (`149`_)
:TangleAction summary method provides total lines tangled:
    |srarr|\ (`151`_)
:Tangler code chunk begin:
    |srarr|\ (`46`_)
:Tangler code chunk end:
    |srarr|\ (`47`_)
:Tangler doOpen, and doClose overrides:
    |srarr|\ (`45`_)
:Tangler subclass of Emitter to create source files with no markup:
    |srarr|\ (`44`_)
:TanglerMake doClose override, comparing temporary to original:
    |srarr|\ (`51`_)
:TanglerMake doOpen override, using a temporary file:
    |srarr|\ (`50`_)
:TanglerMake subclass which is make-sensitive:
    |srarr|\ (`49`_)
:TextCommand class to contain a document text block:
    |srarr|\ (`82`_)
:Tokenizer class - breaks input into tokens:
    |srarr|\ (`133`_)
:UserIdXrefCommand class for a user identifier cross-reference:
    |srarr|\ (`87`_)
:WeaveAction call method to pick the language:
    |srarr|\ (`147`_)
:WeaveAction subclass initiates the weave action:
    |srarr|\ (`146`_)
:WeaveAction summary of language choice:
    |srarr|\ (`148`_)
:Weaver code chunk begin-end:
    |srarr|\ (`18`_)
:Weaver cross reference output methods:
    |srarr|\ (`21`_) |srarr|\ (`22`_)
:Weaver doOpen, doClose and addIndent overrides:
    |srarr|\ (`14`_)
:Weaver document chunk begin-end:
    |srarr|\ (`16`_)
:Weaver file chunk begin-end:
    |srarr|\ (`19`_)
:Weaver quoted characters:
    |srarr|\ (`15`_)
:Weaver reference command output:
    |srarr|\ (`20`_)
:Weaver reference summary, used by code chunk and file chunk:
    |srarr|\ (`17`_)
:Weaver subclass of Emitter to create documentation:
    |srarr|\ (`13`_)
:Web Chunk check reference counts are all one:
    |srarr|\ (`107`_)
:Web Chunk cross reference methods:
    |srarr|\ (`106`_) |srarr|\ (`108`_) |srarr|\ (`109`_) |srarr|\ (`110`_)
:Web Chunk name resolution methods:
    |srarr|\ (`104`_) |srarr|\ (`105`_)
:Web add a named macro chunk:
    |srarr|\ (`102`_)
:Web add an anonymous chunk:
    |srarr|\ (`101`_)
:Web add an output file definition chunk:
    |srarr|\ (`103`_)
:Web add full chunk names, ignoring abbreviated names:
    |srarr|\ (`100`_)
:Web class - describes the overall "web" of chunks:
    |srarr|\ (`97`_)
:Web construction methods used by Chunks and WebReader:
    |srarr|\ (`99`_)
:Web determination of the language from the first chunk:
    |srarr|\ (`113`_)
:Web tangle the output files:
    |srarr|\ (`114`_)
:Web weave the output document:
    |srarr|\ (`115`_)
:WebReader class - parses the input file, building the Web structure:
    |srarr|\ (`116`_)
:WebReader command literals:
    |srarr|\ (`131`_)
:WebReader handle a command string:
    |srarr|\ (`117`_) |srarr|\ (`127`_)
:WebReader load the web:
    |srarr|\ (`130`_)
:WebReader location in the input stream:
    |srarr|\ (`128`_)
:XrefCommand superclass for all cross-reference commands:
    |srarr|\ (`84`_)
:add a reference command to the current chunk:
    |srarr|\ (`123`_)
:add an expression command to the current chunk:
    |srarr|\ (`125`_)
:assign user identifiers to the current chunk:
    |srarr|\ (`122`_)
:collect all user identifiers from a given map into ux:
    |srarr|\ (`111`_)
:double at-sign replacement, append this character to previous TextCommand:
    |srarr|\ (`126`_)
:find user identifier usage and update ux from the given map:
    |srarr|\ (`112`_)
:finish a chunk, start a new Chunk adding it to the web:
    |srarr|\ (`121`_)
:include another file:
    |srarr|\ (`120`_)
:start a NamedChunk or NamedDocumentChunk, adding it to the web:
    |srarr|\ (`119`_)
:start an OutputChunk, adding it to the web:
    |srarr|\ (`118`_)
:weave.py custom weaver definition to customize the Weaver being used:
    |srarr|\ (`173`_)
:weave.py overheads for correct operation of a script:
    |srarr|\ (`172`_)
:weaver.py processing: load and weave the document:
    |srarr|\ (`174`_)



User Identifiers
----------------


:Action:
    [`139`_] `142`_ `144`_ `146`_ `149`_ `152`_
:ActionSequence:
    [`142`_] `163`_
:Application:
    [`161`_] `169`_
:Chunk:
    `16`_ `17`_ `18`_ `19`_ `46`_ `47`_ [`53`_] `59`_ `60`_ `65`_ `79`_ `88`_ `92`_ `93`_ `94`_ `95`_ `97`_ `101`_ `102`_ `103`_ `105`_ `106`_ `110`_ `116`_ `120`_ `121`_ `123`_ `130`_
:CodeCommand:
    `65`_ [`83`_]
:Command:
    `53`_ `54`_ `55`_ `57`_ `65`_ `75`_ [`79`_] `82`_ `84`_ `88`_ `165`_
:Emitter:
    [`4`_] `5`_ `13`_ `44`_
:Error:
    `60`_ `63`_ `69`_ `77`_ `84`_ `92`_ [`96`_] `102`_ `104`_ `105`_ `115`_ `119`_ `120`_ `125`_ `137`_ `147`_ `150`_ `153`_ `164`_
:FileXrefCommand:
    [`85`_] `117`_
:HTML:
    `32`_ [`33`_] `113`_ `162`_ `173`_
:LaTeX:
    [`24`_] `113`_ `162`_
:LoadAction:
    [`152`_] `163`_ `170`_ `174`_
:MacroXrefCommand:
    [`86`_] `117`_
:NamedChunk:
    `59`_ [`65`_] `70`_ `71`_ `75`_ `119`_
:NamedDocumentChunk:
    [`75`_] `119`_
:OutputChunk:
    [`71`_] `118`_
:Path:
    [`3`_] `4`_ `5`_ `53`_ `97`_ `114`_ `116`_ `120`_ `130`_ `163`_ `164`_ `170`_ `172`_ `174`_
:ReferenceCommand:
    [`88`_] `123`_
:TangleAction:
    [`149`_] `163`_ `170`_
:Tangler:
    `4`_ [`44`_] `49`_ `63`_ `64`_ `69`_ `70`_ `74`_ `77`_ `81`_ `82`_ `83`_ `84`_ `92`_ `114`_ `164`_
:TanglerMake:
    [`49`_] `164`_ `168`_ `170`_
:TextCommand:
    `55`_ `57`_ `69`_ `75`_ [`82`_] `83`_
:Tokenizer:
    `116`_ `130`_ [`133`_]
:UserIdXrefCommand:
    [`87`_] `117`_
:WeaveAction:
    [`146`_] `163`_ `174`_
:Weaver:
    [`13`_] `23`_ `24`_ `32`_ `61`_ `62`_ `68`_ `73`_ `76`_ `81`_ `82`_ `83`_ `84`_ `85`_ `86`_ `87`_ `91`_ `113`_ `115`_ `164`_ `165`_
:Web:
    `46`_ `53`_ `56`_ `60`_ `62`_ `63`_ `64`_ `67`_ `68`_ `69`_ `70`_ `72`_ `73`_ `74`_ `76`_ `77`_ `81`_ `82`_ `83`_ `84`_ `85`_ `86`_ `87`_ `89`_ `90`_ `91`_ `92`_ [`97`_] `116`_ `130`_ `139`_ `153`_ `165`_ `170`_ `174`_
:WebReader:
    [`116`_] `120`_ `130`_ `164`_ `168`_ `170`_ `174`_
:XrefCommand:
    [`84`_] `85`_ `86`_ `87`_
:__enter__:
    [`5`_] `167`_
:__exit__:
    [`5`_] `167`_
:__version__:
    `125`_ [`159`_] `164`_
:_gatherUserId:
    [`110`_]
:_updateUserId:
    [`110`_]
:add:
    `56`_ [`101`_]
:addDefName:
    [`100`_] `102`_ `123`_
:addIndent:
    `11`_ [`14`_] `64`_ `68`_
:addNamed:
    `67`_ [`102`_]
:addOutput:
    `72`_ [`103`_]
:append:
    `11`_ `14`_ `54`_ `55`_ `95`_ `101`_ `102`_ `103`_ `106`_ `112`_ `117`_ `123`_ `137`_ [`144`_]
:appendText:
    [`55`_] `123`_ `125`_ `126`_ `130`_
:argparse:
    `139`_ [`160`_] `163`_ `164`_ `165`_ `170`_ `172`_ `174`_
:builtins:
    [`124`_] `125`_
:chunkXref:
    `86`_ [`109`_]
:close:
    [`5`_] `14`_ `45`_ `51`_
:clrIndent:
    [`11`_] `64`_ `68`_ `70`_
:codeBegin:
    `18`_ [`46`_] `68`_ `69`_
:codeBlock:
    [`8`_] `68`_ `83`_
:codeEnd:
    `18`_ [`47`_] `68`_ `69`_
:codeFinish:
    `5`_ `10`_ [`14`_]
:createUsedBy:
    [`106`_] `153`_
:datetime:
    `125`_ [`156`_]
:doClose:
    `5`_ `7`_ `14`_ `45`_ [`51`_]
:doOpen:
    `5`_ `6`_ `14`_ `45`_ [`50`_]
:docBegin:
    [`16`_] `62`_
:docEnd:
    [`16`_] `62`_
:duration:
    [`141`_] `148`_ `151`_ `154`_
:expand:
    `76`_ `123`_ `163`_ [`164`_]
:expect:
    `118`_ `119`_ `123`_ `125`_ [`127`_]
:fileBegin:
    `19`_ [`36`_] `73`_
:fileEnd:
    `19`_ [`37`_] `73`_
:fileXref:
    `85`_ [`109`_]
:filecmp:
    [`48`_] `51`_
:formatXref:
    [`84`_] `85`_ `86`_
:fullNameFor:
    `68`_ `73`_ `89`_ `100`_ [`104`_] `105`_ `106`_
:genReferences:
    [`60`_] `106`_
:getUserIDRefs:
    `59`_ [`66`_] `111`_
:getchunk:
    `89`_ [`105`_] `106`_ `115`_
:handleCommand:
    [`117`_] `130`_
:language:
    [`113`_] `147`_ `158`_
:lineNumber:
    `18`_ `19`_ `34`_ `36`_ `46`_ `55`_ `57`_ [`59`_] `65`_ `69`_ `75`_ `79`_ `82`_ `84`_ `88`_ `117`_ `120`_ `123`_ `125`_ `126`_ `128`_ `130`_ `133`_ `173`_
:load:
    `120`_ [`130`_] `153`_ `163`_ `165`_
:location:
    `117`_ `122`_ `125`_ `127`_ [`128`_]
:logging:
    `4`_ `53`_ `79`_ `93`_ `97`_ `116`_ `139`_ `161`_ `163`_ `164`_ `165`_ [`166`_] `167`_ `168`_ `170`_ `172`_ `174`_
:logging.config:
    [`166`_] `167`_
:main:
    [`169`_] `170`_ `174`_
:makeContent:
    `55`_ [`57`_] `65`_ `75`_
:multi_reference:
    `107`_ [`108`_]
:no_definition:
    `107`_ [`108`_]
:no_reference:
    `107`_ [`108`_]
:open:
    [`5`_] `14`_ `45`_ `114`_ `115`_ `125`_ `130`_
:os:
    `50`_ `51`_ `125`_ [`156`_]
:parse:
    `118`_ `119`_ [`130`_] `137`_
:parseArgs:
    [`164`_] `169`_
:perform:
    [`153`_]
:platform:
    [`124`_] `125`_
:process:
    `125`_ [`165`_] `169`_
:quote:
    [`9`_] `83`_
:quoted_chars:
    `9`_ `15`_ `30`_ [`39`_]
:re:
    `112`_ [`132`_] `133`_
:readdIndent:
    `4`_ [`11`_] `14`_
:ref:
    `29`_ `60`_ [`81`_] `90`_ `101`_ `102`_ `103`_
:referenceSep:
    [`20`_] `115`_
:referenceTo:
    `20`_ `21`_ [`40`_] `68`_
:references:
    `17`_ `18`_ `19`_ `20`_ `26`_ `33`_ `35`_ `37`_ [`43`_] `53`_ `60`_ `61`_ `107`_ `122`_ `163`_ `173`_
:resolve:
    `69`_ [`89`_] `90`_ `91`_ `92`_ `105`_
:searchForRE:
    `59`_ [`80`_] `82`_ `112`_
:setIndent:
    [`11`_] `70`_
:setUserIDRefs:
    `59`_ [`66`_] `122`_
:shlex:
    [`134`_] `137`_
:startswith:
    `59`_ [`80`_] `82`_ `104`_ `113`_ `130`_ `137`_ `165`_
:string:
    [`12`_] `17`_ `18`_ `19`_ `20`_ `21`_ `22`_ `25`_ `26`_ `29`_ `31`_ `34`_ `35`_ `36`_ `37`_ `38`_ `40`_ `41`_ `42`_ `43`_ `55`_ `172`_ `173`_
:summary:
    `141`_ `145`_ `148`_ `151`_ [`154`_] `165`_ `170`_ `174`_
:sys:
    [`124`_] `125`_ `168`_ `169`_
:tangle:
    `46`_ `63`_ `69`_ `71`_ `74`_ `75`_ `77`_ `81`_ `82`_ `83`_ `84`_ `92`_ [`114`_] `150`_ `163`_ `170`_
:tempfile:
    [`48`_] `50`_
:time:
    `125`_ `140`_ `141`_ [`156`_]
:types:
    `13`_ `125`_ [`156`_]
:usedBy:
    [`90`_]
:userNamesXref:
    `87`_ [`110`_]
:weakref:
    `53`_ [`98`_] `101`_ `102`_ `103`_
:weave:
    `62`_ `68`_ `73`_ `76`_ `81`_ `82`_ `83`_ `85`_ `86`_ `87`_ `91`_ [`115`_] `147`_ `163`_ `172`_
:weaveChunk:
    `91`_ [`115`_]
:weaveReferenceTo:
    `62`_ `68`_ [`76`_] `115`_
:weaveShortReferenceTo:
    `62`_ `68`_ [`76`_] `115`_
:webAdd:
    `56`_ `67`_ [`72`_] `118`_ `119`_ `120`_ `121`_ `130`_
:write:
    `4`_ [`5`_] `8`_ `10`_ `18`_ `19`_ `21`_ `22`_ `46`_ `82`_ `115`_
:xrefDefLine:
    `22`_ [`42`_] `87`_
:xrefFoot:
    `21`_ [`41`_] `84`_ `87`_
:xrefHead:
    `21`_ [`41`_] `84`_ `87`_
:xrefLine:
    `21`_ [`41`_] `84`_




---------

..	class:: small

	Created by /Users/slott/Documents/Projects/py-web-tool/bootstrap/pyweb.py at Mon Jun 13 11:12:26 2022.

    Source pyweb.w modified Mon Jun 13 08:52:05 2022.

	pyweb.__version__ '3.0'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool/src'.
