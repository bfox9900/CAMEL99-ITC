\ VDP STRINGS create/print Forth style stack strings IN VDP Memory
\ *Requires V2.69 with DUPXOR

INCLUDE DSK1.TOOLS    \ For debugging
INCLUDE DSK1.ELAPSE   \  "     "
INCLUDE DSK1.MALLOC

\ This saves lots of dictionary space in your program
\ if you need many strings

\
\ Strings are stored in VDP RAM as counted strings. (1st byte is length)
\ When we invoke the string's name it returns a VDP address and a length
\ onto the Forth DATA stack. This is called a "stack string".
\ The power of this method is we don't cut strings to make a sub-strings.
\ We simply adjust the address and length on the Data stack. Very fast!
\

 NEEDS VHERE   FROM DSK1.VDPMEM
\ VDPMEM LIB provides: 
\ VHERE   ( -- addr)
\ VALLOT  ( n -- )  
\ VC,     ( n -- )
\ V,      ( n -- )
\ VCOUNT  ( vdp$adr -- vdpadr len )
\ VCREATE ( <text> -- )

\ R> DROP is used 4 times. RDROP is 8x faster
HEX
CODE RDROP   05C7 ,  NEXT, ENDCODE \ TP INCT, 
DECIMAL
 
\ ====================================
\ VDP STRING PRIMITIVES

\ store CPU string to VDP string
: V$!     ( addr len  vaddr len -- ) DROP 1- VPLACE ;

: VGET$ ( VDP-adr len addr -- ) \ move VDP string to CPU addr
         2DUP C! CHAR+ SWAP VREAD ;
\ compile stack string into VDP memory
: VS,       ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ Print a VDP stack string
: VDPTYPE   ( vdp_addr len -- ) BOUNDS ?DO  I VC@ EMIT  LOOP ;


\ ====================================
\ Replicate TI-BASIC string functions
: VASC      ( vaddr len -- c) NIP VC@ ;
: VLEN      ( vaddr len -- vaddr len)  DUP ; \ makes a copy of length
DECIMAL 
: VAL$     ( vaddr len - # )
            32 MALLOC >R         \ get a temp buffer 32 bytes
            R@ VGET$             \ move string to CPU buff
            R> NUMBER? ABORT" VAL$ err"  \ ABORT if it fails
            32 MFREE ;           \ free the buffer

\ DOES NOT CUT STRING: simply returns a new (address,len) pair
: VLEFT$    ( vaddr len len' -- vaddr len') NIP ;
: VRIGHT$   ( vaddr len len' -- vaddr len') 1- /STRING ;
: VSEG$     ( vaddr len n1 n2 -- vaddr len) >R VRIGHT$  R> VLEFT$ ;

\ >>> VSTR$ VCHR$ return a stack string in CPU memory <<<
\ you can store the result in a VDP string if needed
: VSTR$     ( n -- addr len)  DUP ABS 0 <# #S ROT SIGN #>  ;

\ uses ascii# as an offset into PAD.
\ ie: each char has it's own 1 byte buffer :-)
: VCHR$     ( ascii# -- addr len) DUP PAD + TUCK C!  1 ;

\ ===============================
\ string functions not in BASIC
: VTRIM  ( adr len char -- adr len') \ remove trailing chars
        >R                      \ push CHAR to return stack
        OVER +  1- ( 'start 'end)
        BEGIN
          DUP              \ test if 'start='end
        WHILE
          DUP VC@ R@ =          \ compare to last character
        WHILE                   \ test for match.
          1-                    \ while char is a match, decrement length
        REPEAT
        THEN
        OVER -                  \ compute length
        RDROP ;               \ clean up rstack

: V-TRAILING ( addr len -- addr len') BL VTRIM ;

: VSKIP ( adr len char -- adr len')  \ remove leading chars
        >R     \ remember char
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER VC@ R@ =
        WHILE ( R@<>char)
          1 /STRING            \ advance to next char address
        REPEAT
        THEN
        RDROP  \ drop char   \ 32 bytes
;

: VSCAN (  adr len char -- adr' len')
        >R     \ remember char
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER VC@ R@ <>
        WHILE ( R@<>char)
          1 /STRING            \ advance to next char address
        REPEAT
        THEN
        RDROP  \ drop char   \ 32 bytes
;

\ add a char onto the end of a VDP stack string
: V+CHAR  ( char addr len -- )
          OVER 1- >R     \ compute address of length byte, rpush
          DUP 1+ R> VC!  \ incr len, store new length in VDP
          + VC! ;        \ compute address of end of string, store char

: VPRINT  ( vaddr len -- ) CR VDPTYPE ;


\ assign text to a VDP stack string
: :="    ( vaddr len -- )  [CHAR] " PARSE  2SWAP V$! ;

\ Neil Baud's toolbelt compare, modded for VDP RAM
\  0 means adr1 = adr2
\ -1 means adr1 < adr2
\  1 means adr1 > adr2

: VCOMPARE  ( adr1 n1 adr2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS
    ?DO                       ( a1)
        VCOUNT  I VC@  -      ( a1 diff)
        DUP IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            RDROP
            EXIT
        THEN                  ( a1 diff)
        DROP                  ( a1)
    LOOP DROP                 ( )
    R> DUP IF  0> 1 OR  THEN   \  2's complement arith.
;

: =V$   ( adr len adr len -- ? ) VCOMPARE 0= ;

\ compile a VDP string literal into a Forth word.
\ uses 6 bytes of dictionary space
: V"    ( <text> )
       ?COMP                            \ abort if not compiling
       VHERE                            \ get current VDP address
       [CHAR] " PARSE VS,               \ compile string to VDP RAM
       POSTPONE LITERAL                 \ make VDP address a literal no. 
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


