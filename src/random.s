.include "vic.inc"

.export rnd_init
.export	rnd

.zeropage

rnd_state:	.res	4
rnd_buf:	.res	4

.code

rnd_init:
		lda	#$0
		ldx	#$3
rndi_clrloop:	sta	rnd_state,x
		dex
		bne	rndi_clrloop
		lda	VIC_RASTER
		bne	rndi_ok
		lda	#$7f
rndi_ok:	sta	rnd_state
		rts

rnd:
		ldx	#$3
r_copyloop:	lda	rnd_state,x
		sta	rnd_buf,x
		dex
		bpl	r_copyloop
		ldx	#$3
r_shiftloop:	asl	rnd_buf
		rol	rnd_buf+1
		rol	rnd_buf+2
		rol	rnd_buf+3
		dex
		bpl	r_shiftloop
		ldx	#$3
r_xorloop:	lda	rnd_state,x
		eor	rnd_buf,x
		sta	rnd_state,x
		dex
		bpl	r_xorloop
		lda	rnd_state+3
		lsr	a
		eor	rnd_state
		sta	rnd_state
		eor	rnd_state+3
		sta	rnd_state+3
		rts

