.include "zp.inc"
.include "irq.inc"
.include "charset.inc"
.include "random.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "board.inc"

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
		lsr	a
		bcs	move_up
		lsr	a
		bcs	move_down
		lsr	a
		bcs	move_left
		lsr	a
		bcs	move_right
		bcc	check_js

move_up:	jsr	board_up
		bne	dosteps

move_down:	jsr	board_down
		bne	dosteps

move_left:	jsr	board_left
		bne	dosteps

move_right:	jsr	board_right

dosteps:	lda	#$0
		sta	validmove
steploop:	jsr	board_step
		bcs	stepdone
		lda	#$1
		sta	validmove
		jsr	screen_draw
		bne	steploop
stepdone:	lda	validmove
		beq	check_js
		jsr	board_addpiece
		bcc	add_done

gameover:	bcs	gameover

add_done:	jsr	screen_draw
		bne	check_js

