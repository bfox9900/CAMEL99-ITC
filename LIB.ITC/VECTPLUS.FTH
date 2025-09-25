\ VECTPLUS.FTH

\ Vector addition of current position with offset
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;
HEX
CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE
