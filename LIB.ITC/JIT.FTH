\ jit.fth Compiles inline code as headless words in HEAP  Nov 29 2022

\ Problem:
\ ITC Forth spends 50% of it's time running 3 instructions call NEXT.
\ This system compiles primitives from the kernel as super-instructions
\ and compiles the execution token for the super instructions in a Forth word.

NEEDS .S     FROM DSK1.TOOLS   \ debug
NEEDS ELAPSE FROM DSK1.ELAPSE  \ execution timing
NEEDS CASE   FROM DSK1.CASE
NEEDS LIFO:  FROM DSK1.STACKS
NEEDS WORDLIST FROM DSK1.WORDLISTS

HERE

8 LIFO: CS     \ small CONTROL FLOW STACK for loops and branching
: >CS     ( n -- ) CS PUSH ;
: CS>     ( -- n ) CS POP ;
: CS>SWAP ( -- )   CS> CS> SWAP >CS >CS ;
: ?CS     CS STACK-DEPTH ABORT" Un-match IF or loop" ;

: ABORT"  ( ? --) \ restores normal Forth interpreter
   DUP IF  ['] <INTERP> 'IV ! THEN  POSTPONE ABORT" ; IMMEDIATE

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

\ Heap management
: THERE  ( -- addr) H @ ;  \ returns end of Target memory in HEAP
: HALLOT ( n -- )   H +! ; \ Allocate n bytes of target memory.
: T,     ( n -- )   THERE ! 2 HALLOT ;  \ "target compile" n into heap

: NEWHEAP ( -- ) 2000 2000 0 FILL   2000 H ! ; \ reset HEAP

045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

: CODE,  ( xt --)  \ Read code word from kernel, compile into target memory
    >BODY 80 CELLS  \ 128 bytes is max size we will try to compile
    BOUNDS    ( -- IPend IPstart)
    BEGIN
        DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
    WHILE
        DUP @  ( -- IP instruction)
        T,     \ compile instruction
        CELL+  \ advance IP
        2DUP < ABORT" End of code not found"
    REPEAT
    2DROP
;

: COMPILES ( <codeword> ) POSTPONE [']  POSTPONE CODE, ; IMMEDIATE

\ steal code words from the kernel and compile it to target memory
: DUP,   COMPILES DUP ;
: DROP,  COMPILES DROP ;
: 1-,    ( n -- n') COMPILES 1-  ; \ TOS DEC,

\ tiny assemblers to explain the code
HEX
: TOS!,  ( n )       0204 T,  T, ; \ load n into TOS
: @TOS, ( addr - )   C120 T,  T, ; \ fetch symbolic to TOS

: LIT,   ( n -- )    DUP, TOS!, ; \ compile n as literal in TOS
: JVAR, ( addr -- )  DUP, @TOS,  ;

\ store a byte offset in odd byte of addr.
\ Addr is the location of Jump instruction
: RESOLVE ( addr offset --) 2- 2/ SWAP 1+ C! ;

\ compute offset from addr addr' & complete the jump instruction
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: ?BYTE ( c -- c)  DUP FF00 AND ABORT" Jump out of range" ;

\ compile jump instructions with no offset
: JMP,  ( c --) ?BYTE 1000 + T, ;
: JNO,  ( c --) ?BYTE 1900 + T, ;
: JNC,  ( c --) ?BYTE 1700 + T, ;

\ --------[ JIT compilers for LOOPS and BRANCHING ]---------
\ When the JITS wordlist is placed 1st in the search order
\ these immediate words will run in place of their normal Forth versions.
\ These version compile machine code into the HEAP.
\ In the case of DO it "steals" the code for setting up the loop
\ from the kernel.

VOCABULARY JITS
ALSO JITS DEFINITIONS

: BEGIN    THERE >CS ; IMMEDIATE  \ push location onto control stack

\ <DO> is CODE preamble to setup return stack.
: DO  ( -- there) COMPILES <DO>   POSTPONE BEGIN ; IMMEDIATE

: LOOP
    0597 T,                   \ *RP INC,
    CS> THERE  0 JNO, <BACK   \ compute offset, compile into JNO
    COMPILES UNLOOP           \ collapse stack frame
; IMMEDIATE

: +LOOP
    0A5CA T,         \ TOS *RP ADD,
    DROP,            \ don't need TOS value anymore
    POSTPONE LOOP    \ compile loop code
; IMMEDIATE

: I  COMPILES I ;  IMMEDIATE
: J  COMPILES J ;  IMMEDIATE

: AGAIN   CS> THERE 0 JMP, <BACK ; IMMEDIATE

: UNTIL
    1-,
    DROP,
    CS> THERE 0 JNC, <BACK ; IMMEDIATE

: IF    ( n -- )
    1-,       \ If tos=0, DEC will cause a carry
    DROP,
    THERE >CS 0 JNC, ; IMMEDIATE

: THEN  CS> THERE OVER - RESOLVE ; IMMEDIATE

: ELSE  THERE >CS  0 JMP,
        CS>SWAP POSTPONE THEN ; IMMEDIATE

: WHILE  ( n -- ) POSTPONE IF CS>SWAP ; IMMEDIATE

: REPEAT  POSTPONE AGAIN  POSTPONE THEN ; IMMEDIATE

\ --------------------------------------------------------------

FORTH DEFINITIONS
\ CFA of a code word contains the address of the next cell
: CODE? ( XT -- ?)  DUP @ 2- = ;

: SPECIALS ( xt -- ) \
    DUP
    @     \ FETCH the "executor" address
    CASE  \ compare to know executors
        ['] DOVAR    OF  >BODY   LIT, ENDOF
        ['] DOCON    OF  >BODY @ LIT, ENDOF
        ['] DOUSER @ OF  EXECUTE LIT, ENDOF
        TRUE ABORT" Can't optimize word"  ( any other Forth word bombs)
    ENDCASE
;

: JITCOMPILE,  ( xt -- )
    DUP CODE?
    IF
       CODE,      \ compile kernel code & exit
    ELSE
       SPECIALS   \ xt is not a code word...
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
            ELSE JITCOMPILE,  \ code and data are not
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
: FORTH-COMPILER  ['] <INTERP> 'IV ! ;

: TCODE ( -- addr) HEADER !CSP   THERE , ;

: JIT: ( -- JIT-xt)
    ALSO JITS         \ put JITS VOCABULARY first in search order
    TCODE
    JSTATE ON
    JIT-COMPILER
;

: ;JIT ( JIT-XT -- )
    PREVIOUS          \ restore previous search order
    FORTH-COMPILER
    JSTATE OFF
    'NEXT' T,        \ compile NEXT at end of new code word
    ?CS              \ check control flow stack
    ?CSP
; IMMEDIATE

HERE SWAP -
CR SPACE DECIMAL . .( bytes)
NEWHEAP
