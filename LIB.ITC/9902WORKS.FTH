\ hi speed rs232 EMIT using direct CRU communication 21JAN87 BJF
\ *written for TI-Forth* modified for CAMEL99 Forth 07DEC18 BJF

NEEDS CRU!  FROM DSK1.CRU
NEEDS LDCR  FROM DSK1.LDCRSTCR
\ NEEDS 'EMIT FROM DSK1.VECTORIO

HEX
      034 CREATE   RATE  ,   \ 9600 baud, 1A1 1200 baud
      0B3 CONSTANT PROTOCOL  \ 8 bits, Odd, 1 stop
     1300 CONSTANT RS232

RS232 40 + CONSTANT PORT1    \ 40= 9902#1,
RS232 80 + CONSTANT PORT2    \ 80= 9902#2

DECIMAL
      13 CONSTANT LDIR     \ load interval register
      16 CONSTANT RTSON    \ request to send
      18 CONSTANT RIENB    \ rcv interrupt enable
      21 CONSTANT RXRL     \ receive register loaded bit
      22 CONSTANT TXRE     \ transmit register empty bit
      28 CONSTANT CTS      \ data set ready
      31 CONSTANT RESET    \ reset the 9902

HEX
: CARD-ON ( CRU -- )
          RS232  CRU!
          0 SBO             \ turn on RS232
          7 SBO  ;          \ turn on LED

: CARD-OFF ( -- ) RS232 CRU!  0 SBZ  7 SBZ ;

: OPEN-TTY ( -- )
          CARD-ON
          PORT1 CRU!            \ chip is base address
          RESET SBO 20 MS       \ reset 9902 chip
          PROTOCOL 8 PORT1 LDCR \ 8 bits, Odd, 1 stop
          LDIR SBZ              \ interval timer off
          RATE @ 0C PORT1 LDCR ;  \ set baud rate (12 bits)

CODE PC!   3204 , C136 , NEXT, ENDCODE
CODE PC@   0646 , C585 , 3604 , NEXT, ENDCODE
: TTYEMIT   ( c --) \ NO HANDSHAKE!
   7F AND  CARD-ON PORT1 CRU! RTSON SBO
   BEGIN TXRE TB UNTIL
   8 PORT1 LDCR  \ send byte
   RTSON SBZ     \ clear tx buffer
   1 OUT +!      \ count character
   CARD-OFF ;
: TTY?   ( -- ? ) RXRL TB ;

: TTYKEY ( -- n)
         CARD-ON
         PORT1 CRU!
         BEGIN
           TTY? ?BREAK
         UNTIL
         8 PORT1 STCR  7F AND

         RIENB SBZ  CARD-OFF ;
HEX
: TTYCR  ( -- ) 0A EMIT 0D EMIT  OUT OFF ;
 CR .( Done!) ABORT

 CR .( INIT UART)  OPEN/TTY


