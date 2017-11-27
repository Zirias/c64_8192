.export zp_init
.export zp_done

.exportzp TMPW0
.exportzp TMPW1
.exportzp TMPW2
.exportzp TMPW3
.exportzp TMPW4
.exportzp TMPW5
.exportzp TMPW6
.exportzp TMPW7

.exportzp TMPB0
.exportzp TMPB1
.exportzp TMPB2
.exportzp TMPB3
.exportzp TMPB4
.exportzp TMPB5
.exportzp TMPB6
.exportzp TMPB7

.import __ZPS_LOAD__

.zeropage

TMPW0:		.res	2
TMPW1:		.res	2
TMPW2:		.res	2
TMPW3:		.res	2
TMPW4:		.res	2
TMPW5:		.res	2
TMPW6:		.res	2
TMPW7:		.res	2

TMPB0:		.res	1
TMPB1:		.res	1
TMPB2:		.res	1
TMPB3:		.res	1
TMPB4:		.res	1
TMPB5:		.res	1
TMPB6:		.res	1
TMPB7:		.res	1

.segment "ZPS"
		.res	$fe

.code

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

