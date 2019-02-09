\ STRAIGHT a word from PolyForth
\ Accept chars into a buffer with no echo
\ capable of reading continuos data at 9600 bps

NEEDS MOV, FROM DSK1.ASM9900

DECIMAL
VARIABLE PORT      1340 PORT !

\ Interrupt timer provides an easy 4 second timeout
8378 CONSTANT TIMER    ( 0 .. FF x 16mS)

CREATE GETOUT
         R12 RPOP,
         TOS CLR,           \ tos=0 all good
         NEXT,

CODE STRAIGHT ( addr len -- len')
             R12 RPUSH,
        *SP+ R1  MOV,        \ len -> R1
        *SP+ W   MOV,        \ 'buffer -> W
         W   R1  ADD,        \ R1 has last buffer location
         TOS CLR,            \ clr error flag.

         PORT @@ R12 MOV,    \ enable selected port
         EQ IF,              \ if port=0
              TOS -2 LI,     \ error -2 = no port selected
              GETOUT @@ B,
         ENDIF,

         BEGIN,
            TIMER @@ CLR,    \ reset interrupt timer
            BEGIN,
               TIMER @@ 00FF CI,  \ did we timeout?
               EQ IF,
                    TOS SETO,     \ yes, tos=-1, timeout error
                    GETOUT @@ B,  \ self explanatory
                ENDIF,
               21 TB,        \ wait for UART rcv buffer
            EQ UNTIL,
           *W+ 8 STCR,       \ read the char
              18 SBZ,        \ reset char buffer
              TOS INC,       \ count the char we read
           W  R1 CMP,        \ end of buffer?
         EQ UNTIL,
         GETOUT @@ B,
         ENDCODE
