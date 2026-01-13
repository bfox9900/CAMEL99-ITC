\ ORB.FTH  OR bits into a byte   Brian Fox 2026
HEX
CODE ORB ( n addr -- )
C036 , \ *SP+ R0 MOV,
06C0 , \      R0 SWPB,
F500 , \ R0 *TOS SOCB,
C136 , \     TOS POP,
NEXT,
ENDCODE

DECIMAL
