#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#if defined USE_64_BIT_INT
#ifndef _MSC_VER
#include <inttypes.h>
#endif
#endif

#include <mpfi.h>
#include <mpfi_io.h>

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#ifndef Newxz
#  define Newxz(v,n,t) Newz(0,v,n,t)
#endif

#ifndef __gmpfr_default_rounding_mode
#define __gmpfr_default_rounding_mode mpfr_get_default_rounding_mode()
#endif

/* Has inttypes.h been included ?
              &&
 Do we have USE_64_BIT_INT ? */

int _has_inttypes(void) {
#ifdef _MSC_VER
return 0;
#else
#if defined USE_64_BIT_INT
return 1;
#else
return 0;
#endif
#endif
}

int _has_longlong(void) {
#ifdef USE_64_BIT_INT
    return 1;
#else
    return 0;
#endif
}

int _has_longdouble(void) {
#ifdef USE_LONG_DOUBLE
    return 1;
#else
    return 0;
#endif
}

/*******************************
Rounding Modes and Precision Handling
*******************************/

SV * RMPFI_BOTH_ARE_EXACT (pTHX_ int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_BOTH_ARE_EXACT");
     if(MPFI_BOTH_ARE_EXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_LEFT_IS_INEXACT (pTHX_ int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_LEFT_IS_INEXACT");
     if(MPFI_LEFT_IS_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_RIGHT_IS_INEXACT (pTHX_ int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_RIGHT_IS_INEXACT");
     if(MPFI_RIGHT_IS_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_BOTH_ARE_INEXACT (pTHX_ int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_BOTH_ARE_INEXACT");
     if(MPFI_BOTH_ARE_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

void _Rmpfi_set_default_prec(pTHX_ SV * p) {
     mpfr_set_default_prec((mp_prec_t)SvUV(p));
}

SV * Rmpfi_get_default_prec(pTHX) {
     return newSVuv(mpfr_get_default_prec());
}

void Rmpfi_set_prec(pTHX_ mpfi_t * op, SV * prec) {
     mpfi_set_prec(*op, (mp_prec_t)SvUV(prec));
}

SV * Rmpfi_get_prec(pTHX_ mpfi_t * op) {
     return newSVuv(mpfi_get_prec(*op));
}

SV * Rmpfi_round_prec(pTHX_ mpfi_t * op, SV * prec) {
     return newSViv(mpfi_round_prec(*op, (mp_prec_t)SvUV(prec)));
}

/*******************************
Initialization Functions
*******************************/

SV * Rmpfi_init(pTHX) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init_nobless(pTHX) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfi_init(*mpfi_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init2(pTHX_ SV * prec) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init2 (*mpfi_t_obj, (mp_prec_t)SvUV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init2_nobless(pTHX_ SV * prec) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init2_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfi_init2 (*mpfi_t_obj, (mp_prec_t)SvUV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

void DESTROY(pTHX_ mpfi_t * p) {
     mpfi_clear(*p);
     Safefree(p);
}

void Rmpfi_clear(pTHX_ mpfi_t * p) {
     mpfi_clear(*p);
     Safefree(p);
}

/*******************************
Assignment Functions
*******************************/

SV * Rmpfi_set (pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_set(*rop, *op));
}

SV * Rmpfi_set_ui (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_ui(*rop, SvUV(op)));
}

SV * Rmpfi_set_si (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_si(*rop, SvIV(op)));
}

SV * Rmpfi_set_d (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_d(*rop, SvNV(op)));
}

SV * Rmpfi_set_z (pTHX_ mpfi_t * rop, mpz_t * op) {
     return newSViv(mpfi_set_z(*rop, *op));
}

SV * Rmpfi_set_q (pTHX_ mpfi_t * rop, mpq_t * op) {
     return newSViv(mpfi_set_q(*rop, *op));
}

SV * Rmpfi_set_fr (pTHX_ mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_set_fr(*rop, *op));
}

SV * Rmpfi_set_str (pTHX_ mpfi_t * rop, SV * s, SV * base) {
     return newSViv(mpfi_set_str(*rop, SvPV_nolen(s), SvIV(base)));
}

void Rmpfi_swap (pTHX_ mpfi_t * x, mpfi_t * y) {
     mpfi_swap(*x, *y);
}

/*******************************
Combined Initialization and Assignment Functions
*******************************/

void Rmpfi_init_set(pTHX_ mpfi_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_ui(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_ui function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_ui(*mpfi_t_obj, (unsigned long)SvUV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_si(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_si function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_si(*mpfi_t_obj, (long)SvIV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_d(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_d function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_d(*mpfi_t_obj, (double)SvNV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_z(pTHX_ mpz_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_z function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_z(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_q(pTHX_ mpq_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_q function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_q(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_fr(pTHX_ mpfr_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_fr function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_fr(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_str(pTHX_ SV * q, SV * base) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

     if(ret < 0 || ret > 36 || ret == 1) croak("2nd argument supplied to Rmpfi_init_set str is out of allowable range");

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_str function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ret = mpfi_init_set_str(*mpfi_t_obj, SvPV_nolen(q), ret);

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

/**********************************
 The nobless variants
***********************************/

void Rmpfi_init_set_nobless(pTHX_ mpfi_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_ui_nobless(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_ui_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_ui(*mpfi_t_obj, (unsigned long)SvUV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_si_nobless(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_si_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_si(*mpfi_t_obj, (long)SvIV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_d_nobless(pTHX_ SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_d_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_d(*mpfi_t_obj, (double)SvNV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_z_nobless(pTHX_ mpz_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_z_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_z(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_q_nobless(pTHX_ mpq_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_q_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_q(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_fr_nobless(pTHX_ mpfr_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_fr_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_fr(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_str_nobless(pTHX_ SV * q, SV * base) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

     if(ret < 0 || ret > 36 || ret == 1) croak("2nd argument supplied to Rmpfi_init_set str is out of allowable range");

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_str_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ret = mpfi_init_set_str(*mpfi_t_obj, SvPV_nolen(q), ret);

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}


/*******************************
Interval Functions with Floating-point Results
*******************************/

SV * Rmpfi_diam_abs(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam_abs(*rop, *op));
}

SV * Rmpfi_diam_rel(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam_rel(*rop, *op));
}

SV * Rmpfi_diam(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam(*rop, *op));
}

SV * Rmpfi_mag(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mag(*rop, *op));
}

SV * Rmpfi_mig(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mig(*rop, *op));
}

SV * Rmpfi_mid(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mid(*rop, *op));
}

void Rmpfi_alea(pTHX_ mpfr_t * rop, mpfi_t * op) {
     mpfi_alea(*rop, *op);
}

/*******************************
Conversion Functions
*******************************/

SV * Rmpfi_get_d (pTHX_ mpfi_t * op) {
     return newSVnv(mpfi_get_d(*op));
}

void Rmpfi_get_fr(pTHX_ mpfr_t * rop, mpfi_t * op) {
     mpfi_get_fr(*rop, *op);
}

/*******************************
Basic Arithmetic Functions
*******************************/

SV * Rmpfi_add (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_add(*rop, *op1, *op2));
}

SV * Rmpfi_add_d (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_add_ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_add_si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_add_z (pTHX_ mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_add_z(*rop, *op1, *op2));
}

SV * Rmpfi_add_q (pTHX_ mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_add_q(*rop, *op1, *op2));
}

SV * Rmpfi_add_fr (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_add_fr(*rop, *op1, *op2));
}

SV * Rmpfi_sub (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_d (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_d_sub (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_d_sub(*rop, SvNV(op1), *op2));
}

SV * Rmpfi_sub_ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_ui(*rop, *op1, SvUV(op2)));
}
SV * Rmpfi_ui_sub (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_ui_sub(*rop, SvUV(op1), *op2));
}

SV * Rmpfi_sub_si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_si_sub (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_si_sub(*rop, SvIV(op1), *op2));
}

SV * Rmpfi_sub_z (pTHX_ mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_sub_z(*rop, *op1, *op2));
}

SV * Rmpfi_z_sub (pTHX_ mpfi_t * rop, mpz_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_z_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_q (pTHX_ mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_sub_q(*rop, *op1, *op2));
}

SV * Rmpfi_q_sub (pTHX_ mpfi_t * rop, mpq_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_q_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_fr (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_sub_fr(*rop, *op1, *op2));
}

SV * Rmpfi_fr_sub (pTHX_ mpfi_t * rop, mpfr_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_fr_sub(*rop, *op1, *op2));
}

SV * Rmpfi_mul (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_mul(*rop, *op1, *op2));
}

SV * Rmpfi_mul_d (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_mul_ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_mul_z (pTHX_ mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_mul_z(*rop, *op1, *op2));
}

SV * Rmpfi_mul_q (pTHX_ mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_mul_q(*rop, *op1, *op2));
}

SV * Rmpfi_mul_fr (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_mul_fr(*rop, *op1, *op2));
}

SV * Rmpfi_div (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_d (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_d_div (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_d_div(*rop, SvNV(op1), *op2));
}

SV * Rmpfi_div_ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_ui_div (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_ui_div(*rop, SvUV(op1), *op2));
}

SV * Rmpfi_div_si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_si_div (pTHX_ mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_si_div(*rop, SvIV(op1), *op2));
}

SV * Rmpfi_div_z (pTHX_ mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_div_z(*rop, *op1, *op2));
}

SV * Rmpfi_z_div (pTHX_ mpfi_t * rop, mpz_t * op1, mpfi_t *op2) {
     return newSViv(mpfi_z_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_q (pTHX_ mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_div_q(*rop, *op1, *op2));
}

SV * Rmpfi_q_div (pTHX_ mpfi_t * rop, mpq_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_q_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_fr (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_div_fr(*rop, *op1, *op2));
}

SV * Rmpfi_fr_div (pTHX_ mpfi_t * rop, mpfr_t *op1, mpfi_t * op2) {
     return newSViv(mpfi_fr_div(*rop, *op1, *op2));
}

SV * Rmpfi_neg(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_neg(*rop, *op));
}

SV * Rmpfi_sqr(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sqr(*rop, *op));
}

SV * Rmpfi_inv(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_inv(*rop, *op));
}

SV * Rmpfi_sqrt(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sqrt(*rop, *op));
}

SV * Rmpfi_abs(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_abs(*rop, *op));
}

SV * Rmpfi_mul_2exp (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2exp(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_2ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_2si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_div_2exp (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2exp(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_div_2ui (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_div_2si (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2si(*rop, *op1, SvIV(op2)));
}

/*******************************
Special Functions
*******************************/

SV * Rmpfi_log(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log(*rop, *op));
}

SV * Rmpfi_exp(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_exp(*rop, *op));
}

SV * Rmpfi_exp2(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_exp2(*rop, *op));
}

SV * Rmpfi_cos(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cos(*rop, *op));
}

SV * Rmpfi_sin(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sin(*rop, *op));
}

SV * Rmpfi_tan(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_tan(*rop, *op));
}

SV * Rmpfi_acos(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_acos(*rop, *op));
}

SV * Rmpfi_asin(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_asin(*rop, *op));
}

SV * Rmpfi_atan(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_atan(*rop, *op));
}

SV * Rmpfi_cosh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cosh(*rop, *op));
}

SV * Rmpfi_sinh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sinh(*rop, *op));
}

SV * Rmpfi_tanh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_tanh(*rop, *op));
}

SV * Rmpfi_acosh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_acosh(*rop, *op));
}

SV * Rmpfi_asinh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_asinh(*rop, *op));
}

SV * Rmpfi_atanh(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_atanh(*rop, *op));
}

SV * Rmpfi_log1p(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log1p(*rop, *op));
}

SV * Rmpfi_expm1(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_expm1(*rop, *op));
}

SV * Rmpfi_log2(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log2(*rop, *op));
}

SV * Rmpfi_log10(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log10(*rop, *op));
}

SV * Rmpfi_const_log2(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_const_log2(*op));
}

SV * Rmpfi_const_pi(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_const_pi(*op));
}

SV * Rmpfi_const_euler(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_const_euler(*op));
}

/*******************************
Comparison Functions
*******************************/

SV * Rmpfi_cmp (pTHX_ mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_cmp(*op1, *op2));
}

SV * Rmpfi_cmp_d (pTHX_ mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_d(*op1, SvNV(op2)));
}

SV * Rmpfi_cmp_ui (pTHX_ mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_ui(*op1, SvUV(op2)));
}

SV * Rmpfi_cmp_si (pTHX_ mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_si(*op1, SvIV(op2)));
}

SV * Rmpfi_cmp_z (pTHX_ mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_cmp_z(*op1, *op2));
}

SV * Rmpfi_cmp_q (pTHX_ mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_cmp_q(*op1, *op2));
}

SV * Rmpfi_cmp_fr (pTHX_ mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_cmp_fr(*op1, *op2));
}

SV * Rmpfi_is_pos(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_pos(*op));
}

SV * Rmpfi_is_strictly_pos(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_strictly_pos(*op));
}

SV * Rmpfi_is_nonneg(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_nonneg(*op));
}

SV * Rmpfi_is_neg(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_neg(*op));
}

SV * Rmpfi_is_strictly_neg(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_strictly_neg(*op));
}

SV * Rmpfi_is_nonpos(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_nonpos(*op));
}

SV * Rmpfi_is_zero(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_zero(*op));
}

SV * Rmpfi_has_zero(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_has_zero(*op));
}

SV * Rmpfi_nan_p(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_nan_p(*op));
}

SV * Rmpfi_inf_p(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_inf_p(*op));
}

SV * Rmpfi_bounded_p(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_bounded_p(*op));
}

/*******************************
Input and Output Functions
*******************************/

SV * _Rmpfi_out_str(pTHX_ FILE * stream, SV * base, SV * dig, mpfi_t * p) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("2nd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strS(pTHX_ FILE * stream, SV * base, SV * dig, mpfi_t * p, SV * suff) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("2nd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strP(pTHX_ SV * pre, FILE * stream, SV * base, SV * dig, mpfi_t * p) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strPS(pTHX_ SV * pre, FILE * stream, SV * base, SV * dig, mpfi_t * p, SV * suff) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * Rmpfi_inp_str(pTHX_ mpfi_t * p, FILE * stream, SV * base) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_inp_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_inp_str(*p, stream, (int)SvIV(base));
     return newSVuv(ret);
}

void Rmpfi_print_binary(pTHX_ mpfi_t * op) {
     mpfi_print_binary(*op);
}

/*******************************
Functions Operating on Endpoints
*******************************/

SV * Rmpfi_get_left(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_get_left(*rop, *op));
}

SV * Rmpfi_get_right(pTHX_ mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_get_right(*rop, *op));
}

SV * Rmpfi_revert_if_needed(pTHX_ mpfi_t * op) {
     return newSViv(mpfi_revert_if_needed(*op));
}

SV * Rmpfi_put (pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_put(*rop, *op));
}

SV * Rmpfi_put_d (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_d(*rop, SvNV(op)));
}

SV * Rmpfi_put_ui (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_ui(*rop, SvUV(op)));
}

SV * Rmpfi_put_si (pTHX_ mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_si(*rop, SvIV(op)));
}

SV * Rmpfi_put_z (pTHX_ mpfi_t * rop, mpz_t * op) {
     return newSViv(mpfi_put_z(*rop, *op));
}

SV * Rmpfi_put_q (pTHX_ mpfi_t * rop, mpq_t * op) {
     return newSViv(mpfi_put_q(*rop, *op));
}

SV * Rmpfi_put_fr (pTHX_ mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_put_fr(*rop, *op));
}

SV * Rmpfi_interv_d (pTHX_ mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_d(*rop, SvNV(op1), SvNV(op2)));
}

SV * Rmpfi_interv_ui (pTHX_ mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_ui(*rop, SvUV(op1), SvUV(op2)));
}

SV * Rmpfi_interv_si (pTHX_ mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_si(*rop, SvIV(op1), SvIV(op2)));
}

SV * Rmpfi_interv_z (pTHX_ mpfi_t * rop, mpz_t * op1, mpz_t * op2) {
     return newSViv(mpfi_interv_z(*rop, *op1, *op2));
}

SV * Rmpfi_interv_q (pTHX_ mpfi_t * rop, mpq_t * op1, mpq_t * op2) {
     return newSViv(mpfi_interv_q(*rop, *op1, *op2));
}

SV * Rmpfi_interv_fr (pTHX_ mpfi_t * rop, mpfr_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_interv_fr(*rop, *op1, *op2));
}

/*******************************
Set Functions on Intervals
*******************************/

SV * Rmpfi_is_strictly_inside (pTHX_ mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_is_strictly_inside(*op1, *op2));
}

SV * Rmpfi_is_inside (pTHX_ mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_is_inside(*op1, *op2));
}

SV * Rmpfi_is_inside_d (pTHX_ SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_d(SvNV(op2), *op1));
}

SV * Rmpfi_is_inside_ui (pTHX_ SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_ui(SvUV(op2), *op1));
}

SV * Rmpfi_is_inside_si (pTHX_ SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_si(SvIV(op2), *op1));
}

SV * Rmpfi_is_inside_z (pTHX_ mpz_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_z(*op2, *op1));
}

SV * Rmpfi_is_inside_q (pTHX_ mpq_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_q(*op2, *op1));
}

SV * Rmpfi_is_inside_fr (pTHX_ mpfr_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_fr(*op2, *op1));
}

SV * Rmpfi_is_empty (pTHX_ mpfi_t * op) {
     return newSViv(mpfi_is_empty(*op));
}

SV * Rmpfi_intersect (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_intersect(*rop, *op1, *op2));
}

SV * Rmpfi_union (pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_union(*rop, *op1, *op2));
}

/*******************************
Miscellaneous Interval Functions
*******************************/

SV * Rmpfi_increase (pTHX_ mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_increase(*rop, *op));
}

SV * Rmpfi_blow (pTHX_ mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_blow(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_bisect (pTHX_ mpfi_t * rop1, mpfi_t * rop2, mpfi_t * op) {
     return newSViv(mpfi_bisect(*rop1, *rop2, *op));
}

/*******************************
Error Handling
*******************************/

void RMPFI_ERROR (pTHX_ SV * msg) {
     MPFI_ERROR(SvPV_nolen(msg));
}

SV * Rmpfi_is_error(pTHX) {
     return newSViv(mpfi_is_error());
}

void Rmpfi_set_error(pTHX_ SV * op) {
     mpfi_set_error(SvIV(op));
}

void Rmpfi_reset_error(void) {
     mpfi_reset_error();
}

SV * _itsa(pTHX_ SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::MPFR")) return newSVuv(5);
       if(strEQ(h, "Math::GMPf")) return newSVuv(6);
       if(strEQ(h, "Math::GMPq")) return newSVuv(7);
       if(strEQ(h, "Math::GMPz")) return newSVuv(8);
       if(strEQ(h, "Math::GMP")) return newSVuv(9);
       if(strEQ(h, "Math::MPC")) return newSVuv(10);
       if(strEQ(h, "Math::MPFI")) return newSVuv(11);
       }
     return newSVuv(0);
}

SV * gmp_v(pTHX) {
     return newSVpv(gmp_version, 0);
}

SV * mpfr_v(pTHX) {
     return newSVpv(mpfr_get_version(), 0);
}

/*******************************
Overloading
*******************************/

SV * overload_gte(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_gte");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret >= 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_gte");
}

SV * overload_lte(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_lte");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret <= 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_lte");
}

SV * overload_gt(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_gt");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret > 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_gt");
}

SV * overload_lt(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_lt");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret < 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_lt");
}

SV * overload_equiv(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_equiv");
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret == 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_equiv");
}

SV * overload_add(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_add function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_add_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_add_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_add_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_add");
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_add(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_add");
}

SV * overload_mul(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_mul function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_mul_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_mul_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_mul_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_mul");
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_mul(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_mul");
}

SV * overload_sub(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_sub function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfi_ui_sub(*mpfi_t_obj, SvUV(b), *a);
       else mpfi_sub_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfi_si_sub(*mpfi_t_obj, SvIV(b), *a);
       else mpfi_sub_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(third == &PL_sv_yes) mpfi_d_sub(*mpfi_t_obj, SvNV(b), *a);
       else mpfi_sub_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_sub");
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_sub(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_sub");
}

SV * overload_div(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_div function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfi_ui_div(*mpfi_t_obj, SvUV(b), *a);
       else mpfi_div_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfi_si_div(*mpfi_t_obj, SvIV(b), *a);
       else mpfi_div_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(third == &PL_sv_yes) mpfi_d_div(*mpfi_t_obj, SvNV(b), *a);
       else mpfi_div_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_div");
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_div(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_div");
}

SV * overload_add_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_add_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_add_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_add_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_add_eq");
       }
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_add(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_add_eq");
}

SV * overload_mul_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_mul_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_mul_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_mul_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_mul_eq");
       }
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_mul(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_mul_eq");
}

SV * overload_sub_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_sub_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_sub_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_sub_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_sub_eq");
       }
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_sub(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_sub_eq");
}

SV * overload_div_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_div_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_div_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_div_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_div_eq");
       }
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_div(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_div_eq");
}

SV * overload_sqrt(pTHX_ mpfi_t * p, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in overload_sqrt function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_sqrt(*mpfi_t_obj, *p);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_get_version(pTHX) {
     return newSVpv(mpfi_get_version(), 0);
}

SV * Rmpfi_const_catalan(pTHX_ mpfi_t * rop) {
     return newSViv(mpfi_const_catalan(*rop));
}

SV * Rmpfi_cbrt(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cbrt(*rop, *op));
}

SV * Rmpfi_sec(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sec(*rop, *op));
}

SV * Rmpfi_csc(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_csc(*rop, *op));
}

SV * Rmpfi_cot(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cot(*rop, *op));
}

SV * Rmpfi_sech(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sech(*rop, *op));
}

SV * Rmpfi_csch(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_csch(*rop, *op));
}

SV * Rmpfi_coth(pTHX_ mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_coth(*rop, *op));
}

SV * Rmpfi_atan2(pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_atan2(*rop, *op1, *op2));
}

SV * Rmpfi_hypot(pTHX_ mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_hypot(*rop, *op1, *op2));
}

void Rmpfi_urandom(pTHX_ mpfr_t * rop, mpfi_t * op, gmp_randstate_t * state) {
     mpfi_urandom(*rop, *op, *state);
}

SV * overload_true(pTHX_ mpfi_t * op, SV * second, SV * third) {
     if(mpfi_is_zero(*op)) return newSViv(0);
     if(mpfi_nan_p(*op)) return newSViv(0);
     return newSViv(1);
}

SV * overload_not(pTHX_ mpfi_t * op, SV * second, SV * third) {
     if(mpfi_is_zero(*op)) return newSViv(1);
     if(mpfi_nan_p(*op)) return newSViv(1);
     return newSViv(0);
}

SV * overload_abs(pTHX_ mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_abs function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_abs(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_sin(pTHX_ mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_sin function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_sin(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_cos(pTHX_ mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_cos function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_cos(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_log(pTHX_ mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_log function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_log(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_exp(pTHX_ mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_exp function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_exp(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_atan2(pTHX_ mpfi_t * a, SV * b, SV * third) {
     mpfi_t * mpfi_t_obj;
     mpfr_t tr;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in overload_atan2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

#ifdef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfr_init(tr);
       mpfr_set_uj(tr, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(tr);
       mpfr_set_sj(tr, SvIV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfi_set_ui(*mpfi_t_obj, SvUV(b));
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_set_si(*mpfi_t_obj, SvIV(b));
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       mpfr_init_set_ld(tr, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
#else
       mpfi_set_d(*mpfi_t_obj, SvNV(b));
#endif
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvPOK(b)) {
       if(mpfi_set_str(*mpfi_t_obj, SvPV_nolen(b), 10))
         croak("Invalid string supplied to Math::MPFI::overload_atan2");
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::MPFI")) {
         mpfi_atan2(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
         SvREADONLY_on(obj);
         return obj_ref;
         }
       }

     croak("Invalid argument supplied to Math::MPFI::overload_atan2 function");
}

SV * _MPFI_VERSION_MAJOR(pTHX) {
#ifdef MPFI_VERSION_MAJOR
     return newSVuv(MPFI_VERSION_MAJOR);
#else
     croak("MPFI_VERSION_MAJOR not defined in mpfi.h until mpfi-1.5.1. Library version is %s", mpfi_get_version());
#endif
}

SV * _MPFI_VERSION_MINOR(pTHX) {
#ifdef MPFI_VERSION_MINOR
     return newSVuv(MPFI_VERSION_MINOR);
#else
     croak("MPFI_VERSION_MINOR not defined in mpfi.h until mpfi-1.5.1. Library version is %s", mpfi_get_version());
#endif
}

SV * _MPFI_VERSION_PATCHLEVEL(pTHX) {
#ifdef MPFI_VERSION_PATCHLEVEL
     return newSVuv(MPFI_VERSION_PATCHLEVEL);
#else
     croak("MPFI_VERSION_PATCHLEVEL not defined in mpfi.h until mpfi-1.5.1. Library version is %s", mpfi_get_version());
#endif
}

SV * _MPFI_VERSION_STRING(pTHX) {
#ifdef MPFI_VERSION_STRING
     return newSVpv(MPFI_VERSION_STRING, 0);
#else
     croak("MPFI_VERSION_STRING not defined in mpfi.h until mpfi-1.5.1. Library version is %s", mpfi_get_version());
#endif
}

SV * _wrap_count(pTHX) {
     return newSVuv(PL_sv_count);
}

SV * _get_xs_version(pTHX) {
     return newSVpv(XS_VERSION, 0);
}
MODULE = Math::MPFI	PACKAGE = Math::MPFI

PROTOTYPES: DISABLE


int
_has_inttypes ()


int
_has_longlong ()


int
_has_longdouble ()


SV *
RMPFI_BOTH_ARE_EXACT (ret)
	int	ret
CODE:
  RETVAL = RMPFI_BOTH_ARE_EXACT (aTHX_ ret);
OUTPUT:  RETVAL

SV *
RMPFI_LEFT_IS_INEXACT (ret)
	int	ret
CODE:
  RETVAL = RMPFI_LEFT_IS_INEXACT (aTHX_ ret);
OUTPUT:  RETVAL

SV *
RMPFI_RIGHT_IS_INEXACT (ret)
	int	ret
CODE:
  RETVAL = RMPFI_RIGHT_IS_INEXACT (aTHX_ ret);
OUTPUT:  RETVAL

SV *
RMPFI_BOTH_ARE_INEXACT (ret)
	int	ret
CODE:
  RETVAL = RMPFI_BOTH_ARE_INEXACT (aTHX_ ret);
OUTPUT:  RETVAL

void
_Rmpfi_set_default_prec (p)
	SV *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_Rmpfi_set_default_prec(aTHX_ p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_default_prec ()
CODE:
  RETVAL = Rmpfi_get_default_prec (aTHX);
OUTPUT:  RETVAL


void
Rmpfi_set_prec (op, prec)
	mpfi_t *	op
	SV *	prec
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_set_prec(aTHX_ op, prec);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_prec (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_get_prec (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_round_prec (op, prec)
	mpfi_t *	op
	SV *	prec
CODE:
  RETVAL = Rmpfi_round_prec (aTHX_ op, prec);
OUTPUT:  RETVAL

SV *
Rmpfi_init ()
CODE:
  RETVAL = Rmpfi_init (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfi_init_nobless ()
CODE:
  RETVAL = Rmpfi_init_nobless (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfi_init2 (prec)
	SV *	prec
CODE:
  RETVAL = Rmpfi_init2 (aTHX_ prec);
OUTPUT:  RETVAL

SV *
Rmpfi_init2_nobless (prec)
	SV *	prec
CODE:
  RETVAL = Rmpfi_init2_nobless (aTHX_ prec);
OUTPUT:  RETVAL

void
DESTROY (p)
	mpfi_t *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	DESTROY(aTHX_ p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_clear (p)
	mpfi_t *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_clear(aTHX_ p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_set (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_set (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_ui (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_set_ui (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_si (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_set_si (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_d (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_set_d (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_z (rop, op)
	mpfi_t *	rop
	mpz_t *	op
CODE:
  RETVAL = Rmpfi_set_z (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_q (rop, op)
	mpfi_t *	rop
	mpq_t *	op
CODE:
  RETVAL = Rmpfi_set_q (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_fr (rop, op)
	mpfi_t *	rop
	mpfr_t *	op
CODE:
  RETVAL = Rmpfi_set_fr (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_set_str (rop, s, base)
	mpfi_t *	rop
	SV *	s
	SV *	base
CODE:
  RETVAL = Rmpfi_set_str (aTHX_ rop, s, base);
OUTPUT:  RETVAL

void
Rmpfi_swap (x, y)
	mpfi_t *	x
	mpfi_t *	y
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_swap(aTHX_ x, y);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set (q)
	mpfi_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_ui (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_ui(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_si (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_si(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_d (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_d(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_z (q)
	mpz_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_z(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_q (q)
	mpq_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_q(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_fr (q)
	mpfr_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_fr(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_str (q, base)
	SV *	q
	SV *	base
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_str(aTHX_ q, base);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_nobless (q)
	mpfi_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_ui_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_ui_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_si_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_si_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_d_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_d_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_z_nobless (q)
	mpz_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_z_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_q_nobless (q)
	mpq_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_q_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_fr_nobless (q)
	mpfr_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_fr_nobless(aTHX_ q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_str_nobless (q, base)
	SV *	q
	SV *	base
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_str_nobless(aTHX_ q, base);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_diam_abs (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_diam_abs (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_diam_rel (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_diam_rel (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_diam (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_diam (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_mag (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_mag (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_mig (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_mig (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_mid (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_mid (aTHX_ rop, op);
OUTPUT:  RETVAL

void
Rmpfi_alea (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_alea(aTHX_ rop, op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_d (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_get_d (aTHX_ op);
OUTPUT:  RETVAL

void
Rmpfi_get_fr (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_get_fr(aTHX_ rop, op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_add (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_add (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_add_d (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_add_ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_add_si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_add_z (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_add_q (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_add_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_add_fr (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_sub_d (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_d_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_d_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_sub_ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_ui_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_ui_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_sub_si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_si_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_si_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_sub_z (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_z_sub (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_z_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_sub_q (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_q_sub (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_q_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_sub_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_sub_fr (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_fr_sub (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_fr_sub (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_mul (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_d (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_mul_z (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_mul_q (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_mul_fr (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_d (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_d_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_d_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_ui_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_ui_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_si_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_si_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_div_z (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_z_div (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_z_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_div_q (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_q_div (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_q_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_div_fr (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_fr_div (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_fr_div (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_neg (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_neg (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sqr (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sqr (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_inv (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_inv (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sqrt (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sqrt (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_abs (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_abs (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_2exp (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_2exp (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_2ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_2ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_mul_2si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_mul_2si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_2exp (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_2exp (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_2ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_2ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_div_2si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_div_2si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_log (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_log (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_exp (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_exp (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_exp2 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_exp2 (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_cos (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_cos (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sin (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sin (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_tan (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_tan (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_acos (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_acos (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_asin (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_asin (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_atan (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_atan (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_cosh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_cosh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sinh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sinh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_tanh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_tanh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_acosh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_acosh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_asinh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_asinh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_atanh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_atanh (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_log1p (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_log1p (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_expm1 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_expm1 (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_log2 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_log2 (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_log10 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_log10 (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_const_log2 (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_const_log2 (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_const_pi (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_const_pi (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_const_euler (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_const_euler (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_cmp (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_d (op1, op2)
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_cmp_d (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_ui (op1, op2)
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_cmp_ui (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_si (op1, op2)
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_cmp_si (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_z (op1, op2)
	mpfi_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_cmp_z (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_q (op1, op2)
	mpfi_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_cmp_q (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_cmp_fr (op1, op2)
	mpfi_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_cmp_fr (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_is_pos (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_pos (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_strictly_pos (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_strictly_pos (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_nonneg (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_nonneg (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_neg (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_neg (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_strictly_neg (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_strictly_neg (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_nonpos (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_nonpos (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_is_zero (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_zero (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_has_zero (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_has_zero (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_nan_p (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_nan_p (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_inf_p (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_inf_p (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_bounded_p (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_bounded_p (aTHX_ op);
OUTPUT:  RETVAL

SV *
_Rmpfi_out_str (stream, base, dig, p)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
CODE:
  RETVAL = _Rmpfi_out_str (aTHX_ stream, base, dig, p);
OUTPUT:  RETVAL

SV *
_Rmpfi_out_strS (stream, base, dig, p, suff)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
	SV *	suff
CODE:
  RETVAL = _Rmpfi_out_strS (aTHX_ stream, base, dig, p, suff);
OUTPUT:  RETVAL

SV *
_Rmpfi_out_strP (pre, stream, base, dig, p)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
CODE:
  RETVAL = _Rmpfi_out_strP (aTHX_ pre, stream, base, dig, p);
OUTPUT:  RETVAL

SV *
_Rmpfi_out_strPS (pre, stream, base, dig, p, suff)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
	SV *	suff
CODE:
  RETVAL = _Rmpfi_out_strPS (aTHX_ pre, stream, base, dig, p, suff);
OUTPUT:  RETVAL

SV *
Rmpfi_inp_str (p, stream, base)
	mpfi_t *	p
	FILE *	stream
	SV *	base
CODE:
  RETVAL = Rmpfi_inp_str (aTHX_ p, stream, base);
OUTPUT:  RETVAL

void
Rmpfi_print_binary (op)
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_print_binary(aTHX_ op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_left (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_get_left (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_get_right (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_get_right (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_revert_if_needed (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_revert_if_needed (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_put (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_put (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_d (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_put_d (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_ui (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_put_ui (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_si (rop, op)
	mpfi_t *	rop
	SV *	op
CODE:
  RETVAL = Rmpfi_put_si (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_z (rop, op)
	mpfi_t *	rop
	mpz_t *	op
CODE:
  RETVAL = Rmpfi_put_z (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_q (rop, op)
	mpfi_t *	rop
	mpq_t *	op
CODE:
  RETVAL = Rmpfi_put_q (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_put_fr (rop, op)
	mpfi_t *	rop
	mpfr_t *	op
CODE:
  RETVAL = Rmpfi_put_fr (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_d (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_interv_d (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_ui (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_interv_ui (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_si (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_interv_si (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_z (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpz_t *	op2
CODE:
  RETVAL = Rmpfi_interv_z (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_q (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpq_t *	op2
CODE:
  RETVAL = Rmpfi_interv_q (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_interv_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfr_t *	op2
CODE:
  RETVAL = Rmpfi_interv_fr (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_is_strictly_inside (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_is_strictly_inside (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_is_inside (aTHX_ op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_d (op2, op1)
	SV *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_d (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_ui (op2, op1)
	SV *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_ui (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_si (op2, op1)
	SV *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_si (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_z (op2, op1)
	mpz_t *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_z (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_q (op2, op1)
	mpq_t *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_q (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_inside_fr (op2, op1)
	mpfr_t *	op2
	mpfi_t *	op1
CODE:
  RETVAL = Rmpfi_is_inside_fr (aTHX_ op2, op1);
OUTPUT:  RETVAL

SV *
Rmpfi_is_empty (op)
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_is_empty (aTHX_ op);
OUTPUT:  RETVAL

SV *
Rmpfi_intersect (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_intersect (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_union (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_union (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_increase (rop, op)
	mpfi_t *	rop
	mpfr_t *	op
CODE:
  RETVAL = Rmpfi_increase (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_blow (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2
CODE:
  RETVAL = Rmpfi_blow (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_bisect (rop1, rop2, op)
	mpfi_t *	rop1
	mpfi_t *	rop2
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_bisect (aTHX_ rop1, rop2, op);
OUTPUT:  RETVAL

void
RMPFI_ERROR (msg)
	SV *	msg
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	RMPFI_ERROR(aTHX_ msg);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_is_error ()
CODE:
  RETVAL = Rmpfi_is_error (aTHX);
OUTPUT:  RETVAL


void
Rmpfi_set_error (op)
	SV *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_set_error(aTHX_ op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_reset_error ()

	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_reset_error();
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

SV *
gmp_v ()
CODE:
  RETVAL = gmp_v (aTHX);
OUTPUT:  RETVAL


SV *
mpfr_v ()
CODE:
  RETVAL = mpfr_v (aTHX);
OUTPUT:  RETVAL


SV *
overload_gte (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lte (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_gt (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lt (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_equiv (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_mul (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_div (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sqrt (p, second, third)
	mpfi_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_sqrt (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
Rmpfi_get_version ()
CODE:
  RETVAL = Rmpfi_get_version (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfi_const_catalan (rop)
	mpfi_t *	rop
CODE:
  RETVAL = Rmpfi_const_catalan (aTHX_ rop);
OUTPUT:  RETVAL

SV *
Rmpfi_cbrt (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_cbrt (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sec (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sec (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_csc (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_csc (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_cot (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_cot (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_sech (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_sech (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_csch (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_csch (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_coth (rop, op)
	mpfi_t *	rop
	mpfi_t *	op
CODE:
  RETVAL = Rmpfi_coth (aTHX_ rop, op);
OUTPUT:  RETVAL

SV *
Rmpfi_atan2 (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_atan2 (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

SV *
Rmpfi_hypot (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2
CODE:
  RETVAL = Rmpfi_hypot (aTHX_ rop, op1, op2);
OUTPUT:  RETVAL

void
Rmpfi_urandom (rop, op, state)
	mpfr_t *	rop
	mpfi_t *	op
	gmp_randstate_t *	state
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_urandom(aTHX_ rop, op, state);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
overload_true (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_true (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_not (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_not (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_abs (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_abs (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_sin (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_sin (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_cos (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_cos (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_log (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_log (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_exp (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_exp (aTHX_ op, second, third);
OUTPUT:  RETVAL

SV *
overload_atan2 (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_atan2 (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_MPFI_VERSION_MAJOR ()
CODE:
  RETVAL = _MPFI_VERSION_MAJOR (aTHX);
OUTPUT:  RETVAL


SV *
_MPFI_VERSION_MINOR ()
CODE:
  RETVAL = _MPFI_VERSION_MINOR (aTHX);
OUTPUT:  RETVAL


SV *
_MPFI_VERSION_PATCHLEVEL ()
CODE:
  RETVAL = _MPFI_VERSION_PATCHLEVEL (aTHX);
OUTPUT:  RETVAL


SV *
_MPFI_VERSION_STRING ()
CODE:
  RETVAL = _MPFI_VERSION_STRING (aTHX);
OUTPUT:  RETVAL


SV *
_wrap_count ()
CODE:
  RETVAL = _wrap_count (aTHX);
OUTPUT:  RETVAL


SV *
_get_xs_version ()
CODE:
  RETVAL = _get_xs_version (aTHX);
OUTPUT:  RETVAL


