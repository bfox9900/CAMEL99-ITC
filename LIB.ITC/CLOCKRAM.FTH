\ CLOCK.MAX    access realtime clock in maxforth cpu           21DEC92 FOX
\ Ported from MaxForth ot ANS/ISO Forth for CAMEL99 Forth      27MAR19 BFox
\ Tested with MK48T18 8K battery ram with CLOCK and calendar

HEX
 E000    CONSTANT ctrl     ( base address of real time clock with 8K RAM)
( 3FF8     CONSTANT ctrl   ( base address of real time clock with Hi ram )
ctrl 1 + CONSTANT sec
ctrl 2 + CONSTANT min
ctrl 3 + CONSTANT hr
ctrl 4 + CONSTANT day
ctrl 5 + CONSTANT date
ctrl 6 + CONSTANT month
ctrl 7 + CONSTANT yr

2 BASE !
 10000000 CONSTANT wrtmsk
 01000000 CONSTANT rdmsk
 00100000 CONSTANT dwnmsk

.( bcd conversions)
HEX
: BCD>S ( bcd -- n )
       DUP  0F AND
       SWAP F0 AND
       4 RSHIFT 0A * + ;

DECIMAL
: S>BCD ( n -- bcd )  10 /MOD  4 LSHIFT + ;

: BCD@  ( adr -- c)   C@ BCD>S ;      \ fetches BCD # and converts it

: clkwrt ( --) wrtmsk ctrl C! ;
: clkrd  ( --) rdmsk ctrl C! ;        \ stop updates
: clkon  ( --) 0 ctrl C! ;            \ resume updates

: DAY@  ( -- c )   clkrd day C@  07 AND clkon ;

: TIME@  ( -- sec min hr)
       clkrd
       sec BCD@  min BCD@  hr BCD@    \ read the bytes
       clkon ;
HEX
: TIME! ( hr min sec -- )
       clkwrt                         \ enable write-thru
       S>BCD 7F AND sec C!            \ prevent writing the STOP  bit
       S>BCD min C!
       S>BCD hr C!                    \ store values
       clkon ;                        \ disable writes

DECIMAL
: ##  ( n -- )  0 <# # # #> TYPE ;
: :## ( n -- )  0 <# # # 58 HOLD #> TYPE ;

: TIME. ( c c c -- )  ## :## :## ;

: .TIME  ( -- )   TIME@  TIME. ;


: DATE@  ( -- date month yr)
       clkrd                           ( stop updates )
       date BCD@  month BCD@  yr BCD@  ( read the bytes )
       clkon ;

: DATE! ( yr month date  -- )
       clkwrt
       0 day C!                        ( starts the oscillator)
       S>BCD date C!
       S>BCD month C!
       S>BCD yr C!                     ( store values )
       clkon ;                         ( disable writes )

: DATE.  ( c c c -- )   ## ." /" ## ." /" ## ;
: .DATE  ( -- )  DATE@  ## ." /" ## ." /" ## ;
