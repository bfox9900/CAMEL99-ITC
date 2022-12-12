\ transient compilation                        Mar 19 2022 Brian Fox
\ modified to default to use  H @ for TRANSIENT definitions memory
\ Jul 2022 DETACH now restores H to original address.

\ INCLUDE DSK1.TOOLS  \ for debugging
CR .( Compile transient code in LOW RAM and remove it later)
CR .( Remove temporary words with: DETACH )

HEX
VARIABLE OLDDP      \ remember the dictionary pointer
VARIABLE OLDH       \ remember the HEAP (low RAM)
VARIABLE OLDLINK    \ link field of a dummy word after PERMANENT

: TRANSIENT ( -- )
       H @ DUP>R  OLDH !
       HERE OLDDP !    \ save the dictionary pointer.
       R> DP !         \ Point DP to transient memory
;

: PERMANENT ( -- )
       HERE H !                    \ update heap pointer (LOW RAM)
       S"  " HEADER,               \ DUMMY word is blank. Can't be found
       LATEST @ NFA>LFA OLDLINK !  \ Remember LFA of DUMMY
       OLDDP @ DP !                \ restore normal dictionary
       OLDDP OFF
;

\ removes everything from TRANSIENT to this definition
\ restores heap to previous address
: DETACH
       [ LATEST @ ] LITERAL  \ compute NFA of DETACH, compile a literal no.
       OLDLINK @ !           \ OLDLINK holds LFA of DUMMY word, re-link to it
       OLDH @ H ! ;          \ restore HEAP pointer also
