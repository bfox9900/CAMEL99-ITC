\ BANNER   for Ti-99  CAMEL99 Forth    Brian Fox

\ The VDP Pattern Descriptor Table (PDT) has all the bit patterns 
\ for the ASCII chars in the system
\ So read them directly from the pattern descriptor table (PDT)

NEEDS CHARDEF FROM DSK1.GRAFIX

HEX
007E 7E7E 7E7E 7E00 PATTERN: CSHAPE

DECIMAL
CSHAPE 159 CHARDEF

: VBANNER ( str len -- )
    8 0 DO  CR                       ( str len)
        2DUP BOUNDS ?DO              ( . .)
            I C@ 
            ]PDT J +  VC@       \ PDT char, byte# J from VDP RAM
            2 7 DO                   \ from bit# 7 to 2
                DUP 1 I LSHIFT AND   \ mask out each bit
                IF    [CHAR] * EMIT  \ if true emit a character
                ELSE  SPACE          \ else print space
                THEN
            -1 +LOOP  DROP           ( . .)
        LOOP                         ( str len)
    LOOP  2DROP ;


HEX
: TEST
      PAGE
\      17 7 VWTR
      BEGIN
        S" TI-99" VBANNER
        S" Chars" VBANNER
        S"  "     VBANNER
        S" UPPER" VBANNER
        S" lower" VBANNER
        S" ( * )" VBANNER
        S"  "       VBANNER
        S" !@#$%^" VBANNER
        S"  "      VBANNER
        S" Cool!"  VBANNER
      ?TERMINAL
      UNTIL ;

\  Thanks to Marcel Hendrix.
