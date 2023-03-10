; Plays a scale using pulse wave and triangle waves. See:
; http://wiki.nesdev.com/w/index.php/APU_basics
; https://web.archive.org/web/20200202131408/http://blargg.8bitalley.com/parodius/nes-code/apu_scale.s
;
; The code header and footer were corrected by Twenkid/Todor Arnaudov, 26.2.2023, because
; the original either: did not compile properly (VECTOR segment overlapped ROM by 6
; bytes)
; or after a small fix (removal of 0s) FCEUX did not recognize the ROM format; 
; NESten also did not recognize the
; Corrections:
; * Added segment HEADER from NESHacker example demo.s:
;   https://github.com/NesHacker/DevEnvironmentDemo
; * Removed the 3 0s from the VECTOR segment:
;   .word 0,0,0, nmi, reset, irq --> .word nmi, reset, irq

; Original:
; ca65 apu_scale.s
; ld65 -t nes apu_scale.o -o apu_scale.nes
; This one:
; ca65 apu2.s
; ld65 -t nes apu2.o -o apu2.nes

.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

; Main code segment for the program
.segment "CODE"

reset:
	; Since we only use APU, we don't need to
	; initialize anything else
	jsr init_apu
	
	ldy #20
	jsr delay_y_frames
	
	jsr play_pulse_scale
	jsr play_tri_scale
	
forever:
	jmp forever

play_pulse_scale:
	ldx #20
:       jsr play_pulse_note
	inx
	cpx #32
	bne :-
	rts

play_pulse_note:
	lda periodTableHi,x
	sta $4003
	
	lda periodTableLo,x
	sta $4002
	
	; Fade volume from 15 to 0
	ldy #15
:       tya
	ora #%10110000
	sta $4000
	jsr delay_frame
	dey
	bpl :-
	
	rts

play_tri_scale:
	ldx #20
:       jsr play_tri_note
	inx
	cpx #32
	bne :-
	rts

play_tri_note:
	; Halve period, since triangle is octave lower
	lda periodTableHi,x
	lsr a
	sta $400B
	
	lda periodTableLo,x
	ror a
	sta $400A
	
	; Play for 8 frames, then silence for 8 frames
	lda #%11000000
	sta $4008
	sta $4017
	
	ldy #8
	jsr delay_y_frames
	
	lda #%10000000
	sta $4008
	sta $4017
	
	ldy #8
	jsr delay_y_frames
	
	rts

; NTSC period table generated by mktables.py. See
; http://wiki.nesdev.com/w/index.php/APU_period_table
periodTableLo:
  .byt $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byt $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byt $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byt $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byt $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byt $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byt $1f,$1d,$1b,$1a,$18,$17,$15,$14

periodTableHi:
  .byt $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byt $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byt $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00

; Initializes APU registers and silences all channels
init_apu:
	lda #$0F
	sta $4015
	
	ldy #0
:       lda @regs,y
	sta $4000,y
	iny
	cpy #$18
	bne :-
	
	rts
@regs:
	.byte $30,$7F,$00,$00
	.byte $30,$7F,$00,$00
	.byte $80,$00,$00,$00
	.byte $30,$00,$00,$00
	.byte $00,$00,$00,$00
	.byte $00,$0F,$00,$C0

; Delays Y/60 second
delay_y_frames:
:       jsr delay_frame
	dey
	bne :-
	rts

; Delays 1/60 second
delay_frame:
	; delay 29816
	lda #67
:       pha
	lda #86
	sec
:       sbc #1
	bne :-
	pla
	sbc #1
	bne :--
	rts

; Hang if these somehow get activated, so we know about it
nmi:    jmp nmi
irq:    jmp irq

;.segment "HEADER"
;	.byte "NES",26, 2,1, 0,0 ; 32K PRG 8K CHR
;	.byte 0,0,0,0,0,0,0,0

;.segment "VECTORS"
;	.word 0,0,0, nmi, reset, irq
.segment "VECTORS"
	.word nmi, reset, irq

.segment "STARTUP" ; eliminates warning

.segment "CHARS"
	.res $2000
