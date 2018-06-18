\ FOR NEXT  demonstration 
\ Even using R15 for loop index it is a little faster than do/loop
\ not worth the effort :-)


\ *************************************
\ *    NOT MULTI-TASKER COMPATIBLE    *
\ *************************************

INCLUDE DSK1.TOOLS.F        \ debugging tool
INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.ELAPSE.F       \ used for timing

CODE (FOR)
      R15 RPUSH,
      TOS R15 MOV,
      TOS POP, 
      NEXT,
      ENDCODE

\ R9 CONSTANT IP          \ R9 is the forth IP register
HEX
CODE (NEXT)
      *RP DEC,  ( R15 DEC,)      \ increment loop ON RSTACK or R15
       NC IF,             \ if NO carry then exit loop
           R9 INCT,       \ move past (LOOP)'s in-line parameter
           RP INCT,  ( 15 RPOP,)
       ELSE,
           R9 ** R9 A,    \ jump back: ADD *IP,IP
       ENDIF,
       NEXT,              \ NEXT via R10
\ - OR - use this version
\       R9 *+ W MOV,      \ inline NEXT for max loop speed
\      *W+  R5 MOV,
\       R5 ** B,
       ENDCODE

CODE N   ( -- n) \ n is the loop index for these Forth loops
     TOS PUSH,
     R15 TOS  MOV,
     NEXT,
     ENDCODE

\ : FOR       ( n -- ) ?COMP      POSTPONE (FOR) HERE 67 ;  IMMEDIATE
: FOR       ( n -- ) ?COMP      POSTPONE >R HERE 67 ;  IMMEDIATE
: NEXT      ( -- )   67 ?PAIRS  POSTPONE (NEXT) BACK ; IMMEDIATE

HEX
: FORTEST  FFFF FOR NEXT ;   \ down count from FFFF to 0
: DOTEST   FFFF 0 DO LOOP ;

: FORTEST2  FFFF FOR  R@ DROP  NEXT ;
: DOTEST2   FFFF 0 DO  I DROP  LOOP ;

\ ELAPSE FORTEST 
\ ELAPSE DOTEST
\ ETC...




