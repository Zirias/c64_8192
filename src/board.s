.exportzp board
.export board_init

.zeropage

board:		.res	$10

.code

board_init:
		lda	#$0
		ldx	#$10
clearloop:	sta	board,x
		dex
		bpl	clearloop
		rts


