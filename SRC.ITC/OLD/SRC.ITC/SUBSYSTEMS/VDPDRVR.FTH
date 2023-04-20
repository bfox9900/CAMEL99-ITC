\ V D P  S C R E E N   D R I V E R
[CC] cr .( Console output)

HEX [TC]

: C/L!     ( c/l -- )  \ pronounced "SEE-PER-ELL-STORE"
           DUP C/L !           \ set chars per line
           L/SCR *  C/SCR ! ;  \ calc. chars per screen

: VPOS   ( -- vaddr) VROW 2@ >VPOS ;
: VPUT   ( char -- ) VPOS VC! ;
: AT-XY  ( col row -- ) VROW 2! ;  \ set VDP address for Fast type

SLOWER [IF]

    : TOPLN   ( -- vaddr)  VPG @ VTOP @ + ;  \ 10 bytes
    : LASTLN  ( -- vaddr)  VPG @ C/SCR @ + ; \ 10 bytes

[ELSE]

CODE TOPLN ( -- vaddr)
       TOS PUSH,
       VPG @@  TOS MOV,
       VTOP @@ TOS ADD,
       NEXT,
       ENDCODE  \ 12 bytes

CODE LASTLN ( -- vaddr)
       TOS PUSH,
       VPG   @@ TOS MOV,
       C/SCR @@ TOS ADD,
       NEXT,
       ENDCODE  \ 12 bytes
[THEN]

\ =====================================================================
\ *G Scrolling has been implemented in Forth using VREAD & VWRITE
\ ** Uses un-allocated Dictionary as a temporary buffer to hold lines of text

\ Notes: Using SEVENs program as a benchmark
\ Buffer Lines	Sevens Speed
\     1          	01:08.71
\     2           01:02.13  10% faster
: SCROLL ( buffer vaddr -- )
       PAUSE
       HERE 100 +     \ grab some space above Forth PAD
       TOPLN C/SCR @  ( -- buffer Vstart len)
       BOUNDS  ( -- buffer SCRend SCRstart)
       DO
         I  C/L@ +  OVER  C/L@ 2* VREAD
         DUP  I           C/L@ 2* VWRITE
       C/L@ 2* +LOOP
       DROP
       0 17 2DUP AT-XY >VPOS C/L@ BL VFILL
;

\ ======================================================================
\ V D P   T E X T   O U T P U T

[cc] HEX [tc]
:  CR    ( -- )  (CR) L/SCR = IF  SCROLL  THEN  ;
: (EMIT) ( char -- ) CPUT IF  CR  THEN ;
: PAGE   ( -- ) TOPLN LASTLN OVER -  BL VFILL   0 0 AT-XY ;
: BS     ( --)  VCOL DUP @ 1- 0 MAX  SWAP ! ;

: EMIT   ( char -- )  \ shows how to handle control characters
          PAUSE
          DUP 0D = IF  DROP CR   EXIT THEN
          DUP 08 = IF  DROP BS     EXIT THEN
         (EMIT) ;

: TYPE ( addr cnt -- )
    DUP 0= IF  2DROP EXIT  THEN
    0 DO   PAUSE COUNT (EMIT)   LOOP  DROP ;

: SPACE  ( -- )   BL (EMIT) ;
: SPACES ( n -- ) 0 MAX  0 ?DO  SPACE  LOOP ;

CROSS-COMPILING
