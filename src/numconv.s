.export numtostring
.exportzp nc_string
.exportzp nc_num

NUMSTRSIZE	= $a
NUMSIZE		= $4

.zeropage

nc_string:	.res	NUMSTRSIZE
nc_num:		.res	NUMSIZE

.code

numtostring:
		ldy	#NUMSTRSIZE
		lda	#$0
nts_fillzero:	sta	nc_string-1,y
		dey
		bne	nts_fillzero
		ldy	#(NUMSIZE*8)
nts_bcdloop:	ldx	#(NUMSTRSIZE-2)
nts_addloop:	lda	nc_string+1,x
		cmp	#$5
		bmi	nts_noadd
		adc	#$2
		sta	nc_string+1,x
nts_noadd:	dex
		bpl	nts_addloop
		asl	nc_num
		ldx	#($ff-NUMSIZE+2)
nts_rol:	rol	nc_num+NUMSIZE,x
		inx
		bne	nts_rol
		ldx	#(NUMSTRSIZE-2)
nts_rolloop:	lda	nc_string+1,x
		rol	a
		cmp	#$10
		and	#$f
		sta	nc_string+1,x
nts_rolnext:	dex
		bpl	nts_rolloop
		dey
		bne	nts_bcdloop
nts_scan:	cpx	#(NUMSTRSIZE-1)
		beq	nts_digits
		inx
		lda	nc_string,x
		bne	nts_digits
		lda	#$20
		sta	nc_string,x
		bne	nts_scan
nts_digits:	lda	nc_string,x
		ora	#$30
		sta	nc_string,x
		inx
		cpx	#(NUMSTRSIZE)
		bne	nts_digits
		rts

