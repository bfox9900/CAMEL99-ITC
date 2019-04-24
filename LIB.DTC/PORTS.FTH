\ "PORT"  C STORE C FETCH: read/write 8 bits to IO address set by CRU!

\ "PORT C STORE" writes 8 bits to IO address in R12, set by CRU!
CODE PC! (  c -- )
        C304 ,        \ TOS R12 MOV,
        3204 ,        \ TOS 8 LDCR,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

\ "PORT C FETCH" read 8 bits from IO address in R12, set by CRU!
CODE PC@ ( -- c)
        0646 , C584 , \ TOS PUSH,
        3604 ,        \ TOS 8 STCR,
        0984 ,        \ TOS 8 SRL,
        NEXT,
        ENDCODE
