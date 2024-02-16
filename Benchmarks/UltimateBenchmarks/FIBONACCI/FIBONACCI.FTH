\ https://www.theultimatebenchmark.org/#sec-13-5

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
: FIB2
  0 1 ROT 0 DO
    OVER + SWAP
  LOOP DROP ;

: FIB2-BENCH 
  1000 0 DO
    I FIB2 DROP
  LOOP ;

HERE SWAP -  . ( 70 BYTES)

\   ELAPSE ' FIB2-BENCH 1 BENCHME  \ 1:48.0


INCLUDE DSK1.JIT 

JIT: FIB2
  0 1 ROT 0 
  DO
    \ OVER + SWAP  ( much slower)
    BOUNDS 
  LOOP
  DROP 
;JIT

: FIB2-JIT
  1000 0 DO
    I FIB2 DROP
  LOOP 
;

\  
\ 1x = 0:43  
\  ELAPSE  ' FIB2-JIT 10 BENCHME 
\ with BOUNDS 10X = 3:40.8
