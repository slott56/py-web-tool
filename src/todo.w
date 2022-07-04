..    py-web-tool/src/todo.w 

 
To Do
=======

1.  Add a docutils plug-in for PlantUML. See https://gist.github.com/mastbaum/2655700 and https://plantuml.com/docutils.
    
#.  Separate TOML-based logging configuration file would be helpful. 
    Must be separate from template configuration.

#.  Tangling can include non-woven content. More usefully, Weaving can exclude some chunks.
    The use case is a book chapter with test cases that are **not** woven into the text.
    Add an option to define tangle-only chunks that are NOT woven into the final document. 
    
#.  Update the ``-indent`` option on @@d chunks to accept a numeric argument with the 
    specific indentation value. This becomes a kind of "noindent" with a given
    value. The ``-noindent`` would then be the same as ``-indent 0``.  
    Currently, `-indent` and `-noindent` are true/false flags. 
    
#.  We might want to decompose the ``impl.w`` file: it's huge.

#.  We might want to interleave code and test into a document that presents both
    side-by-side. We can route the tangled code to multiple files.
    It can be awkward to create tangled files in multiple directories, however.
    We'd have to use ``../tests/whatever.py``, **assuming** we were always using ``-o src``.

#.  Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
    Rename the project from ``py-web-tool`` to ``py-lpweb``.
    
#.  Offer a basic XHTML template that uses ``CDATA`` sections instead of quoting.
    Does require the standard quoting for the ``CDATA`` end tag.
    
#.  Note that the overall ``Web`` is a bit like a ``NamedChunk`` that contains ``Chunks``.
    This similarity could be factored out. 
    While this will create a more proper **Composition** pattern implementation, it
    leads to the question of why nest ``@@d`` or ``@@o`` chunks in the first place?
