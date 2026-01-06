\ INLINE-CODE.FTH  creates code words from Forth prims. Jan 5 2026 Fox

\ Problem:
\  threaded Forth spends 50% of its time running the interpreter.
\  OPT[ ] compiles Forth primitives inline without the interpreter.
\  This optimizer also converts variables, numbers and constants
\  to use the 'load immediate' instruction.

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

NEEDS .S    FROM DSK1.LOWTOOLS
NEEDS CASE  FROM DSK1.CASE

HERE
HEX
\ machine code compilers instead of using the assembler
: DUP,      0646 , C584 , ;
: DROP,     C136 , ;
: !,        C536 , ;
: @,        C114 , ;   \ fetch from address in TOS
: ADDR@, ( addr -- ) C120 ,  , ;  \ symbolic fetch

: #,    ( n -- )   0204 ,  ( n) , ; \ load n to TOS
: LIT,  ( n -- ) DUP,  #,   ;
: #+,   ( n -- n') 0224 ,  ;        \ ADD n to TOS

\ *** changed for kernel V2.69 ***
\ need copies of words that do not end in NEXT, in the Camel99 kernel
CODE DUP    DUP,      NEXT, ENDCODE
CODE DROP   DROP,     NEXT, ENDCODE
CODE !      !, DROP,  NEXT, ENDCODE
CODE @      @,        NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE

\ CFA of a code word contains the address of the next cell
: NOTCODE? ( -- ?)  DUP @ 2- - 0> ;

045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
           >BODY 80 CELLS  ( -- addr len)
           BOUNDS ( -- IPend IPstart)
           BEGIN
              DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
           WHILE
             DUP @  ( -- IP instruction)
             ,     \ compile instruction
             CELL+  \ advance IP
             2DUP < ABORT" End of code not found"
           REPEAT
           2DROP
;

HEX

\ new interpreter loop for inlining *future* make this the Forth compiler
: OPT[ ( -- addr)  \ Returns address where code has been copied
         BEGIN
            BL WORD CHAR+ C@  [CHAR] ] <>  WHILE
            HERE FIND
            IF ( *it's a Forth word* )
                  DUP NOTCODE?
                  IF DUP
                    @  \ get the "executor" code routine address
                  CASE \ **** DATA OPTIMIZER ****
                      [']  DOVAR    OF  >BODY   LIT, ENDOF
                      [']  DOCON    OF  EXECUTE LIT, ENDOF
                      [']  DOUSER   OF  EXECUTE LIT, ENDOF

                      CR ." *Can't optimize word"  TRUE ?ERR
                  ENDCASE

                  ELSE  \ it's a CODE primitive
                        CODE, \ default compile kernel code
                  THEN

            ELSE ( maybe its a number)
                 COUNT NUMBER?  ?ERR
                 ( n ) LIT, \ compile n as a literal
            THEN
         REPEAT
         NEXT,    \ compile NEXT at end of code
;  IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR

VARIABLE X
VARIABLE Y
VARIABLE Z

CODE TEST  OPT[ X @ 2 + Y ! ] ENDCODE

CODE TEST2  OPT[ X @  Y @  +  Z ! ] ENDCODE