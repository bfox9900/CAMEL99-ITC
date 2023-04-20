\ S T R I N G  T O  N U M B E R   C O N V E R S I O N
[CC] CR .( CAMEL FORTH Number conversion)
 HEX
TARGET-COMPILING

SLOWER [IF]
    : BASE@   BASE @ ;
[ELSE]
 CODE BASE@
             TOS PUSH,
             R1 STWP,
             2A (R1) TOS MOV,
             NEXT,
             ENDCODE
[THEN]

SLOWER [IF]

: DIGIT?  ( c -- n -1) \ if c is a valid digit
 \             -- x  0  \ otherwise
  DUP  39 > 100 AND +    \ silly looking
  DUP 140 > 107 AND -  t[CHAR] 0 -   \ but it works!
  DUP BASE@ U< ;         \ 48 Bytes

[ELSE]

CODE DIGIT?   ( char -- n f )
            TOS PUSH,          \  dup char
            TOS -30 ADDI,      \  convert char to number
            TOS 9 CMPI,
            HI IF,
               TOS -7 ADDI,
               TOS 9 CMPI,
               LO IF,
                   TOS CLR,  \ bad result
                   NEXT,
               ENDIF,
            ENDIF,
            R1 STWP,       \ multi-tasking friendly
            TOS 2A (R1) CMP, \ USER var 2A (BASE)
            HE IF,
               TOS CLR,    \ bad result
               NEXT,
            ENDIF,
            TOS *SP MOV,   \ replace char with no.
            TOS SETO,      \ set flag to true
            NEXT,
            ENDCODE        \ 4 bytes bigger than Forth, much faster

[THEN]

: UD*      ( ud1 u2 -- ud3) DUP>R * SWAP R> UM* ROT + ;

: >NUMBER  ( ud adr u -- ud' adr' u' )
            BEGIN
            DUP WHILE
                OVER C@ DIGIT?
                0= IF DROP EXIT THEN
                >R 2SWAP BASE@ UD*
                R> M+ 2SWAP
                1 /STRING
            REPEAT ;

\ *G This is smaller than original ?NUMBER but ***FLAG LOGIC IS REVERSED***
: NUMBER?  ( addr len -- n ?)      \ ?=0 is good conversion
           (          -- addr len) \ bad conversion
            OVER C@ T[CHAR] - = DUP>R     \ save flag for later
            IF 1 /STRING THEN             \ remove minus sign
            0 0  2SWAP >NUMBER NIP NIP    \ convert the number
            R> IF SWAP NEGATE SWAP THEN   \ negate if needed
;
