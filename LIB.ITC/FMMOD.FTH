\ FMMOD.FTH   required for ANS/ISO Forth, not used normally in CAMEL99

: SM/REM      \ d1 n1 -- n2 n3   symmetric signed division
    2DUP XOR >R
    OVER >R
    ABS >R DABS R> UM/MOD
    SWAP R> ?NEGATE
    SWAP R> ?NEGATE ;

\   High level: arithmetic operators             (c) 31mar95 bjr
: FM/MOD      \ d1 n1 -- n2 n3   floored signed division
    DUP >R
    SM/REM
    DUP 0< IF
        SWAP R> +
        SWAP 1-
    ELSE  R> DROP  THEN ;

