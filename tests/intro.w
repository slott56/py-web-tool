Introduction
============

..	test/intro.w 

There are two levels of testing in this document.

-	`Unit Testing`_

-	`Functional Testing`_

Other testing, like performance or security, is possible.
But for this application, not very interesting.

This WEB document builds a complete test suite, ``test.py``.
This can then be run with

::

    PYTHONPATH=src pytest
