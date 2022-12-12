\ HILITE.FTH   create reverse color characters and removes itself
\ INCLUDE DSK1.TOOLS

MARKER /REMOVE             \ put a "bookmark in the dictionary"

NEEDS MALLOC  FROM DSK1.MALLOC
HEX
: ]PDT   ( char# -- 'pdt[n] ) 8* 800 + ; \ VDP pattern Descriptor table

400 CONSTANT 1K

: INVERTFONT ( -- )
      1K MALLOC >R               \ get a 1K buffer
      0 ]PDT R@  1K VREAD        \ copy VDP patterns to RAM
      R@  1K  BOUNDS             \ loop thru 1K byte by byte
      DO
        I DUP C@ INVERT SWAP C!  \ invert char pattern
      LOOP
      R@  80 ]PDT  1K VWRITE     \ write RAM back to VDP upper charset
      R> MFREE ;                 \ release the memory

INVERTFONT    ( change the VDP memory)
 /REMOVE      ( remove the above code from the Forth dictionary)

\ *permanent routines*
\ Type a string with reversed colors
  : HITYPE ( addr len --)   BOUNDS DO   I  C@ 80 OR (EMIT)   LOOP ;

\ These operate on the VDP screen only. The original strings are not changed
  : HILITE  ( Vaddr len --) BOUNDS DO   I VC@ 80 OR  I VC!   LOOP ;
  : NORMAL  ( Vaddr len --) BOUNDS DO   I VC@ 7F AND I VC!   LOOP ;
  : REVERSE ( Vaddr len --) BOUNDS DO   I VC@ 80 XOR I VC!   LOOP ;

\ test code
 : .HICHARS  FF 80 DO I EMIT LOOP ;

DECIMAL
 : BLINKER  ( Vaddr len -- ) BEGIN  2DUP REVERSE  500 MS  KEY? UNTIL 2DROP ;

: TEST  PAGE ." This string will print normally"
          CR   ." This will be reversed in 3 seconds"
          CR
          CR   ." This one will blink"

          0 23 AT-XY ." Press a key to stop demo"
          3000 MS
          0 1 AT-XY VPOS 34 REVERSE

          0 3 AT-XY VPOS 19 BLINKER
 ;
