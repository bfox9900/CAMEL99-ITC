\ HILITE.FTH    updated Mar 25 2025
\ create reverse color character set
\ INCLUDE DSK1.TOOLS

HEX
: ]PDT   ( char# -- 'pdt[n] ) 8* 800 + ; \ VDP pattern Descriptor table

400 CONSTANT 1K

: INVERTFONT ( -- )
      0 ]PDT 1K
      BOUNDS             \ loop thru pattern table byte by byte
      DO
        I VC@ INVERT  I 1K +  VC! \ invert char patterns in VDP RAM 
      LOOP
;

\ use this word at the start of your program 
INVERTFONT    ( change the VDP memory)

\ *permanent routines*
\ Type a string with reversed colors
  : HITYPE ( addr len --)   BOUNDS DO   I  C@ 80 OR (EMIT)   LOOP ;

\ These operate on the VDP screen only. The original strings are not changed
  : HILITE  ( Vaddr len --) BOUNDS DO   I VC@ 80 OR  I VC!   LOOP ;
  : NORMAL  ( Vaddr len --) BOUNDS DO   I VC@ 7F AND I VC!   LOOP ;
  : REVERSE ( Vaddr len --) BOUNDS DO   I VC@ 80 XOR I VC!   LOOP ;

\ test code ........................................
: .HICHARS CR  FF 80 DO I EMIT LOOP ;
: .LOCHARS CR  80 0  DO I EMIT LOOP ;

DECIMAL
 : BLINKER  ( Vaddr len -- ) BEGIN  2DUP REVERSE  500 MS  KEY? UNTIL 2DROP ;

: TEST  PAGE ." This string will print normally"
          CR ." This will be reversed in 3 seconds"
          CR
          CR ." This one will blink"

          0 23 AT-XY ." Press a key to stop demo"
          3000 MS

      \   X Y       len
          0 1 >VPOS 34 REVERSE
          0 3 >VPOS 19 BLINKER
;

.LOCHARS 
.HICHARS