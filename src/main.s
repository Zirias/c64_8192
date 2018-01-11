.include "irq.inc"
.include "random.inc"
.include "dirinput.inc"
.include "screen.inc"
.include "board.inc"
.include "menu.inc"
.include "vicconfig.inc"
.include "charconv.inc"
.include "sound.inc"
.include "jscodes.inc"

.zeropage

validmove:	.res	1

.segment "MAIN"

		sei

		jsr	rnd_init
		jsr	board_init
		jsr	screen_init
		jsr	irq_init
		cli

		jsr	menu_init
		lda	#$0
		jsr	snd_settune

mainrestart:	lda	#DRAWREQ_BOARD | DRAWREQ_SCORE | DRAWREQ_PANEL
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

check_js:	jsr	dir_get
		bcs	check_js
		jsr	board_setdir
		bcc	domove
		jsr	menu_invoke
		bcc	check_js
		jsr	board_init
		bne	mainrestart

domove:		lda	#$0
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

gameover:	sei
		dec	$01
		ldx	#gameoverlen
gotextloop:	lda	gameovertext-1,x
		sta	vic_screenram+$93,x
		dex
		bne	gotextloop
		inc	$01
		cli
end:		bne	end


.data

gameovertext:	plainchr "Game over!"
gameoverlen	= *-gameovertext

