.include "zp.inc"
.include "irq.inc"
.include "charset.inc"
.include "random.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "board.inc"
.include "numconv.inc"
.include "vicconfig.inc"
.include "charconv.inc"

.zeropage

validmove:	.res	1

.segment "MAIN"

		sei
		jsr	zp_init
		jsr	rnd_init
		jsr	charset_init
		jsr	board_init
		jsr	screen_init
		jsr	js_init
		jsr	irq_init
		cli

		jsr	screen_draw

check_js:	jsr	js_get
		bcs	check_js
		jsr	board_setdir
		bcs	check_js
		lda	#$0
		sta	validmove
steploop:	jsr	board_step
		bcs	stepdone
		lda	#$1
		sta	validmove
		ldx	#$3
copyscore:	lda	score,x
		sta	nc_num,x
		dex
		bpl	copyscore
		jsr	numtostring
		ldx	#NUMSTRSIZE
copyscorestr:	lda	nc_string-1,x
		sta	vic_colram+$43,x
		dex
		bne	copyscorestr
		jsr	screen_draw
		bne	steploop
stepdone:	lda	validmove
		beq	check_js
		jsr	board_addpiece
		jsr	screen_draw
		jsr	board_canmove
		bcs	check_js

		ldx	#gameoverlen
gotextloop:	lda	gameovertext-1,x
		sta	vic_colram+$93,x
		dex
		bne	gotextloop
end:		beq	end


.data

gameovertext:	plainchr "Game over!"
gameoverlen	= *-gameovertext
