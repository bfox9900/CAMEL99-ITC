\ JIT.FTH Compiles inline code as headless word in HEAP  Feb 16 2021 B Fox
\ Problem:
\ ITC code spends 50% of it's time running the interpreter.
\ Code words can run sequentially without the interperter
\ ! Compile "super-instructions" dynamically made of code word sequences

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

NEEDS .S   FROM DSK1.TOOLS
NEEDS CASE FROM DSK1.CASE

MARKER /JIT

HERE
HEX
\ need NORMAL copies of words that are WEIRD in the Camel99 kernel
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE

\ CFA of a code word contains the address of the next cell
: CODE? ( -- ?)  DUP @ 2- - 0= ;

\ Heap management words
: HEAP    ( -- addr) H @ ;
: HALLOT  ( n -- )   H +! ;
: HEAP,  ( n -- )    HEAP ! 2 HALLOT ;

045A CONSTANT 'NEXT'   \ camel99 Next instruction ( B *R10 )

\ scan MACHINE code looking for the NEXT, routine.
\ Abort if NEXT is not found after 256 bytes. This is an arbitrary size
\ but most Forth code words are much smaller than 256 bytes.
: TONEXT ( adr --  adr2 )
           0                \ flag that falls thru if we don't succeed
           SWAP
         ( adr) 80          \ max length of code word is $80 CELLS
           BOUNDS
           DO
             I @ 'NEXT' =   \ test each CELL for CAMEL99 NEXT (B *R10)
             IF   DROP I LEAVE
             THEN
           2 +LOOP
           DUP 0= ABORT" NEXT not found" ;

: XT>CODE,  ( xt --)  \ Copy XT's kernel code into HEAP removing NEXT
  >BODY DUP TONEXT OVER  -   ( -- PFA PFA len)
   HEAP OVER HALLOT SWAP CMOVE ;  \ transcribe code to HEAP

: LOOKAHEAD ( -- addr ?)  BL WORD FIND  ;
: CODEHEAD  ( -- xt)  HEAP  DUP 2+ HEAP, ; \ make code word, return XT

VARIABLE FXT      \ Last Forth XT that we find while searching for
: JITLOOP ( -- )  \ JIT source until no more code words
  BEGIN
     LOOKAHEAD
  WHILE
     DUP CODE?
     IF  XT>CODE,    \ add code to super instruction
     ELSE FXT !   \ Found Forth word, remember the XT
          EXIT    \ get out of loop
     THEN
  REPEAT
;

: JIT  ( xt -- super-instructionXT | Forth XT)
     LOOKAHEAD CODE? ( -- xt1 xt2 ? )
     IF ( ... we have 2 code words in a row)
       CODEHEAD -ROT   \ make a super-intruction, put on bottom of stack
       SWAP XT>CODE, XT>CODE,  \ convert
\       JITLOOP       \ jit remaining code words
      'NEXT' HEAP,   \ compile NEXT at end of super-instruction code
    THEN             \ return super instruction xt OR input xt
;

: <JIT>  ( i*x c-addr u -- j*x )
         'SOURCE 2!  >IN OFF
          BEGIN
              BL WORD DUP C@ ( -- addr len)
          WHILE
              FIND ?DUP
              IF ( it's a word)
                   1+ STATE @ 0= OR
                   IF   EXECUTE
                   ELSE
                        DUP CODE?
                        IF   JIT COMPILE,
                        ELSE COMPILE,
                        THEN
                   THEN
              ELSE ( it's a number)
                   COUNT NUMBER? ?ERR
                   t[COMPILE] LITERAL
              THEN
              DEPTH 0< TS" Short stack" ?ABORT
          REPEAT
          DROP ;

HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR
