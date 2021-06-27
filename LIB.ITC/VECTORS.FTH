\ VECTOR.FTH   faster deferred words       Apr 2021 B Fox
\ vector creates words that START faster than using EXECUTE or PERFORM
\ You can use IS to change their run-time action like a deferred word

NEEDS MOV, FROM DSK1.ASM9900
NEEDS WORDS FROM DSK1.TOOLS
NEEDS TO   FROM DSK1.DEFER

: VECTOR ( xt -- )
    CREATE   ,
    ;CODE   *W  W  MOV,      \ fetch address in W->W
            *W+ R5 MOV,      \ move contents of the XT to temp
             R5 ** B,        \ branch to the address
    ENDCODE

\ ' WORDS VECTOR MYWORDS   \ MYWORDS runs words

\ ' PAUSE IS MYWORDS       \ MYWORDS does nothing
