\ CALLCHAR.FTH  compile string pattern to VDP RAM    Jan 6 2021 BFox
\ THIS CODE IS IN GRAFIX library.
\ Usage: S" 0123456789ABCDEDEF" 65 CALLCHAR ( string can be any length)

NEEDS VC, FROM DSK1.VDPMEM

: >NIB  ( char -- n) DIGIT? 0= ABORT" Bad char" ;

: CALLCHAR ( addr len char --)
        BASE @ VP @ 2>R
        HEX
        8* 800 +
( *optional: clear pattern allows partial strings like BASIC )
        \ DUP 8 0 VFILL
        VP !
        BOUNDS
        DO
           I C@ >NIB  4 LSHIFT
           I 1+ C@ >NIB
           OR VC,
        2 +LOOP
        2R> VP ! BASE !
;
