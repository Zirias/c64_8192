.include "vicconfig.inc"
.include "vic.inc"
.include "zp.inc"

.export screen_init

.code

screen_init:
		lda	#>vic_colram
		sta	TMPW0+1		
		lda	#$20
		ldy	#$0
		sty	TMPW0
		sty	BORDER_COLOR
		sty	BG_COLOR_0
		ldx	#$3
clearloop:	sta	(TMPW0),y
		dey
		bne	clearloop
		inc	TMPW0+1
		dex
		bne	clearloop
		ldy	#$e8
clearloop2:	sta	vic_colram + $2ff, y
		dey
		bne	clearloop2
		rts
		
