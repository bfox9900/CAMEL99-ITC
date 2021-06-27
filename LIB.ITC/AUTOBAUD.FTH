\ * autobaud for 9902 for CAMEL99 Forth  May 2020
\ * Software Development, Texas Instruments 1981
NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900

**NOT WORKING***

MARKER REMOVE

HEX
CREATE BAUDTB
           0007 , 001A ,    \ 19200
           000E , 0034 ,    \ 9600
           001D , 0068 ,    \ 4800
           003B , 00D0 ,    \ 2400
           0075 , 01A0 ,    \ 1200
           00EA , 0340 ,    \  600
           0246 , 04D0 ,    \  300
           7FFF , 0638 ,    \  110

DECIMAL
CREATE LEDON
           CARD @@ R12  MOV,   \ set card address
           7 SBO,
           RT,

CREATE LEDOFF
           CARD @@ R12  MOV,   \ set card address
           7 SBZ,
           RT,

DECIMAL
 CODE RIN?  TOS PUSH,
            TOS SETO,
            15 TB, EQ 
            IF, TOS CLR, ENDIF,
            NEXT, 
            ENDCODE

: TEST  BEGIN  RIN? .  ?TERMINAL UNTIL ; 


\ * wait until rin goes back to space condition
CODE WAITRIN ( rin# -- )
           TOS PUSH,
           TOS CLR,
\           LEDON @@ BL,
\           UART @@ R12 ADD, \ select the current UART
\           31          SBO,   \ reset 9902
\ HEX        R1 9300     LI,    \ 8,N,1 is >93
\ DECIMAL    R1  8       LDCR,  \ init control register
\           13          SBZ,   \ no interval register
           BEGIN,
DECIMAL      15  TB, NE       \ Wait RIN=HI
           UNTIL,

\         BEGIN,
\              TOS INC,     \ count
\              15 TB, EQ    \ until RIN=0
\           UNTIL,
\           NEXT,
\           ENDCODE

\ * find the baud rate
CODE FINDBAUD ( rin# -- n)
           W BAUDTB 2- LI,
           BEGIN,
             W INCT,
             TOS *W+ CMP,
           LO UNTIL,
           *W TOS MOV,
           NEXT,
           ENDCODE

\ * baud rate found - set receive and transmit data interval
\ * read a char and throw it away
CODE SETBAUD ( n -- )
           *TOS 12 LDCR,
           BEGIN,   21 TB,  EQ UNTIL,
           18 SBZ,       \ reset rcv buffer register
           LEDOFF @@ BL,
           TOS POP,
           NEXT,
           ENDCODE
HEX

: AUTOBAUD  WAITRIN FINDBAUD SETBAUD ;
