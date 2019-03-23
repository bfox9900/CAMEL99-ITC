\ A "BASIC" string library

\ This simple word set is useful but not optimal.
\ The objective is to provide the new Forth programmer with something they
\ can use out of the box while they learn more about Forth.

\ Pros:
\ - emulates BASIC's string functionality in RPN form
\ - easy to use
\ - provides a foundation for learning Forth's lower level operations

\ Negatives:
\ - uses byte counted strings which are frowned upon in contemporary Forth
\ - copies to a string stack for processing which is not efficient
\ - there are NO protections for exceeding the capacity of a string variable

\ Where appropriate, string operations create a copy on the string stack.
\ The source string is not modified, unless you put the operation's result
\ back into the source string.

\      BASIC                      Forth
\ ----------------            ------------------
\ DIM A$(100)                  100 DIM A$
\ DIM B$(100)                  100 DIM B$
\ A$=LEFT$(A$,5)               A$ 5 LEFT$ A$ !$   ( modify, store, collapse stack)
\ PRINT MID$(A$,4,4)           A$ 4 4 MID$ .$     ( process, print, collapse stack)
\ PRINT A$&B$                  A$ B$ & .$         ( concatenate, print, collapse stack)
\ A$=B$                        A$ B$ COPY$        ( COPY, do NOT collapse stack)
\ A$=B$                        A$ B$ !$           ( store, collapse stack)
\ A$=RIGHT$(B$,3)&LEFT$(A$,4)  B$ 3 RIGHT$  A$ 4 LEFT$ &  A$ !$
\ INPUT A$                     A$ $ACCEPT
\ INPUT X                      VARIABLE X   X #INPUT

\ An assumption is made here, that if the program stores a string or prints a string,
\ the string stack can be safely collapsed, a cheap way to do garbage collection.
\ ----------------------------------------------------

DECIMAL
\ === string stack created above PAD ====
         VARIABLE SSP     \ string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: TOP$     ( -- $) SSP @ PAD + ;
: NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero

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

: ?NUMBER  ( $ -- n ?)  \ convert $ to single, return flag
             COUNT
             OVER C@ [CHAR] - =
             IF   TRUE >R  1 /STRING
             ELSE FALSE >R
             THEN 0 0  2SWAP >NUMBER NIP NIP
             R> IF SWAP NEGATE SWAP THEN ;

: VAL$     ( $ - n ) ?NUMBER 0= ABORT" not a number" ;

: CHR$     ( ascii# -- adr len ) NEW: TOP$ 1 OVER C! SWAP OVER 1+ C! ;
: ASC$     ( $ -- c)   1+ C@ ;

: &        ( $1 $2 -- top$) SWAP COUNT SPUSH >R COUNT R@ +PLACE R> ;

: -LEADING ( addr len -- addr' len') BL SKIP ;  \ compliment to -TRAILING

: CLEAN$   ( $ -- $') COUNT -LEADING -TRAILING SPUSH ;
: TRIM$    ( $ -- top$)      COUNT -TRAILING SPUSH ;   \ trim trailing spaces
: SKIP$    ( $ char -- top$) >R COUNT R> SKIP SPUSH ;  \ removes leading char

\ === compare counted strings ===
: COMPARE$ ( $1 $2 -- flag) COUNT ROT COUNT COMPARE  ;
: =$       ( $1 $1 -- flag)  COMPARE$ 0= ;
: >$       ( $1 $2 -- flag)  COMPARE$ 0< ;  \ $1 > $2
: <$       ( $1 $2 -- flag)  COMPARE$ 0> ;  \ $1 < $2

\ compile time string assignment
: ="       ( $ -- <text> ) [CHAR] " PARSE ROT PLACE ;

: =""      ( $ -- )  0 SWAP C! ; \ $ =""

: ?$IZE    ( n -- ) MXLEN > ABORT" $ too big!" ;

\ create a named string of size n in the Dictionary
: DIM     ( n -- ) DUP ?$IZE  CREATE 0 C, ALLOT ;

: !$      ( $1 $2 -- ) COPY$ COLLAPSE ;
: .$      ( $ -- )   COUNT TYPE COLLAPSE ;

: "       ( -- )   \ create string literal
           POSTPONE S"
           STATE @                      \ are we compiling?
           IF     POSTPONE SPUSH        \ action when Compiled
           ELSE   SPUSH                 \ action when interpreted
           THEN ; IMMEDIATE

\ ======= string input =======
DECIMAL
: $ACCEPT ( $addr -- ) CR ." ?  "  DUP  1+ 80 ACCEPT  SWAP C!  ;

\ ===== number input =====
: #INPUT  ( addr -- ) \ like BASIC INPUT
          BEGIN
            PAD DUP $ACCEPT ?NUMBER
          WHILE              ( while the conversion is bad we do this)
             CR ." input error"
             CR DROP
          REPEAT
          SWAP ! ;           ( store the number in the variable on the stack)

COLLAPSE  ( initialize string stack)
