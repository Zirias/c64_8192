.include "jsinput.inc"
.include "keyboard.inc"
.include "vic.inc"
.include "vicconfig.inc"
.include "charconv.inc"
.include "sprites.inc"

.export title_init
.export title_scroll
.export title_loop

.zeropage

nextchar_0:	.res	8
nextchar_1:	.res	8
charbit:	.res	1
temp1:		.res	1
temp2:		.res	1
startcol:	.res	1
colcounter:	.res	1

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
		sta	startcol
		sta	colcounter
		lda	#<scrolltext
		sta	scrolltextptr
		lda	#>scrolltext
		sta	scrolltextptr+1
		rts

ts_setcols:
tssc_w:		dex
		bne	tssc_w
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
		sta	SPRITE_3_COL
		sta	SPRITE_4_COL
		sta	SPRITE_5_COL
		sta	SPRITE_6_COL
		rts

title_scroll:
ts_col0		= *+1
		lda	#$0b
		ldx	#$09
		jsr	ts_setcols
ts_col1		= *+1
		lda	#$0c
		ldx	#$09
		jsr	ts_setcols
ts_col2		= *+1
		lda	#$0f
		ldx	#$09
		jsr	ts_setcols
ts_col3		= *+1
		lda	#$0d
		ldx	#$04
		nop
		nop
		nop
		jsr	ts_setcols
ts_col4		= *+1
		lda	#$01
		ldx	#$09
		jsr	ts_setcols
ts_col5		= *+1
		lda	#$0f
		ldx	#$09
		jsr	ts_setcols
ts_col6		= *+1
		lda	#$0c
		ldx	#$09
		jsr	ts_setcols
ts_col7		= *+1
		lda	#$0b
		ldx	#$03
		nop
		nop
		jsr	ts_setcols

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
scrolltextptr	= *+1
		lda	$ffff
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
		inc	scrolltextptr
		bne	ts_checkptr
		inc	scrolltextptr+1
ts_checkptr:	lda	scrolltextptr
		cmp	#<scrolltextend
		bne	ts_scrollbit
		lda	scrolltextptr+1
		cmp	#>scrolltextend
		bne	ts_scrollbit
		lda	#<scrolltext
		sta	scrolltextptr
		lda	#>scrolltext
		sta	scrolltextptr+1
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
		.byte	$7f
		plainchr " 2018 by Zirias <felix@palmen-it.de> "
		plainchr " -- press FIRE to start --       "
		plainchr "Control with joystick in port #2 or <i>, <j>, <k>, "
		plainchr "<l> and <space>.       This only exists "
		plainchr "because I wanted to create my own little game. "
		plainchr "A game needs a title screen and a scrolltext, "
		plainchr "so here it is ;)       "
		plainchr "Tools used: vim, GNU make, ca65/ld65, multipaint, "
		plainchr "exomizer and mkd64.       "
		plainchr "Greetings to all C64 enthusiasts, have fun!       "
scrolltextend:

colors:		.byte	$0b,$0c,$0f,$0d,$01,$0f,$0c
numcolors	= *-colors

.code


title_loop:
		jsr	js_flush
tl_waitfire:	jsr	js_get
		bcs	tl_checkkb
		cmp	#JS_FIRE
		beq	tl_exit
tl_checkkb:	jsr	kb_get
		bcs	tl_waitfire
		cmp	#$3b		; scancode for space
		bne	tl_waitfire
tl_exit:	rts

