.include "cia.inc"
.include "jscodes.inc"

.export js_init
.export js_check
.export js_get
.export js_flush

.zeropage

js_buf:		.res	$10
js_latest:	.res	1
js_debounce:	.res	1
js_next:	.res	1
js_decode:	.res	1
js_front:	.res	1
js_back:	.res	1
js_repeat:	.res	1
js_repcnt:	.res	1

.code

js_init:
		lda	#$0
		sta	js_front
		sta	js_back
		sta	js_debounce
		sta	js_next
		sta	js_repeat
		rts

js_check:
		lda	CIA1_PRA
		and	#$1f
		eor	#$1f
		tay
		and	js_debounce
		eor	js_debounce
		beq	jc_nobounce
		cpy	js_next
		beq	jc_nobounce
		sty	js_next
		rts
jc_nobounce:	tya
		sta	js_debounce
		sta	js_next
		beq	jc_done
		cmp	js_latest
		beq	jc_done
		and	js_latest
		eor	js_latest
		bne	jc_done
		tya
		eor	js_latest
		sta	js_decode
		lsr	js_decode
		bcc	jc_skipup
		lda	#JS_UP
		jsr	jc_enqueue
jc_skipup:	lsr	js_decode
		bcc	jc_skipdown
		lda	#JS_DOWN
		jsr	jc_enqueue
jc_skipdown:	lsr	js_decode
		bcc	jc_skipleft
		lda	#JS_LEFT
		jsr	jc_enqueue
jc_skipleft:	lsr	js_decode
		bcc	jc_skipright
		lda	#JS_RIGHT
		jsr	jc_enqueue
jc_skipright:	lsr	js_decode
		bcc	jc_done
		lda	#JS_FIRE
		jsr	jc_enqueue
jc_done:	sty	js_latest
		rts

jc_enqueue:	ldx	js_front
		dex
		bpl	jc_store
		ldx	#$f
jc_store:	stx	js_front
		sta	js_buf,x
		rts

js_get:
		ldx	js_back
		cpx	js_front
		beq	jg_done
		dex
		bpl	jg_dequeue
		ldx	#$f
jg_dequeue:	stx	js_back
		lda	js_buf,x
		clc
jg_done:	rts

js_flush:
		ldx	js_front
		stx	js_back
		rts
