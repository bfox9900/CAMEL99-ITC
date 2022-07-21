\ Translate a BASIC program to FORTH

\ 100 call clear
\ 102 call screen(6)
\ 103 call char(33,"30C0030C30C0030C0C03C0300C03C03")
\ 110 call box(4,9,29,11,33)
\ 111 call box(10,13,23,18,34)
\ 112 goto 112
\ 1120 sub box(x1,y1,x2,y2,c)
\ 1130     for y=y1 to y2
\ 1140         call hchar(y,x1,c,x2-x1+1)
\ 1150     next y
\ 1160 subend

\ NEEDS DUMP     FROM DSK1.TOOLS
NEEDS GRAPHICS   FROM DSK1.GRAFIX

\ The temptation is to write this using HCHAR like BASIC.
\ Forth has more functions than BASIC like AT-XY.
\ Good Forth style says to partition the program into small, named, components.
\ The names should be well chosen and the code simple enough that it is
\ easy to understand.

DECIMAL
S" 30C0030C30C0030C0C03C0300C03C030" 126 CALLCHAR

: LSLASH    126 EMIT ;
: RSLASH    127 EMIT ;

: /SLASHES  ( col row len ) -ROT AT-XY   0 ?DO  LSLASH  LOOP ;
: \SLASHES  ( col row len ) -ROT AT-XY   0 ?DO  RSLASH  LOOP ;

: BOX1   ( col row -- )
             2DUP  14 /SLASHES
          1+ 2DUP  14 /SLASHES
          1+ 2DUP  14 /SLASHES
          1+       14 /SLASHES ;

: BOX2   ( col row -- )
             2DUP  24 \SLASHES
          1+ 2DUP  24 \SLASHES
          1+ 2DUP  24 \SLASHES
          1+       24 \SLASHES
;

: RUN
      CLEAR
      6 SCREEN
      7  8 BOX1
      3 13 BOX2
      BEGIN ?TERMINAL UNTIL
;
