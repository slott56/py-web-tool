.. py-web-tool/src/language.w

The **py-web-lp** Markup Language
==========================================

The essence of literate programming is a markup language that includes both code as well as documentation.
For tangling, the code is relevant.
For weaving, both code and documentation are relevant.

The source document is a "Web" document that includes the code.
It's important to understand the ``.w`` file as the only source for code and documentation.
The code is tangled out  of the source web file.

The **py-web-lp** tool parses the ``.w`` file, and performs the tangle and weave operations.
It *tangles* each individual output file from the program source chunks.
It *weaves* the final documentation file file from the entire sequence of chunks provided, mixing the author's  original documentation with some markup around the embedded program source.

Concepts
---------

The ``.w`` file has two tiers of markup in it.

-   At the top, a file will have **py-web-lp** markup to distinguish
    documentation chunks from code chunks. 
    
-   Within the documentation chunks, there can be markup for the target publication tool chain.
    This might be RST, LaTeX, HTML, or some other markup language.
    
The **py-web-lp** markup decomposes the source document a sequence of *Chunks*.

..  uml::

    object web
    object chunk
    object documentation
    object "source code" as code
    
    web *-- chunk
    chunk *-- documentation
    chunk *-- code

The chunks have the following two overall sets of features:
 
-   Program source code to be *tangled* and *woven*. There are two important varieties:

    -   "defined" chunks that have names,
    -   "output" chunks that lead to writing a tangled file.

    Output chunks can have references to defined code chunks defined anywhere else in the web file.
    This permits tangling output files in a compiler-friendly order, separate from a sensible presentation order.

-   Documentation to be *woven*.  These are the blocks of text between commands.

The bulk of the file is typically documentation chunks that describe the program in
some publication-oriented markup language like RST, HTML, or LaTeX.

All code chunks have two transformations applied:

- When Tangling, the indentation is adjusted to match the context in which they were originally defined. 
  This assures that Python (which relies on indentation) parses correctly.
  For other languages, proper indentation is expected but not required.

- When Weaving, selected characters can be quoted so they don't break the publication tool.
  For HTML, ``&``, ``<``, ``>`` are quoted properly.
  For LaTeX, a few escapes are used to avoid problems with the ``fancyvrb`` environment.

The non-code documentation chunks are not transformed up in any way.
Everything that's not explicitly a code chunk is output without modification.

All of the **py-web-lp** tags begin with ``@@``.
This is sometimes called the command prefix.
(This can be changed.)
The tags were historically referred to as "commands."
For Python code using decorators, the symbol must be doubled, ``@@@@``, because all ``@@`` symbols are commands, irrespective of context.

The *Structural* tags (historically called "major commands") partition the input and define the various chunks.
The *Inline* tags are (called "minor commands") are used to control the woven and tangled output from the defined chunks.
There are *Content* tags which generate  summary cross-reference content in woven files.

Boilerplate
-----------

There is some mandatory "boilerplate" required to make a working document.
Requirements vary by markup language.

LaTeX
~~~~~

The LaTeX templates use ``\\fancyvrb``.
The following is required.

::

    \\usepackage{fancyvrb}

Some minimal boilerplate document looks like this:

..  parsed-literal::
    
    \\documentclass{article}
    \\usepackage{fancyvrb}
    \\title{ *Title* }
    \\author{ *Author* }
    
    \\begin{document}
    
    \\maketitle
    \\tableofcontents

    *Your Document Starts Here*

    \\end{document}

HTML
~~~~

There's often a fairly large amount of HTML boilerplate.
Currently, the templates used do **not** provide any CSS classes.
For more sophisticated HTML documents, it may be necessary to
provide customized templates with CSS classes to make the 
document look good.

Structural Tags
---------------

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

``@@d`` *options* *name* ``@@{`` *text* ``@@}``

    The ``@@d`` (define) command defines a named chunk of program source. 
    This text is tangled or woven when it is referenced by the *reference* inline tag.
    
    The ``-indent`` and ``-noindent`` options specify the indentation for this particular chunk.
    In rare cases, it can be helpful to override the indentation context.

    The ``-style *name*`` option specifies a parameter that's provided to the ``begin_code()`` and ``end_code()`` macro.
    This permits a macro to fine-tune the presentation for a specific chunk.
    This can help when writing LaTeX that has a mixture of example block styles.

    A special case extension uses ``@@[`` and ``@@]`` to bracket text instead of program source. A *reference* tag can expand this somewhere else in the text.
    It's not clear what the use case for this is.

Each ``@@o`` and ``@@d`` tag is followed by a chunk which is delimited by ``@@{`` and ``@@}`` tags.
At the end of that chunk, there is an optional "major" tag.  

``@@|``

    A chunk may define user identifiers.
    The list of defined identifiers is placed in the chunk, separated by the ``@@|`` separator.
    This is used to create the index material.


Additionally, these tags provide for the inclusion of additional input files.
This is necessary for decomposing a long document into easy-to-edit sections.

``@@i`` *file*

    The ``@@i`` (include) command includes another file.  The previous chunk
    is ended.  The file is processed completely, then a new chunk
    is started for the text after the ``@@i`` command.

All material that is not explicitly in a ``@@o`` or ``@@d`` named chunk is implicitly collected into a sequence of anonymous document source chunks.
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

This starts with an anonymous chunk of documentation.
It includes a named output chunk which will write to ``myFile.py``.
It ends with an anonymous chunk of documentation.

Inline Tags
---------------

There are several tags that are replaced by content in the woven output.

``@@@@``

    The ``@@@@`` command creates a single ``@@`` in the output file.
    This is replaced in tangled as well as woven output.

``@@<``\ *name*\ ``@@>``

    The *name* references a named chunk.
    When tangling, the referenced chunk replaces the reference tag.
    When weaving, a reference marker is used.
    For example, in RST, this can be replaced with RST ```reference`_`` markup.
    Note that the indentation prior to the ``@@<`` tag is preserved for the tangled chunk that replaces the tag.


``@@(``\ *Python expression*\ ``@@)``

    The *Python expression* is evaluated and the result is tangled or woven in place.
    A few global variables and modules are available.
    These are described in `Expression Context`_.

Content Tags
---------------

There are three index creation tags that are replaced by content in the woven output.


``@@f``

    The ``@@f`` command inserts a file cross reference.
    This lists the name of each file created by an ``@@o`` command, and all of the various chunks that are concatenated to create this file.

``@@m``

    The ``@@m`` command inserts a named chunk ("macro") cross reference.
    This lists the name of each chunk created by a ``@@d`` command, and all of the various chunks that are concatenated to create the complete chunk.

``@@u``

    The ``@@u`` command inserts a user identifier cross reference. 
    This index lists the name of each chunk created by an ``@@d`` command or ``@@|``, 
    and all of the various chunks that are concatenated to create the complete chunk.


Additional Features
-------------------

**Sequence Numbers**. The named chunks (from both ``@@o`` and ``@@d`` commands) are assigned 
unique sequence numbers to simplify cross references.  

**Case Sensitive**. Chunk names and file names are case sensitive.

**Abbreviations**. Chunk names can be abbreviated.
A partial name can have a trailing ellipsis (``...``), this will be resolved to the full name.
The most typical use for this is shown in the following example:

..  parsed-literal::

    Some RST-format documentation.

    @@o myFile.py 
    @@{
    @@<imports of the various packages used@@>
    print(math.pi,time.time())
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

2.  A named chunk that tangles the ``myFile.py`` output.
    It has a reference to the ``imports of the various packages used`` chunk.
    Note that the full name of the chunk is essentially a line of  documentation,
    traditionally done as a comment line in a non-literate programming environment.

3.  An anonymous chunk of documentation.

4.  A named chunk with an abbreviated name.
    The ``imports...`` reference matches the defined name ``imports of the various packages used``.
    Set off after the ``@@|`` separator is the list of user-specified identifiers defined in this chunk.

5.  An anonymous chunk of documentation.

Note that the first time a name appears (in a reference or definition), it **must** be the full name.
All subsequent uses can be elisions.
Also not that ambiguous elision is an annoying problem when you first start creating a document.

**Concatenation**. Named chunks are concatenated from their various pieces.
This allows a named chunk to be broken into several pieces, simplifying the description.
This is most often used when producing  fairly complex output files.

..  parsed-literal::

    An anonymous chunk with some RST documentation.

    @@o myFile.py 
    @@{
    import math, time
    @@}

    Some notes on the packages used.

    @@o myFile.py
    @@{
    print(math.pi, time.time())
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
In all of the above examples, each named chunk was defined with the following.

..  parsed-literal::

    @@{
    import math, time
    @@}

This puts a newline character before and after the import line.

Controlling Indentation
-----------------------

We have two choices in indentation:

-   Context-Sensitive.

-   Consistent.

If we have context-sensitive indentation, then the indentation of a chunk reference  is applied to the entire chunk when expanded in place of the reference.
This makes it simpler to prepare source for languages (like Python) where indentation is important.

There are cases, however, when this is not desirable.
There are some places in Python where we want to create long, triple-quoted strings with indentation that does not follow the prevailing indentations of the surrounding code.

Here's how the context-sensitive indentation works.

..  parsed-literal::

    @@o myFile.py 
    @@{
    def aFunction(a, b):
        @@<body of aFunction@@>
    @@| aFunction @@}

    @@d body...
    @@{
    """doc string"""
    return a + b
    @@}

The ``@@<body of aFunction@@>`` command is indented.
The tangled output from this will look like the following.
All of the newline characters are preserved, and the reference to *body of the aFunction* is indented to match the prevailing indent where it was referenced.
In the following example,  explicit line markers of ``~`` are provided to make the blank lines  more obvious.

..  parsed-literal::

    ~
    ~def aFunction(a, b):
    ~        
    ~    """doc string"""
    ~    return a + b
    ~

[The ``@@|`` command shows that this chunk defines the identifier ``aFunction``.]

This leads to the use of "options" for some commands.
This seems to go against the utter simplicity we're cribbing from **noweb**.

The syntax to define a section the will not the indentation context applied looks like this:
    
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
    
The ``-noindent`` section will be included by resetting the contextual indentation to zero.
The *First partial line* line will be output after the four spaces
provided by the ``some bigger chunk`` context. 

After the first newline, the remaining lines will be at the left margin.

Tracking Source Line Numbers
----------------------------

Since the tangled output files are -- well -- tangled, it can be difficult to
trace back from a Python error stack to the original line in the ``.w`` file that
needs to be fixed.
To facilitate this, there is a two-step operation to get more detailed information
on how tangling worked.

1.  Use the ``-n`` command-line option to include line numbers in the tangled output.

2.  Include comment indicators on the ``@@o`` commands to show what comment syntax is used.

The expanded syntax for ``@@o`` looks like this.

..  parsed-literal::

    @@o -start /* -end \*/ page-layout.css
    @@{
    *Some CSS code*
    @@}
    
We've added two options: ``-start /*`` and ``-end */`` to define comment start and end syntax.
This will lead to comments embedded in the tangled output to show source line numbers for every (every!) chunk.

Expression Context
-------------------

Expressions are evaluated as they are encountered during input parsing.
They produce a ``TextCommand`` in the current ``Chunk``.
This means a limited context is available for the Python expression.

The context has the following variables defined.

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
    The name of the running **py-web-lp** application. It may not be pyweb.py,
    if some other script is being used.

:__version__:
    The version string in the **py-web-lp** application.
