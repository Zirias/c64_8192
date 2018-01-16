.include "sound.inc"

.zeropage

sidtune:	.res 1

.segment "SIDHDR"

		.byte	"PSID"
		.byte	$00,$02		; version
		.byte	$00,$7c		; offset
		.byte	$00,$00		; load address
		.byte	$10,$00		; init
		.byte	$10,$03		; play
		.byte	$00,$02		; songs
		.byte	$00,$01		; start song
		.byte	$00,$00,$00,$00	; speed

		; title
		.byte	"8192 v0.3a Game music"
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00

		; composer
		.byte	"Felix Palmen (Zi"
		.byte	"rias)", $00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00

		; released
		.byte	"2018 Zirias", $00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00

		.byte	$00, %00110100	; flags
		.byte	$00		; reloc start page
		.byte	$00		; reloc pages
		.byte	$00		
		.byte	$00

		.word	$1000
		jmp	sidinit
		jsr	snd_out
		jmp	snd_step
sidinit:	eor	#$1
		sta	sidtune
		jsr	snd_init
		lda	sidtune
		jmp	snd_settune

