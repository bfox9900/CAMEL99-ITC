\ https://www.theultimatebenchmark.org/#sec-13-5
\ demonstrates 3 levels optimizing 

NEEDS ELAPSE FROM DSK1.ELAPSE

\ ----------------------------------------------
\ The 20,000 iterations took much too long on TI-99 
\ These are reduced to 1000 iterations 

DECIMAL
: BENCHME ( XT N -- ) 
  DUP >R 
  0 DO DUP EXECUTE LOOP 
  CR R> . ." ITERATIONS." CR \
;

\ bigger data stack in Low RAM was done for recursion 
HEX  
: NEWSTACK  3FFE ['] SP0 >BODY !  ABORT ;

NEWSTACK 

DECIMAL
HERE
DECIMAL
: FIB
  0 1 ROT 0 DO
    OVER + SWAP
  LOOP DROP ;

: FIB-BENCH 
  1000 0 DO
    I FIB DROP
  LOOP ;

: FIB-CHEAT 
  0 1 ROT 0 DO
      BOUNDS  \ bounds is a code word for OVER + SWAP 
  LOOP DROP ;

: FIB-BENCH-CHEAT
  1000 0 DO
    I FIB-CHEAT DROP
  LOOP ;
;


HERE SWAP -  . ( 70 BYTES)
\   ELAPSE FIB-BENCH  1:48.0
\   ELAPSE FIB-BENCH-CHEAT  1:48.0

INCLUDE DSK1.JIT 

JIT: FIB2
  0 1 ROT 0 
  DO
    OVER + SWAP 
  LOOP
  DROP 
;JIT

: FIB-JIT
  1000 0 DO
    I FIB2 DROP
  LOOP 
;
\   ELAPSE FIB-JIT 0:42.55

\ inline the function so everthing is compiled as native code 
JIT: FIB3-JIT
  1000 0 DO
    I 0 1 ROT 0 
    DO
      OVER + SWAP 
    LOOP
    DROP 
    DROP 
  LOOP 
;JIT
\   ELAPSE FIB-JIT 0:42.36  
\ *ALMOST NO IMPROVEMENT WITH OUTER LOOP OPTIMIZED 
