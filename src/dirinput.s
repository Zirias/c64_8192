.include "jsinput.inc"
.include "kbinput.inc"
.include "petscii_lc.inc"

.export dir_get

.code

dir_get:
		jsr	js_get
		bcc	dg_exit
		jsr	kb_in
		bcs	dg_exit
		ldx	#$5
dg_checkchar:	cmp	jskeymap-1,x
		beq	dg_founddir
		dex
		bne	dg_checkchar
		sec
		rts
dg_founddir:	txa
		clc
dg_exit:	rts

.data

jskeymap:	.byte 'i','k','j','l',' '

