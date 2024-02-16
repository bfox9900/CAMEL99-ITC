\ fig-forth to ANS Forth translation harness
: VARIABLE     CREATE  , ;
: CREATE2   CREATE ;
: CLS   PAGE ;
: ENDIF   POSTPONE THEN ; IMMEDIATE

DECIMAL

\ ===[ ORIGINAL FIG-FORTH CODE ]=== runtime CAMEL99 V2.62 = 2:13 !!!
\ Lee Stewart's version ran un-optimized in 1/2 that time.
-1 CONSTANT TRUE
0 CONSTANT FALSE

180 CONSTANT SIZE
0 VARIABLE V1
0 VARIABLE V2
0 VARIABLE POWER
CREATE2 A1 SIZE CELLS ALLOT
0 VARIABLE LENGTH

: A1*7->A1 ( -- )
 0 V1 !
 0 V2 !
 SIZE 0 DO
   A1 V1 @ CELLS + @ DUP
   0= V1 @ LENGTH @ > AND V2 @ 0= AND IF
     DROP LEAVE
   ELSE
     7 * V2 @ + DUP
     10 MOD A1 V1 @ CELLS + !
     10 / V2 !
     V1 @ 1+ V1 !
   ENDIF
 LOOP
 V1 @ LENGTH ! ;

: TYPE-A1 ( -- )
 0 V1 !
 FALSE V2 !
 -1 LENGTH @ 1- DO
   A1 I CELLS + @ 48 + DUP
   48 = 0= IF TRUE V2 ! ENDIF
   V2 @ IF
     PAD V1 @ 1+ + C!
     V1 @ 1+ V1 !
   ELSE
     DROP
   ENDIF
 -1 +LOOP
 V1 @ PAD C!
 CR PAD COUNT TYPE CR ;

: TEST-A1 ( -- f )
 0 V1 !
 FALSE V2 !
 LENGTH @ 0 DO
   A1 I CELLS + @
   7 = 0= IF
     0 V1 !
   ELSE
     V1 @ 1+ V1 !
   ENDIF
   V1 @ 5 > IF
     TRUE V2 !
   ENDIF
 LOOP
 V2 @ ;

: SEVENS 
 CLS
 A1 SIZE CELLS 0 FILL
 7 A1 !
 2 POWER !
 BEGIN
   A1*7->A1
   CR ." SEVEN TO THE POWER OF " POWER @ . ." IS"
   POWER @ 1+ POWER !
   TYPE-A1
 TEST-A1 UNTIL ;
DECIMAL
