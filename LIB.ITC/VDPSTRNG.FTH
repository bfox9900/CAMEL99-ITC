\ VDP STRINGS create/print Forth style stack strings IN VDP Memory
\ This saves lots of dictionary space in your program
\ if you need many strings

\
\ Strings are stored in VDP RAM as counted strings. (1st byte is length)
\ When we invoke the string's name it returns a VDP address and a length
\ onto the Forth DATA stack. This is called a "stack string".
\ The power of this method is we don't cut strings to make a sub-strings.
\ We simply adjust the address and length on the Data stack. Very fast!
\

  NEEDS DUMP   FROM DSK1.TOOLS    \ For debugging
  NEEDS ELAPSE FROM DSK1.ELAPSE   \  for speed testing
  NEEDS VHERE   FROM DSK1.VDPMEM

  DECIMAL
  \ === string stack created above PAD ====
           VARIABLE SSP     \ string stack pointer
       255 CONSTANT MXLEN   \ 255 bytes is longest string
  MXLEN 1+ CONSTANT SSW     \ width of string stack items

  : TOP$     ( -- $) SSP @ PAD + ;
  : NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
  : COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

\ ====================================
\ VDP string primitives
: V@$   ( vaddr len addr -- ) 2DUP C! CHAR+ SWAP VREAD ;
: +V@$  ( vaddr len addr -- ) 2DUP 2>R COUNT +  SWAP VREAD 2R> C+! ;

\ : VPLACE  ( addr len vaddr -- )  *THIS WORD IS IN THE KERNEL*

\ store CPU string to VDP string
: V$!     ( addr len  vaddr len -- ) DROP 1- VPLACE ;

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ convert a VDP counted string to a stack string
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ ====================================
\ Replicate TI-BASIC string functions
: VASC     ( vaddr len -- c) NIP VC@ ;
: VLEN     ( vaddr len -- vaddr len len)  DUP ; \ makes a copy of length
: VAL$     ( vaddr len - # )
            20 MALLOC >R         \ get a temp buffer 32 bytes
            R@ VGET$             \ move string to CPU buff
            R> ?NUMBER           \ test if buffer is number
            0= ABORT" VAL$ err"  \ ABORT if it fails
            20 MFREE ;           \ free the buffer

\ These words DO NOT CUT THE STRING: return a new (address,len) pair
: VLEFT$   ( vaddr len len' -- vaddr len') NIP ;
: VRIGHT$  ( vaddr len len' -- vaddr len') 1- /STRING ;
: VSEG$    ( vaddr len n1 n2 -- vaddr len) >R VRIGHT$  R> VLEFT$ ;

\ STR$ CHR$ returns a stack string in CPU memory
\ you need to store the result in a VDP string to keep it
: STR$     ( n -- addr len)  DUP ABS 0 <# #S ROT SIGN #>  ;

\ uses ascii# as an offset into PAD.
\ ie: each char has it's own 1 byte buffer :-)
: CHR$     ( ascii# -- addr len) DUP PAD + TUCK C!  1 ;

\ ===============================
\ string functions not in BASIC
: V-TRAILING  ( adr len char -- adr len') \ remove trailing chars
             BEGIN
               2DUP + 1- VC@         \ fetch last character
        BL = WHILE                   \ test for match.
               1-                    \ while char is a match, decrement length
             REPEAT ;

: VSKIP  ( adr len char -- adr len') \ remove leading chars
             >R                      \ push CHAR to return stack
             BEGIN
               OVER VC@              \ fetch 1st char
        R@ = WHILE                   \ test for match
                1 /STRING            \ while char is a match, cut 1st char
             REPEAT
             R> DROP ;               \ clean up rstack

: VCLEAN$ ( V$ len  -- v$' len')
            BL SKIP  V-TRAILING ;

\ add a char onto the end of a VDP stack string
: V+CHAR  ( char addr len -- )
          OVER 1- >R     \ compute address of length byte, rpush
          DUP 1+ R> VC!  \ incr len, store new length in VDP
          + VC! ;        \ compute address of end of string, store char

\ ===================================
\ HI LEVEL user interface
: VPRINT  ( vaddr len -- ) CR VTYPE ;

\ assign text to a VDP stack string
: :="    ( vaddr len -- )  [CHAR] " PARSE  2SWAP V$! ;

\ Neil Baud's toolbelt compare, modded for VDP RAM
\  0 means adr1 = adr2
\ -1 means adr1 < adr2
\  1 means adr1 > adr2

: VCOMPARE  ( Vadr1 n1 Vadr2 n2 -- -1|0|1 )
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

: =V$   ( adr len adr len -- ? ) VCOMPARE 0= ;

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
 80 VDIM A$    A$ :=" THIS IS A$ IN VDP RAM :-)"
 80 VDIM B$    B$ :=" This B$ IN VDP RAM"
 80 VDIM C$    C$ :="             1234                  "

\ create string literals (cannot change these)
\ : Q$       V" The single quote creates a string li teral in VDP memory" ;
\ : DIRTY$   V"                    <<CORE>>                            " ;

\ assigning string variables with $! ("string store")
\ S" Now is the time for all good men "    A$ V$!
\ S" to come to the aid of their country." B$ V$!

\ : TEST
\         10 0 DO
\            A$ VPRINT
\            B$ VPRINT
\            Q$ VPRINT
\         LOOP ;

\ : COMPTEST  100 0 DO   Q$ Q$ =V$  DROP   LOOP ;
\
\ : TRIMTEST  100 0 DO  DIRTY$ BL VTRIM  2DROP  LOOP ;
\
\ : SKIPTEST  100 0 DO  DIRTY$ BL VSKIP  2DROP  LOOP ;
\ : CLEANTEST 100 0 DO  DIRTY$ BL VSKIP  BL VTRIM  2DROP  LOOP ;
\
\ : CLEANTEST2 100 0 DO  DIRTY$ BL VSKIP  BL VTRIM VTYPE SPACE   LOOP ;
