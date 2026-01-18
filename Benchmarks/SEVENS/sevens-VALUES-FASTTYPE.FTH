\ literal translation of a BASIC version of the sevens problem Brian Fox
\ Original BASIC program from Atariage.com

\ *V2.73 Camel99 uses a smaller but slower VDP driver.

\                                   v2.73  ITC      DTC
\ V1 using variables and ARRAY:           1:20.9   1:04
\ V2 replaced variables with VALUES:      1:19.8   1:01
\ V3 print with address loop, not indices          1:00
\ V4 Fast scroll & all above              1:11     0:57
\ V5 Using EMIT+ for output and all above 1:10     0:48
\ INCLUDE DSK1.ASM9900
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.ARRAYS
INCLUDE DSK1.VALUES

DECIMAL
: ?BREAK   ?TERMINAL ABORT" *BREAK*" ;

\ Scroll ends up being the slowest part of the benchmark.
\ Uncomment the screen I/O code below to a faster driver
\ .......................................................
\ SCROLL entire screen in one block with VMBR and VMBW
 : SCROLL ( -- )
  HERE 100 + DUP>R  VTOP @  ( --  buffer dst) ( r: BUFFER)
  DUP C/L@ + R>             ( -- buffer dst src buffer)
  [ C/SCR @ C/L @ - ] LITERAL DUP>R VREAD  R> VWRITE
  0 23 2DUP >VPOS C/L@ BL VFILL  \ erase bottom line
  AT-XY ;                        \ set cursor

\ The 2nd slowest part is writing the digits to screen
\ The word EMIT+ does not update the VDP write address for each char
HEX
\ New CR with faster scroll
: CR     (  -- ) VCOL OFF  VROW ++@  L/SCR = IF SCROLL THEN ;

\ New EMIT that uses VDPS autoincrement
HEX
\ get access to 'headless' WMODE sub-routine in kernel
' VC! 2 CELLS + @ CONSTANT WMODE

\ set VDP write address from Forth
\ CODE VDPWA! ( Vaddr --)
\    WMODE @@ BL,
\    TOS POP,
\    NEXT,
\ ENDCODE

: VDPWA!  S" 4000  OR 8800 C!" EVALUATE  ; IMMEDIATE

: EMIT+  ( char -- )
    VPOS VDPWA!
    8C00 C!   \ write to VDP and auto-inc VDP address
    VCOL ++@  C/L@ = IF CR  VPOS VDPWA! THEN ;
DECIMAL
\ .......................................................

\ define all data before use
0 VALUE WIN
0 VALUE POWER
0 VALUE NUMLEN
0 VALUE CARRY
0 VALUE INAROW
0 VALUE NDX   ( transfers loop index out of DO LOOP )
0 VALUE [I]

 256 CARRAY ]A                  \ 100 DIM A(256)
: RUN
  CR ." 7's Problem "           \ 110 PRINT "7's Problem"
  0 ]A 256 0 FILL               \ init ]A to zero
  7 0 ]A C!                     \ 120 A(1)=7
  0 TO WIN                      \ 130 WIN=0
  1 TO POWER                    \ 140 POWER=1
  0 TO NUMLEN                   \ 150 NUMLEN=1
  BEGIN
     1 +TO POWER                \ 160 POWER=POWER+1
    ." 7 ^" POWER . ." IS:"   \ 170 PRINT "7 ^";POWER;"IS:"
    ?BREAK
    0 TO CARRY                  \ 180 CARRY=0
    0 TO INAROW                 \ 190 INAROW=0
    NUMLEN 1+ 0                 \ 200 FOR I=1 TO NUMLEN
    DO
        I TO NDX                \ copy I for later
        I ]A                    \ Array address onto data stack
        DUP C@ 7 *  CARRY +     \ 210 A(I)=A(I)*7+CARRY
        0 10 UM/MOD TO CARRY    \ 220 CARRY=INT(A(I)/10)
( addr n) TUCK SWAP C!          \ 230 A(I)=A(I)-CARRY*10
        7 =                     \ 240 IF A(I)<>7 THEN 290
        IF
            1 +TO INAROW        \ 250 INAROW=INAROW+1
            INAROW 6 =          \ 260 IF INAROW<>6 THEN 300
            IF
              TRUE TO WIN       \ 270 WIN=1
              LEAVE
            THEN
        ELSE                    \ 280 GOTO 300
            0 TO INAROW         \ 290 INAROW=0
        THEN
    LOOP                        \ 300 NEXT I

    CARRY
    DUP NDX 1+ ]A C!            \ 310 A(I)=CARRY
    IF                          \ 320 IF CARRY=0 THEN 340
       1 +TO NUMLEN             \ 330 NUMLEN=NUMLEN+1
    THEN

    CR                          \ replaces PRINT
    VPOS VDPWA!
    0  NUMLEN                   \ 340 FOR I=NUMLEN TO 1
    DO
       I ]A C@ >DIGIT EMIT+     \ 350 PRINT CHR$(A(I)+48);
    -1 +LOOP                    \ 360 NEXT I ( STEP -1)
    CR CR                       \ 370 PRINT ::
    WIN                         \ 380 IF WIN<>1
  UNTIL                         \     THEN 160
  ." Winner is 7 ^" POWER .     \ 390 PRINT "WINNER IS 7 ^";POWER
;                               \ 420 END

DECIMAL
