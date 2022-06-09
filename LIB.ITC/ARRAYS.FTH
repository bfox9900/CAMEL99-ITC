\ Traditional Forth array words                  Updated Apr 6 2021 Fox
\ These work as expected but were a litte slow due to DOES> overhead
\ *G Replaced runtime Forth with machine code that is ~2X faster

\ CARRAY  creates a byte size array.
\ Usage:  20 CARRAY Q     99 Q C!   Q C@ . ( 99)
HEX
\ : CARRAY ( n -- ) CREATE  ALLOT  ALIGN     DOES>  + ;
: CARRAY ( n -- )
      CREATE  ALLOT ALIGN  \ compile time
;CODE ( n -- addr)         \ RUN time
      A108 ,  \ W TOS ADD,
      NEXT,
      ENDCODE

\ ARRAY  creates a fast cell size array.
: ARRAY ( n -- )
      CREATE 2+ CELLS ALLOT      \ compile time
;CODE ( n -- addr)             \ RUN time
       A104 ,   \  R4 R4 ADD,  \ 2*  ie: CELLS
       A108 ,   \  W  R4 ADD,  \ base-address+tos=address'
       NEXT,
       ENDCODE

\ ** Usage:
\ ** HEX 1000 CARRAY []Q     99 6 []Q C!   6 []Q C@ . ( 99)
\ ** HEX 1000 ARRAY  []T   1234 3 []T !    3 []T @ .  ( 1234)
\ ** : ATEST  1000 0 DO  I []T @ DROP  LOOP ;

DECIMAL
