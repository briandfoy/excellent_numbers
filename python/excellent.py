#!/usr/bin/python
import sys;
import math;

class Excellent(object):
	def __init__ ( self ):
		self

	def run ( self, args ):
		if len(args) == 1:
			args.append( None )
		if len(args) == 2:
			args.append( None )

		self.digits  = int( args[0] )
		if not self.digits % 2 == 0:
			raise Exception('Digits should be an even number')

		self.get_start( args[1] )
		self.get_end(   args[2] )
		print( "Start is %d\nEnd is %d" % (self.start_a, self.end_a ) )

		self.test_range()

	def digits ( self ):
		print( "Hello" )

	def half_digits ( self ):
		return self.digits / 2;

	def k ( self ):
		return self.half_digits() - 1

	def get_start ( self, start ):
		if start is None:
			start = 10**self.k()

		start = int(start);

		if len( str(start) ) != self.half_digits():
			raise Exception("start a should be %d digits" % self.half_digits() )

		if start % 2 == 1:
			start += 1

		self.start_a = start

	def get_end ( self, end ):
		if end is None:
			end = self.bisect( 1 )

		end = int(end);

		if len( str(end) ) != self.half_digits():
			raise Exception("end a should be %d digits" % self.half_digits() )

		self.end_a = end

	def bisect ( self, threshold=1 ):
		b = 10**(self.k() + 1) - 1

		maximum = b;
		minimum = 10**self.k()

		trial = (maximum - minimum) // 2

		k1 = self.k()+1
		while( 1 ):
			result = math.sqrt( trial * (10**k1) + trial**2 )

			last_trial = trial

			if( abs( result - b ) < threshold ):
				break;
			elif( result > b ):
				maximum = trial
				trial = minimum + ( trial - minimum ) // 2
			elif( result < b ):
				minimum = trial
				trial = trial + ( maximum - trial ) // 2 + 1
			else:
				return trial

			if( last_trial == trial ):
				break

		return trial + threshold

	def compound_duration ( self, seconds ):
		raise Exception('compound_duration unimplemented')

	def test_range ( self ):
		k2 = len( str( self.start_a ) )
		ten_k2 = 10**k2;

		# the only candidates end in 0, 4, 6, 8
		# so only check even numbers and skip those ending in 2
		if( self.start_a % 2 == 1 ):
			self.start_a += 1

		for a in xrange( self.start_a, self.end_a, 2 ):
			if( a % 10 == 2 ):
				continue

			front = a*( ten_k2 + a)

			root = int( math.sqrt( front ) );

			# use seen to stop when we might check a root
			# a second time so we don't get into loops
			seen = {}
			while( 1 ):
				back = root * ( root - 1 );
				if( seen.has_key( str(back) ) ):
					break

				seen[ str(back) ] = 1

				if( back < front ):
					root +=1
					continue
				elif( back > front ):
					root -= 1
					continue
				else:
					print( "%d%d is excellent" % ( a, root ) )
					break


if __name__ == '__main__':
	print( "This is Python %s" % sys.version )
	Excellent().run( sys.argv[1:] )


