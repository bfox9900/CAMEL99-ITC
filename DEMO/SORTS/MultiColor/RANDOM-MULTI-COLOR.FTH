\ fill screen with random color dots

NEEDS MCHAR   FROM DSK1.MULTIMODE
NEEDS DUMP    FROM DSK1.LOWTOOLS
NEEDS CHARSET FROM DSK1.CHARSET
NEEDS RND     FROM DSK1.RANDOM
NEEDS VALUE   FROM DSK1.VALUES


DECIMAL

48 CONSTANT MAXROW
64 CONSTANT MAXCOL

\ : MCHAR  ( color col row --)
\    2DUP ]NAME VC@ ]PATTERN DUP>R VC@  NYBBLES  R> VC! ;

: MCHAR@ ( col row -- color)
    2DUP ]NAME VC@ ]PATTERN DUP>R  VC@ NYBBLES R> VC@ 4 RSHIFT ;

: XY>VDP  ( COL ROW -- N) MAXCOL *  + ;
: >XY  ( Vaddr -- col row ) MAXCOL /MOD ;

: MC@   ( Vaddr -- color) >XY MCHAR@ ;
: MC!   ( color Vaddr -- ) >XY MCHAR ;

: FILLSCREEN
    MULTICOLOR
    MAXROW 0
    DO
        MAXCOL 0
        DO
           17 RND I J MCHAR
        LOOP
    LOOP
;

DECIMAL
: 1.35/  ( n -- n' )  100 135 */ ; \ 1.35: 2000 @ 39.38sec

: XCHG  ( addr1 addr2 -- ) 2DUP MC@ SWAP MC@  ROT MC! SWAP MC! ;

VARIABLE SORTED
0 VALUE GAP

DECIMAL
: COMBSORTBYTE ( addr n -- )
    DUP>R  TO GAP                   \ save n on Rstack and in GAP
    BEGIN
      GAP 1.35/ TO GAP              \ re-compute the gap
      SORTED ON
      R@ ( -- n) GAP -  0           \ n-gap is loop limit
      DO ( -- addr )
         DUP I +  DUP GAP +  ( -- addr1 addr2 )
         OVER MC@ OVER MC@ >             \ compare the contents of cells
         IF
            XCHG                     \ Exchange the data in the cells
            SORTED OFF               \ flag we are not sorted
         ELSE
           2DROP
         THEN
      LOOP
      SORTED @  GAP 0=  AND          \ test for complete
   UNTIL
   R> 2DROP
;

: RUN
    1234 SEED !
    FILLSCREEN
 \   0  MAXROW MAXCOL * 1-  COMBSORTBYTE
    BEGIN KEY? UNTIL

    1 0 MCHAR@
    2 0 MCHAR@
    3 0 MCHAR@
    4 0 MCHAR@

    TEXT
    CHARSET
;
