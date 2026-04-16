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
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	adrp	x0, _msg@page
	add	x0, x0, _msg@pageoff
	bl	_puts
	mov	w0, #0
	bl	_exit
	ldp	x29, x30, [sp], 16
	ret
/* end function hacked */

.text
.balign 4
_smash:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
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
	ldp	x29, x30, [sp], 32
	ret
/* end function smash */

.text
.balign 4
.globl _main
_main:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	bl	_smash
	mov	w0, #1
	ldp	x29, x30, [sp], 16
	ret
/* end function main */

