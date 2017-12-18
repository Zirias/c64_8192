.include "jsinput.inc"
.include "vic.inc"
.include "vicconfig.inc"
.include "charconv.inc"

.export title_init
.export title_scroll
.export title_loop

.zeropage

nextchar_0:	.res	8
nextchar_1:	.res	8
charbit:	.res	1
scrtextpos:	.res	1
temp1:		.res	1
temp2:		.res	1
startcol:	.res	1
colcounter:	.res	1


.segment "TSPRITES"

sprite_0:	.res	$40
sprite_1:	.res	$40
sprite_2:	.res	$40
sprite_3:	.res	$40
sprite_4:	.res	$40
sprite_5:	.res	$40
sprite_6:	.res	$40
sprite_7:	.res	$40
sprite_8:	.res	$40
sprite_9:	.res	$40
sprite_a:	.res	$40
sprite_b:	.res	$40
sprite_c:	.res	$40
sprite_d:	.res	$40
sprite_e:	.res	$40
sprite_f:	.res	$40

.segment "TCODE"

title_init:
		lda	#$b5
		sta	SPRITE_0_Y
		sta	SPRITE_1_Y
		sta	SPRITE_2_Y
		sta	SPRITE_3_Y
		sta	SPRITE_4_Y
		sta	SPRITE_5_Y
		sta	SPRITE_6_Y
		lda	#$08
		sta	SPRITE_0_X
		lda	#$38
		sta	SPRITE_1_X
		lda	#$68
		sta	SPRITE_2_X
		lda	#$98
		sta	SPRITE_3_X
		lda	#$c8
		sta	SPRITE_4_X
		lda	#$f8
		sta	SPRITE_5_X
		lda	#$28
		sta	SPRITE_6_X
		lda	#$40
		sta	SPRITE_X_HB
		dec	$01
		ldy	#$46
		ldx	#$6
ti_spptr:	tya
		sta	vic_colram+$3f8,x
		dey
		dex
		bpl	ti_spptr
		ldy	#$4
		lda	#>sprite_0
		sta	ti_spclrdst
		lda	#$0
		tax
ti_spclrdst	= *+2
ti_spclr:	sta	$ff00,x
		inx
		bne	ti_spclr
		inc	ti_spclrdst
		dey
		bne	ti_spclr
		inc	$01
		lda	#$ff
		sta	SPRITE_DBL_X
		sta	SPRITE_DBL_Y
		lda	#$7f
		sta	SPRITE_SHOW
		lda	#$0
		sta	charbit
		sta	scrtextpos
		sta	startcol
		sta	colcounter
		rts

title_scroll:
		ldx	#$2
ts_w0:		dex
		bne	ts_w0
ts_col0		= *+1
		lda	#$0b
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$b
ts_w1:		dex
		bne	ts_w1
ts_col1		= *+1
		lda	#$0c
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$b
ts_w2:		dex
		bne	ts_w2
		nop
		nop
		nop
ts_col2		= *+1
		lda	#$0f
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$8
ts_w3:		dex
		bne	ts_w3
		nop
ts_col3		= *+1
		lda	#$0d
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$b
ts_w4:		dex
		bne	ts_w4
ts_col4		= *+1
		lda	#$01
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$b
ts_w5:		dex
		bne	ts_w5
ts_col5		= *+1
		lda	#$0f
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$b
ts_w6:		dex
		bne	ts_w6
ts_col6		= *+1
		lda	#$0c
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		ldx	#$8
ts_w7:		dex
		bne	ts_w7
ts_col7		= *+1
		lda	#$0b
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL

		lda	#$01
		eor	colcounter
		sta	colcounter
		beq	ts_doscroll

		ldx	startcol
		dex
		bpl	ts_docolors
		ldx	#numcolors-1
ts_docolors:	stx	startcol
		lda	colors,x
		sta	ts_col0
		dex
		bpl	ts_docol1
		ldx	#numcolors-1
ts_docol1:	lda	colors,x
		sta	ts_col1
		dex
		bpl	ts_docol2
		ldx	#numcolors-1
ts_docol2:	lda	colors,x
		sta	ts_col2
		dex
		bpl	ts_docol3
		ldx	#numcolors-1
ts_docol3:	lda	colors,x
		sta	ts_col3
		dex
		bpl	ts_docol4
		ldx	#numcolors-1
ts_docol4:	lda	colors,x
		sta	ts_col4
		dex
		bpl	ts_docol5
		ldx	#numcolors-1
ts_docol5:	lda	colors,x
		sta	ts_col5
		dex
		bpl	ts_docol6
		ldx	#numcolors-1
ts_docol6:	lda	colors,x
		sta	ts_col6
		dex
		bpl	ts_docol7
		ldx	#numcolors-1
ts_docol7:	lda	colors,x
		sta	ts_col7

ts_doscroll:	dec	$01
		ldx	charbit
		bne	ts_scrollbit
		ldx	scrtextpos
		cpx	#scrolltextlen
		bne	ts_fetchchar
		ldx	#$0
		stx	scrtextpos
ts_fetchchar:	lda	scrolltext,x
		asl	a
		rol	charbit
		asl	a
		rol	charbit
		asl	a
		rol	charbit
		sta	ts_fetchfrom
		lda	#>vic_charset
		adc	charbit
		sta	ts_fetchfrom+1
		ldx	#$7
ts_fetchfrom	= *+1
ts_fetchloop:	lda	$ffff,x
		sta	nextchar_0,x
		dex
		bpl	ts_fetchloop
		lda	#$8
		sta	charbit
		inc	scrtextpos
ts_scrollbit:	ldx	#$7
		stx	temp1
		ldx	#$15
		stx	temp2
ts_scrollloop:	ldx	temp1
		asl	nextchar_0,x
		ldx	temp2
		rol	sprite_6+2,x
		rol	sprite_6+1,x
		rol	sprite_6+0,x
		rol	sprite_5+2,x
		rol	sprite_5+1,x
		rol	sprite_5+0,x
		rol	sprite_4+2,x
		rol	sprite_4+1,x
		rol	sprite_4+0,x
		rol	sprite_3+2,x
		rol	sprite_3+1,x
		rol	sprite_3+0,x
		rol	sprite_2+2,x
		rol	sprite_2+1,x
		rol	sprite_2+0,x
		rol	sprite_1+2,x
		rol	sprite_1+1,x
		rol	sprite_1+0,x
		rol	sprite_0+2,x
		rol	sprite_0+1,x
		rol	sprite_0+0,x
		dec	temp2
		dec	temp2
		dec	temp2
		dec	temp1
		bpl	ts_scrollloop
		dec	charbit
		inc	$01
		rts

scrolltext:
		plainchr "8192 Game "
		.byte	$ff
		plainchr " 2018 by Zirias <felix@palmen-it.de> "
		plainchr " -- press FIRE to start!   This only exists "
		plainchr "because I wanted to create my own little simple "
		plainchr "game. A game needs a title screen and a scroller, "
		plainchr "so here it is ;)       "
scrolltextlen	= *-scrolltext

colors:		.byte	$0b,$0c,$0f,$0d,$01,$0f,$0c
numcolors	= *-colors

.code


title_loop:
		jsr	js_flush
tl_waitfire:	jsr	js_get
		bcs	tl_waitfire
		cmp	#JS_FIRE
		bne	tl_waitfire
		rts

