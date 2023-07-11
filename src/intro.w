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

**py-web-lp** is a literate programming tool that combines the actions
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

The immediate predecessors to this **py-web-lp** tool are
`FunnelWeb <http://www.ross.net/funnelweb>`_,
`noweb <http://www.eecs.harvard.edu/~nr/noweb/>`_ and 
`nuweb <http://sourceforge.net/projects/nuweb/>`_.  The ideas lifted from these other
tools created the foundation for **py-web-lp**.

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

The *PyLit-3* tool is perhaps the very best approach to Literate
programming, since it leverages an existing lightweight markup language
and it's output formatting. However, it's limited in the presentation order,
making it difficult to present a complex Python module out of the proper
Python required presentation.

**py-web-lp**
---------------

**py-web-lp** works with any
programming language. It can work with any markup language, but is currently
configured to work with RST.  This philosophy
comes from *FunnelWeb*
*noweb*, *nuweb* and *interscript*.  The primary differences
between **py-web-lp** and other tools are the following.

-   **py-web-lp** is object-oriented, permitting easy extension.
    *noweb* extensions
    are separate processes that communicate through a sophisticated protocol.
    *nuweb* is not easily extended without rewriting and recompiling
    the C programs.

-   **py-web-lp** is built in the very portable Python programming
    language.  This allows it to run anywhere that Python 3.3 runs, with
    only the addition of docutils.  This makes it a useful
    tool for programmers in any language.

-   **py-web-lp** is much simpler than *FunnelWeb*, *LEO* or *Interscript*.  It has
    a very limited selection of commands, but can still produce 
    complex programs and HTML documents.

-   **py-web-lp** does not invent a complex markup language like *Interscript*.
    Because *Iterscript* has its own markup, it can generate L\ :sub:`a`\ T\ :sub:`e`\ X or HTML or other
    output formats from a unique input format.  While powerful, it seems simpler to
    avoid inventing yet another sophisticated markup language.  The language **py-web-lp**
    uses is very simple, and the author's use their preferred markup language almost
    exclusively.

-   **py-web-lp** supports the forward literate programming philosophy,
    where a source document creates programming language and markup language.
    The alternative, deriving the document from markup embedded in 
    program comments ("inverted literate programming"), seems less appealing.
    The disadvantage of inverted literate programming is that the final document
    can't reflect the original author's preferred order of exposition,
    since that informtion generally isn't part of the source code.

-   **py-web-lp** also specifically rejects some features of *nuweb*
    and *FunnelWeb*.  These include the macro capability with parameter
    substitution, and multiple references to a chunk.  These two capabilities
    can be used to grow object-like applications from non-object programming
    languages (*e.g.* C or Pascal).  Since most modern languages (Python,
    Java, C++) are object-oriented, this macro capability is more of a problem
    than a help.

-   Since **py-web-lp** is built in the Python interpreter, a source document
    can include Python expressions that are evaluated during weave operation to
    produce time stamps, source file descriptions or other information in the woven 
    or tangled output.


**py-web-lp** works with any programming language; it can work with any markup language.
The initial release supports RST via simple templates.

The following is extensively quoted from Briggs' *nuweb* documentation, 
and provides an excellent background in the advantages of the very
simple approach started by *nuweb* and adopted by **py-web-lp**.

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
        Since [**py-web-lp**] doesn't do too much, it runs very quickly.
        It combines the functions of ``tangle`` and ``weave`` into a single 
        program that performs both functions at once.

    :Chunk numbers:
        Inspired by the example of **noweb**, [**py-web-lp**] refers to all program code
        chunks by a simple, ascending sequence number through the file.  
        This becomes the HTML anchor name, also.

    :Multiple file output:
        The programmer may specify more than one output file in a single [**py-web-lp**]
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
