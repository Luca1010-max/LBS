.text
.balign 4
.globl _mix
_mix:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	w18, w6
	mov	w6, w1
	mov	w1, w18
	mov	w18, w7
	mov	w7, w0
	mov	w0, w18
	add	w7, w7, w6
	add	w6, w2, w3
	add	w3, w4, w5
	add	w2, w1, w0
	mov	w0, #3
	mul	w1, w7, w0
	mov	w0, #5
	mul	w0, w6, w0
	mov	w4, #7
	mul	w5, w3, w4
	mov	w4, #9
	mul	w4, w2, w4
	eor	w1, w1, w5
	eor	w0, w0, w4
	add	w0, w1, w0
	sub	w4, w4, w7
	add	w5, w5, w6
	mul	w4, w4, w5
	mov	w5, #1023
	and	w0, w0, w5
	mov	w5, #1023
	and	w4, w4, w5
	add	w0, w0, w4
	sub	w0, w0, w3
	add	w0, w0, w2
	eor	w0, w0, w1
	ldp	x29, x30, [sp], 16
	ret
/* end function mix */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	str	x19, [x29, 24]
	mov	w7, #8
	mov	w6, #7
	mov	w5, #6
	mov	w4, #5
	mov	w3, #4
	mov	w2, #3
	mov	w1, #2
	mov	w0, #1
	bl	_mix
	mov	w19, w0
	mov	w7, #18
	mov	w6, #17
	mov	w5, #16
	mov	w4, #15
	mov	w3, #14
	mov	w2, #13
	mov	w1, #12
	mov	w0, #11
	bl	_mix
	add	w0, w19, w0
	ldr	x19, [x29, 24]
	ldp	x29, x30, [sp], 32
	ret
/* end function main */

