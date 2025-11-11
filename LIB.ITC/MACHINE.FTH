\ EXPERIMENTAL MACHINE FORTH PRIMITIVES

\ This macros are created by stealing code from the KERNEL very much like
\ a conventional compiler would emit code.
\ Use these words to create CODE words that are like Forth but run faster.
\ The biggest speed up is when used with structured assembler loops.
\ Forth loops is always 5X slower than native code loops

NEEDS .S       FROM DSK1.TOOLS
NEEDS INLINE   FROM DSK1.INLINE

NEEDS VOCABULARY FROM DSK1.WORDLISTS

VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
NEEDS BEGIN,   FROM DSK1.ASM9900

ONLY FORTH DEFINITIONS
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
: STEAL ( <codeword> )
   POSTPONE [']   POSTPONE CODE, ; IMMEDIATE

VOCABULARY MACHINE
ONLY FORTH ALSO ASSEMBLER ALSO MACHINE DEFINITIONS

 : CALL     ( dst -- )   \ 6 bytes per call
              R11 RPUSH,       \ 28 save R11 on forth return stack
            ( addr) @@ BL,     \ 16   branch & link saves the PC in R11
;

: RET        R11 RPOP,        \  6 bytes per return
             R11 ** B,
;

\ CALL/RET Overhead:   ITC vs STC on 9900
\                     -----------------------
\                      98     82   STC is 16% faster

\ but bigger code is generated.


\ ==========================================================================
CR .( M E M O R Y  F E T C H  &  S T O R E)

\ ** colon words  compile inline code in a CODE word

: !      ( n addr -- ) STEAL ! ;
: @      ( a -- w )    STEAL @ ;
: 2!     ( d addr -- ) STEAL 2! ;
: 2@     ( addr -- d)  STEAL 2@ ;

: C!     ( c addr -- ) *SP+  W MOV, W SWPB, W *TOS MOVB, TOS POP, ;

: C@      ( addr -- c ) *TOS TOS MOVB,  TOS 8 SRL, ;

: COUNT    STEAL COUNT ;
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
: -ROT   STEAL -ROT ;
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
: 1+      ( n -- n) STEAL 1+;
: 1-      ( n -- n) STEAL 1- ;
: 2+      ( n -- n) STEAL 2+ ;
: 2-      ( n -- n) STEAL 2+ ;
: 2*      ( n -- n) STEAL 2* ;
: 2/      ( n -- n) STEAL 2/ ;
: INVERT  ( w w -- w) STEAL INVERT ;
: +       ( u1 u2 -- u ) STEAL + ;
: *      ( n n -- n) STEAL * ;

: UM+    ( u u -- u cy ) STEAL UM+ ;        \ or ( u u -- ud )
: M+      ( d n -- d )  STEAL M+ ;        \ add single to double
: UM*     ( n n -- d)   STEAL UM* ;
: UM/MOD  ( ud u1 -- u2 u3 ) STEAL UM/MOD ;

HEX
\ compile code to load TOS ( r4 ) with n
: #   ( n -- )  DUP  0204 ,  , ; \ LI R4,<n>

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
    STEAK DROP       \ don't need TOS value anymore
    POSTPONE LOOP    \ compile loop code
; IMMEDIATE

: I  STEAL I ;  IMMEDIATE
: J  STEAK J ;  IMMEDIATE

: AGAIN   CS> HERE 0 JMP, <BACK ; IMMEDIATE

: UNTIL
    1-
    DROP
    CS> HERE 0 JNC, <BACK ; IMMEDIATE

: IF    ( n -- )
    1-,       \ If tos=0, DEC will cause a carry
    DROP
    HERE >CS 0 JNC, ; IMMEDIATE

: THEN  CS> HERE OVER - RESOLVE ; IMMEDIATE

: ELSE  HERE >CS  0 JMP,
        CS>SWAP POSTPONE THEN ; IMMEDIATE

: WHILE  ( n -- ) POSTPONE IF CS>SWAP ; IMMEDIATE

: REPEAT  POSTPONE AGAIN  POSTPONE THEN ; IMMEDIATE
