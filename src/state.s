.include "board.inc"
.include "diskio.inc"

.export state_setpin
.export state_auth
.export state_save
.export state_load

PINKEY_L	= $69
PINKEY_H	= $cb

.zeropage

save_x:		.res	1

.segment "PDATA"

pinl:		.byte	PINKEY_L, PINKEY_L, PINKEY_L, PINKEY_L, PINKEY_L
		.byte	PINKEY_L, PINKEY_L, PINKEY_L, PINKEY_L, PINKEY_L
pinh:		.byte	PINKEY_H, PINKEY_H, PINKEY_H, PINKEY_H, PINKEY_H
		.byte	PINKEY_H, PINKEY_H, PINKEY_H, PINKEY_H, PINKEY_H
		
score0:		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
score1:		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
score2:		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
score3:		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

board0:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board1:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board2:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board3:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board4:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board5:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board6:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board7:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board8:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
board9:		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00

.bss

tmppin:		.res	2
tmpscore:	.res	4
tmpboard:	.res	$10

.data

boardsl:	.byte	<board0, <board1, <board2, <board3, <board4
		.byte	<board5, <board6, <board7, <board8, <board9
boardsh:	.byte	>board0, >board1, >board2, >board3, >board4
		.byte	>board5, >board6, >board7, >board8, >board9

.code

state_setpin:
		sta	ssp_pin
		sty	ssp_pin+1
		ldx	#$3
ssp_pin		= *+1
ssp_readchar:	lda	$ffff,x
		eor	#$30
		ldy	#$4
ssp_shiftout:	asl	a
		bcs	ssp_out
		dey
		bne	ssp_shiftout
		ldy	#$4
ssp_shiftbits:	asl	a
		rol	tmppin
		rol	tmppin+1
		dey
		bne	ssp_shiftbits
		dex
		bpl	ssp_readchar
		clc
ssp_out:	rts

state_auth:
		stx	save_x
		jsr	state_setpin
		bcs	sa_out
		ldx	save_x
		lda	pinl,x
		eor	#PINKEY_L
		cmp	tmppin
		beq	sa_checkhi
		sec
		bcs	sa_out
sa_checkhi:	lda	pinh,x
		eor	#PINKEY_H
		cmp	tmppin+1
		clc
		beq	sa_out
		sec
sa_out:		rts

state_save:
		lda	tmppin
		eor	#PINKEY_L
		sta	pinl,x
		lda	tmppin+1
		eor	#PINKEY_H
		sta	pinh,x
		lda	score
		sta	score0,x
		lda	score+1
		sta	score1,x
		lda	score+2
		sta	score2,x
		lda	score+3
		lda	score3,x
		lda	boardsl,x
		sta	ss_tgtboard
		lda	boardsh,x
		sta	ss_tgtboard+1
		ldx	#$f
ss_boardloop:	lda	board,x
ss_tgtboard	= *+1
		sta	$ffff,x
		dex
		bpl	ss_boardloop
		jmp	dio_savegamedat

state_load:
		lda	score0,x
		sta	score
		lda	score1,x
		sta	score+1
		lda	score2,x
		sta	score+2
		lda	score3,x
		sta	score+3
		lda	boardsl,x
		sta	sl_srcboard
		lda	boardsh,x
		sta	sl_srcboard+1
		ldx	#$f
sl_srcboard	= *+1
sl_boardloop:	lda	$ffff,x
		sta	board,x
		dex
		bpl	ss_boardloop
		rts

