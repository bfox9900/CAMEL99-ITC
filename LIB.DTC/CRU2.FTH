\ CRU support for CAMEL99   BJFOX 6FEB2018
\ INCLUDE DSK1.TOOLS

HERE
HEX
CODE CRU! ( CRUaddr -- )   \ load CRU adr to R12
        C304 ,       \ TOS R12 MOV,
        C136 ,       \ TOS POP,
        NEXT,
        ENDCODE

CODE CRU@  ( -- CRUaddr ) \ read R12 to TOS
        0646 , C584 , \ TOS PUSH,
        C10C ,        \ R12 TOS MOV,
        NEXT,
        ENDCODE

\ *set the CRU address before using these words*

\ fastest for bit 0
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

\ slower but bit variable
CODE SBO ( c -- )
        0264 , 1D00 , \ TOS 1D00 ORI,
        0484 ,        \ TOS X,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

CODE SBZ ( c -- )
        0264 , 1E00 , \ TOS 1E00 ORI,
        0484 ,        \ TOS X,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

CODE TB ( c -- ? ) \ builds instruction at runtime Why?
        C004 ,        \ TOS R0 MOV,
        04C4 ,        \ TOS CLR,
        0260 , 1F00 , \ R0 1F00 ORI,
        0480 ,        \ R0 X,
        1601 , 0704 , \ EQ IF, TOS SETO, ENDIF,
        NEXT,
        ENDCODE

CODE LDCR ( data bits -- ) \ cru base must be set with CRU!
         *SP+   R0 MOV,   \ pop data -> R0
          TOS 000F ANDI,  \ instruction built in TOS
          NE IF,
             TOS 8 CI,
             LTE IF,
                 R0 SWPB,   \ swap the data byte
             ENDIF,
          ENDIF,
          TOS 06 SLA,
          TOS 3000 ORI,   \ create: R0 bits LDCR,
          TOS X,          \ execute the intruction
          TOS POP,
     NEXT,
     ENDCODE

\ Performs the TMS9900 STCR instruction. The bit count is n1.
\ The CRU base is set first with CRU! The returned value is n2.
CODE STCR ( bits --- n )
     R0 CLR,       \
     TOS 000F ANDI,
     TOS R2 MOV,
     TOS 06 SLA,
     TOS 3400 ORI,  \ create: R0 bits STCR,
     TOS X,         \ execute the intruction
     R2 R2 MOV,
     NE IF,
         R2 08 CI,
         LTE IF,
              R0 SWPB,
         ENDIF,
     ENDIF,
     R0 TOS MOV,
     NEXT,
     ENDCODE


HERE SWAP - DECIMAL  CR . .( bytes)
