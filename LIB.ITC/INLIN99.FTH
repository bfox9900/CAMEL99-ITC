\ inline.fth  a simple speedup for ITC FORTH July 2017  B Fox

\ Premis:
\ An indirect threaded code (ITC) system can spend up to 50% of its time 
\ running the Forth thread interperpreter, typically called NEXT.
\ The ITC NEXT routine is three instructions on the TMS9900.
\ The Forth Kernel contains many words called primitives, that are coded
\ in Assembler.
\ Many of these primitives are only 1 or 2 instructions.
\ INLINE[ ... ] copies the code from a primitive and compiles it in a new 
\ definition but removes the call to NEXT at the end of each primitive.
\ This can double the speed of chains of CODE words.

\ **not portable Forth code**  Uses TMS9900/CAMEL99 CARNAL Knowledge

INCLUDE DSK1.CODE.F

HEX
\ TEST for CODE word
\ CFA of a code word contains the address of the next cell
: ?CODE ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;

\ scan MACHINE code looking for the NEXT, routine.
\ abort if NEXT is not found after 256 bytes. This is an arbitrary size
\ but most Forth code words are much smaller than 256 bytes.
: TONEXT ( adr --  adr2 )
           0                \ flag that falls thru if we don't succeed
           SWAP
          ( ADR) 80         \ max length of code word is $80 CELLS
           BOUNDS
           DO
             I @  045A   =   \ test each CELL for CAMEL99 NEXT (B *R10)
             IF   DROP I LEAVE
             THEN
           2 +LOOP
           DUP 0= ABORT" can't find NEXT" ;

\ : RANGE  ( cfa -- addr cnt )
\         >BODY DUP TONEXT OVER  -  ;  \ calc.  start and length of code

\ put inline ASM in colon definitions
: ASM[
           HERE CELL+ ,            \ compile a pointer to the next cell
           HERE CELL+ ,            \ which is the CFA of the inline code
           [  ;  IMMEDIATE         \ switch to interpreter mode

: ]ASM     0209 ,  HERE 2 CELLS + , \ macro:  LI R9,HERE+4
                                    \ moves Forth IP reg.)
           NEXT,
           ] ;   IMMEDIATE          \ switch ON compiler

\ create code words using primitives
: CODE[    BEGIN
             BL PARSE-WORD PAD PLACE
             PAD CHAR+ C@ [CHAR] ] <>
           WHILE
             PAD FIND 0= ABORT" not found"
             DUP ?CODE
             >BODY DUP TONEXT OVER  -     \ calc. start and len. of code
             HERE OVER ALLOT SWAP CMOVE   \ transcribe the code to HERE
           REPEAT ; IMMEDIATE

\ embed  a literal number as machine code  *HUGE* 8 bytes!!
\ equivalent: TOS PUSH,  LI TOS ( n ) , ;
: :ARG   ( n -- ) 0646 , C584 , 0204 , ( n) ,  ;  IMMEDIATE

\ compile primitives inline inside a colon definition
: INLINE[
           POSTPONE ASM[
           POSTPONE CODE[
           POSTPONE ]ASM ;  IMMEDIATE
\ ===================================


\ EXAMPLES
\ CODE 1+!  ASM[ *TOS INC,  TOS POP, ]ASM  NEXT,

\ CREATE Q  20 ALLOT
\ CODE ]Q    CODE[ 2* ]  Q :ARG  CODE[ + ] NEXT, END-CODE

\ : *+       INLINE[ * + ]    ;

\ : DUPC@    INLINE[ DUP C@ ] ;
\ : DUP>R    INLINE[ DUP >R ] ;
\ : ^2       INLINE[ DUP *  ] ;


