.include "jsinput.inc"
.include "vic.inc"
.include "vicconfig.inc"
.include "cia.inc"

.import title_colram
.export title_show

.zeropage
accu_save:	.res	1
x_save:		.res	1
y_save:		.res	1

.code

title_show:
		sei
		lda	#$0
		sta	VIC_IRM
		sta	BORDER_COLOR
		sta	BG_COLOR_0
		tax
		lda	#<title_colram
		sta	ts_tcstart
		lda	#>title_colram
		sta	ts_tcstart+1
		lda	#$d8
		sta	ts_crpage
		ldy	#$4
ts_tcstart	= *+1
ts_colloop:	lda	$ffff,x
ts_crpage	= *+2
		sta	$ff00,x
		inx
		bne	ts_colloop
		inc	ts_tcstart+1
		inc	ts_crpage
		dey
		bne	ts_colloop
		lda	#<titleisr
		sta	$fffe
		lda	#>titleisr
		sta	$ffff
		lda	#$1
		sta	VIC_IRM
		sta	VIC_IRR

		; VIC memory configuration
		lda	CIA2_PRA
		and	#vic_bankselect_and
		sta	CIA2_PRA
		lda	VIC_MEMCTL
		lda	#vic_memctl_hires
		sta	VIC_MEMCTL
		lda	#$3b
		sta	VIC_CTL1
		cli

ts_waitfire:	jsr	js_get
		bcs	ts_waitfire
		cmp	#JS_FIRE
		bne	ts_waitfire
		rts

titleisr:
		sta	accu_save
		stx	x_save
		sty	y_save
		lda	#$ff
		sta	VIC_IRR
		jsr	js_check
		ldy	y_save
		ldx	x_save
		lda	accu_save
		rti
