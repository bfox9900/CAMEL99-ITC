\ "PORT"  C STORE C FETCH: read/write 8 bits to IO address set by CRU!

CODE PC! (  c addr -- )
        C304 ,        \ TOS R12 MOV,
        3204 ,        \ TOS 8 LDCR,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

\ "PORT C FETCH" read 8 bits from IO address set by CRU!
CODE PC@ ( CRUadr -- c)
        C304 ,        \ TOS R12 MOV,
        3604 ,        \ TOS 8 STCR,
        0984 ,        \ TOS 8 SRL,
        NEXT,
        ENDCODE
