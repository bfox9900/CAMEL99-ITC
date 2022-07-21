\ reverse a string in place

NEEDS DUMP  FROM DSK1.TOOLS

: EXCHANGE ( a1 a2 -- ) 2DUP C@ SWAP C@ ROT C! SWAP C! ;

: REVERSE ( c-addr u -- )
      1- BOUNDS  ( -- end-addr start-addr )
      BEGIN  2DUP >     \ end>start?
      WHILE
         2DUP EXCHANGE  \ exchange bytes
        -1 /STRING      \ adjust the pointers (this is clever)
      REPEAT
      2DROP ;

: A$ S" ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" ;
  CR A$ TYPE
  CR
  CR A$ 2DUP REVERSE TYPE

