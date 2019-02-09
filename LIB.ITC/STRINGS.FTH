( RE-ENTRANT STRING LEXICON                    OCT 8 1987 Brian Fox)
\ Re-write for CAMEL99                         AUG 28 2017

\ original version used run-time size checking.
\ It's removed here for more speed so be careful

\ Aug 17 2018
\   - STRING stack lives in free dictionary
\   - DIM creates static string in dictionary
\   - HDIM uses MALLOC to create static string in HEAP
\ Aug 21 2018 - fixed bug in POS$
\ Nov 25, 2018 - MOVED string stack to top of HEAP (un-allocated)

HERE

DECIMAL
\ === string stack in high heap ====
            255 CONSTANT MXLEN   \ 255 bytes is longest string

MXLEN 1+ NEGATE CONSTANT SSW     \ negative width of string stack
HEX 3FFF SSW +  CONSTANT $STACK

                VARIABLE SSP     \ the string stack pointer

: NEW:     ( -- ) SSW SSP +! ;  \ bump string stack pointer by -256
: COLLAPSE ( -- ) SSP OFF ;     \ reset string stack pointer to zero

: TOP$     ( -- $) $STACK SSP @ + ;

\ changed APPEND to +PLACE to avoid name conflict with FILE SYSTEM WORD
: +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

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

: POS$  ( $1 $2 -- n )  \ return "position" $1 in $2
\           DUP -ROT DUP -ROT
           TUCK SWAP OVER       ( $2 $2 $1 $2)
           COUNT BOUNDS         \ step $2 char by char
           DO
             I OVER COUNT S=
             0= IF
                  NIP I SWAP
                  LEAVE
             THEN
           LOOP
           DROP - ABS ;

\ much faster find position of char in $
: CPOS     ( $ char -- n) >R COUNT 2DUP R> SCAN NIP - NIP ;

: COPY$    ( $1 $2 -- )  >R COUNT R> PLACE ;
 \           NEW: TOP$ COUNT PLACE
 \           COUNT TOP$ PLACE ;

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

: ?$IZE    ( n -- ) MXLEN > ABORT" $>255 bytes" ;

\ DIM creates a named string of n size in the Dictionary
: DIM      ( n -- ) DUP ?$IZE 1+ ALIGNED CREATE  ALLOT ;

\ HDIM  creates a static named string in the HEAP (low mem)
: HDIM    ( n -- ) DUP ?$IZE  1+ ALIGNED MALLOC CONSTANT ;

: PUT      ( $1 $2 -- ) COPY$ COLLAPSE ;
.( ...)
\ print a string, but do NOT collapse string stack
: PRINT$   ( $ -- )  COUNT TYPE ;

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

HERE SWAP - DECIMAL .  .( Bytes)

\ 20 DIM A$  A$ =" This is A$"
\ 20 DIM B$  B$ =" This is B$."
\ 50 DIM C$  A$ B$ & C$ PUT

