.include "irq.inc"
.include "random.inc"
.include "dirinput.inc"
.include "screen.inc"
.include "board.inc"
.include "state.inc"
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

		lda	#DRAWREQ_BOARD | DRAWREQ_SCORE
		jsr	screen_draw
		jsr	irq_init
		cli

		lda	#$0
		jsr	snd_settune

mainrestart:	jsr	board_addpiece
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

		lda	#<defpin
		ldy	#>defpin
		jsr	state_setpin
		ldx	#$0
		lda	score
		bne	savegame
		lda	score+1
		bne	savegame
		lda	score+2
		bne	savegame
		lda	score+3
		bne	savegame
		jsr	state_load
		ldx	#$f
check_empty:	lda	board,x
		beq	ce_next
		lda	#DRAWREQ_BOARD | DRAWREQ_SCORE
		jsr	screen_draw
		beq	check_js
ce_next:	dex
		bpl	check_empty
		bne	mainrestart

savegame:	jsr	state_save
		beq	check_js

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

defpin:		plainchr "0000"

