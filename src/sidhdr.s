.include "sound.inc"

.zeropage

sidtune:	.res 1

.segment "SIDHDR"

		.byte	"PSID"
		.word	$0200		; version
		.word	$7c00		; offset
		.word	$0010		; load address
		.word	$0010		; init
		.word	$0310		; play
		.word	$0200		; songs
		.word	$0100		; start song
		.word	$0000,$0000	; speed
		.byte	"8192 v0.3a Game music"
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00
		.byte	"Felix Palmen (Zi"
		.byte	"rias)", $00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	"2018 Zirias", $00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	%00000000, %00110100	; flags
		.byte	$00		; reloc start page
		.byte	$00		; reloc pages
		.byte	$00		
		.byte	$00

		jmp	sidinit
		jsr	snd_out
		jmp	snd_step
sidinit:	eor	#$1
		sta	sidtune
		jsr	snd_init
		lda	sidtune
		jmp	snd_settune
