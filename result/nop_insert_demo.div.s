.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -48]!
	mov	x29, sp
	str	x19, [x29, 40]
	mov	x1, #1
	nop
	add	x0, x29, #28
	add	x1, x0, x1
	nop
	mov	w0, #0
	strb	w0, [x1]
	nop
	mov	w19, #0
L2:
	mov	w0, #65
	add	w0, w19, w0
	add	x1, x29, #28
	nop
	strb	w0, [x1]
	add	x0, x29, #28
	nop
	bl	_puts
	mov	w0, #1
	add	w19, w19, w0
	cmp	w19, #4
	ble	L2
	ldr	x19, [x29, 40]
	ldp	x29, x30, [sp], 48
	ret
/* end function main */

