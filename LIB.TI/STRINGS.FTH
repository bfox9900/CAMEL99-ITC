( RE-ENTRANT STRING LEXICON                    OCT 8 1987 Brian Fox)
\ Re-write for CAMEL99                         AUG 28 2017

\ Written orginally to provide TI-BASIC string functions for TI-Forth.
\ I have re-written it many times; for HsForth GForth, MPE Power Forth,
\ Mark COMPLETELY re-wrote it for Turbo Forth and now I have re-written 
\ it for CAMEL99.

\ New Concept:
\ Input strings are manipulated by adjusting addr & len on the data stack.
\ This method is MUCH faster than copying sub-strings.
\ Functions that output a string copy their result onto a string stack.
\ The address of the output string is on the Forth Parameter stack.
\ This allows string functions to feed into another string function.

\                --THE SECRET SAUCE --
\ Two functions, PUT and PRINT, collapse the string stack automatically.
\ This cleans up the intermediate strings that are created as you use the
\ string functions after you either store or print the final result.
\ No garbage collection required.

\ original version used run-time size checking.
\ It's removed here for more speed so be careful


DECIMAL
\ === string stack ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: NEW:     ( -- ) SSW SSP +! ;  \ bump string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

\ * You have a choice where to place the string stack *

\ : TOP$     ( -- $) SSP @ PAD + ; \ string stack in dictionary

: TOP$     ( -- $) SSP @ H @ + ; \ string stack in free HEAP memory

\ From Wil Baden's Tool Belt [R.I.P. Wil] ====
\ : C+!        ( n addr -- )   DUP >R  C@ +  R> C! ; \ now a code word

\ changed APPEND to +PLACE to avoid name conflict with FILE SYSTEM WORD
: +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

\ : PLACE      ( addr n dst$ -- ) 2DUP C! 1+ SWAP CMOVE ; \ in Kernel

.( ..)
\ string stack helpers ====
: SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

\ Replicate TI-BASIC string functions ====
: LEN      ( $ -- n )  C@ ;
: SEG$     ( $ n1 n2 -- top$) >R >R COUNT R> 1- /STRING DROP R> SPUSH ;
: STR$     ( n -- top$)  DUP ABS 0 <# #S ROT SIGN #> SPUSH ;
: VAL$     ( adr$ - # )  ?NUMBER 0= ABORT" VAL$ err"  ;
: CHR$     ( ascii# -- top$ ) NEW: TOP$ 1 OVER C! SWAP OVER 1+ C! ;
: ASC      ( $ -- c)   1+ C@ ;
.( .)
: &        ( $1 $2 -- top$)   \ concatenate operator
           SWAP COUNT SPUSH >R COUNT R@ +PLACE R>  ;

: POS$    ( $1 $2 -- n )       \ return "position" of $1 in $2
           DUP -ROT            \ copy $2 under the inputs
           COUNT OVER + SWAP   \ step $2 char by char
           DO
             I OVER COUNT S=   \ S= part of CAMEL Forth.
             0= IF I LEAVE THEN  \ match! push loop index & leave
           LOOP
           NIP SWAP -  ;       \ subtract addresses to get position

\ much faster find position of char in $
: CPOS     ( $ char -- n) >R COUNT 2DUP R> SCAN NIP - NIP ;

: COPY$    ( $1 $2 -- )  >R COUNT R> PLACE ;

\ compare strings also use S=
: COMPARE$ ( $1 $2 -- flag) DUP C@ 1+ S= ;

.( ..)
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
           CREATE H @ DUP , 0 C!   \ record heap address and init  length
                  1+ ALIGNED  H +! \ allot Heap memory to EVEN address
           DOES>  @  ;

: PUT      ( $1 $2 -- ) COPY$ COLLAPSE ;
.( ...)
\ print a string, but do NOT collapse string stack
: PRINT$   ( $ -- )     COUNT TYPE ;

\ high level string print, collapses stringstack
: PRINT    ( $ -- )  CR PRINT$ COLLAPSE ;

: (")      ( -- ) R> DUP COUNT + ALIGNED >R ;

: "        ( -- )   \ create string literal when compiling
           [CHAR] " PARSE              \ parse input upto quote char
           STATE @                     \ are we compiling?
           IF    POSTPONE (")  S,      \ action when Compiled
           ELSE  SPUSH                 \ action when interpreted
           THEN ; IMMEDIATE

COLLAPSE  \ initialize the string stack

( 700+ BYTES)
