\ Dutch flag DEMO using CAMEL99 Forth using Dijkstra's Algorithm
\ *SORTS IN PLACE FROM Video MEMORY*

\ Compare this version to dijkstra.fth
\ This code uses INLINE optimizer for a real speedup

 INCLUDE DSK1.TOOLS   ( for debugging)
 INCLUDE DSK1.GRAFIX
 INCLUDE DSK1.RANDOM
 INCLUDE DSK1.CASE
 INCLUDE DSK1.ELAPSE
 INCLUDE DSK1.INLINE


\ TMS9918 Video chip Specific code
HEX
CREATE SQUARE  FFFF , FFFF , FFFF , FFFF ,

\ define colors and characters
DECIMAL
24 32 *  CONSTANT SIZE     \ flag will fill GRAPHICS screen
SIZE 3 / CONSTANT #256     \ 256 chars per segment of flag
1        CONSTANT REDSQR   \ red character
9        CONSTANT WHTSQR   \ white character
19       CONSTANT BLUSQR   \ blue character
28       CONSTANT PTR1

\ color constants
1        CONSTANT TRANS
7        CONSTANT RED
5        CONSTANT BLU
16       CONSTANT WHT

SQUARE REDSQR CHARDEF
SQUARE BLUSQR CHARDEF
SQUARE WHTSQR CHARDEF
SQUARE PTR1   CHARDEF

\ charset  FG    BG
  0        RED TRANS COLOR
  1        WHT TRANS COLOR
  2        BLU TRANS COLOR

\ screen fillers
: RNDI    ( -- n ) SIZE 1+ RND ; \ return a random VDP screen address

: NOTRED    (  -- n ) \ return rnd index that is not RED
           BEGIN
           RNDI  INLINE[ DUP VC@ REDSQR = ]
           WHILE
             DROP
           REPEAT ;

: NOTREDWHT    ( -- n ) \ return rnd index that is not RED or BLU
           BEGIN
             RNDI
             INLINE[ DUP VC@  DUP REDSQR =   SWAP WHTSQR = OR ]
           WHILE
              DROP
           REPEAT ;

: RNDRED  (  -- ) \ Random RED on VDP screen
          #256 0 DO   REDSQR NOTRED VC!   LOOP ;

: RNDWHT (  -- ) \ place white where there is no red or white
          #256 0 DO   WHTSQR NOTREDWHT VC!   LOOP ;

: BLUSCREEN ( -- )
          INLINE[ 0 768 BLUSQR ] VFILL ;

\ load the screen with random red,white&blue squares
: RNDSCREEN ( -- )
            BLUSCREEN  RNDRED  RNDWHT ;

: CHECKERED  ( -- ) \ red,wht,blue checker board
         SIZE 0
         DO
          INLINE[  BLUSQR I VC! ]
          INLINE[  WHTSQR I 1+ VC! ]
          INLINE[  REDSQR I 2+ VC! ]
         3 +LOOP ;

\ inlining multiple parameters generates faster code as well.
: RUSSIAN  \ Russian flag
          INLINE[ 0  0 WHTSQR 256 ] HCHAR
          INLINE[ 0  8 BLUSQR 256 ] HCHAR
          INLINE[ 0 16 REDSQR 256 ] HCHAR ;

: FRENCH  \ kind of a French flag
        INLINE[   0  0 BLUSQR 256 ] VCHAR
        INLINE[  10 16 WHTSQR 256 ] VCHAR
        INLINE[  21  8 REDSQR 256 ] VCHAR ;

\ Algorithm Dijkstra(A)  \ A is an array of three colors
\ begin
\   r <- 1;
\   b <- n;
\   w <- n;
\ while (w>=r)
\       check the color of A[w]
\       case 1: red
\               swap(A[r],A [w]);
\                r<-r+1
\       case 2: white
\               w<-w-1
\       case 3: blue
\               swap(A[w],A[b]);
\               w<-w-1;
\               b<-b-1
\ end

: XCHG  ( adr1 adr2 -- )  \ exchange the characters in addresses
  INLINE[  OVER VC@ OVER VC@  SWAP ROT VC! SWAP VC! ]  ;

\ address pointer variables
VARIABLE R
VARIABLE B
VARIABLE W
SIZE 1- CONSTANT n   \ sugar to match the Algorithm

: DIJKSTRA ( -- )
           0 R !
           n B !
           n W !
           BEGIN
              INLINE[ W @  R @ 1- ]  >
           WHILE
              INLINE[ W @ VC@ ]
               CASE
                 REDSQR OF  INLINE[ R @ W @ ] XCHG
                            INLINE[ R 1+! ]
                                              ENDOF

                 WHTSQR OF  INLINE[ W 1-! ]   ENDOF

                 BLUSQR OF  INLINE[ W @ B @ ]  XCHG
                            INLINE[  W 1-!  ]
                            INLINE[  B 1-!  ]
                                              ENDOF
               ENDCASE
           REPEAT ;


: WAIT   11 11 AT-XY ." Finished!" 1500 MS ;

: TITLE  PAGE
         CR ."   DIJKSTRA DUTCHFLAG DEMO 2"
         CR ."   -------------------------"
         CR
         CR ."  Using the 3 colour algorithm"
         CR ."  translated to hi-level Forth"
         CR
         CR ."  Sorted in-place in Video RAM"
         CR ."  using INLINE optimizer."

         0 23 AT-XY ."   Press any key to begin"
         KEY DROP ;

: RUN ( -- ) \ test with different input patterns
         TITLE
         TICKER OFF
         RNDSCREEN  DIJKSTRA \ WAIT
         CHECKERED  DIJKSTRA \ WAIT
         RUSSIAN    DIJKSTRA \ WAIT
         FRENCH     DIJKSTRA \ WAIT
         0 23 AT-XY
         CR ." Completed"
         .ELAPSED
;
