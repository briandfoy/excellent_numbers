#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

const uint64_t powers_of_10[] = {
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000LL,
    100000000000LL,
    1000000000000LL,
    10000000000000LL,
    100000000000000LL,
    1000000000000000LL,
    10000000000000000LL,
    100000000000000000LL,
    1000000000000000000LL,
};

const uint64_t stop_a[] = {
		0,
		6,
        63,
        619,
        6181,
        61805,
        618034,
        6180340,
        61803400,
        618033989,
        6180339888LL,
        61803398875LL,
        618033988751LL,
        6180339887499LL,
        61803398874990LL,
        618033988749895LL,
        6180339887498949LL,
        61803398874989485LL,
        618033988749894849LL,
        6180339887498948483LL,
};

const int next_a[] = {
		4,         /* previous a ends in 0 */
		0, 0, 0,
		2,         /* previous a ends in 4 */
		0,
		4          /* previous a ends in 4 */
};

/* see http://stackoverflow.com/a/13187798 */
static uint64_t
UnsignedMultiply128(uint64_t x, uint64_t y, uint64_t *hi) {
    unsigned __int128 z = ((unsigned __int128) x) * ((unsigned __int128) y);
    *hi = z >> 64;
    return (uint64_t) z;
}

int main(int argc, char *argv[])
{
    int d, k;
    uint64_t K, start, end, front, back, last_digit, count = 0;
    uint64_t lhs[2], rhs[2], frontsq[2];

    if (argc < 2) {
        fputs("Need number of digits", stderr);
        exit(1);
    }

    d = atoi(argv[1]);
    if (!d) {
        d = 2;
    }

    if (d % 2) {
        d *= 2;
    }

    k = d/2;

    if (k >= sizeof(powers_of_10)/sizeof(powers_of_10[0])) {
        fputs("Too many digits", stderr);
        exit(1);
    }

    K     = powers_of_10[ k ];
    start = powers_of_10[ k - 1 ];
	end   = stop_a[ k ];

    for (front = start; front <= end; front += next_a[ front % 10 ])
    {
        back = (uint64_t) (1.0 + front * sqrt(1 + ((double) K) / front));
        if (back >= K) {
            break;
        }

        lhs[0] = lhs[1] = rhs[0] = rhs[1] = frontsq[0] = frontsq[1] = 0;

        lhs[0] = UnsignedMultiply128(back,  back - 1, lhs + 1);
        rhs[0] = UnsignedMultiply128(front, K, rhs + 1);
        frontsq[0] = UnsignedMultiply128(front, front, frontsq + 1);

        rhs[0] += frontsq[0];
        rhs[1] += frontsq[1];

        if (rhs[0] < frontsq[0]) {
            rhs[1] += 1;
        }

        if ((lhs[1] == rhs[1]) && (lhs[0] == rhs[0])) {
            count += 1;
            printf("%llu%llu\n", front, back);
        }
    }

    printf("%llu excellent numbers with %d digits\n", count, d);

    return 0;

}
