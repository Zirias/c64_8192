.include "vicconfig.inc"
.include "vic.inc"
.include "zp.inc"
.include "board.inc"
.include "charconv.inc"

.export screen_init
.export screen_draw

.zeropage

drawptr:	.res	2
boardrow:	.res	1
tilerow:	.res	1
boardcol:	.res	1
boardindex:	.res	1
tilecol:	.res	1

.code

screen_init:
		lda	#>vic_colram
		sta	TMPW0+1		
		lda	#$20
		ldy	#$0
		sty	TMPW0
		sty	BORDER_COLOR
		sty	BG_COLOR_0
		ldx	#$3
clearloop:	sta	(TMPW0),y
		dey
		bne	clearloop
		inc	TMPW0+1
		dex
		bne	clearloop
		ldy	#$e8
clearloop2:	sta	vic_colram + $2ff, y
		dey
		bne	clearloop2

		lda	#>vic_colram
		sta	TMPW0+1
		lda	#$04
		sta	TMPB0
row0_repeat:	ldy	# 4*6 - 1
row0_outer:	ldx	#5
row0_inner:	lda	row0,x
		sta	(TMPW0),y
		dey
		bmi	row0_done
		dex
		bpl	row0_inner
		bmi	row0_outer
row0_done:	lda	TMPW0
		clc
		adc	#$28
		sta	TMPW0
		bcc	row1_start
		inc	TMPW0+1
row1_start:	lda	#$03
		sta	TMPB1
row1_repeat:	ldy	# 4*6 - 1
row1_outer:	ldx	#5
row1_inner:	lda	row1,x
		sta	(TMPW0),y
		dey
		bmi	row1_next
		dex
		bpl	row1_inner
		bmi	row1_outer
row1_next:	lda	TMPW0
		clc
		adc	#$28
		sta	TMPW0
		bcc	row1_nocarry
		inc	TMPW0+1
row1_nocarry:	dec	TMPB1
		bne	row1_repeat
		ldy	# 4*6 - 1
row2_outer:	ldx	#5
row2_inner:	lda	row2,x
		sta	(TMPW0),y
		dey
		bmi	row2_done
		dex
		bpl	row2_inner
		bmi	row2_outer
row2_done:	lda	TMPW0
		clc
		adc	#$28
		sta	TMPW0
		bcc	row2_nocarry
		inc	TMPW0+1
row2_nocarry:	dec	TMPB0
		bne	row0_repeat
		
		rts
		
screen_draw:
		lda	#$0
		sta	boardrow

		lda	#$0
		sta	drawptr
		lda	#$d8
		sta	drawptr+1

boardloop:	lda	#$5
		sta	tilerow

bdrowloop:	lda	#$4
		sta	boardcol
		ldy	#$0

		lda	boardrow
		asl	a
		asl	a
		sta	boardindex
		tax

scrowloop:	lda	#$6
		sta	tilecol
		lda	board,x
		tax
		lda	tilecolors,x
tlrowloop:	sta	(drawptr),y
		iny
		dec	tilecol
		bne	tlrowloop
		dec	boardcol
		beq	scrowdone
		inc	boardindex
		ldx	boardindex
		bne	scrowloop
scrowdone:	lda	drawptr
		clc
		adc	#$28
		sta	drawptr
		bcc	rownocarry
		inc	drawptr+1
rownocarry:	dec	tilerow
		bne	bdrowloop
		inc	boardrow
		ldx	boardrow
		cpx	#$4
		bne	boardloop

		rts

.data

row0:		.byte	$5b, $e3, $e3, $e3, $e3, $5c
row1:		.byte	$e5, $e0, $e0, $e0, $e0, $e7
row2:		.byte	$5e, $e4, $e4, $e4, $e4, $5d

tilestrings:	revchr	"    "
		revchr	"  2 "
		revchr	"  4 "
		revchr	"  8 "
		revchr	" 16 "
		revchr	" 32 "
		revchr	" 64 "
		revchr	" 128"
		revchr	" 256"
		revchr	" 512"
		revchr	"1024"
		revchr	"2048"
		revchr	"4096"
		revchr	"8192"

tilecolors:	.byte	$b, $f, $c, $9, $8, $2, $a, $4, $7, $3, $6, $e, $5, $d

