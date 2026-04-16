.data
.balign 8
_secret:
	.ascii "SECRETSX"
	.byte 0
/* end data */

.text
.balign 4
.globl _timing_check_secret
_timing_check_secret:
	stp	x29, x30, [sp, -64]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0xfd97
	movk	x17, #0xf7e9, lsl #16
	movk	x17, #0x3f49, lsl #32
	movk	x17, #0x555, lsl #48
	bl	___qbe_stack_canary_init
	str	x19, [x29, 56]
	str	x20, [x29, 48]
	str	x21, [x29, 40]
	mov	w20, #0
	mov	w19, #0
L2:
	mov	w1, #3392
	movk	w1, #0x3, lsl #16
	cmp	w20, w1
	bge	L4
	adrp	x1, _secret@page
	add	x1, x1, _secret@pageoff
	mov	x21, x0
	bl	_strcmp
	mov	w1, w0
	mov	x0, x21
	orr	w19, w19, w1
	mov	w1, #1
	add	w20, w20, w1
	b	L2
L4:
	cmp	w19, #0
	cset	w0, eq
	add	x16, x29, #16
	movz	x17, #0xfd97
	movk	x17, #0xf7e9, lsl #16
	movk	x17, #0x3f49, lsl #32
	movk	x17, #0x555, lsl #48
	bl	___qbe_stack_canary_check
	ldr	x19, [x29, 56]
	ldr	x20, [x29, 48]
	ldr	x21, [x29, 40]
	ldp	x29, x30, [sp], 64
	ret
/* end function timing_check_secret */

.text
.balign 4
___qbe_stack_canary_init:
	str	x17, [x16]
	ret
/* end function __qbe_stack_canary_init */

.text
.balign 4
___qbe_stack_canary_check:
	ldr	x15, [x16]
	cmp	x15, x17
	b.ne	___qbe_stack_canary_fail
	ret
/* end function __qbe_stack_canary_check */

.text
.balign 4
___qbe_stack_canary_fail:
	brk	#1001
/* end function __qbe_stack_canary_fail */

