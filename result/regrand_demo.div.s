.text
.balign 4
.globl _mix
_mix:
	stp	x29, x30, [sp, -80]!
	mov	x29, sp
	str	x19, [x29, 72]
	str	x20, [x29, 64]
	str	x21, [x29, 56]
	str	x24, [x29, 48]
	str	x25, [x29, 40]
	str	x26, [x29, 32]
	str	x27, [x29, 24]
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
	ldr	x19, [x29, 72]
	ldr	x20, [x29, 64]
	ldr	x21, [x29, 56]
	ldr	x24, [x29, 48]
	ldr	x25, [x29, 40]
	ldr	x26, [x29, 32]
	ldr	x27, [x29, 24]
	ldp	x29, x30, [sp], 80
	ret
/* end function mix */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	str	x24, [x29, 24]
	str	x28, [x29, 16]
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
	ldr	x24, [x29, 24]
	ldr	x28, [x29, 16]
	ldp	x29, x30, [sp], 32
	ret
/* end function main */

