\ VDPDRVR.HSF  text ouput to the TI-99 screen      Jan 2022 B Fox

[CC] cr .( Console output)

HEX
[TC]
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
: SCROLL ( buffer vaddr -- )
       PAUSE
       HERE 100 +     \ grab some space above Forth PAD
       TOPLN C/SCR @  ( -- buffer Vstart len)
       BOUNDS  ( -- buffer SCRend SCRstart)
       DO
         I  C/L@ +  OVER  C/L@ 4* VREAD
         DUP  I           C/L@ 4* VWRITE
       C/L@ 4* +LOOP
       DROP
       0 17 2DUP AT-XY >VPOS C/L@ BL VFILL
;

[cc] HEX [tc]
:  CR    ( -- )  (CR) L/SCR = IF  SCROLL  THEN  ;
: (EMIT) ( char -- ) CPUT IF  CR  THEN ;
: PAGE   ( -- ) TOPLN LASTLN OVER -  BL VFILL   0 0 AT-XY ;
: BS     ( --)  VCOL DUP @ 1- 0 MAX  SWAP ! ;

: EMIT   ( char -- )  \ shows how to handle control characters
          PAUSE
          DUP 0D = IF  DROP CR     EXIT THEN
          DUP 08 = IF  DROP BS     EXIT THEN
          (EMIT) ;

[PRIVATE]
: (TYPE)  0 ?DO   COUNT (EMIT) LOOP ;

[PUBLIC]
: TYPE ( addr cnt -- ) PAUSE (TYPE) DROP ;

[CC] T' TYPE  RESOLVES 'TYPE  [TC]

: SPACE  ( -- )   BL (EMIT) ;
: SPACES ( n -- ) 0 MAX  0 ?DO  SPACE  LOOP ;


[cc] cr .( Character input)
\ ======================================================================
\ C H A R A C T E R   I N P U T
\ *G Cursor flash control is now done by reading the 9901 timer.
\ ** It counts down from >3FFF in 349mS. If the timer> 1FFF we show the cursor.
\ ** If < 1FFF show the screen char. Flash rate is about 2 per second.

TARGET-COMPILING
: KEY      ( -- char)
           BEGIN                  \ start the loop
              PAUSE               \ Essential for Multi-tasking with Console
              CURS @              \ fetch 2 char cursor (space & _ )
              TMR@ 1FFF <         \ compare hardware timer to 1FFF
              IF >< THEN VPUT     \ swap cursor bytes & write
              KEY?                \ check the keyboard
              ?DUP                \ DUP IF <> 0
            UNTIL                 \ loop until a key pressed
            BL VPUT ;             \ put the space char on screen


\ ======================================================================
\ T I - 9 9   T E X T   M O D E   C O N T R O L
TARGET-COMPILING

\ TCREATE: 40COL
\            VR0   VR1    VR2    VR3    VR4    VR5    VR6    VR7
\   08 TC,  00 TC, F0 TC, 00 TC, 0E TC, 01 TC, 06 TC, 02 TC, 17 TC, TALIGN
\ : VREGS    ( Caddr  -- ) COUNT 0 DO  COUNT I VWTR  LOOP DROP ;

: TEXT    ( -- )
         F0 DUP  1 VWTR  83D4 C!
              0  2 VWTR  \ set VDP screen page
               VTOP OFF  \ topline VDP offset
               VPG  OFF  \ VDP screen page offset
             E0 7 VWTR  \ sets FG & BG color
                28 C/L!
              0 0 AT-XY
               2 VMODE !   \ 2=ID for 40 column "TEXT" mode
               PAGE
;
