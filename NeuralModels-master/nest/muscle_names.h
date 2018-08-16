/*
 *  muscle_names.h
 *
 *  Copyright (C) 2017 Lorenzo Vannucci
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef MUSCLE_NAMES_H
#define MUSCLE_NAMES_H

#include "nest_names.h"


namespace muscle {

namespace names {

extern const Name primary_rate;
extern const Name secondary_rate;

extern const Name L;
extern const Name dL;

extern const Name T_bag1;
extern const Name T_bag2;
extern const Name T_chain;

extern const Name primary;

extern const Name tau_dyn;
extern const Name a_dyn;
extern const Name tau_st;
extern const Name a_st;

extern const Name bag1_beta0;
extern const Name bag1_beta;
extern const Name bag1_gamma;
extern const Name bag1_Ksr;
extern const Name bag1_Kpr;
extern const Name bag1_a;
extern const Name bag1_R;
extern const Name bag1_Lsr0;
extern const Name bag1_Lpr0;
extern const Name bag1_G;
extern const Name bag1_LsrN;
extern const Name bag1_X;
extern const Name bag1_Lsec;
extern const Name bag1_LprN;

extern const Name bag2_beta0;
extern const Name bag2_beta;
extern const Name bag2_gamma;
extern const Name bag2_Ksr;
extern const Name bag2_Kpr;
extern const Name bag2_a;
extern const Name bag2_R;
extern const Name bag2_Lsr0;
extern const Name bag2_Lpr0;
extern const Name bag2_G;
extern const Name bag2_LsrN;
extern const Name bag2_X;
extern const Name bag2_Lsec;
extern const Name bag2_LprN;

extern const Name chain_beta0;
extern const Name chain_beta;
extern const Name chain_gamma;
extern const Name chain_Ksr;
extern const Name chain_Kpr;
extern const Name chain_a;
extern const Name chain_R;
extern const Name chain_Lsr0;
extern const Name chain_Lpr0;
extern const Name chain_G;
extern const Name chain_LsrN;
extern const Name chain_X;
extern const Name chain_Lsec;
extern const Name chain_LprN;

}

}

#endif // MUSCLE_NAMES_H
