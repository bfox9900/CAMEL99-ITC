\ * autobaud for 9902
\ * Software Development, Texas Instruments 1981
HEX
CREATE BAUDTB
           0007 , 001A ,
           000E , 0034 ,
           001D , 0068 ,
           003B , 00D0 ,
           0075 , 01A0 ,
           00EA , 0340 ,
           0246 , 04D0 ,
           7FFF , 0638 ,

CODE AUTOBAUD ( tty_cru -- n )
           TOS   R12  MOV,   \ set CRU base
           31         SBO,   \ reset 9902
           R1  B300   LI,    \ 8 bits odd parity 1 stop
           R1  8      LDCR,  \ init control register
           13         SBZ,
           R3         CLR,
\ * wait for start bit
           BEGIN,
             15  TB,
           NE UNTIL,
\ * wait until rin goes back to space condition
           BEGIN,
             R3 INC,
             15 TB,
           EQ UNTIL,
\ * find the baud rate
\           R4 BAUDTB 2- LI,
\           BEGIN,
\             R4 INCT,
\             R3 R4 *+ CMP,
\           LO UNTIL,
\ * baud rate found - move value to TOS
\          R4 ** TOS MOV,

           R3 TOS MOV,   \ for test just put to TOS

           BEGIN,        \ * read a char and throw it away
             21 TB,      \ wait for last character
           EQ UNTIL,
           18 SBZ,       \ reset rcv buffer register
           NEXT,
           ENDCODE
HEX
: TESTBAUD    BEGIN  1340 AUTOBAUD .  ?TERMINAL UNTIL ;
