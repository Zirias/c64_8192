.include "vic.inc"
.include "vicconfig.inc"
.include "cia.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "sound.inc"
.include "charset.inc"
.include "title.inc"

.export irq_early_init
.export irq_init
.export irq_done

FRAMESKIP	= 1

OP_BEQ		= $F0
OP_BNE		= $D0

.zeropage

memctl_save:	.res	1
accu_save:	.res	1
x_save:		.res	1
y_save:		.res	1
bank_save:	.res	1
framephase:	.res	1
curtainpos	= framephase
curtaintoggle	= y_save

.segment "CORE"

irq_early_init:
		; disable CIA1 IRQ
		lda	#$7f
		sta	CIA1_ICR
		lda	CIA1_ICR

		; bank out ROMs
		lda	#$35
		sta	$1

		; disable NMI
		lda	#<ei_end
		sta	$fffa
		lda	#>ei_end
		sta	$fffb
		lda	#$0
		sta	SPRITE_SHOW   ; disable all sprites here
		sta	CIA2_CRA
		sta	CIA2_TA_LO
		sta	CIA2_TA_HI
		lda	#$81
		sta	CIA2_ICR
		lda	#$01
		sta	CIA2_CRA

		lda	#<earlyisr
		sta	$fffe
		lda	#>earlyisr
		sta	$ffff

		lda	BORDER_COLOR
		sta	bordercol
		lda	VIC_CTL1
		sta	vctl1
		lda	VIC_CTL2
		sta	vctl2
		lda	#$5
		sta	curtainpos
		lda	#$1
		sta	curtaintoggle

		lda	#OP_BEQ
		sta	ei_on_off
		lda	#<title_show
		sta	ei_donejmp
		lda	#>title_show
		sta	ei_donejmp+1

		; configure VIC IRQ
		jsr	setraster
		lda	#$01
		sta	VIC_IRM
		sta	VIC_IRR
		rts

setraster:
		lda	#$1
		eor	curtaintoggle
		sta	curtaintoggle
		beq	sr_curt_on
		lda	VIC_CTL1
		and	#$7f
		sta	VIC_CTL1
		lda	#$0
		sta	VIC_RASTER
		beq	sr_done
sr_curt_on:	lda	VIC_CTL1
		ora	#$80
		sta	VIC_CTL1
		lda	curtainpos
		asl	a
		sta	VIC_RASTER
		bcs	sr_done
		lda	VIC_CTL1
		and	#$7f
		sta	VIC_CTL1
sr_done:	rts

eisr_wait:
		nop
		nop
		rts

earlyisr:
		sta	accu_save
		lda	$01
		sta	bank_save
		lda	#$35
		sta	$01
		lda	#$ff
		sta	VIC_IRR
		jsr	eisr_wait
		lda	curtaintoggle
ei_on_off:	beq	ei_curt_off
ei_curt_on:	lda	#$d8
		sta	VIC_CTL2
		lda	#$5b
		sta	VIC_CTL1
		lda	#$0
		sta	BORDER_COLOR
		lda	curtainpos
		cmp	#$9a
		bcc	ei_bottom
ei_donejmp	= *+1
		jmp	$ffff
ei_curt_off:
vctl2		= *+1
		lda	#$ff
		sta	VIC_CTL2
bordercol	= *+1
		lda	#$ff
		sta	BORDER_COLOR
vctl1		= *+1
		lda	#$ff
		sta	VIC_CTL1
		inc	curtainpos
ei_bottom:	jsr	setraster
ei_out:		lda	bank_save
		sta	$01
		lda	accu_save
ei_end:		rti

.segment "TCODE"

title_show:
		; VIC memory configuration
		lda	CIA2_PRA
		and	#vic_bankselect_and
		sta	CIA2_PRA
		lda	VIC_MEMCTL
		lda	#vic_memctl_hires
		sta	VIC_MEMCTL

		lda	#OP_BNE
		sta	ei_on_off
		lda	#<title_shown
		sta	ei_donejmp
		lda	#>title_shown
		sta	ei_donejmp+1
		lda	#$3
		sta	curtainpos
		lda	#$3b
		sta	vctl1
		lda	#$18
		sta	vctl2

		lda	#$0
		sta	BG_COLOR_0
		sta	bordercol
		jmp	ei_bottom

title_shown:
		lda	#<titleisr
		sta	$fffe
		lda	#>titleisr
		sta	$ffff
		sty	y_save
		stx	x_save
		lda	#$18
		sta	VIC_CTL2
		lda	#$3b
		sta	VIC_CTL1
		lda	#$b4
		sta	VIC_RASTER
		jsr	charset_init
		jsr	title_init
		ldx	x_save
		ldy	y_save
		jmp	ei_out

titleisr:
		sta	accu_save
		lda	VIC_RASTER
ti_waitline:	cmp	VIC_RASTER
		beq	ti_waitline
		stx	x_save
		sty	y_save
		lda	#$ff
		sta	VIC_IRR
		jsr	title_scroll
		jsr	js_check
		ldy	y_save
		ldx	x_save
		lda	accu_save
		rti
.code

irq_init:
		;lda	#FRAMESKIP
		sta	framephase

		lda	#vic_memctl_text
		sta	VIC_MEMCTL

		lda	#$0
		sta	SPRITE_SHOW

		; install ISR for VIC IRQ
		lda	#<isr
		sta	$fffe
		lda	#>isr
		sta	$ffff

		; configure VIC IRQ
		lda	#$f2
		sta	VIC_RASTER
		lda	#$1b
		sta	VIC_CTL1
		lda	#$08
		sta	VIC_CTL2
		lda	#$01
		sta	VIC_IRM
		sta	VIC_IRR

		rts

irq_done:
		rts

isr:
		sta	accu_save
		stx	x_save
		sty	y_save
		lda	#$ff
		sta	VIC_IRR

		lda	VIC_RASTER
		bpl	isr_upper

		lda	#$56
		sta	VIC_RASTER
		dec	framephase
		bpl	isr_nodraw
		lda	#FRAMESKIP
		sta	framephase
		jsr	screen_refresh
isr_nodraw:	jsr	js_check
		jmp	isr_bottom

isr_upper:	lda	#$f2
		sta	VIC_RASTER
.ifdef DEBUG
		inc	$d020
.endif
		jsr	snd_out
		jsr	snd_step
.ifdef DEBUG
		dec	$d020
.endif
		jsr	js_check

isr_bottom:	ldy	y_save
		ldx	x_save
		lda	accu_save
isrend:		rti

