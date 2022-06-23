############################################
pyWeb Literate Programming 3.2 - Test Suite
############################################    
    
    
=================================================
Yet Another Literate Programming Tool
=================================================

..	include:: <isoamsa.txt>
..	include:: <isopub.txt>

..	contents::


Introduction
============

..	test/intro.w 

There are two levels of testing in this document.

-	`Unit Testing`_

-	`Functional Testing`_

Other testing, like performance or security, is possible.
But for this application, not very interesting.

This doument builds a complete test suite, ``test.py``.

..	parsed-literal::

	MacBookPro-SLott:test slott$ python3.3 ../pyweb.py pyweb_test.w
	INFO:Application:Setting root log level to 'INFO'
	INFO:Application:Setting command character to '@'
	INFO:Application:Weaver RST
	INFO:Application:load, tangle and weave 'pyweb_test.w'
	INFO:LoadAction:Starting Load
	INFO:WebReader:Including 'intro.w'
	WARNING:WebReader:Unknown @-command in input: "@'"
	INFO:WebReader:Including 'unit.w'
	INFO:WebReader:Including 'func.w'
	INFO:WebReader:Including 'combined.w'
	INFO:TangleAction:Starting Tangle
	INFO:TanglerMake:Tangling 'test_unit.py'
	INFO:TanglerMake:No change to 'test_unit.py'
	INFO:TanglerMake:Tangling 'test_loader.py'
	INFO:TanglerMake:No change to 'test_loader.py'
	INFO:TanglerMake:Tangling 'test.py'
	INFO:TanglerMake:No change to 'test.py'
	INFO:TanglerMake:Tangling 'page-layout.css'
	INFO:TanglerMake:No change to 'page-layout.css'
	INFO:TanglerMake:Tangling 'docutils.conf'
	INFO:TanglerMake:No change to 'docutils.conf'
	INFO:TanglerMake:Tangling 'test_tangler.py'
	INFO:TanglerMake:No change to 'test_tangler.py'
	INFO:TanglerMake:Tangling 'test_weaver.py'
	INFO:TanglerMake:No change to 'test_weaver.py'
	INFO:WeaveAction:Starting Weave
	INFO:RST:Weaving 'pyweb_test.rst'
	INFO:RST:Wrote 3173 lines to 'pyweb_test.rst'
	INFO:WeaveAction:Finished Normally
	INFO:Application:Load 1911 lines from 5 files in 0.05 sec., Tangle 138 lines in 0.03 sec., Weave 3173 lines in 0.02 sec.
	MacBookPro-SLott:test slott$ PYTHONPATH=.. python3.3 test.py
	ERROR:WebReader:At ('test8_inc.tmp', 4): end of input, ('@{', '@[') not found
	ERROR:WebReader:Errors in included file test8_inc.tmp, output is incomplete.
	.ERROR:WebReader:At ('test1.w', 8): expected ('@{',), found '@o'
	ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)
	ERROR:WebReader:Extra '@{' (possibly missing chunk name) near ('test1.w', 9)
	.............................................................................
	----------------------------------------------------------------------
	Ran 78 tests in 0.025s

	OK
	MacBookPro-SLott:test slott$ rst2html.py pyweb_test.rst pyweb_test.html


Unit Testing
============

..    test/unit.w 

There are several broad areas of unit testing.  There are the 34 classes in this application.
However, it isn't really necessary to test everyone single one of these classes.
We'll decompose these into several hierarchies.


-    Emitters
    
        class Emitter:  
        
        class Weaver(Emitter):  
        
        class LaTeX(Weaver):  
        
        class HTML(Weaver):  
        
        class HTMLShort(HTML):  
        
        class Tangler(Emitter):  
        
        class TanglerMake(Tangler):  
    
    
-    Structure: Chunk, Command
    
        class Chunk:  
        
        class NamedChunk(Chunk):  

        class NamedChunk_Noindent(Chunk):  
        
        class OutputChunk(NamedChunk):  
        
        class NamedDocumentChunk(NamedChunk):  
                
        class Command:  
        
        class TextCommand(Command):  
        
        class CodeCommand(TextCommand):  
        
        class XrefCommand(Command):  
        
        class FileXrefCommand(XrefCommand):  
        
        class MacroXrefCommand(XrefCommand):  
        
        class UserIdXrefCommand(XrefCommand):  
        
        class ReferenceCommand(Command):  
    
    
-    class Error(Exception):   
    
-    Reference Handling
    
        class Reference:  
        
        class SimpleReference(Reference):  
        
        class TransitiveReference(Reference):  
    
    
-    class Web:  

-    class WebReader:  

        class Tokenizer:
        
        class OptionParser:
    
-    Action
    
        class Action:  
        
        class ActionSequence(Action):  
        
        class WeaveAction(Action):  
        
        class TangleAction(Action):  
        
        class LoadAction(Action):  
    
    
-    class Application:  
    
-    class MyWeaver(HTML):  
    
-    class MyHTML(pyweb.HTML):


This gives us the following outline for unit testing.


..  _`None (1)`:
..  rubric:: test_unit.py (1) =
..  parsed-literal::
    :class: code

        
    →\ `Unit Test overheads: imports, etc. (43)`_→\ `Unit Test of Emitter class hierarchy (2)`_→\ `Unit Test of Chunk class hierarchy (11)`_→\ `Unit Test of Command class hierarchy (23)`_→\ `Unit Test of Reference class hierarchy (32)`_→\ `Unit Test of Web class (33)`_→\ `Unit Test of WebReader class (34)`_→\ `Unit Test of Action class hierarchy (37)`_→\ `Unit Test of Application class (42)`_→\ `Unit Test main (45)`_
        
..

..  class:: small

    ∎ *None (1)*



Emitter Tests
-------------

The emitter class hierarchy produces output files; either woven output
which uses templates to generate proper markup, or tangled output which
precisely follows the document structure.



..  _`Unit Test of Emitter class hierarchy (2)`:
..  rubric:: Unit Test of Emitter class hierarchy... (2) =
..  parsed-literal::
    :class: code

        
    →\ `Unit Test Mock Chunk class (4)`_→\ `Unit Test of Emitter Superclass (3)`_→\ `Unit Test of Weaver subclass of Emitter (5)`_→\ `Unit Test of LaTeX subclass of Emitter (6)`_→\ `Unit Test of HTML subclass of Emitter (7)`_→\ `Unit Test of HTMLShort subclass of Emitter (8)`_→\ `Unit Test of Tangler subclass of Emitter (9)`_→\ `Unit Test of TanglerMake subclass of Emitter (10)`_
        
..

..  class:: small

    ∎ *Unit Test of Emitter class hierarchy (2)*



The Emitter superclass is designed to be extended.  The test 
creates a subclass to exercise a few key features. The default
emitter is Tangler-like.


..  _`Unit Test of Emitter Superclass (3)`:
..  rubric:: Unit Test of Emitter Superclass... (3) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Emitter Superclass (3)*



A mock Chunk is a Chunk-like object that we can use to test Weavers.

Some tests will create multiple chunks. To keep their state separate,
we define a function to return each mocked ``Chunk`` instance as a new Mock
object. The overall ``MockChunk`` class, uses a side effect to 
invoke the the ``mock_chunk_instance()`` function.

The ``write_closure()`` is a function that calls the ``Tangler.write()`` 
method. This is *not* consistent with best unit testing practices.
It is merely a hold-over from an older testing strategy. The mock call
history to the ``tangle()`` method of each ``Chunk`` instance is a better
test strategy. 

**TODO:** Simplify the following definition. A great deal of these features are legacy definitions.


..  _`Unit Test Mock Chunk class (4)`:
..  rubric:: Unit Test Mock Chunk... (4) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test Mock Chunk class (4)*



The default Weaver is an Emitter that uses templates to produce RST markup.


..  _`Unit Test of Weaver subclass of Emitter (5)`:
..  rubric:: Unit Test of Weaver... (5) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Weaver subclass of Emitter (5)*



A significant fraction of the various subclasses of weaver are simply
expansion of templates.  There's no real point in testing the template
expansion, since that's more easily tested by running a document
through pyweb and looking at the results.

We'll examine a few features of the LaTeX templates.


..  _`Unit Test of LaTeX subclass of Emitter (6)`:
..  rubric:: Unit Test of LaTeX... (6) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of LaTeX subclass of Emitter (6)*



We'll examine a few features of the HTML templates.


..  _`Unit Test of HTML subclass of Emitter (7)`:
..  rubric:: Unit Test of HTML subclass... (7) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of HTML subclass of Emitter (7)*



The unique feature of the ``HTMLShort`` class is a template change.

    **TODO:** Test ``HTMLShort``.


..  _`Unit Test of HTMLShort subclass of Emitter (8)`:
..  rubric:: Unit Test of HTMLShort subclass... (8) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of HTMLShort subclass of Emitter (8)*



A Tangler emits the various named source files in proper format for the desired
compiler and language.


..  _`Unit Test of Tangler subclass of Emitter (9)`:
..  rubric:: Unit Test of Tangler subclass... (9) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Tangler subclass of Emitter (9)*



A TanglerMake uses a cheap hack to see if anything changed.
It creates a temporary file and then does a complete (slow, expensive) file difference
check.  If the file is different, the old version is replaced with 
the new version.  If the file content is the same, the old version
is left intact with all of the operating system creation timestamps
untouched.





..  _`Unit Test of TanglerMake subclass of Emitter (10)`:
..  rubric:: Unit Test of TanglerMake subclass... (10) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of TanglerMake subclass of Emitter (10)*



Chunk Tests
------------

The Chunk and Command class hierarchies model the input document -- the web
of chunks that are used to produce the documentation and the source files.



..  _`Unit Test of Chunk class hierarchy (11)`:
..  rubric:: Unit Test of Chunk class hierarchy... (11) =
..  parsed-literal::
    :class: code

        
    →\ `Unit Test of Chunk superclass (12)`_→\ `Unit Test of NamedChunk subclass (19)`_→\ `Unit Test of NamedChunk_Noindent subclass (20)`_→\ `Unit Test of OutputChunk subclass (21)`_→\ `Unit Test of NamedDocumentChunk subclass (22)`_
        
..

..  class:: small

    ∎ *Unit Test of Chunk class hierarchy (11)*



In order to test the Chunk superclass, we need several mock objects.
A Chunk contains one or more commands.  A Chunk is a part of a Web.
Also, a Chunk is processed by a Tangler or a Weaver.  We'll need 
mock objects for all of these relationships in which a Chunk participates.

A MockCommand can be attached to a Chunk.


..  _`Unit Test of Chunk superclass (12)`:
..  rubric:: Unit Test of Chunk superclass... (12) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk superclass (12)*



A MockWeb can contain a Chunk.


..  _`Unit Test of Chunk superclass (13)`:
..  rubric:: Unit Test of Chunk superclass... (13) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk superclass (13)*



A MockWeaver or MockTangler appear to process a Chunk.
We can interrogate the ``mock_calls`` to be sure the right things were done.

We need to permit ``__enter__()`` and ``__exit__()``,
which leads to a multi-step instance.
The initial instance with ``__enter__()`` that
returns the context manager instance.



..  _`Unit Test of Chunk superclass (14)`:
..  rubric:: Unit Test of Chunk superclass... (14) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk superclass (14)*



A Chunk is built, interrogated and then emitted.


..  _`Unit Test of Chunk superclass (15)`:
..  rubric:: Unit Test of Chunk superclass... (15) =
..  parsed-literal::
    :class: code

        
    →\ `Unit Test of Chunk construction (16)`_→\ `Unit Test of Chunk interrogation (17)`_→\ `Unit Test of Chunk properties (18)`_
        
..

..  class:: small

    ∎ *Unit Test of Chunk superclass (15)*



Can we build a Chunk?


..  _`Unit Test of Chunk construction (16)`:
..  rubric:: Unit Test of Chunk construction... (16) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk construction (16)*



Can we interrogate a Chunk?


..  _`Unit Test of Chunk interrogation (17)`:
..  rubric:: Unit Test of Chunk interrogation... (17) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk interrogation (17)*



Can we emit a Chunk with a weaver or tangler?


..  _`Unit Test of Chunk properties (18)`:
..  rubric:: Unit Test of Chunk properties... (18) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Chunk properties (18)*



The ``NamedChunk`` is created by a ``@d`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks.


..  _`Unit Test of NamedChunk subclass (19)`:
..  rubric:: Unit Test of NamedChunk subclass... (19) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of NamedChunk subclass (19)*




..  _`Unit Test of NamedChunk_Noindent subclass (20)`:
..  rubric:: Unit Test of NamedChunk_Noindent subclass... (20) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of NamedChunk_Noindent subclass (20)*




The ``OutputChunk`` is created by a ``@o`` command.
Since it's named, it appears in the Web's index.  Also, it is woven
and tangled differently than anonymous chunks of text.
This defines the files of tangled code. 


..  _`Unit Test of OutputChunk subclass (21)`:
..  rubric:: Unit Test of OutputChunk subclass... (21) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of OutputChunk subclass (21)*



The ``NamedDocumentChunk`` is a way to define substitutable text, similar to
tabled code, but it applies to document chunks. It's not clear how useful this really
is.


..  _`Unit Test of NamedDocumentChunk subclass (22)`:
..  rubric:: Unit Test of NamedDocumentChunk subclass... (22) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of NamedDocumentChunk subclass (22)*



Command Tests
---------------


..  _`Unit Test of Command class hierarchy (23)`:
..  rubric:: Unit Test of Command class hierarchy... (23) =
..  parsed-literal::
    :class: code

        
    →\ `Unit Test of Command superclass (24)`_→\ `Unit Test of TextCommand class to contain a document text block (25)`_→\ `Unit Test of CodeCommand class to contain a program source code block (26)`_→\ `Unit Test of XrefCommand superclass for all cross-reference commands (27)`_→\ `Unit Test of FileXrefCommand class for an output file cross-reference (28)`_→\ `Unit Test of MacroXrefCommand class for a named chunk cross-reference (29)`_→\ `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30)`_→\ `Unit Test of ReferenceCommand class for chunk references (31)`_
        
..

..  class:: small

    ∎ *Unit Test of Command class hierarchy (23)*



This Command superclass is essentially an inteface definition, it
has no real testable features.


..  _`Unit Test of Command superclass (24)`:
..  rubric:: Unit Test of Command superclass... (24) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Command superclass (24)*



A ``TextCommand`` object must be built from source text, interrogated, and emitted.
A ``TextCommand`` should not (generally) be created in a ``Chunk``, it should
only be part of a ``NamedChunk`` or ``OutputChunk``.


..  _`Unit Test of TextCommand class to contain a document text block (25)`:
..  rubric:: Unit Test of TextCommand class... (25) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of TextCommand class to contain a document text block (25)*



A ``CodeCommand`` object is a ``TextCommand`` with different processing for being emitted.
It represents a block of code in a ``NamedChunk`` or ``OutputChunk``. 


..  _`Unit Test of CodeCommand class to contain a program source code block (26)`:
..  rubric:: Unit Test of CodeCommand class... (26) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of CodeCommand class to contain a program source code block (26)*



An ``XrefCommand`` class (if defined) would be abstract. We could formalize this,
but it seems easier to have a collection of ``@dataclass`` definitions a 
``Union[...]`` type hint.



..  _`Unit Test of XrefCommand superclass for all cross-reference commands (27)`:
..  rubric:: Unit Test of XrefCommand superclass... (27) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of XrefCommand superclass for all cross-reference commands (27)*



The ``FileXrefCommand`` command is expanded by a weaver to a list of ``@o``
locations.


..  _`Unit Test of FileXrefCommand class for an output file cross-reference (28)`:
..  rubric:: Unit Test of FileXrefCommand class... (28) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of FileXrefCommand class for an output file cross-reference (28)*



The ``MacroXrefCommand`` command is expanded by a weaver to a list of all ``@d``
locations.


..  _`Unit Test of MacroXrefCommand class for a named chunk cross-reference (29)`:
..  rubric:: Unit Test of MacroXrefCommand class... (29) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of MacroXrefCommand class for a named chunk cross-reference (29)*



The ``UserIdXrefCommand`` command is expanded by a weaver to a list of all ``@|``
names.


..  _`Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30)`:
..  rubric:: Unit Test of UserIdXrefCommand class... (30) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30)*



Instances of the ``Reference`` command reflect ``@< name @>`` locations in code.
These require a context when tangling.
The context helps provide the required indentation.
They can't be simply tangled, since the expand to code that may (transitively) 
have more references to more code.

The document here is a mock-up of the following

..  parsed-literal::

    @d name @{ @<Some Name@> @}
    
    @d Some Name @{ code @}
    
This is a single Chunk with a reference to another Chunk.

The ``Web`` class ``__post_init__`` sets the references and referencedBy attributes of each Chunk.


..  _`Unit Test of ReferenceCommand class for chunk references (31)`:
..  rubric:: Unit Test of ReferenceCommand class... (31) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of ReferenceCommand class for chunk references (31)*



Reference Tests
----------------

The Reference class implements one of two search strategies for 
cross-references.  Either simple (or "immediate") or transitive.

The superclass is little more than an interface definition,
it's completely abstract.  The two subclasses differ in 
a single method.

The test fixture is this

..  parsed-literal::

    @d main @{ @< parent @> @}
    
    @d parent @{ @< sub @> @}
    
    @d sub @{ something @}
    
The ``sub`` item is used by ``parent`` which is used by ``main``.

The simple reference is ``sub`` referenced by ``parent``.

The transitive references are ``sub`` referenced by ``parent`` which is referenced by ``main``.



..  _`Unit Test of Reference class hierarchy (32)`:
..  rubric:: Unit Test of Reference class hierarchy... (32) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Reference class hierarchy (32)*



Web Tests
-----------

We create a ``Web`` instance with mocked Chunks and mocked Commands.
The point is to test the ``Web`` features in isolation. This is tricky
because some state is recorded in the Chunk instances.


..  _`Unit Test of Web class (33)`:
..  rubric:: Unit Test of Web class... (33) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Web class (33)*





WebReader Tests
----------------

Generally, this is tested separately through the functional tests.
Those tests each present source files to be processed by the
WebReader.

We should test this through some clever mocks that produce the
proper sequence of tokens to parse the various kinds of Commands.


..  _`Unit Test of WebReader class (34)`:
..  rubric:: Unit Test of WebReader... (34) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of WebReader class (34)*



Some lower-level units: specifically the tokenizer and the option parser.


..  _`Unit Test of WebReader class (35)`:
..  rubric:: Unit Test of WebReader... (35) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of WebReader class (35)*




..  _`Unit Test of WebReader class (36)`:
..  rubric:: Unit Test of WebReader... (36) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of WebReader class (36)*




Action Tests
-------------

Each class is tested separately.  Sequence of some mocks, 
load, tangle, weave.  


..  _`Unit Test of Action class hierarchy (37)`:
..  rubric:: Unit Test of Action class hierarchy... (37) =
..  parsed-literal::
    :class: code

        
    →\ `Unit test of Action Sequence class (38)`_→\ `Unit test of LoadAction class (41)`_→\ `Unit test of TangleAction class (40)`_→\ `Unit test of WeaverAction class (39)`_
        
..

..  class:: small

    ∎ *Unit Test of Action class hierarchy (37)*



**TODO:** Replace with Mock


..  _`Unit test of Action Sequence class (38)`:
..  rubric:: Unit test of Action Sequence class... (38) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit test of Action Sequence class (38)*




..  _`Unit test of WeaverAction class (39)`:
..  rubric:: Unit test of WeaverAction class... (39) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit test of WeaverAction class (39)*




..  _`Unit test of TangleAction class (40)`:
..  rubric:: Unit test of TangleAction class... (40) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit test of TangleAction class (40)*



The mocked ``WebReader`` must provide an ``errors`` property to the ``LoadAction`` instance.


..  _`Unit test of LoadAction class (41)`:
..  rubric:: Unit test of LoadAction class... (41) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit test of LoadAction class (41)*



Application Tests
------------------

As with testing WebReader, this requires extensive mocking.
It's easier to simply run the various use cases.

**TODO:** Test Application class


..  _`Unit Test of Application class (42)`:
..  rubric:: Unit Test of Application... (42) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test of Application class (42)*



Overheads and Main Script
--------------------------

The boilerplate code for unit testing is the following.


..  _`Unit Test overheads: imports, etc. (43)`:
..  rubric:: Unit Test overheads... (43) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test overheads: imports, etc. (43)*



One more overhead is a function we can inject into selected subclasses
of ``unittest.TestCase``. This is monkeypatch feature that seems useful.


..  _`Unit Test overheads: imports, etc. (44)`:
..  rubric:: Unit Test overheads... (44) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test overheads: imports, etc. (44)*




..  _`Unit Test main (45)`:
..  rubric:: Unit Test main... (45) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Unit Test main (45)*



We run the default ``unittest.main()`` to execute the entire suite of tests.


Functional Testing
==================

.. test/func.w

There are three broad areas of functional testing.

-   `Tests for Loading`_

-   `Tests for Tangling`_

-   `Tests for Weaving`_

There are a total of 11 test cases.

Tests for Loading
------------------

We need to be able to load a web from one or more source files.


..  _`None (46)`:
..  rubric:: test_loader.py (46) =
..  parsed-literal::
    :class: code

        
    →\ `Load Test overheads: imports, etc. (48)`_→\ `Load Test superclass to refactor common setup (47)`_→\ `Load Test error handling with a few common syntax errors (49)`_→\ `Load Test include processing with syntax errors (51)`_→\ `Load Test main program (54)`_
        
..

..  class:: small

    ∎ *None (46)*



Parsing test cases have a common setup shown in this superclass.

By using some class-level variables ``text``,
``file_path``, we can simply provide a file-like
input object to the ``WebReader`` instance.


..  _`Load Test superclass to refactor common setup (47)`:
..  rubric:: Load Test superclass... (47) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Load Test superclass to refactor common setup (47)*



There are a lot of specific parsing exceptions which can be thrown.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.


..  _`Load Test overheads: imports, etc. (48)`:
..  rubric:: Load Test overheads... (48) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Load Test overheads: imports, etc. (48)*




..  _`Load Test error handling with a few common syntax errors (49)`:
..  rubric:: Load Test error handling... (49) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 1 with correct and incorrect syntax (50)`_
        
..

..  class:: small

    ∎ *Load Test error handling with a few common syntax errors (49)*




..  _`Sample Document 1 with correct and incorrect syntax (50)`:
..  rubric:: Sample Document 1... (50) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 1 with correct and incorrect syntax (50)*



All of the parsing exceptions should be correctly identified with
any included file.
We'll cover most of the cases with a quick check for a failure to 
find an expected next token.

In order to test the include file processing, we have to actually
create a temporary file.  It's hard to mock the include processing,
since it's a nested instance of the tokenizer.


..  _`Load Test include processing with syntax errors (51)`:
..  rubric:: Load Test include... (51) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 8 and the file it includes (52)`_
        
..

..  class:: small

    ∎ *Load Test include processing with syntax errors (51)*



The sample document must reference the correct name that will
be given to the included document by ``setUp``.


..  _`Sample Document 8 and the file it includes (52)`:
..  rubric:: Sample Document 8... (52) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 8 and the file it includes (52)*



<p>The overheads for a Python unittest.</p>


..  _`Load Test overheads: imports, etc. (53)`:
..  rubric:: Load Test overheads... (53) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Load Test overheads: imports, etc. (53)*



A main program that configures logging and then runs the test.


..  _`Load Test main program (54)`:
..  rubric:: Load Test main program... (54) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Load Test main program (54)*



Tests for Tangling
------------------

We need to be able to tangle a web.


..  _`None (55)`:
..  rubric:: test_tangler.py (55) =
..  parsed-literal::
    :class: code

        
    →\ `Tangle Test overheads: imports, etc. (69)`_→\ `Tangle Test superclass to refactor common setup (56)`_→\ `Tangle Test semantic error 2 (57)`_→\ `Tangle Test semantic error 3 (59)`_→\ `Tangle Test semantic error 4 (61)`_→\ `Tangle Test semantic error 5 (63)`_→\ `Tangle Test semantic error 6 (65)`_→\ `Tangle Test include error 7 (67)`_→\ `Tangle Test main program (70)`_
        
..

..  class:: small

    ∎ *None (55)*



Tangling test cases have a common setup and teardown shown in this superclass.
Since tangling must produce a file, it's helpful to remove the file that gets created.
The essential test case is to load and attempt to tangle, checking the 
exceptions raised.



..  _`Tangle Test superclass to refactor common setup (56)`:
..  rubric:: Tangle Test superclass... (56) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Tangle Test superclass to refactor common setup (56)*




..  _`Tangle Test semantic error 2 (57)`:
..  rubric:: Tangle Test semantic error 2... (57) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 2 (58)`_
        
..

..  class:: small

    ∎ *Tangle Test semantic error 2 (57)*




..  _`Sample Document 2 (58)`:
..  rubric:: Sample Document 2... (58) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 2 (58)*




..  _`Tangle Test semantic error 3 (59)`:
..  rubric:: Tangle Test semantic error 3... (59) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 3 (60)`_
        
..

..  class:: small

    ∎ *Tangle Test semantic error 3 (59)*




..  _`Sample Document 3 (60)`:
..  rubric:: Sample Document 3... (60) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 3 (60)*





..  _`Tangle Test semantic error 4 (61)`:
..  rubric:: Tangle Test semantic error 4... (61) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 4 (62)`_
        
..

..  class:: small

    ∎ *Tangle Test semantic error 4 (61)*




..  _`Sample Document 4 (62)`:
..  rubric:: Sample Document 4... (62) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 4 (62)*




..  _`Tangle Test semantic error 5 (63)`:
..  rubric:: Tangle Test semantic error 5... (63) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 5 (64)`_
        
..

..  class:: small

    ∎ *Tangle Test semantic error 5 (63)*




..  _`Sample Document 5 (64)`:
..  rubric:: Sample Document 5... (64) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 5 (64)*




..  _`Tangle Test semantic error 6 (65)`:
..  rubric:: Tangle Test semantic error 6... (65) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 6 (66)`_
        
..

..  class:: small

    ∎ *Tangle Test semantic error 6 (65)*




..  _`Sample Document 6 (66)`:
..  rubric:: Sample Document 6... (66) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 6 (66)*




..  _`Tangle Test include error 7 (67)`:
..  rubric:: Tangle Test include error 7... (67) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 7 and it's included file (68)`_
        
..

..  class:: small

    ∎ *Tangle Test include error 7 (67)*




..  _`Sample Document 7 and it's included file (68)`:
..  rubric:: Sample Document 7... (68) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 7 and it's included file (68)*




..  _`Tangle Test overheads: imports, etc. (69)`:
..  rubric:: Tangle Test overheads... (69) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Tangle Test overheads: imports, etc. (69)*




..  _`Tangle Test main program (70)`:
..  rubric:: Tangle Test main program... (70) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Tangle Test main program (70)*




Tests for Weaving
-----------------

We need to be able to weave a document from one or more source files.


..  _`None (71)`:
..  rubric:: test_weaver.py (71) =
..  parsed-literal::
    :class: code

        
    →\ `Weave Test overheads: imports, etc. (78)`_→\ `Weave Test superclass to refactor common setup (72)`_→\ `Weave Test references and definitions (73)`_→\ `Weave Test evaluation of expressions (76)`_→\ `Weave Test main program (79)`_
        
..

..  class:: small

    ∎ *None (71)*



Weaving test cases have a common setup shown in this superclass.


..  _`Weave Test superclass to refactor common setup (72)`:
..  rubric:: Weave Test superclass... (72) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Weave Test superclass to refactor common setup (72)*




..  _`Weave Test references and definitions (73)`:
..  rubric:: Weave Test references... (73) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 0 (74)`_→\ `Expected Output 0 (75)`_
        
..

..  class:: small

    ∎ *Weave Test references and definitions (73)*




..  _`Sample Document 0 (74)`:
..  rubric:: Sample Document 0... (74) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 0 (74)*




..  _`Expected Output 0 (75)`:
..  rubric:: Expected Output 0... (75) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Expected Output 0 (75)*



Note that this really requires a mocked ``time`` module in order
to properly provide a consistent output from ``time.asctime()``.


..  _`Weave Test evaluation of expressions (76)`:
..  rubric:: Weave Test evaluation... (76) =
..  parsed-literal::
    :class: code

        
    →\ `Sample Document 9 (77)`_
        
..

..  class:: small

    ∎ *Weave Test evaluation of expressions (76)*




..  _`Sample Document 9 (77)`:
..  rubric:: Sample Document 9... (77) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample Document 9 (77)*




..  _`Weave Test overheads: imports, etc. (78)`:
..  rubric:: Weave Test overheads... (78) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Weave Test overheads: imports, etc. (78)*




..  _`Weave Test main program (79)`:
..  rubric:: Weave Test main program... (79) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Weave Test main program (79)*




Additional Scripts Testing
==========================

.. test/scripts.w

We provide these two additional scripts; effectively command-line short-cuts:

-   ``tangle.py``

-   ``weave.py``

These need their own test cases.


This gives us the following outline for the script testing.


..  _`None (80)`:
..  rubric:: test_scripts.py (80) =
..  parsed-literal::
    :class: code

        
    →\ `Script Test overheads: imports, etc. (85)`_→\ `Sample web file to test with (81)`_→\ `Superclass for test cases (82)`_→\ `Test of weave.py (83)`_→\ `Test of tangle.py (84)`_→\ `Scripts Test main (86)`_
        
..

..  class:: small

    ∎ *None (80)*



Sample Web File
---------------

This is a web ``.w`` file to create a document and tangle a small file.


..  _`Sample web file to test with (81)`:
..  rubric:: Sample web file... (81) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Sample web file to test with (81)*



Superclass for test cases
-------------------------

This superclass definition creates a consistent test fixture for both test cases.
The sample ``test_sample.w`` file is created and removed after the test.


..  _`Superclass for test cases (82)`:
..  rubric:: Superclass... (82) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Superclass for test cases (82)*



Weave Script Test
-----------------

We check the weave output to be sure it's what we expected. 
This could be altered to check a few features of the weave file rather than compare the entire file.


..  _`Test of weave.py (83)`:
..  rubric:: Test of weave.py (83) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Test of weave.py (83)*



Tangle Script Test
------------------

We check the tangle output to be sure it's what we expected. 


..  _`Test of tangle.py (84)`:
..  rubric:: Test of tangle.py (84) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Test of tangle.py (84)*



Overheads and Main Script
--------------------------

This is typical of the other test modules. We provide a unittest runner 
here in case we want to run these tests in isolation.


..  _`Script Test overheads: imports, etc. (85)`:
..  rubric:: Script Test overheads... (85) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Script Test overheads: imports, etc. (85)*




..  _`Scripts Test main (86)`:
..  rubric:: Scripts Test main... (86) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *Scripts Test main (86)*



We run the default ``unittest.main()`` to execute the entire suite of tests.


No Longer supported: @i runner.w, using **pytest** seems better.

Additional Files
=================

To get the RST to look good, there are two additional files.
These are clones of what's in the ``src`` directory.

``docutils.conf`` defines two CSS files to use.
	The default CSS file may need to be customized.


..  _`None (87)`:
..  rubric:: docutils.conf (87) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *None (87)*



``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. These are minor
tweaks to the default CSS.


..  _`None (88)`:
..  rubric:: page-layout.css (88) =
..  parsed-literal::
    :class: code

        
    
        
..

..  class:: small

    ∎ *None (88)*




Indices
=======

Files
-----

:test_unit.py:
    →\ `None (1)`_:test_loader.py:
    →\ `None (46)`_:test_tangler.py:
    →\ `None (55)`_:test_weaver.py:
    →\ `None (71)`_:test_scripts.py:
    →\ `None (80)`_:docutils.conf:
    →\ `None (87)`_:page-layout.css:
    →\ `None (88)`_

Macros
------

:Expected Output 0:
    →\ `Expected Output 0 (75)`_

:Load Test error handling with a few common syntax errors:
    →\ `Load Test error handling with a few common syntax errors (49)`_

:Load Test include processing with syntax errors:
    →\ `Load Test include processing with syntax errors (51)`_

:Load Test main program:
    →\ `Load Test main program (54)`_

:Load Test overheads: imports, etc.:
    →\ `Load Test overheads: imports, etc. (48)`_, →\ `Load Test overheads: imports, etc. (53)`_

:Load Test superclass to refactor common setup:
    →\ `Load Test superclass to refactor common setup (47)`_

:Sample Document 0:
    →\ `Sample Document 0 (74)`_

:Sample Document 1 with correct and incorrect syntax:
    →\ `Sample Document 1 with correct and incorrect syntax (50)`_

:Sample Document 2:
    →\ `Sample Document 2 (58)`_

:Sample Document 3:
    →\ `Sample Document 3 (60)`_

:Sample Document 4:
    →\ `Sample Document 4 (62)`_

:Sample Document 5:
    →\ `Sample Document 5 (64)`_

:Sample Document 6:
    →\ `Sample Document 6 (66)`_

:Sample Document 7 and it's included file:
    →\ `Sample Document 7 and it's included file (68)`_

:Sample Document 8 and the file it includes:
    →\ `Sample Document 8 and the file it includes (52)`_

:Sample Document 9:
    →\ `Sample Document 9 (77)`_

:Sample web file to test with:
    →\ `Sample web file to test with (81)`_

:Script Test overheads: imports, etc.:
    →\ `Script Test overheads: imports, etc. (85)`_

:Scripts Test main:
    →\ `Scripts Test main (86)`_

:Superclass for test cases:
    →\ `Superclass for test cases (82)`_

:Tangle Test include error 7:
    →\ `Tangle Test include error 7 (67)`_

:Tangle Test main program:
    →\ `Tangle Test main program (70)`_

:Tangle Test overheads: imports, etc.:
    →\ `Tangle Test overheads: imports, etc. (69)`_

:Tangle Test semantic error 2:
    →\ `Tangle Test semantic error 2 (57)`_

:Tangle Test semantic error 3:
    →\ `Tangle Test semantic error 3 (59)`_

:Tangle Test semantic error 4:
    →\ `Tangle Test semantic error 4 (61)`_

:Tangle Test semantic error 5:
    →\ `Tangle Test semantic error 5 (63)`_

:Tangle Test semantic error 6:
    →\ `Tangle Test semantic error 6 (65)`_

:Tangle Test superclass to refactor common setup:
    →\ `Tangle Test superclass to refactor common setup (56)`_

:Test of tangle.py:
    →\ `Test of tangle.py (84)`_

:Test of weave.py:
    →\ `Test of weave.py (83)`_

:Unit Test Mock Chunk class:
    →\ `Unit Test Mock Chunk class (4)`_

:Unit Test main:
    →\ `Unit Test main (45)`_

:Unit Test of Action class hierarchy:
    →\ `Unit Test of Action class hierarchy (37)`_

:Unit Test of Application class:
    →\ `Unit Test of Application class (42)`_

:Unit Test of Chunk class hierarchy:
    →\ `Unit Test of Chunk class hierarchy (11)`_

:Unit Test of Chunk construction:
    →\ `Unit Test of Chunk construction (16)`_

:Unit Test of Chunk interrogation:
    →\ `Unit Test of Chunk interrogation (17)`_

:Unit Test of Chunk properties:
    →\ `Unit Test of Chunk properties (18)`_

:Unit Test of Chunk superclass:
    →\ `Unit Test of Chunk superclass (12)`_, →\ `Unit Test of Chunk superclass (13)`_, →\ `Unit Test of Chunk superclass (14)`_, →\ `Unit Test of Chunk superclass (15)`_

:Unit Test of CodeCommand class to contain a program source code block:
    →\ `Unit Test of CodeCommand class to contain a program source code block (26)`_

:Unit Test of Command class hierarchy:
    →\ `Unit Test of Command class hierarchy (23)`_

:Unit Test of Command superclass:
    →\ `Unit Test of Command superclass (24)`_

:Unit Test of Emitter Superclass:
    →\ `Unit Test of Emitter Superclass (3)`_

:Unit Test of Emitter class hierarchy:
    →\ `Unit Test of Emitter class hierarchy (2)`_

:Unit Test of FileXrefCommand class for an output file cross-reference:
    →\ `Unit Test of FileXrefCommand class for an output file cross-reference (28)`_

:Unit Test of HTML subclass of Emitter:
    →\ `Unit Test of HTML subclass of Emitter (7)`_

:Unit Test of HTMLShort subclass of Emitter:
    →\ `Unit Test of HTMLShort subclass of Emitter (8)`_

:Unit Test of LaTeX subclass of Emitter:
    →\ `Unit Test of LaTeX subclass of Emitter (6)`_

:Unit Test of MacroXrefCommand class for a named chunk cross-reference:
    →\ `Unit Test of MacroXrefCommand class for a named chunk cross-reference (29)`_

:Unit Test of NamedChunk subclass:
    →\ `Unit Test of NamedChunk subclass (19)`_

:Unit Test of NamedChunk_Noindent subclass:
    →\ `Unit Test of NamedChunk_Noindent subclass (20)`_

:Unit Test of NamedDocumentChunk subclass:
    →\ `Unit Test of NamedDocumentChunk subclass (22)`_

:Unit Test of OutputChunk subclass:
    →\ `Unit Test of OutputChunk subclass (21)`_

:Unit Test of Reference class hierarchy:
    →\ `Unit Test of Reference class hierarchy (32)`_

:Unit Test of ReferenceCommand class for chunk references:
    →\ `Unit Test of ReferenceCommand class for chunk references (31)`_

:Unit Test of Tangler subclass of Emitter:
    →\ `Unit Test of Tangler subclass of Emitter (9)`_

:Unit Test of TanglerMake subclass of Emitter:
    →\ `Unit Test of TanglerMake subclass of Emitter (10)`_

:Unit Test of TextCommand class to contain a document text block:
    →\ `Unit Test of TextCommand class to contain a document text block (25)`_

:Unit Test of UserIdXrefCommand class for a user identifier cross-reference:
    →\ `Unit Test of UserIdXrefCommand class for a user identifier cross-reference (30)`_

:Unit Test of Weaver subclass of Emitter:
    →\ `Unit Test of Weaver subclass of Emitter (5)`_

:Unit Test of Web class:
    →\ `Unit Test of Web class (33)`_

:Unit Test of WebReader class:
    →\ `Unit Test of WebReader class (34)`_, →\ `Unit Test of WebReader class (35)`_, →\ `Unit Test of WebReader class (36)`_

:Unit Test of XrefCommand superclass for all cross-reference commands:
    →\ `Unit Test of XrefCommand superclass for all cross-reference commands (27)`_

:Unit Test overheads: imports, etc.:
    →\ `Unit Test overheads: imports, etc. (43)`_, →\ `Unit Test overheads: imports, etc. (44)`_

:Unit test of Action Sequence class:
    →\ `Unit test of Action Sequence class (38)`_

:Unit test of LoadAction class:
    →\ `Unit test of LoadAction class (41)`_

:Unit test of TangleAction class:
    →\ `Unit test of TangleAction class (40)`_

:Unit test of WeaverAction class:
    →\ `Unit test of WeaverAction class (39)`_

:Weave Test evaluation of expressions:
    →\ `Weave Test evaluation of expressions (76)`_

:Weave Test main program:
    →\ `Weave Test main program (79)`_

:Weave Test overheads: imports, etc.:
    →\ `Weave Test overheads: imports, etc. (78)`_

:Weave Test references and definitions:
    →\ `Weave Test references and definitions (73)`_

:Weave Test superclass to refactor common setup:
    →\ `Weave Test superclass to refactor common setup (72)`_



User Identifiers
----------------


            

----------

..	class:: small

	Created by src/pyweb.py at Thu Jun 23 15:30:46 2022.

    Source tests/pyweb_test.w modified Sat Jun 18 11:00:51 2022.

	pyweb.__version__ '3.2'.

	Working directory '/Users/slott/Documents/Projects/py-web-tool'.
