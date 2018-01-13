.include "kernal.inc"
.include "cia.inc"
.include "via.inc"
.include "decr.inc"
.include "vicconfig.inc"

.export dio_init
.export dio_setname
.export dio_loadarchive
.export dio_loadbitmap
.export dio_endloadarchive
.export get_crunched_byte
.export dio_loadgamedat
.export dio_savegamedat

.import __DRVCODE_LOAD__
.import __DRVCODE_RUN__
.import __DRVCODE_SIZE__
.import __PDATA_LOAD__
.import __PDATA_SIZE__

drvcode_chunk	= $20

CMD_LOAD	= $00
CMD_SAVE	= $01

.zeropage

temp1:		.res	1
temp2:		.res	1
temp3:		.res	1
temp4:		.res	1
stackptrstore:	.res	1
nameptr:	.res	2
namelength:	.res	1
dataptr:	.res	2
newfile:	.res	1

.bss

loadbuf:	.res	254

.segment "CORE"

dio_init:
		lda	#<__DRVCODE_LOAD__
		sta	di_chunkstart
		lda	#>__DRVCODE_LOAD__
		sta	di_chunkstart+1
		lda	#<__DRVCODE_RUN__
		sta	mwcmd+2
		lda	#>__DRVCODE_RUN__
		sta	mwcmd+1
di_mwloop:	jsr	di_device
		ldx	#mwcmd_size - 1
di_sendmw:	lda	mwcmd,x
		jsr	KRNL_CIOUT
		dex
		bpl	di_sendmw
		ldx	#0
di_chunkstart	= *+1
di_mwbyte:	lda	$ffff,x
		jsr	KRNL_CIOUT
		inx
		cpx	#drvcode_chunk
		bne	di_mwbyte
		jsr	KRNL_UNLSN
		lda	mwcmd+2
		clc
		adc	#drvcode_chunk
		sta	mwcmd+2
		bcc	di_nocarry
		inc	mwcmd+1
di_nocarry:	lda	di_chunkstart
		clc
		adc	#drvcode_chunk
		sta	di_chunkstart
		tax
		bcc	di_nocarry2
		inc	di_chunkstart+1
di_nocarry2:	lda	di_chunkstart+1
		cpx	#<(__DRVCODE_LOAD__+__DRVCODE_SIZE__)
		sbc	#>(__DRVCODE_LOAD__+__DRVCODE_SIZE__)
		bcc	di_mwloop
		jsr	di_device
		ldx	#mecmd_size-1
di_sendme:	lda	mecmd,x
		jsr	KRNL_CIOUT
		dex
		bpl	di_sendme
		jmp	KRNL_UNLSN
di_device:	lda	$ba
		jsr	KRNL_LISTEN
		lda	#$6f
		jmp	KRNL_SECOND

dio_setname:
		sta	nameptr
		sty	nameptr+1
		ldy	#$0
ds_scan:	lda	(nameptr),y
		beq	ds_done
		iny
		bne	ds_scan
ds_done:	sty	namelength
		sty	newfile
		rts

dio_sendbyte:
		sta	temp1
		ldx	#$08
ds_loop:	bit	CIA2_PRA
		bvc	ds_loop
		bpl	ds_loop
		lsr	temp1
		lda	CIA2_PRA
		and	#$ff-$30
		ora	#$10
		bcc	ds_zerobit
		eor	#$30
ds_zerobit:	sta	CIA2_PRA
		lda	#$c0
ds_sendack:	bit	CIA2_PRA
		bne	ds_sendack
		lda	CIA2_PRA
		and	#$ff-$30
		sta	CIA2_PRA
		dex
		bne	ds_loop
		rts

dio_getbyte:
		ldx	temp2
		beq	dg_fillbuf
		lda	loadbuf-1,x
		dex
		stx	temp2
		rts
dg_fillbuf:	jsr	dg_get
		cmp	#$01
		bcc	dg_exit
		beq	dg_exit
		sbc	#$01
		sta	temp2
		ldx	#$00
dg_fillloop:	jsr	dg_get
		sta	loadbuf,x
		inx
		cpx	temp2
		bcc	dg_fillloop
		bcs	dio_getbyte
dg_exit:	ldx	stackptrstore
		txs
		rts
dg_get:		bit	CIA2_PRA
		bvc	dg_get
		lda	#$0f
		and	CIA2_PRA
		sta	CIA2_PRA
		lda	#$08
		sta	temp3
dg_bitloop:	nop
		nop
		lda	#$10
		eor	CIA2_PRA
		sta	CIA2_PRA
		asl
		rol	temp1
		lda	temp1
		dec	temp3
		bne	dg_bitloop
		rts

get_crunched_byte:
		php
		stx	gcb_savex
		jsr	dio_getbyte
gcb_savex	= *+1
		ldx	#$ff
		plp
		rts

dio_loadarchive:
		sta	dataptr
		sty	dataptr+1
		ldx	newfile
		beq	dl_nextchunk
		lda	namelength
		jsr	dio_sendbyte
		ldy	namelength
		dey
dl_sendname:	lda	(nameptr),y
		jsr	dio_sendbyte
		dey
		bpl	dl_sendname
dl_namedone:	lda	#CMD_LOAD
		jsr	dio_sendbyte
dl_delay:	dex
		bne	dl_delay
		stx	newfile
		stx	temp2
dl_nextchunk:	stx	temp4
		jsr	init_decruncher
dl_loop:	jsr	get_decrunched_byte
		bcs	dl_endload
		ldy	temp4
		sta	(dataptr),y
		inc	temp4
		bne	dl_loop
		inc	dataptr+1
		bne	dl_loop
dl_endload:	rts

.segment "COREDATA"

mwcmd:		.byte	drvcode_chunk, $ff, $ff, "w-m"
mwcmd_size	= *-mwcmd

mecmd:		.byte	>__DRVCODE_RUN__, <__DRVCODE_RUN__, "e-m"
mecmd_size	= *-mecmd

.segment "TCODE"

dio_loadbitmap:
		lda	#$0
		sta	temp4
		sta	dataptr
		sta	col1ptr
		sta	col2ptr
		lda	#>vic_bitmap
		sta	dataptr+1
		lda	#>vic_colram
		sta	col1ptr+1
		lda	#$d8
		sta	col2ptr+1
		jsr	init_decruncher
dlb_loop:	jsr	get_decrunched_byte
		bcc	dlb_cont
		rts
dlb_cont:	dec	$01
col1ptr		= *+1
		sta	$ffff
		inc	$01
		inc	col1ptr
		bne	dlb_col2
		inc	col1ptr+1
dlb_col2:	jsr	get_decrunched_byte
col2ptr		= *+1
		sta	$ffff
		inc	col2ptr
		bne	dlb_bitmap
		inc	col2ptr+1
dlb_bitmap:	jsr	get_decrunched_byte
		ldy	temp4
		sta	(dataptr),y
		inc	temp4
		beq	dlb_next
		lda	temp4
		and	#$7
		bne	dlb_bitmap
		beq	dlb_loop
dlb_next:	inc	dataptr+1
		bne	dlb_loop

dio_endloadarchive:
		tsx
		stx	stackptrstore
dle_loop:	jsr	dio_getbyte
		bcc	dle_loop

.code

dio_loadgamedat:
		lda	#<__PDATA_LOAD__
		sta	dataptr
		lda	#>__PDATA_LOAD__
		sta	dataptr+1
		tsx
		stx	stackptrstore
		lda	namelength
		jsr	dio_sendbyte
		ldy	namelength
		dey
dlg_sendname:	lda	(nameptr),y
		jsr	dio_sendbyte
		dey
		bpl	dlg_sendname
		lda	#CMD_LOAD
		jsr	dio_sendbyte
dlg_delay:	dex
		bne	dlg_delay
		stx	temp2
		iny
dlg_loop:	jsr	dio_getbyte
		sta	(dataptr),y
		iny
		bne	dlg_loop
		inc	dataptr+1
		bne	dlg_loop

dio_savegamedat:
		lda	#<__PDATA_LOAD__
		sta	dataptr
		lda	#>__PDATA_LOAD__
		sta	dataptr+1
		lda	namelength
		jsr	dio_sendbyte
		ldy	namelength
		dey
dsg_sendname:	lda	(nameptr),y
		jsr	dio_sendbyte
		dey
		bpl	dsg_sendname
		lda	#CMD_SAVE
		jsr	dio_sendbyte
		iny
dsg_loop:	cpy	#<__PDATA_SIZE__
		bne	dsg_next
		lda	dataptr+1
		cmp	#>__PDATA_LOAD__ + >__PDATA_SIZE__
		bne	dsg_next
		rts
dsg_next:	lda	(dataptr),y
		jsr	dio_sendbyte
		iny
		bne	dsg_loop
		inc	dataptr+1
		bne	dsg_loop

.segment "DRVCODE"

RETRIES		= 5
acsbf		= $01
trkbf		= $08
sctbf		= $09
iddrv0		= $12
id		= $16
datbf		= $14
drvcmd		= $1b
buf		= $0400
cmd		= $35
namelen		= $37
tmp1		= $2c
tmp2		= $46

CMD_READ	= $80
CMD_WRITE	= $90

drv_main:
		cli
		jsr	drv_getbyte
		tax
		stx	namelen
drv_nameloop:	jsr	drv_getbyte
		sta	fname-1,x
		dex
		bne	drv_nameloop
		sei
		jsr	drv_getbyte
		sta	cmd
		lda	#CMD_READ
		sta	drvcmd
		lda	#$08
		sta	VIA1_PRB

		ldx	#18
		ldy	#1
drv_dirloop:	stx	trkbf
		sty	sctbf
		jsr	drv_rwsect
		bcc	drv_error
		ldy	#$02
drv_nextfile:	lda	buf,y
		sty	tmp1
		and	#$83
		cmp	#$83
		bne	drv_notfound
		ldx	#$0
drv_fnamecmp:	lda	buf+3,y
		cmp	fname,x
		bne	drv_notfound
		iny
		inx
		cpx	namelen
		bne	drv_fnamecmp
		beq	drv_found
drv_notfound:	lda	tmp1
		clc
		adc	#$20
		tay
		bcc	drv_nextfile
		ldy	buf+1
		ldx	buf
		bne	drv_dirloop

drv_error:	lda	#$01

drv_end:	ldy	cmd
		bne	drv_endsilent
		jsr	drv_sendbyte
		lda	VIA1_PRB
		and	#$f7
		sta	VIA1_PRB
		lda	#$04
drv_endwait:	bit	VIA1_PRB
		bne	drv_endwait
drv_endsilent:	ldy	#$00
		sty	VIA1_PRB
		jmp	drv_main

drv_found:	ldy	tmp1
		iny
drv_nextsect:	lda	buf,y
		sta	trkbf
		beq	drv_end
		lda	buf+1,y
		sta	sctbf
		jsr	drv_rwsect
		bcc	drv_error
		ldy	#$ff
		lda	cmd
		beq	drv_load

		lda	buf
		bne	drv_recvblk
		ldy	buf+1
drv_recvblk:	iny
		sty	tmp2
		ldy	#$2
drv_recvloop:	jsr	drv_getbyte
		sta	buf,y
		iny
		cpy	tmp2
		bne	drv_recvloop
		lda	#$90
		sta	drvcmd
		jsr	drv_rwsect
		lda	#$80
		sta	drvcmd
		bcc	drv_error
		ldy	tmp2
		beq	drv_nextsect
		lda	#$0
		beq	drv_endsilent

drv_load:	lda	buf
		bne	drv_sendblk
		ldy	buf+1
drv_sendblk:	tya
drv_sendloop:	jsr	drv_sendbyte
		lda	buf,y
		dey
		bne	drv_sendloop
		beq	drv_nextsect

drv_rwsect:	ldy	#RETRIES
drv_retry:	cli
		jsr	drv_success
		lda	drvcmd
		sta	acsbf
drv_poll:	lda	acsbf
		bmi	drv_poll
		sei
		cmp	#$01
		beq	drv_success
		lda	id
		sta	iddrv0
		lda	id+1
		sta	iddrv0+1
		dey
		bne	drv_retry
		clc
drv_success:	lda	VIA2_PRB
		eor	#$08
		sta	VIA2_PRB
		rts

drv_sendbyte:	sta	datbf
		sty	tmp1
		ldy	#$04
		lda	VIA1_PRB
		and	#$f7
		sta	VIA1_PRB
		tya
drv_sbitloop:	asl	datbf
		ldx	#$02
		bcc	drv_waitclk1
		ldx	#$00
drv_waitclk1:	bit	VIA1_PRB
		bne	drv_waitclk1
		stx	VIA1_PRB
		asl	datbf
		ldx	#$02
		bcc	drv_waitclk2
		ldx	#$00
drv_waitclk2:	bit	VIA1_PRB
		beq	drv_waitclk2
		stx	VIA1_PRB
		dey
		bne	drv_sbitloop
		txa
		ora	#$08
		sta	VIA1_PRB
		ldy	tmp1
		rts

drv_getbyte:	sty	tmp1
		ldy	#$08
drv_gbitloop:	lda	#$85
		and	VIA1_PRB
		bmi	drv_exit
		beq	drv_gbitloop
		lsr	a
		lda	#$02
		bcc	drv_gbskip
		lda	#$08
drv_gbskip:	sta	VIA1_PRB
		ror	datbf
drv_gbwait:	lda	VIA1_PRB
		and	#$05
		eor	#$05
		beq	drv_gbwait
		lda	#$0
		sta	VIA1_PRB
		dey
		bne	drv_gbitloop
		lda	datbf
		ldy	tmp1
		rts

drv_exit:	pla
		pla
		rts

fname:		.res	$10

