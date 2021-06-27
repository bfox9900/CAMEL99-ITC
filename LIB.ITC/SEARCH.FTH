\ search.fth  for Camel99 Forth     Brian Fox  26Jun2020
( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ Search the string specified by c-addr1 u1 for the string specified by c-addr2
\ u2. If flag is true, a match was found at c-addr3 with u3 characters remaining
\ If flag is false there was no match and c-addr3 is c-addr1 and u3 is u1.

NEEDS COMPARE FROM DSK1.COMPARE

HEX
CODE 2OVER ( a b c d e--  a b c d e a)
         0646 , C584 ,  \ TOS PUSH,         \ 28
         C126 , 0006 ,  \ 6 (SP) TOS MOV,   \ 22
         0646 , C584 ,  \ TOS PUSH,         \ 28
         C126 , 0006 ,  \ 6 (SP) TOS MOV,   \ 22
         NEXT,                             \ =100
         ENDCODE

\ : 4DUP     (  d d2  --  d d2 d d2) 2OVER 2OVER ;
: 2NIP     ( a b c d -- c d ) 2SWAP 2DROP ;

: SEARCH  ( caddr1 u1 caddr2 u2 -- caddr3 u3 flag)
         2SWAP (  -- caddr2 u2 caddr1 u1 )
         BEGIN
            DUP ( test u1 )
         WHILE
            2OVER 2OVER ROT MIN S= INVERT
            IF 2NIP
               TRUE
               EXIT
            THEN             ( jump to ';')
            1 /STRING        ( cut caddr1 u1)
         REPEAT
         2NIP
         FALSE ;
