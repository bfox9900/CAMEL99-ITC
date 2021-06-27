\ Faster "BASIC" style string library for CAMEL99   Jan 28 2020 B Fox

\ This simple word set is useful for the BASIC-to-Forth transition
\ These words provide the new Forth programmer with something they
\ can use out of the box while they learn more about Forth.

\ This version limits string copying by using the Forth data
\ stack to hold intermediate results of LEFT$, SEG$ etc.

\ In memory strings are held as [byte,ABCDEFG], where byte is the length
\
\ However when a string name is used it returns the address and the length
\ onto the DATA stack. This is called a "stack string" ( -- addr len)

\ String functions output the intermediate result as a stack string which
\ means the next string function can pick it up and process further.

\ A temporary buffer is therefore only needed for concatentation.
\ The TOP$ is used for that purpose as part of a stack of buffers


\ An assumption is made here, that if the program stores a string or prints a string,
\ the string stack can be safely collapsed. ie: a cheap way to do garbage collection.

\    TI BASIC                      Forth
\ ----------------            ------------------
\ DIM A$(100)                  100 DIM A$
\ DIM B$(100)                  100 DIM B$
\ A$=LEFT$(A$,5)               A$ 5 LEFT$ A$ !$   ( modify, store, collapse stack)
\ PRINT SEG$(A$,4,4)           A$ 4 4 SEG$ .$     ( process, print, collapse stack)
\ PRINT A$&B$&C$               A$ B$ & C$ & .$    ( concatenate, print, collapse stack)
\ A$=B$                        A$ B$ !$           ( store, collapse stack)
\ INPUT A$                     A$ $INPUT
\ INPUT X                      VARIABLE X   X #INPUT

\ ----------------------------------------------------
\ INCLUDE DSK1.TOOLS
HERE
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS COMPARE   FROM DSK1.COMPARE

DECIMAL
\ === string stack created above PAD ====
          VARIABLE SSP     \ string stack pointer
      255 CONSTANT MXLEN   \ 255 bytes is longest string
 MXLEN 1+ CONSTANT SSW     \ width of string stack items
\ ==== string stack operations ====
: ?$IZE    ( n -- ) MXLEN > ABORT" $ too big!" ;
: TOP$     ( -- $) SSP @ PAD + ;
: NEW$     ( -- $) SSW SSP +!  TOP$ ;
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack
: ?SSP     ( -- ) SSP @ 0= ABORT" Empty $ stack" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

\ convert stack string to counted string address
: >COUNTED ( addr len -- caddr) DROP [ 1 CHARS ] LITERAL - ;

\ ====[ create a named string of size n ]====
\ When a DIM string is executed it returns a stack string.
: DIM     ( n -- )
          ALIGNED DUP ?$IZE
	  CREATE ALIGN 0 C, ALLOT
	  DOES> COUNT ;  ( -- addr len)

\ ==== From Wil Baden's Tool Belt [R.I.P. Wil] ====
\ : PLACE       ( addr n dst$ -- ) 2DUP C! 1+ SWAP CMOVE ;
: C+!         ( n addr -- )      DUP >R  C@ +  R> C! ;
: +PLACE      ( addr n $ -- )    2DUP 2>R  COUNT + SWAP CMOVE  2R> C+! ;
: APPEND-CHAR ( char caddr -- )  DUP >R COUNT DUP 1+ R> C! + C! ;

\ ==== Replicate BASIC string functions ====
: LEN      ( addr len -- addr len c ) DUP ;
\ : LEFT$    ( addr len n -- addr len') NIP ;
\ : RIGHT$   ( addr len n -- addr len) /STRING ;
: SEG$     ( addr len n1 n2 -- addr len) >R /STRING  R>  NIP ;
: POS$     ( char $ -- c) ROT SCAN NIP ;
: STR$     ( n -- adr len) DUP ABS 0 <# #S ROT SIGN #> ;
: ASC$     ( addr len -- c) DROP C@ ;

\ : -LEADING ( addr len -- addr' len') BL SKIP ;   \ trim leading spaces
\ : CLEAN$   ( addr len -- addr len) -LEADING -TRAILING  ;

: &        ( addr len addr len -- addr len )
           2SWAP NEW$ PLACE  TOP$ +PLACE  TOP$ COUNT ;  \ abort if string len >255

: ?NUMBER  ( addr len -- n ?)  \ convert to single, 0 flag is good conversion
             OVER C@ [CHAR] - =
             IF   TRUE >R  1 /STRING
             ELSE FALSE >R
             THEN 0 0  2SWAP >NUMBER NIP NIP
             R> IF SWAP NEGATE SWAP THEN ;

: VAL$     ( addr len -- n ) ?NUMBER ABORT" not a number" ;

\ compare stack strings
: =$       ( addr len addr len -- flag) COMPARE 0= ;
: >$       ( addr len addr len -- flag) COMPARE 0< ;  \ $1 > $2
: <$       ( addr len addr len -- flag) COMPARE 0> ;  \ $1 < $2

\ *WARNING* You are protected from trying to store a 255 byte string.
\ If the destination string is too small it will crash!
: !$      ( addr len addr len -- ) >COUNTED OVER ?$IZE PLACE COLLAPSE ;
: .$      ( addr len -- )  TYPE COLLAPSE ;

\ compile time string assignment
: ="       ( addr len -- <text> )  [CHAR] " PARSE 2SWAP !$ ;

: =""      ( addr len -- ) >COUNTED OFF ; \ sets string length to zero

HERE SWAP - DECIMAL .  .( Bytes)

COLLAPSE  ( initialize string stack)

\ 100 DIM A$ A$ =" Now is the time "
\ 100 DIM B$ B$ =" for all good men "
\ 100 DIM C$ C$ =" to come to the aid of their country."


