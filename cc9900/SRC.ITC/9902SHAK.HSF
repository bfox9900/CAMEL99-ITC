\ 9902SHAK.HSF rs232/1 DRIVER with H/W handshake         9Feb2019 bjf
\ For: xfc99X.exe cross-compiler
\ CODE words are used to save kernel space by not needing the CRU library

\ These routines push the value in R12 onto the return stack
\ then restore it when returning to Forth.
\ This supports accessing other I/O devices while using the serial port.

\ Jul 30/2019  added CTS control in CKEY? for hardware handshaking
\ - CKEY


\ for reference...
[CC] HEX [TC]
\     1300 CONSTANT RS232/1    \ RS232/1 card address
\     1500 CONSTANT RS232/2    \ RS232/2 card address
\      40 CONSTANT TTY1       \ 40 = uart#1
\      80 CONSTANT TTY2       \ 80 = uart#2

\ 9902 control bits
[CC] DECIMAL
       13 EQU LDIR           \ "load interval register"
\      16 EQU RTSON    \ request to send
\      18 EQU RIENB    \ rcv interrupt enable
\      21 EQU RBRL     \ receive buffer register loaded
\      22 EQU TXRE     \ transmit register empty bit
\      27 EQU -DSR     \ NOT data set ready
\      28 EQU -CTS     \ NOT clear to send
       31 EQU RESET    \ 9902 reset bit

[CC] HEX

TARGET-COMPILING
\ these variables are the data needed for 1 comm UART connection
VARIABLE CARD   \ CRU address of rs232 card. Default to >1300
VARIABLE UART   \ /tty1 = >40  /tty2 = ?80
VARIABLE BPS    \ 0034 BPS T!   \ 9600 baud
VARIABLE PROTO  \ 9300 PROTO T! = 8 bits, no parity, 1 stops


\ 9900 sub-routines. *NOT* Forth words.
l: CARD-ON
         CARD @@ R12 MOV,   \ select the card
         7 SBO,             \ turn LED on
         RT,

l: CARD-OFF
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
         BPS @@ 0C LDCR,    \ set baud rate for XMIT & RCV
         CARD-OFF @@ BL,
         R12 RPOP,          \ restore R12
         NEXT,
         ENDCODE

[CC] DECIMAL [TC]
\ this word turns on the LED when sending
CODE CEMIT ( c -- )  \ 'com-emit"
         R12 RPUSH,
         CARD-ON @@ BL,
         UART @@ R12 ADD,   \ add UART offset
\     *** DSR handshake  ***
         BEGIN, 27 TB, EQ UNTIL,   \ wait for -DSR=0

\  *** handshake hardware ***
         16 SBO,        \ set RTS
\        BEGIN,  28 TB, EQ  UNTIL,  \ wait for CTS line
\  ******************************
         BEGIN,  22 TB, EQ  UNTIL,   \ wait TXRE empty
         TOS SWPB,      \ put byte on the other side
         TOS 8 LDCR,    \ send 8 bits
         16 SBZ,        \ reset RTS

\ housekeeping on USER VARIABLES...
         R1      STWP,  \ get current user area address
         48 (R1) INC,   \ inc  OUT user variable  **DECIMAL OFFSET VALUES**
         52 (R1) INC,   \ inc  VCOL user variable **DECIMAL OFFSET VALUES**
         CARD-OFF @@ BL,
         R12 RPOP,
         TOS POP,
         NEXT,
         ENDCODE

[CC] DECIMAL [TC]
CODE KEY? ( -- n )            \  "com-key"
         0 LIMI,
         R12 RPUSH,           \ save R12 on return stack  *Needed?*
         CARD @@ R12 MOV,     \ set base address of CARD
         TOS PUSH,            \ give us a new TOS register (R4)
         TOS CLR,             \ erase it
\  *** handshake hardware ON ***
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
         R12 RPOP,            \ restore old R12  *Needed?*
         2 LIMI,
         NEXT,
         ENDCODE

\ hi level interface 
: EMIT   ( c -- ) PAUSE CEMIT ; 

[CC] HEX 
TARGET-COMPILING 
: CR   ( -- ?)   \ comm port carriage return
       0D EMIT 0A EMIT
       VCOL OFF
       VROW @ 1+  17 MIN VROW !  ; \ don't count past last line

: TYPE   ( addr cnt --)  PAUSE  BOUNDS ?DO  I C@ CEMIT LOOP ;
T' TYPE  RESOLVES 'TYPE


: SPACE  ( -- )   BL EMIT ;
: SPACES ( n -- ) 0 MAX  0 ?DO  SPACE  LOOP ;
\ : BS    ( --)  08 EMIT SPACE 08 EMIT ; 
         

[CC] HEX [TC]

\ simplified 9902 setup commands
\ Usage:
\  RS232 /TTY1 BA=9600 8,N,1 OPEN-TTY

: RS232    ( -- ) 1300  CARD ! ;   \ primary card
\ : RS232/2  ( -- ) 1500  CARD ! ;
: /TTY1    ( -- ) 040  UART ! ;
: /TTY2    ( -- ) 080  UART ! ;
\  : BA=1200         01A0 BPS ! ;
: BA=2400         00D0 BPS ! ;
: BA=9600  ( -- ) 0034 BPS ! ;
: BA=19200 ( -- ) 001A BPS ! ;
\ : BA=38400 ( -- ) 000D BPS ! ;
: 8,N,1    ( -- ) 9300 PROTO ! ;

CROSS-COMPILING
