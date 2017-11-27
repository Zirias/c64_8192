.include "irq.inc"
.include "charset.inc"
.include "screen.inc"

.segment "MAIN"

		sei
		jsr	charset_init
		jsr	irq_init
		jsr	screen_init
		cli
end:		jmp	end

