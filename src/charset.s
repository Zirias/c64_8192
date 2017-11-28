.include "vicconfig.inc"
.include "zp.inc"

.export charset_init
.export charset_done

.code

charset_init:
		lda	#$00
		tay
		sta	TMPW0
		lda	#>vic_charset
		sta	TMPW0+1
		lda	#$31
		sta	$1
		ldx	#$08
cpcharset:	lda	(TMPW0),y
		sta	(TMPW0),y
		iny
		bne	cpcharset
		inc	TMPW0+1
		dex
		bne	cpcharset

		; copy corners to codepoints 5b - 5e
		ldx	#corners_len
corners_loop:	lda	corners-1,x
		sta	vic_charset + ($5b << 3) -1, x
		sta	vic_charset + ($5d << 3), y
		iny
		dex
		bne	corners_loop

		ldx	#$08
		lda	#$7f
ledge_loop:	sta	vic_charset + ($e5 << 3) -1,x
		dex
		bne	ledge_loop
		ldx	#$08
		lda	#$fe
redge_loop:	sta	vic_charset + ($e7 << 3) -1,x
		dex
		bne	redge_loop

		lda	#$37
		sta	$1
		rts

charset_done:
		rts

.data

corners:	.byte	$00,$07,$1f,$3f,$3f,$7f,$7f,$7f
		.byte	$00,$e0,$f8,$fc,$fc,$fe,$fe,$fe
corners_len	= *-corners
