\ MOVEW   replaces MOVE16.     Jul 2022 Brian Fox
\ **DEPRECATED**  as of Oct 2025, MOVE is part of the kernel
\ and it is 16 bit wide move with n=0 protection
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
