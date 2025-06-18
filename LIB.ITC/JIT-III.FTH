\ jit-II.fth Compiles inline code as headless words in HEAP  Nov 29 2022

\ Problem:
\ ITC Forth spends 50% of it's time running 3 instructions call NEXT.
\ This system compiles primitives from the kernel as super-instructions
\ and compiles the execution token for the super instructions in a Forth word.

\ Version II compiles code into dictionary ram as CODE definitions.

\ Version III uses a literal stack to allow optimizing

NEEDS .S     FROM DSK1.TOOLS   \ debug
NEEDS ELAPSE FROM DSK1.ELAPSE  \ execution timing
NEEDS CASE   FROM DSK1.CASE
NEEDS LIFO:  FROM DSK1.STACKS
NEEDS WORDLIST FROM DSK1.WORDLISTS

VOCABULARY ASSEMBLER
ALSO ASSEMBLER DEFINITIONS

INCLUDE DSK1.ASM9900

ONLY FORTH ALSO ASSEMBLER ALSO FORTH DEFINITIONS


HERE

10 LIFO: LITSTK
: >LIT    LITSTK PUSH ;
: LIT>    LITSTK POP ;
: LIT?  ( -- n) LITSTK STACK-DEPTH ;
: /LIT  LITSTK DUP @  SWAP CELL+ ! ;
: .LS   LIT? 0 DO LIT> U. LOOP ;

8 LIFO: CS     \ small CONTROL FLOW STACK for loops and branching
: >CS     ( n -- ) CS PUSH ;
: CS>     ( -- n ) CS POP ;
: CS>SWAP ( -- )   CS> CS> SWAP >CS >CS ;
: ?CS     CS STACK-DEPTH ABORT" Un-match IF or loop words" ;

: FORTH-COMPILER  ['] <INTERP> 'IV ! ;

: ABORT"  ( ? --) \ restores normal Forth interpreter
     DUP IF FORTH-COMPILER
            /LIT    ( collapse litstk)
     THEN  POSTPONE ABORT" ; IMMEDIATE

HEX
\ *** changed for kernel V2.69 ***
\ Words in scratchpad RAM end in a JMP instruction, not NEXT
\ Might change this, but for now make some conventional versions.
CODE DUP    0646 , C584 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE
CODE !      C536 , C136 ,  NEXT, ENDCODE
CODE @      C114 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE


045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
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

: COMPILES ( <codeword> ) POSTPONE [']  POSTPONE CODE, ; IMMEDIATE

\ tiny assemblers to explain the code
HEX
: 1-,    ( n -- n') COMPILES 1-  ; \ TOS DEC,


\ ================================================
\     ATTEMPT TO OPTIMIZE DROP/DUP sequences

VARIABLE TOSFREE  \ TRUE = TOS REGISTER IS FREE TO USE

: DUP,   COMPILES DUP    TOSFREE ON  ;
: DROP,  COMPILES DROP   TOSFREE OFF ;
\ =================================================


: LIT,   ( n -- )  COMPILES DUP  0204 ,  , ; \ LI R4,<n>

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

\ --------[ JIT compilers for LOOPS and BRANCHING ]---------
\ When the JITS wordlist is placed 1st in the search order
\ these immediate words will run in place of their normal Forth versions.
\ These version compile machine code into the HEAP.
\ In the case of DO it "steals" the code for setting up the loop
\ from the kernel.

VOCABULARY JITS
ALSO JITS DEFINITIONS

: BEGIN    HERE >CS ; IMMEDIATE  \ push location onto control stack

\ <DO> is CODE preamble to setup return stack.
: DO  ( -- HERE)
   COMPILES <DO>   POSTPONE BEGIN
; IMMEDIATE

: LOOP
    0597 ,                   \ *RP INC,
    CS> HERE  0 JNO, <BACK   \ compute offset, compile into JNO
    COMPILES UNLOOP          \ collapse stack frame
; IMMEDIATE

: +LOOP
    0A5CA ,          \ TOS *RP ADD,
    DROP,            \ don't need TOS value anymore
    POSTPONE LOOP    \ compile loop code
; IMMEDIATE

: I  COMPILES I ;  IMMEDIATE
: J  COMPILES J ;  IMMEDIATE

: AGAIN   CS> HERE 0 JMP, <BACK ; IMMEDIATE

: UNTIL
    1-,
    DROP,
    CS> HERE 0 JNC, <BACK ; IMMEDIATE

: IF    ( n -- )
    1-,       \ If tos=0, DEC will cause a carry
    DROP,
    HERE >CS 0 JNC, ; IMMEDIATE

: THEN  CS> HERE OVER - RESOLVE ; IMMEDIATE

: ELSE  HERE >CS  0 JMP,
        CS>SWAP POSTPONE THEN ; IMMEDIATE

: WHILE  ( n -- ) POSTPONE IF CS>SWAP ; IMMEDIATE

: REPEAT  POSTPONE AGAIN  POSTPONE THEN ; IMMEDIATE


\ --------------------------------------------------------------

FORTH DEFINITIONS
\ CFA of a code word contains the address of the next cell
: CODE? ( XT -- ?)  DUP @ 2- = ;

VARIABLE XT-TYPE  \ future ...
: ISVAR   1 XT-TYPE ! ;
: ISCONST 2 XT-TYPE ! ;
: ISUSER  3 XT-TYPE ! ;
: ISCODE  4 XT-TYPE ! ;

: OPT@, ( xT 'XT)
    LIT? 0=
    IF CODE,  \ if not literal found, the argument is already on the stack
    ELSE
        DROP  \ don't need xt of kernel code.
    \ this is the optimized code
       DUP,
       LIT> @@ TOS MOV,  \ compile symbolic addressing code
    THEN
;

 : OPTC@, ( xT 'XT)
    LIT? 0=
    IF CODE,  \ if not literal found, the argument is already on the stack
    ELSE
        DROP  \ don't need xt of kernel code.
    \ this is the optimized code
       DUP,
       LIT> @@ TOS MOVB,  \ compile symbolic addressing code
       TOS 8 SRA,
    THEN
 ;

: OPT!,
    LIT? 0=
    IF CODE,
    ELSE
        DROP  \ don't need xt of kernel code.
    \ this is the optimized code
        TOS LIT> @@ MOV,   \ compile stack-> memory instruction
        DROP,              \ to refill TOS
    THEN
;

: OPTC!,
    LIT? 0=
    IF CODE,
    ELSE
        DROP  \ don't need xt of kernel code.
    \ this is the optimized code
        1 (SP) LIT> @@ MOVB,  \  26
        SP INCT,              \  10   inc. stack pointer by 2
        DROP,                 \ to refill TOS
    THEN
;

: OTHERS, ( xt -- ) \
    DUP
    @     \ FETCH the "executor" addres
    CASE  \ compare to executor words
        ['] DOVAR    OF  >BODY   >LIT  ENDOF
        ['] DOCON    OF  >BODY @ LIT,  ENDOF
        ['] DOUSER @ OF  EXECUTE LIT,  ENDOF
\       ['] DOCOL    OF  >BODY RECURSE  ENDOF     \ future? :-)
        TRUE ABORT" Can't optimize word"
    ENDCASE
;

\ specific CODE word and optimizers , otherwise just compile kernel code
: OPT-CODE,
    DUP
    CASE
        ['] @ OF    OPT@,   ENDOF
        ['] C@ OF  OPTC@,   ENDOF

        ['] ! OF    OPT!,   ENDOF
        ['] C! OF  OPTC!,   ENDOF
                    CODE,  \ default, compile kernel code
    ENDCASE
;

: JITCOMPILE,  ( xt -- )
    DUP CODE?
    IF
       OPT-CODE,    \ compile kernel code inline
    ELSE
       OTHERS,   \ handle everything else
    THEN
;

\ new interpreter loop
\ 1. Executes Immediate words: BEGIN WHILE IF THEN etc.
\ 2. Steals kernel code and compiles any CODE word.
\ 3. ABORTS if you try to compile a Forth word
\ 4. Compiles literal numbers with LI instruction

VARIABLE JSTATE

: <JIT> ( -- )
    'SOURCE 2!  >IN OFF
    BEGIN
        BL WORD  DUP C@
    WHILE
        FIND ?DUP
        IF ( it's a word)
            1+ JSTATE @ 0= OR
            IF   EXECUTE      \ IF BEGIN etc. are all immediate
            ELSE JITCOMPILE,
            THEN
        ELSE
            COUNT NUMBER? ?ERR
            JSTATE @ IF LIT, THEN  \ special number compiler
        THEN
        DEPTH 0< ABORT" JIT: Underflow"
    REPEAT
    DROP
;

: JIT-COMPILER    ['] <JIT>    'IV ! ;

: JIT: ( -- JIT-xt)
    ALSO JITS         \ put JITS VOCABULARY first in search order
    CODE
    JSTATE ON
    /LIT              \ clear the literal stack
    JIT-COMPILER
;

: ;JIT ( JIT-XT -- )
    PREVIOUS          \ restore previous search order
    FORTH-COMPILER
    JSTATE OFF
    NEXT,            \ compile NEXT at end of new code word
    LIT? IF CR ." WARNING: LIT stack contains " CR ." >> ".LS THEN
    ?CS              \ check control flow stack
    ENDCODE
; IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes)

VARIABLE X
VARIABLE Y
HEX
JIT: TEST1
    FFFF 0
    DO
       X C@ DROP
    LOOP
;JIT

' TEST1 >BODY
.S
