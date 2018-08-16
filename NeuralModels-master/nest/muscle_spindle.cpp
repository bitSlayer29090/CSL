/*
 *  muscle_spindle.cpp
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

#include "muscle_spindle.h"

// C++ includes:
#include <limits>
#include <cmath>

// Includes from libnestutil:
#include "numerics.h"

// Includes from nestkernel:
#include "exceptions.h"
#include "universal_data_logger_impl.h"

// Includes from sli:
#include "dict.h"
#include "dictutils.h"
#include "doubledatum.h"
#include "integerdatum.h"
#include "lockptrdatum.h"

#include "muscle_names.h"

using namespace nest;

namespace muscle {

/* ----------------------------------------------------------------
 * Recordables map
 * ---------------------------------------------------------------- */

nest::RecordablesMap<muscle_spindle> muscle_spindle::recordablesMap_;

}

namespace nest
{
// Override the create() method with one call to RecordablesMap::insert_()
// for each quantity to be recorded.
template <>
void
RecordablesMap<muscle::muscle_spindle>::create()
{
    // use standard names whereever you can for consistency!
    insert_(muscle::names::primary_rate, &muscle::muscle_spindle::get_p_rate_);
    insert_(muscle::names::secondary_rate, &muscle::muscle_spindle::get_s_rate_);
}
}

namespace muscle {

/* ----------------------------------------------------------------
 * Parameters and state
 * ---------------------------------------------------------------- */

muscle_spindle::Parameters_::Parameters_()
    : L(1.0), dL(0.0), primary(true) {

    bag1_params.beta0 = 0.0605;
    bag1_params.beta = 0.2592;
    bag1_params.gamma = 0.0289;
    bag1_params.Ksr = 10.4649;
    bag1_params.Kpr = 0.1500;
    bag1_params.a = 3.333333;
    bag1_params.R = 0.46;
    bag1_params.Lsr0 = 0.04;
    bag1_params.Lpr0 = 0.76;
    bag1_params.G = 20000.0;
    bag1_params.LsrN = 0.0423;
    bag1_params.X = 0.0;
    bag1_params.Lsec = 0.0;
    bag1_params.LprN = 0.0;

    bag2_params.beta0 = 0.0822;
    bag2_params.beta = -0.0460;
    bag2_params.gamma = 0.0636;
    bag2_params.Ksr = 10.4649;
    bag2_params.Kpr = 0.1500;
    bag2_params.a = 3.333333;
    bag2_params.R = 0.46;
    bag2_params.Lsr0 = 0.04;
    bag2_params.Lpr0 = 0.76;
    bag2_params.G = 10000.0;
    bag2_params.LsrN = 0.0423;
    bag2_params.X = 0.7;
    bag2_params.Lsec = 0.04;
    bag2_params.LprN = 0.89;

    chain_params.beta0 = 0.0822;
    chain_params.beta = -0.0690;
    chain_params.gamma = 0.0954;
    chain_params.Ksr = 10.4649;
    chain_params.Kpr = 0.1500;
    chain_params.a = 3.333333;
    chain_params.R = 0.46;
    chain_params.Lsr0 = 0.04;
    chain_params.Lpr0 = 0.76;
    chain_params.G = 10000.0;
    chain_params.LsrN = 0.0423;
    chain_params.X = 0.7;
    chain_params.Lsec = 0.04;
    chain_params.LprN = 0.89;

    // static and dynamic fusimotor synapses
    num_of_receptors_ = 2;
    receptor_types_.resize(num_of_receptors_);
    for ( size_t i = 0; i < num_of_receptors_; i++ )
    {
        receptor_types_[ i ] = i + 1;
    }

    tau_dyn = 310;
    a_dyn = 0.08;
    tau_st = 425;
    a_st = 0.06;

}

muscle_spindle::State_::State_(const muscle_spindle::Parameters_&)
    :primary_afferent_rate(0.0),
      secondary_afferent_rate(0.0),
      T_bag1(0.0),
      T_bag2(0.0),
      T_chain(0.0),
      f_dyn(0.0),
      f_st(0.0) {}

/* ----------------------------------------------------------------
 * Parameter and state extractions and manipulation functions
 * ---------------------------------------------------------------- */

void muscle_spindle::Parameters_::get(DictionaryDatum& d) const {

    (*d)[names::L] = L;
    (*d)[names::dL] = dL;

    (*d)[names::primary] = primary;

    (*d)[names::tau_dyn] = tau_dyn;
    (*d)[names::a_dyn] = a_dyn;
    (*d)[names::tau_st] = tau_st;
    (*d)[names::a_st] = a_st;

    (*d)[names::bag1_beta0] = bag1_params.beta0;
    (*d)[names::bag1_beta] = bag1_params.beta;
    (*d)[names::bag1_gamma] = bag1_params.gamma;
    (*d)[names::bag1_Ksr] = bag1_params.Ksr;
    (*d)[names::bag1_Kpr] = bag1_params.Kpr;
    (*d)[names::bag1_a] = bag1_params.a;
    (*d)[names::bag1_R] = bag1_params.R;
    (*d)[names::bag1_Lsr0] = bag1_params.Lsr0;
    (*d)[names::bag1_Lpr0] = bag1_params.Lpr0;
    (*d)[names::bag1_G] = bag1_params.G;
    (*d)[names::bag1_LsrN] = bag1_params.LsrN;
    (*d)[names::bag1_X] = bag1_params.X;
    (*d)[names::bag1_Lsec] = bag1_params.Lsec;
    (*d)[names::bag1_LprN] = bag1_params.LprN;

    (*d)[names::bag2_beta0] = bag2_params.beta0;
    (*d)[names::bag2_beta] = bag2_params.beta;
    (*d)[names::bag2_gamma] = bag2_params.gamma;
    (*d)[names::bag2_Ksr] = bag2_params.Ksr;
    (*d)[names::bag2_Kpr] = bag2_params.Kpr;
    (*d)[names::bag2_a] = bag2_params.a;
    (*d)[names::bag2_R] = bag2_params.R;
    (*d)[names::bag2_Lsr0] = bag2_params.Lsr0;
    (*d)[names::bag2_Lpr0] = bag2_params.Lpr0;
    (*d)[names::bag2_G] = bag2_params.G;
    (*d)[names::bag2_LsrN] = bag2_params.LsrN;
    (*d)[names::bag2_X] = bag2_params.X;
    (*d)[names::bag2_Lsec] = bag2_params.Lsec;
    (*d)[names::bag2_LprN] = bag2_params.LprN;

    (*d)[names::chain_beta0] = chain_params.beta0;
    (*d)[names::chain_beta] = chain_params.beta;
    (*d)[names::chain_gamma] = chain_params.gamma;
    (*d)[names::chain_Ksr] = chain_params.Ksr;
    (*d)[names::chain_Kpr] = chain_params.Kpr;
    (*d)[names::chain_a] = chain_params.a;
    (*d)[names::chain_R] = chain_params.R;
    (*d)[names::chain_Lsr0] = chain_params.Lsr0;
    (*d)[names::chain_Lpr0] = chain_params.Lpr0;
    (*d)[names::chain_G] = chain_params.G;
    (*d)[names::chain_LsrN] = chain_params.LsrN;
    (*d)[names::chain_X] = chain_params.X;
    (*d)[names::chain_Lsec] = chain_params.Lsec;
    (*d)[names::chain_LprN] = chain_params.LprN;

}

void muscle_spindle::Parameters_::set(const DictionaryDatum& d) {

    updateValue<double>(d, names::L, L);
    updateValue<double>(d, names::dL, dL);

    updateValue<bool>(d, names::primary, primary);

    updateValue<double>(d, names::tau_dyn, tau_dyn);
    updateValue<double>(d, names::a_dyn, a_dyn);
    updateValue<double>(d, names::tau_st, tau_st);
    updateValue<double>(d, names::a_st, a_st);

    if ( L <= 0 )
        throw nest::BadProperty("The muscle length must be positive.");

    updateValue<double>(d, names::bag1_beta0, bag1_params.beta0);
    updateValue<double>(d, names::bag1_beta, bag1_params.beta);
    updateValue<double>(d, names::bag1_gamma, bag1_params.gamma);
    updateValue<double>(d, names::bag1_Ksr, bag1_params.Ksr);
    updateValue<double>(d, names::bag1_Kpr, bag1_params.Kpr);
    updateValue<double>(d, names::bag1_a, bag1_params.a);
    updateValue<double>(d, names::bag1_R, bag1_params.R);
    updateValue<double>(d, names::bag1_Lsr0, bag1_params.Lsr0);
    updateValue<double>(d, names::bag1_Lpr0, bag1_params.Lpr0);
    updateValue<double>(d, names::bag1_G, bag1_params.G);
    updateValue<double>(d, names::bag1_LsrN, bag1_params.LsrN);
    updateValue<double>(d, names::bag1_X, bag1_params.X);
    updateValue<double>(d, names::bag1_Lsec, bag1_params.Lsec);
    updateValue<double>(d, names::bag1_LprN, bag1_params.LprN);

    updateValue<double>(d, names::bag2_beta0, bag2_params.beta0);
    updateValue<double>(d, names::bag2_beta, bag2_params.beta);
    updateValue<double>(d, names::bag2_gamma, bag2_params.gamma);
    updateValue<double>(d, names::bag2_Ksr, bag2_params.Ksr);
    updateValue<double>(d, names::bag2_Kpr, bag2_params.Kpr);
    updateValue<double>(d, names::bag2_a, bag2_params.a);
    updateValue<double>(d, names::bag2_R, bag2_params.R);
    updateValue<double>(d, names::bag2_Lsr0, bag2_params.Lsr0);
    updateValue<double>(d, names::bag2_Lpr0, bag2_params.Lpr0);
    updateValue<double>(d, names::bag2_G, bag2_params.G);
    updateValue<double>(d, names::bag2_LsrN, bag2_params.LsrN);
    updateValue<double>(d, names::bag2_X, bag2_params.X);
    updateValue<double>(d, names::bag2_Lsec, bag2_params.Lsec);
    updateValue<double>(d, names::bag2_LprN, bag2_params.LprN);

    updateValue<double>(d, names::chain_beta0, chain_params.beta0);
    updateValue<double>(d, names::chain_beta, chain_params.beta);
    updateValue<double>(d, names::chain_gamma, chain_params.gamma);
    updateValue<double>(d, names::chain_Ksr, chain_params.Ksr);
    updateValue<double>(d, names::chain_Kpr, chain_params.Kpr);
    updateValue<double>(d, names::chain_a, chain_params.a);
    updateValue<double>(d, names::chain_R, chain_params.R);
    updateValue<double>(d, names::chain_Lsr0, chain_params.Lsr0);
    updateValue<double>(d, names::chain_Lpr0, chain_params.Lpr0);
    updateValue<double>(d, names::chain_G, chain_params.G);
    updateValue<double>(d, names::chain_LsrN, chain_params.LsrN);
    updateValue<double>(d, names::chain_X, chain_params.X);
    updateValue<double>(d, names::chain_Lsec, chain_params.Lsec);
    updateValue<double>(d, names::chain_LprN, chain_params.LprN);

}

void muscle_spindle::State_::get(DictionaryDatum& d) const {

    (*d)[names::primary_rate] = primary_afferent_rate;
    (*d)[names::secondary_rate] = secondary_afferent_rate;

    (*d)[names::T_bag1] = T_bag1;
    (*d)[names::T_bag2] = T_bag2;
    (*d)[names::T_chain] = T_chain;

}

void muscle_spindle::State_::set(const DictionaryDatum& d) {

    updateValue<double>(d, names::primary_rate, primary_afferent_rate );
    updateValue<double>(d, names::secondary_rate, secondary_afferent_rate );

}

muscle_spindle::Buffers_::Buffers_(muscle_spindle& n)
    :logger_(n) {}

muscle_spindle::Buffers_::Buffers_(const Buffers_& b, muscle_spindle& n)
    : spikes_(b.spikes_), logger_(n) {}



/* ----------------------------------------------------------------
 * Default and copy constructor for spindle model
 * ---------------------------------------------------------------- */

muscle_spindle::muscle_spindle()
    :Archiving_Node(),
      P_(),
      S_(P_),
      B_(*this) {

    recordablesMap_.create();

}

muscle_spindle::muscle_spindle(const muscle_spindle& n)
    :Archiving_Node(n),
     P_(n.P_),
     S_(n.S_),
     B_(n.B_, *this) {}


/* ----------------------------------------------------------------
 * Spindle initialization functions
 * ---------------------------------------------------------------- */

void muscle_spindle::init_state_(const Node& proto) {

    const muscle_spindle& pr = downcast<muscle_spindle>(proto);
    S_ = pr.S_;

}

void muscle_spindle::init_buffers_() {

    B_.spikes_.resize(2);
    B_.logger_.reset();

}

void muscle_spindle::calibrate() {

    B_.logger_.init();

    V_.int_time = Time::get_resolution().get_ms()/1000.0;

    // compute decay and init values for fusimotor spike integration
    double timefactor = 1.0/Time::get_resolution().get_ms();  // we should use this because we are dealing with fractions of milli
    V_.spike_decay_dyn = std::exp(-1.0/P_.tau_dyn/timefactor);
    V_.spike_init_dyn = P_.a_dyn*P_.tau_dyn*(1.0-V_.spike_decay_dyn) * timefactor;

    V_.spike_decay_st = std::exp(-1.0/P_.tau_st/timefactor);
    V_.spike_init_st = P_.a_st*P_.tau_st*(1.0-V_.spike_decay_st) * timefactor;

}

/* ----------------------------------------------------------------
 * Update and spike handling functions
 * ---------------------------------------------------------------- */

double muscle_spindle::fiber_tension(muscle_spindle::spindle_param_t* p, double f, double L, double dL, double& T) {


    // dynamic paremeters
    double beta = p->beta0 + p->beta*f;
    double gamma = p->gamma*f;
    double C = dL < 0 ? 0.42 : 1.0;

    // compute dT
    double Lpr = L - p->Lsr0 - T/p->Ksr;
    double left = (T - p->Kpr*(Lpr - p->Lpr0) - gamma) / (beta*C*(Lpr - p->R));
    double sg = left < 0 ? -1.0 : 1.0;
    double ab = left < 0 ? -left : left;
    double dT = (dL - sg*std::pow(ab, p->a))*p->Ksr;

    // integration step
    T += dT * V_.int_time;

    return T;

}

double muscle_spindle::primary_afferent(double T, muscle_spindle::spindle_param_t* p) {

    // compute rate
    double rate = T/p->Ksr - (p->LsrN - p->Lsr0);
    double sat_rate = rate < 0 ? 0.0 : rate;
    double ret = p->G*sat_rate;
    return ret;

}

double muscle_spindle::secondary_afferent(double T, double L, muscle_spindle::spindle_param_t* p) {

    // compute rate
    double TKsr = T/p->Ksr;

    double rate = p->X * (p->Lsec/p->Lsr0) * (TKsr - (p->LsrN - p->Lsr0));
    rate += (1-p->X) * (p->Lsec/p->Lpr0) * (L - TKsr - p->Lsr0 - p->LprN);
    double sat_rate = rate < 0 ? 0.0 : rate;
    double ret = p->G*sat_rate;
    return ret;

}

void muscle_spindle::update(Time const& slice_origin,
                            const long from_step,
                            const long to_step) {


    for ( long lag = from_step; lag < to_step; ++lag ) {

        // fusimotor activation
        S_.f_dyn = S_.f_dyn*V_.spike_decay_dyn + (1-S_.f_dyn)*B_.spikes_[0].get_value(lag)*V_.spike_init_dyn;
        S_.f_st = S_.f_st*V_.spike_decay_st + (1-S_.f_st)*B_.spikes_[1].get_value(lag)*V_.spike_init_st;

        // compute rate of fibers
        double rate_bag1 = primary_afferent(fiber_tension(&P_.bag1_params, S_.f_dyn, P_.L, P_.dL, S_.T_bag1), &P_.bag1_params);
        double rate_bag2 = secondary_afferent(fiber_tension(&P_.bag2_params, S_.f_st, P_.L, P_.dL, S_.T_bag2), P_.L, &P_.bag2_params);
        double rate_chain = secondary_afferent(fiber_tension(&P_.chain_params, 0.829*S_.f_st, P_.L, P_.dL, S_.T_chain), P_.L, &P_.chain_params);

        // primary and secondary afferent rates
        S_.secondary_afferent_rate = rate_bag2 + rate_chain;

        if (S_.secondary_afferent_rate > rate_bag1)
            S_.primary_afferent_rate = S_.secondary_afferent_rate + 0.156*rate_bag1;
        else
            S_.primary_afferent_rate = rate_bag1 + 0.156*S_.secondary_afferent_rate;

        // configure Poisson device
        if (P_.primary)
            V_.rate = S_.primary_afferent_rate;
        else
            V_.rate = S_.secondary_afferent_rate;

        // poisson firing
        if (V_.rate > 0.0) {
            poisson_dev_.set_lambda(Time::get_resolution().get_ms() * V_.rate * 1e-3);
            librandom::RngPtr rng = kernel().rng_manager.get_rng( get_thread() );
            long n_spikes = poisson_dev_.ldev( rng );
            if (n_spikes > 0) {
                SpikeEvent se;
                se.set_multiplicity( n_spikes );
                kernel().event_delivery_manager.send( *this, se, lag );
            }
        }


        // log membrane potential (?)
        B_.logger_.record_data( slice_origin.get_steps() + lag );

    }

}


/* ----------------------------------------------------------------
 * Event handlers
 * ---------------------------------------------------------------- */

void muscle::muscle_spindle::handle(SpikeEvent& e) {

    assert( e.get_delay() > 0 );

    for ( size_t i = 0; i < 2; ++i )
    {
        if ( P_.receptor_types_[ i ] == e.get_rport() )
        {
            B_.spikes_[ i ].add_value( e.get_rel_delivery_steps( kernel().simulation_manager.get_slice_origin() ),
                                       e.get_weight() * e.get_multiplicity() );
        }
    }
}

// Do not move this function as inline to h-file. It depends on
// universal_data_logger_impl.h being included here.
void muscle::muscle_spindle::handle(DataLoggingRequest& e) {

    B_.logger_.handle( e ); // the logger does this for us

}

}
