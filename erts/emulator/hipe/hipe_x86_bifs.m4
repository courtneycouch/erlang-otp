changecom(`/*', `*/')dnl
/*
 * $Id$
 */

include(`hipe/hipe_x86_asm.m4')
#`include' "hipe_literals.h"

/*
 * These m4 macros expand to assembly code which
 * is further processed using the C pre-processor:
 * - Expansion of symbolic names for registers and PCB fields.
 * - Conditional assembly. Some BIFs need specialised code.
 *   Instead of special-casing them in all generated BIF lists,
 *   we use #ifndef wrappers to allow hand-written code to
 *   override that generated by the standard m4 macros.
 *   This is used for:
 *   - demonitor/1, exit/2, group_leader/2, link/1, monitor/2,
 *     port_command/2, send/2, unlink/1: can fail with RESCHEDULE
 * - Appropriate BIF exception test for debug and non-debug mode.
 *
 * XXX: TODO:
 * - Can a BIF with arity 0 fail? beam_emu doesn't think so.
 */

`#if THE_NON_VALUE == 0
#define TEST_GOT_EXN	testl	%eax,%eax
#else
#define TEST_GOT_EXN	cmpl	$THE_NON_VALUE,%eax
#endif'

/*
 * standard_bif_interface_0(nbif_name, cbif_name)
 * standard_bif_interface_1(nbif_name, cbif_name)
 * standard_bif_interface_2(nbif_name, cbif_name)
 * standard_bif_interface_3(nbif_name, cbif_name)
 *
 * Generate native interface for a BIF with 0-3 parameters and
 * standard failure mode (may fail, but not with RESCHEDULE).
 */
define(standard_bif_interface_0,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	P
	call	$2
	addl	`$'4, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	nbif_0_simple_exception
	NBIF_RET(0)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(standard_bif_interface_1,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(1)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(1,0)
	pushl	P
	call	$2
	addl	`$'8, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	nbif_1_simple_exception
	NBIF_RET(1)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(standard_bif_interface_2,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(2)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(2,1)
	pushl	NBIF_ARG(2,0)
	pushl	P
	call	$2
	addl	`$'12, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	nbif_2_simple_exception
	NBIF_RET(2)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(standard_bif_interface_3,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(3)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(3,2)
	pushl	NBIF_ARG(3,1)
	pushl	NBIF_ARG(3,0)
	pushl	P
	call	$2
	addl	`$'16, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	nbif_3_simple_exception
	NBIF_RET(3)
	.size	$1,.-$1
	.type	$1,@function
#endif')

/*
 * expensive_bif_interface_1(nbif_name, cbif_name)
 * expensive_bif_interface_2(nbif_name, cbif_name)
 *
 * Generate native interface for a BIF with 1-2 parameters and
 * an expensive failure mode (may fail with RESCHEDULE).
 */
define(expensive_bif_interface_1,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(1)

	/* save actual parameters in case we must reschedule */
	NBIF_SAVE_RESCHED_ARGS(1)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(1,0)
	pushl	P
	call	$2
	addl	`$'8, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	1f
	NBIF_RET(1)
1:
	movl	`$'$1, %edx	/* resumption address */
	jmp	nbif_1_hairy_exception
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(expensive_bif_interface_2,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(2)

	/* save actual parameters in case we must reschedule */
	NBIF_SAVE_RESCHED_ARGS(2)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(2,1)
	pushl	NBIF_ARG(2,0)
	pushl	P
	call	$2
	addl	`$'12, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* throw exception if failure, otherwise return */
	TEST_GOT_EXN
	jz	1f
	NBIF_RET(2)
1:
	movl	`$'$1, %edx	/* resumption address */
	jmp	nbif_2_hairy_exception
	.size	$1,.-$1
	.type	$1,@function
#endif')

/*
 * nofail_primop_interface_0(nbif_name, cbif_name)
 * nofail_primop_interface_1(nbif_name, cbif_name)
 * nofail_primop_interface_2(nbif_name, cbif_name)
 *
 * Generate native interface for a primop with implicit P
 * parameter, 0-2 ordinary parameters and no failure mode.
 * Also used for guard BIFs.
 */
define(nofail_primop_interface_0,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	P
	call	$2
	addl	`$'4, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* return */
	NBIF_RET(0)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(nofail_primop_interface_1,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(1)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(1,0)
	pushl	P
	call	$2
	addl	`$'8, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* return */
	NBIF_RET(1)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(nofail_primop_interface_2,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(2)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C

	/* make the call on the C stack */
	pushl	NBIF_ARG(2,1)
	pushl	NBIF_ARG(2,0)
	pushl	P
	call	$2
	addl	`$'12, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG

	/* return */
	NBIF_RET(2)
	.size	$1,.-$1
	.type	$1,@function
#endif')

/*
 * nocons_nofail_primop_interface_0(nbif_name, cbif_name)
 *
 * Generate native interface for a primop with implicit P
 * parameter, 0 ordinary parameters, and no failure mode.
 * The primop cannot CONS or gc.
 */
define(nocons_nofail_primop_interface_0,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	pushl	P
	call	$2
	addl	`$'4, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(0)
	.size	$1,.-$1
	.type	$1,@function
#endif')

/* 
 * noproc_primop_interface_0(nbif_name, cbif_name)
 * noproc_primop_interface_1(nbif_name, cbif_name)
 * noproc_primop_interface_2(nbif_name, cbif_name)
 * noproc_primop_interface_3(nbif_name, cbif_name)
 * noproc_primop_interface_5(nbif_name, cbif_name)
 *
 * Generate native interface for a primop with no implicit P
 * parameter, 0-3 or 5 ordinary parameters, and no failure mode.
 * The primop cannot CONS or gc.
 */
define(noproc_primop_interface_0,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	call	$2

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(0)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(noproc_primop_interface_1,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(1)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	pushl	NBIF_ARG(1,0)
	call	$2
	addl	`$'4, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(1)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(noproc_primop_interface_2,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(2)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	pushl	NBIF_ARG(2,1)
	pushl	NBIF_ARG(2,0)
	call	$2
	addl	`$'8, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(2)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(noproc_primop_interface_3,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(3)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	pushl	NBIF_ARG(3,2)
	pushl	NBIF_ARG(3,1)
	pushl	NBIF_ARG(3,0)
	call	$2
	addl	`$'12, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(3)
	.size	$1,.-$1
	.type	$1,@function
#endif')

define(noproc_primop_interface_5,
`
#ifndef HAVE_$1
#`define' HAVE_$1
	.section ".text"
	.align	4
	.global	$1
$1:
	/* copy native stack pointer */
	NBIF_COPY_NSP(5)

	/* switch to C stack */
	SWITCH_ERLANG_TO_C_QUICK

	/* make the call on the C stack */
	pushl	NBIF_ARG(5,4)
	pushl	NBIF_ARG(5,3)
	pushl	NBIF_ARG(5,2)
	pushl	NBIF_ARG(5,1)
	pushl	NBIF_ARG(5,0)
	call	$2
	addl	`$'20, %esp

	/* switch to native stack */
	SWITCH_C_TO_ERLANG_QUICK

	/* return */
	NBIF_RET(5)
	.size	$1,.-$1
	.type	$1,@function
#endif')

/*
 * x86-specific primops.
 */
noproc_primop_interface_0(nbif_handle_fp_exception, erts_restore_fpu)

/*
 * BIFs that may trigger a native stack walk with p->narity != 0.
 * Relevant on x86 when NR_ARG_REGS < 2.
 */
standard_bif_interface_2(nbif_check_process_code_2, hipe_x86_check_process_code_2)
standard_bif_interface_1(nbif_garbage_collect_1, hipe_x86_garbage_collect_1)

/*
 * Implement gc_nofail_primop_interface_1 as nofail_primop_interface_1.
 */
define(gc_nofail_primop_interface_1,`nofail_primop_interface_1($1, $2)')

include(`hipe/hipe_bif_list.m4')
