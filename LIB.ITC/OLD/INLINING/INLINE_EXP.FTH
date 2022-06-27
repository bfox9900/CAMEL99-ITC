\ inline.fth  a simple speedup for ITC FORTH July 2017  B Fox
\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
NEEDS OF   FROM DSK1.CASE

HEX
\ CFA of a code word contains the address of the next cell
: ?CODE ( cfa -- ? ) DUP @ 2- - 0= ;

\ scan MACHINE code looking for the NEXT, routine.
\ abort if NEXT is not found after 256 bytes. This is an arbitrary size
\ but most Forth code words are much smaller than 256 bytes.
: TONEXT ( adr --  adr2 )
           0                \ flag that falls thru if we don't succeed
           SWAP
         ( ADR) 80         \ max length of code word is $80 CELLS
           BOUNDS
           DO
             I @  045A  =   \ test each CELL for CAMEL99 NEXT (B *R10)
             IF   DROP I LEAVE
             THEN
           2 +LOOP
           DUP 0= ABORT" no NEXT" ;

: TRANSCRIBE  ( cfa -- )
              >BODY DUP TONEXT OVER  -     \ calc. start and len. of code
              HERE OVER ALLOT SWAP CMOVE ;  \ transcribe the code to HERE
              
\ compile assembler code to push arguments into TOS register
: PUSH_VAR ( cfa -- )  TOS PUSH,  TOS SWAP >BODY LI, ;
: PUSH_CON ( cfa -- )  TOS PUSH,  TOS SWAP >BODY @ LI, ;

' DOVAR CONSTANT 'DOVAR
' DOCON CONSTANT 'DOCON

: INLINE, ( $addr -- )    \ compile code for $addr word
           FIND 0= ABORT" INLINE, can't find"
           DUP @ 'DOVAR = IF  ." PUSHVAR"  PUSH_VAR   EXIT THEN
           DUP ?CODE IF  TRANSCRIBE EXIT THEN
 \          DUP ?CONST IF DROP PUSH_CON   EXIT THEN
           TRUE ABORT" INLINE: unknown type" ;

\ create code words using primitives
: INLINE[   ( <TEXT>)
            BEGIN
              BL PARSE-WORD PAD PLACE
              PAD 1+  C@ [CHAR] ] <>
              PAD C@ 0= OR
            WHILE
              PAD INLINE,
            REPEAT ;

\ ===================================
\ EXAMPLES
 CODE ^2      INLINE[  DUP *  ] NEXT, ENDCODE
 CODE DUPC@   INLINE[  DUP C@ ] NEXT, ENDCODE
 CODE DUP>R   INLINE[  DUP >R ] NEXT, ENDCODE

VARIABLE X
 CODE X@      INLINE[ X @ ]     NEXT, ENDCODE


