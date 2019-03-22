
CODE QCKEY? ( -- n )      \  "com-key"
         R12 RPUSH,
         PORT @@ R12 MOV,    \ select the 9902
         TOS PUSH,
         TOS CLR,
         21 TB,              \ test if char ready
         EQ IF,
            16 SBO,          \ set RTS (handshake rcv off)
            TOS 8 STCR,      \ read the char
            TOS 8 SRL,       \ shift to other byte
               18 SBZ,       \ reset 9902 rcv buffer
         ENDIF,
         16 SBZ,       \ reset RTS
         R12 RPOP,
         NEXT,
         ENDCODE
