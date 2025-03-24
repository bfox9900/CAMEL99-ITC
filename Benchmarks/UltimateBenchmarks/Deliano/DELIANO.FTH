\ 12.16 Deliano
\ Ein Benchmark für 8bit Mikrocontroller, angeregt in Vierte Dimension 03/93
\ von Rafael Deliano
\ A-ONE (Apple 1 Clone) mit 65C02	TaliForth 2 (STC)   Deliano 0:29.0  1x
\ Z79Forth (Hitachi HD63C09 3 Mhz)	                  Deliano 7:53.0  50x 
\                                                           = 0:09.46 1x

\ TI-99                         Camel99 Forth (ITC)   Deliano 0:26.4  1x
\                               Turbo Forth (ITC)             0:27.0  1x 
\ with Just in time optimizer                                 FAILED        
\                                     
\                                   

INCLUDE DSK1.ELAPSE 

HEX
5 CONSTANT FIVE
0 VARIABLE BVAR

: BENCH
  100 0 DO
    1 BEGIN
        DUP SWAP
        DUP ROT DROP
        1 AND IF
          FIVE +
        ELSE
          1-
        THEN
        BVAR ! BVAR @
        DUP 0100 AND
     UNTIL DROP
   LOOP ;

INCLUDE DSK1.JIT 
DECIMAL 100 CONSTANT #100 

\ does above benchmark 100 times 
JIT: BENCH2
  100 0 DO
    1 BEGIN
        DUP SWAP
        DUP ROT DROP
        1 AND IF
          FIVE +
        ELSE
          1-
        THEN
        BVAR ! BVAR @
        DUP 0100 AND
     UNTIL DROP
   LOOP 
;JIT
;

: TEST #100 0 DO  BENCH2  LOOP ;

