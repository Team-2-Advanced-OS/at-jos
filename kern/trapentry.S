/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps


.text
TRAPHANDLER_NOEC(i0, 0)
TRAPHANDLER_NOEC(i1, 1)
TRAPHANDLER_NOEC(i2, 2)
TRAPHANDLER_NOEC(i3, 3)
TRAPHANDLER_NOEC(i4, 4)
TRAPHANDLER_NOEC(i5, 5)
TRAPHANDLER_NOEC(i6, 6)
TRAPHANDLER_NOEC(i7, 7)
TRAPHANDLER(i8, 8)
TRAPHANDLER_NOEC(i9, 9)
TRAPHANDLER(i10, 10)
TRAPHANDLER(i11, 11)
TRAPHANDLER(i12, 12)
TRAPHANDLER(i13, 13)
TRAPHANDLER(i14, 14)
TRAPHANDLER_NOEC(i15, 15)
TRAPHANDLER_NOEC(i16, 16)
TRAPHANDLER(i17, 17)
TRAPHANDLER_NOEC(i18, 18)
TRAPHANDLER_NOEC(i19, 19)
TRAPHANDLER_NOEC(i20, 20)
TRAPHANDLER_NOEC(i21, 21)
TRAPHANDLER_NOEC(i22, 22)
TRAPHANDLER_NOEC(i23, 23)
TRAPHANDLER_NOEC(i24, 24)
TRAPHANDLER_NOEC(i25, 25)
TRAPHANDLER_NOEC(i26, 26)
TRAPHANDLER_NOEC(i27, 27)
TRAPHANDLER_NOEC(i28, 28)
TRAPHANDLER_NOEC(i29, 29)
TRAPHANDLER_NOEC(i30, 30)
TRAPHANDLER_NOEC(i31, 31)
TRAPHANDLER_NOEC(i32, 32)
TRAPHANDLER_NOEC(i33, 33)
TRAPHANDLER_NOEC(i34, 34)
TRAPHANDLER_NOEC(i35, 35)
TRAPHANDLER_NOEC(i36, 36)
TRAPHANDLER_NOEC(i37, 37)
TRAPHANDLER_NOEC(i38, 38)
TRAPHANDLER_NOEC(i39, 39)
TRAPHANDLER_NOEC(i40, 40)
TRAPHANDLER_NOEC(i41, 41)
TRAPHANDLER_NOEC(i42, 42)
TRAPHANDLER_NOEC(i43, 43)
TRAPHANDLER_NOEC(i44, 44)
TRAPHANDLER_NOEC(i45, 45)
TRAPHANDLER_NOEC(i46, 46)
TRAPHANDLER_NOEC(i47, 47)
TRAPHANDLER_NOEC(i48, 48)
 

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es
	pushal
	pushl $GD_KD
	popl %ds
	pushl $GD_KD
	popl %es
	pushl %esp
	call trap


