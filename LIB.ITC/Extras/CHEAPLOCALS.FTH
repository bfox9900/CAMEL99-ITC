\ cheaplocals.fth for Camel99 Forth                 Oct 2022 Brian Fox
\ ANS locals would consume over 1500 bytes of dictionary :-)
\ These non-standard locals use predefined names for simplicity. 
\ Locals index into the return stack using 9900 indexed addressing. 
\ To avoid self modifying code this means we need a word to get the value
\ and a separate word to "set" the value. 
\ This code uses 282 bytes for 4 locals. They are also faster then VALUEs
\ Use SYNONYM if you want different names for the setters and getters

\ NEEDS DUMP FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900

HERE
HEX
CODE LOCALS ( n --) \ build a stack frame n cells deep
\ RP R0 MOV, TOS 1 SLA, TOS RP SUB, R0 RPUSH,     TOS POP,
  C007 ,    0A14 ,   61C4 ,    0647 , C5C0 ,  C136 ,  NEXT,  ENDCODE

CODE /LOCALS  ( -- ) \ collapse stack frame
    C1D7 , NEXT, \ *RP RP MOV, NEXT,
ENDCODE

\ Local variable compilers make named code words
: GETTER  ( n --) \ create name that returns a contents of a local
\           TOS PUSH,  ( n) 2* (RP) TOS MOV,  NEXT,  ;
  CODE     0646 , C584 , C127 , CELLS ,       NEXT,  ;

\ create name that sets contents of a local
: SETTER ( n --) 
\      TOS SWAP CELLS (RP) MOV, TOS POP, 
  CODE    C9C4 ,   CELLS ,    C136 ,  NEXT,  ;

: ADDER  ( n -- ) \ defines a local for +! operation
\      TOS SWAP CELLS (RP) ADD, TOS POP, 
  CODE    A9C4 ,   CELLS ,    C136 ,   NEXT,  ;

\ defines a "getter" & "setter" on one line
: LOCAL:  ( n ) DUP GETTER  SETTER  ;

\ 4 locals is more than enough for most forth words 
 1 LOCAL: n1 n1! 
 2 LOCAL: n2 n2! 
 3 LOCAL: n3 n3! 
 4 LOCAL: n4 n4! 

HERE SWAP - DECIMAL . .( bytes ) \ 282 bytes 

\ USAGE
\ : NEWROT ( n1 n2 n3 -- n3 n1 n2) 
\  3 LOCALS           \ allocate space for 3 locals 
\    n3! n2! n1!      \ store the top 3 stack items 
\    n3 n1 n2         \ put them back on the stack rotated 
\  /LOCALS            \ de-allocate the locals 
\ ; 


