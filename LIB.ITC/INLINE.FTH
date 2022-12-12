\ INLINE5B.FTH Compiles inline code as headless word in HEAP  Dec 2, 2020 B Fox
\ *VERSION 5* CAN OPTIMIZE VARIABLES, CONSTANTS AND LITERAL NUMBERS*
\ Improved constant optimization
\ APR 15 2021: Made CODE, one definition
\ This is a very narrow focus, static JIT (just in time compiler)
\ Dec 2021: Simplified CODE, with BOUNDS
\ Apr 2022  Added primitives for DROP, @ and ! that are in hispeed RAM.
\ Problem:
\  The extra overhead to compile an ITC word as inline machine code
\  is 4 bytes for the ENTRY and 4 bytes to correct the IP.
\  This meant it was OK to make new code words that combined other code words.
\  INLINE[ ] in this version uses HEAP memory to compile a headless version
\  of the new code word. That NEW XT is compiled into your Forth definition.
\

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

\ NEEDS .S   FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900
NEEDS CASE FROM DSK1.CASE

HERE
HEX
\ *** changed for kernel V2.69 ***
\ need copies of words that do not end in NEXT, in the Camel99 kernel
CODE DUP    0646 , C584 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE
CODE !      C536 , C136 ,  NEXT, ENDCODE
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE

\ CFA of a code word contains the address of the next cell
: NOTCODE? ( -- ?)  DUP @ 2- - ;

\ Heap management words
: HEAP    ( -- addr) H @ ;
: HALLOT  ( n -- )   H +! ;
: H,   ( n -- )    HEAP ! 2 HALLOT ;

045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
           >BODY 80 CELLS  ( -- addr len)
           BOUNDS ( -- IPend IPstart)
           BEGIN
              DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
           WHILE
             DUP @  ( -- IP instruction)
             H,     \ compile instruction
             CELL+  \ advance IP
             2DUP < ABORT" End of code not found"
           REPEAT
           2DROP
;

HEX
: DUP,    ['] DUP  CODE, ;

\ LIT,              TOS PUSH,   TOS n LI,
: LIT,      ( n -- ) DUP,     0204 H,  ( n) H, ;

\ new interpreter loop for inlining *future* make this the Forth compiler
: INLINE[ ( -- addr)  \ Returns address where code has been copied
           HEAP ( -- XT)  \ HEAP will be our new execution token (XT)
           DUP 2+ H,    \ create the ITC header for CODE word
           BEGIN   BL WORD CHAR+ C@  [CHAR] ] <>  WHILE
              HERE FIND
              IF ( *it's a Forth word* )
                 DUP NOTCODE?
                 IF DUP
                    @  \ get the "executor" code routine address
                    CASE
                      [']  DOVAR    OF >BODY LIT,    ENDOF
                      [']  DOCON    OF  EXECUTE LIT, ENDOF
                      [']  DOUSER   OF  EXECUTE LIT, ENDOF
                      CR ." *Can't optimize type"  TRUE ?ERR
                    ENDCASE

                 ELSE \ it's a CODE primitive
                     CODE, \ compile kernel code
                 THEN

             ELSE ( maybe its a number)
                 COUNT NUMBER?  ?ERR
                 ( n ) LIT, \ compile n as a literal
             THEN
           REPEAT
           045A H,    \ compile NEXT at end of HEAP code
           COMPILE,   \ compile HEAP XT into current colon definition
;  IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR
