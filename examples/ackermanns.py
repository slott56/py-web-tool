

phi_1 = (
    lambda m, n, p: (
        {
            m+n if p == 0 else None, 
            0 if n == 0 and p == 1 else None, 
            1 if n == 0 and p == 2 else None, 
            m if n == 0 and p > 2 else None, 
            phi_1(m, phi_1(m, n-1, p), p-1) if n > 0 and p > 0 else None,
        } - {None}
    ).pop()
)

REPL_set_reduction = """

>>> phi_1(3, 5, 0)
8
>>> phi_1(3, 5, 1)
15
>>> phi_1(3, 5, 2)
243
>>> 3**5
243

"""


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

REPL_dict_reduction = """

>>> phi(3, 5, 0) == 3+5
True
>>> phi(3, 5, 1) == 3*5
True
>>> phi(3, 5, 2) == 3**5
True

"""


def phi_m(m, n, p):
    match (m, n, p):
        case (_, _, 0):
            return m + n
        case (_, 0, 1):
            return 0
        case (_, 0, 2):
            return 1
        case (_, 0, _) if p > 2:
            return m
        case (_, _, _) if n > 0 and p > 0:
            return phi_m(m, phi_m(m, n-1, p), p-1)

REPL_match_statement = """

>>> phi_m(3, 5, 0) == 3+5
True
>>> phi_m(3, 5, 1) == 3*5
True
>>> phi_m(3, 5, 2) == 3**5
True

"""

__test__ = {n: v for n, v in globals().items() if n.startswith('REPL')}
