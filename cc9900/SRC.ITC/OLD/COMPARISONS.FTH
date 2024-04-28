\ ==================================================================
cr .( COMPARISON)

CODE 0=  ( n -- ?)         \ used 6X in kernel
     TOS NEG,
     NE IF,
         TOS SETO,
     ENDIF,
     TOS INV,
     NEXT,
     ENDCODE

CODE =     ( n n -- ?)     \ Used 4X in Kernel
             *SP+ TOS CMP,
              TOS CLR,
              EQ IF,
                TOS SETO,
              ENDIF,
              NEXT,
              ENDCODE

\ stack setter routines are the smallest way to do this on 9900
\ using +CODE allows all these routines to jump inside CODE .. ENDCODE
CODE 0<     ( n -- flag )
              TOS TOS MOV,
              TOS SETO,
              @@1 JLT,
              TOS CLR,          \ Common FALSE stack setter
@@1:          NEXT,
              ENDCODE

CODE U<    ( n1 n2 -- flag)
             *SP+ TOS CMP,
              TOS SETO,
              @@1 JL,
              TOS CLR,
@@1:          NEXT,
              ENDCODE

CODE >     ( n1 n2 -- flag)
             *SP+ TOS CMP,
              TOS SETO,
              @@1 JGT,
              TOS CLR,
@@1:          NEXT,
              ENDCODE

CODE <     ( n1 n2 -- flag)
             *SP+ TOS CMP,
              TOS SETO,
              @@1 JLT,
              TOS CLR,
@@1:          NEXT,
              ENDCODE
ENDCODE
