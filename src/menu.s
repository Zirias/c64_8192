.include "screen.inc"
.include "charconv.inc"

.export menu_init

.code

menu_init:
		jsr	screen_clearpanel
		lda	#<menu_t1
		ldy	#>menu_t1
		ldx	#2
		jsr	screen_setpaneltext
		lda	#<menu_t2
		ldy	#>menu_t2
		ldx	#4
		jsr	screen_setpaneltext
		lda	#<menu_t3
		ldy	#>menu_t3
		ldx	#11
		jsr	screen_setpaneltext
		lda	#<menu_t4
		ldy	#>menu_t4
		ldx	#13
		jsr	screen_setpaneltext
		lda	#<menu_t5
		ldy	#>menu_t5
		ldx	#15
		jmp	screen_setpaneltext

.data

menu_t1:	revchr	" 8192 "
		.byte	$ff
		revchr	" 2018 "
menu_t2:	revchr	"  by Zirias  "
menu_t3:	revchr	" press  FIRE "
menu_t4:	revchr	" to activate "
menu_t5:	revchr	"  the  menu  "

