\ FAST vector table from HsForth, Jim Kalihan (RIP)
\ no speed difference versus  CASE OF ENDOF  etc.. for 2 items
\ improves greatly with long list of cases.

INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.TOOLS.F

INCLUDE DSK1.INLINE.F

CODE VECTR  INLINE[ OVER + + ] NEXT, ENDCODE

CODE PERFORM ( addr -- )
             *TOS TOS MOV,    \ fetch the XT
              TOS W MOV,      \ move the execution token in TOS into temp
              TOS POP,        \ refill TOS
             *W+ R5 MOV,      \ move contents of the XT (the address of the doer routine) to R5
              R5 ** B,        \ branch to the address of the DOER routine
              ENDCODE


: CASE:  ( -- -7)   CREATE   ;

: |      ( <name> )  '  ,  ;

\ !! no runtime error checking !!
\ : ;CASE   ( n -- )  DOES>  OVER + + @ EXECUTE ;
\ : ;CASE   ( n -- )  DOES>  VECTR PERFORM ;


CREATE Q  111 , 222 , 333 , 444 ,  ;CODE  TOS PUSH,  W TOS MOV,   NEXT,  ENDCODE

;CODE DOVECTR
      *W





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
