\ literal translation of BASIC program to Forth

\ FORTH                       V2.78        ITC      DTC v2.69
\ ---------                   -------    ------     ---------
\ V1 literal translation from BASIC       1:26      1:04
\      "          "   with fast scroll    1:14

\ CAMELTTY   4800 BAUD                    0:51
\           38400 BAUD                    0:32

\ ============================================================
\ TI BASIC                               27:20
\ Compiled BASIC                          1:40

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.ARRAYS

\ Scroll ends up being the slowest part of the benchmark.
\ Uncomment the screen I/O code below for a faster driver
\ .......................................................

\ SCROLL entire screen in one block with VMBR and VMBW
 : SCROLL ( -- )
  HERE 100 + DUP>R  VTOP @  ( --  buffer dst) ( r: BUFFER)
  DUP C/L@ + R>             ( -- buffer dst src buffer)
  [ C/SCR @ C/L @ - ] LITERAL DUP>R VREAD  R> VWRITE
  0 23 2DUP >VPOS C/L@ BL VFILL  \ erase bottom line
  AT-XY ;                        \ set cursor

\ this code is the same as the kernel, but with faster scroll
 : CR     (  -- )     VCOL OFF  VROW ++@  L/SCR = IF SCROLL THEN ;
 : (EMIT) ( char -- ) VPOS VC!  VCOL ++@  C/L@ = IF CR THEN ;
\ .......................................................

DECIMAL
: ?BREAK   ?TERMINAL ABORT" *BREAK*" ;

\ must define all data before use
VARIABLE WIN
VARIABLE POWER
VARIABLE NUMLEN
VARIABLE CARRY
VARIABLE INAROW
VARIABLE NDX   ( transfers loop index out of DO LOOP )

 256 CARRAY ]A                  \ 100 DIM A(256)
  0 ]A 256 0 FILL               \ init ]A to zero as DIM does
  ( Forth Arrays are OPTION BASE 0)

: RUN
  CR ." 7's Problem "           \ 110 PRINT "7's Problem"
  7 0 ]A C!                     \ 120 A(1)=7
   WIN OFF                      \ 130 WIN=0
  1 POWER !                     \ 140 POWER=1
  0 NUMLEN !                    \ 150 NUMLEN=1
  BEGIN POWER 1+!               \ 160 POWER=POWER+1
    ." 7 ^" POWER @ . ." IS:"   \ 170 PRINT "7 ^";POWER;"IS:"
    ?BREAK
    CARRY OFF                   \ 180 CARRY=0
    INAROW OFF                  \ 190 INAROW=0
    NUMLEN @ 1+ 0               \ 200 FOR I=1 TO NUMLEN
    DO
        I NDX !                 \ copy I for later
        I ]A C@ 7 *  CARRY @ +  \ 210 A(I)=A(I)*7+CARRY
\ We avoid some math with divide & mod ( UM/MOD ) function
        0 10 UM/MOD  CARRY !    \ 220 CARRY=INT(A(I)/10)
        I ]A C!                 \ 230 A(I)=A(I)-CARRY*10
        I ]A C@ 7 =             \ 240 IF A(I)<>7 THEN 290
        IF
            INAROW DUP 1+!      \ 250 INAROW=INAROW+1
            @ 6 =               \ 260 IF INAROW<>6 THEN 300
            IF
              WIN ON            \ 270 WIN=1
              LEAVE
            THEN
        ELSE                    \ 280 GOTO 300
            INAROW OFF          \ 290 INAROW=0
        THEN
    LOOP                        \ 300 NEXT I

    CARRY @
    DUP NDX @ 1+ ]A C!          \ 310 A(I)=CARRY
    IF                          \ 320 IF CARRY=0 THEN 340
        NUMLEN 1+!              \ 330 NUMLEN=NUMLEN+1
    THEN
    CR                          \ replaces PRINT
    0 NUMLEN @                  \ 340 FOR I=NUMLEN TO 1
    DO
      I ]A C@ 48 + EMIT     \ 350 PRINT CHR$(A(I)+48);
    -1 +LOOP                    \ 360 NEXT I ( STEP -1)
    CR CR                       \ 370 PRINT ::
    WIN @                       \ 380 IF WIN<>1
  UNTIL                         \     THEN 160
  ." Winner is 7 ^" POWER @ .   \ 390 PRINT "WINNER IS 7 ^";POWER
;                               \ 420 END
