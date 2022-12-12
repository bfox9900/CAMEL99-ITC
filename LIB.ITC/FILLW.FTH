\ FILLW.FTH
INCLUDE DSK1.LOWTOOLS

CODE FILLW ( adr len c --)
    *SP+ R0 MOV,
    *SP+ W MOV,
     R1 STWP,
     9 R1 () TOS MOVB, \ dup c in both bytes of TOS
     BEGIN,
       TOS *W+ MOV,  \ 2 chars are in TOS register
       R0 DECT,      \ decr. count by two
     NC UNTIL,       \ loop until r0=0
     NEXT,
    ENDCODE
