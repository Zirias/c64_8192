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
		.byte	$13
		.byte	$12
		.byte	$32
		.byte	$12

inst_sr:
		.byte	$ab
		.byte	$68
		.byte	$8c
		.byte	$68

inst_wt:
		.byte	w_1 - wave_l+1
		.byte	w_2 - wave_l+1
		.byte	w_3 - wave_l+1
		.byte	w_4 - wave_l+1

inst_pt:
		.byte	$00
		.byte	p_2 - pulse_l+1
		.byte	$00
		.byte	p_2 - pulse_l+1

inst_ft:
		.byte	$00
		.byte	f_1 - filter_l+1
		.byte	f_2 - filter_l+1
		.byte	f_1 - filter_l+1

wave_l:
w_1:		.byte	$11,$ff
w_2:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$41,$ff
w_3:		.byte	$21,$21,$21,$21,$21,$21,$21,$21
		.byte	$20,$ff
w_4:		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$41
		.byte	$41,$41,$41,$41,$41,$ff

wave_h:
		.byte	$00,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00
		.byte	$f7,$fb,$00,$f7,$fb,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00
		.byte	$00,$04,$07,$00,$04,$07
		.byte	$00,$04,$07,$00,$04,$07
		.byte	$00,$04,$07,$00,$04,$00

pulse_l:
p_2:		.byte	$8a,$20,$ff

pulse_h:
		.byte	$00,$20,$00

filter_l:
f_1:		.byte	$80,$ff
f_2:		.byte	$90,$00,$10,$ff

filter_h:
		.byte	$00,$00
		.byte	$22,$48,$fc,$00

