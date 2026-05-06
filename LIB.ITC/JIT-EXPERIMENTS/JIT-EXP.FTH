\ jit.fth Compiles inline code as headless words in HEAP  Nov 29 2022

\ Problem:
\ ITC Forth spends 50% of it's time running 3 instructions call NEXT.
\ This system compiles primitives from the kernel as super-instructions
\ and compiles the execution token for the super instructions in a Forth word.

\ May 5 2026
\ -EXP version is an experiment in optimizing
\ Removes DROP/DUP sequences
\ @ will replace code with symbolic addressing
\ ! will replace code with symbolic addressing

NEEDS .S     FROM DSK1.TOOLS   \ debug
NEEDS ELAPSE FROM DSK1.ELAPSE  \ execution timing
NEEDS CASE   FROM DSK1.CASE
NEEDS LIFO:  FROM DSK1.STACKS
NEEDS MARKER FROM DSK1.MARKER
NEEDS WORDLIST FROM DSK1.WORDLISTS

: EMPTY  S" *CLEAN* MARKER *CLEAN*" EVALUATE ;
MARKER *CLEAN*
EMPTY

HERE

\ Let's record where free low ram starts in case
\ there are other programs using it as well.
H @ CONSTANT CODEMEM

\ messages help with debugging ...
VARIABLE MESSAGES
: ?TYPE  MESSAGES @ IF CR ." -- " TYPE EXIT THEN 2DROP ;
: MSG"   POSTPONE S"  POSTPONE ?TYPE ; IMMEDIATE

10 LIFO: ARGSTK
: >ARG    ARGSTK PUSH  MSG" ARG pushed" ;
: ARG>    ARGSTK POP   MSG" ARG popped" ;
: ARG?  ( -- n) ARGSTK STACK-DEPTH ;
: /ARGS  ARGSTK DUP @  SWAP CELL+ ! ;
: .ARGS   ARG? 0 DO ARG> U. LOOP ;

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
: THERE  ( -- addr) H @ ;  \ returns end of Target memory in Low RAM
: TALLOT ( n -- )   H +! ; \ Allocate n bytes of target memory.
: T,     ( n -- )   THERE ! 2 TALLOT ;  \ "target compile" n into heap

: NEWHEAP ( -- ) CODEMEM  2000 ERASE   CODEMEM  H ! ; \ reset HEAP

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

\ LOOKBACK and REMOVE are used for optimization
: LOOKBACK ( n -- u) CELLS NEGATE THERE + @ ; \ read existing code

VARIABLE REMOVED   \ count number of bytes removed from code
: REMOVE   ( n -- )
    CELLS DUP NEGATE TALLOT  \ removes cells of code in target memory
    THERE OVER ERASE         \ erase for debugging
    REMOVED +!               \ count how many bytes were removed
;

HEX
C136 CONSTANT "DROP"  \ *SP+ R4 MOV,

\ now we can steal code word from the kernel and compile it to target memory
: DUP,   COMPILES DUP ;

VARIABLE TOSFREE

: ?DUP,
    1 LOOKBACK  "DROP" =
    IF   1 REMOVE
    ELSE DUP,
    THEN TOSFREE ON
;

: DROP,   COMPILES DROP  TOSFREE OFF ;
: 1-,    ( n -- n') COMPILES 1-  ; \ TOS DEC,
: #,     ( n -- )  0204 T, ( n) T, ;  \ TOS n LI,

: LIT,   ( -- n) DUP, #, ; \ compile n as literal in TOS

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

WARNINGS OFF
: BEGIN    THERE >CS ; IMMEDIATE  \ push location onto control stack

\ <DO> is CODE preamble to setup return stack.
: DO  ( -- there) COMPILES <DO>   POSTPONE BEGIN ; IMMEDIATE

: LOOP
    0597 T,                   \ *RP INC,
    CS> THERE  0 JNO, <BACK   \ compute offset, compile into JNO
    COMPILES UNLOOP           \ collapse stack frame
; IMMEDIATE

: +LOOP ( n --)
    A5C4 T,                   \ TOS *RP ADD,
    DROP,                     \ don't need TOS value now
    CS> THERE  0 JNO, <BACK   \ compute offset, compile into JNO
    COMPILES UNLOOP           \ collapse DO/LOOP rstack frame
; IMMEDIATE

HEX
: I   COMPILES I ; IMMEDIATE
: J   COMPILES J ; IMMEDIATE

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
WARNINGS ON
\ --------------------------------------------------------------

FORTH DEFINITIONS
\ CFA of a code word contains the address of the next cell
: CODE? ( XT -- ?)  DUP @ 2- = ;

HEX
0204 CONSTANT 'LI'  \ LI R4,   instruction
C120 CONSTANT 'X@'  \ fetch from memory

\ machine code optimizers for symbolic fetch and store use symbolic addressing
: FAST@,   ( addr -- )  C120 T,  T,  ; \ MOV @ADDR,R4
: FAST!,   ( addr -- )  C804 T,  T,  ; \ MOV R4,@ADDR
: MEM2MEM,    ( addr1 addr2 -- ) C820 T,  T,  T, ; \ mem2mem move

\ test if an address has been compiled as LITERAL
: DATA-ARG? ( -- ?)  2 LOOKBACK  'LI' =  ARG? AND ;

: OPT@,
    DATA-ARG?
    IF
        4 REMOVE         \ removes: DUP,  #,  ( 8 bytes)
        ?DUP,            \ compile DUP if we must
        ARG>  FAST@,
    ELSE
        ARG> DROP
        COMPILES @
    THEN
;

\  store is complicated if we want to use 9900 mem2mem feature
HEX
: OPT!, ( -- )
\ Condition I:  previous instruction was a fetch from memory
                \ 2000 10 DUMP
    6 LOOKBACK  \ DUP  CR ." 2 LB= " HEX U.
    'X@' =
    ARG? AND   \ look for fetch & address argument
    IF  CR ." mem2mem"
        5 LOOKBACK   \ get the address part
        8 REMOVE     \ remove 6 CELLS
        ( dst) ARG> SWAP  MEM2MEM,  \ replace with 3 cells
        EXIT         \ get out early
    THEN

\ Condition II:  literal in TOS register
    DATA-ARG?
    IF \ CR ." lit addr !"
        4 REMOVE
        ARG> FAST!,
        DROP,           \ refill TOS
    ELSE
       COMPILES !
    THEN
;


\ -----------------------------------------------
: FASTC@,   ( addr -- )  D120 T,  T,  0984 T, ;

: OPTC@,
    DATA-ARG?
    IF
        4 REMOVE         \ removes: DUP,  #,  ( 8 bytes)
        ?DUP,            \ compile DUP if we must
        ARG>  FASTC@,
    ELSE
        COMPILES C@
    THEN
;


: FASTC!,   ( addr -- )  06C4 T, D804 T,  T,  ;
: OPTC!,
    DATA-ARG?
    IF
       4 REMOVE
       ARG> FASTC!,
       DROP,           \ refill TOS
    ELSE
       COMPILES C!
    THEN
;

\ Some code words can be optimized.
VARIABLE OPTIMIZER

: OPT-CODE, ( xt -- )
    OPTIMIZER @ 0= IF  CODE,   EXIT  THEN

    CASE
        ['] @ OF  OPT@,   ENDOF
        ['] ! OF  OPT!,   ENDOF

        ['] C@ OF OPTC@,  ENDOF
        ['] C! OF OPTC!,  ENDOF

     ( default:)
    \ NO optimizer code so compile Forth's code
               DUP CODE,
    ENDCASE
;

\ *CHANGE*
\ In this version data words compile with LI instruction but..
\ the address is also pushed onto the ARG stack.
\ The arg stack is a proxy for a "data type is present"
\ Literal numbers do NOT echo onto the ARG stack.
\ The original code using LI is compiled as the decault.
\ But the compiler can REMOVE that code if it sees the right signals.

\ The advantage is that if we can't optimize then we do nothing and
\ the existing code will still work.

: JITCOMPILE,  ( xt -- )
    DUP CODE? IF   OPT-CODE,   EXIT  THEN  \ compile kernel code & exit
    \ xt is not a code word...
    DUP @   \ FETCH the "executor" address
    CASE ( data words )
        ['] DOVAR    OF  EXECUTE DUP >ARG LIT, ENDOF
        ['] DOCON    OF  EXECUTE DUP >ARG LIT, ENDOF
        ['] DOUSER @ OF  EXECUTE DUP >ARG LIT, ENDOF
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

\ 'IV  is CAMEL99 "interpreter vector" variable
\ We can change the interpeter's action with it.
: FORTH-COMPILER  ['] <INTERP> 'IV ! ;
: JIT-COMPILER    ['] <JIT>    'IV ! ;

: JIT: ( -- JIT-xt)
    REMOVED OFF     \ Reset the counter variable
    /ARGS           \ reset the ARG stack
    ALSO JITS       \ put JITS VOCABULARY first in search order
    HEADER          \ put the name in dictionary
    THERE ,         \ Compile code address in the dictionary
    !CSP            \ remember the stack address
    JIT-COMPILER ]  \ switch to JIT compiler loop. STATE=true
;

: ;JIT ( JIT-XT -- )
    PREVIOUS         \ restore previous search order
    FORTH-COMPILER   \ back to Forth compiler loop
    'NEXT' T,        \ compile NEXT at end of new code word
    POSTPONE [       \ compile code to turn off compiler
    ?CSP             \ test the data stack is same beginning
    ?CS              \ check control flow stack is empty
; IMMEDIATE

HERE SWAP -
CR DECIMAL . .( bytes)
NEWHEAP CR .( HEAP is reset to >2000)

\         *** IMPORTANT ***
\ There can be NO code on the  'JIT: <name>'  line
\ JIT: TESTDO
\  -1 0 DO I DROP LOOP
\ ;JIT
