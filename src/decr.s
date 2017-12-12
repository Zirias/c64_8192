; This source code is altered and is not the original version found on
; the Exomizer homepage.
; It contains modifications made by Krill/Plush to depack a packed file
; crunched forward and to work with his loader.
; It was further modified by Zirias to match the loader used in the 8192
; game

;
; Copyright (c) 2002 - 2005 Magnus Lind.
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from
; the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;   1. The origin of this software must not be misrepresented; you must not
;   claim that you wrote the original software. If you use this software in a
;   product, an acknowledgment in the product documentation would be
;   appreciated but is not required.
;
;   2. Altered source versions must be plainly marked as such, and must not
;   be misrepresented as being the original software.
;
;   3. This notice may not be removed or altered from any distribution.
;
;   4. The names of this software and/or it's copyright holders may not be
;   used to endorse or promote products derived from this software without
;   specific prior written permission.
;
; -------------------------------------------------------------------
; The decruncher jsr:s to the get_crunched_byte address when it wants to
; read a crunched byte. This subroutine has to preserve x and y register and,
; if FORWARD_DECRUNCHING = 0, must not modify the state of the carry flag.
; -------------------------------------------------------------------
.import get_crunched_byte
; -------------------------------------------------------------------
; this function is the heart of the decruncher.
; It initializes the decruncher zeropage locations and precalculates the
; decrunch tables and decrunches the data
; This function will not change the interrupt status bit and it will not
; modify the memory configuration.
; -------------------------------------------------------------------
.export decrunch
.exportzp zp_dest_lo
.exportzp zp_dest_hi

; -------------------------------------------------------------------
; if literal sequences is not used (the data was crunched with the -c
; flag) then the following line can be uncommented for shorter code.
LITERAL_SEQUENCES_NOT_USED=1

; -------------------------------------------------------------------
; set this flag to 0 if the data are depacked backwards,
; and non-0 otherwise
; -------------------------------------------------------------------
FORWARD_DECRUNCHING=1

; -------------------------------------------------------------------
; zero page addresses used
; -------------------------------------------------------------------

.zeropage

zp_len_lo:	.res	1

zp_src_lo:	.res	1
zp_src_hi:	.res	1

zp_bits_hi:	.res	1

zp_bitbuf:	.res	1
zp_dest_lo:	.res	1	; dest addr lo
zp_dest_hi:	.res	1	; dest addr hi

tabl_bi = decrunch_table
tabl_lo = decrunch_table + 52
tabl_hi = decrunch_table + 104

.bss
decrunch_table:	.res	156

; -------------------------------------------------------------------
; no code below this comment has to be modified in order to generate
; a working decruncher of this source file.
; However, you may want to relocate the tables last in the file to a
; more suitable address.
; -------------------------------------------------------------------

.segment "CORE"
; -------------------------------------------------------------------
; jsr this label to decrunch, it will in turn init the tables and
; call the decruncher
; no constraints on register content, however the
; decimal flag has to be #0 (it almost always is, otherwise do a cld)
decrunch:
; -------------------------------------------------------------------
; init zeropage, x and y regs.
;
	ldy #0
	ldx #3
init_zp:
	jsr get_crunched_byte
	sta zp_bitbuf - 1,x
	dex
	bne init_zp
; -------------------------------------------------------------------
; calculate tables (50 bytes)
; x and y must be #0 when entering
;
nextone:
	inx
	tya
	and #$0f
	beq shortcut		; start with new sequence

	txa			    ; this clears reg a
	lsr a			; and sets the carry flag
	ldx tabl_bi-1,y
rolle:
	rol a
	rol zp_bits_hi
	dex
	bpl rolle		; c = 0 after this (rol zp_bits_hi)

	adc tabl_lo-1,y
	tax

	lda zp_bits_hi
	adc tabl_hi-1,y
shortcut:
	sta tabl_hi,y
	txa
	sta tabl_lo,y

	ldx #4
	jsr get_bits		; clears x-reg.
	sta tabl_bi,y
	iny
	cpy #52
	bne nextone
	beq begin

; -------------------------------------------------------------------
; get bits (29 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   z = 1
;   zp_bits_hi = #bits_hi
; notes:
;   y is untouched
; -------------------------------------------------------------------
get_bits:
	lda #$00
	sta zp_bits_hi
	cpx #$01
	bcc bits_done
bits_next:
	lsr zp_bitbuf
	bne ok
	pha
.IF FORWARD_DECRUNCHING = 0
literal_get_byte:
	jsr get_crunched_byte
	bcc literal_byte_gotten
.ELSE
	jsr get_crunched_byte
	sec
.ENDIF
	ror a
	sta zp_bitbuf
	pla
ok:
	rol a
	rol zp_bits_hi
	dex
	bne bits_next
bits_done:
	rts

.IF FORWARD_DECRUNCHING

; -------------------------------------------------------------------
; literal sequence handling
;
literal_start:
	ldx #$10    ; these 16 bits
	jsr get_bits; tell the length of the sequence
	ldx zp_bits_hi
literal_start1: ; if literal byte, a = 1, zp_bits_hi = 0
	sta zp_len_lo
	.byte $2c   ; skip next instruction

; -------------------------------------------------------------------
; main copy loop
; x = length hi
; y = length lo
;
copy_start:
    stx zp_bits_hi
    ldy #$00
copy_next:
.IFNDEF LITERAL_SEQUENCES_NOT_USED
	bcs :+
	jsr get_crunched_byte
	clc
	.byte $2c; skip next instruction
:
.ENDIF
	lda (zp_src_lo),y
	sta (zp_dest_lo),y
    iny
    bne :+
    dex
	inc zp_dest_hi
	inc zp_src_hi
:   tya
	eor zp_len_lo
	bne copy_next
	txa
	bne copy_next
	tya
	clc
	adc zp_dest_lo
	sta zp_dest_lo
	bcc :+
	inc zp_dest_hi
:

.ELSE

; -------------------------------------------------------------------
; main copy loop
; x = length hi
; y = length lo
; (18(16) bytes)
;
copy_next_hi:
	dex
	dec zp_dest_hi
	dec zp_src_hi
copy_next:
	dey
.IFNDEF LITERAL_SEQUENCES_NOT_USED
	bcc literal_get_byte
.ENDIF
	lda (zp_src_lo),y
literal_byte_gotten: ; y = 0 when this label is jumped to
	sta (zp_dest_lo),y
copy_start:
	tya
	bne copy_next
	txa
	bne copy_next_hi

.ENDIF

; -------------------------------------------------------------------
; decruncher entry point, needs calculated tables (21(13) bytes)
; x and y must be #0 when entering
;
begin:
.IFNDEF LITERAL_SEQUENCES_NOT_USED
    inx
	jsr get_bits
	tay
	bne literal_start1; if bit set, get a literal byte
.ELSE
	dey
.ENDIF
getgamma:
	inx
	jsr bits_next
	lsr a
	iny
	bcc getgamma
.IFDEF LITERAL_SEQUENCES_NOT_USED
	beq literal_start
.ENDIF
	cpy #$11

.IFNDEF LITERAL_SEQUENCES_NOT_USED
    .IF FORWARD_DECRUNCHING
	beq bits_done     ; gamma = 17   : end of file
	bcs literal_start ; gamma = 18   : literal sequence
	                  ; gamma = 1..16: sequence
	.ELSE
	bcc sequence_start; gamma = 1..16: sequence
	beq bits_done     ; gamma = 17   : end of file
	                  ; gamma = 18   : literal sequence
; -------------------------------------------------------------------
; literal sequence handling (13(2) bytes)
;
	ldx #$10    ; these 16 bits
	jsr get_bits; tell the length of the sequence
literal_start1: ; if literal byte, a = 1, zp_bits_hi = 0
	sta zp_len_lo
	ldx zp_bits_hi
	ldy #0
	bcc literal_start; jmp

sequence_start:
    .ENDIF
.ELSE
	bcs bits_done
.ENDIF
; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (11 bytes)
;
	ldx tabl_bi - 1,y
	jsr get_bits
	adc tabl_lo - 1,y	; we have now calculated zp_len_lo
	sta zp_len_lo
; -------------------------------------------------------------------
; now do the hibyte of the sequence length calculation (6 bytes)
	lda zp_bits_hi
	adc tabl_hi - 1,y	; c = 0 after this.
	pha
; -------------------------------------------------------------------
; here we decide what offset table to use (20 bytes)
; x is 0 here
;
	bne nots123
	ldy zp_len_lo
	cpy #$04
	bcc size123
nots123:
	ldy #$03
size123:
	ldx tabl_bit - 1,y
	jsr get_bits
	adc tabl_off - 1,y	; c = 0 after this.
	tay			; 1 <= y <= 52 here
; -------------------------------------------------------------------
.IF FORWARD_DECRUNCHING = 0
; Here we do the dest_lo -= len_lo subtraction to prepare zp_dest
; but we do it backwards:	a - b == (b - a - 1) ^ ~0 (C-syntax)
; (16(16) bytes)
	lda zp_len_lo
literal_start:
	sbc zp_dest_lo
	bcc noborrow
	dec zp_dest_hi
noborrow:
	eor #$ff
	sta zp_dest_lo
	cpy #$01		; y < 1 then literal
.IFNDEF LITERAL_SEQUENCES_NOT_USED
	bcc pre_copy
    .ELSE
	bcc literal_get_byte
    .ENDIF
.ENDIF

; -------------------------------------------------------------------
; calulate absolute offset (zp_src)
;
	ldx tabl_bi,y
	jsr get_bits
	adc tabl_lo,y
	bcc skipcarry
	inc zp_bits_hi
.IF FORWARD_DECRUNCHING
skipcarry:
    sec
    eor #$ff
    adc zp_dest_lo
	sta zp_src_lo
	lda zp_dest_hi
	sbc zp_bits_hi
	sbc tabl_hi,y
	sta zp_src_hi
.ELSE
	clc
skipcarry:
	adc zp_dest_lo
	sta zp_src_lo
	lda zp_bits_hi
	adc tabl_hi,y
	adc zp_dest_hi
	sta zp_src_hi
.ENDIF

; -------------------------------------------------------------------
; prepare for copy loop (8(6) bytes)
;
	pla
	tax
.IFNDEF LITERAL_SEQUENCES_NOT_USED
	sec
    .IF FORWARD_DECRUNCHING = 0
pre_copy:
literal_start:
	ldy zp_len_lo
    .ENDIF
	jmp copy_start
.ELSE
	ldy zp_len_lo
	bcc copy_start
.ENDIF

.segment "COREDATA"
; -------------------------------------------------------------------
; two small static tables (6(6) bytes)
;
tabl_bit:
	.byte 2,4,4
tabl_off:
	.byte 48,32,16
; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------

