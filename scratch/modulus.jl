#!/Applications/Julia-0.3.8.app/Contents/Resources/julia/bin/julia
digits = 10
k = div( digits, 2 )

start = BigInt( 10 ^ (k - 1) )

for a = start : BigInt( 10 ^ (k) + 1 )
	if a % start == 0
		println( "$a is even" )
	end
end
