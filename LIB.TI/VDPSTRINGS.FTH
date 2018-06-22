\ VDP STRINGS create/print Forth style stack strings IN VDP Memory

INCLUDE DSK1.TOOLS.F    \ For debugging
INCLUDE DSK1.ELAPSE.F

\ This saves lots of dictionary space in your program if you need many strings

\ Strings are stored in VDP RAM as counted strings. (1st byte is length)
\ When we invoke the string's name it returns a VDP address and a length
\ onto the Forth DATA stack. This is called a "stack string".
\ The power of this method is we don't cut strings to make a sub-strings.
\ We simply adjust the address and length on the Data stack. Very fast!
\
INCLUDE DSK1.VDPMEM.F    \ vdp MEMORY allocation words

\ ====================================
\ VDP string primitives

: VGET$ ( VDP-adr len addr -- )      \ move VDP string to CPU addr
         2DUP C! CHAR+ SWAP VREAD ;

\ compile stack string into VDP memory
: VS,       ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ convert a VDP counted string to a stack string
: VCOUNT    ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ Print a VDP stack string
: VTYPE     ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;


\ ====================================
\ Replicate TI-BASIC string functions
: VASC      ( vaddr len -- c) NIP VC@ ;
: VLEN      ( vaddr len -- vaddr len)  DUP ; \ just makes a copy of length
: VAL$     ( vaddr len - # )
            20 MALLOC >R         \ get a temp buffer 32 bytes
            R@ VGET$             \ move string to CPU buff
            R> ?NUMBER           \ test if buffer is number
            0= ABORT" VAL$ err"  \ ABORT if it fails
            20 MFREE ;           \ free the buffer

\ DOES NOT CUT STRING: simply returns a new (address,len) pair
: VLEFT$    ( vaddr len len' -- vaddr len') NIP ;
: VRIGHT$   ( vaddr len len' -- vaddr len') 1- /STRING ;
: VSEG$     ( vaddr len n1 n2 -- vaddr len) >R VRIGHT$  R> VLEFT$ ;

\ VSTR$ VCHR$ return a stack string in CPU memory
\ you need to store the result in a VDP string to keep it
: VSTR$     ( n -- addr len)  DUP ABS 0 <# #S ROT SIGN #>  ;

\ uses ascii# as an offset into PAD. 
\ ie: each char has it's own 1 byte buffer :-)
: VCHR$     ( ascii# -- addr len) DUP PAD + TUCK C!  1 ;

\ ===============================
\ string functions not in BASIC
: VTRIM$  ( adr len char -- adr len')  \ remove trailing chars
             >R                      \ push CHAR to return stack
             1-                      \ decr. length on stack
             BEGIN  2DUP + VC@ R@ =  \ compute end char addr, test for match.
             WHILE  1-               \ while char is a match, decrement length
             REPEAT
             1+  R> DROP ;           \ incr. len , clean up rstack

: VSKIP$  ( adr len char -- adr len') \ remove leading chars
             >R                     \ push CHAR to return stack
             BEGIN  OVER VC@ R@ =   \ test char at end of string (adr+len)
             WHILE  1 /STRING       \ while char is a match, cut 1 char off
             REPEAT
             R> DROP ;              \ clean up char from rstack

\ add a char onto the end of a VDP stack string
: V&CHAR  ( char addr len -- )
          OVER 1- >R     \ compute address of length byte, rpush
          DUP 1+ R> VC!  \ incr len, store new length in VDP
          + VC! ;        \ compute address of end of string, store char

\ ===================================
\ HI LEVEL user interface
: VPRINT  ( vaddr len -- ) CR VTYPE ;

\ store CPU string to VDP string
: V$!     ( addr len  vaddr len -- ) DROP 1- VPLACE ;

\ assign text to a VDP stack string
: :="    ( vaddr len -- )  [CHAR] " PARSE  2SWAP V$! ;

\ Neil Baud's toolbelt compare, modded for VDP RAM
\  0 means adr1 = adr2
\ -1 means adr1 < adr2
\  1 means adr1 > adr2

: VCOMP  ( adr1 n1 adr2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS
    ?DO                       ( a1)
        VCOUNT  I VC@  -      ( a1 diff)
        DUP IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT
        THEN                  ( a1 diff)
        DROP                  ( a1)
    LOOP DROP                 ( )
    R> DUP IF  0> 1 OR  THEN   \  2's complement arith.
;

: =V$   ( adr len adr len -- ? ) VCOMP 0= ;

\ compile a VDP string literal into a Forth word.
\ uses 6 bytes of dictionary space
: V"    ( <text> )
       ?COMP                            \ test for compiling, abort if not
       S" [ VHERE ] LITERAL" EVALUATE   \ run-time: compile VDP address
       [CHAR] " PARSE VS,               \ compile-time: string to VDP RAM
       POSTPONE VCOUNT ; IMMEDIATE      \ runtime: convert to addr,len
       
\ ================================
\ VDP string data structures

\ like Forth BUFFER: but create a buffer in VDP memory
: VBUFFER:  ( n <text> -- addr) VHERE CONSTANT  VALLOT ;

\ create a VDP string of size n
: VDIM      ( n -- vaddr len)
            CREATE VHERE , VALLOT
            DOES> @ VCOUNT  ;

: V$ARRAY  ( items len -- )  \ CREATE array of fixed length strings
\ compile time action
           CREATE VHERE ,  2DUP ( len) , ( #) , * VALLOT
\ runtime action
           DOES>  ( n -- vaddr len)
                  2@      ( -- n vaddr len)
                  ROT *   ( -- vaddr offset)
                  +       ( -- vaddr[n] )
                  VCOUNT ;

\ ==============================
\ DEMO code
\ create string variables (the text is compiled one after the other)
DECIMAL
80 VDIM A$
80 VDIM B$
80 VDIM C$    C$ :=" 1234"

\ create string literals (cannot change these)
: Q$       V" The single quote creates a string literal in VDP memory" ;
: DIRTY$   V"                    <<CORE>>                            " ;

\ assigning string variables with $! ("string store")
S" Now is the time for all good men "    A$ V$!
S" to come to the aid of their country." B$ V$!

: TEST
         10 0 DO
            A$ VPRINT
            B$ VPRINT
            Q$ VPRINT
         LOOP ;

: COMPTEST  100 0 DO   Q$ Q$ =V$  DROP   LOOP ;

: TRIMTEST  100 0 DO  DIRTY$ BL VTRIM$  2DROP  LOOP ;

: SKIPTEST  100 0 DO  DIRTY$ BL VSKIP$  2DROP  LOOP ;
: CLEANTEST 100 0 DO  DIRTY$ BL VSKIP$  BL VTRIM$  2DROP  LOOP ;




