.text
.balign 4
.globl _fa
_fa:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	w0, #11
	ldp	x29, x30, [sp], 16
	ret
/* end function fa */

.text
.balign 4
.globl _fb
_fb:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	w0, #22
	ldp	x29, x30, [sp], 16
	ret
/* end function fb */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	str	x19, [x29, 24]
	str	x20, [x29, 16]
	bl	_fa
	mov	w19, w0
	bl	_fb
	mov	w20, w0
	bl	_fc
	mov	w1, w0
	add	w0, w19, w20
	add	w0, w0, w1
	ldr	x19, [x29, 24]
	ldr	x20, [x29, 16]
	ldp	x29, x30, [sp], 32
	ret
/* end function main */

.text
.balign 4
.globl _fc
_fc:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	w0, #33
	ldp	x29, x30, [sp], 16
	ret
/* end function fc */

