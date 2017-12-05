.include "pitches.inc"

.export tunes_l
.export tunes_h

.export patterns_l
.export patterns_h


.data

tunes_l:	.byte	<tune_ingame

tunes_h:	.byte	>tune_ingame

tune_ingame:
		.byte	$0c
		.byte	$00,$01,$00,$00
		.byte	$00,$01,$02,$00
		.byte	$00,$01,$03,$00
		.byte	$00,$01,$03,$00
		.byte	$00,$04,$00,$00
		.byte	$00,$05,$00,$00
		.byte	$80,$05

patterns_l:
		.byte	<pat1, <pat2, <pat3, <pat4, <pat5

patterns_h:
		.byte	>pat1, >pat2, >pat3, >pat4, >pat5

pat1:
		.byte	$01,PT_C3
		.byte	$00
		.byte	$c0
		.byte	$01,PT_G3
		.byte	$01,PT_C4
		.byte	$00
		.byte	$01,PT_BF3
		.byte	$00
		.byte	$01,PT_F3
		.byte	$c0
		.byte	$01,PT_BF3
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$00
		.byte	$80,PT_G3
		.byte	$00
		.byte	$80,PT_F3
		.byte	$00
		.byte	$01,PT_G3
		.byte	$00
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$01,PT_BF3
		.byte	$00
		.byte	$01,PT_A3
		.byte	$00
		.byte	$01,PT_F3
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$c0
		.byte	$01,PT_G3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$01,PT_G3
		.byte	$00
		.byte	$ff

pat2:		.byte	$03,PT_C1
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$03,PT_BF0
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$03,PT_F0
		.byte	$00
		.byte	$03,PT_F0
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$03,PT_C1
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$03,PT_F1
		.byte	$00
		.byte	$03,PT_D1
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$03,PT_BF0
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$ff

pat3:		.byte	$03,PT_C1
		.byte	$00
		.byte	$02,PT_C4
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$03,PT_BF0
		.byte	$00
		.byte	$02,PT_BF3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$04,PT_F3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$04,PT_F3
		.byte	$c0
		.byte	$03,PT_C1
		.byte	$00
		.byte	$02,PT_C4
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$03,PT_F1
		.byte	$00
		.byte	$02,PT_A3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$03,PT_BF0
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$00
		.byte	$ff

pat4:
		.byte	$01,PT_C4
		.byte	$00
		.byte	$80,PT_BF3
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$c0
		.byte	$01,PT_C4
		.byte	$00
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$01,PT_F3
		.byte	$00
		.byte	$01,PT_G3
		.byte	$00
		.byte	$80,PT_A3
		.byte	$00
		.byte	$80,PT_G3
		.byte	$00
		.byte	$01,PT_A3
		.byte	$00
		.byte	$80,PT_F3
		.byte	$c0
		.byte	$01,PT_D3
		.byte	$c0
		.byte	$01,PT_F3
		.byte	$c0
		.byte	$01,PT_E3
		.byte	$00
		.byte	$c0
		.byte	$01,PT_F3
		.byte	$01,PT_D3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$01,PT_D3
		.byte	$00
		.byte	$ff

pat5:
		.byte	$01,PT_E3
		.byte	$00
		.byte	$c0
		.byte	$01,PT_D3
		.byte	$01,PT_C3
		.byte	$c0
		.byte	$01,PT_E3
		.byte	$00
		.byte	$80,PT_G3
		.byte	$c0
		.byte	$01,PT_F3
		.byte	$c0
		.byte	$01,PT_E3
		.byte	$00
		.byte	$80,PT_D3
		.byte	$00
		.byte	$80,PT_C3
		.byte	$00
		.byte	$01,PT_D3
		.byte	$00
		.byte	$c0
		.byte	$01,PT_F3
		.byte	$01,PT_E3
		.byte	$c0
		.byte	$01,PT_D3
		.byte	$00
		.byte	$80,PT_G3
		.byte	$c0
		.byte	$01,PT_E3
		.byte	$c0
		.byte	$01,PT_A3
		.byte	$00
		.byte	$c0
		.byte	$00
		.byte	$01,PT_A3
		.byte	$00
		.byte	$ff
