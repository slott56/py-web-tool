.. pyweb/overview.w 

Architecture and Design Overview
================================

This application breaks the overall problem into the following sub-problems.

1.	Representation of the Web as Chunks and Commands

2.	Reading and parsing the input.

3.	Weaving a document file.

4. 	Tangling the desired program source files.


Representation
---------------

The basic parse tree has three layers. The source document is transformed into a web, 
which is the overall container. The source is
decomposed into a simple sequence of Chunks.  Each Chunk is a simple sequence
of Commands.

Chunks and Commands cannot be nested, leading to delightful simplification.

The overall Web
includes the sequence of Chunks as well as an index for the named chunks.

Note that a named chunk may be created through a number of ``@@d`` commands.
This means that
each named chunk may be a sequence of Chunks with a common name.

Because a Chunk is composed of a sequence Commands, the weave and tangle actions can be 
delegated to each Chunk, and in turn, delegated to each Command that
composes a Chunk.

There is a small interaction between Tanglers and Chunks to work out the indentation.
Otherwise, the output and input work is largely independent of the Web itself.


Reading and Parsing
--------------------

A solution to the reading and parsing problem depends on a convenient 
tool for breaking up the input stream and a representation for the chunks of input.
Input decomposition is done with the Python Splitter pattern. 

The **Splitter** pattern is widely used in text processing, and has a long legacy
in a variety of languages and libraries.  A Splitter decomposes a string into
a sequence of strings using the split pattern.  There are many variant implementations.
One variant locates only a single occurence (usually the left-most); this is
commonly implemented as a Find or Search string function.  Another variant locates all
occurrences of a specific string or character, and discards the matching string or
character.

The variation on **Splitter** that we use in this application
creates each element in the resulting sequence as either (1) an instance of the 
split regular expression or (2) the text between split patterns.  

We define our splitting pattern with the regular
expression ``'@@.|\n'``.  This will split on either of these patterns:

-	 ``@@`` followed by a single character,

-	or, a newline.

For the most part, ``\n`` is just text. The exception is the 
``@@i`` *filename* command, which ends at the end of the line, making the ``\n``
significant syntax.

We could be a tad more specific and use the following as a split pattern:
``'@@[doOifmu\|<>(){}\[\]]|\n'``.  This would silently ignore unknown commands, 
merging them in with the surrounding text.  This would leave the ``'@@@@'`` sequences 
completely alone, allowing us to replace ``'@@@@'`` with ``'@@'`` in
every text chunk.

Within the ``@@d`` and ``@@o`` commands, we also parse options. These follow
the syntax rules for Tcl or the shell. Optional fields are prefaced with ``-``.
All options come before all positional arguments. 

Weaving
---------

The weaving operation depends on the target document markup language.
There are several approaches to this problem.  

-	We can use a markup language unique to **pyWeb**, 
	and weave using markup in the desired target language.
	
-	We can use a standard markup language and use converters to transform
	the standard markup to the desired target markup. We could adopt
	XML or RST or some other generic markup that can be converted.
	
The problem with the second method is the mixture of background document
in some standard markup and the code elements, which need to be bracketed 
with common templates. We hate to repeat these templates; that's the
job of a literate programming tool. Also, certain code characters must
be properly escaped.

Since **pyWeb** must transform the code into a specific markup language,
we opt using a **Strategy** pattern to encapsulate markup language details.
Each alternative markup strategy is then a subclass of **Weaver**.  This 
simplifies adding additional markup languages without inventing a 
markup language unique to **pyWeb**.
The author uses their preferred markup, and their preferred
toolset to convert to other output languages.

The templates used to wrap code sections can be tweaked relatively easily.


Tangling
----------

The tangling operation produces output files.  In other tools,
some care was taken to understand the source code context for tangling, and
provide a correct indentation.  This required a command-line parameter
to turn off indentation for languages like Fortran, where identation
is not used.  

In **pyWeb**, there are two options. The default behavior is that the
indent of a ``@@<`` command is used to set the indent of the 
material is expanded in place of this reference.  If all ``@@<`` commands are presented at the
left margin, no indentation will be done.  This is helpful simplification,
particularly for users of Python, where indentation is significant.

In rare cases, we might need both, and a ``@@d`` chunk can override the indentation
rule to force the material to be placed at the left margin.

Application
------------

The overall application has two layers to it. There are actions (Load, Tangle, Weave)
as well as a top-level application that parses the command line, creates
and configures the actions, and then closes up shop when all done.

The idea is that the Weaver Action should fit with SCons Builder.
We can see ``Weave( "someFile.w" )`` as sensible.  Tangling is tougher
because the ``@@o`` commands define the file dependencies there.  