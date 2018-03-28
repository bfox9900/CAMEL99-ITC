\ FAST vector table from HsForth, Jim Kalihan (RIP)
\ no speed difference versus  CASE OF ENDOF  etc.. for 2 items
\ improves greatly with long list of cases.

: CASE:  ( -- -7)   CREATE   ;
: |      ( <name> )  '  ,  ;
: ;CASE   ( n -- )  DOES>  OVER + + @ EXECUTE ;  \ !! no runtime error checking !!

\ example code:
\ : FOO   ." FOO" ;
\ : BAR   ." BAR" ;
\ : FIZZ  ." FIZZ" ;
\ : BUZZ  ." BUZZ" ;

\ CASE: CHOICE  ( n -- ) | FOO  | BAR | FIZZ | BUZZ  ;CASE
\ Usage:   3 CHOICE  ( executes BUZZ)

\ equivalent with Eaker CASE statement
\ : TEST
\         CASE
\           0 OF  FOO ENDOF
\           1 OF  BAR ENDOF
\           2 OF FIZZ ENDOF
\           3 OF BUZZ ENDOF
\         ENDCASE  ;
