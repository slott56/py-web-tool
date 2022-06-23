Fast Exponentiation
===================

A classic divide-and-conquer algorithm.


..  _`fast exp (1)`:
..  rubric:: fast exp (1) =
..  parsed-literal::
    :class: code

    
    def fast_exp(n: int, p: int) -> int:
        match p:
            case 0: 
                return 1
            case _ if p % 2 == 0:
                t = fast_exp(n, p // 2)
                return t * t
            case _ if p % 1 == 0:
                return n * fast_exp(n, p - 1)
    
..

..  class:: small

    ∎ *fast exp (1)*



With a test case.


..  _`test case (2)`:
..  rubric:: test case (2) =
..  parsed-literal::
    :class: code

    
    >>> fast_exp(2, 30)
    1073741824
    
..

..  class:: small

    ∎ *test case (2)*




..  _`example.py (3)`:
..  rubric:: example.py (3) =
..  parsed-literal::
    :class: code

    
    →\ `fast exp (1)`_
    
    __test__ = {
        "test 1": '''
    →\ `test case (2)`_
    
        '''
    }
    
..

..  class:: small

    ∎ *example.py (3)*



Use ``python -m doctest`` to test.

