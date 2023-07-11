..    py-web-tool/src/todo.w 

 
To Do
======= 
   
1.  Change the comment start and comment end options
    to use Jinja template fragments.
    There needs to be an ``-add '# {{chunk.position}}'``
    which overrides the default of ``''`` and injects
    this into each Tangled chunk. Indented appropriately.
    
1.  Implement all four alternative references in the ``end_code()`` macro.

    -   Nothing. 

    -   The immediate reference. 

    -   The two variants on full paths: 

        -   top-down ``→ Named (1) / → Sub-Named (2) / → Sub-Sub-Named (3)``

        -   bottom-up ``→ Sub-Sub-Named (3) ∈ → Sub-Named (2) ∈ → Named (1)``

#.  Implement ``@@h`` command and ``HiddenOutputChunk``. This may be sufficient.
    Tangling can then include non-woven output files. 
    Viewed the other way, Weaving can exclude the non-woven file.
    The use case is a book chapter with test cases that are **not** woven into the text.
    See https://github.com/slott56/py-web-tool/wiki/Tangle-only-Output.
       
#.  Permit selecting a specific ``begin_code()`` template for a named block. 
    A book may have distinct formatting for REPL examples and code examples.
    It may be as small as CSS classes for RST or HTML. It may be a more elaborate
    set of differences in LaTeX.

#.  Update the ``-indent`` option on ``@@d`` chunks to accept a numeric argument with the 
    specific indentation value. This becomes a kind of "noindent" with a given
    value. The ``-noindent`` would then be the same as ``-indent 0``.  
    Currently, `-indent` and `-noindent` are true/false flags. 
    
#.  We might want to decompose the ``impl.w`` file: it's huge.
    The four major sections -- base model, output, input parsing, other components -- make sense.
    However, since the output is a *single* .rst file, it doesn't change much to do this.

#.  We might want to interleave code and test into a document that presents both
    side-by-side. We can route the tangled code to multiple files.
    It can be awkward to create tangled files in multiple directories, however.
    We'd have to use ``../tests/whatever.py``, **assuming** we were always using ``-o src``.

#.  Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
    Rename the project from ``py-web-lp`` to ``py-lpweb``.
    
#.  Offer a basic XHTML template that uses ``CDATA`` sections instead of quoting.
    Does require the standard quoting for the ``CDATA`` end tag.
    
#.  Note that the overall ``Web`` is a bit like a ``NamedChunk`` that contains ``Chunks``.
    This similarity could be factored out. 
    While this will create a more proper **Composition** pattern implementation, it
    leads to the question of why nest ``@@d`` or ``@@o`` chunks in the first place?
