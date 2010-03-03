<!-- pyweb/overview.w -->

<p>This application breaks the overall problem into the following sub-problems.</p>
<ol>
<li>Repesentation of the Web as Chunks and Commands</li>
<li>Reading and parsing the input.</li>
<li>Weaving a document file.</li>
<li>Tangling the desired program source files.</li>
</ol>

<h2>Representation</h2>
<p>The basic "parse tree" is actually quite flat.  The source document can be
decomposed into a simple sequence of Chunks.  Each Chunk is a simple sequence
of Commands.</p>
<p>Chunks and commands cannot be nested, leading to delightful simplification.</p>

<p>The overall parse "tree" is contained in the overall <b>Web</b>.  The web
includes the sequence of Chunks as well as an index for the Named chunks.
</p>
<p>Note that a named chunk may be created through a number of <tt>@@d</tt> commands.
This means that
Each named chunk may be a sequence of Chunks with a common name.
</p>
<p>Each chunk is composed of a sequence of instances of <b>Command</b>.  
Because of this uniform composition, the several operations (particularly
weave and tangle) can be 
delegated to each Chunk, and in turn, delegated to each Command that
composes a Chunk.
</p>

<h2>Reading and Parsing</h2>
<p>A solution to the reading and parsing problem depends on a convenient 
tool for breaking up the input stream and a representation for the chunks of input.
Input decomposition is done with the Python <b>Splitter</b> pattern. 
</p>
<p>The Splitter pattern is widely used in text processing, and has a long legacy
in a variety of languages and libraries.  A Splitter decomposes a string into
a sequence of strings using the split pattern.  There are many variant implementations.
One variant locates only a single occurence (usually the left-most); this is
commonly implemented as a Find or Search string function.  Another variant locates all
occurrences of a specific string or character, and discards the matching string or
character.
</p>
<p>
The variation on Splitter that we use in this application
creates each element in the resulting sequence as either (1) an instance of the 
split regular expression or (2) the text between split patterns.  By preserving 
the actual split text, we can define our splitting pattern with the regular
expression <tt>'@@.'</tt>.  This will split on any <tt>@@</tt> followed by a single character.
We can then examine the instances of the split RE to locate pyWeb commands.
</p>
<p>We could be a tad more specific and use the following as a split pattern:
<tt>'@@[doOifmu|<>(){}[\]]'</tt>.  This would silently ignore unknown commands, 
merging them in with the surrounding text.  This would leave the <tt>'@@@@'</tt> sequences 
completely alone, allowing us to replace <tt>'@@@@'</tt> with <tt>'@@'</tt> in
every text chunk.
</p>

<h2>Weaving</h2>
<p>The weaving operation depends on the target document markup language.
There are several approaches to this problem.  One is to use a markup language
unique to <em>pyWeb</em>, and emit markup in the desired target language.
Another is to use a standard markup language and use converters to transform
the standard markup to the desired target markup.  The problem with the second
method is specifying the markup for actual source code elements in the
document.  These must be emitted in the proper markup language.
</p>
<p>Since the application must transform input into a specific markup language,
we opt using the Strategy pattern to encapsulate markup language details.
Each alternative markup strategy is then a subclass of <b>Weaver</b>.  This 
simplifies adding additional markup languages without inventing a 
markup language unique to <em>pyWeb</em>.
The author uses their preferred markup, and their preferred
toolset to convert to other output languages.
</p>

<h2>Tangling</h2>
<p>The tangling operation produces output files.  In earlier tools,
some care was taken to understand the source code context for tangling, and
provide a correct indentation.  This required a command-line parameter
to turn off indentation for languages like Fortran, where identation
is not used.  In <em>pyWeb</em>, the indent of
the actual <tt>@@&lt;</tt> command is used to set the indent of the 
material that follows.  If all <tt>@@&lt;</tt> commands are presented at the
left margin, no indentation will be done.  This is helpful simplification,
particularly for users of Python, where indentation is significant.
</p>
<p>The standard <b>Emitter</b> class handles this basic indentation.  A subclass can be 
created, if necessary, to handle more elaborate indentation rules.</p>