CR .( INLINE5C.FTH  Jan 6, 2022 B Fox)
\ Compiles inline code as headless word in HEAP
\ *VERSION 5* CAN OPTIMIZE VARIABLES, CONSTANTS AND LITERAL NUMBERS*
\ Improved constant optimization
\ APR 15 2021: Made CODE, one definition
\ This is a very narrow focus, static JIT (just in time compiler)

\ Problem:
\  The preamble overhead to compile an ITC word as inline machine code
\  is too big. You need 8 bytes for the header and 8 bytes to correct the IP.
\  This meant it was easier make new code words that combined other code words.
\  INLINE[ ] in this version uses HEAP memory to compile a headless version
\  of the new code word. That NEW XT is compiled into your Forth definition.
\

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

\ NEEDS .S   FROM DSK1.TOOLS
NEEDS CASE FROM DSK1.CASE

HERE
HEX

\ need NORMAL copies of words that are WEIRD in the Camel99 kernel
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE DUP    0646 , C584 ,  NEXT, ENDCODE \ for V2.68G
CODE +      A136 ,         NEXT, ENDCODE \ for V2.68G

\ steal code to create properly formed primitives (rather than aliases)
CODE CELLS ' 2* >BODY @ ,   NEXT, ENDCODE
CODE CELL+ ' 2+ >BODY @ ,   NEXT, ENDCODE
CODE CHAR+ ' 1+ >BODY @ ,   NEXT, ENDCODE
CODE >BODY ' 2+ CELL+ @ ,   NEXT, ENDCODE
CODE CHARS   NEXT, ENDCODE  \ do nothing

\ CFA of a code word contains the address of the next cell
: NOTCODE? ( -- ?)  DUP @ 2- - ;

\ Heap management words
: HEAP    ( -- addr) H @ ;
: HALLOT  ( n -- )   H +! ;
: HEAP,  ( n -- )    HEAP ! 2 HALLOT ;

045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
           >BODY
           DUP 80 CELLS +   \ set a max size for any code fragment
           SWAP   ( -- IPend IPstart)
           BEGIN
              DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
           WHILE
             DUP @ ( -- IP instruction)
             HEAP,  \ compile instruction
             CELL+  \ advance IP
             2DUP < ABORT" End of code not found"
           REPEAT
           2DROP
;

\ now we can steal code from the kernel and compile it to HEAP
: DUP,   ['] DUP CODE, ;


\ LIT,   DUP TOS and compile n as a literal into TOS register
: LIT,      ( n -- ) DUP,  0204 HEAP, ( n) HEAP, ;

\ new interpreter loop for inlining *future* make this the Forth compiler
: INLINE[ ( -- addr)  \ Returns address where code has been copied
           HEAP ( -- XT)  \ HEAP will be our new execution token (XT)
           DUP 2+ HEAP,   \ create the ITC header for CODE word
           BEGIN   BL WORD CHAR+ C@  [CHAR] ] <>
           WHILE
              HERE FIND
              IF ( *it's a Forth word* )
                 DUP NOTCODE?
                 IF DUP
                    @  \ get the "executor" code routine address
                    CASE
                      [']  DOVAR    OF  >BODY   LIT, ENDOF
                      [']  DOCON    OF  EXECUTE LIT, ENDOF
                      [']  DOUSER   OF  EXECUTE LIT, ENDOF
                      CR ." *Can't optimize type"  TRUE ?ERR
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


HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR
