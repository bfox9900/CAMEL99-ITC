\ VDP STRINGS Forth style stack strings in VDP Memory 31May2022  Brian Fox
\ This saves lots of dictionary space in your program

\ Method:
\ Strings are stored in VDP RAM as counted strings. (1st byte is length)
\ When we invoke the string's name, it returns a VDP stack string.
\ that is a VDP address and a length.
\ With stack strings we don't cut strings to make a sub-strings.
\ We simply adjust the address and length on the Data stack. Very fast!
\
\ Concatenation uses a temp buffer in Low RAM but writes the result back
\ to VDP RAM in unallocated space. The result can be assigned to string variable
\ if that is required.

  NEEDS DUMP   FROM DSK1.TOOLS    \ For debugging
  NEEDS ELAPSE FROM DSK1.ELAPSE   \  for speed testing
  NEEDS VHERE   FROM DSK1.VDPMEM
HERE

DECIMAL
 255 CONSTANT MXLEN   \ 255 bytes is longest string

: HEAP    ( -- addr) H @  ;  \ returns free memory location in LOW RAM

\ ====================================
\ VDP string primitives

\ : VPLACE  ( addr len vaddr -- )  *THIS WORD IS IN THE KERNEL*

\ convert a VDP counted string to a stack string
\ : VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ; ( in DSK1.VDPMEM)

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ read VDP string into temp memory in HEAP, return HEAP address
: VGET$   ( vaddr len -- addr) TUCK  HEAP DUP>R CHAR+ SWAP VREAD  R@ C!  R> ;

\ concat Vstring to CPU string
: V+PLACE ( vaddr len addr -- ) 2DUP 2>R COUNT +  SWAP VREAD 2R> C+! ;

: >VHERE  ( addr len -- Vaddr len) VHERE VPLACE  VHERE VCOUNT ;

\ a bit complicated but it works
: &        ( Vaddr len Vaddr len -- Vaddr len )
           2SWAP VGET$  ( -- heap)             \ get 1st Vstring into HEAP
           V+PLACE                             \ concat 2nd Vstring
           HEAP DUP C@  MXLEN > ABORT" VDP string >255 bytes"
           COUNT >VHERE
;

\ ====================================
\ Replicate TI-BASIC string functions
: VASC    ( vaddr len -- c) DROP VC@ ;
: VLEN    ( vaddr len -- vaddr len len)  DUP ; \ makes a copy of length

: VAL$    ( vaddr len - # ) VGET$ COUNT NUMBER? ?ERR ;

\ These words DO NOT CUT THE STRING; they return a new (Vaddr,len) pair
: VLEFT$  ( vaddr len len' -- vaddr len') NIP ;
: VRIGHT$ ( vaddr len len' -- vaddr len') 1- /STRING ;
: VSEG$   ( vaddr len n1 n2 -- vaddr len) >R VRIGHT$  R> VLEFT$ ;

\ STR$ & CHR$ return a stack string in VDP memory
\ you need to store the result in a VDP string to keep it
: VSTR$    ( n -- Vaddr len) (.) >VHERE ;

\ uses ascii# as an offset into unallocated VDP RAM
\ ie: each char has it's own 1 byte buffer :-)
: VCHR$    ( ascii# -- Vaddr len) DUP VHERE + TUCK VC!  1  ;

\ ===============================
\ Extra string functions
HEX CODE RDROP   05C7 , NEXT, ENDCODE  \ used 4x

DECIMAL
: VTRIM  ( Vadr len char -- Vadr len') \ remove ALL trailing char
         >R
         1-
         BEGIN
            DUP
         WHILE
           2DUP +  VC@ R@ =   \ compare last character
         WHILE
           1-                 \ while char is a match, decrement length
         REPEAT
         THEN
         1+
         RDROP ;

: VSKIP  ( Vadr len char -- Vadr' len') \ remove ALL leading char
         >R
         BEGIN
            DUP
         WHILE
            OVER VC@ R@ =
         WHILE
            1 /STRING
         REPEAT
         THEN
         RDROP ;

: VSCAN (  Vadr len char -- Vadr' len')
        >R     \ remember char
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER VC@ R@ <>
        WHILE ( R@<>char)
          1 /STRING            \ advance to next char address
        REPEAT
        THEN
        RDROP
;

\ : VCLEAN ( V$ len  -- v$' len') BL VSKIP  BL VTRIM ;

\ add a char onto the end of a VDP stack string
: V+CHAR  ( char Vaddr len -- )
          OVER 1- >R     \ compute address of length byte, rpush
          DUP 1+ R> VC!  \ incr len, store new length in VDP
          + VC! ;        \ compute address of end of string, store char

: VPRINT  ( vaddr len -- ) CR VTYPE ;

\ assign text to a VDP stack string in memory
: V$!    ( addr len Vaddr len -- )  DROP 1-  VPLACE ;
: :="    ( vaddr len -- ) DROP 1- [CHAR] " PARSE ROT VPLACE ;

\ Neil Baud's toolbelt compare, modded for VDP RAM
\  0 means adr1 = adr2
\ -1 means adr1 < adr2
\  1 means adr1 > adr2
: VCOMPARE  ( Vadr1 n1 Vadr2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1) ( R: n2-n1)
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

: (V")  ( Vaddr -- Vaddr' len)
        POSTPONE LITERAL POSTPONE VCOUNT ; IMMEDIATE

\ compile a VDP string literal into a Forth word.
: V"    ( <text> -- Vaddr len)
       ?COMP VHERE
       [CHAR] " PARSE  VS,
       POSTPONE (V") ; IMMEDIATE

\ ================================
\ VDP string data structures

\ create a VDP buffer of size n
: VBUFFER: ( n -- vaddr)  VHERE CONSTANT  VALLOT ;

: VDIM     ( n -- )
          CREATE
             VHERE
             0 VC,        \ init length to zer0
             SWAP VALLOT  \ allocate space
              ,           \ remember the address
          DOES> @ VCOUNT ;

: V$ARRAY  ( items len -- )  \ CREATE array of fixed length strings
          \ compile time action
           CREATE VHERE ,  2DUP ( len) , ( #) , * VALLOT
          \ runtime action
           DOES>  ( n -- vaddr len)
                  2@      ( -- n vaddr len)
                  ROT *   ( -- vaddr offset)
                  +       ( -- vaddr[n] )
                  VCOUNT ;

HERE SWAP - DECIMAL .
