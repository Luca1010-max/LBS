.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -48]!
	mov	x29, sp
	str	x19, [x29, 40]
	str	x20, [x29, 32]
	add	x3, x29, #24
	mov	x2, #29477
	movk	x2, #0x6325, lsl #16
	str	x2, [x3]
	mov	x2, #8
	add	x19, x1, x2
	mov	w1, #1
	sub	w20, w0, w1
L1:
	cmp	w20, #0
	beq	L6
	cmp	w20, #1
	beq	L4
	mov	w1, #32
	b	L5
L4:
	mov	w1, #10
L5:
	ldr	x0, [x19]
	mov	x2, #16
	sub	sp, sp, x2
	mov	x2, #8
	add	x2, sp, x2
	str	w1, [x2]
	mov	x1, #0
	add	x1, sp, x1
	str	x0, [x1]
	add	x0, x29, #24
	bl	_printf
	mov	x0, #16
	add	sp, sp, x0
	mov	x0, #8
	add	x19, x19, x0
	mov	w0, #1
	sub	w20, w20, w0
	b	L1
L6:
	mov	w0, #0
	ldr	x19, [x29, 40]
	ldr	x20, [x29, 32]
	ldp	x29, x30, [sp], 48
	ret
/* end function main */

