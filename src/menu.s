.include "screen.inc"
.include "charconv.inc"
.include "dirinput.inc"
.include "state.inc"
.include "sprites.inc"
.include "vic.inc"
.include "jscodes.inc"

.export menu_init
.export menu_invoke
.export menu_gameover
.export menu_irq

.zeropage

activerow:	.res	1
colpos:		.res	1

.code

menu_init:
		lda	#$80
		sta	activerow
		lda	#nummenucols-1
		sta	colpos
		lda	#$ff
		ldx	#$17
		dec	$01
bgspriteloop:	sta	sprite_0,x
		sta	sprite_1,x
		sta	sprite_2,x
		dex
		bpl	bgspriteloop
		inc	$01
		lda	#$0
		sta	SPRITE_DBL_Y
		lda	#$fe
		sta	SPRITE_DBL_X
		lda	#$e8
		sta	SPRITE_0_X
		lda	#$f0
		sta	SPRITE_1_X
		lda	#$20
		sta	SPRITE_2_X
		lda	#$04
		sta	SPRITE_X_HB
		lda	#$07
		sta	SPRITE_LAYER
showidlestate:	jsr	screen_clearpanel
		lda	#<menu_t1
		ldy	#>menu_t1
		ldx	#3
		jsr	screen_setpaneltext
		lda	#<menu_t2
		ldy	#>menu_t2
		ldx	#5
		jsr	screen_setpaneltext
		lda	#<menu_t3
		ldy	#>menu_t3
		ldx	#6
		jsr	screen_setpaneltext
		lda	#<menu_t4
		ldy	#>menu_t4
		ldx	#13
		jsr	screen_setpaneltext
		lda	#<menu_t5
		ldy	#>menu_t5
		ldx	#14
		jsr	screen_setpaneltext
		lda	#<menu_t6
		ldy	#>menu_t6
		ldx	#15
		jmp	screen_setpaneltext

menu_invoke:
		lda	#2
		sta	activerow

		jsr	screen_clearpanel
		lda	#<menu_m1
		ldy	#>menu_m1
		ldx	#2
		jsr	screen_setpaneltext
		lda	#<menu_m2
		ldy	#>menu_m2
		ldx	#4
		jsr	screen_setpaneltext
		lda	#<menu_m3a
		ldy	#>menu_m3a
		ldx	#6
		jsr	screen_setpaneltext
		lda	#<menu_m4a
		ldy	#>menu_m4a
		ldx	#8
		jsr	screen_setpaneltext
		lda	#<menu_m5
		ldy	#>menu_m5
		ldx	#10
		jsr	screen_setpaneltext
		lda	#<menu_m6
		ldy	#>menu_m6
		ldx	#12
		jsr	screen_setpaneltext
		lda	#<menu_m7
		ldy	#>menu_m7
		ldx	#14
		jsr	screen_setpaneltext
		lda	#DRAWREQ_PANEL
		jsr	screen_draw

		lda	#$07
		sta	SPRITE_SHOW
		
waitinput:	jsr	dir_get
		bcs	waitinput

		cmp	#JS_FIRE
		bne	checkup

		lda	activerow
		cmp	#$4
		bne	m_norestart
		jsr	hidemenu
		sec
		rts
m_norestart:	jsr	hidemenu
		clc
		rts

checkup:	cmp	#JS_UP
		bne	checkdown
		lda	activerow
		sbc	#$2
		beq	waitinput
		sta	activerow
		bne	waitinput

checkdown:	cmp	#JS_DOWN
		bne	waitinput
		lda	activerow
		adc	#$1
		cmp	#15
		bcs	waitinput
		sta	activerow
		bne	waitinput

hidemenu:	lda	#$80
		sta	activerow
		lda	#$00
		sta	SPRITE_SHOW
		jsr	showidlestate
		lda	#DRAWREQ_PANEL
		jmp	screen_draw

menu_gameover:
		lda	#<menu_govr
		ldy	#>menu_govr
		ldx	#10
		stx	activerow
		jsr	screen_setpaneltext
		lda	#$07
		sta	SPRITE_SHOW
		lda	#DRAWREQ_PANEL
		jmp	screen_draw

menu_irq:
		lda	activerow
		bmi	mi_done
		asl	a
		asl	a
		asl	a
		adc	#$3a
		sta	SPRITE_0_Y
		sta	SPRITE_1_Y
		sta	SPRITE_2_Y
		dec	colpos
		bpl	colposok
		lda	#nummenucols-1
		sta	colpos
colposok:	ldx	colpos
		lda	menucols,x
		sta	SPRITE_0_COL
		sta	SPRITE_1_COL
		sta	SPRITE_2_COL
mi_done:	rts

gamestate:	; TODO
		;lda	#<defpin
		;ldy	#>defpin
		jsr	state_setpin
		ldx	#$0
		;lda	score
		;bne	savegame
		;lda	score+1
		;bne	savegame
		;lda	score+2
		;bne	savegame
		;lda	score+3
		;bne	savegame
		;jsr	state_load
		;ldx	#$f
check_empty:	;lda	board,x
		beq	ce_next
		lda	#DRAWREQ_BOARD | DRAWREQ_SCORE
		jsr	screen_draw
		;beq	check_js
ce_next:	dex
		bpl	check_empty
		;bne	mainrestart

savegame:	jsr	state_save
		;beq	check_js


.data

menu_t1:	revchr	" 8192  v0.3a "
menu_t2:	.byte	$a0,$a0,$a0,$ff
		revchr	    " 2018    "
menu_t3:	revchr	"  by Zirias  "
menu_t4:	revchr	" press  FIRE "
menu_t5:	revchr	" to activate "
menu_t6:	revchr	"  the  menu  "

menu_m1:	revchr	" Continue    "
menu_m2:	revchr  " Restart     "
menu_m3a:	revchr	" Music off   "
menu_m3b:	revchr	" Music on    "
menu_m4a:	revchr  " SFX off     "
menu_m4b:	revchr	" SFX on      "
menu_m5:	revchr  " Load / Save "
menu_m6:	revchr  " Highscores  "
menu_m7:	revchr	" Quit game   "

menu_govr:	revchr	"  GAME OVER  "

menucols:	.byte	$0c,$0b,$0c,$0f,$0f,$01,$01,$01,$01,$01,$01,$0f,$0f
nummenucols	= *-menucols
