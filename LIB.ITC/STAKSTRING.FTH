\ Faster/smaller "TI BASIC" string library for CAMEL99 V2.59  Jan 28 2020 B Fox
\ Mov 25 2021 Change to use MALLOC/MFREE for temp strings.

\ No string stack.
\ Uses stack strings so processing just changes addresses and length.
\ "Copy on write" (COW) with store string operator. (!$)
\ Strings are stored as byte counted strings
\ MALLOC buffer used for concatenation and then de-allocated

\    TI BASIC                      Forth
\ ----------------            ------------------
\ DIM A$(100)                  100 DIM A$
\ DIM B$(100)                  100 DIM B$
\  not needed                  100 DIM C$         ( must DIM first)
\ A$=LEFT$(A$,5)               A$ 5 LEFT$ A$ !$   ( modify, store)
\ PRINT SEG$(A$,4,4)           A$ 4 4 SEG$ PRINT  ( process, print)
\ PRINT A$&B$&C$               A$ B$ & C$ & PRINT ( concatenate, print)
\ A$=B$                        A$ B$ !$           ( store string)

\ ----------------------------------------------------
\ INCLUDE DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS COMPARE   FROM DSK1.COMPARE
NEEDS MALLOC    FROM DSK1.MALLOC

HERE
DECIMAL
  255 CONSTANT MXLEN          \ 255 bytes is longest string

: ?$IZE    ( n -- ) MXLEN > ABORT" $ too big!" ;

\ ====[ create a named string of size n ]====
\ When a DIM string is executed it returns a stack string.
: DIM     ( n -- )
    DUP ?$IZE
	  CREATE 0 C, ALLOT ALIGN       \ prepare a counted string
	  DOES>  COUNT ; ( -- addr len) \ returns stack string

\ convert ONLY DIM strings to its counted string address
: >COUNTED ( addr len -- caddr) DROP [ 1 CHARS ] LITERAL - ;

\ ==== From Wil Baden's Tool Belt [R.I.P. Wil] ====
\ : PLACE       ( addr n dst$ -- ) 2DUP C! 1+ SWAP MOVE ; \ in kernel
\ : C+!         ( n addr -- )      DUP >R  C@ +  R> C! ;   \ in Kernel
: +PLACE      ( addr n $ -- )    2DUP 2>R  COUNT + SWAP MOVE  2R> C+! ;
: APPEND-CHAR ( char caddr -- )  DUP >R COUNT DUP 1+ R> C! + C! ;

\ ==== Replicate TI BASIC string functions ====
: LEN      ( addr len -- addr len c ) DUP ;
: SEG$     ( addr len n1 n2 -- addr len) >R /STRING  R> NIP ;
: POS$     ( char addr len  -- c) ROT SCAN NIP ;
: STR$     ( n -- adr len) DUP ABS 0 <# #S ROT SIGN #> ;
: ASC$     ( addr len -- c) DROP C@ ;
: &        ( addr len addr len -- addr len )
           2SWAP MXLEN MALLOC DUP >R PLACE
           R@ +PLACE
           R> COUNT LEN
           MXLEN MFREE
           ?$IZE  ;  \ abort if string len >255

\ needed for some ANS Forth systems
\ : NUMBER?  ( addr len -- n ?)  \ convert to single, ?=0 is good conversion
\             OVER C@ [CHAR] - = DUP >R   \ save minus sign flag
\             IF   1 /STRING THEN
\             0 0  2SWAP >NUMBER NIP NIP
\             R> IF SWAP NEGATE SWAP THEN ;

: VAL$     ( addr len -- n ) NUMBER? ABORT" not a number" ;

\ compare stack strings
: =$       ( addr len addr len -- flag) COMPARE 0= ;
: >$       ( addr len addr len -- flag) COMPARE 0< ;  \ $1 > $2
: <$       ( addr len addr len -- flag) COMPARE 0> ;  \ $1 < $2

\ *WARNING* You are protected from trying to store a string >255 bytes
\ BUT... If the destination string is too small its your problem
: !$      ( addr len addr len -- ) >COUNTED OVER ?$IZE PLACE ;

\ interpret only string assignment
: ="     [CHAR] " PARSE 2SWAP !$ ;
: =""      ( addr len -- ) >COUNTED OFF ; \ sets string length to zero

: "      POSTPONE S" ; IMMEDIATE   \ renamed S"
: PRINT    ( addr len -- ) CR TYPE ;  \ more like BASIC'S print

\ Strings words that TI-BASIC does not have
: LEFT$    ( addr len n -- addr len') NIP ;
: RIGHT$   ( addr len n -- addr len) /STRING ;
: -LEADING ( addr len -- addr' len') BL SKIP ;   \ trim leading spaces
: CLEAN$   ( addr len -- addr len) -LEADING -TRAILING  ;
: DELIMIT$ ( addr len char -- addr' len') >R 2DUP R> SCAN NIP - 0 MAX ;

\ *EXTRA*  compile or interpret string assignment
\ : :="       ( addr len -- <text> )
\            [CHAR] " PARSE
\            STATE @
\            IF    POSTPONE (S") S,
\                  POSTPONE 2SWAP
\                  POSTPONE !$
\
\            ELSE   2SWAP !$
\            THEN ; IMMEDIATE

HERE SWAP - DECIMAL CR .  .( Bytes)
