\ PROG:  a Compiler Directive to create a BLWP SUB-PROGRAM
\ ... THAT CALLS ITSELF!

\ Just use the name in a Forth program and it uses it's own register set
\ and then returns to Forth.

\ Interface to Forth is through the QREGS workspace.
\ The base address of QREGS workspace is used just like a forth variable.
\ The external registers are just memory so use @ ! C@ C! etc.

\ QREGS           = R0
\ QREGS CELLS+    = R1
\ QREGS 2 CELLS + = R2
\ etc...
\ R13,R14 & R15 must not be used. The contain the return vector back to Forth.

\ ALTERNATIVE INTERFACE:
\ Use the [TOS] macro to reference the Forth TOS register.
                                                       
: PROG: ( wksp -- )
       CREATE
         ( wksp) ,  HERE CELL+ ,
         !CSP
      ;CODE *W BLWP,
               NEXT,
            ENDCODE

: ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.

: [TOS]  8 R13 () ;      \ macro for Forth's TOS register

\ Usage Example:
\ QREGS PROG: INIT-QREGS   \ code that initializes wksp
\     \ R0            \ can be an input/output buffer
\       R8 Q LI,      \ R8 holds the Q data buffer address
\     	R9   CLR,     \ R9 is the input pointer
\     	R10  CLR,     \ R10 is the output pointer
\     	RTWP,
\      ;PROG