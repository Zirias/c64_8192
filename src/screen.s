.include "vicconfig.inc"
.include "vic.inc"
.include "board.inc"
.include "charconv.inc"
.include "numconv.inc"
.include "drawreq.inc"

.export screen_init
.export screen_draw
.export screen_refresh

.zeropage

drawptr0:	.res	2
drawptr1:	.res	2
drawptr2:	.res	2
drawptr3:	.res	2
drawptr4:	.res	2
boardrow:	.res	1
boardcol:	.res	1
tilecol:	.res	1
screencol:	.res	1
nextreq:	.res	1
drawreq:	.res	1

.code

screen_init:
		dec	$01

		lda	#>vic_screenram
		sta	drawptr0+1		
		lda	#$20
		ldy	#$1
		sty	drawreq
		dey
		sty	drawptr0
		sty	BORDER_COLOR
		sty	BG_COLOR_0
		ldx	#$3
clearloop:	sta	(drawptr0),y
		dey
		bne	clearloop
		inc	drawptr0+1
		dex
		bne	clearloop
		ldy	#$e8
clearloop2:	sta	vic_screenram + $2ff, y
		dey
		bne	clearloop2

		lda	#>vic_screenram
		sta	drawptr0+1
		lda	#$04
		sta	boardrow
row0_repeat:	ldy	# 4*6 - 1
row0_outer:	ldx	#5
row0_inner:	lda	row0,x
		sta	(drawptr0),y
		dey
		bmi	row0_done
		dex
		bpl	row0_inner
		bmi	row0_outer
row0_done:	lda	drawptr0
		clc
		adc	#$28
		sta	drawptr0
		bcc	row1_start
		inc	drawptr0+1
row1_start:	lda	#$03
		sta	boardcol
row1_repeat:	ldy	# 4*6 - 1
row1_outer:	ldx	#5
row1_inner:	lda	row1,x
		sta	(drawptr0),y
		dey
		bmi	row1_next
		dex
		bpl	row1_inner
		bmi	row1_outer
row1_next:	lda	drawptr0
		clc
		adc	#$28
		sta	drawptr0
		bcc	row1_nocarry
		inc	drawptr0+1
row1_nocarry:	dec	boardcol
		bne	row1_repeat
		ldy	# 4*6 - 1
row2_outer:	ldx	#5
row2_inner:	lda	row2,x
		sta	(drawptr0),y
		dey
		bmi	row2_done
		dex
		bpl	row2_inner
		bmi	row2_outer
row2_done:	lda	drawptr0
		clc
		adc	#$28
		sta	drawptr0
		bcc	row2_nocarry
		inc	drawptr0+1
row2_nocarry:	dec	boardrow
		bne	row0_repeat
		
		lda	#$a0
		ldx	#$4e
lowerboxloop1:	sta	vic_screenram+$370,x
		dex
		bne	lowerboxloop1
		lda	#$e3
		ldx	#$26
lowerboxloop2:	sta	vic_screenram+$348,x
		eor	#$7
		sta	vic_screenram+$3c0,x
		eor	#$7
		dex
		bne	lowerboxloop2
		lda	#$e5
		sta	vic_screenram+$370
		sta	vic_screenram+$398
		lda	#$e7
		sta	vic_screenram+$397
		sta	vic_screenram+$3bf
		ldy	#$5b
		sty	vic_screenram+$348
		iny
		sty	vic_screenram+$36f
		iny
		sty	vic_screenram+$3e7
		iny
		sty	vic_screenram+$3c0

		ldx	#scorestrlen
scorelbl:	lda	scorestr-1,x
		sta	vic_screenram+$374,x
		dex
		bne	scorelbl

		ldx	#highscorestrlen
highscorelbl:	lda	highscorestr-1,x
		sta	vic_screenram+$387,x
		dex
		bne	highscorelbl

		inc	$01
		ldx	#$a0
		lda	#$d
lowerboxcol:	sta	$d800+$347,x
		dex
		bne	lowerboxcol

		rts
		
screen_draw:
		sta	nextreq
		and	#DRAWREQ_SCORE
		beq	sd_noscore
		ldx	#$3
copyscore:	lda	score,x
		sta	nc_num,x
		dex
		bpl	copyscore
		jsr	numtostring
sd_noscore:	lda	nextreq
		sta	drawreq
sd_wait:	lda	drawreq
		bne	sd_wait
sc_nodraw:	rts
		
screen_refresh:
		lda	drawreq
		and	#DRAWREQ_BOARD
		beq	sr_score
		jsr	sr_doboard

sr_score:	lda	drawreq
		and	#DRAWREQ_SCORE
		beq	sr_appear
		dec	$01
		ldx	#NUMSTRSIZE
copyscorestr:	lda	nc_string-1,x
		ora	#$80
		sta	vic_screenram+$39c,x
		dex
		bne	copyscorestr
		inc	$01

sr_appear:	lda	drawreq
		and	#DRAWREQ_APPEAR
		beq	sr_done
		lda	appearat
		lsr	a
		lsr	a
		tay
		jsr	sr_rowpointers
		lda	appearat
		and	#$3
		tay
		lda	#$0
		clc	
sr_coladd:	dey
		bmi	sr_appearcol
		adc	#$6
		bcc	sr_coladd
sr_appearcol:	sta	screencol
		ldy	screencol
		lda	#$0
		ldx	#$6
sr_cleartile:	sta	(drawptr0),y
		sta	(drawptr1),y
		sta	(drawptr2),y
		sta	(drawptr3),y
		sta	(drawptr4),y
		iny
		dex
		bne	sr_cleartile
		ldy	appear
		lda	tilecolors,y
		ldx	#$4
		ldy	screencol
		iny
sr_fillcenter:	sta	(drawptr1),y
		sta	(drawptr2),y
		sta	(drawptr3),y
		iny
		dex
		bne	sr_fillcenter
		lda	appearat
		lsr	a
		lsr	a
		tay
		lda	screenrowl2,y
		sta	drawptr0
		lda	captrow,y
		sta	drawptr0+1
		lda	appear
		asl	a
		asl	a
		tax
		lda	#$4
		sta	tilecol
		ldy	screencol
		iny
		dec	$01
sr_appcap:	lda	tilestrings,x
		sta	(drawptr0),y
		iny
		inx
		dec	tilecol
		bne	sr_appcap
		inc	$01
			
sr_done:	lda	#$0
		sta	drawreq
		rts

sr_doboard:
		ldx	#$10
		lda	#$3
		sta	boardrow
sr_boardloop:	ldy	boardrow
		jsr	sr_rowpointers
		lda	#$3
		sta	boardcol
		ldy	#$17
sr_rowloop:	lda	#$6
		sta	tilecol
		dex
		lda	board,x
		sty	screencol
		tay
		lda	tilecolors,y
		ldy	screencol
sr_filltile:	sta	(drawptr0),y
		sta	(drawptr1),y
		sta	(drawptr2),y
		sta	(drawptr3),y
		sta	(drawptr4),y
		dey
		dec	tilecol
		bne	sr_filltile
		dec	boardcol
		bpl	sr_rowloop
		dec	boardrow
		bpl	sr_boardloop

		dec	$01
		inc	boardrow
captloop:	ldy	boardrow
		lda	screenrowl2,y
		sta	drawptr0
		lda	captrow,y
		sta	drawptr0+1
		lda	#$3
		sta	boardcol
		ldy	#$1
captrowloop:	lda	board,x
		asl	a
		asl	a
		stx	screencol
		tax
		lda	#$4
		sta	tilecol
captoutloop:	lda	tilestrings,x
		sta	(drawptr0),y
		iny
		inx
		dec	tilecol
		bne	captoutloop
		iny
		iny
		ldx	screencol
		inx
		dec	boardcol
		bpl	captrowloop
		inc	boardrow
		cpx	#$10
		bne	captloop
		inc	$01
		rts

sr_rowpointers:
		lda	screenrowl0,y
		sta	drawptr0
		lda	screenrowl1,y
		sta	drawptr1
		lda	screenrowl2,y
		sta	drawptr2
		lda	screenrowl3,y
		sta	drawptr3
		lda	screenrowl4,y
		sta	drawptr4
		lda	colrowh0_1,y
		sta	drawptr0+1
		sta	drawptr1+1
		lda	colrowh2,y
		sta	drawptr2+1
		lda	colrowh3_4,y
		sta	drawptr3+1
		sta	drawptr4+1
		rts

.data

row0:		.byte	$5b, $e3, $e3, $e3, $e3, $5c
row1:		.byte	$e5, $a0, $a0, $a0, $a0, $e7
row2:		.byte	$5e, $e4, $e4, $e4, $e4, $5d

tilestrings:	revchr	"    "
		.byte	$a0, $f1, $f2, $a0
		.byte	$a0, $f3, $f4, $a0
		.byte	$a0, $f5, $f6, $a0
		revchr	" 16 "
		revchr	" 32 "
		revchr	" 64 "
		.byte	$f7, $f8, $f9, $f6
		.byte	$f1, $fa, $fb, $fc
		.byte	$fd, $fe, $f8, $f2
		revchr	"1024"
		revchr	"2048"
		revchr	"4096"
		revchr	"8192"

tilecolors:	.byte	$b, $f, $c, $9, $8, $2, $a, $4, $7, $3, $6, $e, $5, $d

screenrowl0:	.byte	$00, $c8, $90, $58
screenrowl1:	.byte	$28, $f0, $b8, $80
screenrowl2:	.byte	$50, $18, $e0, $a8
screenrowl3:	.byte	$78, $40, $08, $d0
screenrowl4:	.byte	$a0, $68, $30, $f8

colrowh0_1:	.byte	$d8, $d8, $d9, $da
colrowh2:	.byte	$d8, $d9, $d9, $da
colrowh3_4:	.byte	$d8, $d9, $da, $da
captrow:	.byte	>vic_screenram, (>vic_screenram)+1
		.byte	(>vic_screenram)+1, (>vic_screenram)+2

scorestr:	revchr "Score:"
scorestrlen	= *-scorestr
highscorestr:	revchr "High score:"
highscorestrlen	= *-highscorestr
