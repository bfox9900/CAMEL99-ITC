\ CLOCK.MAX    access realtime clock in maxforth cpu           21DEC92 FOX
\ Ported from MaxForth to ANS/ISO Forth for CAMEL99 Forth      30MAY2020 BFox
\ MK48T18 8K battery ram with CLOCK and calendar in SUPER CART (>6000)

HERE
HEX
    6FF8   CONSTANT ctrl ( base address & control register of clock)
  ctrl 1 + CONSTANT sec
\ ctrl 2 + CONSTANT min
\ ctrl 3 + CONSTANT hr
  ctrl 4 + CONSTANT day
  ctrl 5 + CONSTANT date
\ ctrl 6 + CONSTANT month
\ ctrl 7 + CONSTANT yr

.( bcd conversions)
HEX
: BCD>S ( bcd -- n )
       DUP  0F AND
       SWAP F0 AND
       4 RSHIFT 0A * + ;

DECIMAL
: S>BCD ( n -- bcd )  10 /MOD  4 LSHIFT + ;

: BCD@  ( adr -- c)   C@ BCD>S ;      \ fetches BCD # and converts it

: clkwrt ( --) 80 ctrl C! ;    \ set write bit
: clkrd  ( --) 40 ctrl C! ;    \ set read bit stops updates
: clkon  ( --)  0 ctrl C! ;    \ clr R/W, resume updates
: ##  ( n -- ) 0 <# # # #> TYPE ;
DECIMAL
: DAY@  ( -- c ) clkrd day C@  07 AND clkon ;

: TIME@  ( -- sec min hr) \ can be used to compute total seconds
       clkrd
       sec BCD@
       sec 1+ BCD@
       sec 2+ BCD@    \ read the bytes
       clkon ;

: DATE@  ( -- date month yr)
       clkrd                           ( stop updates )
       date BCD@  date 1+ BCD@  date 2+ BCD@  ( read the bytes )
       clkon ;

: .TIME  ( -- ) TIME@  ## ." :" ## ." :" ## ;
HEX
: TIME! ( hr min sec -- )
       clkwrt               \ enable write-thru
       S>BCD 7F AND sec C!  \ store sec. & protect the STOP  bit
       S>BCD sec 1+ C!      \ store minutes
       S>BCD sec 2+ C!      \ store hours
       clkon ;              \ disable writes

: DATE! ( yr month date  -- )
       clkwrt
       0 day C!             \ starts the oscillator
       S>BCD date C!
       S>BCD date 1+ C!
       S>BCD date 2+ C!     \ store values
       clkon ;

                 \      YR       MM       DD
: .DATE  ( -- )  DATE@  ## ." /" ## ." /" ## ;

HERE SWAP - DECIMAL . .( bytes)
