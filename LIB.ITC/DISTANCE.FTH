\ DISTANCE.FTH  compute distance between 2 coordidates  Mar 14 2022 Brian Fox
\ Max range is 255 pixels with "out of range" flag.

INCLUDE DSK1.LOWTOOLS

MARKER NEW

HERE
\ machine code is same size as Forth
HEX \ : U/  ( u1 u2 -- u3 )  0 SWAP UM/MOD NIP ;
CODE U/   ( u1 u2 -- u3 )     \ unsigned division
    C004 ,  \   TOS R0 MOV,   \ divisor->R0
    04C4 ,  \      TOS CLR,   \ high word in TOS = 0
    C176 ,  \ *SP+  R5 MOV,   \ MOVE low word to r5
    3D00 ,  \   R0 TOS DIV,
    NEXT,
ENDCODE

\ SQRT by Albert Van der Horst, comp.lang.forth, Aug 29, 2017
\ Newtonian Interpolation. ~10X faster than linear method
\ Returns FLOOR of the square root of n.
DECIMAL
: SQRT ( n -- n')
  DUP
  IF >R
     1  \ 1st seed
     R@ OVER U/ OVER + 2/ NIP ( DUP . ) \ debug viewing
     BEGIN
        R@ OVER U/ OVER + 2/  ( DUP .)
        2DUP >
     WHILE
        NIP
     REPEAT
     DROP
     R> DROP
  THEN ;
DECIMAL

\ : DXY  ( x y x y -- dx dy) ROT -  -ROT - ;
\ Code is same size as Forth, faster
HEX
CODE DXY   ( x y x2 y2 -- dx dy)
  *SP+  R1 MOV, \ x2
  *SP+ TOS SUB, \ y2=y2-y
       TOS ABS,
   R1  *SP SUB, \ x=x-x2
       *SP ABS,
        NEXT,
ENDCODE

DECIMAL
: SUMSQR   ( n1 n2 -- d)   DUP * SWAP DUP *  0 ROT 0 D+ ;
: DISTANCE ( x y x y -- n) DXY SUMSQR IF DROP TRUE EXIT   THEN SQRT ;
HERE SWAP - .  ( 170 bytes)
