\ EXPERIMENTAL NATIVE CODE COMPILER      Nov 2025 Brian Fox

\ Native sub-routines are created by stealing code from the KERNEL.
\ Each sub-rotuine saves R11 to the Rstack on entry and restores on exit.
\ Loop words are replaced with versions that compile native code jumps.


NEEDS .S     FROM DSK1.TOOLS
NEEDS LIFO:  FROM DSK1.STACKS

NEEDS VOCABULARY FROM DSK1.WORDLISTS

VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
NEEDS BEGIN,   FROM DSK1.ASM9900

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

: ?CODE ( xt --) DUP @ 2- - ABORT" Not a primitive"  ;

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
: STEAL ( <codeword> )  POSTPONE [']   POSTPONE CODE, ; IMMEDIATE

\ ==========================================================
\ Machine code compiler

VOCABULARY MACHINE
ONLY FORTH ALSO ASSEMBLER ALSO MACHINE DEFINITIONS
\ call a sub-routine from inside a sub-routine
: CALL   ( addr -- ) @@ BL, ;

VARIABLE MSTATE     \ state variable for the machine compiler

\ MACHINE code sub-routine
\ 1. If Mstate=true, compile a branch to it own code
\ 2. If Mstate=false, return the address to the data stack

\ Note: We RPUSH R11 on entry to sub-routines so we can return properly
: SUB:
    CREATE
        MSTATE  ON          \ signal that we are compiling
        R11 RPUSH,          \ all sub-routines save R11 on entry

    DOES> ( -- addr)
\ Runtime: If Mstate = true, compile code to call the word.
\ Otherwise we just leave the address on the stack
    MSTATE @ IF  @@ BL,  THEN ;

\ Note: We RPOP R11 and then do the return
: ;SUB
    R11 RPOP,  RT,
    MSTATE OFF   \ compile is off
;


\ call & run a native sub-routine from Forth.
CODE RUN ( addr -- )
    TOS R0 MOV,     \ get 'addr' into temp register
    TOS POP,        \ refill the TOS register (ie: DROP)
    R0 ** BL,       \ branch & link to 'addr'
    NEXT,
ENDCODE

HEX
\ compile code to load TOS ( r4 ) with n
: LIT,   ( n -- )  STEAL DUP   0204 ,  , ; \ LI R4,<n>

\ since we don't have a compiler loop we need use evaluate on a text number
\ and compile some code to put a literal number into the TOS register
: #    ( <TEXT> )  PARSE-NAME  EVALUATE  LIT, ;

\ These words compile machine code for a LI instruction and value
: VARIABLE  CREATE HERE DUP OFF ,  DOES>  @ LIT, ;
: CONSTANT  ( n -- ) CREATE  ,     DOES>  @ LIT, ;

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

\ Chuck Moore's Machine Forth FOR/NEXT loop. Simple downcount in Register 11
\ * THIS IS NOT SAFE IF YOUR SYSTEM CALLS A "LEAF" sub-routine inside the FOR loop **
 : FOR   ( n --) R11 RPUSH, TOS R11 MOV, TOS POP,  BEGIN, ;
 : NEXT  ( -- )  R11 DEC,   NC UNTIL,  R11 RPOP, ;
 : NEXT2 ( -- )  R11 DECT,  NC UNTIL,  R11 RPOP, ;
 : i     ( -- u) TOS PUSH,  R11 TOS MOV, ;


\ ==========================================================================
CR .( Inline code compilers are "stolen" from the kernel)

\ ** colon words  compile inline code in a CODE word

: !      ( n addr -- ) STEAL ! ;
: @      ( a -- w )    STEAL @ ;
: 2!     ( d addr -- ) STEAL 2! ;
: 2@     ( addr -- d)  STEAL 2@ ;

: C!     ( c addr -- ) *SP+ W MOV,  W SWPB,  W *TOS MOVB,  TOS POP, ;
: C@      ( addr -- c ) *TOS TOS MOVB,  TOS 8 SRL, ;

: COUNT   ( addr -- addr' n) STEAL COUNT ;
: +!      ( n addr --) STEAL +! ;
: 1+!     ( addr -- )  STEAL 1+! ;
: 1-!     ( addr -- )  STEAL 1-! ;
: 2+!,    ( addr -- ) *TOS INCT, ;
: 2-!,    ( addr -- ) *TOS DECT, ;

\ ===================================================================
CR .( D A T A   S T A C K)
: SP@    ( -- a ) STEAL SP@ ;
: SP!    ( a -- ) STEAL SP! ;
: DROP   ( w -- ) STEAL DROP ;
: NIP    ( n n' -- n') STEAL NIP ;
: DUP    ( w -- w w ) STEAL DUP ;
: OVER   ( w1 w2 -- w1 w2 w1 ) STEAL OVER ;
: SWAP   ( w1 w2 -- w2 w1 ) STEAL SWAP ;
: ROT    ( n1 n2 n3 --  n2 n3 n1) STEAL ROT ;
: -ROT   ( n1 n2 n3 --  n3 n1 n2) STEAL -ROT ;
: ><     ( aabb -- bbaa)  STEAL >< ;
: SPLIT  ( AABB --  BB AA ) STEAL SPLIT ;

: 2DROP  ( n n -- ) STEAL 2DROP ;
: 2DUP   ( n1 n2 -- n1 n2 n1 n2 ) STEAL 2DUP ;
: 2SWAP   ( n1 n2 n3 n4-- n3 n4 n1 n2) STEAL 2SWAP ;
: PICK   ( n -- n) STEAL PICK ;

\ ==========================================================================
CR .( R E T U R N   S T A C K)

: RP@     ( -- a ) STEAL RP@ ;
: RP!     ( a -- ) STEAL RP! ;
: >R      ( w -- ) STEAL >R ;
: R>      ( -- w ) STEAL R> ;
: R@      ( -- w ) STEAL R@ ;

\ ==========================================================================
CR .( Shift right & left)

: RSHIFT  ( n bits -- n') STEAL RSHIFT ;
: LSHIFT  ( n bits -- n') STEAL LSHIFT ;

\ ===================================================================
CR .( A R I T H M E T I C)
: 0        DUP  TOS CLR, ;
: 1+      ( n -- n) STEAL 1+ ;
: 1-      ( n -- n) STEAL 1- ;
: 2+      ( n -- n) STEAL 2+ ;
: 2-      ( n -- n) STEAL 2+ ;
: 2*      ( n -- n) STEAL 2* ;
: 2/      ( n -- n) STEAL 2/ ;
: INVERT  ( w w -- w) STEAL INVERT ;
: +       ( u1 u2 -- u ) STEAL + ;
: -       ( u1 u2 -- u ) STEAL - ;
: *       ( n n -- n) STEAL * ;

\ : UM+    ( u u -- u cy ) STEAL UM+ ;        \ or ( u u -- ud )
\ : M+      ( d n -- d )  STEAL M+ ;        \ add single to double
: UM*     ( n n -- d)   STEAL UM* ;
\ : UM/MOD  ( ud u1 -- u2 u3 ) STEAL UM/MOD ;

: 0=   STEAL 0= ;


\ ===================================================================
\ VDP primitives
: VC@   STEAL VC@ ;
: VC!   STEAL VC! ;
: V@    STEAL V@ ;
: V!    STEAL V! ;
: VWTR  STEAL VWTR ;


\ *******************************************************************
\                   *** TEST CODE ***
\ *******************************************************************
\ Create subroutines using inline primitivies
SUB: ADD1    1+ ;SUB
SUB: ADD2    2+ ;SUB

\ Use the sub-routines
SUB: ADD3
    ADD1
    ADD2
;SUB

SUB: ADD4   ADD3   1+  ;SUB

\ use RUN inside Forth definition
: RUNTEST   ADD4 RUN  ;

\ put numbers on the data stack and subtract
SUB: #TEST   HEX # DEAD  # BEEF  -  ;SUB

\ X and Y are not Forth data structures.
\ They can only be used in SUB: ;SUB   definitions
VARIABLE X
2 CONSTANT Y

SUB: DOLOOP
    # FFFF  0 ( 0 is an optimzed word )
    DO
        Y X +!
    LOOP
;SUB

SUB: WHILELOOP
    # FFFF
    BEGIN
        DUP
    WHILE
        1-
    REPEAT
    DROP
;SUB  \ 2.81 seconds

HEX
SUB: UNTILOOP
      # FFFF BEGIN  1- DUP  0= UNTIL
;SUB \ 3.8 seconds
\ ITC speed = 10.75 secs.

SUB: FORLOOP     # FFFF FOR  NEXT  ;SUB

DECIMAL \ 64K iterations as 2 nested loops
SUB: NESTED
    # 256 FOR
        # 256 FOR
        NEXT
    NEXT
;SUB