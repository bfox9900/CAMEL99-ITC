\ stack  operations for faster loops


CODE 1-DUP   ( n -- n )
             TOS DEC,      \ 1-
             TOS PUSH,     \ DUP
             NEXT,
             ENDCODE

CODE DUP0=   ( n -- n ?)
             TOS PUSH,          \ DUP
             TOS TOS MOV,       \ 0=
             EQ IF, TOS SETO,
             ELSE,  TOS CLR,
             ENDIF,
             NEXT,
             ENDCODE

CODE 1-0=  ( n -- n ?)
             TOS DEC,          \ 1-
             TOS PUSH,         \ DUP
             EQ IF, TOS SETO,  \ 0=
             ELSE,  TOS CLR,
             ENDIF,
             NEXT,
             ENDCODE
