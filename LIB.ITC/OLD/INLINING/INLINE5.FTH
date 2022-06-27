\ inline5.fth Compiles inline code as headless word in HEAP  Dec 2, 2020 B Fox
\ *VERSION 5* CAN OPTIMIZE VARIABLES, CONSTANTS AND LITERAL NUMBERS*
\  improved constant optimization
\ This is a very narrow focus, static JIT (just in time compiler)

\ Problem:
\  The preamble overhead to compile an ITC word as inline machine code
\  is too big. You need 8 bytes for the header and 8 bytes to correct the IP.
\  This meant it was easier make new code words that combined other code words.
\  INLINE[ ] in this version uses HEAP memory to compile a headless version
\  of the new code word. That XT is compiled into your Forth definition.
\

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

\ NEEDS .S   FROM DSK1.TOOLS
NEEDS CASE FROM DSK1.CASE

MARKER /INLINE

HERE
HEX
\ CFA of a code word contains the address of the next cell
: NOTCODE? ( -- ?)  DUP @ 2- - ;

\ Heap management words
: HEAP    ( -- addr) H @ ;
: HALLOT  ( n -- )   H +! ;
: HEAP,  ( n -- )    HEAP ! 2 HALLOT ;

\ scan MACHINE code looking for the NEXT, routine.
\ Abort if NEXT is not found after 256 bytes. This is an arbitrary size
\ but most Forth code words are much smaller than 256 bytes.
: TONEXT ( adr --  adr2 )
           0                \ flag that falls thru if we don't succeed
           SWAP
         ( adr) 80          \ max length of code word is $80 CELLS
           BOUNDS
           DO
             I @ 045A  =   \ test each CELL for CAMEL99 NEXT (B *R10)
             IF   DROP I LEAVE
             THEN
           2 +LOOP
           DUP 0= ABORT" NEXT not found" ;

: CODE,  ( xt --)  \ Compile code word from kernel into HEAP
           >BODY DUP TONEXT OVER  -   ( -- PFA PFA len)
           HEAP OVER HALLOT SWAP CMOVE ;  \ transcribe code to HEAP

\ now we can steal code from the kernel and compile it to HEAP
: DUP,   ['] DUP CODE, ;

\ LIT,   DUP TOS and compile n as a literal into TOS register
: LIT,      ( n -- ) DUP,  0204 HEAP, ( n) HEAP, ;

\ new interpreter loop for inlining
: INLINE[ ( -- addr)  \ Returns address where code has been copied
           HEAP ( -- XT)  \ HEAP will be our new execution token (XT)
           DUP 2+ HEAP,   \ create the ITC header for CODE word
           BEGIN   BL WORD CHAR+ C@  [CHAR] ] <>  WHILE
              HERE FIND
              IF ( *it's a Forth word* )
                 DUP NOTCODE?
                 IF DUP
                    @  \ get the "executor" code routine address
                    CASE
                      [']  DOVAR    OF  >BODY LIT,   ENDOF
                      [']  DOCON    OF  EXECUTE LIT, ENDOF
                      [']  DOUSER @ OF  EXECUTE LIT, ENDOF
                      CR ." *Can't optimize type"  TRUE  ?ERR
                    ENDCASE

                 ELSE  \ it's a CODE primitive
                       CODE,  \ compile kernel code
                 THEN

             ELSE ( maybe its a number)
                 COUNT NUMBER?  ?ERR
                 ( n ) LIT,   \ compile n as a literal
             THEN
           REPEAT
           045A HEAP,   \ compile NEXT at end of HEAP code
           COMPILE,     \ compile HEAP XT into current colon definition
;  IMMEDIATE

\ need NORMAL copies of words that are WEIRD in the Camel99 kernel
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE

HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR
