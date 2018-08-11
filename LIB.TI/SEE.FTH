\ see.fth a decompiler for CAMEL99    brian fox 2018
\ License: Free for non-commercial use

HEX
INCLUDE DSK1.CASE.F

\ support words
: .ID        ( nfa --) COUNT 1F AND TYPE ;

: .####     ( n --) 0 <# # # # # #> TYPE ;

: ?BREAK    ( -- )
	    KEY?
            IF 
               CR ." *BREAK*" ABORT
            THEN ;

\ Getting back from the CFA to the NFA is tricky in CAMEL Forth
: CFA>NFA  ( cfa -- nfa | 0 )
            2-           \ cfa-2 gets to end of name text
            BEGIN
              2- DUP C@  \ dect the address and fetch the byte
              0FE AND    \ mask out immediate bit and check byte count
            0= UNTIL     \ 0 means we found immediate field address
            1+ ;         \ +1 byte puts us at nfa

\ determine if a memory cell contains a word
\ if not it must be a number.
: VALIDWORD? ( nfa -- nfa | 0 )
            LATEST @
            BEGIN
              NFA>LFA @
              2DUP = OVER 0= OR
            UNTIL
            NIP ;

: LOOKUP    ( <text> -- cfa)
            BL WORD FIND  0= ABORT" Not a word" ;

CR .( ..) 
     VARIABLE IMMFLAG    \ set if decompiled word is immediate
HEX
 045A    CONSTANT $NEXT  \ machine code for CAMEL99 NEXT (B *R10)

( lookup XTs of special words at compile time) 
( declare constants for speed)
' EXIT   CONSTANT 'EXIT
' (S")   CONSTANT '(S")
' DOVAR  CONSTANT 'DOVAR
' DOCON  CONSTANT 'DOCON
' DOUSER CONSTANT 'DOUSER

: TAB       ( -- ) 4 SPACES ;
: ?NEWLINE  ( -- ) OUT @ 5 + C/L@ > IF CR TAB THEN ;

: IMMED?    ( nfa -- f ) 1- C@ 1 AND NEGATE ;

: CLEANSTK  ( -- )  SP0 SP!  CR QUIT ;

: .VARIABLE ( nfa cfa -- nfa)
            CR  ." VARIABLE " OVER .ID ."  = "  >BODY @ U.
            CLEANSTK ;

: .CONSTANT ( nfa cfa -- nfa)
            CR  DUP >BODY @ U. ." CONSTANT " OVER .ID
            CLEANSTK ;

\ only works with workspace=8300
: .USER     ( nfa cfa -- nfa) 
            CR  DUP >BODY @ DUP  U. ." USER " ROT .ID
            ."  = " 8300 + @ U.
            CLEANSTK ;

: .EXIT     ( cfa -- )
            ."  ; "
            IMMFLAG @ IF CR TAB ." IMMEDIATE" THEN  
            CR  ;

.( ..)
CHAR " CONSTANT '"'

: .SQUOTE   ( addr -- addr' )
            CR TAB
            [CHAR] S EMIT '"' EMIT SPACE
            CELL+ COUNT 2DUP TYPE '"' EMIT SPACE     \ emit closeing quote
            + ALIGNED  2-    \ compute address past the string
            NIP ;             \ remove old address

\ test for word type
: ?CODE  ( cfa -- ?) DUP @ 2- = ;
: ?COLON ( cfa -- ?) @  ['] DOCOL @ OVER = ;

: .CODEWORD ( NFA CFA -- ) \ tms9900 specific
            CR ." CODE "  OVER .ID
            CR TAB
            >BODY   \ advance to data field
            BEGIN
              DUP @  ?NEWLINE .#### ."  , "
              CELL+ 
              DUP @ $NEXT =
            UNTIL
            DROP
            CR TAB ." NEXT,"
            CR ." ENDCODE"  ;

: .COLONWORD  ( cfa -- )
            CFA>NFA              \ -- nfa
            DUP  VALIDWORD?      \ -- nfa ?
            IF
              ?NEWLINE .ID SPACE
            ELSE
              SWAP  \ not a word so drop the nfa
                    \ fetch the contents and print it
              DUP @ .  SPACE                                                                 
            THEN ;

.( ..)
: DECOMPILE ( nfa cfa -- )
            CR ." : "  OVER .ID
            CR TAB
            BEGIN
              CELL+    \ move to next cell in the thread
              DUP @              \ -- cell XT
              DUP 'EXIT = 0=  \ not the end of word?
            WHILE
              DUP '(S") =       \ is it a string?
              IF   
                   ( cfa) DROP
                   .SQUOTE
              ELSE
                   .COLONWORD    \ it's a colon def.
              THEN ?BREAK
            REPEAT
           .EXIT  SP0 SP! CR ;   \ print the ending

: DATA-DECODER ( cfa -- ) \ show single data types correctly
            DUP @     ( -- xt)
            CASE
              'DOVAR  OF  .VARIABLE     ENDOF
              'DOCON  OF  .CONSTANT     ENDOF
              'DOUSER OF  .USER         ENDOF
            ENDCASE ;

.( ..)
: SEE       (  -- <string> )
            IMMFLAG OFF
            LOOKUP DUP CFA>NFA SWAP  ( -- nfa cfa)
            DUP ?CODE \ alternate:  ABORT" Can't decompile code word"
                     IF  .CODEWORD DROP EXIT THEN
            OVER IMMED?  IMMFLAG !  \ set flag if the word is immediate
            DATA-DECODER
            DECOMPILE
;
