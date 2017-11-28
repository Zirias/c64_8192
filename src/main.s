.include "zp.inc"
.include "irq.inc"
.include "charset.inc"
.include "screen.inc"
.include "board.inc"

.segment "MAIN"

		sei
		jsr	zp_init
		jsr	charset_init
		jsr	board_init
		jsr	screen_init
		jsr	irq_init
		cli
end:		jmp	end

