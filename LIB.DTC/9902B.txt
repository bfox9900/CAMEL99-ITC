\ CAMEL99 FORTH TMS9902 RS232/1 direct CRU communication 07DEC18 BJF

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS CRU!  FROM DSK1.CRU2
\ NEEDS 'EMIT FROM DSK1.VECTORIO

HEX

      1300 CONSTANT RS232    \ card address
RS232 40 + CONSTANT PORT1    \ 40= 9902#1,
RS232 80 + CONSTANT PORT2    \ 80= 9902#2

\ 9902 control bits
DECIMAL
      13 CONSTANT LDIR     \ load interval register
      16 CONSTANT RTSON    \ request to send
      18 CONSTANT RIENB    \ rcv interrupt enable
      21 CONSTANT RXRL     \ receive register loaded bit
      22 CONSTANT TXRE     \ transmit register empty bit
      27 CONSTANT -DSR     \ NOT data set ready
\      28 CONSTANT -CTS     \ NOT clear to send
      31 CONSTANT RESET    \ reset the UART

\ configuration variables
      VARIABLE BPS           \ bits per sec
      VARIABLE PROTOCOL    \ 8 BITS ODD PARITY
      VARIABLE PORT
\
DECIMAL
: 499200. ( -- d) 40488 7 ;   \ double precision literal

: BAUD   ( n -- )
         DUP 600 < ABORT" BAUD<600"       \ 600..19200 only
         499200. ROT UM/MOD NIP  BPS ! ;

: PROTOCOL! ( n -- ) PROTOCOL @ OR PROTOCOL ! ;

: STOPS  ( n -- ) \ bits 7 & 6
          3 - ABS
          2 OVER U< ABORT" stop bits!"
          6 LSHIFT  PROTOCOL! ;

: BITS  ( n -- ) \ bits 1 & 0
        5 -  4 OVER U< ABORT" data bits!"
        PROTOCOL!  ;

2 BASE !
00010000 CONSTANT NO
00100000 CONSTANT EVEN
00110000 CONSTANT ODD

HEX
: PARITY  ( n -- ) \ bit 5 & 4
          DUP NO ODD 1+ WITHIN 0= ABORT" Bad parity!"
          PROTOCOL! ;

: CARD    ( cru -- )
          CRU@ OVER <>  \ is this a new card?
          IF   0SBZ     \ yes, turn off current card
          THEN CRU! ;   \ then select new card

: RS232-ON  ( -- ) RS232 CARD  0SBO  7 SBO ;
: RS232-OFF ( -- ) RS232 CARD  0SBZ  7 SBZ ;

: OPEN-TTY ( -- )   \ Use: PORT1 OPEN-TTY
          BPS @  0= ABORT" Baud err"
          PORT @ 0= ABORT" Port err"
          PROTOCOL @ 0= ABORT" Protocol err"
          RS232-ON
          PORT @ CRU!               \ chip is base address
          RESET SBO 20 MS           \ reset 9902 chip
          PROTOCOL @ 8 PORT @ LDCR  \ 8 bits, Odd, 1 stop
          LDIR SBZ                  \ interval timer off
          BPS @  0C PORT @ LDCR     \ set RX/TX baud BPS (12 bits)
          RS232-OFF ;

: ?TTYBRK  ( -- ) ?TERMINAL ABORT" TTY stopped" ;

: TTYEMIT   ( c -- ) \ with RTS handshake
\     7F AND
     RS232-ON
     PORT @ CRU!
     BEGIN
       BEGIN
         RTSON SBO
        -DSR TB INVERT
       WHILE
         PAUSE
         ?TTYBRK
       REPEAT
       TXRE TB
     UNTIL
     8 PORT @ LDCR  \ send byte
     RTSON SBZ      \ clear tx buffer
     1 OUT +!       \ count character
     RS232-OFF ;

: TTYKEY ( -- n)
          RS232-ON
          PORT @ CRU!
          BEGIN
            RXRL TB
          UNTIL
          8 PORT @ STCR 7F AND
          RIENB SBZ
          RS232-OFF ;

HEX
: TTYCR    ( -- ) 0D TTYEMIT 0A TTYEMIT   OUT OFF ;
: TTY-TYPE ( adr len -- ) BOUNDS DO I C@ TTYEMIT LOOP ; 


: TTY1:  ( -- ) PORT1 PORT !  PROTOCOL OFF  BPS OFF ;


CR .( Opening TTY1)

 TTY1: 9600 BAUD  8 BITS  ODD PARITY  1 STOPS  OPEN-TTY

CR .( Done!)

CR .( TESTERS...)
DECIMAL
: TCHARS TTYCR 127 32 DO I TTYEMIT LOOP TTYCR ;

: TESTRUN  BEGIN TCHARS ?TERMINAL UNTIL ;


