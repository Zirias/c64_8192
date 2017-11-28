.include "random.inc"

.exportzp board
.export board_init
.export board_addpiece

.zeropage

board:		.res	$10
tmppos:		.res	1

.code

board_init:
		lda	#$0
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
		and	#$c
		beq	ba_add4
		lda	#$1
		bne	ba_done
ba_add4:	lda	#$2
ba_done:	ldx	tmppos
		sta	board,x
		rts
