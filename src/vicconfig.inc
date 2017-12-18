; memory configuration
; --------------------

; start address of vic AS ($00, $40, $80, $c0)
vic_bank = $c0

; start page of character set in vic AS
vic_charpage = $18

; start page of color memory in vic AS
vic_colpage = $14

; start page of screen memory in vic AS
vic_screenpage = $10

; start page for spriteset in vic AS
vic_sprite_base = $1a


; calculated values
; -----------------

; lowest sprite pointer value
vic_sprite_baseptr = vic_sprite_base << 2

; value to AND CIA2_DATA_A with for selecting configured bank
vic_bankselect_and = $fc + (~(vic_bank >> 6) & $3)

; MEM_CTL value for hires mode
vic_memctl_hires = (vic_colpage << 2) + 9

; MEM_CTL value for text mode
vic_memctl_text = (vic_screenpage << 2) & $f0 | (vic_charpage >> 2) & $0e | 1

; start address of character set in 6510 AS
vic_charset = (vic_bank + vic_charpage) << 8

; start address of screen / color ram in 6510 AS
vic_colram = (vic_bank + vic_colpage) << 8

; start address of screen / color ram in 6510 AS
vic_screenram = (vic_bank + vic_screenpage) << 8

; start address of bitmap data in 6510 AS
vic_bitmap = (vic_bank + $20) << 8

; start address of sprite vectors in 6510 AS
vic_sprite_vectors = ((vic_bank + vic_colpage) << 8) + $3f8

; start address of spriteset in 6510 AS
vic_spriteset = (vic_bank + vic_sprite_base) << 8

; vim: ft=asm:et:si:ts=8:sts=8:sw=8
