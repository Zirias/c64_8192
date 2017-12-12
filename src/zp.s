.export zp_init
.export zp_done

.import __ZPS_LOAD__

.zeropage

.segment "ZPS"
		.res	$fe

.segment "CORE"

zp_init:
		ldx	#$ff
zpi_copy:	lda	$1,x
		sta	__ZPS_LOAD__-1,x
		dex
		bne	zpi_copy
		rts

zp_done:
		ldx	#$ff
zpd_copy:	lda	__ZPS_LOAD__-1,x
		sta	$1,x
		dex
		bne	zpd_copy
		rts

