\ KISS COMMANDS (Albert Nijhof) -- 1 april 2003

NEEDS VOCABULARY FROM DSK1.WORDLISTS

ONLY FORTH DEFINITIONS

DECIMAL
VOCABULARY INFIX

ONLY FORTH ALSO INFIX DEFINITIONS
\ P-stack with relative stackpointer in cell # 0
12 CELLS CONSTANT PQ
CREATE P   0 ,   PQ ALLOT

: CELL-  2- ;
: FRESH   0 P ! ;          \ Reset p-stack
: ?P ( p# -- )           \ Check overflow and underflow
  PQ 0 WITHIN
  IF   FRESH TRUE ABORT" Syntax Error "
  THEN ;

: P> ( -- x ) P @ DUP CELL- DUP ?P P ! P + @ ;
: >P ( x -- ) P @ DUP ?P CELL+ DUP P ! P + ! ;

\ INFIX ALSO FORTH DEFINITIONS
: ) ( -- ) P> 2@                ( xt imm? )
  0< STATE @ AND
  IF   COMPILE, EXIT
  THEN EXECUTE ; IMMEDIATE

: KISS ( ccc -- )
  >IN @ >R ' DROP                \ Does this word exist?
  R@ >IN ! BL WORD FIND R> >IN ! \ xt imm?
  CREATE  HERE 2 CELLS ALLOT 2! IMMEDIATE
  DOES>   >P
  BL WORD COUNT EVALUATE
  POSTPONE ) ;

: DUMMY ; IMMEDIATE

: (      ['] DUMMY >BODY >P ; IMMEDIATE

PREVIOUS
\ ----- End of code -----

\ Defining KISS-commands
KISS +      KISS -       KISS *       KISS /
