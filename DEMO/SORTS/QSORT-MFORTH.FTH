\ QUICKSORT From Rossetta Code with tail call optimization

\ USE SORTTESTSUITE
NEEDS .S        FROM DSK1.TOOLS
NEEDS MOV,      FROM DSK1.ASM9900
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
: PIVOT ( l r -- PIVOT )  OVER - 2/ -CELL AND +  @ ;

CODE PIVOT2
     *SP TOS SUB,
     TOS 1 SRA,
     TOS FFFE ANDI,
     *SP+ TOS ADD,
     *TOS TOS MOV,
     NEXT,
ENDCODE

CODE NOS++   *SP INCT,  NEXT, ENDCODE

\ : EXCH    2DUP @ SWAP @  ROT ! SWAP ! ;

CODE EXCH2 ( a1 a2 -- )
    *SP+    R0 MOV,   \ A1 -> R0
    R0 **   R1 MOV,   \ a1 @  -> temp
    *TOS  R0 ** MOV,  \ a2 @  a1 !
    R1    *TOS MOV,   \ temp -> a2
    TOS POP,
    NEXT,
ENDCODE

CODE DUP@  TOS PUSH,  *TOS TOS MOV,  NEXT, ENDCODE

CODE OVER@  ( a n -- a n n2)
    *SP  R0 MOV,
    TOS PUSH,
    R0 ** TOS MOV,
    NEXT,
ENDCODE

CODE RDROP    RP INCT,  NEXT, ENDCODE

: PARTITION ( l r -- l r r2 l2 )
  2DUP PIVOT2 >R ( r: pivot )
  2DUP
  BEGIN
    SWAP BEGIN  DUP@  R@  < WHILE CELL+ REPEAT
    SWAP BEGIN  R@ OVER@  < WHILE CELL- REPEAT
    2DUP <= IF 2DUP EXCH2  NOS++ CELL-  THEN
    2DUP >
  UNTIL
  RDROP
;

: QSORT ( l r -- )
  PARTITION  SWAP ROT
  2DUP < IF RECURSE ELSE 2DROP THEN
  2DUP < IF RECURSE ELSE 2DROP THEN ;

: QUICKSORT ( array len -- )
  DUP 2 < IF 2DROP EXIT THEN  1- CELLS OVER + QSORT ;

: RUN   Q[] SIZE QUICKSORT ;