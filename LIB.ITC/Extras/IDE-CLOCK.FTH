\ IDECLOCK.FTH  small version  Jul 2024

\ INCLUDE DSK1.TOOLS 

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

HEX 
1000 CONSTANT IDECARD 

DECIMAL
12 2* USER CRU   \ address of R12 in any Forth workspace 

\ Machine code CRU words
HEX
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
CODE 3SBO  ( -- ) 1D03 ,  NEXT, ENDCODE

: BCD>S ( bcd -- n )
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

: TIME@ ( -- secs min hrs)
    CLOCK-ON 
    UTI-ON 
    secs C@  mins C@  hrs C@ 
    UTI-OFF 
    0SBZ            \ card off 
;     

: DATE@ ( -- day month yr )
    CLOCK-ON 
    day C@ month C@ year C@ 
    0SBO
;
  
\ formatted output 

\ returns a string. can be used to assemble 
:  (##)  ( -- addr len ) 0 <#  # #  #>  ;

: .##    (##) TYPE ;

: .TIME  ( -- ) 
    BASE @ >R  
    HEX TIME@ .## ." :" .##  ." :" .## 
    R> BASE ! ;         

: .DATE  
   BASE @ >R HEX 
   HEX DATE@ .## ." /"  .## ." /" .## 
   R> BASE !  
;

: .DATE&TIME   .DATE  SPACE .TIME  ;

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
