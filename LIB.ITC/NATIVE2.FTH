\ EXPERIMENTAL NATIVE CODE TEST PLATFORM  Nov 2025 Brian Fox

\ These macros are created by stealing code from the KERNEL very much like
\ a conventional compiler would emit code.
\ Use these words to create "native" sub-routines that are like Forth but run faster.
\ The biggest speed up is when used with structured assembler loops.

NEEDS .S     FROM DSK1.TOOLS
NEEDS LIFO:  FROM DSK1.STACKS

NEEDS VOCABULARY FROM DSK1.WORDLISTS

VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
NEEDS BEGIN,   FROM DSK1.ASM9900


ONLY FORTH DEFINITIONS ALSO ASSEMBLER

HERE
HEX
\ Words in scratchpad RAM end in a JMP instruction, not NEXT
\ Might change this, but for now make some conventional versions.
CODE DUP    0646 , C584 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE
CODE !      C536 , C136 ,  NEXT, ENDCODE
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE


045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: ?CODE ( xt -- ) DUP @ 2- - ABORT" Not a primitive"  ;

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
    DUP ?CODE
    >BODY 80 CELLS  \ 128 bytes is max size we will try to compile
    BOUNDS    ( -- IPend IPstart)
    BEGIN
        DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
    WHILE
        DUP @  ( -- IP instruction)
        ,      \ compile instruction
        CELL+  \ advance IP
        2DUP < ABORT" End of code not found"
    REPEAT
    2DROP
;

\ we can steal primitives from the kernel
: STEAL ( <codeword> ) POSTPONE [']   POSTPONE CODE, ; IMMEDIATE

\ ==========================================================
\ Machine code compiler

VOCABULARY MACHINE
ONLY FORTH ALSO ASSEMBLER ALSO MACHINE DEFINITIONS

\ MACHINE code sub-routine.  Use with CALL
: SUB:   CREATE    R11 RPUSH, ;
: ;SUB   R11 RPOP,   R11 ** B, ;

\ call a sub-routine from inside a sub-routine
: CALL   ( addr -- )  @@ BL, ;

\ call & run a sub-routine from Forth
CODE RUN ( addr -- ) TOS R0 MOV,  TOS POP,   R0 ** BL,  NEXT, ENDCODE

HEX
\ compile code to load TOS ( r4 ) with n
: LIT,   ( n -- )  STEAL DUP   0204 ,  , ; \ LI R4,<n>

\ These words compile machine code for a LI instruction and value
: VARIABLE  CREATE HERE ,  DOES>  @ LIT, ;
: CONSTANT  CREATE      ,  DOES>  @ LIT, ;

\ since we don't have a compiler loop we need this to put a literal
\ number into the code
: #    ( <TEXT> )  PARSE-NAME  EVALUATE LIT, ;

\  jump primitives
\ store a byte offset in odd byte of addr.
\ Addr is the location of Jump instruction
: RESOLVE ( addr offset --) 2- 2/ SWAP 1+ C! ;

\ compute offset from addr to addr' & complete the jump instruction
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: ?BYTE ( c -- c)  DUP FF00 AND ABORT" Jump out of range" ;

\ compile "raw" jump instructions with no offset byte
: JMP,  ( c --) ?BYTE 1000 + , ;
: JNO,  ( c --) ?BYTE 1900 + , ;
: JNC,  ( c --) ?BYTE 1700 + , ;

\ ===============================================================
\               >>> BRANCHING AND LOOPING <<<

\ small CONTROL FLOW STACK for loops and branching

8 LIFO: CS
: >CS     ( n -- ) CS PUSH ;
: CS>     ( -- n ) CS POP ;
: CS>SWAP ( -- )   CS> CS> SWAP >CS >CS ;
: ?CS     CS STACK-DEPTH ABORT" Un-matched IF or loop words" ;

: BEGIN    HERE >CS ; IMMEDIATE  \ push location onto control stack

\ <DO> is CODE preamble to setup return stack.
: DO  ( -- HERE)  STEAL <DO>   POSTPONE BEGIN  ; IMMEDIATE

: LOOP
    0597 ,                   \ *RP INC,
    CS> HERE  0 JNO, <BACK   \ compute offset, compile into JNO
    STEAL UNLOOP             \ collapse stack frame
; IMMEDIATE

: +LOOP
    0A5CA ,          \ TOS *RP ADD,
    STEAL DROP       \ don't need TOS value anymore
    POSTPONE LOOP    \ compile loop code
; IMMEDIATE

: I  STEAL I ;  IMMEDIATE
: J  STEAL J ;  IMMEDIATE

: AGAIN   CS> HERE 0 JMP, <BACK ; IMMEDIATE

: UNTIL
    STEAL 1-
    STEAL DROP
    CS> HERE 0 JNC, <BACK ; IMMEDIATE

: IF    ( n -- )
    STEAL 1-       \ If tos=0, DEC will cause a carry
    STEAL DROP
    HERE >CS 0 JNC, ; IMMEDIATE

: THEN  CS> HERE OVER - RESOLVE ; IMMEDIATE

: ELSE  HERE >CS  0 JMP,
        CS>SWAP POSTPONE THEN ; IMMEDIATE

: WHILE  ( n -- ) POSTPONE IF CS>SWAP ; IMMEDIATE
: REPEAT  POSTPONE AGAIN  POSTPONE THEN ; IMMEDIATE
\ EXPERIMENTAL NATIVE CODE TEST PLATFORM  Nov 2025 Brian Fox

\ These macros are created by stealing code from the KERNEL very much like
\ a conventional compiler would emit code.
\ Use these words to create "native" sub-routines that are like Forth but run faster.
\ The biggest speed up is when used with structured assembler loops.

NEEDS .S     FROM DSK1.TOOLS
NEEDS LIFO:  FROM DSK1.STACKS

NEEDS VOCABULARY FROM DSK1.WORDLISTS

VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
NEEDS BEGIN,   FROM DSK1.ASM9900

HERE
ONLY FORTH DEFINITIONS ALSO ASSEMBLER
HEX
\ Words in scratchpad RAM end in a JMP instruction, not NEXT
\ Might change this, but for now make some conventional versions.
CODE DUP    0646 , C584 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE
CODE !      C536 , C136 ,  NEXT, ENDCODE
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE


045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: ?CODE ( xt -- ) DUP @ 2- - ABORT" Not a primitive"  ;

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
    DUP ?CODE
    >BODY 80 CELLS  \ 128 bytes is max size we will try to compile
    BOUNDS    ( -- IPend IPstart)
    BEGIN
        DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
    WHILE
        DUP @  ( -- IP instruction)
        ,      \ compile instruction
        CELL+  \ advance IP
        2DUP < ABORT" End of code not found"
    REPEAT
    2DROP
;

\ we can steal primitives from the kernel
: STEAL ( <codeword> ) POSTPONE [']   POSTPONE CODE, ; IMMEDIATE

\ ==========================================================
\ Machine code compiler

VOCABULARY MACHINE
ONLY FORTH ALSO ASSEMBLER ALSO MACHINE DEFINITIONS

\ MACHINE code sub-routine.  Use with CALL
: SUB:   CREATE    R11 RPUSH, ;
: ;SUB   R11 RPOP,   R11 ** B, ;

\ call a sub-routine from inside a sub-routine
: CALL   ( addr -- )  @@ BL, ;

\ call & run a sub-routine from Forth
CODE RUN ( addr -- ) TOS R0 MOV,  TOS POP,   R0 ** BL,  NEXT, ENDCODE

HEX
\ compile code to load TOS ( r4 ) with n
: LIT,   ( n -- )  STEAL DUP   0204 ,  , ; \ LI R4,<n>

\ These words compile machine code for a LI instruction and value
: VARIABLE  CREATE HERE ,  DOES>  @ LIT, ;
: CONSTANT  CREATE      ,  DOES>  @ LIT, ;

\ since we don't have a compiler loop we need this to put a literal
\ number into the code
: #    ( <TEXT> )  PARSE-NAME  EVALUATE LIT, ;

\  jump primitives
\ store a byte offset in odd byte of addr.
\ Addr is the location of Jump instruction
: RESOLVE ( addr offset --) 2- 2/ SWAP 1+ C! ;

\ compute offset from addr to addr' & complete the jump instruction
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: ?BYTE ( c -- c)  DUP FF00 AND ABORT" Jump out of range" ;

\ compile "raw" jump instructions with no offset byte
: JMP,  ( c --) ?BYTE 1000 + , ;
: JNO,  ( c --) ?BYTE 1900 + , ;
: JNC,  ( c --) ?BYTE 1700 + , ;

\ ==========================================================================
CR .( Inline code compilers are "stolen" from the kernel)
CREATE BUFFER 20 ALLOT

: INLINE:
    CREATE
    LATEST @ COUNT BUFFER PLACE
    ALSO FORTH   \ search the Forth wordlist first
    BUFFER FIND 0= ABORT" Not in the kernel"
    DUP ?CODE    \ is it a code word
    ,            \ compile this XT in this word
    PREVIOUS     \ restore search order

    DOES>  @ CODE, ; \ at run time compile the machine code of the XT


\ ** colon words  compile inline code in a CODE word

INLINE: !       INLINE: @
INLINE: 2!      INLINE: 2@
INLINE: C!      INLINE: C@      INLINE: COUNT

INLINE: +!      INLINE: 1+!
INLINE: 1-!
\  INLINE: 2+!  INLINE: 2-!

\ ===================================================================
CR .( D A T A   S T A C K)
INLINE: SP@     INLINE: SP!
INLINE: DROP    INLINE: NIP
INLINE: DUP     INLINE: OVER
INLINE: SWAP    INLINE: ROT
INLINE: -ROT    INLINE: ><
INLINE: SPLIT

INLINE: 2DROP   INLINE: 2DUP
INLINE: 2SWAP   INLINE: PICK

\ ==========================================================================
CR .( R E T U R N   S T A C K)
INLINE: RP@     INLINE: RP!
INLINE: >R      INLINE: R>
INLINE: R@

\ ==================================================================
CR .( Shift right & left)

INLINE: RSHIFT      INLINE: LSHIFT

\ ==================================================================
CR .( A R I T H M E T I C)
: 0       TOS PUSH, TOS CLR, ; \ fast constant

INLINE: 1+      INLINE: 1-
INLINE: 2+      INLINE: 2-
INLINE: 2*      INLINE: 2/
INLINE: INVERT  INLINE: +
INLINE: -       INLINE: *

\ INLINE: UM+    ( u u -- u cy ) STEAL UM+ ;        \ or ( u u -- ud )
\ INLINE: M+      ( d n -- d )  STEAL M+ ;        \ add single to double
INLINE: UM*
\ INLINE: UM/MOD  ( ud u1 -- u2 u3 ) STEAL UM/MOD ;

\ ===================================================================
\ VDP primitives
INLINE: VC@     INLINE: VC!
INLINE: V@      INLINE: V!
INLINE: VWTR

HERE SWAP -  CR DECIMAL U. .( bytes)


\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

\ ===================================================================
\ subroutines using inline primitivies
\ Run sub-routines with the 'RUN' command

SUB: ADD1    1+ ;SUB
SUB: ADD2    2+ ;SUB

\ call the sub-routines when invoked inside a sub-routine
SUB: ADD3
    ADD1 CALL
    ADD2 CALL
;SUB

SUB: ADD4   ADD3 CALL  1+    NEXT, ENDCODE

\ use RUN inside Forth definition
: RUNTEST   ADD4 RUN  ;

\ put two numbers on the data stack and subtract
SUB: #TEST   HEX # DEAD  # BEEF  -  ;SUB

\ X and Y are not Forth data structures.
\ They can only be used in SUB: ;SUB   definitions
VARIABLE X
2 CONSTANT Y

SUB: DOLOOP
    # FFFF # 0
    DO
        Y X +!
    LOOP
;SUB
