.include "random.inc"
.include "jscodes.inc"

.exportzp board
.exportzp score
.export board_init
.export board_addpiece
.export board_setdir
.export board_step
.export board_canmove

.zeropage

board:		.res	$10
score:		.res	4
scoreadd:	.res	2
tmppos:		.res	1
direction:	.res	1
moving:		.res	1
combined:	.res	4
moverow:	.res	1
movestep:	.res	1
stepdone:	.res	1
fromidx:	.res	1
toidx:		.res	1

.code

board_init:
		lda	#$0
		sta	moving
		ldx	#$13		; board + score
clearloop:	sta	board,x
		dex
		bpl	clearloop
		jsr	board_addpiece

board_addpiece:
		jsr	rnd
		and	#$1f
		tay
		ldx	#$10
ba_scan2:	dex
		bpl	ba_scannext
		ldx	#$f
ba_scannext:	lda	board,x
		bne	ba_scan2
		dey
		bpl	ba_scan2
		stx	tmppos
		jsr	rnd
		tax
		and	#$f
		beq	ba_add4
		txa
		and	#$f1
		beq	ba_add4
		lda	#$1
		bne	ba_done
ba_add4:	lda	#$2
ba_done:	ldx	tmppos
		sta	board,x
		rts

board_setdir:	cmp	#JS_FIRE
		bcs	bs_done
		sta	direction
		lda	#$1
		sta	moving
		lda	#$3
		ldx	#$3
initcombined:	sta	combined,x
		dex
		bpl	initcombined
bs_done:	rts


getidx:
		lda	direction
		cmp	#JS_RIGHT
		beq	getidx_right
		cmp	#JS_LEFT
		beq	getidx_left
		cmp	#JS_DOWN
		beq	getidx_down

getidx_up:	
		lda	#$3
		sbc	movestep
		asl	a
		asl	a
		adc	moverow
		sta	toidx
		adc	#$4
		sta	fromidx
		rts

getidx_down:
		lda	movestep
		asl	a
		asl	a
		adc	moverow
		sta	fromidx
		adc	#$4
		sta	toidx
		rts

getidx_left:
		lda	moverow
		asl	a
		asl	a
		adc	#$3
		sbc	movestep
		tax
		stx	toidx
		inx
		stx	fromidx
		rts

getidx_right:
		lda	moverow
		asl	a
		asl	a
		adc	movestep
		tax
		stx	fromidx
		inx
		stx	toidx
		rts	

board_step:
		lda	#$0
		sta	stepdone
		lda	#$3
		sta	moverow
bs_rowloop:	lda	#$2
		sta	movestep
bs_steploop:	jsr	getidx
		ldx	fromidx
		lda	board,x
		sta	tmppos
		beq	bs_stepnext
		ldx	toidx
		lda	board,x
		bne	bs_checkcomb
		lda	tmppos
		sta	board,x
		lda	#$0
		ldx	fromidx
		sta	board,x
		inc	stepdone
		bne	bs_stepnext
bs_checkcomb:	ldx	moverow
		ldy	combined,x
		cpy	movestep
		bcc	bs_stepnext
		beq	bs_stepnext
		cmp	tmppos
		bne	bs_stepnext
		cmp	#$d
		beq	bs_stepnext
		lda	#$0
		ldx	fromidx
		sta	board,x
		ldx	toidx
		inc	board,x
		inc	stepdone
		ldy	#$1
		sty	scoreadd
		dey
		sty	scoreadd+1
		ldy	board,x
bs_rolloop:	asl	scoreadd
		rol	scoreadd+1
		dey
		bne	bs_rolloop
		lda	score
		adc	scoreadd
		sta	score
		lda	score+1
		adc	scoreadd+1
		sta	score+1
		lda	score+2
		adc	#$0
		sta	score+2
		lda	score+3
		adc	#$0
		sta	score+3
		ldx	moverow
		lda	movestep
		sta	combined,x
bs_stepnext:	dec	movestep
		bpl	bs_steploop
		dec	moverow
		bpl	bs_rowloop
		lda	#$0
		cmp	stepdone
		rts

board_canmove:
		ldx	#$f
		sec
bcm_empty:	lda	board,x
		bne	bcm_notempty
bcm_out:	rts
bcm_notempty:	dex
		bpl	bcm_empty
		ldx	#$e
bcm_adjacent:	txa
		and	#$3
		eor	#$3
		beq	bcm_skipcols
		lda	board,x
		cmp	board+1,x
		beq	bcm_out
bcm_skipcols:	cpx	#$c
		bcs	bcm_skiprows
		lda	board,x
		cmp	board+4,x
		beq	bcm_out
bcm_skiprows:	dex
		bpl	bcm_adjacent
		clc
		rts

