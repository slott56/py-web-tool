..    py-web-tool/src/todo.w 
..  _todo:
 
To Do
=======

Additional Features for 3.3
---------------------------

For writing books, we need a number of new features.

[x] Implement ``@@o`` command with a ``-noweave`` option.
    Tangling will always create all files.
    Weaving will ignore this file, producing **no** output for this ``@@o``.

    The use case is a book chapter with numerous examples in the text.
    The resulting ``*.py`` or ``*.txt`` file is not shown in all of it's glorious detail.
    This file is tangled, so the code examples can be wrapped with test cases,
    but this file is not described anywhere.
    See https://github.com/slott56/py-web-tool/wiki/Tangle-only-Output.

[x] Refactor options parsers into class ``OutputChunk`` or ``NamedChunk``, removing them from the ``WebReader`` ``handleCommand()`` method.

[x] Refactor macro definitions and the override rules.
    Remove the limited two-tier overrides done via Jinja ``{% if %}`` constructs.
    Build a ``ChainMap`` of all macro definitions in priority order.
    The ordering is [``@@t macro``, ``config.macros``, app overrides, app defaults].
    Then, reduce the chain map to a single list of the highest-priority definitions of each macro.
    From this list, build a final macro template for the loader.

    This enables ``@@t macro`` and config-file macro definition.

[x] Refactor config file and CLI argument processing.
    This can make it easier to use the config file to define macro overrides.

[x] Use additional ``style`` attribute of a ``NamedChunk`` in the  ``begin_code()`` template.
    Source syntax uses an option to set the ``style`` attribute: ``@@d -style console`` or ``@@d -style code``.
    This updates the ``NamedChunk`` parameter parsing and the templates.

    The use case is a book chapter with distinct formatting for REPL examples and code examples.
    It may be as small as CSS classes for RST or HTML.
    It may be a more elaborate set of differences in LaTeX.

[x] Provide ``latex-minted`` (and ``tex-minted``) macros.
    Also ``latex-verbatim`` (and ``tex-verbatim``) macros.
    Make minted the default.

[x] Accept macro definitions from the configuration file.

Other Extensions for 3.4
------------------------

1.  Implement ``@@t`` command to define template macros.
    Add feature to ``Web`` to find the macro definitions.
    Add feature to ``Weaver`` initialization.

    A ``@@t macro @@{`` *jinja* ``@@}`` command will add a new macro to the list of macros to use for the current weaving language.
    The **Jinja** code **must** be of the form ``{% macro name(args) %}...{% endmacro %}``,
    The ``name`` must be one of the pre-defined names, or it won't be used by the base weaver template.

    Also. character quote rules can be defined as part of a template. These rules will **replace** the default rules.

    ..  code-block:: jinja

        @@t macro @@{
            {%- macro begin_code(chunk) %}
            ...
            {%- endmacro -%}
        @@}
        @@t macro @@{
            {%- macro end_code(chunk) %}
            ...
            {%- endmacro -%}
        @@}
        @@t quote @@{
            "_": "\_"
        @@}

1.  Fully support ``Tangler.include_line_numbers``.
    This updates the ``codeBlock()`` method to
    Stuff in a comment.

    The comment start and comment end options
    could use Jinja macros, but, a document
    often has multiple languages, making this risky.

1.  Implement all four alternative references in the ``end_code()`` macro.

    -   Nothing. 

    -   The immediate reference. 

    -   The two variants on full paths: 

        -   top-down ``→ Named (1) / → Sub-Named (2) / → Sub-Sub-Named (3)``

        -   bottom-up ``→ Sub-Sub-Named (3) ∈ → Sub-Named (2) ∈ → Named (1)``

    Provide needed parameters to configure the ``Weaver`` with one of these choices.
    It seems burdensome to require a full macro definition in the config TOML file or as a ``@@t macro`` command.

#.  Update the ``-indent`` option on ``@@d`` chunks to accept a numeric argument with the specific indentation value.
    This becomes a kind of "noindent" with a given value; ``-noindent`` is short-hand for ``-indent 0``.
    Currently, `-indent` and `-noindent` are true/false flags.

    The complication is that ``-indent`` without a value becomes difficult to implement with ``argparse``.

#.  More gracefully handle the case where an output chunk has a multi-part definition.
    For example,

    ..  parsed-literal::

        @@o x.y
        @@{
        ... part 1 ...
        @@}

        @@o x.y
        @@{
        ... part 2 ...
        @@}

    The above should have the same output as the following (more complex) alternative:

    ..  parsed-literal::

        @@o x.y
        @@{
        @@<part 1@@>
        @@<part 2@@>
        @@}

        @@d part 1
        @@{
        ... part 1 ...
        @@}

        @@d part 2
        @@{
        ... part 2 ...
        @@}

    Currently, we casually treat the first instance as the "definition", and don't provide clear references to the additional parts of the definition.


#.  Upgrade ``Chunk`` to recursively examine each ``Command`` for RE patterns. ``find_iter(re)``.
    Build ``has_any(re)`` as an ``any()`` reduction of ``Command`` instances.

#.  Upgrade ``Command`` to examine each line of text for an RE pattern. ``find_iter(re)``

Some additional ideas
---------------------

1.  Push ``TypeId`` meta-class into ``Chunk`` hierarchy?
    Would this break the ``@@dataclass`` nature?

#.  We might want to decompose the ``impl.w`` file: it's huge.
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
