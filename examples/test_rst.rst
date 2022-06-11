####################
Test Program
####################

===============
Jason R. Fruit
===============

..  include:: <isoamsa.txt>

..  contents::


Introduction
============

This test program prints the word "hello", followed by the name of
the operating system as understood by Python.  It is implemented in
Python and uses the ``os`` module.  It builds the message string
in two different ways, and writes separate versions of the program to
two different files.

Implementation
==============

Output files
------------

This document contains the makings of two files; the first,
``test.py``, uses simple string concatenation to build its output
message:


..  _`1`:
..  rubric:: test.py (1)
..  parsed-literal::
        
    |srarr| Import the os module (`3`_)    
    |srarr| Get the OS description (`4`_)    
    |srarr| Construct the message with Concatenation (`5`_)    
    |srarr| Print the message (`7`_)    




The second uses string substitution:


..  _`2`:
..  rubric:: test2.py (2)
..  parsed-literal::
        
    |srarr| Import the os module (`3`_)    
    |srarr| Get the OS description (`4`_)    
    |srarr| Construct the message with Substitution (`6`_)    
    |srarr| Print the message (`7`_)    




Retrieving the OS description
-------------------------------

First we must import the os module so we can learn about the OS:


..  _`3`:
..  rubric:: Import the os module (3)
..  parsed-literal::
        
    import os


Used by: test.py (`1`_); test2.py (`2`_)



That having been done, we can retrieve Python's name for the OS type:


..  _`4`:
..  rubric:: Get the OS description (4)
..  parsed-literal::
        
    os\_name = os.name


Used by: test.py (`1`_); test2.py (`2`_)



Building the message
---------------------

Now, we're ready for the meat of the application: concatenating two strings:


..  _`5`:
..  rubric:: Construct the message with Concatenation (5)
..  parsed-literal::
        
    msg = "Hello, " + os\_name + "!"


Used by: test.py (`1`_)



But wait!  Is there a better way?  Using string substitution might be
better:


..  _`6`:
..  rubric:: Construct the message with Substitution (6)
..  parsed-literal::
        
    msg = "Hello, %s!" % os\_name


Used by: test2.py (`2`_)



We'll use the first of these methods in ``test.py``, and the
other in ``test2.py``.

Printing the message
----------------------

Finally, we print the message out for the user to see.  Hopefully, a
cheery greeting will make them happy to know what operating system
they have:


..  _`7`:
..  rubric:: Print the message (7)
..  parsed-literal::
        
    print msg


Used by: test.py (`1`_); test2.py (`2`_)




