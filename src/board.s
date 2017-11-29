.include "random.inc"

.exportzp board
.export board_init
.export board_addpiece
.export board_up
.export board_down
.export board_left
.export board_right
.export board_step

DIR_UP		= 1
DIR_DOWN	= 2
DIR_LEFT	= 3
DIR_RIGHT	= 4

.zeropage

board:		.res	$10
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
		ldx	#$f
clearloop:	sta	board,x
		dex
		bpl	clearloop
		jsr	board_addpiece

board_addpiece:
		ldx	#$10
		ldy	#$0
ba_scan:	dex
		bmi	ba_scandone
		lda	board,x
		bne	ba_scan
		iny
		bne	ba_scan
ba_scandone:	cpy	#$0
		bne	ba_doadd
		sec
		rts
ba_doadd:	jsr	rnd
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
		clc
		rts

board_up:
		lda	#DIR_UP
		bne	board_setdir

board_down:
		lda	#DIR_DOWN
		bne	board_setdir

board_left:
		lda	#DIR_LEFT
		bne	board_setdir

board_right:
		lda	#DIR_RIGHT
		
board_setdir:	sta	direction
		lda	#$1
		sta	moving
		lda	#$0
		ldx	#$3
initcombined:	sta	combined,x
		dex
		bpl	initcombined
		rts


getidx:
		lda	direction
		cmp	#DIR_RIGHT
		beq	getidx_right
		cmp	#DIR_LEFT
		beq	getidx_left
		cmp	#DIR_DOWN
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
		bne	bs_stepnext
		cmp	tmppos
		bne	bs_stepnext
		lda	#$0
		ldx	fromidx
		sta	board,x
		ldx	toidx
		inc	board,x
		inc	stepdone
		ldx	moverow
		inc	combined,x
bs_stepnext:	dec	movestep
		bpl	bs_steploop
		dec	moverow
		bpl	bs_rowloop
		lda	#$0
		cmp	stepdone
		rts
