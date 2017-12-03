.include "sid.inc"
.include "pitches.inc"
.include "instruments.inc"
.include "tunes.inc"

.export snd_init
.export snd_settune
.export snd_step

.zeropage

tune:		.res	1
nexttune:	.res	1
tuneptr:	.res	2
tunepos:	.res	1
patptr0:	.res	2
patptr1:	.res	2
patptr2:	.res	2
patpos0:	.res	1
patpos1:	.res	1
patpos2:	.res	1
speed:		.res	1
stepcount:	.res	1
hrstep:		.res	1
wtpos0:		.res	1
ptpos0:		.res	1
ftpos0:		.res	1
wtpos1:		.res	1
ptpos1:		.res	1
ftpos1:		.res	1
wtpos2:		.res	1
ptpos2:		.res	1
ftpos2:		.res	1
inst0:		.res	1
inst1:		.res	1
inst2:		.res	1
pitch0:		.res	1
pitch1:		.res	1
pitch2:		.res	1
snd_zpsize	= *-tune

.code

snd_init:
		lda	#$0
		ldx	#snd_zpsize-1
si_zpinit:	sta	tune,x
		dex
		bpl	si_zpinit
		ldx	#SID_RESFLT - SID_FREQLO1
si_sidinit:	sta	SID_FREQLO1,x
		dex
		bpl	si_sidinit
		lda	#$f
		sta	SID_MODEVOL
		lda	#$ff
		sta	tune
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

snd_nextpat:
		jsr	snd_tunestep
snd_hr_off:
		ldy	patpos0
		cpy	#$ff
		bne	ss_hr_do0
		lda	#$0
		beq	ss_hr_sti0
ss_hr_do0:	lda	(patptr0),y
ss_hr_sti0:	sta	inst0
		beq	ss_hr_off1
		cmp	#$ff
		beq	snd_nextpat
		lda	#$0
		sta	SID_AD1
		sta	SID_SR1
		sta	wtpos0
		sta	ptpos0
		sta	ftpos0
		lda	SID_CR1
		and	#$fe
		sta	SID_CR1
ss_hr_off1:	ldy	patpos1
		cpy	#$ff
		bne	ss_hr_do1
		lda	#$0
		beq	ss_hr_sti1
ss_hr_do1:	lda	(patptr1),y
ss_hr_sti1:	sta	inst1
		beq	ss_hr_off2
		cmp	#$ff
		beq	snd_nextpat
		lda	#$0
		sta	SID_AD2
		sta	SID_SR2
		sta	wtpos1
		sta	ptpos1
		sta	ftpos1
		lda	SID_CR2
		and	#$fe
		sta	SID_CR2
ss_hr_off2:	ldy	patpos2
		cpy	#$ff
		bne	ss_hr_do2
		lda	#$0
		beq	ss_hr_sti2
ss_hr_do2:	lda	(patptr2),y
ss_hr_sti2:	sta	inst2
		beq	ss_hr_done
		cmp	#$ff
		beq	snd_nextpat
		lda	#$0
		sta	SID_AD3
		sta	SID_SR3
		sta	wtpos2
		sta	ptpos2
		sta	ftpos2
		lda	SID_CR3
		and	#$fe
		sta	SID_CR3
ss_hr_done:	jmp	ss_tablestep

snd_step:
		ldx	hrstep
		beq	ss_no_hr
		dex
		stx	hrstep
		beq	ss_hr_pre
		cpx	#$02
		bne	ss_hr_done
		jmp	snd_hr_off
ss_hr_pre:	ldx	inst0
		beq	ss_hr_pre1
		lda	inst_ad,x
		sta	SID_AD1
		lda	inst_sr,x
		sta	SID_SR1
		lda	#$01
		sta	SID_CR1
ss_hr_pre1:	ldx	inst1
		beq	ss_hr_pre2
		lda	inst_ad,x
		sta	SID_AD2
		lda	inst_sr,x
		sta	SID_SR2
		lda	#$01
		sta	SID_CR2
ss_hr_pre2:	ldx	inst2
		beq	ss_hr_speed
		lda	inst_ad,x
		sta	SID_AD3
		lda	inst_sr,x
		sta	SID_SR3
		lda	#$01
		sta	SID_CR3
ss_hr_speed:	lda	#$80
		sta	stepcount
		bmi	ss_hr_done
ss_no_hr:	ldx	stepcount
		bpl	ss_normalstep
		lda	speed
		sta	stepcount
		ldy	patpos0
		ldx	inst0
		beq	ss_patstep1
		lda	inst_wt,x
		sta	wtpos0
		lda	inst_pt,x
		sta	ptpos0
		lda	inst_ft,x
		sta	ftpos0
		iny
		lda	(patptr0),y
		sta	pitch0
ss_patstep1:	iny
		beq	ss_posskip0
		sty	patpos0
ss_posskip0:	ldy	patpos1
		ldx	inst1
		beq	ss_patstep2
		lda	inst_wt,x
		sta	wtpos1
		lda	inst_pt,x
		sta	ptpos1
		lda	inst_ft,x
		sta	ftpos1
		iny
		lda	(patptr1),y
		sta	pitch1
ss_patstep2:	iny
		beq	ss_posskip1
		sty	patpos1
ss_posskip1:	ldy	patpos2
		ldx	inst2
		beq	ss_patstepdone
		lda	inst_wt,x
		sta	wtpos2
		lda	inst_pt,x
		sta	ptpos2
		lda	inst_ft,x
		sta	ftpos2
		iny
		lda	(patptr1),y
		sta	pitch2
ss_patstepdone:	iny
		beq	ss_posskip2
		sty	patpos2
ss_posskip2:	ldx	stepcount
ss_normalstep:	dex
		stx	stepcount
		bpl	ss_tablestep
		ldx	#$3
		stx	hrstep
		lda	nexttune
		cmp	tune
		beq	ss_sametune
		jsr	snd_gototune
ss_sametune:	cmp	#$ff
		bne	ss_tablestep
		rts
ss_tablestep:	ldx	wtpos0
		beq	ss_pulse0
		lda	wave_l-1,x
		cmp	#$ff
		bne	ss_dowave0
		lda	wave_h-1,x
		sta	wtpos0
		jmp	ss_tablestep
ss_dowave0:	sta	SID_CR1
		lda	wave_h-1,x
		clc
		adc	pitch0
		tax
		lda	pitches_l,x
		sta	SID_FREQLO1
		lda	pitches_h,x
		sta	SID_FREQHI1
		inc	wtpos0
ss_pulse0:	ldx	ptpos0
		beq	ss_filter0
		lda	pulse_l-1,x
		cmp	#$ff
		bne	ss_dopulse0
		lda	pulse_h-1,x
		sta	ptpos0
		jmp	ss_pulse0
ss_dopulse0:	and	#$f
		sta	SID_PWHI1
		lda	pulse_h-1,x
		sta	SID_PWLO1
		inc	ptpos0
ss_filter0:
ss_wave1:	ldx	wtpos1
		beq	ss_pulse1
		lda	wave_l-1,x
		cmp	#$ff
		bne	ss_dowave1
		lda	wave_h-1,x
		sta	wtpos1
		jmp	ss_tablestep
ss_dowave1:	sta	SID_CR2
		lda	wave_h-1,x
		clc
		adc	pitch1
		tax
		lda	pitches_l,x
		sta	SID_FREQLO2
		lda	pitches_h,x
		sta	SID_FREQHI2
		inc	wtpos1
ss_pulse1:	ldx	ptpos1
		beq	ss_filter1
		lda	pulse_l-1,x
		cmp	#$ff
		bne	ss_dopulse1
		lda	pulse_h-1,x
		sta	ptpos1
		jmp	ss_pulse1
ss_dopulse1:	and	#$f
		sta	SID_PWHI2
		lda	pulse_h-1,x
		sta	SID_PWLO2
		inc	ptpos1
ss_filter1:
ss_wave2:	ldx	wtpos2
		beq	ss_pulse2
		lda	wave_l-1,x
		cmp	#$ff
		bne	ss_dowave1
		lda	wave_h-1,x
		sta	wtpos2
		jmp	ss_tablestep
ss_dowave2:	sta	SID_CR3
		lda	wave_h-1,x
		clc
		adc	pitch2
		tax
		lda	pitches_l,x
		sta	SID_FREQLO3
		lda	pitches_h,x
		sta	SID_FREQHI3
		inc	wtpos2
ss_pulse2:	ldx	ptpos2
		beq	ss_filter2
		lda	pulse_l-1,x
		cmp	#$ff
		bne	ss_dopulse2
		lda	pulse_h-1,x
		sta	ptpos2
		jmp	ss_pulse2
ss_dopulse2:	and	#$f
		sta	SID_PWHI3
		lda	pulse_h-1,x
		sta	SID_PWLO3
		inc	ptpos2
ss_filter2:

ss_done:	rts
