
\ FAST vector table from HsForth, Jim Kalihan (RIP)
\ no speed difference versus  CASE OF ENDOF  etc.. for 2 items
\ improves greatly with long list of cases.

: CASE:  ( -- <name>)   CREATE   ;

: |      ( <name> )  '  ,  ;

\ !! no runtime error checking !!
: ;CASE   ( n -- )  DOES>  OVER + + @ EXECUTE ;

\ example code:
\ : FOO   ." FOO" ;
\ : BAR   ." BAR" ;
\ : FIZZ  ." FIZZ" ;
\ : BUZZ  ." BUZZ" ;

\ Usage 1:
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

\ Usage 2:
\ Define headless routines. Saves space!
\ The definition's XT's fall onto the stack in reverse order
\ :NONAME ." BUZZ" ;
\ :NONAME ." FIZZ" ;
\ :NONAME ." BAR" ;
\ :NONAME ." FOO" ;

\ COMMA the 4 XTs into the case statement
\ CASE: ONGOTO  , , , ,   ;CASE
