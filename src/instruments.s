.export	inst_ad
.export	inst_sr
.export	inst_wt
.export	inst_pt
.export	inst_ft
.export wave_l
.export wave_h
.export pulse_l
.export pulse_h
.export filter_l
.export	filter_h

.data

inst_ad:
		.byte	$00
		.byte	$11
		.byte	$11
		.byte	$32

inst_sr:
		.byte	$00
		.byte	$a9
		.byte	$a9
		.byte	$cc

inst_wt:
		.byte	$00
		.byte	w_1 -wave_l+1
		.byte	w_2 -wave_l+1
		.byte	w_3 -wave_l+1

inst_pt:
		.byte	$00
		.byte	p_1 - pulse_l+1
		.byte	p_1 - pulse_l+1
		.byte	$00

inst_ft:
		.byte	$00
		.byte	f_1 - filter_l+1
		.byte	$00
		.byte	$00

wave_l:
w_1:		.byte	$41,$41,$41,$41,$41,$41,$41,$41
		.byte	$40,$ff
w_2:		.byte	$41,$41,$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$41,$41,$41
		.byte	$40,$ff
w_3:		.byte	$21,$21,$21,$21,$21,$21,$21,$21
		.byte	$20,$ff

wave_h:
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00,$f7,$fb
		.byte	$00,$f7,$fb,$00,$f7,$fb,$00,$f7
		.byte	$fb,$00,$f7,$fb,$00,$f7,$fb,$00
		.byte	$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00

pulse_l:
p_1:		.byte	$89,$20,$ff

pulse_h:
		.byte	$00,$08,$00

filter_l:
f_1:		.byte	$90,$00,$20,$ff

filter_h:
		.byte	$21,$c0,$fa,$00

