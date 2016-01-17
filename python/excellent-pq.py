# https://news.ycombinator.com/item?id=10909909

# Given N, introducing q=10^N, they are looking for a and b in [0,q)
# such that
#
#   (q+2a)^2-(2b-1)^2 = q^2-1
#
# For example, for N=1, q=10, given 18^2 - 15^2 = 99, we find a solution
# with a=4, b=8: 48 That suggests using
# https://en.m.wikipedia.org/wiki/Midpoint_circle_algorithm to get
# rid of that pesky square root (circle drawing uses sums of squares,
# but I think that is trivially adjusted for) I also think it is
# worthwhile to extend this to other bases, as it more easily produces
# more examples to look at for discovering structure, and gets rid of
# the arbitrarily chosen number 10. Edit: for those needing some
# explanation how to get at that claim:
#
#   let q > 0
# (they pick q=10, q=100, q=1000, but this generalises this)
#
# Assume
#
#   aq+b = b^2 - a^2 for some a,b in [0,q]
#
# in other words: b^2-a^2, written in base q, is ab
#
# Then:
#
#   b^2 - a^2 = qa+b                          <=> (bring all b’s to the left, all else to the right)
#   b^2 - b = qa + a^2                        <=> (factor)
#   b(b-1)  = a(a+q)                          <=> (using (p+q)(p-q) = p^2-q^2)
#   (b-1/2)^2 - (1/2)^2 = (a+q/2)^2 - (q/2)^2 <=> (multiply by 4 on both sides)
#   (2b-1)^2 - 1 = (2a+q)^2 - q^2             <=> (bring all a’s and all b’s to the right)
#   q^2 - 1 = (2a+q)^2 - (2b-1)^2             <=> (switch sides; slight rewrite)
#   (q+2a)^2 - (2b-1)^2 = q^2-1
#
# Edit 2: for large q, it probably is faster to do the (p+q)(p-q) =
# p^2-q^2 trick again (apologies for naming the free variable q the same
# as the q introduced earlier), and get:
#
#   (q+2a+2b-1)(q+2a-2b+1) = q^2-1
#
# Next, factor q^2-1, write all ways to write it as product of integers,
# and check each case for integer solutions for a and b in the right
# range. For example, for q=10, we have:
#
#   99 = 1x99 = 3x33 = 9x11 = 11x9 = 33x3 = 99x1, so we solve 6 systems (I guess one easily discard half of them on arguments of the p+q part being larger than the p-q part, but that’s peanuts) of two linear equations in two variables:
#
#   / q+2a+2b-1 =  1
#   \ q+2a-2b+1 = 99
#
#   / q+2a+2b-1 =  3
#   \ q+2a-2b+1 = 33
#
#   …
#
#   / q+2a+2b-1 = 99
#   \ q+2a-2b+1 =  1
#
# This also suggests that the number of solutions with d base q digits
# for a and b is correlated with the number of integers that divide
# q^2-1. That would link it to http://oeis.org/A000010.
#
# Edit 3: and for the 10^N case, one might consider
# http://oeis.org/A095370. For example, the 62-digit number 1111…1111
# has only 5 prime factors. You have to add 2 factors of 3 to get
# 9999…9999, so 10^62-1 can be written as product of two integers in 2^7
# ways => only 2^6 = 64 equations to solve.

q = 1000000000000000000000
n = 111111111111111111111111111111111111111111
factors  = [3,7,7,11,13,37,43,127,239,1933,2689,4649,459691,909091,10838689]

q10 = q/10

bits = len(factors)
#print b
#print 11*41*101*271*3541*9091*27961
for i in range(2**bits):
	r = 1
	s = 1
	for j in range(bits):
	  if i&(1<<j):
		r *= factors[j]
	  else:
		s *= factors[j]
	# To solve:
	# q+2a+2b-1 = r
	# q+2a-2b+1 = s
	# q+2a = (r+s)/2
	# 2b-1 = (r-s)/2
	#
	# => a = ((r+s)/2 - q) / 2
	# => b = (1+(r-s)/2) / 2
	#
	# r and s are odd, so we do not have to worry much about fractions
	two_a = (r+s)/2 - q
	if two_a % 1 == 0:
	  a = two_a / 2
	  two_b = (r-s)/2 + 1
	  if two_b %1  == 0:
		b = two_b / 2
		if (q10 <= a < q) and (q10 <= b < q):
		  print b*b-a*a

