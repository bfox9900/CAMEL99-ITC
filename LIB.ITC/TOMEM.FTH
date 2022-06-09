\ TOMEM.FTH  write strings to buffers
\ based on DxForth with extensions

: 2OVER   3 PICK  3 PICK ;
: &       ( a1 u1 a2 u2 -- a2 u1+u2 ) SWAP 2OVER + 2 PICK CMOVE + ;
: +STRING ( a1 u1 a2 u2 -- a2 u1+u2 ) 2SWAP  & ;
: >MEM ( a u a2 -- a2 u) 0 +STRING ;
: >PAD ( a u -- a2 u ) PAD >MEM ;
