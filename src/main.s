.include "zp.inc"
.include "irq.inc"
.include "charset.inc"
.include "random.inc"
.include "jsinput.inc"
.include "screen.inc"
.include "board.inc"

.segment "MAIN"

		sei
		jsr	zp_init
		jsr	rnd_init
		jsr	charset_init
		jsr	board_init
		jsr	screen_init
		jsr	js_init
		jsr	irq_init
		cli

		jsr	screen_draw

end:		jsr	js_get
		bcs	end
		inc	$d020
		bcc	end

