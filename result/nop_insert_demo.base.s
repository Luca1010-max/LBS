.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -48]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe10b, lsl #16
	movk	x17, #0x199, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_init
	str	x19, [x29, 40]
	mov	x1, #1
	add	x0, x29, #28
	add	x1, x0, x1
	mov	w0, #0
	strb	w0, [x1]
	mov	w19, #0
L2:
	mov	w0, #65
	add	w0, w19, w0
	add	x1, x29, #28
	strb	w0, [x1]
	add	x0, x29, #28
	bl	_puts
	mov	w0, #1
	add	w19, w19, w0
	cmp	w19, #4
	ble	L2
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe10b, lsl #16
	movk	x17, #0x199, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_check
	ldr	x19, [x29, 40]
	ldp	x29, x30, [sp], 48
	ret
/* end function main */

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

