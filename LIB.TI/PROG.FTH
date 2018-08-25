\ PROG:  a Compiler Directive to create a BLWP SUB-PROGRAM
\ ... THAT CALLS ITSELF!

\ Just use the name in a Forth program and it uses it's own register set
\ and then returns to Forth.

\ Interface to Forth is through the a workspace that you create.
\ The addresses of your workspace are just like a forth variable.
\ so use @ ! C@ C! etc.

\ ALTERNATIVE INTERFACE:
\ Use this [TOS] macro to reference the Forth TOS register in your code
: [TOS]  8 R13 () ;      \ macro for Forth's TOS register

: PROG: ( wksp -- )
       CREATE
         ( wksp) ,  HERE CELL+ ,
         !CSP
      ;CODE *W BLWP,
               NEXT,
            ENDCODE

: ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.


\ Usage Example:
\
\  CREATE WKSP2 16 CELLS ALLOT  \ for 16 registers

\  WKSP2        CONSTANT XR0  \ name the "external registers" as needed
\  XR0   CELL+  CONSTANT XR1
\  XR1   CELL+  CONSTANT XR2
\  XR2   CELL+  CONSTANT XR3

\ load external registers with input parameters like normal variables
\     7 XR0 !
\    -1 XR1 !
\  9999 XR2 !
\ MYVAR XR3 !

\ WKSP2 PROG: APROGRAM
\     \ R0            \ r0 contains the 7
\       R1 Q LI,      \ R1 holds -1
\     	R2   CLR,     \ R2 holds 9999
\     	R3   CLR,     \ R3 has the address of MYVAR

\     < your code goes here>

\     	RTWP,
\      ;PROG

\ Read the results from the external registers
\ : RESULTS    XR1 @ IF ." GOOD"  ELSE  ." BAD!"  THEN ;