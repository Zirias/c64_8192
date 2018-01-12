.include "vicconfig.inc"

.export charset_init

.zeropage

tempptr:	.res	2

.segment "TCODE"

charset_init:
		lda	#$00
		tay
		sta	tempptr
		lda	#>vic_charset
		sta	tempptr+1
		lda	#$31
		sta	$1
		ldx	#$08
cpcharset:	lda	(tempptr),y
		sta	(tempptr),y
		iny
		bne	cpcharset
		inc	tempptr+1
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
copyright_loop:	lda	copyright-1,x
		sta	vic_charset + ($7f << 3) -1,x
		dex
		bne	copyright_loop

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

		ldx	#combnums_len
combnums_loop:	lda	combnums-1,x
		sta	vic_charset + ($f1 << 3) -1,x
		dex
		bne	combnums_loop

		lda	#$35
		sta	$1
		rts

corners:	.byte	$00,$07,$1f,$3f,$3f,$7f,$7f,$7f
		.byte	$00,$e0,$f8,$fc,$fc,$fe,$fe,$fe
corners_len	= *-corners

copyright:	.byte	$3c,$66,$5a,$52,$5a,$66,$3c,$00

combnums:	.byte	$fc,$f9,$ff,$ff,$fc,$f9,$f8,$ff
		.byte	$3f,$9f,$9f,$3f,$ff,$ff,$1f,$ff
		.byte	$ff,$ff,$fe,$f9,$f8,$ff,$ff,$ff
		.byte	$9f,$1f,$1f,$9f,$0f,$9f,$9f,$ff
		.byte	$fc,$f9,$f9,$fc,$f9,$f9,$fc,$ff
		.byte	$3f,$9f,$9f,$3f,$9f,$9f,$3f,$ff
		.byte	$fe,$fe,$fc,$fe,$fe,$fe,$f8,$ff
		.byte	$7c,$79,$7f,$7f,$7c,$79,$18,$ff
		.byte	$3c,$99,$99,$3c,$f9,$f9,$1c,$ff
		.byte	$38,$99,$98,$3f,$ff,$f9,$1c,$ff
		.byte	$1c,$f9,$39,$98,$99,$99,$3c,$ff
		.byte	$3f,$9f,$ff,$3f,$9f,$9f,$3f,$ff
		.byte	$f8,$f9,$f8,$ff,$ff,$f9,$fc,$ff
		.byte	$1e,$fe,$3c,$9e,$9e,$9e,$38,$ff
		.byte	$c3,$99,$a5,$ad,$a5,$99,$c3,$ff
combnums_len	= *-combnums
