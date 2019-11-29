\ inline.fth  a simple speedup for DTC FORTH Oct 2019  B Fox
\    **************************************
\    **** DIRECT THREADED CODE VERSION ****
\    **************************************
\ NEEDS DUMP FROM DSK1.TOOLS      ( debugging)
 
HEX
\ CFA of Version 2 DTC Forth word contains a BRANCH and link instruction
\ 06A0 CONSTANT B&L
: ?CODE ( cfa -- ) 06A0 = ABORT" Not code word" ;

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
 
\ create code words using primitives
: INLINE[   BEGIN
             BL PARSE-WORD PAD PLACE
            PAD CHAR+ C@ [CHAR] ] <>
           WHILE
             PAD FIND 0= ABORT" INLINE FIND err"
             DUP ?CODE
           ( >BODY) DUP TONEXT OVER  -     \ calc. start and len. of code
             HERE OVER ALLOT SWAP CMOVE   \ transcribe the code to HERE
           REPEAT ;
 
\ embed  a literal number as machine code  *HUGE* 8 bytes!!
\ equivalent: TOS PUSH,  LI TOS ( n ) , ;
: #,   ( n -- ) 0646 , C584 , 0204 , ( n) ,  ;  IMMEDIATE
 
\ ===================================

\ EXAMPLES
\ CODE ^2      INLINE[  DUP *  ] NEXT, ENDCODE
\ CODE DUPC@   INLINE[  DUP C@ ] NEXT, ENDCODE
\ CODE DUP>R   INLINE[  DUP >R ] NEXT, ENDCODE
 
 
 
