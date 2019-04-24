\ vector.FTH
\ vector creates words that are faster than <variable> @ executed
\ To change them after compilation

NEEDS MOV, FROM DSK1.ASM9900
NEEDS TO   FROM DSK1.DEFER

: VECTOR ( xt -- )
    CREATE   ,
    ;CODE   *W  W  MOV,      \ fetch address in W->W
            *W+ R5 MOV,      \ move contents of the XT
             R5 ** B,        \ branch to the address of the DOER routine
            ENDCODE
