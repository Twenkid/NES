# NES
NES Development - Nintendo Entertainment System, Famicom, 8-bit Nintendo Video Game, Home Console ... 

26.2.2023: /tests/apu2.s

Plays a scale using pulse wave and triangle waves. See:
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



12.2.2025

Calls:
C:\cc65\bin\ca65.exe
C:\cc65\bin\ld65.exe
C:\Guz\Nesten\

; Original:
; ca65 apu_scale.s
; ld65 -t nes apu_scale.o -o apu_scale.nes
; This one:
; ca65 apu2.s
; ld65 -t nes apu2.o -o apu2.nes
