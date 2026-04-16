.text
.balign 4
.globl _mix
_mix:
	stp	x29, x30, [sp, -96]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x190f
	movk	x17, #0x39c7, lsl #16
	movk	x17, #0x3f23, lsl #32
	movk	x17, #0x9d15, lsl #48
	bl	___qbe_stack_canary_init
	str	x19, [x29, 88]
	str	x20, [x29, 80]
	str	x21, [x29, 72]
	str	x24, [x29, 64]
	str	x25, [x29, 56]
	str	x26, [x29, 48]
	str	x27, [x29, 40]
	add	w25, w0, w1
	add	w0, w2, w3
	add	w21, w4, w5
	add	w27, w6, w7
	mov	w11, #3
	mul	w5, w25, w11
	mov	w9, #5
	mul	w9, w0, w9
	mov	w24, #7
	mul	w6, w21, w24
	mov	w8, #9
	mul	w1, w27, w8
	eor	w26, w5, w6
	eor	w12, w9, w1
	add	w8, w26, w12
	sub	w16, w1, w25
	add	w19, w6, w0
	mul	w11, w16, w19
	mov	w4, #1023
	and	w4, w8, w4
	mov	w20, #1023
	and	w8, w11, w20
	add	w16, w4, w8
	sub	w14, w16, w21
	add	w5, w14, w27
	eor	w0, w5, w26
	add	x16, x29, #16
	movz	x17, #0x190f
	movk	x17, #0x39c7, lsl #16
	movk	x17, #0x3f23, lsl #32
	movk	x17, #0x9d15, lsl #48
	bl	___qbe_stack_canary_check
	ldr	x19, [x29, 88]
	ldr	x20, [x29, 80]
	ldr	x21, [x29, 72]
	ldr	x24, [x29, 64]
	ldr	x25, [x29, 56]
	ldr	x26, [x29, 48]
	ldr	x27, [x29, 40]
	ldp	x29, x30, [sp], 96
	ret
/* end function mix */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -48]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe109, lsl #16
	movk	x17, #0xd99, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_init
	str	x24, [x29, 40]
	str	x28, [x29, 32]
	mov	w7, #8
	mov	w6, #7
	mov	w5, #6
	mov	w4, #5
	mov	w3, #4
	mov	w2, #3
	mov	w1, #2
	mov	w0, #1
	bl	_mix
	mov	w24, w0
	mov	w7, #18
	mov	w6, #17
	mov	w5, #16
	mov	w4, #15
	mov	w3, #14
	mov	w2, #13
	mov	w1, #12
	mov	w0, #11
	bl	_mix
	mov	w28, w0
	add	w0, w24, w28
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe109, lsl #16
	movk	x17, #0xd99, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_check
	ldr	x24, [x29, 40]
	ldr	x28, [x29, 32]
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

