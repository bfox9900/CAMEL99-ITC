\ tms9902 RS232 driver for TI-99 cards

\ Strategy for no-interrupt RS232 receive
\ 1. Use multi-tasker to sample com port?
\ 2. Use CODE word to read the 9902 chip
\ 3. If character is waiting CODE word will Queue the character and check for another one.
\    This will stop the multi-tasker while data is coming in but is required.
\ 4. Consider using BLWP to call the CODE and use registers for enqueue/dequeue pointers

NEEDS DUMP FROM DSK1.TOOLS
NEEDS TOS  FROM DSK1.ASM9900
NEEDS SBO  FROM DSK1.CRU
NEEDS 'KEY FROM DSK1.VECTORIO

\ TI-99 RS232 CRU address definitions
HEX
0034 CONSTANT 9600BPS   \ this number is 9600 bps, odd parity

1300 CONSTANT RS232/1   \ base address of the cards
1500 CONSTANT RS232/2

   7 CONSTANT LED       \ LED bit for TI-99 serial card

40 CONSTANT TTY1         \ address for 9902 #1
80 CONSTANT TTY2         \ address for 9902 #2

VARIABLE CARD            \ holds base address of the rs232 card
VARIABLE PORT            \ holds CRU offset of 9902 chip



\ load control bits.  **not CRU addresses, they are bit offsets**
DECIMAL
11 CONSTANT LXDR         \ gives access to the TX data register
12 CONSTANT LRDR
13 CONSTANT LDIR
14 CONSTANT LDCTRL
16 CONSTANT RTS
17 CONSTANT BRK
18 CONSTANT RXRST
21 CONSTANT RXBL      \ rec'v buffer loaded bit
22 CONSTANT TXBE      \ tx buffer empty bit
27 CONSTANT DSR
31 CONSTANT RST9902   \ reset the TMS9902 UART by setting this bit to '1'

\ create control register constants
\ OR these constants together to create the rate configuration byte

\     LI   R0,>0800    Divide Phi3 by 4
\     ORI  R0,>3000    Odd parity
\     ORI  R0,>0300    8 bits per char
\     ORI  R0,>8000    1 stop bit

2 BASE ! ( binary RADIX)
00001000 CONSTANT CLK/4
00110000 CONSTANT ODD
00100000 CONSTANT EVEN
00000000 CONSTANT NONE
11000000 CONSTANT 1STOPS
01000000 CONSTANT 2STOPS

HEX
\ create the control byte as an CONSTANT
CLK/4 ODD + 1STOPS + CONSTANT CTRLBYTE

\ Clock          3.0 MHz
\ Rate(bps) CLK4M Rate register
\ --------- ----- -----------
\ 110         1     >5AA
\ 300         1     >49C
\ 600         1     >271
\ 1200        0     >1A1
\ 2400        1     >09C
\ 4800        1     >04E
\ 9600        1     >034

CODE TTYINIT (  -- )
     CARD @@ R12 MOV,  \ CRU address of interface card (>1300 or >1500 for the second card)
\               0  SBO,   \ Turn card on  ONLY use for DSRs
               7  SBO,   \ turn on front panel LED
      PORT @@ R12 ADD,   \ Address  TMS9902 chip added to combase
          RST9902 SBO,   \ reset the chip
           LDCTRL SBO,   \ select control register

\ create control value in R0
\      R0      800 LI,   \ Divide Phi3 by 4
\      R0     3000 ORI,  \ Odd parity
\      R0     0300 ORI,  \ 8 bits per char
\      R0     8000 ORI,  \ 1 stop bit
      R0   CTRLBYTE LI,
      R0     0008 LDCR,  \ Load the control register

               0C SBO,   \ skip the interval register
      R0       27 LI,    \ 9600 bps
      R0     0011 LDCR,  \ Load the reception rate register
      R0     0011 LDCR,  \ Load same value in the emission rate register
      NEXT,
      ENDCODE

CODE TTY@ (  -- c)
        TOS PUSH,
        TOS CLR,
        TOS 7 STCR,      \ "store" 7 bits from TOS to CRU
        TOS 8 SRL,
        RXRST SBZ,       \ reset RXBL
        NEXT,
        ENDCODE

CODE TTY! ( c -- )
        TOS 8 LDCR,   \ write the character
        RTS SBZ,      \ ready to OFF
        TOS POP,
        NEXT,
        ENDCODE
        
CODE CRU+! ( cru-bits -- )  
       TOS R12 ADD,
       TOS POP, 
       NEXT, 
       ENDCODE

\ ============================================
\ HI LEVEL FORTH API

CREATE COMTBL
       RS232/1 , TTY1 ,
       RS232/1 , TTY2 ,
       RS232/2 , TTY1 ,
       RS232/2 , TTY2 ,
HEX
: COMPORT ( n -- )
          DUP 0 4 WITHIN 0= ABORT" bad comport"
          4* COMTBL + 2@  CARD !  PORT ! ;

: TTY?  ( -- ?) RXBL TB ;

: TTYKEY  ( -- c)
        RTS   SBZ
        BRK   SBO
        BEGIN  PAUSE  TTY? UNTIL
        TTY@ ;
HEX
: TTYEMIT ( c -- )
        PORT @ CRU!
        007F AND
        BEGIN  PAUSE DSR TB UNTIL
        RTS SBO     \ ready to ON
        BEGIN  PAUSE TXBE TB UNTIL
        TTY! ;

: TTYCR  ( -- ) 0D EMIT 0A EMIT ;

\ VT100 CONTROL
DECIMAL
: .PARM   ( n -- ) BASE @ SWAP DECIMAL U. BASE ! ;
: \ESC    ( -- )   27 EMIT ." [" ;
: \PARM   ( c -- ) \ESC .PARM ;
: <UP>    ( -- )   \PARM ." A" ;
: <DOWN>  ( -- )   \PARM ." B" ;
: <RIGHT> ( -- )   \PARM ." C" ;
: <BACK>  ( -- )   \PARM ." D" ;
: <HOME>  ( -- )   \ESC  ." F" ;
: <CLS>   ( -- )   \ESC  ." 2J" ;
: <CLRLN> ( -- )   \ESC  ." K" ;

: AT-XY  ( col row --) 2DUP AT-XY  \ESC .PARM ." ;" .PARM ." H" ;
: TTYCLS ( -- ) <CLS>  <HOME> ;

: TTY-IO ( -- )
        ['] TTYEMIT  'EMIT !   \ output a char
        ['] TTYCR    'CR   !
        ['] TTYKEY   'KEY  !   \ wait for a char
        ['] TTY?     'KEY? !   \ test for a char and return a flag
        ['] TTYCLS   'PAGE !
        -1 SOURCE-ID !         \ indicate we not on ti-99 console
;


0 COMPORT TTYINIT


