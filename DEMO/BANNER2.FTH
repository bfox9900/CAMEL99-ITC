\ BANNER   for Ti-99  CAMEL99 Forth    Brian Fox

\ The VDP Pattern Descriptor Table (PDT) has all the bit patterns
\ for the ASCII chars in the system
\ So we can read them directly from the pattern descriptor table (PDT)

NEEDS CHARDEF FROM DSK1.GRAFIX

DECIMAL


: TYPE.BIG ( str len -- )
  8 0 DO  CR                       \ index the 8 bytes of character pattern
        2DUP BOUNDS
        ?DO                         \ index the string char by char
            I C@ ]PDT               \ get pattern for the character in string
            J +  VC@                \ get 'Jth' byte of the pattern from VRAM
            2 7                     \ index the bits in the pattern byte
            DO                      \ from bit# 7 to 2
                DUP 1 I LSHIFT AND  \ mask out each bit
                IF    159 EMIT      \ if bit=1 emit the square character
                ELSE  SPACE         \ else print space
                THEN
            -1 +LOOP                \ index backwards
            DROP
        LOOP
  LOOP
  2DROP
;

HEX
: TEST
     GRAPHICS
     S" 007E7E7E7E7E7E00" 159 CALLCHAR \ small square character
     \ 1st  2nd
     \ set# set#  fg bg
        4     24   5  1 COLORS    \ set a range of colorsets
      BEGIN
        S" TI-99" TYPE.BIG
        S" Chars" TYPE.BIG
        S"  "     TYPE.BIG
        S" UPPER" TYPE.BIG
        S" lower" TYPE.BIG
        S" ( * )" TYPE.BIG
        S"  "     TYPE.BIG
        S" ! @ #" TYPE.BIG
        S"  "     TYPE.BIG
        S" Cool!" TYPE.BIG
        S"  "     TYPE.BIG
        S" Press" TYPE.BIG
        S" FCTN"  TYPE.BIG
        S"  4"    TYPE.BIG
        S"  TO"   TYPE.BIG
        S" STOP"  TYPE.BIG
        S" THIS"  TYPE.BIG
        S" THING" TYPE.BIG
        S" ..."   TYPE.BIG
        ?TERMINAL
      UNTIL ;

\  Thanks to Marcel Hendrix.
