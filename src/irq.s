.include "vic.inc"
.include "vicconfig.inc"
.include "cia.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "sound.inc"

.export irq_early_init
.export irq_init
.export irq_done

FRAMESKIP	= 1

.zeropage

memctl_save:	.res	1
accu_save:	.res	1
x_save:		.res	1
y_save:		.res	1
framephase:	.res	1
bgcol:		.res	1
bordercol:	.res	1
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
		lda	#$00
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
		lda	BG_COLOR_0
		sta	bgcol
		lda	#$5
		sta	curtainpos
		lda	#$1
		sta	curtaintoggle

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
		sta	VIC_RASTER
		lda	VIC_CTL1
		and	#$7f
		bpl	sr_store
sr_curt_on:	lda	curtainpos
		asl	a
		sta	VIC_RASTER
		lda	VIC_CTL1
		bcs	sr_highbit
		and	#$7f
		bpl	sr_store
sr_highbit:	ora	#$80
sr_store:	sta	VIC_CTL1
		rts

earlyisr:
		sta	accu_save
		lda	#$ff
		sta	VIC_IRR
		lda	curtaintoggle
		beq	ei_curt_off
		lda	#$0
		sta	BORDER_COLOR
		sta	BG_COLOR_0
		lda	curtainpos
		cmp	#$9a
		bcc	ei_bottom
		lda	#$0
		sta	VIC_IRM
		beq	ei_out
ei_curt_off:	stx	x_save
		ldx	#$5
ei_wait:	dex
		bne	ei_wait
		nop
		ldx	x_save
		lda	bordercol
		sta	BORDER_COLOR
		lda	bgcol
		sta	BG_COLOR_0
		inc	curtainpos
ei_bottom:	jsr	setraster
ei_out:		lda	accu_save
ei_end:		rti

.code

irq_init:
		;lda	#FRAMESKIP
		sta	framephase

		; VIC memory configuration
		lda	CIA2_PRA
		and	#vic_bankselect_and
		sta	CIA2_PRA
		lda	VIC_MEMCTL
		sta	memctl_save
		lda	#vic_memctl_text
		sta	VIC_MEMCTL

		; install ISR for VIC IRQ
		lda	#<isr
		sta	$fffe
		lda	#>isr
		sta	$ffff

		; configure VIC IRQ
		lda	#$f2
		sta	VIC_RASTER
		lda	VIC_CTL1
		and	#$7f
		sta	VIC_CTL1
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

