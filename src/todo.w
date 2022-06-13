..    py-web-tool/src/todo.w 

 
To Do
=======

1.  Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
    Rename the project from ``py-web-tool`` to ``py-lpweb``.
    
2.  Switch to jinja templates.

    -   See the ``weave.py`` example. 
        Defining templates in the source removes any need for a command-line option. A silly optimization.
        Setting the "command character" to something other than ``@@`` can be done in the configuration, too.

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
    
#.  Update the ``-indent`` option on @@d chunks to accept a numeric argument with the 
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
    leads to the question of why nest ``@@d`` or ``@@o`` chunks in the first place?
