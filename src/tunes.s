.include "pitches.inc"

.export tunes_l
.export tunes_h

.export patterns_l
.export patterns_h


.data

tunes_l:	.byte <tune_ingame

tunes_h:	.byte >tune_ingame

tune_ingame:
		.byte $08
		.byte $00,$01,$00,$00
		.byte $80,$01

patterns_l:
		.byte <pat1

patterns_h:
		.byte >pat1

pat1:
		.byte $01,PT_C3
		.byte $00
		.byte $00
		.byte $01,PT_G3
		.byte $01,PT_C4
		.byte $00
		.byte $01,PT_BF3
		.byte $00
		.byte $01,PT_F3
		.byte $00
		.byte $01,PT_BF3
		.byte $00
		.byte $01,PT_A3
		.byte $00
		.byte $01,PT_G3
		.byte $00
		.byte $01,PT_F3
		.byte $00
		.byte $ff

