\ vpdextras needed for grafix library

CODE >VPOS  ( col row -- vaddr)
    02A1 , C0C4 , 38E1 , 002E , A136 ,
    NEXT,
ENDCODE

CODE VCLIP ( lim char addr -- lim char addr)
    8126 , 0002 , 1402 , 6126 , 0002 ,
    NEXT,
ENDCODE


\ CODE >VPOS ( col row -- vaddr) \ compute video address
\             R1         STWP,
\             TOS     R3  MOV,   \ this move to make best use of MPY
\             2E R1 () R3  MPY,   \ multply by chars/line. result goes to R4 ie: TOS
\            *SP+     TOS ADD,   \ add col value to tos
\             NEXT,
\             ENDCODE

\ make VCHAR go faster. clip vertical address value in VCHAR
\ CODE VCLIP  ( lim char addr -- lim char addr)
\             2 (SP) TOS CMP,
\             LO IF,
\                2 (SP) TOS SUB,
\             ENDIF,
\             NEXT,
\             ENDCODE
