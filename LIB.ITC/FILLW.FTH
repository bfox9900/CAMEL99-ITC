\ FILLW.FTH  fill mem with cell wide data  Feb 2023 Brian Fox
 
HEX
CODE FILLW
  C036 , C236 , CE04 , 0640 , 18FD , 
  C136 , NEXT,
ENDCODE
 
DECIMAL
 
\ NEEDS MOV,  FROM DSK1.ASM9900
 
\ CODE FILLW ( adr len u --)
\   *SP+ R0 MOV,
\   *SP+ W MOV,
\    BEGIN,
\      TOS *W+ MOV,  \ 2 chars are in TOS register
\      R0 DECT,      \ decr. count by two
\    NC UNTIL,       \ loop until r0=0
\    TOS POP,
\    NEXT,
\ ENDCODE
 
