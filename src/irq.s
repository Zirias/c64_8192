.include "vic.inc"
.include "vicconfig.inc"
.include "cia.inc"
.include "jsinput.inc"
.include "screen.inc"

.export irq_init
.export irq_done

.zeropage

memctl_save:	.res	1
accu_save:	.res	1
x_save:		.res	1
y_save:		.res	1

.code

irq_init:
		; disable NMI
		lda	#<isrend
		sta	$0318
		lda	#>isrend
		sta	$0319
		lda	#$00
		sta	CIA2_CRA
		sta	CIA2_TA_LO
		sta	CIA2_TA_HI
		lda	#$81
		sta	CIA2_ICR
		lda	#$01
		sta	CIA2_CRA

		; VIC memory configuration
		lda	CIA2_PRA
		and	#vic_bankselect_and
		sta	CIA2_PRA
		lda	VIC_MEMCTL
		sta	memctl_save
		lda	#vic_memctl_text
		sta	VIC_MEMCTL

		; disable CIA1 IRQ
		lda	#$7f
		sta	CIA1_ICR
		lda	CIA1_ICR

		; install ISR for VIC IRQ
		lda	#<isr
		sta	$fffe
		lda	#>isr
		sta	$ffff

		; bank out ROMs
		lda	#$35
		sta	$1

		; configure VIC IRQ
		lda	#$20
		sta	VIC_RASTER
		lda	VIC_CTL1
		ora	#$80
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
		jsr	screen_refresh
		jsr	js_check
		ldy	y_save
		ldx	x_save
		lda	accu_save
isrend:		rti

