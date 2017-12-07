.include "zp.inc"
.include "irq.inc"
.include "charset.inc"
.include "random.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "board.inc"
.include "vicconfig.inc"
.include "charconv.inc"
.include "sound.inc"

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
		jsr	snd_init
		cli

		lda	#$0
		jsr	snd_settune

		lda	#DRAWREQ_BOARD | DRAWREQ_SCORE
		jsr	screen_draw

		jsr	board_addpiece
		lda	#DRAWREQ_APPEAR
		jsr	screen_draw
		lda	#DRAWREQ_BOARD
		jsr	screen_draw

mainloop:	jsr	board_addpiece
		lda	#DRAWREQ_APPEAR
		jsr	screen_draw
		lda	#DRAWREQ_BOARD
		jsr	screen_draw
		jsr	board_canmove
		bcc	gameover

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
		lda	#DRAWREQ_BOARD | DRAWREQ_SCORE
		jsr	screen_draw
		beq	steploop
stepdone:	lda	validmove
		bne	mainloop
		lda	#$3
		ldy	#$1
		jsr	snd_fx
		bpl	check_js

gameover:	ldx	#gameoverlen
gotextloop:	lda	gameovertext-1,x
		sta	vic_colram+$93,x
		dex
		bne	gotextloop
end:		beq	end


.data

gameovertext:	plainchr "Game over!"
gameoverlen	= *-gameovertext
