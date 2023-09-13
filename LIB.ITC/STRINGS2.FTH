\ Uses ANS Forth stack strings. ( addr len -- ) on the stack
\ which is faster to process than copying strings to memory 
\ between every operation. 

NEEDS DUMP FROM DSK1.TOOLS 

HERE 
NEEDS COMPARE FROM DSK1.COMPARE

DECIMAL
\ === string stack ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

\ * You have a choice where to place the string stack *
\ : TOP$     ( -- $) SSP @ PAD + ;      \ $stack in free dictionary space
: TOP$     ( -- $) SSP @  H @ + COUNT ;  \ $stack in free HEAP memory 

\ ==== From Wil Baden's Tool Belt [R.I.P. Wil] ====
\ : PLACE     ( addr n dst$ -- ) 2DUP C! 1+ SWAP MOVE ; \ in CAMEL99 Kernel
\ : C+!       ( n addr -- )      DUP >R  C@ +  R> C! ;   \ moved to kernel
: +PLACE      ( adr n adr -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

\ ==== string stack helpers ====
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

\ ==== Replicate TI-BASIC string functions ====
: LEN      ( adr len -- n ) DUP ;
: SEG$     ( adr len n1 n2 -- addr len) >R  1- /STRING DROP R> ;
: STR$     ( n -- adr len) DUP ABS 0 <# #S ROT SIGN #> ;
: VAL$     ( adr len - n ) PAD PLACE PAD NUMBER? ABORT" VAL$ err" ;
: CHR$     ( ascii# -- adr len ) NEW: TOP$ 1 OVER C! SWAP OVER 1+ C! ;
: ASC      ( adr len -- adr len) DROP 1 ;

\ MS BASIC functions
: LEFT$  ( addr len n -- addr  n) NIP ;   \ :-) 
: RIGHT$ ( addr len n -- addr' n) OVER - ABS 0 MAX /STRING ;

: ?$SIZE    ( n -- ) MXLEN > ABORT" $ too big!" ;
: $!       ( addr len addr len --) DROP 1-  OVER ?$SIZE  PLACE ; 
: $+!      ( addr len addr len --) DROP 1-  OVER ?$SIZE  +PLACE ; 

\ Concatenate 2 stack strings using TOP$ as a temp buffer.
: &        ( addr len addr len -- addr len )
        2SWAP NEW: TOP$ $! TOP$ $+!  TOP$ ;  

: =$       ( addr len addr len -- ?) COMPARE 0= ;
: <>$      ( addr len addr len -- ?) =$ 0= ;
: >$       ( addr len addr len -- ?) COMPARE 0> ;  \ $1 > $2
: <$       ( addr len addr len -- ?) COMPARE 0< ;  \ $1 < $2

( compile time string assignment)
: ="       ( addr len -- <text> ) ?EXEC [CHAR] " PARSE 2SWAP $! ;
: =""      ( addr len -- ) ?EXEC DROP 1-  0 SWAP C! ; 

\ create a named string of size n 
\ When a DIM string is executed it returns a stack string.
: DIM     ( n -- )
    DUP ?$SIZE
	  CREATE 0 C, ALLOT ALIGN       \ prepare a counted string
	  DOES>  COUNT ; ( -- addr len) \ returns stack string

: PRINT$   ( addr len -- )  CR TYPE ;  \ print on new line

\ These 2 functions clean up the string stack. cheap garage collection
: PUT      ( addr len addr len -- ) $! COLLAPSE ; \ copy and clean $stack
: PRINT    ( addr len -- )  PRINT$ COLLAPSE ;  \ print and clean $stack

: "    POSTPONE S" ; IMMEDIATE  \ syntactic sugar

COLLAPSE  ( initializes the string stack)

HERE SWAP - DECIMAL . .( bytes used)

\ TEST CODE 
80 DIM A$ 
80 DIM B$ 

\ compile time assignment
A$ =" The rain in Spain falls mainly on the plain."
B$ =" Now is the time for all good men to come to the aid of their country"

A$ PRINT  B$ PRINT 
\ complex string statement 
B$ 20 LEFT$  A$ 18 LEFT$ &  B$ 35 RIGHT$ &  PRINT  
 

