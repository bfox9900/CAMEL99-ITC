\ 'R  'R++  'R--  'R+!  non-standard acces to Return stack

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.ELAPSE.F


\ return address of top of return stack
CODE 'R     ( -- addr) TOS PUSH,  RP TOS MOV, NEXT, ENDCODE

\ increment/decrement value op top of Rstack
CODE 'R++   ( -- )  *RP INC, NEXT, ENDCODE
CODE 'R--   ( -- )  *RP DEC, NEXT, ENDCODE
CODE 'R+!   ( n --)  TOS *RP A,  TOS POP,   NEXT, ENDCODE

CODE 'R0=   ( -- ?)
            TOS PUSH,
           *RP TOS MOV,
            EQ IF,  TOS SETO,
            ELSE,  TOS CLR,
            ENDIF,
            NEXT,
            ENDCODE

CODE 'R=   ( n -- ?)
           *RP TOS C,
            EQ IF, TOS SETO,
            ELSE,  TOS CLR,
            ENDIF,
            NEXT,
            ENDCODE

            
: TEST   FFFF >R  BEGIN  'R--      'R0= UNTIL R> DROP ;

