\ search.fth  for Camel99 Forth     Brian Fox  26Jun2020
( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ Search the string specified by c-addr1 u1 for the string specified by c-addr2
\ u2. If flag is true, a match was found at c-addr3 with u3 characters remaining
\ If flag is false there was no match and c-addr3 is c-addr1 and u3 is u1.

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.3RD4TH
NEEDS COMPARE FROM DSK1.COMPARE

\ : 2OVER   3 PICK 3 PICK ;
HEX
 CODE 2OVER ( a b c d e--  a b c d e a)
         0646 , C584 ,  \ TOS PUSH,         \ 28
         C126 , 0006 ,  \ 6 (SP) TOS MOV,   \ 22
         0646 , C584 ,  \ TOS PUSH,         \ 28
         C126 , 0006 ,  \ 6 (SP) TOS MOV,   \ 22
         NEXT,                             \ =100
         ENDCODE

\ : 4DUP   (  d d2  --  d d2 d d2) 3 PICK 3 PICK 3 PICK 3 PICK ; \ 7.6 sec
\ : 4DUP   (  d d2  --  d d2 d d2) 4TH 4TH 4TH 4TH  ; \ 6.3 sec
\ : 4DUP   (  d d2  --  d d2 d d2) 2OVER 2OVER ; \ 5.85
: 4DUP   POSTPONE 2OVER POSTPONE 2OVER ; IMMEDIATE  ( MACRO 5.25 )

: 2NIP     ( a b c d -- c d ) 2SWAP 2DROP ;

: INSTR   S" ROT MIN S=" EVALUATE ; IMMEDIATE

: SEARCH  ( caddr1 u1 caddr2 u2 -- caddr3 u3 flag)
         2SWAP (  -- caddr2 u2 caddr1 u1 )
         BEGIN
            DUP
         WHILE ( u1<>0 )
            4DUP INSTR
         WHILE ( no match)
            1 /STRING  ( cut caddr1 u1)
         REPEAT
         2NIP TRUE EXIT
         THEN
         2NIP
         FALSE ; \ 8k SEARCH = 5.25 seconds

\ test string in LOW RAM
HEX S" TEST STRING"  3FF0 PLACE
