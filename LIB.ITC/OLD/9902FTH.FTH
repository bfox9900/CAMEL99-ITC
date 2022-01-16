\ hi speed rs232 EMIT using direct CRU communication 21JAN87 BJF
\ *written for TI-Forth* modified for CAMEL99 Forth 07DEC18 BJF
 
NEEDS CRU!  FROM DSK1.CRU2
\ NEEDS 'EMIT FROM DSK1.VECTORIO
 
HEX
      034 CREATE   RATE  ,   \ 9600 baud, 1A1 1200 baud
      0B3 CREATE PROTOCOL  , \ 8 bits, Odd, 1 stop
 
      1300 CONSTANT RS232
RS232 40 + CONSTANT TTY1    \ 40= 9902#1,
RS232 80 + CONSTANT TTY2    \ 80= 9902#2
 
VARIABLE PORT
 
DECIMAL
      13 CONSTANT LDIR     \ load interval register
      16 CONSTANT RTSON    \ request to send
      18 CONSTANT RIENB    \ rcv interrupt enable
      21 CONSTANT RXRL     \ receive register loaded bit
      22 CONSTANT TXRE     \ transmit register empty bit
      28 CONSTANT CTS      \ data set ready
      31 CONSTANT RESET    \ reset the 9902
 
HEX
: CARD    ( cru -- )
          CRU@ OVER <>  \ is this a new card?
          IF   0SBZ     \ yes, turn off current card
          THEN CRU! ;   \ then select NEW card

: RS232-ON  ( -- ) RS232 CARD  0SBO  7 SBO ;     \ turn on LED
: RS232-OFF ( -- ) RS232 CARD  0SBZ  7 SBZ ;
 
: OPEN-TTY ( tty -- )   \ Use: TTY1 OPEN-TTY
          PORT !
          RS232-ON
          PORT @ CRU!             \ chip is base address
          RESET SBO 20 MS        \ reset 9902 chip
          PROTOCOL @ 8 PORT LDCR  \ 8 bits, Odd, 1 stop
          LDIR SBZ               \ interval timer off
          RATE @  0C PORT LDCR  \ set RX/TX baud rate (12 bits)
          RS232-OFF ;
 
: TTYEMIT   ( c --) \ NO HANDSHAKE!
          7F AND
          RS232-ON
          PORT @ CRU!
          RTSON SBO
          BEGIN
            PAUSE
            TXRE TB
          UNTIL
          8 PORT @ LDCR  \ send byte
          RTSON SBZ      \ clear tx buffer
          1 OUT +!       \ count character
          RS232-OFF ;
 
: TTY?   ( -- ? ) RXRL TB ;
 
: TTYKEY ( -- n)
          RS232-ON
          PORT @ CRU!
          BEGIN
            PAUSE
            RXRL TB
          UNTIL
          8 PORT @ STCR  7F AND
          RIENB SBZ
          RS232-OFF ;

HEX
: TTYCR  ( -- ) 0D TTYEMIT 0A TTYEMIT   OUT OFF ;
 
 CR .( Done!) ABORT
 
 CR .( Init UART)
 TTY1 OPEN-TTY
 
 
