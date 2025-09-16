\ PI.FTH from DxForth.

\ *HEAVILY MODIFIED FOR TI-99 CAMEL99 FORTH*

\ This version moves the RESULT array into TI-99 low RAM.
\ This gives us 8K for the results.

\ Thanks to Ed from Australia for finding the bug in my D+
\
\ Revised 2015-02-09  es
\
\ Compute Pi to an arbitrary precision. Uses Machin's
\ formula:  pi/4 = 4 arctan(1/5) - arctan(1/239)
\
\ Compile with 16-bit DX-Forth: FORTH - INCLUDE PI.F BYE
\ Compile with CAMEL99 Forth: INCLUDE DSK*.PI  ( where * is your drive no.)
\
\ This 16-bit implementation allows up to 45,808 digits
\ to be computed before arithmetic overflow occurs.
\
\ The code can be used on 32-bit targets with appropriate
\ changes:
\
\   16-bit             32-bit
\
\   10000 Multiply     100000000 Multiply
\   <# # # # # #>      <# # # # # # # # # #>
\   4 +loop            8 +loop
\   525 um/mod         1050 um/mod
\                      remove 'digits > 45808' warning
\
\ Acknowledgements:
\
\   Roy Williams, Feb 1994
\   J. W. Stumpel, May 1991
\   E. Ford, Aug 2009
\   R. Bishop, Aug 1978
\
\ This code is PUBLIC DOMAIN. Use at your own risk.

\ Modified for Camel99 Forth  Mar 2021 Fox
\ Sept 2025: Using 32bit timer for long duration measurements

\ Sept 6 2025 Speedups:
\ - Removed CELLS in loop and index by 2 instead
\   ( except in DIVIDE where is did not improve times)
\ - Expanded M+ with a TEXT macro
\ - changed +INDEX to DO/LOOP. Big improvement.
\ - replaced OVER with DUP and re-ordered arguments where possible

\ Sept 7, 2025  Added machine Forth Optimizers
\ make some Machine Forth Instructions

\ Sept 8, 2025 Exanded D- to a macro. 6% further improvement
\ NEEDS DUMP   FROM DSK1.TOOLS ( only needed for debugging)

NEEDS ERASEW FROM DSK1.ERASEW  \ 16 bit erase "words"
NEEDS VALUE  FROM DSK1.VALUES
NEEDS D=     FROM DSK1.DOUBLE
NEEDS ELAPSE FROM DSK1.ELAPSE32
NEEDS MARKER FROM DSK1.MARKER
\ NEEDS MORE   FROM DSK1.MORE

\ for saving results to file
NEEDS OUTH   FROM DSK1.OUTFILE

NEEDS .R     FROM DSK1.UDOTR \ these words now can output to file & screen


\ these macros improve speed by 3%
: M+ ( n n -- d) S" DUP 0< D+" EVALUATE ; IMMEDIATE
: D- ( d d -- d) S" 2INVERT 1 M+ D+" EVALUATE ; IMMEDIATE

\ for clarity
: S>UD ( u -- ud ) POSTPONE 0 ; IMMEDIATE
: ^2  S" DUP *" EVALUATE ; IMMEDIATE

\ TI-99 screen timout address
HEX
83D6 CONSTANT TIMEOUT
2000 CONSTANT LORAM

\ machine code primitives for TMS9900
HEX
: PUSH,     0646 , ;
: TOS>STK,  C584 ,  ;
: 2*,       0A14 ,  ;
: +,        A136 ,  ;
: @,        C114 ,  ;
: DROP,     C136 , ;
: R@,       C117 , ;   \   *RP  TOS MOV,
: (R)-, ( n -- ) 6127 , , ; \ n (RP) TOS SUB,

: 2DUP,
    0226 , -4 , \ SP -4 ADDI,
    C5A6 ,  4 , \ 4 (SP) *SP MOV,
    C984 ,  2 , \ TOS  2 (SP) MOV,
;

\ Combine them to make higher level MACRO isntructions
: DUP,      PUSH,  TOS>STK, ;
: OVER,     DUP,   TOS>STK, C126 , 0002 , ;
: I,        DUP, R@,  2 (R)-, ;

\ syntax sugar :-)
: M:   CODE ;
: ;M   NEXT,  ENDCODE ;

\ Now we can make Machine Forth Super instructions
M: CELLS+     2*, +,      ;M
M: DUP@       DUP, @,     ;M
M: 2DUP+@     2DUP, +, @, ;M
M: I+         I, +,       ;M

\ Performance changes from original
\ 500 Digit Test
\ Original Code     2:24
\ Opt1              2:21  \ used CELLS+ primitive
\ Opt M+            2:17  \ Original with M+ as macro
\ Opt1A             2:04  \ removed CELLS, loops index by 2
\ Opt1B             1:59  \ machine Forth superinstructions
\ Opt1c D- MACRO    1:52  \ 6% improvement

\ ================ PROGRAM BEGINS ===============
DECIMAL
0 VALUE POWER  ( adr)
0 VALUE TERM   ( adr)
0 VALUE RESULT ( adr)
0 VALUE SIZE   ( n)

VARIABLE CARRY
\ CHANGED ADD and SUBTRACT to step by 2 through arrays. B FOX
\ 3% speed up on 100 digits, 9% on 500 digits
: ADD ( -- )
  CARRY OFF
  0  SIZE CELLS 2-
  DO
    RESULT I+ DUP@ S>UD  TERM I+ @ S>UD D+
    CARRY @ M+
    ( hi) CARRY !
    ( lo) SWAP ( res) !
  -2 +LOOP
;

: SUBTRACT ( -- )
  CARRY OFF
  0  SIZE CELLS 2-
  DO
    RESULT I+ DUP@ S>UD  TERM I+ @ S>UD D-
    CARRY @ M+
    ( hi) CARRY !
    ( lo) SWAP ( res) !
  -2 +LOOP
;

\ scan forward for cell containing non-zero
\ BOUNDS & DO LOOP MUCH faster in Camel99 Forth
\ : +INDEX ( addr -- addr n)
\    DUP
\    SIZE CELLS
\    BOUNDS
\    DO
\       I @ IF I LEAVE THEN
\    2 +LOOP
\    OVER - 2/
\ ;

INCLUDE DSK1.SKIPSCANW \ SKIP & SCAN for "9900 word width" (CELLS)
\ scan forward for cell containing non-zero
: +INDEX ( addr -- addr n)
    DUP SIZE CELLS  0 SKIPW DROP  OVER - 2/ ;

0 VALUE FACTOR
\ Using cell sized looping made this part slower.
: DIVIDE ( ADR FACTOR -- )
    TO FACTOR
    CARRY OFF
    +INDEX ( adr index ) SIZE SWAP
    DO
        DUP I CELLS+ ( res)
        DUP@  CARRY @  FACTOR UM/MOD
      ( quot) ROT
      ( res) !
      ( rem) CARRY !
    LOOP
    DROP ;

\ scan backward for cell containing non-zero
: -INDEX ( adr -- adr index )
    SIZE CELLS
    BEGIN 2- DUP
    WHILE
       2DUP+@
    UNTIL
    THEN ;

: MULTIPLY ( adr factor -- )
  TO FACTOR   CARRY OFF
  -INDEX ( adr index ) 0 SWAP
  DO
    DUP I+ ( res)
    DUP@  FACTOR  UM*  CARRY @ M+
    ( hi) CARRY !
    ( lo) SWAP ( res) !
  -2 +LOOP
  DROP ;

\ scans the POWER array to determine if we are done.
: ZERO? ( result -- f ) +INDEX NIP SIZE = ;

0 VALUE PASS
VARIABLE EXP
VARIABLE SIGN

: DIVISOR ( -- N )
  PASS 1 <> IF  239  EXIT THEN \ removed ELSE
  5 ;

\ replaced ERASE with ERASEW. 2x faster
\ : ERASE  0 FILL ;

: INITIALIZE ( -- )
  POWER SIZE CELLS ERASEW
  TERM  SIZE CELLS ERASEW
  PASS 1 =
  IF
     RESULT SIZE CELLS ERASEW
  THEN
  16  PASS ^2 / POWER !
  POWER  DIVISOR  DIVIDE
  1 EXP !
  PASS 1- SIGN ! ;


DECIMAL
VARIABLE ITERATIONS

0 VALUE NDIGIT

: CalcPi ( -- )
  NDIGIT 45800 U> IF
    ." Warning: digits > 45808 will be in error "
  THEN
  CR ." Computing..."
  3 1
  DO
    I TO PASS
    INITIALIZE
    BEGIN
      TIMEOUT OFF ( prevent screen from going blank)
   \   .ITERATIONS
      POWER TERM SIZE MOVE
      TERM  EXP @ DIVIDE
      SIGN @ DUP
      IF   SUBTRACT
      ELSE ADD
      THEN
      0= SIGN !  2 EXP +!
      POWER  DIVISOR ^2  DIVIDE
      ITERATIONS 1+!
      POWER ZERO?
    UNTIL
  LOOP
;

: ?OPEN-FILE   PARSE-NAME DUP IF  MAKE-OUTPUT EXIT THEN  2DROP ;
: ?CLOSE-FILE  OUTH IF CLOSE-OUTPUT THEN ;
: ?BREAK       ?TERMINAL IF ?CLOSE-FILE TRUE ABORT" Print halted" THEN ;

DECIMAL
\ This turned out to be critical to make a good output file.
\ in DSK1.OUTFILE, CR causes the file buffer to write to disk.
\ It only works if I used C/L@ 6 -  as the record length cutoff. ??
: ?CR    VCOL @ C/L@ 6 - > IF CR THEN ;

: PRINT ( [ <path> ] )  \ optional path can echo data to I/O device
  ?OPEN-FILE
  CR
  CR ." Camel99 Forth PI Report"
  CR ." PI calculated to " NDIGIT 0 .R ." digits"
  CR ." Processing time: " ELAPSED$ COUNT TYPE
  CR ." ---"
  CR RESULT  DUP@ 0 .R  [CHAR] . EMIT CR
  NDIGIT 0
  ?DO
    0 OVER !
    DUP 10000 MULTIPLY
    DUP@ 0 <#  # # # #  #> TYPE SPACE ?CR
    ?BREAK
  4 +LOOP
  DROP
  CR
  CR ." --end--"
  ?CLOSE-FILE
;

: GetDigits ( -- n )
  CR ." How many digits do you want? "
  PAD DUP 20 ACCEPT NUMBER? ABORT" Bad number" CR ;

: ".."   ." .. " ;

: .SIZE   CR ." Array size = " SIZE . ." bytes" ;
: .POWER  CR ." POWER array is at  >" POWER  U. ".." POWER  SIZE + U. ;
: .TERM   CR ." TERM  array is at  >" TERM   U. ".." TERM   SIZE + U. ;
: .RESULT CR ." RESULT array is at >" RESULT U. ".." RESULT SIZE + U. ;
: .HERE   CR ." HERE is at " HERE U. ;

\ for clarity:
\ array size = ceil(ndigit / log10(2^16))
\ log10(2^16) as a fraction = 525/109 ie: 4.816...
\ Use the 32bit math to divide ndigit by 4.816...
: /log10(2^16) ( n --  rem size) 109 UM* 525 UM/MOD ;

: ARRAY_SIZE ( #Digits -- n)
   /log10(2^16) SWAP ( rem) IF  1+ ALIGNED THEN CELL+
   ( adds 1 extra cell for accurate last digits)
;

HEX 13 CONSTANT GREEN
    17 CONSTANT CYAN

: SCREEN  7 VWTR ;
DECIMAL
: PIDIGITS ( n ) \ Use for scripting
    DUP TO NDIGIT
    ( n) ARRAY_SIZE TO SIZE
    .SIZE
\ create arrays in un-allocated memory
    BASE @ HEX
\ allocate space for arrays
    HERE TO POWER   SIZE 20 + CELLS ALLOT
    HERE TO TERM    SIZE 20 + CELLS ALLOT
    LORAM TO RESULT
    .POWER  .TERM  .RESULT
    BASE !

    ITERATIONS OFF
    GREEN SCREEN
    CR CalcPi
    CYAN SCREEN
    CR ." Done!" SPACE  .ELAPSED
    CR ITERATIONS @ U. ." iterations"
    CR
;

: PI ( -- ) DECIMAL  GetDigits  PIDIGITS ;

: HELP
  CR
  CR ." USER COMMANDS:"
  CR ." PI  to  run the program"
  CR ." PRINT  to see the results"
  CR ." PRINT <device> to save to file"
  CR ." COLD to reset program"
  CR ." BYE to exit program"
  CR ." HELP to see this list"
;

: TITLEPAGE
  PAGE ."  Compute PI in ANS Forth"
  CR
  CR ." DxForth Revised 2015-02-09  ES"
  CR ." Revised for Camel99 2025-09-16 BFox"
  CR
  CR ." - Optimized with Machine Forth"
  CR
  CR ." Compute Pi to an arbitrary precision."
  CR
  CR ." Uses Machin's formula:"
  CR ." pi/4 = 4 arctan(1/5) - arctan(1/239)"
  HELP
;


\ end
: START   WARM  TITLEPAGE TIMER-START ABORT ;

 LOCK
\ Forth in RAM at >A000
\ INCLUDE DSK1.SAVESYS
\ ' START SAVESYS DSK3.PIDEMO

\ Forth in SuperCart at >6000
 INCLUDE DSK1.SUPERSAVE
' START SUPERSAVE DSK3.PIDEMOSC
