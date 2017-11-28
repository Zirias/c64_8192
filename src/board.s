.exportzp board
.export board_init

.zeropage

board:		.res	$10

.code

board_init:
		ldy	#$0
		ldx	#$f
clearloop:	sty	board,x
		iny
		cpy	#$0e
		bne	next
		ldy	#$0
next:		dex
		bpl	clearloop
		rts

