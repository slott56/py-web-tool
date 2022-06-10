..    py-web-tool/todo.w 

Python 3.10 Migration
=====================


1. [x] Add type hints.

#. [x] Replace all ``.format()`` with f-strings.

#. [x] Replace filename strings (and ``os.path``) with ``pathlib.Path``.

#. [x] Add ``abc`` to formalize Abstract Base Classes.

#. [x] Use ``match`` statements for some of the ``elif`` blocks.

#. [x] Introduce pytest instead of building a test runner from ``runner.w``.

#. [ ] ``pyproject.toml``. This requires ```-o dir`` option to write output to a directory of choice; which requires ``pathlib``.
 
#. [ ] Rename the module from ``pyweb`` to ``pylpweb`` to avoid namespace squatting issues.
       Rename the project from ``py-web-tool`` to ``py-lpweb-tool``.

#. [ ] Replace various mock classes with ``unittest.mock.Mock`` objects and appropriate extended testing.

 
To Do
=======
    
1.  Silence the ERROR-level logging during testing.

2.  Silence the error when creating an empty file i.e. ``.nojekyll``

#.  Add a JSON-based (or TOML) configuration file to configure templates.

    -   See the ``weave.py`` example. 
        This removes any need for a weaver command-line option; its defined within the source.
        Also, setting the command character can be done in this configuration, too.

    -   An alternative is to get markup templates from some kind of "header" section in the ``.w`` file.  

        To support reuse over multiple projects, a header could be included with ``@@i``.
        The downside is that we have a lot of variable = value syntax that makes it
        more like a properties file than a ``.w`` syntax file. It seems needless to invent 
        a lot of new syntax just for configuration.

#.  JSON-based logging configuration file would be helpful. 
    Should be separate from template configuration.

#.  We might want to decompose the ``impl.w`` file: it's huge.
    
#.  We might want to interleave code and test into a document that presents both
    side-by-side. They get routed to different output files.

#.  Fix name definition order. There's no **good** reason why a full name should
    be first and elided names defined later.

#.  Add a ``@@h`` "header goes here" command to allow weaving any **pyWeb** required addons to 
    a LaTeX header, HTML header or RST header.
    These are extra ``..  include::``, ``\\usepackage{fancyvrb}`` or maybe an HTML CSS reference
    that come from **pyWeb** and need to be folded into otherwise boilerplate documents.
    
#.  Update the ``-indent`` option to accept a numeric argument with the 
    specific indentation value. This becomes a kind of "noindent" with a given
    value. The ``-noindent`` would then be the same as ``-indent 0``.
    
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

Other Thoughts
----------------

There are two possible projects that might prove useful.

-   Jinja2 for better templates.

-   pyYAML for slightly cleaner encoding of logging configuration
    or other configuration.

There are advantages and disadvantages to depending on other projects. 
The disadvantage is a (very low, but still present) barrier to adoption. 
The advantage of adding these two projects might be some simplification.
