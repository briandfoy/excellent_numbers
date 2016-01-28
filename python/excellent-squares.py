#!python
"""https://matthewarcus.wordpress.com/2016/01/16/excellent-numbers/"""

"""https://pypi.python.org/pypi/primefac"""
import primefac

def excellent(k):
    """Generate all excellent numbers of size 2k"""
    A = 10**k; N = A*A-1
    factors1 = list(primefac.primefac(A-1))
    factors2 = list(primefac.primefac(A+1))
    d = divisors(sorted(factors1+factors2))
    for i in d:
        if i*i > N: continue
        j = N//i
        x,y = (j+i)//2, (j-i)//2
        a,b = (x-A)//2, (y+1)//2
        if A//10 <= a < A and 0 <= b < A:
            n = a*A+b
            assert(n == b*b-a*a) # Check our logic
            yield n

def divisors(factorlist):
    """Generate all divisors of number from list of prime factors"""
    factors = multiset(factorlist)
    nfactors = len(factors)
    a = [0]*nfactors; b = [1]*nfactors
    yield 1
    while True:
        i = 0
        while i < nfactors:
            if a[i] < factors[i][1]: break
            a[i] = 0; b[i] = 1; i += 1
        if i == nfactors: break
        a[i] += 1; b[i] *= factors[i][0]
        for j in range(0,i): b[j] = b[i]
        yield b[0]

def multiset(s):
    """Create a multiset from a (sorted) list of items"""
    m = []; n = s[0]; count = 1
    for i in range(1,len(s)):
        if s[i] != n:
            m.append((n,count))
            n = s[i]
            count = 1
        else:
            count += 1
    m.append((n,count))
    return m

for n in range(2,1000,2):
    for m in excellent(n//2): print m
