\ Translate a hard BASIC program to FORTH  Mar 2025 Fox 

\ X BASIC's sub functions provides local variables. 
\ Without local variable we must stack operations
\ This version uses non-standard light-weight locals system
\ I call CHEAPLOCALS 
\ Local variables live on the return stack and must be
\ predefined to provide a name.

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
NEEDS LOCAL:     FROM DSK1.CHEAPLOCALS

DECIMAL 
1 LOCAL: X1 
2 LOCAL: X2
3 LOCAL: Y1
4 LOCAL: Y2
5 LOCAL: C 

: BOX   ( x1 y1 x2 y2 char -- ) \ 1120 sub box(x1,y1,x2,y2,c)
 5 LOCALS 
    C ! Y2 ! X2 !  Y1 ! X1 !    \ store stack to locals 
    BEGIN 
        Y2 @ 1+ Y1 @ >          \ for y=y1 to y2
    WHILE
                                \ call hchar(y,x1,c,x2-x1+1)
        X1 @  Y1 @  C @  X2 @ X1 @ -  HCHAR  
        Y1 1+!                  \  next y
    REPEAT     
 /LOCALS 
;                               \ 1160 subend

: RUN
    GRAPHICS 

    CLEAR                  \ call clear
    6 SCREEN               \ call screen(6)
    S" 30C0030C30C0030C0C03C0300C03C030" 126 CALLCHAR
\   x  y    x  y   char      
    3  8   28  10  126 BOX
    9 12   22  17  127 BOX
    BEGIN ?TERMINAL UNTIL  \ goto 112  
    
    TEXT 
;
