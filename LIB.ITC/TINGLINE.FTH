\ line drawing by Dr. C. H. Ting  R.I.P.
\ I tried to make it faster with every trick I could think of.
\ It is not as good as Bresenham but fun example of recursion

DECIMAL
\ : DXY  ( x y x2 y2 -- dY dX) ROT - ABS -ROT - ABS ;

\ name items on the stack for clairity
\ Using index addressing to avoid 4DUP
: X1   3 (SP) ;
: Y1   2 (SP) ;
: X2   1 (SP) ;
: Y2   *SP  ;

CODE DXY? ( x y x2 y2 --x y x2 y2 ?)
      TOS PUSH,
   Y2 TOS MOV,
    Y1 Y2 SUB,
       Y2 ABS,

    X1 X2 SUB,
       X2 ABS,
\ MAX
    *SP TOS CMP,
    LO IF, TOS POP,
    ELSE,   SP INCT,
    ENDIF,
\ 2 <
    TOS 2 CI,
    LO IF, TOS SETO,
    ELSE,  TOS CLR,
    ENDIF,
    NEXT,
ENDCODE

CODE MIDXY ( x1 y1 x2 y2 -- x1 y1 x2 y2 x' y')
\ do x mid point
    TOS PUSH,
    X1 TOS MOV,
    X2 TOS ADD,
       TOS INC,
       TOS 1 SRA,
\ do x mid point
    TOS PUSH,
    Y1 TOS MOV,
    Y2 TOS ADD,
       TOS INC,
       TOS 1 SRA,
    NEXT,
ENDCODE

DECIMAL
: 2ROT ( d1 d2 d3 -- d2 d3 d1)
  S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE

HEX
\ manual tail call optimizer. Improves LINE by 1.5%
: PREVXT ( -- XT)  HERE 1 CELLS - @ ;

\ -; does not end with EXIT because it is branching directly to another
\ list of tokens. That other list will end in EXIT or NEXT.
: -;  ( -- ) \ programmer controlled
      PREVXT >BODY              \ get previous XT, compute PFA
     -1 CELLS ALLOT             \ erase the previous XT
      POSTPONE BRANCH HERE - ,  \ compile BRANCH to the PFA
      POSTPONE [                \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE

: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    DXY? IF  2DROP PLOT  EXIT THEN
    MIDXY 2DUP 2ROT RECURSE RECURSE -;

0 VALUE x
0 VALUE y

: MOVETO  ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !!
: HLINE ( x y len ) -ROT MOVETO  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) -ROT MOVETO  0 DO  x  y I +  PLOT  LOOP ;

HERE SWAP - DECIMAL .
