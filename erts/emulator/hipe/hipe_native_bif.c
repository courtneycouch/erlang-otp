/* $Id$
 * hipe_native_bif.c
 */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "sys.h"
#include "erl_vm.h"
#include "global.h"
#include "erl_process.h"
#include "error.h"
#include "bif.h"
#include "erl_bits.h"
#include "erl_binary.h"
#include "hipe_mode_switch.h"
#include "hipe_native_bif.h"
#include "hipe_arch.h"
#include "hipe_stack.h"

/*
 * This is called when inlined heap allocation in native code fails.
 * The 'need' parameter is the number of heap words needed.
 * The value is tagged as a fixnum to avoid untagged data on
 * the x86 stack while the gc is running.
 */
void hipe_gc(Process *p, Eterm need)
{
    hipe_set_narity(p, 1);
    p->fcalls -= erts_garbage_collect(p, unsigned_val(need), NULL, 0);
    hipe_set_narity(p, 0);
}

/* This is like the OP_setTimeout JAM instruction.
 *  Transformation to the BEAM instruction wait_timeout_fs
 *  has begun.
 * XXX: BUG: native code should check return status
 */
Eterm hipe_set_timeout(Process *p, Eterm timeout_value)
{
#if !defined(ARCH_64)
    Uint time_val;
#endif
    /* XXX: This should be converted to follow BEAM conventions,
     * but that requires some compiler changes.
     *
     * In BEAM, set_timeout saves TWO CP values, and suspends.
     * p->def_arg_reg[0] and p->i are both defined and used.
     * If a message arrives, BEAM resumes at p->i.
     * If a timeout fires, BEAM resumes at p->def_arg_reg[0].
     * (See set_timer() and timeout_proc() in erl_process.c.)
     *
     * Here we set p->def_arg_reg[0] to hipe_beam_pc_resume.
     * Assuming our caller invokes suspend immediately after
     * our return, then hipe_mode_switch() will also set
     * p->i to hipe_beam_pc_resume. Thus we'll resume in the same
     * way regardless of the cause (message or timeout).
     * hipe_mode_switch() checks for F_TIMO and returns a
     * flag to native code indicating the cause.
     */

    /*
     * def_arg_reg[0] is (re)set unconditionally, in case this is the
     * 2nd/3rd/... iteration through the receive loop: in order to pass
     * a boolean flag to native code indicating timeout or new message,
     * our mode switch has to clobber def_arg_reg[0]. This is ok, but if
     * we re-suspend (because we ignored a received message) we also have
     * to reinitialise def_arg_reg[0] with the BEAM resume label.
     *
     * XXX: A better solution would be to pass two parameters to
     * set_timeout: the timeout and the on-timeout resume label.
     * We could put the resume label in def_arg_reg[1] and resume
     * at it without having to load a flag in a register and generate
     * code to test it. Requires a HiPE compiler change though.
     */
    p->def_arg_reg[0] = (Eterm) hipe_beam_pc_resume;

    /*
     * If we have already set the timer, we must NOT set it again.  Therefore,
     * we must test the F_INSLPQUEUE flag as well as the F_TIMO flag.
     */
    if( p->flags & (F_INSLPQUEUE | F_TIMO) ) {
	return NIL;	/* caller had better call nbif_suspend ASAP! */
    }
    if( is_small(timeout_value) && signed_val(timeout_value) >= 0 &&
#if defined(ARCH_64)
	(unsigned_val(timeout_value) >> 32) == 0
#else
	1
#endif
	) {
	set_timer(p, unsigned_val(timeout_value));
    } else if( timeout_value == am_infinity ) {
	/* p->flags |= F_TIMO; */	/* XXX: nbif_suspend_msg_timeout */
#if !defined(ARCH_64)
    } else if( term_to_Uint(timeout_value, &time_val) ) {
	set_timer(p, time_val);
#endif
    } else {
	BIF_ERROR(p, EXC_TIMEOUT_VALUE);
    }
    return NIL;	/* caller had better call nbif_suspend ASAP! */
}

/* This is like the remove_message BEAM instruction
 */
void hipe_select_msg(Process *p)
{
    ErlMessage *msgp;

    msgp = PEEK_MESSAGE(p);
    UNLINK_MESSAGE(p, msgp);	/* decrements global 'erts_proc_tot_mem' variable */
    JOIN_MESSAGE(p);
    CANCEL_TIMER(p);		/* calls erl_cancel_timer() */
    free_message(msgp);
}

/*
 * hipe_handle_exception() is called from hipe_${ARCH}_glue.S when an
 * exception has been thrown, to "fix up" the exception value and to
 * locate the current handler.
 */
void hipe_handle_exception(Process *c_p)
{
#if 0 /* NEW_EXCEPTIONS */ 
    Eterm Value = c_p->fvalue;
#else
    Eterm* hp;
    Eterm Value;
    Uint r;
#endif

    ASSERT(c_p->freason != TRAP); /* Should have been handled earlier. */
    ASSERT(c_p->freason != RESCHEDULE); /* Should have been handled earlier. */
#if 0 /* NEW_EXCEPTIONS */ 
    /* Get the fully expanded error term */
    Value = expand_error_value(c_p, Value);

    /* Save final error term and stabilize the exception flags so no
       further expansion is done. */
    c_p->fvalue = Value;
    c_p->freason = PRIMARY_EXCEPTION(c_p->freason);
#else
    r = GET_EXC_INDEX(c_p->freason);
    ASSERT(r < NUMBER_EXIT_CODES); /* range check */
    if (r < NUMBER_EXIT_CODES) {
       Value = error_atom[r];
    } else {
       Value = am_internal_error;
       c_p->freason = EXC_INTERNAL_ERROR;
    }

    r = c_p->freason;
    switch (GET_EXC_INDEX(r)) {
    case (GET_EXC_INDEX(EXC_PRIMARY)):
        /* Primary exceptions use fvalue directly */
        ASSERT(is_value(c_p->fvalue));
        Value = c_p->fvalue;
        break;
    case (GET_EXC_INDEX(EXC_BADMATCH)):
    case (GET_EXC_INDEX(EXC_CASE_CLAUSE)):
    case (GET_EXC_INDEX(EXC_BADFUN)):
       ASSERT(is_value(c_p->fvalue));
       hp = HAlloc(c_p, 3);
       Value = TUPLE2(hp, Value, c_p->fvalue);
       break;
    default:
       hp = HAlloc(c_p, 3);
       Value = TUPLE2(hp, Value, NIL);
       break;
    }

    r = PRIMARY_EXCEPTION(r);    /* make the exception stable */
    c_p->freason = r;
    c_p->fvalue = Value;
#endif

    hipe_find_handler(c_p);
}

Eterm hipe_get_exit_tag(Process *c_p)
{
    return exception_tag[GET_EXC_CLASS(c_p->freason)];
}

/*
 * Support for compiled binary syntax operations.
 */

char *hipe_bs_allocate(int len)
{ 
  Binary* bptr;
  bptr = erts_bin_nrml_alloc(len);
  bptr->flags = 0;
  bptr->orig_size = len;
  bptr->refc = 1;
  return bptr->orig_bytes;
}

int hipe_bs_put_big_integer(Eterm arg, Uint num_bits, byte* base, unsigned offset, unsigned flags)
{ 
  byte* save_bin_buf;
  unsigned save_bin_offset, save_bin_buf_len;
  int res;
  save_bin_buf=erts_bin_buf;
  save_bin_offset=erts_bin_offset;
  save_bin_buf_len=erts_bin_buf_len;
  erts_bin_buf=base;
  erts_bin_offset=offset;
  erts_bin_buf_len=(offset+num_bits+7) >> 3;
  res = erts_bs_put_integer(arg, num_bits, flags);
  erts_bin_buf=save_bin_buf;
  erts_bin_offset=save_bin_offset;
  erts_bin_buf_len=save_bin_buf_len;
  return res;
}
int hipe_bs_put_small_float(Eterm arg, Uint num_bits, byte* base, unsigned offset, unsigned flags)
{ 
  byte* save_bin_buf;
  unsigned save_bin_offset, save_bin_buf_len;
  int res;
  save_bin_buf=erts_bin_buf;
  save_bin_offset=erts_bin_offset;
  save_bin_buf_len=erts_bin_buf_len;
  erts_bin_buf=base;
  erts_bin_offset=offset;
  erts_bin_buf_len=(offset+num_bits+7) >> 3;
  res = erts_bs_put_float(arg, num_bits, flags);
  erts_bin_buf=save_bin_buf;
  erts_bin_offset=save_bin_offset;
  erts_bin_buf_len=save_bin_buf_len;
  return res;
}
