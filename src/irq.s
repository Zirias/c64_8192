.include "vic.inc"
.include "vicconfig.inc"
.include "cia.inc"

.export irq_init
.export irq_done

.zeropage

memctl_save:	.res	1
accu_save:	.res	1

.code

irq_init:
		sei

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
		lda	#$00
		sta	VIC_RASTER
		lda	VIC_CTL1
		and	#$7f
		sta	VIC_CTL1
		lda	#$01
		sta	VIC_IRM
		sta	VIC_IRR

		cli
		rts

irq_done:
		sei
		cli
		rts

isr:
		sta	accu_save
		lda	#$ff
		sta	VIC_IRR
		lda	accu_save
isrend:		rti

