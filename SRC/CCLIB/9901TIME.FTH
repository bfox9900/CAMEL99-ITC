\ TICKTOCK.HSF  TMS9901 hardware timer interface for Camel 99 Forth

\ credit to: http://www.unige.ch/medecine/nouspikel/ti99/tms9901.htm#Timer

\ timer resolution:  64 clock periods, thus 64*333 = 21.3 microseconds
\ Max Duration    :  ($3FFF) 16383 *64*333 ns = 349.2 milliseconds

NEEDS .S   FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
HEX
CODE TMR!   ( n  -- )        \ load TMS9901 timer to max value 3FFF
             R12 CLR,        \ CRU addr of TMS9901 = 0
             0 LIMI,
             0   SBO,        \ SET bit 0 to 1, Enter timer mode
             R12 INCT,       \ CRU Address of bit 1 = 2 , I'm not kidding
             TOS 0E LDCR,    \ Load 14 BITs from tos into timer
             R12  DECT,      \ go back to address 0
             0    SBZ,       \ reset bit 0, Exits clock mode, starts decrementer
             2 LIMI,
             TOS POP,
             NEXT,           \ 16 bytes
             ENDCODE

CODE TMR@   ( -- n)         \ read the TMS9901 timer
             TOS PUSH,
             R12 CLR,
             0 LIMI,
             0 SBO,          \ SET bit 0 TO 1, ie: Enter timer mode
             TOS 0F STCR,    \ READ TIMER (14 bits plus mode bit) into W
             TOS  1 SRL,     \ Get rid of mode bit
             0 SBZ,          \ SET bit 1 to zero
             2 LIMI,
             NEXT,
             ENDCODE

\ Because JIFFS are 1/10 second, there is a lot of time for PAUSE
\ 16666uS / 21.3 = 782   1/60
\ 10000uS / 21.3 = 469   1/10
HEX
: JIFF  ( -- )
       3FFF TMR!   \ count down from here
       BEGIN
          TMR@ [ HEX 3FFF DECIMAL 469 - ] LITERAL
       > WHILE
          PAUSE
       REPEAT
       0 TMR! ;
       
HEX
: 1MS  ( -- )
       3FFF TMR!   \ count down from here
       BEGIN
         TMR@ [ HEX 3FFF DECIMAL 46 - ] LITERAL
       > WHILE
       REPEAT ;

: JIFFS    ( n -- )  PAUSE 0 ?DO JIFF LOOP  ;

\ MS resolution limited to 1/60 second and minimum is 1/60 sec.

\ MS resolution limited to 1/60 second and minimum is 1/60 sec.
: MS  ( n -- )  4 RSHIFT  PAUSE JIFFS ;  \ MS/16 = JIFFS
