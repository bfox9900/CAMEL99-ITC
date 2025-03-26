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

HEX
CODE LOCALS ( n --) \ build a stack frame n cells deep
  C007 ,  \ RP R0 MOV,  ( DUP return stack pointer in R0)
  0A14 ,  \ TOS 1 SLA,  ( CELLS )
  61C4 ,  \ TOS RP SUB, ( allocate space on Rstack)
  0647 ,  \ RP DECT,    ( make room for the old RP)
  C5C0 ,  \ R0 RPUSH,   ( push old RP onto top of frame )
  C136 ,  \ TOS POP,
  NEXT,
ENDCODE

\ collapse stack frame: 
CODE /LOCALS  ( -- ) 
  C1D7 ,  \ *RP RP MOV, 
  NEXT,  
ENDCODE

: LOCAL:  ( n -- ) \ name some local variables
  CREATE  CELLS ,  \ record the cell offset for this local
  ;CODE
    0646 ,  \ make space on the DATA stack 
    C584 ,  \ TOS PUSH,     
    C107 ,  \ RP TOS MOV,   
    A118 ,  \ *W TOS ADD,
    NEXT,
  ENDCODE

1 LOCAL: X1 
2 LOCAL: X2
3 LOCAL: Y1
4 LOCAL: Y2
5 LOCAL: C 

: TEST  ( n n n n n == ) 
  5 LOCALS 
    C !  Y2 ! X2 !  Y1 ! X1 !    \ store stack to locals 
    CR C ?
    CR Y2 ?  X2 ? Y1 ? X1 ? 
  /LOCALS 
;

: BOX   ( x1 y1 x2 y2 char -- ) \ 1120 sub box(x1,y1,x2,y2,c)
  5 LOCALS 
    C ! Y2 ! X2 !  Y1 ! X1 !    \ store stack to locals 
    
    BEGIN 
        Y2 @ Y1 @ <>            \ for y=y1 to y2
    WHILE
                                \ call hchar(y,x1,c,x2-x1+1)
        Y1 @ X1 @ C@  X2 @ X1 @ 1+ - HCHAR  
        Y1 1+!                  \  next y
    REPEAT     
    /LOCALS 
;                \ 1160 subend

: RUN
    PAGE ." * Tilted Boxes Illusion *"
    S" 30C0030C30C0030C0C03C0300C03C030" 126 CALLCHAR
    6 SCREEN
\       x  y    x  y   char      
        6  3   16  7   127 BOX
        4 10   20 15   126 BOX
    BEGIN ?TERMINAL UNTIL
    TEXT 
;
