\ inline4.fth Compiles inline code as headless word in HEAP  Aug 4, 2020
\ *VERSION 3* CAN OPTIMIZE VARIABLES, CONSTANTS AND LITERAL NUMBERS*

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
: HEAP,  ( n -- )   HEAP ! 2 HALLOT ;

\ scan MACHINE code looking for the NEXT, routine.
\ Abort if NEXT is not found after 256 bytes. This is an arbitrary size
\ but most Forth code words are much smaller than 256 bytes.
: TONEXT ( adr --  adr2 )
           0                \ flag that falls thru if we don't succeed
           SWAP
         ( ADR) 80          \ max length of code word is $80 CELLS
           BOUNDS
           DO
             I @ 045A  =   \ test each CELL for CAMEL99 NEXT (B *R10)
             IF   DROP I LEAVE
             THEN
           2 +LOOP
           DUP 0= ABORT" NEXT not found" ;

\ LIT, macro compiles the following machine code into HEAP memory
\              *SP  DECT,
\           TOS *SP  MOV,
\           TOS SWAP LI,
: LIT,      ( n -- ) 0646 HEAP, C584 HEAP, 0204 HEAP, ( n) HEAP, ;

: VAR,    >BODY LIT,  ;               \ compile variable PFA as literal
: CON,    >BODY LIT,  C114 HEAP,  ;   \ compile constant PFA & compile @

\ <<NOT MULTI-TASKING FRIENDLY>> computes address of compiler's workspace
: USER,   ( xt --)  EXECUTE LIT,  ;  \ execute user VAR to compute address 1st

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
                      [']  DOVAR    OF  VAR,  ENDOF
                      [']  DOCON    OF  CON,  ENDOF
                      [']  DOUSER @ OF USER,  ENDOF \ douser is Weird
                      CR ." *Can't optimize type"  TRUE  ?ERR
                    ENDCASE

                 ELSE  \ it's a CODE primitive
                     \ calc. start and len. of code
                     >BODY DUP TONEXT OVER  -   ( -- PFA PFA len)
                     HEAP OVER HALLOT SWAP CMOVE   \ transcribe code to HEAP
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
