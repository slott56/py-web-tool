\documentclass{article}
\usepackage{fancyvrb}
\title{Test Program}
\author{Jason R. Fruit}

\begin{document}

\maketitle
\tableofcontents

\section{Introduction}

This test program prints the word ``hello'', followed by the name of
the operating system as understood by Python.  It is implemented in
Python and uses the \texttt{os} module.  It builds the message string
in two different ways, and writes separate versions of the program to
two different files.

\section{Implementation}

\subsection{Output files}

This document contains the makings of two files; the first,
\texttt{test.py}, uses simple string concatenation to build its output
message:

@o test.py
@{
@< Import the os module @>
@< Get the OS description @>
@< Construct the message with Concatenation @>
@< Print the message @>
@}

The second uses string substitution:

@o test2.py
@{
@< Import the os module @>
@< Get the OS description @>
@< Construct the message with Substitution @>
@< Print the message @>
@}

\subsection{Retrieving the OS description}

First we must import the os module so we can learn about the OS:

@d Import the os module
@{
import os
@}

That having been done, we can retrieve Python's name for the OS type:

@d Get the OS description
@{
os_name = os.name
@}

\subsection{Building the message}

Now, we're ready for the meat of the application: concatenating two strings:

@d Construct the message with Concatenation
@{
msg = "Hello, " + os_name + "!"
@}

But wait!  Is there a better way?  Using string substitution might be
better:

@d Construct the message with Substitution
@{
msg = f"Hello, {os_name}!" 
@}

We'll use the first of these methods in \texttt{test.py}, and the
other in \texttt{test2.py}.

\subsection{Printing the message}

Finally, we print the message out for the user to see.  Hopefully, a
cheery greeting will make them happy to know what operating system
they have:

@d Print the message 
@{
print(msg)
@}

\end{document}
