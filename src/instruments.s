.include "pitches.inc"

.export	inst_ad
.export	inst_sr
.export	inst_wt
.export	inst_pt
.export	inst_ft
.export inst_vdelay
.export inst_vcount
.export inst_voff
.export wave_l
.export wave_h
.export pulse_l
.export pulse_h
.export flt8580_l
.export	flt8580_h
.export flt6581_l
.export	flt6581_h
.export sfx_ad
.export sfx_sr
.export sfx_wt
.export sfx_pt
.export sfx_ft
.export sfx_pitch

.data

inst_ad:
		.byte	$13
		.byte	$00
		.byte	$32
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$06
		.byte	$06

inst_sr:
		.byte	$a9
		.byte	$6a
		.byte	$8a
		.byte	$6a
		.byte	$6a
		.byte	$6a
		.byte	$6c
		.byte	$6c

inst_wt:
		.byte	w_1 - wave_l+1
		.byte	w_2 - wave_l+1
		.byte	w_3 - wave_l+1
		.byte	w_4 - wave_l+1
		.byte	w_5 - wave_l+1
		.byte	w_6 - wave_l+1
		.byte	w_4 - wave_l+1
		.byte	w_5 - wave_l+1

inst_pt:
		.byte	$00
		.byte	p_2 - pulse_l+1
		.byte	$00
		.byte	p_2 - pulse_l+1
		.byte	p_2 - pulse_l+1
		.byte	p_2 - pulse_l+1
		.byte	p_2 - pulse_l+1
		.byte	p_2 - pulse_l+1

inst_ft:
		.byte	$00
		.byte	f_1 - flt8580_l+1
		.byte	f_2 - flt8580_l+1
		.byte	f_1 - flt8580_l+1
		.byte	f_1 - flt8580_l+1
		.byte	f_1 - flt8580_l+1
		.byte	f_1 - flt8580_l+1
		.byte	f_1 - flt8580_l+1

inst_vdelay:
		.byte	$0c
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00

inst_vcount:
		.byte	$04
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00

inst_voff:
		.byte	$12
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00

wave_l:
w_1:		.byte	$11,$ff
w_2:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$40,$40,$40,$ff
w_3:		.byte	$21,$21,$21,$20,$ff
w_4:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$40,$40,$40,$ff
w_5:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$40,$40,$40,$ff
w_6:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$40,$40,$40,$ff
w_7:		.byte	$81,$81,$81,$81,$81,$80,$80,$80,$ff
w_8:		.byte	$41,$41,$41,$41,$40,$40
		.byte	$40,$40,$40,$40,$40,$40,$ff
w_9:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$40,$ff

wave_h:
		.byte	$00,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00,w_2 -wave_l+10
		.byte	$00,$00,$00,$00,$00
		.byte	$00,$04,$07,$00,$04,$07
		.byte	$00,$04,$07,$00,$04,$07,w_4 -wave_l+10
		.byte	$00,$03,$07,$00,$03,$07
		.byte	$00,$03,$07,$00,$03,$07,w_5 -wave_l+10
		.byte	$fb,$00,$03,$fb,$00,$03
		.byte	$fb,$00,$03,$fb,$00,$03,w_6 -wave_l+10
		.byte	$00,$7f,$7f,$7f,$60,$40,$00,$00,$00
		.byte	PT_D4,PT_F4,PT_AF4,PT_B4,PT_DF5,PT_E5
		.byte	$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00
		.byte	$00,$00

pulse_l:
p_2:		.byte	$8c,$20,$ff
p_3:		.byte	$8e,$08,$ff
p_4:		.byte	$8e,$ff

pulse_h:
		.byte	$00,$18,$00
		.byte	$00,$20,$00
		.byte	$80,$00

flt8580_l:
f_1:		.byte	$90,$00,$08,$ff
f_2:		.byte	$90,$00,$08,$ff

flt8580_h:
		.byte	$52,$60,$f8,$00
		.byte	$22,$48,$f8,$00

flt6581_l:
		.byte	$90,$00,$08,$ff
		.byte	$90,$00,$08,$ff

flt6581_h:
		.byte	$52,$7b,$f9,$00
		.byte	$22,$64,$f9,$00

sfx_ad:
		.byte	$a2
		.byte	$00
		.byte	$00

sfx_sr:
		.byte	$48
		.byte	$89
		.byte	$70

sfx_wt:
		.byte	w_7 - wave_l+1
		.byte	w_8 - wave_l+1
		.byte	w_9 - wave_l+1

sfx_pt:
		.byte	$00
		.byte	p_3 - pulse_l+1
		.byte	p_4 - pulse_l+1

sfx_ft:
		.byte	$00
		.byte	$00
		.byte	$00

sfx_pitch:
		.byte	PT_G3
		.byte	PT_D4
		.byte	PT_A1

