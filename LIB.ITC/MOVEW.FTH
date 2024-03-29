\ MOVEW   replaces MOVE16.     Jul 2022 Brian Fox

HEX
CODE MOVEW  ( src dst n -- ) \ n= no. of bytes to move
   C036 , \ *SP+ R0 MOV,
   C076 , \ *SP+ R1 MOV,
          \  BEGIN,
   CC31 , \     R1 *+ R0 *+ MOV,
   0644 , \     TOS DECT,
   16FD , \  EQ UNTIL,
   C136 , \  TOS POP,
   NEXT,
ENDCODE


