\ polled queued com port input

HEX

\ *FAST Queue pointers in scratchpad  (USER VARIABLE space)
    VARIABLE QHEAD   \ >836C Initialized during setup
    VARIABLE QTAIL   \ >836E        "    "

400 MALLOC CONSTANT Q

DECIMAL
CODE STRAIGHT ( addr n -- )
         0 LIMI,
         R12 RPUSH,
         PORT @@ R12 MOV,       \ select the 9902
         *SP+ W MOV,                \ baseindex->W
          W TOS ADD,            \ calc last address
         BEGIN,
            W TOS CMP,
         NE WHILE,
            21 TB,
            EQ IF,
              *W+ 8 STCR,          \ put char in buf & inc
               18 SBO,             \ clr rcv buffer
            ENDIF,
         REPEAT,
         R12 RPOP,
         2 LIMI,                \ RE-ENABLE INTERRUPTS
         NEXT,
ENDCODE

: STRAIGHT ( c-addr +n -- +n')  \ get line from terminal
        BOUNDS
        DO
           KEY DUP 3 = ABORT" ^C" I C!
        LOOP ;
