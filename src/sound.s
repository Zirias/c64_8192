.include "sid.inc"
.include "pitches.inc"
.include "instruments.inc"
.include "tunes.inc"

.export snd_init
.export snd_out
.export snd_settune
.export snd_step

HR_TIMER	= $6

.zeropage

tune:		.res	1
patptr0:	.res	2
patpos0:	.res	1
nexttune:	.res	1
tuneptr:	.res	2
tunepos:	.res	1
patptr1:	.res	2
patpos1:	.res	1
speed:		.res	1
stepcount:	.res	1
hrstep:		.res	1
tmp:		.res	1
patptr2:	.res	2
patpos2:	.res	1
patptr:		.res	2
wtpos0:		.res	1
ptpos0:		.res	1
ftpos0:		.res	1
inst0:		.res	1
pitch0:		.res	1
pstep0:		.res	1
fstep0:		.res	1
wtpos1:		.res	1
ptpos1:		.res	1
ftpos1:		.res	1
inst1:		.res	1
pitch1:		.res	1
pstep1:		.res	1
fstep1:		.res	1
wtpos2:		.res	1
ptpos2:		.res	1
ftpos2:		.res	1
inst2:		.res	1
pitch2:		.res	1
pstep2:		.res	1
fstep2:		.res	1
s_freqlo1:	.res	1
s_freqhi1:	.res	1
s_pwlo1:	.res	1
s_pwhi1:	.res	1
s_cr1:		.res	1
s_ad1:		.res	1
s_sr1:		.res	1
s_freqlo2:	.res	1
s_freqhi2:	.res	1
s_pwlo2:	.res	1
s_pwhi2:	.res	1
s_cr2:		.res	1
s_ad2:		.res	1
s_sr2:		.res	1
s_freqlo3:	.res	1
s_freqhi3:	.res	1
s_pwlo3:	.res	1
s_pwhi3:	.res	1
s_cr3:		.res	1
s_ad3:		.res	1
s_sr3:		.res	1
s_fclo:		.res	1
s_fchi:		.res	1
s_resflt:	.res	1
s_modevol:	.res	1

snd_zpsize	= *-tune

.code

snd_init:
		lda	#$0
		ldx	#snd_zpsize-2
si_zpinit:	sta	tune,x
		dex
		bpl	si_zpinit
		lda	#$f
		sta	s_modevol
		lda	#$ff
		sta	tune
snd_out:	ldx	#s_modevol - s_freqlo1
so_loop:	lda	s_freqlo1,x
		sta	SID_FREQLO1,x
		dex
		bpl	so_loop
		rts

snd_settune:
		sta	nexttune
		rts

snd_tunestep:
		ldy	tunepos
ts_nextcmd:	lda	(tuneptr),y
		bmi	ts_jump
		iny
		lda	(tuneptr),y
		tax
		dex
		bmi	ts_nopat0
		lda	patterns_l,x
		sta	patptr0
		lda	patterns_h,x
		sta	patptr0+1
		ldx	#$0
ts_nopat0:	stx	patpos0
		iny
		lda	(tuneptr),y
		tax
		dex
		bmi	ts_nopat1
		lda	patterns_l,x
		sta	patptr1
		lda	patterns_h,x
		sta	patptr1+1
		ldx	#$0
ts_nopat1:	stx	patpos1
		iny
		lda	(tuneptr),y
		tax
		dex
		bmi	ts_nopat2
		lda	patterns_l,x
		sta	patptr2
		lda	patterns_h,x
		sta	patptr2+1
		ldx	#$0
ts_nopat2:	stx	patpos2
		iny
		sty	tunepos
		rts
ts_jump:	iny
		lda	(tuneptr),y
		tay
		bne	ts_nextcmd
		dey
		sty	patpos0
		sty	patpos1
		sty	patpos2
		rts

snd_gototune:
		sta	tune
		tax
		lda	tunes_l,x
		sta	tuneptr
		lda	tunes_h,x
		sta	tuneptr+1
		ldy	#$0
		lda	(tuneptr),y
		sta	speed
		iny
		bne	ts_nextcmd

ss_setpatptr:
		lda	patptr0,x
		sta	patptr
		lda	patptr0+1,x
		sta	patptr+1
		rts

ss_hr_pre:
		ldy	inst0,x
		beq	ss_hrpredone
		bmi	ss_hrpredone
		lda	inst_ad,y
		sta	s_ad1,x
		lda	inst_sr,y
		sta	s_sr1,x
		lda	#$09
		sta	s_cr1,x
ss_hrpredone:	rts

ss_setpitch:
		sty	tmp
		clc
		adc	pitch0,x
		tay
		lda	pitches_l,y
		sta	s_freqlo1,x
		lda	pitches_h,y
		sta	s_freqhi1,x
		ldy	tmp
		rts

ss_wavetbl:	ldy	wtpos0,x
ss_wtjmp:	bne	ss_wtfetch
		lda	#$0
		jsr	ss_setpitch
		rts
ss_wtfetch:	lda	wave_l-1,y
		cmp	#$ff
		bne	ss_dowave
		lda	wave_h-1,y
		tay
		bcs	ss_wtjmp
ss_dowave:	sta	s_cr1,x
		lda	wave_h-1,y
		jsr	ss_setpitch
		iny
		sty	wtpos0,x
		rts

ss_pulsetbl:	ldy	ptpos0,x
ss_ptjmp:	beq	ss_ptdone
		lda	pstep0,x
		beq	ss_preadtbl
ss_dopstep:	lda	#$0
		sta	tmp
		lda	pulse_h-1,y
		bpl	ss_poffplus
		dec	tmp
ss_poffplus:	clc
		adc	s_pwlo1,x
		sta	s_pwlo1,x
		lda	tmp
		adc	s_pwhi1,x
		and	#$f
		sta	s_pwhi1,x
		dec	pstep0,x
		beq	ss_ptnext
		rts
ss_preadtbl:	lda	pulse_l-1,y
		bmi	ss_nopstep
		sta	pstep0,x
		bpl	ss_dopstep
ss_nopstep:	cmp	#$ff
		bne	ss_setpulse
		lda	pulse_h-1,y
		tay
		bcs	ss_ptjmp
ss_setpulse:	and	#$f
		sta	s_pwhi1,x
		lda	pulse_h-1,y
		sta	s_pwlo1,x
ss_ptnext:	iny
ss_ptdone:	sty	ptpos0,x
		rts

ss_filtertbl:
		ldy	ftpos0,x
ss_ftjmp:	beq	ss_ftdone
		lda	fstep0,x
		beq	ss_freadtbl
ss_dofstep:	lda	filter_h-1,y
		clc
		adc	s_fchi
		sta	s_fchi
		dec	fstep0,x
		beq	ss_ftnext
		rts
ss_freadtbl:	lda	filter_l-1,y
		beq	ss_setfilter
		bpl	ss_filtermod
		cmp	#$ff
		bne	ss_filtercfg
		lda	filter_h-1,y
		tay
		bcs	ss_ftjmp
ss_filtermod:	sta	fstep0,x
		bne	ss_dofstep
ss_setfilter:	lda	filter_h-1,y
		sta	s_fchi
ss_ftnext:	iny
ss_ftdone:	sty	ftpos0,x
		rts
ss_filtercfg:	and	#$70
		sta	tmp
		lda	s_modevol
		and	#$f
		ora	tmp
		sta	s_modevol
		lda	filter_h-1,y
		sta	s_resflt
		iny
		bne	ss_freadtbl
		beq	ss_ftdone

ss_hr_off:
		jsr	ss_setpatptr
		ldy	patpos0,x
		cpy	#$ff
		bne	shro_do
		lda	#$0
		beq	shro_sti
shro_do:	lda	(patptr),y
shro_sti:	sta	inst0,x
		beq	shro_done
		cmp	#$ff
		bne	shro_hro
		rts
shro_hro:	lda	inst0,x
		bmi	shro_done
		lda	#$0
		sta	s_ad1,x
		sta	s_sr1,x
		sta	wtpos0,x
		sta	ptpos0,x
		sta	ftpos0,x
sff_gateoff:	lda	s_cr1,x
		and	#$fe
		sta	s_cr1,x
shro_done:	clc
		rts

ss_firstframe:
		jsr	ss_setpatptr
		ldy	patpos0,x
		lda	inst0,x
		beq	sff_patstep
		bpl	sff_startinst
		asl	a
		bpl	sff_setpitch
		jsr	sff_gateoff
		bcc	sff_patstep
sff_startinst:	sty	tmp
		tay
		lda	inst_wt,y
		sta	wtpos0,x
		lda	inst_pt,y
		sta	ptpos0,x
		lda	inst_ft,y
		sta	ftpos0,x
		lda	#$0
		sta	pstep0,x
		sta	fstep0,x
		ldy	tmp
sff_setpitch:	iny
		lda	(patptr),y
		sta	pitch0,x
sff_patstep:	iny
		beq	sff_done
		sty	patpos0,x
sff_done:	rts

ss_nextpat:
		jsr	snd_tunestep
		jmp	ss_hr_offsteps

snd_step:
		ldx	hrstep
		beq	ss_no_hr
		dex
		stx	hrstep
		beq	ss_hr_presteps
		cpx	#HR_TIMER-1
		bne	ss_tablestep
ss_hr_offsteps:	ldx	#$0
		jsr	ss_hr_off
		bcs	ss_nextpat
		ldx	#$7
		jsr	ss_hr_off
		bcs	ss_nextpat
		ldx	#$e
		jsr	ss_hr_off
		bcs	ss_nextpat
		bcc	ss_tablestep
ss_hr_presteps:	ldx	#$0
		jsr	ss_hr_pre
		ldx	#$7
		jsr	ss_hr_pre
		ldx	#$e
		jsr	ss_hr_pre
ss_hr_speed:	lda	#$80
		sta	stepcount
		bmi	ss_tablestep
ss_no_hr:	ldx	stepcount
		bpl	ss_normalstep
		lda	speed
		sta	stepcount
		ldx	#$0
		jsr	ss_firstframe
		ldx	#$7
		jsr	ss_firstframe
		ldx	#$e
		jsr	ss_firstframe
		ldx	stepcount
ss_normalstep:	dex
		stx	stepcount
		bpl	ss_tablestep
		ldx	#HR_TIMER
		stx	hrstep
		lda	nexttune
		cmp	tune
		beq	ss_sametune
		jsr	snd_gototune
ss_sametune:	cmp	#$ff
		bne	ss_tablestep
		rts
ss_tablestep:	ldx	#$0
		jsr	ss_wavetbl
		jsr	ss_pulsetbl
		jsr	ss_filtertbl
		ldx	#$7
		jsr	ss_wavetbl
		jsr	ss_pulsetbl
		jsr	ss_filtertbl
		ldx	#$e
		jsr	ss_wavetbl
		jsr	ss_pulsetbl
		jsr	ss_filtertbl

ss_done:	rts
