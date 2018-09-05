\ byte queue using Workspace as replacment for variables

\ Concept here is to replace variables that manage circular pointers
\ with registers in a workspace. This should need less code because registers
\ do not need to be loaded if the workspace is initialized first.
\ It should also run faster because the data is always in registers.

\ Interface to Forth is via the Forth TOS register with the [TOS] macro.

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F

\ DATA =======================
HEX
100        CONSTANT QSIZE  \  size be must power of 2
QSIZE 1-   CONSTANT QMASK  \ used for wrap pointer wrap around

\ data is allocated in Lo memory with MALLOC
QSIZE MALLOC CONSTANT Q      \ points to Q's data
20    MALLOC CONSTANT QREGS  \ points to a workspace for Q operations

\ ============================
\ Compiler Directive to create a BLWP sub-program
\ ... THAT CALLS ITSELF!
: PROG: ( wksp -- )
       CREATE
         ( wksp) ,  HERE CELL+ ,
         !CSP
      ;CODE *W BLWP,
               NEXT,
            ENDCODE

: ;PROG  ( -- ) ?CSP  ;  \ check stack positio for junk left on it.

: [TOS]  8 R13 () ;      \ macro for Forth's TOS register

QREGS PROG: INIT-QREGS        \ code that initializes wksp
        R8 Q LI,      \ R8 holds the Q data buffer address
    	R9   CLR,     \ R9 is the input pointer
    	R10  CLR,     \ R10 is the output pointer
    	RTWP,
      ;PROG

\ Forth word to erase Q data and QREGS and call INIT-REGS
: INIT-Q
        QREGS 20 0 FILL
        Q QSIZE  0 FILL
        INIT-QREGS ;

\ code to enqueue a byte in 'Q'
QREGS PROG: ENQ ( c -- ? ) \ put byte in Q, return error code
        [TOS] SWPB,        \ fix byte order
        R9 INC,            \ inc input pointer
        R9 QMASK ANDI,     \ binary wrap around
        R9 R10 CMP,        \ did we hit the out pointer?
        NE IF,
             [TOS] Q R9 () MOVB, \ move char to Q(R9)
             [TOS] CLR,       \ reset [TOS], as return value
        ELSE,
             [TOS] SETO,      \ return true as error flag
        ENDIF,
        RTWP,                 \ return to Forth
      ;PROG

\ DEQ requires we put a zero on the Forth stack.
\ This makes room on the Forth stack for the return data
QREGS PROG: DEQ ( 0 -- c) \ 0 means bad data
        R9 R10 CMP,             \ is there room in Q
        NE IF,
             R10 INC,           \ bump out pointer
             R10 QMASK ANDI,    \ wrap pointer
             Q R10 () [TOS] MOVB, \ put char in buffer
             [TOS] SWPB,
        ELSE,
             [TOS] SETO,        \ no data, return -1
        ENDIF,
        RTWP,
      ;PROG

\ qdata? requires we put a zero on the Forth stack.
\ This makes room on the Forth stack for the return flag
QREGS PROG: QSTAT ( 0 -- ?) \ true means data waiting
        R9 R10 CMP,
        NE IF,
             [TOS] SETO,
        ENDIF,
        RTWP,
      ;PROG

\ Hi-level Forth API to the sub-programs
: QDATA? ( -- ?) 0 QSTAT ;

: QC!    ( c -- ) ENQ ABORT" Q full" ;
: QC@    ( -- c |-1) 0 DEQ DUP TRUE = ABORT" Q empty" ;
: Q$! ( addr len -- ) BOUNDS DO  I C@ QC! LOOP ;

: QEMIT  ( -- )
        BEGIN
          QDATA?
        WHILE
          QC@ EMIT
        REPEAT ;

: TEST  ( -- )
        INIT-Q
        PAGE ." Testing character Queue"
        BEGIN  
          CR
          CR ." Loading 5 strings into Q..."
          S" String #1. " Q$!
          S" String #2. " Q$!
          S" String #3. " Q$!
          S" String #4. " Q$!
          S" String #5. " Q$!
          CR
          CR ." Reading ALL strings..."
          CR QEMIT CR
          ?BREAK
        AGAIN ;

