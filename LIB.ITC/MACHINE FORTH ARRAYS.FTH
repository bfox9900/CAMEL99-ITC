\ Machine forth array words use machine MACROS
NEEDS .S    FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900

\ These work as expected but are a litte slow due to DOES> overhead

\ CARRAY  creates a byte size array.
: CARRAY ( n -- )
         CREATE  ALLOT
         ;CODE  ( n -- a )
                *W TOS MOV,
                TOS TOS ADD,
                NEXT,
          ENDCODE


\ ARRAY  creates a cell size array.
: ARRAY ( n -- )
         CREATE  CELLS ALLOT
         ;CODE ( n -- a )
               *W W MOV,
               TOS TOS ADD,
               W   TOS ADD,
               NEXT,
         ENDCODE

\ 100 ARRAY ]Q


\ ALTERNATIVE Method: array operators
CODE []    ( ndx  addr -- addr[n]) *SP *SP ADD,  *SP+ TOS ADD, NEXT, ENDCODE

: []@   ( ndx addr -- n') [] @ ;
: []!   ( n ndx addr -- ) [] ! ;

\ Usage examples
\ CREATE Q  200 CELLS ALLOT
\ 99 0  Q []!
\  Q []@  .

\ fastest Forth method: specific array operation
\ : ]Q ( n -- addr )  CELLS Q + ;

\ Usage examples
\ 99 6 ]Q !
\ 6 ]Q @ .
