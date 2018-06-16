..  pyweb/intro.w

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

**pyWeb** is a literate programming tool that combines the actions
of *weaving* a document with *tangling* source files.
It is independent of any source language.
It is designed to work with RST document markup.
Is uses a simple set of markup tags to define chunks of code and 
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

The immediate predecessors to this **pyWeb** tool are 
`FunnelWeb <http://www.ross.net/funnelweb>`_,
`noweb <http://www.eecs.harvard.edu/~nr/noweb/>`_ and 
`nuweb <http://sourceforge.net/projects/nuweb/>`_.  The ideas lifted from these other
tools created the foundation for **pyWeb**.

There are several Python-oriented literate programming tools.  
These include 
`LEO <http://personalpages.tds.net/~edream/front.html">`_,
`interscript <http://interscript.sourceforge.net/>`_,
`lpy <http://www.danbala.com/python/lpy/>`_,
`py2html <http://www.egenix.com/files/python/SoftwareDescriptions.html#py2html.py>`_,
`PyLit <http://pylit.berlios.de/>`_.

The *FunnelWeb* tool is independent of any programming language
and only mildly dependent on T\ :sub:`e`\ X.
It has 19 commands, many of which duplicate features of HTML or 
L\ :sub:`a`\ T\ :sub:`e`\ X.

The *noweb* tool was written by Norman Ramsey.
This tool uses a sophisticated multi-processing framework, via Unix
pipes, to permit flexible manipulation of the source file to tangle
and weave the programming language and documentation markup files.

The *nuweb* Simple Literate Programming Tool was developed by
Preston Briggs (preston@@tera.com).  His work was supported by ARPA,
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

The *PyLit* tool is perhaps the very best approach to simple Literate
programming, since it leverages an existing lightweight markup language
and it's output formatting. However, it's limited in the presentation order,
making it difficult to present a complex Python module out of the proper
Python required presentation.

**pyWeb**
---------

**pyWeb** works with any 
programming language. It can work with any markup language, but is currently
configured to work with RST only.  This philosophy
comes from *FunnelWeb*
*noweb*, *nuweb* and *interscript*.  The primary differences
between **pyWeb** and other tools are the following.

-   **pyWeb** is object-oriented, permitting easy extension.  
    *noweb* extensions
    are separate processes that communicate through a sophisticated protocol.
    *nuweb* is not easily extended without rewriting and recompiling
    the C programs.

-   **pyWeb** is built in the very portable Python programming 
    language.  This allows it to run anywhere that Python 3.3 runs, with
    only the addition of docutils.  This makes it a useful
    tool for programmers in any language.

-   **pyWeb** is much simpler than *FunnelWeb*, *LEO* or *Interscript*.  It has 
    a very limited selection of commands, but can still produce 
    complex programs and HTML documents.

-   **pyWeb** does not invent a complex markup language like *Interscript*.
    Because *Iterscript* has its own markup, it can generate L\ :sub:`a`\ T\ :sub:`e`\ X or HTML or other
    output formats from a unique input format.  While powerful, it seems simpler to
    avoid inventing yet another sophisticated markup language.  The language **pyWeb**
    uses is very simple, and the author's use their preferred markup language almost
    exclusively.

-   **pyWeb** supports the forward literate programming philosophy, 
    where a source document creates programming language and markup language.
    The alternative, deriving the document from markup embedded in 
    program comments ("inverted literate programming"), seems less appealing.
    The disadvantage of inverted literate programming is that the final document
    can't reflect the original author's preferred order of exposition,
    since that informtion generally isn't part of the source code.

-   **pyWeb** also specifically rejects some features of *nuweb*
    and *FunnelWeb*.  These include the macro capability with parameter
    substitution, and multiple references to a chunk.  These two capabilities
    can be used to grow object-like applications from non-object programming
    languages (*e.g.* C or Pascal).  Since most modern languages (Python,
    Java, C++) are object-oriented, this macro capability is more of a problem
    than a help.

-   Since **pyWeb** is built in the Python interpreter, a source document
    can include Python expressions that are evaluated during weave operation to
    produce time stamps, source file descriptions or other information in the woven 
    or tangled output.


**pyWeb** works with any programming language; it can work with any markup language.
The initial release supports RST via simple templates.

The following is extensively quoted from Briggs' *nuweb* documentation, 
and provides an excellent background in the advantages of the very
simple approach started by *nuweb* and adopted by **pyWeb**.

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
        Since [**pyWeb**] doesn't do too much, it runs very quickly. 
        It combines the functions of ``tangle`` and ``weave`` into a single 
        program that performs both functions at once.

    :Chunk numbers:
        Inspired by the example of **noweb**, [**pyWeb**] refers to all program code 
        chunks by a simple, ascending sequence number through the file.  
        This becomes the HTML anchor name, also.

    :Multiple file output:
        The programmer may specify more than one output file in a single [**pyWeb**] 
        source file. This is required when constructing programs in a combination of 
        languages (say, Fortran and C). It's also an advantage when constructing 
        very large programs.

Use Cases
-----------

**pyWeb** supports two use cases, `Tangle Source Files`_ and `Weave Documentation`_.
These are often combined into a single request of the application that will both
weave and tangle.

Tangle Source Files
~~~~~~~~~~~~~~~~~~~

A user initiates this process when they have a complete ``.w`` file that contains 
a description of source files.  These source files are described with ``@@o`` commands
in the ``.w`` file.

The use case is successful when the source files are produced.

Outside this use case, the user will debug those source files, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the source files cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

The sequence is simply ``./pyweb.py *theFile*.w``.

Weave Documentation
~~~~~~~~~~~~~~~~~~~~

A user initiates this process when they have a ``.w`` file that contains 
a description of a document to produce.  The document is described by the entire
``.w`` file.

The use case is successful when the documentation file is produced.

Outside this use case, the user will edit the documentation file, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

The sequence is simply ``./pyweb.py *theFile*.w``.

Tangle, Regression Test and Weave
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A user initiates this process when they have a ``.w`` file that contains 
a description of a document to produce.  The document is described by the entire
``.w`` file.  Further, their final document should include regression test output 
from the source files created by the tangle operation.

The use case is successful when the documentation file is produced, including
current regression test output.

Outside this use case, the user will edit the documentation file, possibly updating the
``.w`` file.  This will lead to a need to restart this use case.

The use case is a failure when the documentation file cannot be produced, due to 
errors in the ``.w`` file.  These must be corrected based on information in log messages.

The use case is a failure when the documentation file does not include current
regression test output.

The sequence is as follows:

..  parsed-literal::

    ./pyweb.py -xw -pi *theFile*\ .w
    python *theTest* >\ *aLog*
    ./pyweb.py -xt *theFile*\ .w


The first step excludes weaving and permits errors on the ``@@i`` command.  The ``-pi`` option
is necessary in the event that the log file does not yet exist.  The second step 
runs the regression test, creating a log file.  The third step weaves the final document,
including the regression test output.

Writing **pyWeb** ``.w`` Files
-------------------------------

The essence of literate programming is a markup language that distinguishes code
from documentation. For tangling, the code is relevant. For weaving, both code
and documentation are relevant.

The **pyWeb** markup defines a sequence of *Chunks*. 
Each Chunk is either program source code to 
be *tangled* or it is documentation to be *woven*.  The bulk of
the file is typically documentation chunks that describe the program in
some human-oriented markup language like RST, HTML, or LaTeX.


The **pyWeb** tool parses the input, and performs the
tangle and weave operations.  It *tangles* each individual output file
from the program source chunks.  It *weaves* a final documentation file
file from the entire sequence of chunks provided, mixing the author's 
original documentation with some markup around the embedded program source.

**pyWeb** markup surrounds the code with tags. Everything else is documentation.
When tangling, the tagged code is assembled into the final file.
When weaving, the tags are replaced with output markup. This means that **pyWeb**
is not **totally** independent of the output markup.

The code chunks will have their indentation adjusted to match the context in which
they were originally defined. This assures that Python (which relies on indentation)
parses correctly. For other languages, proper indentation is expected but not required.

The non-code chunks are not transformed up in any way.  Everything that's not
explicitly a code chunk is simply output without modification.

All of the **pyWeb** tags begin with ``@@``.  This can be changed.

The *Structural* tags (historically called "major commands") partition the input and define the
various chunks.  The *Inline* tags are (called "minor commands") are used to control the
woven and tangled output from those chunks. There are *Content* tags which generate 
summary cross-reference content in woven files.


Structural Tags
~~~~~~~~~~~~~~~

There are two definitional tags; these define the various chunks
in an input file. 

``@@o`` *file* ``@@{`` *text* ``@@}``

    The ``@@o`` (output) command defines a named output file chunk.  
    The text is tangled to the named
    file with no alteration.  It is woven into the document
    in an appropriate fixed-width font.
    
    There are options available to specify comment conventions
    for the tangled output; this allows inclusion of source
    line numbers.

``@@d`` *name* ``@@{`` *text* ``@@}``

    The ``@@d`` (define) command defines a named chunk of program source. 
    This text is tangled
    or woven when it is referenced by the *reference* inline tag.
    
    There are options available to specify the indentation for this
    particular chunk. In rare cases, it can be helpful to override
    the indentation context.

Each ``@@o`` and ``@@d`` tag is followed by a chunk which is
delimited by ``@@{`` and ``@@}`` tags.  
At the end of that chunk, there is an optional "major" tag.  

``@@|``

    A chunk may define user identifiers.  The list of defined identifiers is placed
    in the chunk, separated by the ``@@|`` separator.


Additionally, these tags provide for the inclusion of additional input files.
This is necessary for decomposing a long document into easy-to-edit sections.

``@@i`` *file*

    The ``@@i`` (include) command includes another file.  The previous chunk
    is ended.  The file is processed completely, then a new chunk
    is started for the text after the ``@@i`` command.

All material that is not explicitly in a ``@@o`` or ``@@d`` named chunk is
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

    @@o myFile.py 
    @@{
    import math
    print( math.pi )
    @@| math math.pi
    @@}

    Some more RST documentation.

This starts with an anonymous chunk of
documentation. It includes a named output chunk which will write to ``myFile.py``.
It ends with an anonymous chunk of documentation.

Inline Tags
~~~~~~~~~~~~

There are several tags that are replaced by content in the woven output.

``@@@@``

    The ``@@@@`` command creates a single ``@@`` in the output file.
    This is replaced in tangled as well as woven output.

``@@<``\ *name*\ ``@@>``

    The *name* references a named chunk.
    When tangling, the referenced chunk replaces the reference command.
    When weaving, a reference marker is used.  For example, in RST, this can be 
    replaced with RST ```reference`_`` markup.
    Note that the indentation prior to the ``@@<`` tag is preserved
    for the tangled chunk that replaces the tag.


``@@(``\ *Python expression*\ ``@@)``

    The *Python expression* is evaluated and the result is tangled or
    woven in place.  A few global variables and modules are available.
    These are described in `Expression Context`_.

Content Tags
~~~~~~~~~~~~~

There are three index creation tags that are replaced by content in the woven output.


``@@f``

    The ``@@f`` command inserts a file cross reference.  This
    lists the name of each file created by an ``@@o`` command, and all of the various
    chunks that are concatenated to create this file.

``@@m``

    The ``@@m`` command inserts a named chunk ("macro") cross reference.  This
    lists the name of each chunk created by a ``@@d`` command, and all of the various
    chunks that are concatenated to create the complete chunk.

``@@u``

    The ``@@u`` command inserts a user identifier cross reference. 
    This index lists the name of each chunk created by an ``@@d`` command or ``@@|``, 
    and all of the various chunks that are concatenated to create the complete chunk.


Additional Features
~~~~~~~~~~~~~~~~~~~

**Sequence Numbers**. The named chunks (from both ``@@o`` and ``@@d`` commands) are assigned 
unique sequence numbers to simplify cross references.  

**Case Sensitive**. Chunk names and file names are case sensitive.

**Abbreviations**. Chunk names can be abbreviated.  A partial name can have a trailing ellipsis (...), 
this will be resolved to the full name.  The most typical use for this
is shown in the following example:

..  parsed-literal::

    Some RST-format documentation.

    @@o myFile.py 
    @@{
    @@<imports of the various packages used>
    print( math.pi,time.time() )
    @@}

    Some notes on the packages used.

    @@d imports...
    @@{
    import math,time
    @@| math time
    @@}

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
    Set off after the ``@@|`` separator is
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

    @@o myFile.py 
    @@{
    import math,time
    @@}

    Some notes on the packages used.

    @@o myFile.py
    @@{
    print math.pi,time.time()
    @@}

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

    @@{
    import math,time
    @@}

This puts a newline character before and after the import line.

Controlling Indentation
~~~~~~~~~~~~~~~~~~~~~~~

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

    @@o myFile.py 
    @@{
    def aFunction( a, b ):
        @@<body of aFunction@@>
    @@| aFunction @@}

    @@d body...
    @@{
    """doc string"""
    return a + b
    @@}

The tangled output from this will look like the following.
All of the newline characters are preserved, and the reference to
*body of the aFunction* is indented to match the prevailing
indent where it was referenced.  In the following example, 
explicit line markers of ``~`` are provided to make the blank lines 
more obvious.

..  parsed-literal::

    ~
    ~def aFunction( a, b ):
    ~        
    ~    """doc string"""
    ~    return a + b
    ~

[The ``@@|`` command shows that this chunk defines the identifier ``aFunction``.]

This leads to a difficult design choice.

-   Do we use context-sensitive indentation without any exceptions?
    This is the current implementation. 
    
-   Do we use consistent indentation and require the author to get it right?
    This seems to make Python awkward, since we might indent our outdent a 
    ``@@<`` *name* ``@@>`` command, expecting the chunk to indent properly.

-   Do we use context-sensitive indentation with an exception indicator?
    This seems to go against the utter simplicity we're cribbing from **noweb**.
    However, it makes a great deal of sense to add an option for ``@@d`` chunks to
    supersede context-sensitive indentation. The author must then get it right.
    
    The syntax to define a section looks like this: 
    
..  parsed-literal::

    @@d -noindent some chunk name
    @@{*First partial line*
    *More that uses """*
    @@}
    
We might reference such a section like this.

..  parsed-literal::

    @@d some bigger chunk...
    @@{*code*
        @@<some chunk name@@>
    @@}
    
This will include the ``-noindent`` section by resetting the contextual indentation
to zero. The *First partial line* line will be output after the four spaces 
provided by the ``some bigger chunk`` context. 

After the first newline (*More that uses """*) will be at the left margin.

Tracking Source Line Numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since the tangled output files are -- well -- tangled, it can be difficult to
trace back from a Python error stack to the original line in the ``.w`` file that
needs to be fixed.

To facilitate this, there is a two-step operation to get more detailed information
on how tangling worked.

1.  Use the -n command-line option to get line numbers.

2.  Include comment indicators on the ``@@o`` commands that define output files.

The expanded syntax for ``@@o`` looks like this.

..  parsed-literal::

    @@o -start /* -end */ page-layout.css
    @@{
    *Some CSS code*
    @@}
    
We've added two options: ``-start /*`` and ``-end */`` which define comment
start and end syntax. This will lead to comments embedded in the tangled output
which contain source line numbers for every (every!) chunk.

Expression Context
~~~~~~~~~~~~~~~~~~~~

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
A simple global context is created with the following variables defined.

:os.path:
    This is the standard ``os.path`` module. The complete ``os`` module is not
    available. Just this one item.
    
:datetime:
    This is the standard ``datetime`` module.

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
    The name of the running **pyWeb** application. It may not be pyweb.py, 
    if some other script is being used.

:__version__:
    The version string in the **pyWeb** application.


Running **pyWeb** to Tangle and Weave
--------------------------------------

Assuming that you have marked ``pyweb.py`` as executable,
you do the following.

..  parsed-literal::

    ./pyweb.py *file*...

This will tangle the ``@@o`` commands in each *file*.
It will also weave the output, and create *file*.txt.

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

Bootstrapping
--------------

**pyWeb** is written using **pyWeb**. The distribution includes the original ``.w``
files as well as a ``.py`` module.

The bootstrap procedure is this.

..  parsed-literal::

    python pyweb.py pyweb.w
    rst2html.py pyweb.rst pyweb.html
    
The resulting ``pyweb.html`` file is the final documentation.

Similarly, the tests are bootstrapped from ``.w`` files.

..  parsed-literal::

    cd test
    python ../pyweb.py pyweb_test.w
    PYTHONPATH=.. python test.py
    rst2html.py pyweb_test.rst pyweb_test.html    

Dependencies
-------------

**pyWeb** requires Python 3.3 or newer.

If you create RST output, you'll want to use docutils to translate
the RST to HTML or LaTeX or any of the other formats supported by docutils.

Acknowledgements
----------------

This application is very directly based on (derived from?) work that
 preceded this, particularly the following:

-   Ross N. Williams' *FunnelWeb* http://www.ross.net/funnelweb/

-   Norman Ramsey's *noweb* http://www.eecs.harvard.edu/~nr/noweb/

-   Preston Briggs' *nuweb* http://sourceforge.net/projects/nuweb/

    Currently supported by Charles Martin and Marc W. Mengel

Also, after using John Skaller's *interscript* http://interscript.sourceforge.net/
for two large development efforts, I finally understood the feature set I really needed.

Jason Fruit contributed to the previous version.