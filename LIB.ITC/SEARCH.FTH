CR .( search.fth  Camel99 Forth  Brian Fox  24May2024)

( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ Search the string specified by c-addr1 u1 for the string specified
\ by c-addr2 u2. If flag is true, a match was found at c-addr3 with 
\ u3 characters remaining If flag is false there was no match and
\ c-addr3 is c-addr1 and u3 is u1.

NEEDS 4TH     FROM  DSK1.3RD4TH 
NEEDS COMPARE FROM DSK1.COMPARE

HEX
CODE 2OVER   ( a b c d --  a b c d a b)       
      0646 , C584 , \ TOS PUSH,  ( --  a b c d x )     \ 28 
      0646 ,        \ SP DECT,   ( --  a b c d x y )   \ 10 
      C126 , 0006 , \ 6 (SP) TOS MOV,                  \ 22
      C5A6 , 0008 , \ 8 (SP) *SP MOV,                  \ 26  
      NEXT,                                         \ =  76 
ENDCODE         

: 2NIP     2SWAP 2DROP ;

DECIMAL 
: SEARCH  ( caddr1 u1 caddr2 u2 -- caddr3 u3 flag)
   2OVER                \ retain a copy of 1st string 
   BEGIN 
     DUP
   WHILE 
     2OVER 4TH OVER COMPARE 
   WHILE 
     1 /STRING  
   REPEAT
   2NIP 2NIP TRUE EXIT   \ string found 
   THEN
   2DROP 2DROP FALSE ;   \ string not found 

\ test string in LOW RAM
 
: MEN$  S" MEN" ;
: AID$  S" AID" ;
: C$   S" COUNTRY" ;
: F$   S" NO MATCH" ;


: A$ 
 S" NOW IS THE TIME FOR ALL GOOD MEN TO COME TO THE AID OF THEIR COUNTRY." ;
 

\ HEX 2000 2000 CHAR # FILL 
\  2000 2000 AID  ELAPSE SEARCH 

