#include "spindle_model.h"

#include <debug.h>

#include <string.h>
#include <random.h>

#include "../fp_math.h"

static global_neuron_params_pointer_t global_params;

//static REAL rate;

//#define BUF_SIZE 30
//REAL sm_buf[BUF_SIZE];
//uint8_t sm_idx;
//uint8_t first_time;


// parameters
typedef struct spindle_param_t {

    REAL beta0;
    REAL beta;
    REAL gamma;
    REAL Ksr;
    REAL Kpr;
    REAL a;
    REAL R;
    REAL Lsr0;
    REAL Lpr0;
    REAL G;// = 20000;
    REAL LsrN;// = 0.0423;

    // secondary only
    REAL X;
    REAL Lsec;
    REAL LprN;

} spindle_param_t;

spindle_param_t bag1_params;
spindle_param_t bag2_params;
spindle_param_t chain_params;

const REAL CL = REAL_CONST(1.0);
const REAL CS = REAL_CONST(0.42);

const REAL S = 0.156;

REAL int_rem[3];


// debug value that will be printed by neuron_model_get_membrane_voltage
REAL dbg;


// debug
const int32_t poisson = 1;

void neuron_model_set_global_neuron_params(
        global_neuron_params_pointer_t params) {

    // parameters from outside
    global_params = params;

    global_params->int_time = fp_div(1.0k, params->machine_time_step);

//    sm_idx = 0;

//    first_time = 1;

    // set up parameters
    bag1_params.beta0 = REAL_CONST(0.0605);
    bag1_params.beta = REAL_CONST(0.2592);
    bag1_params.gamma = REAL_CONST(0.0289);
    bag1_params.Ksr = REAL_CONST(10.4649);
    bag1_params.Kpr = REAL_CONST(0.1500);
    bag1_params.a = REAL_CONST(3.333333);
    bag1_params.R = REAL_CONST(0.46);
    bag1_params.Lsr0 = REAL_CONST(0.04);
    bag1_params.Lpr0 = REAL_CONST(0.76);
    bag1_params.G = REAL_CONST(2000.0);  // actually G/10, because it could not be represented
    bag1_params.LsrN = REAL_CONST(0.0423);
    bag1_params.X = REAL_CONST(0.0);
    bag1_params.Lsec = REAL_CONST(0.0);
    bag1_params.LprN = REAL_CONST(0.0);

    bag2_params.beta0 = REAL_CONST(0.0822);
    bag2_params.beta = REAL_CONST(-0.0460);
    bag2_params.gamma = REAL_CONST(0.0636);
    bag2_params.Ksr = REAL_CONST(10.4649);
    bag2_params.Kpr = REAL_CONST(0.1500);
    bag2_params.a = REAL_CONST(3.333333);
    bag2_params.R = REAL_CONST(0.46);
    bag2_params.Lsr0 = REAL_CONST(0.04);
    bag2_params.Lpr0 = REAL_CONST(0.76);
    bag2_params.G = REAL_CONST(1000.0);  // actually G/10, because it could not be represented
    bag2_params.LsrN = REAL_CONST(0.0423);
    bag2_params.X = REAL_CONST(0.7);
    bag2_params.Lsec = REAL_CONST(0.04);
    bag2_params.LprN = REAL_CONST(0.89);

    chain_params.beta0 = REAL_CONST(0.0822);
    chain_params.beta = REAL_CONST(-0.0690);
    chain_params.gamma = REAL_CONST(0.0954);
    chain_params.Ksr = REAL_CONST(10.4649);
    chain_params.Kpr = REAL_CONST(0.1500);
    chain_params.a = REAL_CONST(3.333333);
    chain_params.R = REAL_CONST(0.46);
    chain_params.Lsr0 = REAL_CONST(0.04);
    chain_params.Lpr0 = REAL_CONST(0.76);
    chain_params.G = REAL_CONST(1000.0);  // actually G/10, because it could not be represented
    chain_params.LsrN = REAL_CONST(0.0423);
    chain_params.X = REAL_CONST(0.7);
    chain_params.Lsec = REAL_CONST(0.04);
    chain_params.LprN = REAL_CONST(0.89);

    // not initialized
    global_params->primary_spike_timer = -1;
    global_params->secondary_spike_timer = -1;

    // debug
    dbg = 0.0k;

    // initialization
    global_params->T_bag1 = REAL_CONST(0.0);
    global_params->T_bag2 = REAL_CONST(0.0);
    global_params->T_chain = REAL_CONST(0.0);

}

bool neuron_model_state_update(neuron_pointer_t neuron) {

    if (poisson) {

        REAL rate = neuron->primary ? global_params->primary_afferent_rate : global_params->secondary_afferent_rate;

        uint32_t rr = mars_kiss32() & 0x00007FFF;
        REAL r;
        memcpy(&r, &rr, sizeof(REAL));
//        log_info("random = %k", r);
        if (r <= global_params->int_time*rate)
            return 1;
        else
            return 0;

    } else {

        unsigned int relevant_timer;
        if (neuron->primary)
            relevant_timer = global_params->primary_spike_timer;
        else
            relevant_timer = global_params->secondary_spike_timer;


        if (relevant_timer == -1) {
            return 0;
        }

        if (relevant_timer == 0)
            return 0;

        if (relevant_timer > 0 && neuron->timer == -1) {
            neuron->timer = relevant_timer;
        }

        if (relevant_timer > 0 && relevant_timer < neuron->timer) {
            neuron->timer = relevant_timer;
        }

        neuron->timer--;

    }

//    neuron->timer = mars_kiss32();

//    log_info("spike_timer: %d, mytimer: %d", primary_spike_timer, neuron->timer);

    return neuron->timer == 0 ? 1 : 0;
}

state_t neuron_model_get_membrane_voltage(neuron_pointer_t neuron) {

    // TODO: Get the state value representing the membrane voltage
//    log_info("getting state: %f", neuron->V);
    return dbg;
//    return neuron->timer;
}

void neuron_model_has_spiked(neuron_pointer_t neuron) {

    // TODO: Perform operations required to reset the state after a spike
//    neuron->V = neuron->my_parameter;
    if (!poisson)
        neuron->timer = global_params->primary_spike_timer;
//    log_info("spike!!!");
}

void neuron_model_print_state_variables(restrict neuron_pointer_t neuron) {

    // TODO: Print all state variables
//    log_debug("V = %11.4k mv", neuron->V);
}

void neuron_model_print_parameters(restrict neuron_pointer_t neuron) {

    // TODO: Print all neuron parameters
//    log_debug("my parameter = %11.4k mv", neuron->my_parameter);
}

static REAL fiber_tension(spindle_param_t* p, REAL f, REAL L, REAL dL, REAL* T, uint8_t idx) {

    // dynamic paremeters
    REAL beta = p->beta0 + p->beta*f;
    REAL gamma = p->gamma*f;
    REAL C = dL < 0 ? CS : CL;

    // compute dT
    REAL Lpr = L - p->Lsr0 - fp_div(*T, p->Ksr);
    REAL left = fp_div(*T - p->Kpr*(Lpr - p->Lpr0) - gamma, beta*C*(Lpr - p->R));
    REAL sg = left < 0 ? -1.0k : 1.0k;
    REAL ab = left < 0 ? -left : left;
    REAL dT = (dL - sg*fp_pow(ab, p->a))*p->Ksr;

    // integration step
    REAL inc = dT+int_rem[idx];
    REAL absinc = inc < 0 ? -inc : inc;
    if (absinc < REAL_CONST(0.04))
        int_rem[idx] += dT;
    else {
        *T += (dT+int_rem[idx]) * global_params->int_time;
        int_rem[idx] = REAL_CONST(0.0);
    }
//    return *T;

    return *T;

}

static REAL primary_afferent(REAL T, spindle_param_t* p) {

    // compute rate
    REAL rate = fp_div(T, p->Ksr) - (p->LsrN - p->Lsr0);
    REAL sat_rate = rate < 0 ? 0.0k : rate;
    REAL ret = p->G*sat_rate;
    ret *= REAL_CONST(10.0);
//    log_info("rate: %x", ret);
//    ret *= REAL_CONST(2.0);
    return ret;

}

static REAL secondary_afferent(REAL T, REAL L, spindle_param_t* p) {

    // compute rate
    REAL TKsr = fp_div(T, p->Ksr);

    REAL rate = p->X * fp_div(p->Lsec, p->Lsr0) * (TKsr - (p->LsrN - p->Lsr0));
    rate += (1-p->X) * fp_div(p->Lsec, p->Lpr0) * (L - TKsr - p->Lsr0 - p->LprN);
    REAL sat_rate = rate < 0 ? 0.0k : rate;
    REAL ret = p->G*sat_rate;
    ret *= REAL_CONST(10.0);
    return ret;

}

void spindle_model_compute_rate(REAL f_dyn_bag1, REAL f_st_bag2, REAL f_st_chain, REAL L, REAL dL) {

    REAL rate_bag1 = primary_afferent(fiber_tension(&bag1_params, f_dyn_bag1, L, dL, &(global_params->T_bag1), 0), &bag1_params);
    REAL rate_bag2 = secondary_afferent(fiber_tension(&bag2_params, f_st_bag2, L, dL, &(global_params->T_bag2), 1), L, &bag2_params);
    REAL rate_chain = secondary_afferent(fiber_tension(&chain_params, f_st_chain, L, dL, &(global_params->T_chain), 2), L, &chain_params);

    global_params->secondary_afferent_rate = rate_bag2 + rate_chain;

    if (global_params->secondary_afferent_rate > rate_bag1)
        global_params->primary_afferent_rate = global_params->secondary_afferent_rate + S*rate_bag1;
    else
        global_params->primary_afferent_rate = rate_bag1 + S*global_params->secondary_afferent_rate;


    if (!poisson) {

        // rates to timer
        if (REAL_COMPARE(global_params->primary_afferent_rate, ==, REAL_CONST(0.0)))
            global_params->primary_spike_timer = 0;
        else
            global_params->primary_spike_timer = (int32_t)(fp_div(REAL_CONST(1.0), global_params->primary_afferent_rate)*REAL_CONST(1000.0));

        if (REAL_COMPARE(global_params->secondary_afferent_rate, ==, REAL_CONST(0.0)))
            global_params->secondary_spike_timer = 0;
        else
            global_params->secondary_spike_timer = (int32_t)(fp_div(REAL_CONST(1.0), global_params->secondary_afferent_rate)*REAL_CONST(1000.0));

    //    log_info("afferent rate: %k, spike timer: %d", primary_afferent_rate, primary_spike_timer);

    }

//    dbg = f_dyn_bag1;
    dbg = global_params->primary_afferent_rate;
//    dbg = dT;


//    sm_buf[sm_idx] = _f_dyn_bag1;
//    sm_idx++;
//    if (sm_idx >= BUF_SIZE)
//        sm_idx = 0;

//    REAL f_dyn_bag1 = REAL_CONST(0.0);
//    for (uint8_t i = 0; i < BUF_SIZE; i++) {
//        f_dyn_bag1 += sm_buf[i];
//    }
//    f_dyn_bag1 = f_dyn_bag1 * 0.033333k;//fp_div(f_dyn_bag1, REAL_CONST(BUF_SIZE));





//    log_info("rate update: %k %k %k %k %k", f_dyn_bag1, f_st_bag2, f_st_chain, L, dL);

//    REAL beta = REAL_CONST(0.0605) + REAL_CONST(0.2592)*f_dyn_bag1;
//    REAL gamma = REAL_CONST(0.0489)*f_dyn_bag1;
//    REAL Ksr = REAL_CONST(10.4649);
//    REAL Kpr = REAL_CONST(0.1500);
//    REAL a = REAL_CONST(3.333333);
//    REAL C = dL < 0 ? REAL_CONST(0.42) : REAL_CONST(1.0);
//    REAL R = REAL_CONST(0.46);
//    REAL Lsr0 = REAL_CONST(0.04);
//    REAL Lpr0 = REAL_CONST(0.76);


//    REAL Lpr = L - Lsr0 - fp_div(global_params->T,Ksr);
//    REAL left = fp_div(global_params->T-Kpr*(Lpr-Lpr0)-gamma, beta*C*(Lpr-R));
//    REAL sg = left < 0 ? -1.0k : 1.0k;
//    REAL ab = left < 0 ? -left : left;
//    REAL dT = (dL-sg*fp_pow(ab, a))*Ksr;

//    global_params->T += dT * 0.001k;





//    log_info("T = %k, dT = %k", global_params->T, dT);

//    REAL bs = dL-fp_div(global_params->dT, Ksr);
//    REAL s = bs < 0 ? REAL_CONST(-1.0) : REAL_CONST(1.0);
//    REAL abs = bs < 0 ? -bs : bs;
//    REAL ab = fp_pow(abs,a);
////    REAL ab = 30.0;
//    log_info("%k / %k == %k", global_params->dT, Ksr, fp_div(global_params->dT, Ksr));

//    log_info("bs = %k, s = %k, abs = %k, ab = %k", bs, s, abs, ab);


//    REAL mult = beta*C*s*ab;
////    s1615 add = mult*(L-Lsr0-R)+Kpr*(L-Lsr0-Lpr0)+gamma;


//    REAL T = fp_div(Ksr,(Ksr+mult+Kpr))*(mult*(L-Lsr0-R)+Kpr*(L-Lsr0-Lpr0)+gamma);

//    if (first_time) {
//        first_time = 0;
//    } else {
//        global_params->dT = 0.0k;// (T - global_params->T)*(REAL)global_params->machine_time_step;
//    }
//    global_params->T = T;

//    log_info("T = %k, dT = %k", global_params->T, global_params->dT);

////    log_info("%d", global_params->machine_time_step);


////    global_params->rate =
//    global_params->rate = T;

//    REAL d1 = beta*gamma+REAL_CONST(1.0);
//    REAL d3 = Ksr*Kpr;
//    int d2 = fx_div(d1,d3);

//    REAL d5 = REAL_CONST(2.0);
//    REAL d6 = REAL_CONST(3.0);

//    fix16_t aa, bb;
//    memcpy(&aa, &d1, sizeof(fix16_t));
//    memcpy(&bb, &d3, sizeof(fix16_t));

//    aa = (aa & 0x80000000) | (aa << 1);
//    bb = (bb & 0x80000000) | (bb << 1);

//    log_info("%k %k %k", beta, gamma, Ksr);
//    log_info("%k %k", d1, d3);
//    log_info("%k %k", d1, d3);
//    log_info("%f", fix16_div1(10, 2));
//    log_info("%d.%d %d.%d", d1 >> 15, (d1 << 17) >> 17, d3 >> 15, (d3 << 17) >> 17);
//    log_info("%k", fix16_div1(10, 2));
//    log_info("%k", fix16_div1(aa, bb));
//    log_info("%k", fix16_div2(d1, d3));

//    log_info("log(%k) = %k", REAL_CONST(0.1), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.1)))));
//    log_info("log(%k) = %k", REAL_CONST(0.2), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.2)))));
//    log_info("log(%k) = %k", REAL_CONST(0.3), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.3)))));
//    log_info("log(%k) = %k", REAL_CONST(0.4), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.4)))));
//    log_info("log(%k) = %k", REAL_CONST(0.5), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.5)))));
//    log_info("log(%k) = %k", REAL_CONST(0.6), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.6)))));
//    log_info("log(%k) = %k", REAL_CONST(0.7), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.7)))));
//    log_info("log(%k) = %k", REAL_CONST(0.8), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.8)))));
//    log_info("log(%k) = %k", REAL_CONST(0.9), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(0.9)))));
//    log_info("log(%k) = %k", REAL_CONST(1.0), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(1.0)))));
//    log_info("log(%k) = %k", REAL_CONST(10.0), fix16_to_real(fp_ln(real_to_fix16(REAL_CONST(10.0)))));

//    log_info("exp(%k) = %k", REAL_CONST(0.1), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.1)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.2), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.2)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.3), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.3)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.4), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.4)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.5), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.5)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.6), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.6)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.7), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.7)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.9), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.8)))));
//    log_info("exp(%k) = %k", REAL_CONST(0.9), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(0.9)))));
//    log_info("exp(%k) = %k", REAL_CONST(1.0), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(1.0)))));
//    log_info("exp(%k) = %k", REAL_CONST(1.5), fix16_to_real(fp_exp(real_to_fix16(REAL_CONST(1.5)))));

//    log_info("POW(0.1): %k", fp_pow(REAL_CONST(0.1), REAL_CONST(0.3)));
//    log_info("POW(0.2): %k", fp_pow(REAL_CONST(0.2), REAL_CONST(0.3)));
//    log_info("POW(0.3): %k", fp_pow(REAL_CONST(0.3), REAL_CONST(0.3)));
//    log_info("POW(0.4): %k", fp_pow(REAL_CONST(0.4), REAL_CONST(0.3)));
//    log_info("POW(0.5): %k", fp_pow(REAL_CONST(0.5), REAL_CONST(0.3)));
//    log_info("POW(0.6): %k", fp_pow(REAL_CONST(0.6), REAL_CONST(0.3)));
//    log_info("POW(0.7): %k", fp_pow(REAL_CONST(0.7), REAL_CONST(0.3)));
//    log_info("POW(0.8): %k", fp_pow(REAL_CONST(0.8), REAL_CONST(0.3)));
//    log_info("POW(0.9): %k", fp_pow(REAL_CONST(0.9), REAL_CONST(0.3)));
//    log_info("POW(1.0): %k", fp_pow(REAL_CONST(1.0), REAL_CONST(0.3)));
//    log_info("POW(1.5): %k", fp_pow(REAL_CONST(1.5), REAL_CONST(0.3)));

//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(1.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(2.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(3.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(4.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(5.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(6.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(7.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(8.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(9.0)))));
//    log_info("%k", fix16_to_real2(fp_ln(real_to_fix162(REAL_CONST(10.0)))));
//    log_info("%k", log(REAL_CONST(2.0)));
//    log_info("%k", fp_pow(d5, d6));

//    s1615 ret = global_params->rate;
//    log_info("%f", global_params->rate);
//    rate = tmp*add;
//    *((s1615*)global_params) = tmp*add;
//    global_params->rate = tmp*add;

//    s1615 ret = tmp*add;
//    *&(global_params->rate) = ret;
//    return ret;
//    global_params->rate = ret;
//    global_params->rate = tmp*add;
//    global_params->rate = Ksr/(Ksr+mult+Kpr)*(mult*(L-Lsr0-R)+Kpr*(L-Lsr0-Lpr0)+gamma);
//    REAL C3 = Ksr/(Ksr+mult+Kpr)*(mult*(L-Lsr0-R)+Kpr*(L-Lsr0-Lpr0)+gamma);
//    REAL C4 = Ksr/(Ksr+mult+Kpr)*(mult*(L-Lsr0-R)+Kpr*(L-Lsr0-Lpr0)+gamma);
//    return global_params->rate;
//    return tmp*add;

}

