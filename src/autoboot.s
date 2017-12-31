.include "diskio.inc"
.include "irq.inc"
.include "zp.inc"
.include "title.inc"
.include "sound.inc"

CHROUT          = $ffd2
READY           = $a474

.import __TCODE_LOAD__
.import __MAIN_LOAD__

.segment "BOOT"

                .word   $02c1           ; load address for binary
                .assert *=$02c1, error  ; check linker placed us correctly

; BASIC header -- must be here if loaded with ",8" only
ab_basichdr:
                .word   $080a           ; next basic line, in "LOADER"
                .word   $17             ; 23
                .byte   $9E             ; SYS
                .byte   "2154", 0
                .word   0               ; placed at $080a in "LOADER"
ab_basichdrlen	= *-ab_basichdr

; show what is loading:
ab_loadmsg:     .byte   " 8192 game..."
ab_loadmsglen   = *-ab_loadmsg
ab_load:        ldx     #$100 - ab_loadmsglen
ab_loop:        lda     ab_loadmsg - $100 + ab_loadmsglen,x
                jsr     CHROUT
                inx
                bne     ab_loop
                lda     #<loader        ;change end of file to start adress
                sta     $ae             ;of the main code
                sta     $326		;also hijack CHROUT
                rts

; entry of hijacked STOP routine
                .assert *=$02ed, error
                lda     #$f6    ;repair stop check vector right away (only the
                sta     $329    ;hi-byte was altered, that's why *=$02ed)
                jsr     ab_load		;load message
                lda     #>loader
                sta     $af
                sta     $327
                jmp     $f6ed   ;jump back to normal loading routine
                .byte	$00

;the system vectors at $300-$327 must remain intact to allow normal basic/kernal
;operation and therefore the loader must contain the proper bytes for these:

                .assert *=$0300, error  ;the vector table for basic/kernal
                .word $e38b     ;$300 vector: print basic error message ($e38b)
                .word $a483     ;$302 vector: basic warm start ($a483)
                .word $a57c     ;$304 vector: tokenize basic text ($a57c)
                .word $a71a     ;$306 vector: basic text list ($a71a)
                .word $a7e4     ;$308 vector: basic char. dispatch ($a7e4)
                .word $ae86     ;$30a vector: basic token evaluation ($ae86)
                .byte 0,0,0,0   ;$30c temp storage cpu registers

                jmp $b248       ;$310 usr function, jmp+address
                .byte 0         ;$313 unused

                .word $ea31     ;$314 Vector: Hardware Interrupt ($ea31)
                .word $fe66     ;$316 Vector: BRK Instr. Interrupt ($fe66)
                .word $fe47     ;$318 Vector: Non-Maskable Interrupt ($fe47)
                .word $f34a     ;$31a kernal open routine vector ($f34a)
                .word $f291     ;$31c kernal close routine vector ($f291)
                .word $f20e     ;$31e kernal chkin routine ($f20e)
                .word $f250     ;$320 kernal chkout routine ($f250)
                .word $f333     ;$322 kernal clrchn routine vector ($f333)
                .word $f157     ;$324 kernal chrin routine ($f157)

                .word $f1ca     ;$326 kernal chrout routine ($f1ca)
                ;hijack STOP here:
                .word $02ed     ;$328: kernal stop routine Vector ($f6ed)

.segment "LOADER"

loader:
                .assert *=$086a, error  ; check linker placed us correctly
                lda     #$f1
                cmp     $327
                beq     chainload            ; no autostart

                ; repair CHROUT vector
                sta     $327
                lda     #$ca
                sta     $326

                ; forget the (bogus) return address
                pla
                pla

                ; and instead use the "READY." routine
                lda     #>(READY-1)
                pha
                lda     #<(READY-1)
                pha

		ldx	#$100 - ld_donelen
ld_doneloop:	lda	ld_done - $100 + ld_donelen,x
		jsr	CHROUT
		inx
		bne	ld_doneloop

                ; copy BASIC header to correct location ($801)
                ldx     #ab_basichdrlen
ld_hdrcopyloop: lda     ab_basichdr-1,x
                sta     $0800,x
                dex
                bne     ld_hdrcopyloop

chainload:
		jsr	dio_init
		sei
		jsr	zp_init
		jsr	irq_early_init
		cli
		lda	#<filename
		ldy	#>filename
		jsr	dio_setname
		lda	#<__TCODE_LOAD__
		ldy	#>__TCODE_LOAD__
		jsr	dio_loadarchive
		jsr	snd_init
		jsr	irq_nextstate
		jsr	dio_loadbitmap
		lda	#<__MAIN_LOAD__
		ldy	#>__MAIN_LOAD__
		jsr	dio_loadarchive
		jsr	dio_endloadarchive
		lda	#<datafilename
		ldy	#>datafilename
		jsr	dio_setname
		jsr	dio_loadgamedat
		jsr	title_loop
		jmp	__MAIN_LOAD__


.segment "COREDATA"

ld_done:	.byte	" done.", $0d
ld_donelen	= *-ld_done

filename:	.byte	"8192main", $00
datafilename:	.byte	"8192data", $00

