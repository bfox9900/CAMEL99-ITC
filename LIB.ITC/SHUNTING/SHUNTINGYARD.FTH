\ Shunting-yard algorithm in Forth

\ convert infix expression to reverse polish notation
\ Output is an RPN text string that can be interpreted or compiled

\ while there are tokens to be read:
\       read a token.
\       if the token is a number, then push it to the output queue.
\       if the token is an operator, then:
\               while there is an operator at the top of the operator stack with
\                       greater than or equal to precedence and the operator is left associative:
\                               pop operators from the operator stack, onto the output queue.
\               push the read operator onto the operator stack.

\       if the token is a left bracket (i.e. "("), then:
\               push it onto the operator stack.

\       if the token is a right bracket (i.e. ")"), then:
\               while the operator at the top of the operator stack is not a left bracket:
\                       pop operators from the operator stack onto the output queue.
\               pop the left bracket from the stack.
\               *** IF THE STACK RUNS OUT WITHOUT FINDING A LEFT BRACKET, 
\                   THEN THERE ARE MISMATCHED PARENTHESES. ***

\ if there are no more tokens to read:
\               while there are still operator tokens on the stack:
\ *** IF THE OPERATOR TOKEN ON THE TOP OF THE STACK IS A BRACKET, THEN THERE ARE MISMATCHED PARENTHESES. ***
\               pop the operator onto the output queue.
\ exit.

NEEDS CASE FROM DSK1.CASE

\ ===================================
\ === CREATE A STRING STACK ===
\ string stack is the OPERATOR stack in this implementation
DECIMAL
\ string stack ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero
: TOP$     ( -- ) SSP @ PAD + ;

\ string stack helpers ====
: SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" String stack underflow" ;
: DROP$    ( -- ) ?SSP MXLEN NEGATE SSP +! ;

: $PUSH    ( $adr -- top$ ) COUNT SPUSH ;

: ,"          ( -- ) [CHAR] " PARSE  S,  ;  IMMEDIATE

: (")      ( -- ) R> DUP COUNT + ALIGNED >R ; \ advance IP on Rstack, past end of string

: "        ( -- )
           STATE @                          \ are we compiling?
           IF    POSTPONE (") ,"            \ action when Compiled
           ELSE  [CHAR] " PARSE SPUSH       \ action when interpreted
           THEN ; IMMEDIATE

\ ==================================
\     === CREATE OUTPUT QUEUE ===

CREATE OUTQ  80 ALLOT     \ output Queue is a counted string: 80 bytes

\   === Output Queue Operators ===
: C+!         ( n addr -- )   DUP >R  C@ +  R> C! ;
: APPEND-CHAR ( char caddr -- ) DUP >R COUNT DUP 1+ R> C! + C! ;
: +PLACE      ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;
: EMPTY       ( caddr -- )    0 SWAP C! ;

OUTQ EMPTY    \ init output Q

: =$          ( $1 $2 -- flag) OVER C@ 1+ S= 0= ;

: NOT   ( ? -- ?) 0= ;

\ === CONVERT NUMBER TO STACK STRING ===
\ this word adds a trailing space to the number string created
\ : N>S        ( n -- addr len) DUP ABS 0  <#  BL HOLD  #S ROT SIGN  #> ;

\ ======================================
\      === HIGH LEVEL SOLUTION ===

CREATE OPERATORS  ," +" ," -" ," /" ," *" ," ^"

: NEXT$   ( $[1] -- $[2] ) COUNT + ;                     \ get next string in a list

: NTH    ( n list -- $addr ) SWAP 0  DO   NEXT$   LOOP ; \ the nth string in a list

: ]OPERATOR   ( n -- ) OPERATORS NTH ;

: '('   ( -- adr len) S" (" ;
: ')'   ( -- adr len) S" )" ;
: '+'   ( -- adr len) S" +" ;
: '-'   ( -- adr len) S" -" ;
: '*'   ( -- adr len) S" *" ;
: '/'   ( -- adr len) S" /" ;


CREATE TOKEN$   20 ALLOT

: READ_TOKEN  ( -- TOKEN$ ) BL WORD COUNT TOKEN$ PLACE TOKEN$ ;

: >OUTQ       ( $adr -- )
              COUNT OUTQ +PLACE      \ put $adr in output queue
              BL OUTQ APPEND-CHAR ;   \ +PLACE a blank to the Queue

: OPSTACK? ( -- ?) SSP @ 0> ;        \ are there more ops on the op stack?

\ search for char in a string
: CHARSCAN    ( char addr len -- n)  ROT SCAN NIP ;


: OPS       ( -- adr len) S" ^/*+-" ;   \ valid operators in precedence order

: OPERATOR? ( $adr -- ?)  1+ C@  OPS CHARSCAN ;

\ is op$1 higher precendence than op$2
: PRECEDENCE  (  OP$1 OP$2 -- ?)  OPERATOR? SWAP OPERATOR? SWAP > ;

: ISNUMBER? ( $adr -- ?) ?NUMBER NIP ;
: FUNCTION? ( $adr -- ?)  FIND NIP ;

: MATCH         ( $adr adr len -- ?)  DROP SWAP COUNT S= 0= ;  \ common factor to test tokens

: POP-UNTIL-LEFT ( -- )
                  -1          \ TRUE flag means mis-match
                  BEGIN
                     TOP$ '('  MATCH NOT
                  WHILE
                     TOP$ >OUTQ DROP$
                     DROP 0   \ reset the flag
                  REPEAT
                  DROP$       \ drop the left bracket
                  ABORT" mis-matched brackets"  ; \ if -1 is still on stack abort

\ debugging words ...
: $.      ( $ -- ) COUNT TYPE ;

: ]TOP$     ( n -- $)  SSW * PAD + ;             \ index into the string stack to get a specific string
: $DEPTH    ( -- n)  TOP$ PAD - SSW  / ;         \ return the depth of the string stack

: .SS       ( -- )        \ non-destuctive string stack viewer
            1 $DEPTH 1+
            ?DO
               I . ." : "  I ]TOP$ $. CR
            -1 +LOOP ;

: .TOKEN     ." Token=" TOKEN$ $. ;

: OPSTACK->OUTQ ( -- )
              BEGIN 
                OPSTACK?
              WHILE
                TOP$ >OUTQ DROP$
              REPEAT ;

: INFIX       ( -- )
              OUTQ EMPTY
              COLLAPSE
              BEGIN
                   READ_TOKEN C@ 0>
              WHILE
                 TOKEN$ OPERATOR? IF  CR ." OP! " .TOKEN
                                      BEGIN OPSTACK?
                                      WHILE
                                           TOP$ >OUTQ DROP$
                                      REPEAT
                                      TOKEN$ SPUSH
                                                            ELSE

                TOKEN$ ISNUMBER? IF  CR ." Num! " .TOKEN
                                     TOKEN$ >OUTQ           ELSE


                TOKEN$ '('  MATCH IF   CR '(' TYPE  .TOKEN
                                       TOKEN$ SPUSH         ELSE

                TOKEN$ ')'  MATCH IF    CR ')' TYPE  .TOKEN
                                       POP-UNTIL-LEFT       ELSE

                       ( DEFAULT) -1 ABORT" INFIX: bad expression"
                
                 THEN THEN THEN THEN

              REPEAT 
              OPSTACK->OUTQ 
              COLLAPSE ;



