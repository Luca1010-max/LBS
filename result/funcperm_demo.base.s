.text
.balign 4
.globl _fa
_fa:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x97e7
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x353d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_init
	mov	w0, #11
	add	x16, x29, #16
	movz	x17, #0x97e7
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x353d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
	ret
/* end function fa */

.text
.balign 4
.globl _fb
_fb:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x9b8f
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x313d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_init
	mov	w0, #22
	add	x16, x29, #16
	movz	x17, #0x9b8f
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x313d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
	ret
/* end function fb */

.text
.balign 4
.globl _fc
_fc:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x9b41
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x333d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_init
	mov	w0, #33
	add	x16, x29, #16
	movz	x17, #0x9b41
	movk	x17, #0x9bd1, lsl #16
	movk	x17, #0x333d, lsl #32
	movk	x17, #0x9379, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
	ret
/* end function fc */

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
	str	x19, [x29, 40]
	str	x20, [x29, 32]
	bl	_fa
	mov	w19, w0
	bl	_fb
	mov	w20, w0
	bl	_fc
	mov	w1, w0
	add	w0, w19, w20
	add	w0, w0, w1
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe109, lsl #16
	movk	x17, #0xd99, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_check
	ldr	x19, [x29, 40]
	ldr	x20, [x29, 32]
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

