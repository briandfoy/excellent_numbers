#!/Applications/Julia-0.3.8.app/Contents/Resources/julia/bin/julia

function excellent(k)
	if k < 10
		const ten = 10
	else
		const ten = BigInt(10)
	end

	n = 10^k

	for a = ( ten ^ (k - 1) ) : ( ten ^ (k) - 1 )
		front = a * (n + a)

		root = isqrt(front)

		for b = ( root - 1 ) : ( root + 1 )
			back = b * (b - 1);
			back > front && break
			if front == back && ndigits(b,10) == k
				@printf "%d%d\n" a b
			end
		end
	 end
end

const digits = int( ARGS[1] )
excellent( div( digits, 2 ) )
