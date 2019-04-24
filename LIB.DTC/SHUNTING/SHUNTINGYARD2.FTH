\ Shunting-yard algorithm in Forth

\ convert infix expression to reverse polish notation
\ Output is an RPN text string that can be interpreted or compiled

\ while there are tokens to be read:
\       read a token.
\       if the token is a number, then push it to the output queue.

\       if the token is an operator, then:
\               while there is an operator at the top of the operator stack with

\ while (( 1. there is a function at the top of the operator stack)
\      2.  or (there is an operator at the top of the operator stack with greater precedence)
\      3.  or (the operator at the top of the operator stack has equal precedence and is left associative))
\      4. and (the operator at the top of the operator stack is not a left bracket):

\  wend
\ Push the read operator onto the operator stack.

\       if the token is a left bracket (i.e. "("), then:
\               push it onto the operator stack.

\       if the token is a right bracket (i.e. ")"), then:
\               while the operator at the top of the operator stack is not a left bracket:
\                       pop operators from the operator stack onto the output queue.
\                       pop the left bracket from the stack.
\                   *** IF THE STACK RUNS OUT WITHOUT FINDING A LEFT BRACKET,
\                       THEN THERE ARE MISMATCHED PARENTHESES. ***

\ if there are no more tokens to read:
\               while there are still operator tokens on the stack:
\ *** IF THE OPERATOR TOKEN ON THE TOP OF THE STACK IS A BRACKET, THEN THERE ARE MISMATCHED PARENTHESES. ***
\               pop the operator onto the output queue.
\ exit.


NEEDS DUMP FROM DSK1.TOOLS
\ NEEDS CASE FROM DSK1.CASE

\ =========================================
\ === CREATE STRING STACK FOR OPERATORS ===
DECIMAL
\ string stack ====
         VARIABLE SSP     \ the string stack pointer
     255 CONSTANT MXLEN   \ 255 bytes is longest string
MXLEN 1+ CONSTANT SSW     \ width of string stack items

: NEW:     ( -- ) SSW SSP +! ;  \ bump the string stack pointer by 256
: COLLAPSE ( -- ) SSP OFF  ;    \ reset string stack pointer to zero
: TOP$     ( -- ) SSP @ PAD + ;

COLLAPSE

\ string stack helpers ====
: SPUSH    ( addr len -- top$ ) NEW: TOP$ DUP >R PLACE R> ;
: ?SSP     ( -- ) SSP @ 0= ABORT" Op stack underflow" ;
: DROP$    ( -- ) ?SSP SSW NEGATE SSP +! ;

\ debugging words ...
: $.      ( $ -- ) COUNT TYPE ;
: ]TOP$   ( n -- $)  SSW * PAD + ;      \ index into the string stack
: $DEPTH  ( -- n)  TOP$ PAD - SSW  / ;  \ return the depth of the string stack

: .SS     ( -- )        \ non-destuctive string stack viewer
          1 $DEPTH 1+
          ?DO
               I . ." : "  I ]TOP$ $. CR
          -1 +LOOP ;

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

: COMPARE                     ( a1 n1 a2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS ?DO                ( a1)
        COUNT  I C@  -        ( a1 diff)
        DUP 
        IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT              ( a1 diff)
         THEN  DROP           ( a1)
    LOOP 
    DROP                      ( )
    R>  DUP IF  0> 1 OR  THEN   \  2's complement arith.
;

: NOT   ( ? -- ?) 0= ;

\ ======================================
\      === HIGH LEVEL SOLUTION ===

CREATE OPS  10 ALLOT  S" ^/*-+"  OPS PLACE   \ S" +-*/^"

: OPERATORS ( -- addr len)  OPS COUNT ;

\ search for char in a string
: CHARSCAN    ( char addr len -- n)  ROT SCAN NIP ;
: 1STCHAR     ( caddr len -- c)  DROP C@ ;
: PRECEDENCE  ( caddr len -- n)  1STCHAR OPERATORS CHARSCAN ;

\ operators defined as string literals
: '('   ( -- adr len) S" (" ;
: ')'   ( -- adr len) S" )" ;
: '+'   ( -- adr len) S" +" ;
: '-'   ( -- adr len) S" -" ;
: '*'   ( -- adr len) S" *" ;
: '/'   ( -- adr len) S" /" ;
: '^'   ( -- adr len) S" ^" ;


CREATE INBUFFER   20 ALLOT

: TOKEN  ( -- caddr len) INBUFFER COUNT ;

: READ_TOKEN ( -- token len ) BL PARSE-WORD INBUFFER PLACE  ;

: >OUTQ     ( cadr len -- )  OUTQ +PLACE   BL OUTQ APPEND-CHAR ;

: OPSDEPTH  ( --  n) $DEPTH ;  \ depth of opstack

: NUMBER?   ( addr len -- ?) 0 0 2SWAP >NUMBER NIP 0= NIP NIP  ;
: FUNCTION? ( addr len -- ?) FIND NIP ;
: OPERATOR? ( addr len -- ?) PRECEDENCE ;
: MATCH     ( adr len adr len -- ?) COMPARE 0= ;

: TOPOP     ( -- adr len) TOP$ COUNT ;
: PUSHOP    ( addr len -- ) NEW: TOP$ PLACE ;

: .PRINT    ( addr len -- ) TYPE SPACE ;
: POP.PRINT ( -- ) .PRINT DROP$ ;

: ?OPS      ( -- ) OPSDEPTH 0= ABORT" OPS stack empty" ;

: ?VALID    ( token -- ) 0=  ABORT" Bad operator" ;

: ?MISMATCH ( -- )
            OPSDEPTH
            IF  TOPOP ')' MATCH  ABORT" mis-matched brackets"  THEN ;

: POP-UNTIL-LEFT ( -- )
              BEGIN
                 ?OPS
                 TOPOP '(' MATCH NOT
              WHILE
                 TOPOP POP.PRINT
              REPEAT 
              DROP$ ;  \ drop the ')'

: OPERATOR ( token -- )
              TOKEN PRECEDENCE  ?VALID
              OPSDEPTH
              IF
                BEGIN
                  OPSDEPTH                            \ 1.
                  TOPOP PRECEDENCE TOKEN PRECEDENCE >  \ 2.
                  OR
                  FALSE  OR                           \ 3.
                  TOPOP '(' MATCH NOT  AND            \ 4.
                WHILE
                  TOPOP '(' MATCH
                  IF   DROP$
                  ELSE TOPOP POP.PRINT
                  THEN
                REPEAT

              ELSE
               TOKEN PUSHOP
              THEN ;

: OPSTACK.PRINT
              BEGIN
                 OPSDEPTH
               WHILE
                 ?MISMATCH
                 TOPOP POP.PRINT 
              REPEAT ;

: INFIX       ( -- )
              OUTQ EMPTY
              COLLAPSE
              CR
              BEGIN
                   READ_TOKEN
                   INBUFFER C@
              WHILE

                TOKEN NUMBER?   IF  TOKEN .PRINT      ELSE

                TOKEN OPERATOR? IF  OPERATOR    ELSE

                TOKEN '(' MATCH IF  TOKEN PUSHOP      ELSE

                TOKEN ')' MATCH IF  POP-UNTIL-LEFT    ELSE

                ( DEFAULT) -1 ABORT" INFIX: bad expression"

                 THEN THEN THEN THEN

              REPEAT
              OPSTACK.PRINT
              ?MISMATCH
;


\   INFIX 3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3
\         3 4 2 × 1 5 - 2 3 ^ ^ ÷ +
