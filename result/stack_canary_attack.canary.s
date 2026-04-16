.data
.balign 1
_msg:
	.ascii "control flow hijacked"
	.byte 0
/* end data */

.data
.balign 8
_slot:
	.quad 0
/* end data */

.text
.balign 4
_hacked:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0xfba7
	movk	x17, #0x2f2b, lsl #16
	movk	x17, #0xbf5f, lsl #32
	movk	x17, #0xedd1, lsl #48
	bl	___qbe_stack_canary_init
	adrp	x0, _msg@page
	add	x0, x0, _msg@pageoff
	bl	_puts
	mov	w0, #0
	bl	_exit
	add	x16, x29, #16
	movz	x17, #0xfba7
	movk	x17, #0x2f2b, lsl #16
	movk	x17, #0xbf5f, lsl #32
	movk	x17, #0xedd1, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
	ret
/* end function hacked */

.text
.balign 4
_smash:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x6b39
	movk	x17, #0xcff3, lsl #16
	movk	x17, #0x8949, lsl #32
	movk	x17, #0xe7d3, lsl #48
	bl	___qbe_stack_canary_init
	mov	x1, #-16
	add	x0, x29, #24
	add	x2, x0, x1
	mov	x1, #-8
	add	x0, x29, #24
	add	x1, x0, x1
	adrp	x0, _slot@page
	add	x0, x0, _slot@pageoff
	str	x2, [x0]
	adrp	x0, _hacked@page
	add	x0, x0, _hacked@pageoff
	str	x0, [x2]
	adrp	x0, _slot@page
	add	x0, x0, _slot@pageoff
	str	x1, [x0]
	mov	x0, #0
	str	x0, [x1]
	add	x16, x29, #16
	movz	x17, #0x6b39
	movk	x17, #0xcff3, lsl #16
	movk	x17, #0x8949, lsl #32
	movk	x17, #0xe7d3, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
	ret
/* end function smash */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe109, lsl #16
	movk	x17, #0xd99, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_init
	bl	_smash
	mov	w0, #1
	add	x16, x29, #16
	movz	x17, #0x4387
	movk	x17, #0xe109, lsl #16
	movk	x17, #0xd99, lsl #32
	movk	x17, #0x85b9, lsl #48
	bl	___qbe_stack_canary_check
	ldp	x29, x30, [sp], 32
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

