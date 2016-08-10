#!python
"""https://matthewarcus.wordpress.com/2016/01/16/excellent-numbers/"""

"""https://pypi.python.org/pypi/primefac"""
import primefac

for n in range(2,100):
	nines = 10 ** n - 1
	print "%d:" % (n),
	for f in primefac.primefac(nines):
		print " " + str(f),
	print " | ", nines
