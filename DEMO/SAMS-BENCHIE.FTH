\ DEMO: Compile code in CPU RAM & SAMS memory and compare speed May 2022 BFox

NEEDS FAR:  FROM DSK1.SAMSCODE

INCLUDE DSK1.VALUES
INCLUDE DSK1.ELAPSE


HEX
  5 CONSTANT FIVE
100 CONSTANT MASK
  0 VALUE BVAR

: INNERBENCH
    BEGIN
      DUP SWAP DUP ROT DROP 1 AND
      IF FIVE +
      ELSE 1-
      THEN TO BVAR
      BVAR DUP MASK AND
    UNTIL ;

: BENCHIE
   CR ." RAM memory"
   MASK 0 DO   1 INNERBENCH  DROP   LOOP ;

\ __________________________________________

F8 CODEPAGE  \ code on page F8

FAR: INNERBENCH2
    BEGIN
      DUP SWAP DUP ROT DROP 1 AND
      IF FIVE +
      ELSE 1-
      THEN TO BVAR
      BVAR DUP MASK AND
    UNTIL
;FAR

F9 CODEPAGE \ Force a call to another SAMS bank
FAR: BENCHIE2
   CR ." CODE in SAMS card with PAGING"
   MASK 0 DO  1 INNERBENCH2  DROP  LOOP ;FAR

PAGE
CR CR .( Compare CODE SPEED in RAM vs SAMS)
CR
CR .( BENCHIE is a program in CPU RAM.)
CR
CR .( BENCHIE2 is a program split onto two)
CR .( SAMS pages using FAR:  ;FAR.)
CR
CR .( To run the comparison type:)
CR .( ELAPSE BENCHIE )
CR .( ELAPSE BENCHIE2)
CR .( Both run in about 25 seconds)
CR .( showing that FAR: definitions are fast.)
CR
