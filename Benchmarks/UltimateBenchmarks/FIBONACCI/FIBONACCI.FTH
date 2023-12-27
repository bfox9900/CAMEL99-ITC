
NEEDS ELAPSE FROM DSK1.ELAPSE

\ ----------------------------------------------

DECIMAL
: BENCHME ( XT N -- ) 
  DUP >R 
  0 DO DUP EXECUTE LOOP 
  CR R> . ." ITERATIONS." CR \
;

HERE
: FIB2
  0 1 ROT 0
  DO
   OVER + SWAP 
  LOOP
  DROP ;

: FIB2-BENCH 1000 0 DO
    20 0 DO I FIB2 DROP LOOP
  LOOP ;

HERE SWAP -  . ( 70 BYTES)

' FIB2-BENCH ELAPSE BENCHME 

\ C64	DurexForth 1.6.1 (STC) 1:57.00
\ Camel v2.69          (ITC) 1:48.00
\ Camel V2.68          (DTC) 1:24.41
\ W/BOUNDS             (ITC) 0:58.25

\ ----------------------------------------------
\ Other versions
HEX  : NEWSTACK  3FFE ['] SP0 >BODY !  ABORT ;

DECIMAL
: FIB1 ( N1 -- N2 )
    DUP 3 < IF DROP 1 EXIT THEN
    DUP  1- RECURSE
    SWAP 2- RECURSE  + ;

: FIB1-BENCH
  20 0 DO
    I FIB1 DROP
  LOOP ;
\ Camel V2.69  took so long I stoppped it :)

NEEDS INLINE[ FROM DSK1.INLINE

DECIMAL
: FIB3
  INLINE[ 0 1 ROT 0 ]
  DO
   INLINE[ OVER + SWAP ]
  LOOP
  DROP ;

: FIB3-BENCH 1000 0 DO
    I FIB3 DROP
  LOOP ;
\ with inline 1:18.65

FIND FIB2-BENCH 10 BENCHME
