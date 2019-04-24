\ TI-FORTH versions with CRU!
\ Performs a TMS9900 LDCR instruction. The value n1 is transferred
\ to the CRU with a field width of n2 bits.

\ NEEDS .S    FROM DSK1.TOOLS
\ NEEDS MOV   FROM DSK1.ASM9900
\ NEEDS CRU!  FROM DSK1.CRU

HEX
CODE LDCR ( data bits -- )
     C036 ,          \ *SP+   R0 MOV,
     0244 , 0F ,     \ TOS 000F ANDI,
     1304 ,          \ NE IF,
     0284 , 08 ,     \     TOS 8 CI,
     1501 ,          \     LTE IF,
     06C0 ,          \          R0 SWPB,
                     \     ENDIF,
                     \ ENDIF,
    0A6A ,           \ TOS 06 SLA,
    0264 , 3000 ,    \ TOS 3000 ORI,
    0484 ,           \ TOS X,
    C136 ,           \ TOS POP,
    NEXT,
    ENDCODE

\ Performs the TMS9900 STCR instruction. The bit count is n1.
\ The CRU base is set first with CRU! The returned value is n2.
CODE STCR ( bits --- n )
     C044 ,         \ TOS R1 MOV,
     04C4 ,         \ TOS CLR,
     0241 , 0F ,    \ R1 000F ANDI,
     C081 ,         \ R1 R2 MOV,
     0A61 ,         \ R1 06 SLA,
     0261 , 3400 ,  \ R1 3400 ORI,
     0481 ,         \ R1 X,
     C082 ,         \ R2 R2 MOV,
     1304 ,         \ NE IF,
     0282 , 08 ,    \    R2 08 CI,
     1501 ,         \    LTE IF,
     06C4 ,         \        TOS SWPB,
                    \    ENDIF,
                    \ ENDIF,
     NEXT,
     ENDCODE