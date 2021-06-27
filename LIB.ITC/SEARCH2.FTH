 \ search.fth  for Camel99 Forth     Brian Fox  26Jun2020
 ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ Search the string specified by c-addr1 u1 for the string specified by c-addr2
\ u2. If flag is true, a match was found at c-addr3 with u3 characters remaining
\ If flag is false there was no match and c-addr3 is c-addr1 and u3 is u1.
\

NEEDS DUMP   FROM DSK1.TOOLS  \ debug only
NEEDS 3RD    FROM DSK1.3RD4TH  \ CODE like OVER but for 3rd and 4th items
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS S=     FROM DSK1.COMPARE

MARKER /SEARCH

\ S= is CAMEL Forth primitive
: 2OVER    ( d d2 -- d d2 d) S" 4TH 4TH" EVALUATE ; IMMEDIATE
: 4DUP     (  d d2  --  d d2 d d2) 2OVER 2OVER ;
: 2NIP     2SWAP 2DROP ;

: SEARCH  ( caddr1 u1 caddr2 u2 -- caddr3 u3 flag)
          2SWAP (  -- caddr2 u2 caddr1 u1 )
          BEGIN
             DUP ( test u1 )
          WHILE
             4DUP COMPARE
             0= IF 2NIP TRUE EXIT THEN  ( jump to ';')
             1 /STRING             ( cut caddr1 u1)
          REPEAT 
          2SWAP 2DROP
          FALSE
;

: A$
  S" NOW IS THE TIME FOR ALL GOOD MEN TO COME TO THE AID OF THEIR COUNTRY."
;

: MEN  S" MEN" ;
: AID  S" AID" ;
: C$   S" COUNTRY" ;
