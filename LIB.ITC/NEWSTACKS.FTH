\ bigger data stacks in Low RAM if tou need them

HEX
: NEW-RSTACK  4000 ['] RP0 >BODY ! ;
: NEW-DSTACK  3C00 ['] SP0 >BODY ! ;

: NEW-STACKS   NEW-DSTACK NEW-RSTACK ABORT ;
