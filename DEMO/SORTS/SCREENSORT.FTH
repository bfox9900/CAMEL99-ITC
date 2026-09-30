

NEEDS DUMP    FROM DSK1.TOOLS
NEEDS CHARSET FROM DSK1.CHARSET
NEEDS RND     FROM DSK1.RANDOM
NEEDS VALUE   FROM DSK1.VALUES
NEEDS HCHAR   FROM DSK1.GRAFIX
NEEDS HZ      FROM DSK1.SOUND

HEX
CREATE BLK 0018 , 3C7E , 7E3C , 1800 ,

DECIMAL
: ,8+  ( n --)   DUP C,  8 +  ;

\ table of high characters in each color set starting at ASCII 128
CREATE BLKS
    128
    ,8+ ,8+ ,8+ ,8+
    ,8+ ,8+ ,8+ ,8+
    ,8+ ,8+ ,8+ ,8+
    ,8+ ,8+ ,8+ ,8+
    DROP

: VC! ( C vaddr --) DUP 200 + GEN1  HZ  -6 DB VC! ; \ added sound
: V!  ( N Vaddr --) DUP 200 + GEN1  HZ  -6 DB  V! ;

: ]BLK ( n -- char)  BLKS + C@ ;

: DEF-BLKS  16 0 DO  BLK  I ]BLK CHARDEF  LOOP ;

: SET-COLORS  16 0 DO   I ]BLK SET#  I 2+  2 COLOR   LOOP  ;

: FILLSCREEN
    C/SCR @ 0
    DO
       15 RND ]BLK I VC!
    LOOP
    MUTE
;

DECIMAL
: 1.35/  ( n -- n' )  100 135 */ ;


: XCHG  ( addr1 addr2 -- )
    2DUP VC@ SWAP VC@  ROT VC! SWAP VC! ;

VARIABLE SORTED
0 VALUE GAP

DECIMAL
: COMBSORTBYTE ( vaddr n -- )
    DUP>R  TO GAP                   \ save n on Rstack and in GAP
    BEGIN
      GAP 1.35/ TO GAP              \ re-compute the gap
      SORTED ON
      R@ ( -- n) GAP -  0           \ n-gap is loop limit
      DO ( -- addr )
         DUP I +  DUP GAP +  ( -- addr1 addr2 )
         OVER VC@ OVER VC@ >             \ compare the contents of cells
         IF
            XCHG                     \ Exchange the data in the cells
            SORTED OFF               \ flag we are not sorted
         ELSE
           2DROP
         THEN
      LOOP
      MUTE
      SORTED @ TRUE =  GAP 0= AND          \ test for complete
   UNTIL
   R> 2DROP
;


: COMB
    DEF-BLKS
    SET-COLORS
    FILLSCREEN
    GEN1
    0 C/SCR @  COMBSORTBYTE
    BEGIN KEY? UNTIL
    CLEAR
;


: INSERT ( start end -- start ) \ IN vdp memory
         DUP VC@ >R
         BEGIN
           2DUP <
         WHILE
              R@ OVER 1- VC@ <
         WHILE
              1- DUP VC@ OVER 1+ VC!
         REPEAT
         THEN
         R> SWAP VC! ;

: INSORT ( array len -- )
         1 DO
             DUP I +  INSERT
         LOOP
         DROP ;

: INSERTION
    DEF-BLKS
    SET-COLORS
    FILLSCREEN
    0 C/SCR @ INSORT MUTE
    BEGIN KEY? UNTIL
    CLEAR
;

\ This is the original rosseta code but it cheats by reducing the inner loop
\ But it is faster than above.
: BUBBLE2 ( ADDR CNT -- )
  DUP 1
  DO
    2DUP I -  BOUNDS ( endaddr startaddr)
    DO
      I V@ SPLIT <  \ read 2 bytes, split and compare
      IF
         I V@  \ fetch 2 VPD bytes
         ><    \ swap bytes
         I V!  \ store 2 bytes back to VDP ram
      THEN

    LOOP
  LOOP
  MUTE
  2DROP ;


: BUBBLER
    DEF-BLKS
    SET-COLORS
    FILLSCREEN
    0 C/SCR @ BUBBLE2
    BEGIN KEY? UNTIL
    CLEAR
;
