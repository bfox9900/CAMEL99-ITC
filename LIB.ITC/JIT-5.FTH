\ jit-II.fth Compiles inline code as headless words in HEAP  Nov 29 2022

\ Problem:
\ ITC Forth spends 50% of it's time running 3 instructions call NEXT.
\ This system compiles primitives from the kernel as super-instructions
\ and compiles the execution token for the super instructions in a Forth word.

\ Version II compiles code into dictionary ram as CODE definitions.

\ Version III uses a literal stack to allow optimizing AND
\ It replaces fetches and stores with symbolic addressing

\ Version IV adds stuff to the optimizers.

\ Version 5 puts CONSTANTS and addresses on the ARG stack

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
\ *If the 1st word in a JIT: definition is a variable
\  we need to force it into the TOS.
VARIABLE 1STVAR

10 LIFO: ARGSTK
: >ARG    ARGSTK PUSH  1STVAR  OFF ;
: ARG>    ARGSTK POP ;
: #ARGS  ( -- n) ARGSTK STACK-DEPTH ;
: /ARGS  ARGSTK DUP @  SWAP CELL+ ! ;
: .ARGS   #ARGS 0 DO ARG> U. LOOP ;

8 LIFO: CS     \ small CONTROL FLOW STACK for loops and branching
: >CS     ( n -- ) CS PUSH ;
: CS>     ( -- n ) CS POP ;
: CS>SWAP ( -- )   CS> CS> SWAP >CS >CS ;
: ?CS     CS STACK-DEPTH ABORT" Un-matched IF or loop words" ;

: FORTH-COMPILER  ['] <INTERP> 'IV ! ;

: ABORT"  ( ? --) \ restores normal Forth interpreter
     DUP IF FORTH-COMPILER
            /ARGS    ( collapse ARGSTK)
            POSTPONE ABORT"
     THEN  ; IMMEDIATE

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

\ optimizer language to help clarify logic
: OPTIMIZER: : ;
: ;OPTIMIZER  POSTPONE CODE,  POSTPONE ;  ; IMMEDIATE

: CASE:       POSTPONE IF POSTPONE DROP ; IMMEDIATE
: ;CASE       POSTPONE EXIT POSTPONE THEN ; IMMEDIATE

\ ================================================
\     ATTEMPT TO OPTIMIZE DROP/DUP sequences
VARIABLE TOSFREE

VARIABLE #DUPS  \ TRUE = TOS REGISTER IS FREE TO USE
: #DUPS++  #DUPS 1+! ;
: #DUPS--  #DUPS DUP @ 0= ABORT" #DUPS = 0"  1-! ;

: DUP,   COMPILES DUP    #DUPS++  TOSFREE ON ;
: DROP,  COMPILES DROP   #DUPS--  TOSFREE OFF ;

: LOOKBACK ( n -- u) CELLS NEGATE HERE + @ ; \ read existing code
: REMOVE   ( n -- )  CELLS NEGATE ALLOT ; \ removes cells of code

\ push/pop optimizer
HEX
C136 CONSTANT "DROP"  \ *SP+ R4 MOV,

: ?DUP,
    1 LOOKBACK "DROP" = IF  1 REMOVE  TOSFREE ON  EXIT THEN
    TOSFREE @ 0= IF   DUP,        EXIT THEN
    1STVAR @     IF   DUP,        EXIT THEN
    DUP,
;

\ =================================================
HEX
\ compile code to load TOS ( r4 ) with n
: #,     0204 ,  ,  ; \ LI R4,<n>
: LIT,   ( n -- )  ?DUP, #, ;

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


OPTIMIZER: OPT@, ( xt --)
    #ARGS 1 = CASE:  ARG> @ LIT,   ;CASE \ replace address with value
;OPTIMIZER

OPTIMIZER: OPTC@, ( xt -- )
    #ARGS 1 = CASE:   ARG> C@ LIT,   ;CASE
;OPTIMIZER

OPTIMIZER: OPT!,
    #ARGS 1 = CASE:  TOS ARG> @@ MOV, DROP,   ;CASE

;OPTIMIZER

OPTIMIZER: OPTC!,
    #ARGS CASE:
           1 (SP) ARG> @@ MOVB,  SP INCT,  DROP,
        ;CASE
;OPTIMIZER

0204 CONSTANT "LI"    \ load imm. to R4
C136 CONSTANT "DROP"

OPTIMIZER: OPT+, ( xt -- )
\ 2 literal number added together
    2 LOOKBACK "LI" =  6 LOOKBACK "LI" = AND
    CASE:
       1 LOOKBACK 5 LOOKBACK + ( -- sum) \ read literals and add them
       8 REMOVE \ get rid of old code
       ( -- sum) LIT,     \ compile sum as a literal
   ;CASE

\ case of literal and address argument (ie: a variable)
    2 LOOKBACK "LI" =  #ARGS 0> AND
    CASE:
        1 LOOKBACK ARG> + ( sum ) \ literal + address
        4 REMOVE
        LIT,
    ;CASE

   \ address pending on argument stack
     #ARGS CASE:  TOS ARG> AI,   ;CASE  \ 22 clocks
;OPTIMIZER


\ specific CODE word and optimizers
\ If the case statemente can't find it, just compile kernel code
: OPT-CODE,
    DUP
    CASE
        ['] @ OF    OPT@,   ENDOF
        ['] C@ OF  OPTC@,   ENDOF

        ['] ! OF    OPT!,   ENDOF
        ['] C! OF  OPTC!,   ENDOF

        ['] +  OF  OPT+,    ENDOF

\        ['] DUP OF ?DUP,    ENDOF

             CODE,  \ default, compile kernel code
    ENDCASE
;

: VAR-HANDLER ( XT)
   1STVAR @
   IF   >BODY LIT, \ 1st var has to be compiled
   ELSE >BODY >ARG
   THEN
;

: CONST-HANDLER ( XT --)
    >BODY @
    CASE
       0 OF  ?DUP,  TOS CLR,  ENDOF
      -1 OF  ?DUP,  TOS SETO, ENDOF
             DUP LIT,
    ENDCASE
;

: OPT-DATA ( xt -- ) \
    DUP
    @     \ FETCH the "executor" address
    CASE  \ compare to executor words
        ['] DOVAR    OF  VAR-HANDLER   ENDOF \ push address onto literal stack
        ['] DOCON    OF  CONST-HANDLER  ENDOF
        ['] DOUSER @ OF  EXECUTE LIT,  ENDOF
\       ['] DOCOL    OF  >BODY RECURSE  ENDOF \ future? :-)
        TRUE ABORT" Can't optimize word"
    ENDCASE
;

: JITCOMPILE,  ( xt -- )=
    DUP CODE?
    IF
      OPT-CODE,   \ compile kernel code inline
    ELSE
      OPT-DATA    \ handle everything else
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

: JIT-COMPILER    ['] <JIT>  'IV ! ;

: JIT: ( -- JIT-xt)
    ALSO JITS         \ put JITS VOCABULARY first in search order
    CODE
    JSTATE ON
    /ARGS              \ clear the literal stack
    JIT-COMPILER
;

: ;JIT ( JIT-XT -- )
    PREVIOUS          \ restore previous search order
    FORTH-COMPILER
    JSTATE OFF
    NEXT,            \ compile NEXT at end of new code word
    #ARGS IF CR ." WARNING: LIT stack contains " CR ." >> ".ARGS THEN
    ?CS              \ check control flow stack
    ENDCODE
; IMMEDIATE

HERE SWAP - SPACE DECIMAL CR . .( bytes)
