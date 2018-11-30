\ tms9902 RS232 driver for TI-99 cards

\ Strategy for no-interrupt RS232 receive
\ 1. Use multi-tasker to sample com port
\ 2. Use CODE word to read the 9902 chip
\ 3. If character is waiting CODE word will Queue the character and check for another one.
\    This is stop the multi-tasker while data is coming in but is required.
\ 4. Consider using BLWP to call the CODE and use registers for enqueue/dequeue pointers


INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F 

\ TI-99 RS232 CRU address definitions
HEX
 034  CONSTANT RATE
00B3  CONSTANT 9600BPS  \ this number is 9600 bps, odd parity

1300  CONSTANT RS232/1  \ base address of the cards
1500  CONSTANT RS232/2

7     CONSTANT LED      \ LED bit for TI-99 serial card
40    CONSTANT COMBASE1   \ base address of the #1 TMS9902 UART chip
80    CONSTANT COMBASE2   \ base address of the #2 TMS9902 UART chip

RS232/1 COMBASE1 + CONSTANT COM1 \ return the base address for com1
RS232/2 COMBASE2 + CONSTANT COM2 \ return the base address for com2

\ load control bits.  !! these are not CRU addresses, they are bit offsets
DECIMAL
11 CONSTANT LXDR      \ gives access to the TX buffer register
12 CONSTANT LRDR      \
13 CONSTANT LDIR
14 CONSTANT LDCTRL
16 CONSTANT RTSON
17 CONSTANT BRKON
18 CONSTANT RXINTEN

\ Input bits.  These bits are read when LDIR bit is high?
21 CONSTANT RXBL   ( flag)
22 CONSTANT TXBE   ( flag)

31 CONSTANT RST9902   \ reset the TMS9902 UART by setting this bit  to '1'

\ create control register constants
\ OR these constants together to create the rate configuration byte

\     LI   R0,>0800                Divide Phi3 by 4
\     ORI  R0,>3000                Odd parity
\     ORI  R0,>0300                8 bits per char
\     ORI  R0,>8000                1 stop bit

2 BASE ! ( binary RADIX)
00001000        CONSTANT CLK/4
00110000        CONSTANT ODD
00100000        CONSTANT EVEN
00000000        CONSTANT NONE
11000000        CONSTANT 1STOPS
01000000        CONSTANT 2STOPS

HEX
\ create the control byte as an CONSTANTate
CLK/4 EVEN + 1STOPS + CONSTANT CTRLBYTE

\ More hi-level CRU control words
\ Kernel has: CRU!  CRU@  0SBO  0SBZ
CODE 0TB   ( -- )
           0 TB,    \ test fast test bit
           NEXT,
           ENDCODE  

CODE CRU+! ( n  -- )    \ add n to CRU base address
         TOS R12 ADD,
         TOS POP,       \ refill TOS register
         NEXT,
         END-CODE

\ write 8 bits to IO address set by CRU!
CODE: PC!    (  c  -- )
              TOS 8 STCR,   \ "load" 8 bits to TOS
              TOS POP,      \ refill TOS
              NEXT,
              END-CODE

\ read 8 bits from IO address set by CRU!
CODE: PC@    ( CRUadr -- c)
              TOS PUSH,
              TOS 8 LDCR,   \ "store" 8 bits from TOS to CRU
              TOS 8 SRL,
              NEXT,
              END-CODE
HEX

CREATE BAUDTB
       001A ,  \ 19.2Kbps   1
       0034 ,  \ 9600bps    2
       0068 ,  \ 4800bps    3
       00D0 ,  \ 2400bps    4
       01A0 ,  \ 1200bps    5
       0340 ,  \  600bps    6
       04D0 ,  \  300bps

CODE COMINIT  ( selector -- )
        TOS  2 SLA,            \ selector x 2
            31 SBO,            \ reset the 9902 chip with '1' to bit 31
                               \ lcdctrl bit is now set to 1
        LDIR   SBZ,            \ remove 1 from LDIR to get access to rate registers
        LDCTRL SBO,            \ enable load control bit


        BAUDTB (TOS) 12 LDCR,   \ send this rate to RX rate register
                                \ This action clears LRDR bit 12 to gain access
                                \ to the TX rate register.. see next instruction

        BAUDTB (TOS) 12 LDCR,   \ send the rate to Tx rate register
                                \ This action also clears the LXDR bit
                                \ and gives access to the TX buffer register
        NEXT,                   \ return from Branch and link
        ENDCODE




CODE INIT ( card-adr -- ) \ code taken from Fundamentals of Microcomputer Design
           DUP CRU! 0SBO      \ Turn card on

           COM1 CRU!           \ set the base address for com1 in R12
           2 COMINIT           \ 2 sets baud to 9600
;

CODE GETCH  ( -- c)            \ read a char from com1
         TOS PUSH,
         R12 COM1 LI,
         21 TB,   \ is the rcv buffer loaded?
         EQ IF,
             TOS CLR,
             TOS 7 STCR,
             18 SBZ,
         ENDIF,
         NEXT,
         ENDCODE


CODE CKEY? ( -- ? )    \ test if a CHAR is waiting
        RTSON SBZ,         \ turn OFF RTS
        BRKON SBO,         \ disable TX buffer
        TOS PUSH,
        TOS CLR,
        RXBL TB,           \ test rx buffer in this loop
        NE IF  
          TOS SETO,
        ENDIF
        NEXT,
        ENDCODE

CODE CKEY ( -- ? )          \ wait for a char from RS232
        R12 COMBASE1 LI,    \ combase1 needs to be a variable in the final version
        RTSON SBZ,          \ turn OFF RTS
        BRKON SBO,          \ disable TX buffer
        TOS PUSH,           \ make room on the parameter stack
        BEGIN,
            RXBL TB,        \ test rx buffer in this loop
        NE UNTIL,
        TOS 8 STCR,         \ read 8 bits to the top of the Forth stack
        NEXT,
        ENDCODE

: CKEY  ( -- c)
         COMBASE1 CRU!  
         BEGIN 
           PAUSE CKEY? 
         UNTIL
         PC@ ;

CODE (COM-EMIT) ( c -- )
        R12 COMBASE1 LI,    \ combase1 needs to be a variable in the final version
        BEGIN
            RXBL TB,        \ test rx buffer in this loop
        EQ UNTIL

        RTSON SBO,          \ turn on RTS
        BRKON SBZ,          \ expose the TX buffer
        TOS 8 LDCR,         \ write the character
        TOS POP,
        NEXT,
        END-CODE

: CONEMIT  EMIT ;
: CONCR    CR   ;
: ?CONKEY  ?KEY ; 
: CONKEY   KEY  ;
: CONPAGE  PAGE ; 
: CONTYPE  TYPE ;
: CONPAGE  PAGE ;

: PERFORM   @ EXECUTE ;

: EMIT   'EMIT PERFORM ;
: PAGE   'PAGE PERFORM ;
: ?KEY   '?KEY PERFORM ;
: KEY    'KEY  PERFORM ;
: TYPE   'TYPE PERFROM ;

: CONSOLE
       ['] CONEMIT 'EMIT !          \ vector for char. output routine
\      30 USER: 'CR              \ vector for carriage return
\      34 USER: 'KEY?            \ vector for key pressed test
\      32 USER: 'KEY             \ vector for wait-for-key 
\      36 USER: 'TYPE            \ vector for block output
\      38 USER: 'PAGE            \ vector for screen clear


: RS232!IO ( -- )
        ['] ?COMKEY     '?KEY !         \ test for a char and return a flag
        ['] COMKEY      'KEY  !         \ wait for a char
        ['] COMEMIT     'EMIT !         \ output a char

;

exit

* This routine sets the transmission conditions for the first TMS9902 on card 1
      LI   R12,>1300               CRU address of first interface card (use >1500 for the second card, if any)
      SBO  0                       Turn card on
      AI   R12,>0040               Address of first TMS9902 (use >0080 for the second chip)
      SBO  14                      We want to load the control register
      LI   R0,>0800                Divide Phi3 by 4
      ORI  R0,>3000                Odd parity
      ORI  R0,>0300                8 bits per char
      ORI  R0,>8000                1 stop bit
      LDCR R0,8                    Load the control register
      SBO  12                      Let's skip the interval register
      LI   R0,>009C                This boils down to 2400 bps
      LDCR R0,11                   Load the reception rate register
      LDCR R0,11                   Load same value in the emission rate register
      B    *R11

