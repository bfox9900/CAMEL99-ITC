\ inline.fth  a simple speedup for DTC FORTH Oct 2019  B Fox
\    **************************************
\    **** DIRECT THREADED CODE VERSION ****
\    **************************************
\ NEEDS DUMP FROM DSK1.TOOLS      ( debugging)

NEEDS CASE FROM DSK1.CASE

HEX
\ CFA of a DTC Forth word contains a BRANCH&LINK instruction
06A0 CONSTANT B&L
: ?CODE ( cfa -- ) B&L = ABORT" Not code word" ;

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

\ embed  a literal number as machine code  *HUGE* 8 bytes!!
\ Assembler: TOS PUSH,  LI TOS ( n ) , ;
: LIT,   ( n -- ) 0646 , C584 , 0204 , ( n) ,  ;

: INLINE,  ( cfa -- )
           DUP ?CODE                     \ test if code word
           DUP TONEXT OVER -             \ calc. start and len. of code
           HERE OVER ALLOT SWAP CMOVE ;  \ transcribe the code to HERE

: OPT"  ( i*x c-addr u -- j*x )
               'SOURCE 2!  >IN OFF
               BEGIN
                  [CHAR] " WORD DUP C@ ( -- addr len)
               WHILE
                  FIND
                  ?DUP IF ( it's word)
                       DUP B&L =  ( Forth word)
                       IF  CELL+  ( to code address)
                           CASE
                             'DOVAR OF    LIT,  ENDOF
                             'DOCON OF  @ LIT,  ENDOF
                              TRUE ABORT" Unknown word type"
                           ENDCASE

                       ELSE ( It's a CODE word: inline it)
                            INLINE,
                       THEN

                  ELSE ( it's a number)
                       ?NUMBER
                       IF   LIT,
                       ELSE TRUE SWAP COUNT ?ABORT
                       THEN
                  THEN
                  ?STACK
               REPEAT
               DROP ;



\ ===================================

\ EXAMPLES
\ CODE ^2      INLINE[  DUP *  ] NEXT, ENDCODE
 CODE DUPC@   OPT"  DUP C@ " NEXT, ENDCODE
\ CODE DUP>R   INLINE[  DUP >R ] NEXT, ENDCODE
 
 
 
