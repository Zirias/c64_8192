.include "jsinput.inc"

.export title_loop

.code


title_loop:	jsr	js_flush
tl_waitfire:	jsr	js_get
		bcs	tl_waitfire
		cmp	#JS_FIRE
		bne	tl_waitfire
		rts


