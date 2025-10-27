\ GROM memory dump utilty

NEEDS DUMP FROM DSK1.TOOLS 

HEX
\ GROM access port addresses 
9800 CONSTANT Gread  \ read data (GROM base)
9C00 CONSTANT Gwrite \ write data
9C02 CONSTANT Gaddr  \ write address 

: GROM   ( addr -- ) DUP Gaddr ! Gaddr C! ; \ set GROM address

\ read GROM 
: GC@+   ( -- c)  Gread C@ ; \ read char, auto-incr. address
: GC@    ( addr -- c)  GROM GC@+ ;             \ fetch grom character 
: G@     ( addr -- n)  GROM GC@+ ><  GC@+ OR ; \ fetch grom integer 

\ write GROM 
: GC!+   ( c --) Gwrite C! ;
: GC!    ( c addr --) GROM GC!+ ;
: G!     ( n addr --) GROM SPLIT GC!+ GC!+ ; 

: GROMDUMP ( addr len -- ) 
    ['] G@  IS MEM@    
    ['] GC@ IS MEMC@ 
    (DUMP) ;
