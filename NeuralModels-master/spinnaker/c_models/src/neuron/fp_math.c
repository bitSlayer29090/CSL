#include "fp_math.h"

#include <debug.h>

static const fix16_t fix16_minimum  = 0x80000000;
static const fix16_t fix16_overflow = 0x80000000;

#define clz(x) (__builtin_clzl(x) - (8 * sizeof(long) - 32))

#define base 16

fix16_t real_to_fix16(REAL _x) {

    uint8_t neg = _x < 0 ? 1 : 0;
    if (neg)
        _x = -_x;

    fix16_t x;

    memcpy(&x, &_x, sizeof(fix16_t));
    x = (x & 0x80000000) | (x << 1);

    if (neg)
        x = -x;

    return x;

}

REAL fix16_to_real(fix16_t x) {

    uint8_t neg = x < 0 ? 1 : 0;
    if (neg)
        x = -x;

    x = (x & 0x80000000) | ((x & 0x7FFFFFFF) >> 1);

    REAL _x;
    memcpy(&_x, &x, sizeof(REAL));

    if (neg)
        _x = -_x;

    return _x;

}

fix16_t _fp_div(fix16_t a, fix16_t b) {
    // This uses the basic binary restoring division algorithm.
    // It appears to be faster to do the whole division manually than
    // trying to compose a 64-bit divide out of 32-bit divisions on
    // platforms without hardware divide.

//    fix16_t a = real_to_fix16(_a);
//    fix16_t b = real_to_fix16(_b);

    //    fix16_t a, b;
    //    memcpy(&a, &_a, sizeof(fix16_t));
    //    memcpy(&b, &_b, sizeof(fix16_t));

    //    a = (a & 0x80000000) | (a << 1);
    //    b = (b & 0x80000000) | (b << 1);

    if (b == 0)
        return fix16_minimum;

    uint32_t remainder = (a >= 0) ? a : (-a);
    uint32_t divider = (b >= 0) ? b : (-b);

    uint32_t quotient = 0;
    uint32_t bit = 0x10000;

    /* The algorithm requires D >= R */
    while (divider < remainder)
    {
        divider <<= 1;
        bit <<= 1;
    }

#ifndef FIXMATH_NO_OVERFLOW
    if (!bit)
        return fix16_overflow;
#endif

    if (divider & 0x80000000)
    {
        // Perform one step manually to avoid overflows later.
        // We know that divider's bottom bit is 0 here.
        if (remainder >= divider)
        {
            quotient |= bit;
            remainder -= divider;
        }
        divider >>= 1;
        bit >>= 1;
    }

    /* Main division loop */
    while (bit && remainder)
    {
        if (remainder >= divider)
        {
            quotient |= bit;
            remainder -= divider;
        }

        remainder <<= 1;
        bit >>= 1;
    }

#ifndef FIXMATH_NO_ROUNDING
    if (remainder >= divider)
    {
        quotient++;
    }
#endif

    fix16_t result = quotient;

    /* Figure out the sign of result */
    if ((a ^ b) & 0x80000000)
    {
#ifndef FIXMATH_NO_OVERFLOW
        if (result == fix16_minimum)
            return fix16_overflow;
#endif

        result = -result;
    }

    return result;
//    return fix16_to_real(result);
}

REAL fp_div(REAL a, REAL b) {

    return fix16_to_real(_fp_div(real_to_fix16(a), real_to_fix16(b)));

}

fix16_t fp_ln(fix16_t val)
{
    uint32_t fracv, intv, y, ysq, fracr;//, bitpos;
    int32_t bitpos;
    /*
    fracv    -    initial fraction part from "val"
    intv    -    initial integer part from "val"
    y        -    (fracv-1)/(fracv+1)
    ysq        -    y*y
    fracr    -    ln(fracv)
    bitpos    -    integer part of log2(val)
    */

//    log_info("%x", val);

    //    const uint32_t ILN2 = 94548;        /* 1/ln(2) with 2^16 as base*/
    const uint32_t ILOG2E = 45426;    /* 1/log2(e) with 2^16 as base */
    //    const uint32_t ILOG2E = real_to_fix16(REAL_CONST(0.69315));

    const uint32_t ln_denoms[] = {
        (1<<base)/1,
        (1<<base)/3,
        (1<<base)/5,
        (1<<base)/7,
        (1<<base)/9,
        (1<<base)/11,
        (1<<base)/13,
        (1<<base)/15,
        (1<<base)/17,
        (1<<base)/19,
        (1<<base)/21,
    };

    /* compute fracv and intv */
    bitpos = 14 - clz(val);
    if(bitpos >= 0){
        ++bitpos;
        fracv = val>>bitpos;
    } else if(bitpos < 0){
        /* fracr = val / 2^-(bitpos) */
        ++bitpos;
        fracv = val<<(-bitpos);
//        log_info("neg");
    }
//    log_info("bitpos: %d, clz: %d", bitpos, clz(val));
//    log_info("fracr = %x", fracr);

    // bitpos is the integer part of ln(val), but in log2, so we convert
    // ln(val) = log2(val) / log2(e)
    intv = bitpos * ILOG2E;
//    log_info("intv = %x", intv);

    // y = (ln_fraction_value−1)/(ln_fraction_value+1)
    y = ((uint32_t)(fracv-(1<<base))<<base) / (fracv+(1<<base));

    ysq = (y*y)>>base;
    fracr = ln_denoms[10];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[9];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[8];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[7];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[6];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[5];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[4];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[3];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[2];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[1];
    fracr = (((uint32_t)fracr * ysq)>>base) + ln_denoms[0];
    fracr =  ((uint32_t)fracr * (y<<1))>>base;

//    log_info("fracr = %x", fracr);

    return (intv + fracr);
}

fix16_t fp_exp(fix16_t val) {

    uint8_t neg = val < 0 ? 1 : 0;
    if (neg)
        val = -val;

    fix16_t x;

    if (val == 0)
        return 0x10000;

    x = val;
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);
    x = x - (((int64_t)x*(fp_ln(x) - val))>>base);

    if (neg)
        return _fp_div(0x10000, x);

    return x;
}

REAL fp_pow(REAL ebase, REAL exponent) {

//    if (REAL_COMPARE(ebase, == , 0.0k))
//        return REAL_CONST(0.0);

    return fix16_to_real(fp_exp(((int64_t)real_to_fix16(exponent) * fp_ln(real_to_fix16(ebase)))>>base));

}
