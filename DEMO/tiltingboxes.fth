\ Translate a BASIC program to FORTH  Feb 2024 Fox

\ 1 ! TILTED BOXES ILLUSION
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

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS GRAPHICS   FROM DSK1.GRAFIX

DECIMAL
\ this string re-defines the shape of character 126 and 127

\ X BASIC's sub functions provides local variables. We have to do
\ a lot more work to make BOX without local variable support.
\ We can use PICK to reach into the stack to get arguments
\ and the return stack for temporary storage.

\ convert x,y coordinates to VDP address, height and length
( x,y,c,len)
\ resorted to 1 temp variable :-(
VARIABLE CHR
: HORZCHAR ( x y len)  CHR @ SWAP HCHAR ;
: LENGTH   ( x1 x2 -- X1 LEN ) OVER - ;

\ this took much more effort in Forth. :-)
: BOX   ( x1 y1 x2 y2 char -- )
      CHR !         ( x1 y1 x2 y2 )
      ROT           ( x1 x2 y2 y1 )
      2SWAP         ( y2 y1 x1 x2 )
      LENGTH        ( y2 y1 x1 len)
      1+ 2SWAP      ( x1 len y2 y1)
      0 DO          ( x1 len )
         2DUP       ( x1 len x1 len)
         I SWAP HORZCHAR
      LOOP
      2DROP DROP
;

: RUN
    GRAPHICS                     \ switch to Graphics 1

    CLEAR                        \ 100 call clear
    6 SCREEN                     \ 102 call screen(6)
\ 103 call char(33,"30C0030C30C0030C0C03C0300C03C03")
    S" 30C0030C30C0030C0C03C0300C03C030" 126 CALLCHAR
\   x  y    x  y   char
    3  8   28  10  126 BOX      \ 110 call box(4,9,29,11,33)
    9 12   22  17  127 BOX      \ 111 call box(10,13,23,18,34)

    BEGIN  ?TERMINAL  UNTIL     \ 112 goto 112 with BREAK detect

    TEXT
;
