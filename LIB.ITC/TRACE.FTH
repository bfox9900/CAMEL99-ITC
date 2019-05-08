\ TRACE colon definitions Forth Dimensions III/2 P.58 26OCT82 LCT
\ Part of original TI-Forth
\ Modified for ANS Forth/CAMEL99            Jan 7 2018 B J Fox

\ Aug 9 2018 Improved on screen look
\            *SEE TRACE.FTH for test code

NEEDS .S FROM DSK1.TOOLS

HEX
\ Camel Forth dictionary needs help to get from an XT (CFA) back to the NFA
\ Algorythm:    look backwards until you see a '0' or '01'
\               This puts you at the precedence bit field. ( immediate flag)
\               Then go FORWARD 1 byte to get to the NFA
: CFA>NFA ( cfa -- nfa)
                 2-     \ odd length names have 1 empty byte at the end
                 BEGIN
                   2- DUP C@
                   0FE AND 0=  \ mask out immediate bit, check for zero
                 UNTIL         \ we found the immediate field
                 1+  ;         \ advance 1 byte to get to the NFA

: ID.     ( xt -- ) CFA>NFA COUNT 1F AND ?DUP IF TYPE SPACE THEN ;

: ?FREEZE  ( -- )
           KEY?     
           IF 80 MS
              BEGIN  KEY?  UNTIL
           THEN ;

VARIABLE TRACE    \ controls if trace runs or not

: (TRACE) ( -- )
          ?BREAK
          TRACE @
          IF
             CR ." >" R@ ID.  SPACE  .S  ." <-"
           THEN
          ?FREEZE ;

\ re-define COLON to compile (TRACE) routine into every definition
: :     ( -- ) !CSP  HEADER (:NONAME)  COMPILE (TRACE) ;

\ Now anything that's defined/re-defined with ':' will be traceable


