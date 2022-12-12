\ jit.fth Compiles inline code as headless words in HEAP  Nov 29 2022

\ Problem:
\ ITC Forth spends 50% of it's time running 3 instructions call NEXT.
\ This system compiles primitives from the kernel as super-instructions
\ and compiles the execution token for the super instructions in a Forth word.

\ NEEDS .S     FROM DSK1.TOOLS
\ NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS WORDLIST FROM DSK1.WORDLISTS

NEEDS CASE   FROM DSK1.CASE
NEEDS LIFO:  FROM DSK1.STACKS
NEEDS MARKER FROM DSK1.MARKER

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
: NEW-HEAP ( -- ) 2000 2000 0 FILL   2000 H ! ; \ reset HEAP

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

\ now we can steal code word from the kernel and compile it to target memory
: DUP,   COMPILES DUP ;
: DROP,  COMPILES DROP ;
: 1-,    ( n -- n') COMPILES 1-  ; \ TOS DEC,

: LIT,   ( -- n) DUP,  0204 T, ( n) T, ; \ compile n as literal in TOS

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

: AGAIN   CS> THERE 0 JMP, <BACK ; IMMEDIATE

: UNTIL
          1-,
          DROP,
          CS> THERE 0 JNC, <BACK ; IMMEDIATE

: IF    ( n -- )
           1-,       \ If tos=0, DEC will cause a carry
           DROP,
           THERE >CS 0 JNC, ; IMMEDIATE

: THEN     CS> THERE OVER - RESOLVE ; IMMEDIATE

: ELSE     THERE >CS  0 JMP,
            CS>SWAP POSTPONE THEN ; IMMEDIATE

: WHILE   ( n -- ) POSTPONE IF CS>SWAP ; IMMEDIATE

: REPEAT   POSTPONE AGAIN  POSTPONE THEN ; IMMEDIATE

\ --------------------------------------------------------------

ONLY FORTH DEFINITIONS
\ CFA of a code word contains the address of the next cell
: CODE? ( XT -- ?)  DUP @ 2- = ;

: JITCOMPILE,  ( xt -- )
          DUP CODE? IF  CODE,   EXIT  THEN  \ compile kernel code & exit
  \ xt is not a code word...
          DUP @   \ FETCH the "executor" address
          CASE ( data words )
             ['] DOVAR    OF  >BODY   LIT, ENDOF
             ['] DOCON    OF  EXECUTE LIT, ENDOF
             ['] DOUSER @ OF  EXECUTE LIT, ENDOF
             TRUE ABORT" Can't optimize word"  ( any other Forth word bombs)
         ENDCASE
;

\ new interpreter loop
\ 1. Executes Immediate words: BEGIN WHILE IF THEN etc.
\ 2. Steals kernel code and compiles any CODE word.
\ 3. ABORTS if you try to compile a Forth word
\ 4. Compiles literal numbers with LI instruction

: <JIT> ( -- addr)
         'SOURCE 2!  >IN OFF
          BEGIN
             BL WORD  DUP C@
          WHILE
              FIND ?DUP
              IF ( it's a word)
                  1+ STATE @ 0= OR
                  IF   EXECUTE      \ IF BEGIN etc. are all immediate
                  ELSE JITCOMPILE,  \ code and data are not
                  THEN
              ELSE
                  COUNT NUMBER? ?ERR
                  STATE @ IF LIT, THEN  \ special number compiler
              THEN
              DEPTH 0< ABORT" JIT: Underflow"
          REPEAT
          DROP
;

: JIT: ( -- JIT-xt)
        ALSO JITS         \ put JITS VOCABULARY first in search order
        :
         THERE ( -- XT)   \ execution token (XT) for the NEW compiled code
         DUP CELL+ T,     \ create the ITC header for a CODE word
         ['] <JIT> 'IV !  \ switch to JIT compiler
;

: ;JIT ( JIT-XT -- )
        PREVIOUS          \ restore previous search order
        ['] <INTERP> 'IV !
         'NEXT' T,        \ compile NEXT at end of new code word
         ,                \ compile CODE word's XT into Forth definition
        ?CS
        POSTPONE ;
; IMMEDIATE

ONLY FORTH ALSO FORTH DEFINITIONS

HERE SWAP - SPACE DECIMAL . .( bytes)
