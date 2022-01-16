\ xfcc99 cross-compiler tms9902 rs232/1 DIRECT cru DRIVER 11APR2019 bjf

\ eXPERIMENT using SUB-PROGRAMS (separate workspace)
\ this removes the need to push/pop R12 because sub-programs have their own
\ copy.

 NEEDS .S    FROM DSK1.TOOLS
 NEEDS MOV,  FROM DSK1.ASM9900

\ sub-program creator. "PROG:s" blwp themselves from within Forth
 : PROG: ( wksp -- )
\ Compile-time action
        CREATE
          ( wksp) ,  HERE CELL+ ,
          !CSP

\ Run-time Action
       ;CODE *W BLWP,    \ call myself :-)
                NEXT,    \ return to Forth
             ENDCODE

 : ;PROG  ( -- ) ?CSP  ;  \ check stack position for junk left on it.

HEX
CREATE COMREGS  20 ALLOT

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
\ Alias COMREGS registers that hold parameters for clarity
R0     CONSTANT BPS
R1     CONSTANT PROTO
R12    CONSTANT PORT

: [TOS]       8 (R13) ;  \ Forth top of stack register

\ record parameters directly in the workspace registers
: BA=9600  ( -- ) 0034 COMREGS BPS +  ! ;
: 8,N,1    ( -- ) 9300 COMREGS PROTO + ! ;

BA=9600  8,N,1

CREATE LEDON
        R12 RS232/1 LI,
        7 SBO,
        RT,

CREATE LEDOFF
        R12 RS232/1 LI,
        7 SBZ,
        RT,

COMREGS PROG: OPEN-TTY  ( port -- ) \ Usage: /TTY1 OPEN-TTY
         LEDON @@ BL,
         [TOS] R12 MOV,     \ load 9902 port address
         RESET SBO,         \ reset card
         PROTO 8 LDCR,      \ set protocol from R1
         LDIR SBZ,          \ disable 9902 timer
         BPS  0C LDCR,      \ set baud rate from R0
         LEDOFF @@ BL,
;PROG


DECIMAL
\ this word turns on the LED when sending
COMREGS PROG: (CEMIT) ( c -- )  \ 'com-emit"
         LEDON @@ BL,
         BEGIN,
           27 TB, EQ    \ test -DSR bit =0
         UNTIL,
         16 SBO,        \ set RTS
         BEGIN,
           22 TB, EQ    \ wait XBRE empty
         UNTIL,
        [TOS] R4 MOV,
         R4 SWPB,      \ put byte on the other side
         R4 8 LDCR,    \ send 8 bits
         16 SBZ,        \ reset RTS
         OUT  @@ INC,
         VCOL @@ INC,
         LEDOFF @@ BL,
         RTWP,
;PROG

: CEMIT ( c --) (CEMIT) DROP ;

DECIMAL
COMREGS PROG: (CKEY?) ( -- n )         \  "com-key"
         0 LIMI,
         [TOS] CLR,
         21 TB,               \ test if char ready
         EQ IF,
             [TOS] 8 STCR,    \ read the char
             18 SBZ,          \ reset 9902 rcv buffer
             [TOS] 8 SRL,       \ shift to other byte
         ENDIF,
         2 LIMI,
         RTWP,
;PROG

: CKEY?  0 (CKEY?) ;

 BA=9600 8,N,1  /TTY1 OPEN-TTY
