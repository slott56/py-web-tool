..    py-web-tool/src/todo.w 
..  _todo:
 
To Do
=======

Restructuring
-------------

Additional Features
-------------------

For writing books, we need two features.

1.  Select one of several alternative ``begin_code()`` templates for a named block display.
    This could be as sumple as ``@@d -style console`` or ``@@d -style code``.

    The use case is a book chapter with distinct formatting for REPL examples and code examples.
    It may be as small as CSS classes for RST or HTML.
    It may be a more elaborate set of differences in LaTeX.

#.  Implement ``@@o`` command with a ``-noweave`` option.
    Tangling will create files.
    Weaving will ignore this file, producing **no** output.

    The use case is a book chapter with numerous examples in the text, but the resulting ``*.py`` or ``*.txt`` file isn't shown in all of it's glorious detail.
    This file is tangled, so the code examples can be tested, but this file is not described anywhere.
    See https://github.com/slott56/py-web-tool/wiki/Tangle-only-Output.


Other Extensions
----------------------
   
1.  Change the comment start and comment end options
    to use Jinja template fragments instead of simple text.
    There needs to be an ``-add '# {{chunk.position}}'``
    which overrides the default of ``''`` and injects
    this into each Tangled chunk. Indented appropriately.
    
1.  Implement all four alternative references in the ``end_code()`` macro.

    -   Nothing. 

    -   The immediate reference. 

    -   The two variants on full paths: 

        -   top-down ``→ Named (1) / → Sub-Named (2) / → Sub-Sub-Named (3)``

        -   bottom-up ``→ Sub-Sub-Named (3) ∈ → Sub-Named (2) ∈ → Named (1)``

#.  Add commands to define templates in the ``.w`` file.

    The current templates are defaults.
    Additional ``@@t`` commands define the wrappers applied to ``@@d`` and ``@@o`` commands.
    The character replacement rules need to be defined as part of the template.
    Each template has 3 parts:

    -   Pre-code

    -   Replacement Rules

    -   Post-code

    This -- in effect -- is a ``macro(chunk, rule)`` operation in Jinja.
    The macro writes the beginning, applies the rewrite rule to each piece of text, and writes the ending for the code block.

#.  Update the ``-indent`` option on ``@@d`` chunks to accept a numeric argument with the 
    specific indentation value. This becomes a kind of "noindent" with a given
    value. The ``-noindent`` would then be the same as ``-indent 0``.  
    Currently, `-indent` and `-noindent` are true/false flags. 

Some additional ideas
---------------------

1.  We might want to decompose the ``impl.w`` file: it's huge.
    The four major sections -- base model, output, input parsing, other components -- make sense.
    However, since the output is a *single* ``.rst`` file, it doesn't change much to do this.

#.  Rename the module from ``pyweb`` to ``pylpweb`` to avoid name squatting issues.
    Rename the project from ``py-web-lp`` to ``py-lpweb``.
    
#.  Offer a basic XHTML template that uses ``CDATA`` sections instead of quoting.
    Does require the standard quoting for the ``CDATA`` end tag.
    
#.  Note that the overall ``Web`` is a bit like a ``NamedChunk`` that contains ``Chunks``.
    This similarity could be factored out. 
    While this will create a more proper **Composition** pattern implementation, it
    leads to the question of why nest ``@@d`` or ``@@o`` chunks in the first place?

From the code
-------------

..  todolist::
