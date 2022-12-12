
INCLUDE DSK1.LOWTOOLS

CODE FILL   ( addr cnt char -- )
            *SP+ R0 MOV,
            *SP+ W MOV,
             TOS SWPB,

             R0 R3 MOV,
             R3 1 ANDI,
             EQ IF,
                  TOS R3 MOV,
                  R3 SWPB,
                  R3 TOS ADD,
                  BEGIN,
                     TOS *W+ MOV,  \ 2 chars are in TOS register
                     R0 DECT,       \ decr. count by two
                  EQ UNTIL,         \ loop until r0=0
             ELSE,
                \ odd count loop
                 BEGIN,
                   TOS *W+ MOVB,
                   R0 DEC,
                 EQ UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE



CODE TEST

       NEXT,
       ENDCODE

CODE TEST
       TOS SWPB,
       TOS TOS ADDB,
       NEXT,
       ENDCODE
