####################
Ackermann’s Function
####################

==============
Steven F. Lott
==============

..  contents::

Definitions
===========

Here are the definitions for Ackermann's full :math:`\varphi (m,n,p)` function:

.. math::


       \varphi (m,n,p) = \begin{cases}
       \varphi (m,n,0)&=m+n\\
       \varphi (m,0,1)&=0\\
       \varphi (m,0,2)&=1\\
       \varphi (m,0,p)&=m {\textbf{ for }}p>2\\
       \varphi (m,n,p)&=\varphi (m,\varphi (m,n-1,p),p-1) {\textbf{ for }}n,p>0
       \end{cases}

These definitions have the following consequences:

.. math::


       \begin{align}
       \varphi (m,n,0)&=m+n\\
       \varphi (m,n,1)&=m\times n\\
       \varphi (m,n,2)&=m^{n}
       \end{align}

Implementations
===============

We'll look at a number of ways
to implement this.


..  _`ackermanns.py (1)`:
..  rubric:: ackermanns.py (1) =
..  parsed-literal::
    :class: code

    
    →\ `set reduction (2)`_    
    REPL\_set\_reduction = """
    →\ `test set reduction (3)`_    
    """
    
    →\ `dictionary reduction (4)`_    
    REPL\_dict\_reduction = """
    →\ `test dict reduction (5)`_    
    """
    
    →\ `match statement (6)`_    
    REPL\_match\_statement = """
    →\ `test match statemnent (7)`_    
    """
    
    \_\_test\_\_ = {n: v for n, v in globals().items() if n.startswith('REPL')}

..

..  class:: small

    ∎ *ackermanns.py (1)*



Set Reduction
-------------

First, let's consider evaluating the conditionals into "value or None" conditions.
We can then create a set and keep the non-None items.

The set reduction involves computing a non-\ ``None`` result for the case that is true
and ``None`` result for all remaining cases. The resulting set of values will be reduced to
two items. Subtracting the ``None`` item from the set leaves the result value.


..  _`set reduction (2)`:
..  rubric:: set reduction (2) =
..  parsed-literal::
    :class: code

    
    phi\_1 = (
        lambda m, n, p: (
            {
                m+n if p == 0 else None, 
                0 if n == 0 and p == 1 else None, 
                1 if n == 0 and p == 2 else None, 
                m if n == 0 and p > 2 else None, 
                phi\_1(m, phi\_1(m, n-1, p), p-1) if n > 0 and p > 0 else None,
            } - {None}
        ).pop()
    )

..

..  class:: small

    ∎ *set reduction (2)*




..  _`test set reduction (3)`:
..  rubric:: test set reduction (3) =
..  parsed-literal::
    :class: code

    
    >>> phi\_1(3, 5, 0)
    8
    >>> phi\_1(3, 5, 1)
    15
    >>> phi\_1(3, 5, 2)
    243
    >>> 3\*\*5
    243

..

..  class:: small

    ∎ *test set reduction (3)*




Dictionary Reduction
--------------------

We can use the condition value (``True`` or ``False``) as a dictionary
key. The value for each key is the lambda to evaluate when the key is ``True``.
Picking the ``True`` key from the dictionary maps to the applicable lambda. 
The other lambda, mapped to ``False`` can be ignored.


..  _`dictionary reduction (4)`:
..  rubric:: dictionary reduction (4) =
..  parsed-literal::
    :class: code

    
    phi = (
        lambda m, n, p: (
            {
                p == 0: lambda m, n, p: m+n,
                n == 0 and p == 1: lambda m, n, p: 0, 
                n == 0 and p == 2: lambda m, n, p: 1, 
                n == 0 and p > 2: lambda m, n, p: m, 
                n > 0 and p > 0: lambda m, n, p: phi(m, phi(m, n-1, p), p-1)
            }[True](m, n, p)
        )
    )

..

..  class:: small

    ∎ *dictionary reduction (4)*




..  _`test dict reduction (5)`:
..  rubric:: test dict reduction (5) =
..  parsed-literal::
    :class: code

    
    >>> phi(3, 5, 0) == 3+5
    True
    >>> phi(3, 5, 1) == 3\*5
    True
    >>> phi(3, 5, 2) == 3\*\*5
    True

..

..  class:: small

    ∎ *test dict reduction (5)*




Match/Case
----------

We can use Python 3.10's ``match`` statement, also.
This is generally what folks expect to see.


..  _`match statement (6)`:
..  rubric:: match statement (6) =
..  parsed-literal::
    :class: code

    
    def phi\_m(m, n, p):
        match (m, n, p):
            case (\_, \_, 0):
                return m + n
            case (\_, 0, 1):
                return 0
            case (\_, 0, 2):
                return 1
            case (\_, 0, \_) if p > 2:
                return m
            case (\_, \_, \_) if n > 0 and p > 0:
                return phi\_m(m, phi\_m(m, n-1, p), p-1)

..

..  class:: small

    ∎ *match statement (6)*




..  _`test match statemnent (7)`:
..  rubric:: test match statemnent (7) =
..  parsed-literal::
    :class: code

    
    >>> phi\_m(3, 5, 0) == 3+5
    True
    >>> phi\_m(3, 5, 1) == 3\*5
    True
    >>> phi\_m(3, 5, 2) == 3\*\*5
    True

..

..  class:: small

    ∎ *test match statemnent (7)*



Conclusion
==========

We've looked at three ways to define a fairly complex function with a lot of complex-looking 
special cases.

The ``match`` statement seems to fit most people's expectations of the complex-looking math.
