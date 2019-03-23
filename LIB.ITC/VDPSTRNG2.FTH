\ VDP STRINGS II create/print Forth style stack strings IN VDP Memory
\ This saves lots of dictionary space in your program
\ if you need many strings

\  NEW IDEA
\ Strings are stored in VDP RAM as counted strings. (1st byte is length)
\ When we invoke the string's name we need to "fetch" it with V@$ onto
\ the string stack in CPU RAM. The results should be put back to a VDP
\ string variable. VDP strings are therefore just for storage.
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
  : VREAD$   ( vaddr len addr -- ) 2DUP C! CHAR+ SWAP VREAD ;
  : +VREAD$  ( vaddr len addr -- ) 2DUP 2>R COUNT +  SWAP VREAD 2R> C+! ;

  \ string stack helpers ====
  : SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
  : ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
  : DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;


\ : VPLACE  ( addr len vaddr -- )  *THIS WORD IS IN THE KERNEL*

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ convert a VDP counted string to a stack string
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ Print a VDP stack string directly from VDP memory
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ fetch store VDP string to/from string stack
: @$      ( vaddr len -- top$)  NEW: TOP$ DUP >R VREAD$ R> ;
: !$      ( addr  vaddr len -- ) DROP 1- VPLACE ;

\ ==== From Wil Baden's Tool Belt [R.I.P. Wil] ====
: PLACE     ( addr n dst$ -- )  2DUP C! 1+ SWAP CMOVE ;
: C+!       ( n addr -- )       DUP >R  C@ +  R> C! ;
: +PLACE    ( adr n adr -- )    2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;
: APPEND-CHAR ( char caddr -- ) DUP >R COUNT DUP 1+ R> C! + C! ;

\ ==== string stack operations ====
: SPUSH    ( addr len -- adr' len ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;
: COPY$    ( $1 $2 -- )  >R COUNT R> PLACE ;

\ ==== Replicate BASIC string functions ====
: LEN$      ( $ -- c ) C@ ;
: LEFT$    ( $ n -- top$) >R COUNT DROP R> SPUSH ;
: RIGHT$   ( $ n -- top$) >R COUNT DUP R> - 0 MAX /STRING SPUSH ;
: MID$     ( $ n1 n2 -- top$) >R >R COUNT R> 1- /STRING DROP R> SPUSH ;

: POS$     ( char $ -- $ c)
            DUP -ROT
            COUNT BOUNDS
            DO
              I C@ OVER =
              IF DROP I LEAVE THEN
            LOOP
            SWAP - ;

: STR$     ( n -- adr len) DUP ABS 0 <# #S ROT SIGN #> SPUSH ;

\ compile a VDP string literal into a Forth word.
\ uses 6 bytes of dictionary space
: V"    ( <text> )
       ?COMP                            \ test for compiling, abort if not
       S" [ VHERE ] LITERAL" EVALUATE   \ run-time: compile VDP address
       [CHAR] " PARSE VS,               \ compile-time: string to VDP RAM
       POSTPONE VCOUNT ; IMMEDIATE      \ runtime: convert to addr,len

\ ================================
\ VDP string data structures
: DIM      ( n -- top$)
            CREATE VHERE , VALLOT       \ create a VDP string of size n
\
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

\ ==============================
\ DEMO code
\ create string variables (the text is compiled one after the other)
DECIMAL
 80 DIM A$    A$ :=" THIS IS A$ IN VDP RAM :-)"
 80 DIM B$    B$ :=" This B$ IN VDP RAM"
 80 DIM C$    C$ :="             1234                  "

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
