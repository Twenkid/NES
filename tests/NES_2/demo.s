.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

OAM_DMA    = $4014
; Address ($2006) >> write x2
PPU_ADDR		= $2006
PPU_STATUS = $2002

; 2.3.2023: !!! .segment "CODE" is READ ONLY of course!!! RAM is $0000-$07FF ...!!!
; e.g. $210 etc.!!!

current: .byte $00, $6C, $76, $80, $8A, $94, $9E
move: .byte 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, $6C, 00, 00, 00, $76, 00, 00, 00, $80, 00, 00,00,  $8A, 00, 00, 00,  $94

.macro VramReset
  bit PPU_STATUS
  lda #0
  sta PPU_ADDR
  sta PPU_ADDR
.endmacro

.proc LoadSprites
    ;  rts
  ldx #0
  ;:lda hello, x
  :lda current, x
  sta $0200, x
  inx
  bne :-
  rts
.endproc


reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop
  jsr LoadSprites ;//////

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:
;  .repeat 4, K ;0,1,2,3?
;    stx $210 + (4*K) + 1
;    stx $220 + (4*K) + 1
;    stx $230 + (4*K) + 1
;    stx $240 + (4*K) + 1
;    inx
;  .endrep    
;   .repeat 4, K ;0,1,2,3?
;   stx hello + (4*K) +2 
;   stx hello + (4*K) +3 
;    stx hello + (4*K) + 1
  ;  stx $hello + $10 + (4*K) + 1
  ;  stx $hello + $20 + (4*K) + 1
  ;  stx $hello + $30 + (4*K) + 1    
 ;   inx    
 ; .endrep

  jmp forever

nmi:
  ldx #$00; ;hello ; #$00 	; Set SPR-RAM address to 0
  stx $2003
  ldy #$00
  ldy #0 ;for current, move
;@loop:	lda hello, x
@loop:	lda toshko, x
    ;ldx 1 NO LDX,1!
;  .repeat 4, K ;0,1,2,3?
;    stx $210 + (4*K) + 1
;    stx $220 + (4*K) + 1
;    stx $230 + (4*K) + 1
;    stx $240 + (4*K) + 1
;    inx
;  .endrep    
 ;  .repeat 4, K ;0,1,2,3?
   ;stx hello + (4*K) +2 
   ;stx hello + (4*K) +3 
 ;   ldy hello + (4*K) + 1
;    iny
 ;   sty hello + (4*K) + 1
   ; stx $hello + $10 + (4*K) + 1
   ; stx $hello + $20 + (4*K) + 1
   ; stx $hello + $30 + (4*K) + 1          
;  .endrep
  ;ldx 1
  ;ldy hello + 8 + 1
  ;iny 
  ;sty hello + 8 + 1
  ;ldy hello + 12 + 1
  ;iny 
  ;sty hello + 12 + 1

  ;lda hello, x 	; Load the hello message into SPR-RAM
  ;adc #$01
  sta $2004
  inx

 ;#1 
  lda toshko,x
  sta $2004
  inx
 ;#2
 
  lda toshko,x
  sta $2004
  inx
 ;#3  
  ;lda hello,x  
  ;lda move,x
  ;lda $210,y
  lda $200,y
  adc #1  
  ;adc #8
  ;sta move,x
  ;lda move
  sta $200,y   
  ;adc move,y
  ;sta current,y
  ;sta $2004
  ;txa
  ;lsr
  sta $2004
  ;tax
  ;sta hello,x
  inx
  iny  
  cpx #$1c
  ;cpx #$01
  bne @loop

  ;lda #$02
  ;sta OAM_DMA
  ;VramReset
  rti

hello: ;PPU OAM  https://www.nesdev.org/wiki/PPU_OAM
  .byte $00, $00, $00, $00 	; Why do I need these here?
  .byte $00, $00, $00, $00
  .byte $6c, $00, $00, $6c  ; Y-1 top, , , X left
  .byte $6c, $01, $00, $76
  .byte $6c, $02, $00, $80
  .byte $6c, $02, $00, $8A
  .byte $6c, $03, $00, $94

toshko: ;PPU OAM  https://www.nesdev.org/wiki/PPU_OAM
  .byte $00, $00, $00, $00 	; Why do I need these here?
  .byte $00, $00, $00, $00
  .byte $6c, $04, $00, $6c  ; Y-1 top, , , X left
  .byte $6c, $03, $00, $76
  .byte $6c, $05, $00, $80
  .byte $6c, $06, $00, $8A
  .byte $6c, $03, $00, $94

palettes:
  ; Background Palette
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $66, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

; Character memory
.segment "CHARS"
  .byte %11000011	; H (00)
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; E (01)
  .byte %11111111
  .byte %11000000
  .byte %11111100
  .byte %11111100
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000000	; L (02)
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110	; O (03)
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111	; T (04)
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11011011	; Ш (05)
  .byte %11011011
  .byte %11011011
  .byte %11011011
  .byte %11011011
  .byte %11011011
  .byte %11011011
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000110	; К (06)
  .byte %11001100
  .byte %11011000
  .byte %11110000
  .byte %11110000
  .byte %11011000
  .byte %11001110
  .byte %11000110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

;тошко = 04, 03, 05, 05, 03

