\ IDECLOCK.FTH   big version. For TI-99 IDE disk card  July 2024 B FOX

\ INCLUDE DSK1.TOOLS  ( DEBUG only)

HERE 
\ clock registers in memory 
HEX 
4020 CONSTANT secs   \ Register 0: Seconds. Valid values: >00 to >59.
4024 CONSTANT mins   \ Register 2: Minutes. Valid values: >00 to >59.
4028 CONSTANT hrs    \ Register 4: Hours. Valid values: >00 to >23, 
402C CONSTANT day    \ Register 6: Day of the month. Valid values: >01 through >31.
4030 CONSTANT dow    \ day of the week
4032 CONSTANT month  \ Register 9: Month. Valid values >01 to >12.
4034 CONSTANT year   \ Register 10: Year. Valid values >00 to >99.
403C CONSTANT ctrl   \ Register 14: Control register

1000 CONSTANT IDECARD 

DECIMAL
12 2* USER CRU   \ address of R12 in any Camel Forth workspace 

\ Machine code CRU words
HEX
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
CODE 3SBO  ( -- ) 1D03 ,  NEXT, ENDCODE

\ BCD integer conversions 
: BCD>S ( bcd -- n ) \ "BCD to single"
    DUP  0F AND
    SWAP F0 AND
    4 RSHIFT 0A * + ;

DECIMAL
: S>BCD ( n -- bcd )  10 /MOD  4 LSHIFT + ;

\ Update Transfer Inhibit
: UTI-ON   ( -- ) ctrl DUP C@ 8 OR SWAP  C! ;
: UTI-OFF  ( -- ) ctrl DUP C@ 7 AND SWAP C! ;

: CLOCK-ON 
    IDECARD CRU !  
    0SBO            
    1SBO            \ enable mapping of >4000 - >40ff space
    3SBO            \ fixed page at >4000 - >40ff
;

\ creates "field readers" that read a clock field using common code. 
\ slower reads, but saves a lot of space
: CLOCK-FIELD:   
    CREATE  ,     
    DOES> 
        CLOCK-ON 
        UTI-ON 
        @         \ get the clock address from this word
        C@ BCD>S  \ read the address and convert
        UTI-OFF 
        0SBO ;    \ card off 

\ define the field readers 
 secs CLOCK-FIELD: SECS@ 
 mins CLOCK-FIELD: MINS@ 
  hrs CLOCK-FIELD: HRS@  
  dow CLOCK-FIELD: DOW@ 
  day CLOCK-FIELD: DAY@ 
month CLOCK-FIELD: MONTH@  
 year CLOCK-FIELD: YEAR@ 

: TIME@ ( -- secs min hrs)    SECS@ MINS@ HRS@ ;
: DATE@ ( -- day month year)  DAY@ MONTH@ YEAR@ ;  

\ formatted output 

\ returns a string. can be used to create a time/date string 
:  (##)   ( -- addr len ) 0 <#  # #  #>  ;

: .##    (##) TYPE ;

\ +PLACE  concatenates (addr n) to counted string $addr
: +PLACE  ( addr n $addr -- ) 2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

\ syntax suger: concatenate stack string to pad  
: &       ( addr len -- ) PAD +PLACE ; 

\ usage:  TIME@ >TIME$ 
: >TIME$  ( mins secs hrs -- addr len) 
    PAD OFF  
    BASE @ >R 
    DECIMAL (##) &  S" :" &  (##) & S" :" &  (##) & 
    R> BASE !  

    PAD COUNT ;

\ Usage: DATE@ >DATE$ 
: >DATE$  ( day month year -- addr len) 
    PAD OFF  
    BASE @ >R 
    DECIMAL (##) &  S" /" &  (##) &  S" /" &  (##) & 
    R> BASE !  

    PAD COUNT ;

\ Set the clock words 
DECIMAL
: TIME! ( hr min sec -- )
       CLOCK-ON  
       UTI-ON 
       S>BCD secs C!  
       S>BCD mins C!       
       S>BCD hrs  C!     
       UTI-OFF 
       0SBO ;         

: DATE! ( yr month day-- )
       CLOCK-ON  
       UTI-ON 
       S>BCD day C!  
       S>BCD month C!       
       S>BCD year  C!     
       UTI-OFF 
       0SBO ;         

\ OUTPUT WORDS 
: .TIME  ( -- ) 
    BASE @ >R  
    DECIMAL TIME@ .## ." :" .## ." :" .## 
    R> BASE ! ;         

\ compact string array. Uses count byte as link to next string.
: NTH$ ( $array n -- address len )
  0 DO  COUNT +  ALIGNED  LOOP COUNT ;

CREATE MONTHS
  S"  " S,    S" Jan" S,
  S" Feb" S,  S" Mar" S,
  S" Apr" S,  S" May" S,
  S" Jun" S,  S" Jul" S,
  S" Aug" S,  S" Sep" S,
  S" Oct" S,  S" Nov" S,
  S" Dec" S,  0 ,

: ]MONTH  ( n -- addr len)
  DUP 13 1 WITHIN ABORT" Bad month#"
  MONTHS SWAP NTH$ ;

CREATE DAYS
  S"  " S,
  S" Sunday" S,
  S" Monday" S,
  S" Tuesday" S,
  S" Wednesday" S,
  S" Thursday" S,
  S" Saturday" S,
  S" Friday" S,
  0 ,
 
: ]DAY ( n --) 
    DUP 7 1 WITHIN ABORT" Bad day#" 
    DAYS SWAP NTH$ ;

: .DOW     ( --) DOW@ ]DAY TYPE ;
: .MONTH   ( --) MONTH@ ]MONTH TYPE ;
: .YEAR    ( --) YEAR@ 20 .##  .## ;

: .M/D/Y      ( -- ) MONTH@  .## ." /" DAY@ .## ." /"  YEAR@ .## ;
: .Y-M-D      ( -- ) YEAR@ .YEAR ." -" MONTH@ .## ." -" DAY@ .## ;
: .D.M.Y      ( -- ) DAY@ .## ." ." MONTH@ .## ." ." YEAR@ .## ;
: .USADATE    ( -- ) .MONTH SPACE  DAY@ .## ." , "  .YEAR ;
: .FORTH-DATE ( -- ) DAY@ .##  .MONTH  YEAR@ .## ;
: .LONG-DATE  ( -- )  .DOW  ." , "  .MONTH SPACE DAY@ .## ." , "  .YEAR ;  
: .STAMP       ( -- )  .LONG-DATE ." , " .TIME ;
HERE SWAP - DECIMAL . .( bytes)
\ TEST
\ CR 
\ .M/D/Y  CR 
\ .Y-M-D  CR
\ .D.M.Y CR 
\ .USADATE  CR 
\ .FORTH-DATE  CR 
\ .LONG-DATE  CR 
\ .STAMP  CR 
