/* $Id$
 * hipe_debug.c
 *
 * TODO:
 * - detect mode-switch native return addresses (ARCH-specific)
 * - map user-code native return addresses to symbolic names
 */
#include <stddef.h>	/* offsetof() */
#include <stdio.h>
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "sys.h"
#include "erl_vm.h"
#include "global.h"
#include "erl_process.h"
#include "beam_catches.h"
#include "beam_load.h"
#include "hipe_mode_switch.h"
#include "hipe_debug.h"

static const char dashes[2*sizeof(long)+5] = {
    [0 ... 2*sizeof(long)+3] = '-'
};

static const char dots[2*sizeof(long)+5] = {
    [0 ... 2*sizeof(long)+3] = '.'
};

static const char stars[2*sizeof(long)+5] = {
    [0 ... 2*sizeof(long)+3] = '*'
};

extern Uint beam_apply[];

static void print_beam_pc(Uint *pc)
{
    if( pc == hipe_beam_pc_return ) {
	printf("return-to-native");
    } else if( pc == hipe_beam_pc_throw ) {
	printf("throw-to-native");
    } else if( pc == &beam_apply[1] ) {
	printf("normal-process-exit");
    } else {
	Eterm *mfa = find_function_from_pc(pc);
	if( mfa ) {
	    display(mfa[0], COUT);
	    printf(":");
	    display(mfa[1], COUT);
	    printf("/%ld", mfa[2]);
	    printf(" + 0x%x", (int)(pc - &mfa[3]));
	} else {
	    printf("?");
	}
    }
}

static void catch_slot(Eterm *pos, Eterm val)
{
    Uint *pc = catch_pc(val);
    printf(" | 0x%0*lx | 0x%0*lx | CATCH 0x%0*lx (BEAM ",
	   2*(int)sizeof(long), (unsigned long)pos,
	   2*(int)sizeof(long), (unsigned long)val,
	   2*(int)sizeof(long), (unsigned long)pc);
    print_beam_pc(pc);
    printf(")\r\n");
}

static void print_beam_cp(Eterm *pos, Eterm val)
{
    printf(" |%s|%s| BEAM ACTIVATION RECORD\r\n", dashes, dashes);
    printf(" | 0x%0*lx | 0x%0*lx | BEAM PC ",
	   2*(int)sizeof(long), (unsigned long)pos,
	   2*(int)sizeof(long), (unsigned long)val);
    print_beam_pc(cp_val(val));
    printf("\r\n");
}

static void print_catch(Eterm *pos, Eterm val)
{
    printf(" |%s|%s| BEAM CATCH FRAME\r\n", dots, dots);
    catch_slot(pos, val);
    printf(" |%s|%s|\r\n", stars, stars);
}

static void print_stack(Eterm *sp, Eterm *end)
{
    printf(" | %*s | %*s |\r\n",
	   2+2*(int)sizeof(long), "Address",
	   2+2*(int)sizeof(long), "Contents");
    while( sp < end ) {
	Eterm val = sp[0];
	if( is_CP(val) ) {
	    print_beam_cp(sp, val);
	} else if( is_catch(val) ) {
	    print_catch(sp, val);
	} else {
	    printf(" | 0x%0*lx | 0x%0*lx | ",
		   2*(int)sizeof(long), (unsigned long)sp,
		   2*(int)sizeof(long), (unsigned long)val);
	    ldisplay(val, COUT, 30);
	    printf("\r\n");
	}
	sp += 1;
    }
    printf(" |%s|%s|\r\n", dashes, dashes);
}

void hipe_print_estack(Process *p)
{
    printf(" |       BEAM  STACK       |\r\n");
    print_stack(p->stop, STACK_START(p));
}

static void print_heap(Eterm *pos, Eterm *end)
{
    printf("From: 0x%0*lx to 0x%0*lx\n\r",
	   2*(int)sizeof(long), (unsigned long)pos,
	   2*(int)sizeof(long), (unsigned long)end);
    printf(" |         H E A P         |\r\n");
    printf(" | %*s | %*s |\r\n",
	   2+2*(int)sizeof(long), "Address",
	   2+2*(int)sizeof(long), "Contents");
    printf(" |%s|%s|\r\n", dashes, dashes);
    while( pos < end ) {
	Eterm val = pos[0];
	printf(" | 0x%0*lx | 0x%0*lx | ",
	       2*(int)sizeof(long), (unsigned long)pos,
	       2*(int)sizeof(long), (unsigned long)val);
	++pos;
	if( is_arity_value(val) ) {
	    printf("Arity(%lu)", arityval(val));
	} else if( is_thing(val) ) {
	    unsigned int ari = thing_arityval(val);
	    printf("Thing Arity(%u) Tag(%lu)", ari, thing_subtag(val));
	    while( ari ) {
		printf("\r\n | 0x%0*lx | 0x%0*lx | THING",
		       2*(int)sizeof(long), (unsigned long)pos,
		       2*(int)sizeof(long), (unsigned long)*pos);
		++pos;
		--ari;
	    }
	} else
	    ldisplay(val, COUT, 30);
	printf("\r\n");
    }
    printf(" |%s|%s|\r\n", dashes, dashes);
}

void hipe_print_heap(Process *p)
{
    print_heap(p->heap, p->htop);
}

void hipe_print_pcb(Process *p)
{
    printf("P: 0x%0*lx\r\n", 2*(int)sizeof(long), (unsigned long)p);
    printf("-----------------------------------------------\r\n");
    printf("Offset| Name        | Value      | *Value     |\r\n");
#define U(n,x) \
    printf(" % 4d | %s | 0x%0*lx |            |\r\n", (int)offsetof(Process,x), n, 2*(int)sizeof(long), (unsigned long)p->x)
#define P(n,x) \
    printf(" % 4d | %s | 0x%0*lx | 0x%0*lx |\r\n", (int)offsetof(Process,x), n, 2*(int)sizeof(long), (unsigned long)p->x, 2*(int)sizeof(long), p->x ? (unsigned long)*(p->x) : -1UL)
    
    U("htop       ", htop);
    U("hend       ", hend);
    U("heap       ", heap);
    U("heap_sz    ", heap_sz);
    U("stop       ", stop);
#ifdef SHARED_HEAP
    U("stack      ", stack);
    U("send       ", send);
#else
    U("gen_gcs    ", gen_gcs);
    U("max_gen_gcs", max_gen_gcs);
    U("high_water ", high_water);
    U("old_hend   ", old_hend);
    U("old_htop   ", old_htop);
    U("old_head   ", old_heap);
#endif
    U("min_heap_..", min_heap_size);
    U("status     ", status);
    U("rstatus    ", rstatus);
    U("rcount     ", rcount);
    U("id         ", id);
    U("prio       ", prio);
    U("reds       ", reds);
    U("error_han..", error_handler);
    U("tracer_pr..", tracer_proc);
    U("group_lea..", group_leader);
    U("flags      ", flags);
    U("fvalue     ", fvalue);
    U("freason    ", freason);
    U("fcalls     ", fcalls);
    /*XXX: ErlTimer tm; */
    U("next       ", next);
    /*XXX: ErlOffHeap off_heap; */
    U("reg        ", reg);
    /*U("links      ", links);*/
#ifndef SHARED_HEAP
    /*XXX: ErlMessageQueue msg; */
    U("mbuf       ", mbuf);
    U("mbuf_sz    ", mbuf_sz);
#endif
    U("dictionary ", dictionary);
    U("debug_dic..", debug_dictionary);
    U("ct         ", ct);
    U("seq..clock ", seq_trace_clock);
    U("seq..astcnt", seq_trace_lastcnt);
    U("seq..token ", seq_trace_token);
    U("intial[0]  ", initial[0]);
    U("intial[1]  ", initial[1]);
    U("intial[2]  ", initial[2]);
    P("current    ", current);
    P("cp         ", cp);
    P("i          ", i);
    U("catches    ", catches);
#ifndef SHARED_HEAP
    U("arith_heap ", arith_heap);
    U("arith_avail", arith_avail);
#ifdef DEBUG
    U("arith_file ", arith_file);
    U("arith_line ", arith_line);
    P("arith_che..", arith_check_me);
#endif
#endif
    U("arity      ", arity);
    P("arg_reg    ", arg_reg);
    U("max_arg_reg", max_arg_reg);
    U("def..reg[0]", def_arg_reg[0]);
    U("def..reg[1]", def_arg_reg[1]);
    U("def..reg[2]", def_arg_reg[2]);
    U("def..reg[3]", def_arg_reg[3]);
    U("def..reg[4]", def_arg_reg[4]);
    U("def..reg[5]", def_arg_reg[5]);
#ifdef HIPE
    U("nsp        ", hipe.nsp);
    U("nstack     ", hipe.nstack);
    U("nstend     ", hipe.nstend);
    U("ncallee    ", hipe.ncallee);
    hipe_arch_print_pcb(&p->hipe);
#endif	/* HIPE */
#undef U
#undef P
    printf("-----------------------------------------------\r\n");
}
