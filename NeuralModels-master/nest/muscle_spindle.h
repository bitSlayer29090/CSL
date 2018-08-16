/*
 *  muscle_spindle.h
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

#ifndef MUSCLE_SPINDLE_H
#define MUSCLE_SPINDLE_H

#include <vector>

// Includes from nestkernel:
#include "archiving_node.h"
#include "connection.h"
#include "event.h"
#include "ring_buffer.h"
#include "universal_data_logger.h"
#include "normal_randomdev.h"
#include "poisson_randomdev.h"

// Includes from sli:
#include "dictdatum.h"

namespace muscle {

/* BeginDocumentation
Name: muscle_spindle - Muscle spindle model, with gamma fusimotor drive.

Description:

 muscle_spindle is the implementation of the muscle spindle model
 described in [1]. The model is capable of replicating the activity of
 primary and secondary afferent fibers (Ia and II), under dynamic and
 static gamma-motoneurons drive. The output is computed simulating the
 activity of bag1, bag2 and chain intrafusal fibers in response to
 muscle stretches.

 The model has two receptor ports, to distinguish between the two
 different stimulations:
    1 - dynamic gamma
    2 - static gamma

 The length and stretch speed of the muscle can be set by changing the
 L and dL parameters.

 For a complete list of parameters, see [1] and [2].

References:
[1] Vannucci L, Falotico F & Laschi C (2017) Proprioceptive feedback through
    a neuromorphic muscle spindle model. Frontiers in Neuroscience.
[2] Mileusnic M P, Brown I E, Lan N, & Loeb G E (2006) Mathematical models
    of proprioceptors. I. Control and transduction in the muscle spindle.
    Journal of neurophysiology 96, 1772–1788.

Sends: SpikeEvent

Receives: SpikeEvent

Author: Vannucci, 2017
*/
class muscle_spindle : public nest::Archiving_Node
{
public:
    /**
     * The constructor is only used to create the model prototype in the model
     * manager.
     */
    muscle_spindle();

    /**
     * The copy constructor is used to create model copies and instances of the
     * model.
     * @node The copy constructor needs to initialize the parameters and the
     * state.
     *       Initialization of buffers and interal variables is deferred to
     *       @c init_buffers_() and @c calibrate().
     */
    muscle_spindle(const muscle_spindle& n);

    /**
     * Import sets of overloaded virtual functions.
     * This is necessary to ensure proper overload and overriding resolution.
     * @see http://www.gotw.ca/gotw/005.htm.
     */
    using nest::Node::handle;
    using nest::Node::handles_test_event;

    /**
     * Used to validate that we can send SpikeEvent to desired target:port.
     */
    virtual nest::port send_test_event(nest::Node& target, nest::port receptor_type, nest::synindex, bool) override;

    /**
     * @defgroup mynest_handle Functions handling incoming events.
     * We tell nest that we can handle incoming events of various types by
     * defining @c handle() and @c connect_sender() for the given event.
     * @{
     */
    virtual void handle(nest::SpikeEvent& e) override;         //! accept spikes
    virtual void handle(nest::DataLoggingRequest& e) override; //! allow recording with multimeter

    virtual nest::port handles_test_event(nest::SpikeEvent&, nest::port receptor_type) override;
    virtual nest::port handles_test_event(nest::DataLoggingRequest& dlr, nest::port receptor_type) override;
    /** @} */

    virtual void get_status(DictionaryDatum& d) const override;
    virtual void set_status(const DictionaryDatum& d) override;

private:

    //! Reset state of neuron.
    virtual void init_state_(const Node& proto) override;

    //! Reset internal buffers of neuron.
    virtual void init_buffers_() override;

    //! Initialize auxiliary quantities, leave parameters and state untouched.
    virtual void calibrate() override;

    //! Take neuron through given time interval
    virtual void update(nest::Time const& slice_origin, const long from_step, const long to_step) override;

    // The next two classes need to be friends to access the State_ class/member
    friend class nest::RecordablesMap<muscle_spindle>;
    friend class nest::UniversalDataLogger<muscle_spindle>;

    // random generator for more realistic spike generation
    librandom::PoissonRandomDev poisson_dev_;


    /**
     * Parameters of the fibers.
     */
    struct spindle_param_t {

        double beta0;
        double beta;
        double gamma;
        double Ksr;
        double Kpr;
        double a;
        double R;
        double Lsr0;
        double Lpr0;
        double G;
        double LsrN;

        // secondary only
        double X;
        double Lsec;
        double LprN;

    };

    /**
     * Free parameters of the spindle model, can be set through @c SetStatus.
     */
    struct Parameters_ {

        double L;
        double dL;

        bool primary;

        spindle_param_t bag1_params;
        spindle_param_t bag2_params;
        spindle_param_t chain_params;

        // fusimotor activation
        std::vector< long > receptor_types_;
        size_t num_of_receptors_;
        double tau_dyn;
        double a_dyn;
        double tau_st;
        double a_st;


        //! Initialize parameters to their default values.
        Parameters_();

        //! Store parameter values in dictionary.
        void get(DictionaryDatum& d) const;

        //! Set parameter values from dictionary.
        void set(const DictionaryDatum& d);
    };

    /**
     * Dynamic state of the spindle.
     *
     * These are the state variables that are advanced in time by calls to
     * @c update().
     */
    struct State_ {

        double primary_afferent_rate;
        double secondary_afferent_rate;

        // previous values of T for integration
        double T_bag1;
        double T_bag2;
        double T_chain;

        // fusimotor activation
        double f_dyn;
        double f_st;

        /**
         * Construct new default State_ instance.
         */
        State_(const Parameters_&);

        /** Store state values in dictionary. */
        void get(DictionaryDatum& d) const;

        /**
         * Set parameters from dictionary.
         */
        void set(const DictionaryDatum& d);
    };

    /**
     * Buffers for incoming spikes.
     */
    struct Buffers_ {

        Buffers_(muscle_spindle& n);
        Buffers_(const Buffers_& b, muscle_spindle& n);

        // dynamic == 1, static == 2
        std::vector<nest::RingBuffer> spikes_;

        //! Logger for all analog data
        nest::UniversalDataLogger<muscle_spindle> logger_;
    };

    /**
     * Internal variables of the model.
     */
    struct Variables_ {
        double spike_init_dyn;
        double spike_decay_dyn;
        double spike_init_st;
        double spike_decay_st;

        double rate;

        // integration interval
        double int_time;
    };

    /**
     * @defgroup Access functions for UniversalDataLogger.
     * @{
     */
    //! Read out the primary afferent rate
    double get_p_rate_() const {
        return S_.primary_afferent_rate;
    }

    //! Read out the secondary afferent rate
    double get_s_rate_() const {
        return S_.secondary_afferent_rate;
    }
    /** @} */

    /**
     * @defgroup pif_members Member variables of neuron model.
     * @{
     */
    Parameters_ P_; //!< Free parameters.
    State_ S_;      //!< Dynamic state.
    Variables_ V_;  //!< Internal Variables
    Buffers_ B_;    //!< Buffers.

    //! Mapping of recordables names to access functions
    static nest::RecordablesMap<muscle_spindle> recordablesMap_;

    /** @} */

    //! computes new fiber tension, given the current inputs
    double fiber_tension(muscle::muscle_spindle::spindle_param_t* p, double f, double L, double dL, double& T);

    //! computes primary afferent rate, giving the fiber tension
    double primary_afferent(double T, muscle::muscle_spindle::spindle_param_t* p);

    //! computes secondary afferent rate, giving the fiber tension
    double secondary_afferent(double T, double L, muscle::muscle_spindle::spindle_param_t* p);
};

inline nest::port muscle::muscle_spindle::send_test_event(nest::Node& target,
                                                          nest::port receptor_type,
                                                          nest::synindex,
                                                          bool) {

    // It confirms that the target of connection @c c accepts @c SpikeEvent on
    // the given @c receptor_type.
    nest::SpikeEvent e;
    e.set_sender( *this );
    return target.handles_test_event( e, receptor_type );

}

inline nest::port muscle::muscle_spindle::handles_test_event(nest::SpikeEvent&,
                                                             nest::port receptor_type) {

    // It confirms to the connection management system that we are able
    // to handle @c SpikeEvent on ports 1 and 2.
    if ( receptor_type <= 0 || receptor_type > static_cast< nest::port >( P_.num_of_receptors_ ) )
        throw nest::IncompatibleReceptorType( receptor_type, get_name(), "SpikeEvent" );

    return receptor_type;

}

inline nest::port muscle::muscle_spindle::handles_test_event(nest::DataLoggingRequest& dlr,
                                                             nest::port receptor_type) {

    // It confirms to the connection management system that we are able
    // to handle @c DataLoggingRequest on port 0.
    // The function also tells the built-in UniversalDataLogger that this node
    // is recorded from and that it thus needs to collect data during simulation.
    if ( receptor_type != 0 )
        throw nest::UnknownReceptorType( receptor_type, get_name() );

    return B_.logger_.connect_logging_device( dlr, recordablesMap_ );

}

inline void muscle_spindle::get_status(DictionaryDatum& d) const {

    // get our own parameter and state data
    P_.get( d );
    S_.get( d );

    // get information managed by parent class
    Archiving_Node::get_status( d );

    ( *d )[ nest::names::recordables ] = recordablesMap_.get_list();

}

inline void muscle_spindle::set_status(const DictionaryDatum& d) {

    Parameters_ ptmp = P_; // temporary copy in case of errors
    ptmp.set(d);           // throws if BadProperty
    State_ stmp = S_;      // temporary copy in case of errors
    stmp.set(d);           // throws if BadProperty

    // We now know that (ptmp, stmp) are consistent. We do not
    // write them back to (P_, S_) before we are also sure that
    // the properties to be set in the parent class are internally
    // consistent.
    Archiving_Node::set_status(d);

    // if we get here, temporaries contain consistent set of properties
    P_ = ptmp;
    S_ = stmp;
}

} // namespace

#endif /* #ifndef MUSCLE_SPINDLE_H */
