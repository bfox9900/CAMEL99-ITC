\ STRAIGHT a word from PolyForth to accept chars fast, no echo
\ reads continuous data at 9600/19.2K bps

MARKER REMOVE

HEX  .( .)
CREATE ALLDONE \ branch here to exit readcom
 020C , 1300 , \  R12 RS232/1 LI,
 1E07 ,        \ 7 SBZ,  \ turn off LED
 C337 ,        \ R12 RPOP,
 0300 , 0002 , \ 2 LIMI, \ interrupts on
 C101 ,        \ R1 TOS MOV, \ count to Forth TOS
 NEXT,

.( .)
\  DECIMAL ** decimal numbers used in Assembler code
\ CODE READCOM ( addr n -- n' )
\ 0 LIMI,           \ full attention
\ R12 RPUSH,
\ R12 RS232/1 LI,
\ 7 SBO,            \ turn on LED
\ PORT @@ R12 MOV,  \ select the 9902
\ *SP+ W MOV,       \ addr ->W   (ie: R8)
\ W TOS ADD,        \ calc last address ->TOS
\ R0 SETO,          \ set timeout register >FFFF
\ R1 CLR,           \ reset char counter
\ BEGIN,
\  21 TB,         \ test if char in uart
\  EQ IF,
\    *W+ 8 STCR,     \ put char in buf & inc W
\    18 SBO,         \ clr rcv buffer
\    R0 SETO,      \ reset timeout to 0FFFF
\    R1 INC,        \ count char
\ ELSE,
\      R0 DEC,    \ no char, dec TIMEDOUT
\       EQ IF,
\   ALLDONE @@ B,
\    ENDIF,
\  ENDIF,
\  W TOS CMP,        \ W =   end of buffer ?
\  EQ UNTIL,
\ ALLDONE @@ B,
\ ENDCODE
.( .)
HEX
CODE READCOM ( addr n -- n' )
 0300 , 0000 ,
 0647 , C5CC ,
 020C , CARD @ ,
 1D07 ,
 C320 , UART @ ,
 C236 , A108 , 0700 ,
 04C1 , 1F15 , 1605 , 3638 ,
 1D12 , 0700 , 0581 , 1004 ,
 0600 , 1602 ,
 0460 , ALLDONE ,
 8108 , 16F3 ,
 0460 , ALLDONE ,

 .( .)
DECIMAL
\ STRAIGHT from PolyForth. Read n chars into addr or timeout
: STRAIGHT ( addr len -- n)
       1 /STRING OVER 1- ( -- addr+1 len' addr)
       KEY SWAP C!      \ WAIT for 1st Char & store
       READCOM ;
