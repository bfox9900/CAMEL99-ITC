\ FAST vector table from HsForth, Jim Kalihan (RIP)
\ no speed difference versus  CASE OF ENDOF  etc.. for 2 items
\ improves greatly with long list of cases.
\ Added Perfom for Camel99 Forth V2.5...

: CASE:  ( -- <name> ) CREATE  ;
: |      ( <name> )  '  ,  ;

\ !! no runtime error checking !!
: ;CASE   ( n -- )  DOES> SWAP 2* + PERFORM ; \  @ EXECUTE ;

\ example code:
 : FOO   ." FOO" ;
 : BAR   ." BAR" ;
 : FIZZ  ." FIZZ" ;
 : BUZZ  ." BUZZ" ;

\ NO ERROR PROTECTION
 CASE: CHOICE  ( n -- ) | FOO  | BAR | FIZZ | BUZZ  ;CASE

\ simple error protection
: OOPS!    TRUE ABORT" choice error" ;
CASE: TABLE  ( n -- ) | OOPS! | FOO  | BAR | FIZZ | BUZZ  | OOPS! ;CASE

: CLIP      ROT MIN MAX ;
: CHOICES    0  5 CLIP  TABLE ;

\ Usage:   3 CHOICES  ( executes BUZZ)
\ equivalent with Eaker CASE statement
\ : TEST
\         CASE
\           0 OF  FOO ENDOF
\           1 OF  BAR ENDOF
\           2 OF FIZZ ENDOF
\           3 OF BUZZ ENDOF
\         ENDCASE ;
