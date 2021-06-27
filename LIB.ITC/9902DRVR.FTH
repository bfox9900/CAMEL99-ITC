\ xfcc99 cross-compiler tms9902 rs232/1 DIRECT cru DRIVER 9Feb2019 bjf
\ CODE words are used to save kernel space by not needing the CRU library

\ These routines push the value in R12 onto the return stack
\ then restore it when returning to Forth.
\ This supports accessing other I/O devices while using the serial port.

\ Jul 30/2019  added CTS control in CKEY? for hardware handshaking
NEEDS MOV,   FROM DSK1.LOWTOOLS

HERE
\ ****  9902 control bits  ****
DECIMAL
       13 CONSTANT LDIR      \ "load interval register"
\ for reference...
\      16 CONSTANT RTSON    \ rCONSTANTest to send
\      18 CONSTANT RIENB    \ rcv interrupt enable
\      21 CONSTANT RXRL     \ receive register loaded bit
\      22 CONSTANT TXRE     \ transmit register empty bit
\      27 CONSTANT -DSR     \ NOT data set ready
\      28 CONSTANT -CTS     \ NOT clear to send
       31 CONSTANT RESET          \ 9902 reset bit

HEX
\ these variables are the data needed for 1 comm UART connection
VARIABLE CARD   \ default to >1300
VARIABLE UART   \ /tty1 = >40  /tty2 = ?80
VARIABLE BPS    \ 0034 BPS T!   \ 9600 baud
VARIABLE PROTO  \ 9300 PROTO T! = 8 bits, no parity, 1 stops

\ *FUTURE*  comm port data structure
\                 card    uart   bps    proto
\ CREATE RS232/1  1E00  , 0040 , 0034 , 9300 ,
\ CREATE RS232/2  1E00  , 0080 , 0034 , 9300 ,

\ 9900 sub-routines. *NOT* Forth words.
CREATE CARD-ON
         CARD @@ R12 MOV,   \ select the card
         7 SBO,             \ turn LED on
         RT,
CREATE CARD-OFF
         CARD @@ R12 MOV,   \ select the card
         7 SBZ,             \ turn LED off
         RT,

\ *variables CARD, UART, BPS and PROTO must be set correctly before using OPEN-TTY*
CODE OPEN-TTY  ( -- ) \ Usage: /TTY1 OPEN-TTY
         R12 RPUSH,
         CARD-ON @@ BL,     \ load the card address
         UART @@ R12 ADD,   \ add 9902 port address
         RESET SBO,         \ reset UART
         PROTO @@ 8 LDCR,   \ set protocol
         LDIR SBZ,          \ disable 9902 timer
         BPS @@ 0C LDCR,    \ set baud rate
         CARD-OFF @@ BL,
         R12 RPOP,          \ restore R12
         NEXT,
         ENDCODE

 DECIMAL
\ this word turns on the LED when sending
CODE CEMIT ( c -- )  \ 'com-emit"
         R12 RPUSH,
         CARD-ON @@ BL,
         UART @@ R12 ADD,   \ add UART offset
\     *** DSR handshake  ***
         BEGIN, 27 TB, EQ UNTIL,   \ wait for -DSR=0

\  *** handshake hardware ***
         16 SBO,        \ set RTS
         BEGIN, 28 TB, EQ UNTIL,  \ wait for CTS line
\  *****[SEND BYTE ]*********
         BEGIN, 22 TB, EQ UNTIL,   \ wait XBRE empty
         TOS SWPB,      \ put byte on the other side
         TOS 8 LDCR,    \ send 8 bits
         16 SBZ,        \ reset RTS

\ housekeeping on USER VARIABLES...
         R1      STWP,  \ get current user area address
         48 R1 () INC,   \ inc  OUT user variable **DECIMAL OFFSET VALUES**
         CARD-OFF @@ BL,
         R12 RPOP,
         TOS POP,
         NEXT,
         ENDCODE

DECIMAL
CODE CKEY? ( -- n )          \  "com-key"
         0 LIMI,
         R12 RPUSH,           \ save R12 on return stack
         CARD @@ R12 MOV,     \ set base address of CARD
         TOS PUSH,            \ give us a new TOS register (R4)
         TOS CLR,             \ erase it
         5 SBZ,               \ CARD CTS line LOW. You are clear to send
         UART @@ R12 ADD,     \ add UART, >1300+40 = CRU address
         21 TB,               \ test if char ready
         EQ IF,
             TOS 8 STCR,      \ read the char
             18 SBZ,          \ reset 9902 rcv buffer
             TOS SWPB,        \ shift char to other byte
         ENDIF,
\  *** handshake hardware off ***
         CARD @@ R12 MOV,     \ select card
         5 SBO,               \ CTS line HIGH. I am busy!
\  ******************************
         R12 RPOP,            \ restore old R12
         2 LIMI,
         NEXT,
         ENDCODE

HEX
\ simplified 9902 setup commands
\ Usage RS232/1 /TTY1 BA=9600 8,N,1 OPEN-TTY
: RS232/1  ( -- ) 1300  CARD ! ;
: /TTY1    ( -- ) 040   UART ! ;
: /TTY2    ( -- ) 080   UART ! ;
: BA=9600  ( -- ) 0034  BPS ! ;
: BA=19200 ( -- ) 001A  BPS ! ;
: BA=38400 ( -- ) 000D  BPS ! ;
: 8,N,1    ( -- ) 9300  PROTO ! ;

HERE SWAP - DECIMAL .  ( 448 bytes)

REMOVE-TOOLS
