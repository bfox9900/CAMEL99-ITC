\ xfcc99 cross-compiler tms9902 rs232/1 DIRECT cru DRIVER 9Feb2019 bjf
\ MACHINE CODE words are used to save kernel space

\ These routines protect the value in R12 on the return stack
\ then restore it when returning to Forth.
\ This should help with accessing other I/O devices while using
\ the serial port.

 NEEDS .S    FROM DSK1.TOOLS
 NEEDS MOV,  FROM DSK1.ASM9900

 HEX
         1300 CONSTANT RS232/1     \ card address
RS232/1  40 + CONSTANT /TTY1       \ 40= 9902#1,
RS232/1  80 + CONSTANT /TTY2     \ 80= 9902#2

\         1400 CONSTANT RS232/2
\ RS232/2  40 + CONSTANT /TTY3       \ 40= 9902#1,
\ RS232/2  80 + CONSTANT /TTY4     \ 80= 9902#2

\ 9902 control bits
DECIMAL
\ for reference...
      13 CONSTANT LDIR     \ "load interval register"
\      16 CONSTANT RTSON    \ request to send
\      18 CONSTANT RIENB    \ rcv interrupt enable
\      21 CONSTANT RXRL     \ receive register loaded bit
\      22 CONSTANT TXRE     \ transmit register empty bit
\      27 CONSTANT -DSR     \ NOT data set ready
\      28 CONSTANT -CTS     \ NOT clear to send
      31 CONSTANT RESET    \ 9902 reset bit

HEX
VARIABLE BPS
VARIABLE PROTO
VARIABLE PORT
\ VARIABLE CARD   \ future use ?

\ simplified 9902 setup commands
: BA=9600  ( -- ) 0034 BPS ! ;
: 8,N,1    ( -- ) 9300 PROTO ! ;

BA=9600  8,N,1

CREATE LEDON
        R12 RS232/1 LI,
        7 SBO,
        RT,

CREATE LEDOFF
        R12 RS232/1 LI,
        7 SBZ,
        RT,

 CODE OPEN-TTY  ( port -- ) \ Usage: /TTY1 OPEN-TTY
         R12 RPUSH,
         LEDON @@ BL,
         TOS R12 MOV,       \ load 9902 port address
         RESET SBO,         \ reset card
         TOS PORT @@ MOV,   \ set the port variable to use
         PROTO @@ 8 LDCR,   \ set protocol
         LDIR SBZ,          \ disable 9902 timer
         BPS @@ 0C LDCR,    \ set baud rate
         TOS POP,           \ refill TOS
         LEDOFF @@ BL,
         R12 RPOP,          \ restore R12
         NEXT,
         ENDCODE


DECIMAL
\ this word turns on the LED when sending
 CODE CEMIT ( c -- )  \ 'com-emit"
         R12 RPUSH,
         LEDON @@ BL,
         PORT @@ R12 MOV,
         BEGIN,
           27 TB, EQ    \ test -DSR bit =0
         UNTIL,
         16 SBO,        \ set RTS
         BEGIN,
           22 TB, EQ    \ wait XBRE empty
         UNTIL,
         TOS SWPB,      \ put byte on the other side
         TOS 8 LDCR,    \ send 8 bits
         16 SBZ,        \ reset RTS
         OUT  @@ INC,
         VCOL @@ INC,
         TOS POP,
         LEDOFF @@ BL,
         R12 RPOP,
         NEXT,
         ENDCODE


 DECIMAL
 CODE CKEY? ( -- n )         \  "com-key"
         0 LIMI,
         R12 RPUSH,
         PORT @@ R12 MOV,    \ select >1340 CRU address
         TOS PUSH,
         TOS CLR,
         21 TB,               \ test if char ready
         EQ IF,
             TOS 8 STCR,      \ read the char
             18 SBZ,          \ reset 9902 rcv buffer
             TOS 8 SRL,       \ shift to other byte
          ENDIF,
          R12 RPOP,
          2 LIMI,
          NEXT,
          ENDCODE

 BA=9600 8,N,1  /TTY1 OPEN-TTY
