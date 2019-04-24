\ port fetch, port store

INCLUDE DSK1.ASM9900

HEX
CODE PC@   ( cru -- c ) C304 , 3604 ,  NEXT,  ENDCODE
CODE PC!   ( c cru -- ) C304 , 3236 , C136 , NEXT, ENDCODE

\ CODE PC@     ( cru -- c )
\             TOS R12 MOV,
\             TOS 8 STCR,
\             NEXT,
\            ENDCODE

\ CODE PC!     ( c cru -- )
\             TOS R12 MOV,
\            *SP+ 8 LDCR,
\             TOS POP,
\             NEXT,
\             ENDCODE

