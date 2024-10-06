
CODE 2DUPXOR     ( w w -- w w ? )
            TOS PUSH,
            2 (SP) TOS XOR,  
            NEXT,
ENDCODE
