\ QUICKSORT From Rossetta Code with tail call optimization

\ USE SORTTESTSUITE
NEEDS JIT:      FROM DSK1.JITIII
NEEDS .S        FROM DSK1.TOOLS
NEEDS RND       FROM DSK1.RANDOM
NEEDS MALLOC    FROM DSK1.MALLOC
NEEDS ELAPSE    FROM DSK1.ELAPSE

DECIMAL
\ macros for words used by Quicksort author
: -CELL   S" -2" EVALUATE ; IMMEDIATE
: CELL+   POSTPONE 2+ ; IMMEDIATE
: CELL-   POSTPONE 2- ; IMMEDIATE

: <=      S" 1+ <" EVALUATE ;  IMMEDIATE

\ returns the value in the mid point of the array
JIT: PIVOT ( l r -- PIVOT )
  OVER - 2/ -CELL AND +  @
;JIT

\ tried a few of these...
\ : EXCH ( addr1 addr2 -- ) DUP @ >R OVER @ SWAP ! R> SWAP ! ;
\ : EXCH ( addr1 addr2 -- ) OVER @ OVER @ SWAP ROT ! SWAP ! ;
\ : EXCH   ( addr1 addr2 -- )
\  S" 2DUP @ SWAP @  ROT ! SWAP !" EVALUATE ; IMMEDIATE

JIT: EXCH
   2DUP @ SWAP @  ROT ! SWAP !
;JIT


: PARTITION ( l r -- l r r2 l2 )
  2DUP PIVOT >R ( r: pivot )
  2DUP
  BEGIN
    SWAP BEGIN  DUP @  R@  < WHILE CELL+ REPEAT
    SWAP BEGIN  R@ OVER @  < WHILE CELL- REPEAT
    2DUP <= IF 2DUP EXCH  >R CELL+ R> CELL-  THEN
    2DUP >
  UNTIL
  R> DROP
;

JIT: 2DUP<
  2DUP <
;JIT

: QSORT ( l r -- )
  PARTITION  SWAP ROT
  2DUP< IF RECURSE ELSE 2DROP THEN
  2DUP< IF RECURSE ELSE 2DROP THEN ;

: QUICKSORT ( array len -- )
  DUP 2 < IF 2DROP EXIT THEN  1- CELLS OVER + QSORT ;

: RUN   Q[] SIZE QUICKSORT ;