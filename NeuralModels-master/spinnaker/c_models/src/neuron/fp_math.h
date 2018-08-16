#ifndef FP_MATH_H
#define FP_MATH_H

#include <neuron/../common/neuron-typedefs.h>

///////////////////////////////
/// \brief fix16_t
/// from https://code.google.com/archive/p/libfixmath/

typedef int32_t fix16_t;

fix16_t real_to_fix16(REAL _x);

REAL fix16_to_real(fix16_t x);

REAL fp_div(REAL a, REAL b);

fix16_t fp_ln(fix16_t val);

fix16_t fp_exp(fix16_t val);

REAL fp_pow(REAL ebase, REAL exponent);

#endif // FP_MATH_H
