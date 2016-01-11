#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

#ifdef WINDOWS
#include <windows.h>
#endif

uint64_t UnsignedMultiply128( uint64_t a, uint64_t b, uint64_t *hi);

uint64_t UnsignedMultiply128( uint64_t a, uint64_t b, uint64_t *hi) {
    __int128 result = (__int128)a * (__int128)b;
    *hi = result >> 64;
    return (size_t)result;
	}

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

int main(int argc, char *argv[1])
{
    int d, k;
    uint64_t K, start, front, back, last_digit, count = 0;
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

    K = powers_of_10[ k ];
    start = powers_of_10[ k - 1 ];

    for (front = start; front < 7 * start; front += 1)
    {
        last_digit = (front % 10);
        if ( (last_digit != 0) && (last_digit != 4) && (last_digit != 6)) {
            continue;
        }

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
            printf("%lld%lld\n", front, back);
        }
    }

    printf("%lld excellent numbers with %d digits\n", count, d);

    return 0;

}
