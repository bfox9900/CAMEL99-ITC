\ Uses ANS Forth stack strings. ( addr len -- ) on the stack
\ this are faster to process than copying strings to memory 
\ between every operation

DECIMAL
\ === string stack ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

\ * You have a choice where to place the string stack *
\ : TOP$     ( -- $) SSP @ PAD + ;      \ string stack in free dictionary space
: TOP$     ( -- $) SSP @ H @ + COUNT ;  \ string stack in free HEAP memory (low mem)


\ ==== From Wil Baden's Tool Belt [R.I.P. Wil] ====
\ : PLACE     ( addr n dst$ -- ) 2DUP C! 1+ SWAP CMOVE ;  \ in CAMEL99 Kernel
\ : C+!       ( n addr -- )      DUP >R  C@ +  R> C! ;  \ MOVED TO CODE
: APPEND      ( adr n adr -- )   2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

\ ==== string stack helpers ====
: SPUSH    ( addr len -- adr' len ) NEW: TOP$ DUP >R PLACE R> COUNT ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

\ ==== Replicate TI-BASIC string functions ====
: LEN      ( adr len -- n ) DUP ;
: SEG$     ( adr len n1 n2 -- addr len) >R >R R> 1- /STRING DROP R> ;
: STR$     ( n -- adr len) DUP ABS 0 <# #S ROT SIGN #> ;
: VAL$     ( adr len - n ) PAD PLACE PAD ?NUMBER 0= ABORT" VAL$ err" ;
: CHR$     ( ascii# -- adr len ) NEW: TOP$ 1 OVER C! SWAP OVER 1+ C! ;
: ASC      ( adr len -- adr len) DROP 1 ;

: &        ( $1 $2 -- top$)   \ concatenate operator
           SWAP COUNT SPUSH >R COUNT R@ APPEND R>  ; \ A$ B$ &  PRINT

: COPY$    ( $1 $2 -- )  >R COUNT R> PLACE ;

\ compare strings also use S=
: COMPARE$ ( $1 $2 -- flag) DUP C@ 1+ S= ;

: =$       ( $1 $1 -- flag)  COMPARE$ 0= ;
: <>$      =$ 0= ;
: >$       ( $1 $2 -- flag)  COMPARE$ 0> ;  \ $1 > $2
: <$       ( $1 $2 -- flag)  COMPARE$ 0< ;  \ $1 < $2

( compile time string assignment)
: ="       ( $addr -- <text> ) ?EXEC [CHAR] " PARSE ROT PLACE ;
: =""      ( $addr -- ) ?EXEC  0 SWAP C! ;   \ sets string length to zero

: ?$IZE    ( n -- ) MXLEN > ABORT" $ too big!" ;
\ DIM creates a named string of n size in the Dictionary
: DIM      ( n -- ) 
           DUP ?$IZE
           CREATE 0 C, ALLOT ;

\ STRING: creates a named string of n size in the HEAP (low mem)
: STRING:  ( n -- )
           DUP ?$IZE
           CREATE H @ DUP , 0 C!   \ record heap address and init length
                  1+ ALIGNED  H +! \ allot Heap memory to EVEN address
           DOES>  @  ;

: PUT      ( $1 $2 -- ) COPY$ COLLAPSE ;
: PRINT$   ( $ -- )   COUNT TYPE ;
: PRINT    ( $ -- )   CR PRINT$ COLLAPSE ;    \ print on new line, clean $stack

: (")      ( -- ) R> DUP COUNT + ALIGNED >R ; \ advance IP on Rstack, past end of string

: "        ( -- )   \ create string literal when compiling
           [CHAR] " PARSE              \ parse input upto quote char
           STATE @                     \ are we compiling?
           IF    POSTPONE (")  S,      \ action when Compiled
           ELSE  SPUSH                 \ action when interpreted
           THEN ; IMMEDIATE

COLLAPSE  ( initializes the string stack)

( 700+ BYTES)
